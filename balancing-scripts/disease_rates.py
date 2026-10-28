"""Estimates how often huwans get sick and how many hospital beds that keeps busy.

Re-implements the disease progress functions of classes/inhabitants/healthcare.lua
(get_*_disease_progress and the workplace accident progress). Keep it in sync when that logic changes.

Inputs:
- diseases and disease categories from constants/diseases.lua
- base disease rates from constants/inhabitants.lua
- disease susceptibilities from constants/castes.lua (a multiplier on the frequency: higher = more cases)
- workplace disease rates from constants/buildings.lua
- water contamination from constants/drinking-water.lua
- bed speed from constants/buildings.lua (the hospital's speed; every bed building should have the same)

Model:
- New cases per minute come from the health, sanity and accident categories of every inhabitant, and from
  the workplaces of the employed ones (an average job, as if there was one of every workplace).
- Food poisoning and waterborne diseases come from the diet's average poisoning risk (--food-risk) and the
  contamination of the drinking water (--water), the same for every house.
- Bed demand is the bed-minutes those cases need per minute, assuming every treatable case gets a bed
  right away. That's an upper bound: natural recovery only cuts it short for patients who wait.
  Complications of treatments are added (one level deep); escalations are left out, because they only
  happen to untreated cases.
- Not modelled: malnutrition/dehydration (only without food/water), birth defects (per birth),
  zoonosis unless --animal-farms is given.

Contagion model (--contagion), re-implements social_meeting in classes/inhabitants/housing-environment.lua
and InhabitantGroup.make_sick in classes/inhabitants.lua:
- A house has K * V^EXPONENT social meetings per minute (V = inhabitants * caste social coefficient of its
  social environment; K and EXPONENT from the meeting constants in constants/inhabitants.lua). Per meeting, every sick huwan infects with the disease's contagiousness, and the
  infection lands with the chance susceptible / healthy. So per sick huwan: beta = meetings * contagiousness.
- That gives an SIR model where the success chance is S / (S + R), not S / N:
      dS = -beta*I*S/(S+R) + w*R,  dI = beta*I*S/(S+R) - gamma*I,  dR = gamma*I - w*R
  with gamma = 1 / natural recovery, w = 1 / immunity duration and R0 = beta / gamma.
- Without immunity the success chance is always 1, so a disease with R0 > 1 infects everyone. With waning
  immunity it settles at a steady infected share of (w/gamma) / (R0/(R0-1) + w/gamma).
- Worst case: untreated, no deaths or escalations, no randomness that ends small outbreaks early.

Usage, from the mod folder:
    python3 balancing-scripts/disease_rates.py
    python3 balancing-scripts/disease_rates.py -c plasma -H 20 -S 15 --employed 0.6
    python3 balancing-scripts/disease_rates.py --diseases
    python3 balancing-scripts/disease_rates.py --contagion --neighbours 500 --immunity rare-cold=300
    python3 balancing-scripts/disease_rates.py --rate sanity=0.5 --workload depression=10
    python3 balancing-scripts/disease_rates.py --food-risk 0.3 --water drinkable-water
"""
import argparse
import math
import re
from collections import defaultdict
from pathlib import Path

MOD = Path(__file__).resolve().parent.parent

TICKS_PER_MINUTE = 3600
TIME = {"second": 60, "minute": 3600, "hour": 216000, "nauvis_day": 25000}
TIME["nauvis_week"] = TIME["nauvis_day"] * 7
TIME["nauvis_month"] = TIME["nauvis_week"] * 4

# ward for each curing facility, everything else is general medicine
BED_KINDS = {"psych_ward": "psych ward", "intensive_care_unit": "ICU", "gene_clinic": "gene clinic"}
GENERAL = "general"

# categories that every inhabitant is exposed to, with the stat that lowers them
POPULATION_CATEGORIES = ["health", "sanity", "accident"]


def evaluate_time(expression):
    """Evaluates expressions like '3 * Time.nauvis_week' to ticks. math.huge is infinite."""
    if expression.strip() == "math.huge":
        return math.inf
    m = re.fullmatch(r"([\d.]+) \* Time\.(\w+)", expression.strip())
    return float(m.group(1)) * TIME[m.group(2)]


def parse_diseases():
    src = (MOD / "constants" / "diseases.lua").read_text()
    body = src[: src.index("-- test diseases")]
    diseases = {}
    for m in re.finditer(r"\n    \[(\d+)\] = \{(.*?)\n    \}", body, re.S):
        disease_id, text = m.groups()

        def field(pattern, convert=str):
            found = re.search(pattern, text)
            return convert(found.group(1)) if found else None

        name = field(r'name = "([\w-]+)"')
        recovery = field(r"natural_recovery = ([^,\n]+)")
        immunity = field(r"\n\s+immunity_duration = ([^,\n]+)")
        vaccine_immunity = field(r"vaccine_immunity_duration = ([^,\n]+)")
        diseases[name] = {
            "id": int(disease_id),
            "workload": field(r"curing_workload = ([\d.]+)", float),
            "treatable": "is_treatable = false" not in text,
            "bed": BED_KINDS.get(field(r"curing_facility = Type\.(\w+)"), GENERAL),
            "recovery_minutes": evaluate_time(recovery) / TICKS_PER_MINUTE if recovery else None,
            "lethality": field(r"\n\s+lethality = ([\d.]+)", float) or 0,
            "escalation": field(r'escalation = "([\w-]+)"'),
            "escalation_probability": field(r"escalation_probability = ([\d.]+)", float) or 0,
            "complication": field(r'complication = "([\w-]+)"'),
            "complication_probability": field(r"complication_probability = ([\d.]+)", float) or 0,
            "complication_lethality": field(r"complication_lethality = ([\d.]+)", float),
            "contagiousness": field(r"contagiousness = ([\d.]+)", float),
            "immunity_minutes": evaluate_time(immunity) / TICKS_PER_MINUTE if immunity else None,
            "vaccine_immunity_minutes": evaluate_time(vaccine_immunity) / TICKS_PER_MINUTE if vaccine_immunity else None,
        }
    return diseases


def parse_categories():
    src = (MOD / "constants" / "diseases.lua").read_text()
    block = src[src.index("Diseases.categories = {") :]
    block = block[: block.index("\n}\n")]
    categories = {}
    for m in re.finditer(r"\[DiseaseCategory\.(\w+)\] = \{(.*?)\}", block, re.S):
        category, text = m.groups()
        categories[category] = {name: float(w) for name, w in re.findall(r'\["([\w-]+)"\] = ([\d.]+)', text)}
    return categories


def parse_rates():
    """Returns the base disease rates per inhabitant per tick by category name."""
    src = (MOD / "constants" / "inhabitants.lua").read_text()
    return {
        category: float(per_minute) / TICKS_PER_MINUTE
        for category, per_minute in re.findall(
            r"InhabitantsConstants\.(\w+)_disease_rate = ([\d.]+) \* Unit\.per_minute", src
        )
    }


def parse_water_contamination():
    """Returns the contamination by drinking water name."""
    src = (MOD / "constants" / "drinking-water.lua").read_text()
    return {
        name: float(value)
        for name, value in re.findall(r'\["([\w-]+)"\] = \{[^}]*?contamination = ([\d.]+)', src)
    }


def parse_castes():
    src = (MOD / "constants" / "castes.lua").read_text()
    castes = {}
    for m in re.finditer(r'\n        name = "(\w+)",(.*?)\n    \}', src, re.S):
        name, body = m.groups()
        if re.search(r"\n\s+enabled = false", body):
            continue
        castes[name] = {
            category: float(re.search(rf"{category}_disease_susceptibility = ([\d.]+)", body).group(1))
            for category in POPULATION_CATEGORIES
        }
        castes[name]["social"] = float(re.search(r"social_coefficient = ([\d.]+)", body).group(1))
    return castes


def parse_meeting_curve():
    """Returns (meetings per tick per social value^exponent, exponent), derived like the postprocessing of
    constants/inhabitants.lua."""
    src = (MOD / "constants" / "inhabitants.lua").read_text()

    def constant(name):
        return re.search(rf"InhabitantsConstants\.{name} = ([^\n]+)", src).group(1).strip()

    meetings_per_day = float(re.fullmatch(r"([\d.]+) / Time\.nauvis_day", constant("reference_meeting_rate")).group(1))
    exponent = float(constant("meeting_exponent"))
    reference = float(constant("reference_social_value"))
    return meetings_per_day / TIME["nauvis_day"] / reference ** exponent, exponent


def parse_buildings():
    """Returns (cases per minute of an average worker, split by work category; bed speed in operations
    per minute). The average worker is weighted by job count, as if there was one of every workplace."""
    src = (MOD / "constants" / "buildings.lua").read_text()
    cases = defaultdict(float)
    jobs = 0
    speed = None
    for m in re.finditer(r'\n    \["([\w-]+)"\] = \{(.*?)\n    \},', src, re.S):
        name, body = m.groups()
        if name.startswith("test-"):
            continue
        workforce = re.search(
            r"count = (\d+).*?disease_category = DiseaseCategory\.(\w+).*?"
            r"disease_frequency_fully_staffed = ([\d.]+) \* Unit\.per_minute",
            body,
            re.S,
        )
        if workforce:
            count, category, frequency = workforce.groups()
            cases[category] += float(frequency)
            jobs += int(count)
        if name == "hospital":
            m_speed = re.search(r"speed = ([\d.]+) / Time\.(\w+)", body)
            speed = float(m_speed.group(1)) / TIME[m_speed.group(2)] * TICKS_PER_MINUTE
    return {category: rate / jobs for category, rate in cases.items()}, speed


def population_rate(base_rate, susceptibility, category, health, sanity):
    """Cases per inhabitant per minute, see get_*_disease_progress in healthcare.lua."""
    divisor = {"health": health + 1, "sanity": sanity + 1, "accident": health + sanity + 1}[category]
    return TICKS_PER_MINUTE * base_rate / divisor * susceptibility


def split_by_disease(category_rates, categories):
    """Turns cases per minute by category into cases per minute by disease."""
    cases = defaultdict(float)
    for category, rate in category_rates.items():
        weights = categories[category]
        total = sum(weights.values())
        for name, weight in weights.items():
            cases[name] += rate * weight / total
    return cases


def bed_demand(cases, diseases, speed):
    """Busy beds by bed kind, including one level of complications."""
    demand = defaultdict(float)
    for name, rate in cases.items():
        disease = diseases[name]
        if not disease["treatable"]:
            continue
        demand[disease["bed"]] += rate * disease["workload"] / speed
        if disease["complication"]:
            complication = diseases[disease["complication"]]
            if complication["treatable"]:
                extra = rate * disease["complication_probability"]
                demand[complication["bed"]] += extra * complication["workload"] / speed
    return demand


def city_cases(args, castes, base_rates, work_rates):
    category_rates = defaultdict(float)
    for caste_name in args.castes:
        susceptibility = castes[caste_name]
        for category in POPULATION_CATEGORIES:
            rate = population_rate(base_rates[category], susceptibility[category], category, args.health, args.sanity)
            category_rates[category] += args.population * rate
    workers = args.population * len(args.castes) * args.employed
    for category, rate in work_rates.items():
        category_rates[category] += workers * rate
    population = args.population * len(args.castes)
    if args.animal_farms:
        zoonosis = TICKS_PER_MINUTE * math.sqrt(args.animal_farms) * base_rates["zoonosis"]
        category_rates["zoonosis"] += population * zoonosis
    if args.food_risk:
        category_rates["food_poisoning"] += population * TICKS_PER_MINUTE * args.food_risk * base_rates["food_poisoning"]
    if args.contamination:
        category_rates["waterborne"] += population * TICKS_PER_MINUTE * args.contamination * base_rates["waterborne"]
    for category, factor in args.rate.items():
        category_rates[category] *= factor
    return category_rates


def print_city(args, castes, base_rates, categories, diseases, work_rates, speed):
    population = args.population * len(args.castes)
    category_rates = city_cases(args, castes, base_rates, work_rates)
    cases = split_by_disease(category_rates, categories)
    demand = bed_demand(cases, diseases, speed)

    print(f"City: {args.population} inhabitants each of {', '.join(args.castes)} ({population} total)")
    print(f"health {args.health}, sanity {args.sanity}, {args.employed:.0%} employed, bed speed {speed:g} op/min")
    print(f"diet poisoning risk {args.food_risk:g}, drinking {args.water}")
    print()
    print("New cases per minute by category:")
    for category, rate in sorted(category_rates.items(), key=lambda x: -x[1]):
        print(f"  {category:<16} {rate:7.2f}")
    print(f"  {'total':<16} {sum(category_rates.values()):7.2f}")
    print()
    print("Busy beds (upper bound: every treatable case gets a bed right away):")
    for kind, beds in sorted(demand.items(), key=lambda x: -x[1]):
        print(f"  {kind:<16} {beds:7.1f}   ({beds / population * 1000:.1f} per 1000 inhabitants)")
    print()

    print("Busy beds per 1000 inhabitants, general medicine / all wards, by health (rows) and sanity (columns):")
    levels = [0, 5, 10, 20, 40]
    print("  " + "".join(f"{'S=' + str(s):>14}" for s in levels))
    for health in levels:
        row = []
        for sanity in levels:
            sweep = argparse.Namespace(**{**vars(args), "health": health, "sanity": sanity})
            d = bed_demand(split_by_disease(city_cases(sweep, castes, base_rates, work_rates), categories), diseases, speed)
            general = d[GENERAL] / population * 1000
            wards = sum(v for k, v in d.items() if k != GENERAL) / population * 1000
            row.append(f"{general:5.1f} / {wards:4.1f}")
        print(f"  H={health:<3}" + "".join(f"{cell:>14}" for cell in row)[2:])


def print_diseases(diseases, categories):
    direct = defaultdict(list)
    for category, weights in categories.items():
        for name in weights:
            direct[name].append(category)
    escalation_of = defaultdict(list)
    complication_of = defaultdict(list)
    for name, disease in diseases.items():
        if disease["escalation"]:
            escalation_of[disease["escalation"]].append(name)
        if disease["complication"]:
            complication_of[disease["complication"]].append(name)

    print(f"{'disease':<28}{'bed':<13}{'ops':>4}{'recovery':>10}{'lethal':>8}  sources")
    for name, disease in sorted(diseases.items(), key=lambda x: x[1]["id"]):
        recovery = f"{disease['recovery_minutes']:.0f} min" if disease["recovery_minutes"] else "never"
        workload = f"{disease['workload']:g}" if disease["treatable"] else "-"
        sources = (
            direct[name]
            + [f"escalation of {e}" for e in escalation_of[name]]
            + [f"complication of {c}" for c in complication_of[name]]
        )
        flag = ""
        # design rule: specialised diseases need a long natural recovery or have to be preventable escalations
        # the ICU is exempt: acute emergencies are its nature
        if (
            disease["bed"] not in (GENERAL, BED_KINDS["intensive_care_unit"])
            and direct[name]
            and disease["recovery_minutes"]
            and disease["recovery_minutes"] < 60
        ):
            flag = "  <- specialised, short recovery, not only an escalation"
        print(
            f"{name:<28}{disease['bed']:<13}{workload:>4}{recovery:>10}{disease['lethality']:>8.0%}  "
            f"{', '.join(sources) or '-'}{flag}"
        )


def meetings_per_minute(neighbours, social_coefficient, meeting_curve):
    """Social meetings per minute of a house whose social environment holds the given inhabitants."""
    coefficient, exponent = meeting_curve
    return TICKS_PER_MINUTE * coefficient * (neighbours * social_coefficient) ** exponent


def simulate_wave(beta, gamma, w, minutes=20000, dt=0.05):
    """Simulates the first outbreak from 0.1% infected. Returns (peak infected share, minutes to peak)."""
    s, i, r = 0.999, 0.001, 0.0
    peak, peak_time = i, 0.0
    t = 0.0
    while t < minutes:
        healthy = s + r
        infections = beta * i * s / healthy if healthy > 0 else 0
        recoveries = gamma * i
        waning = w * r
        s += (waning - infections) * dt
        i += (infections - recoveries) * dt
        r += (recoveries - waning) * dt
        t += dt
        if i > peak:
            peak, peak_time = i, t
        elif i < peak / 100:
            break
    return peak, peak_time


def steady_infected(r0, gamma, w):
    """Infected share once the outbreak has settled; None means everyone stays infected."""
    if r0 <= 1:
        return 0.0
    if w is None:
        return None
    return (w / gamma) / (r0 / (r0 - 1) + w / gamma)


def print_contagion(args, diseases, castes, meeting_curve):
    social = sum(castes[c]["social"] for c in args.castes) / len(args.castes)
    meetings = meetings_per_minute(args.neighbours, social, meeting_curve)
    contagious = sorted(
        (item for item in diseases.items() if item[1]["contagiousness"]), key=lambda x: x[1]["id"]
    )

    print(f"Social environment: {args.neighbours} inhabitants of {', '.join(args.castes)} "
          f"-> {meetings:.2f} meetings per minute per house")
    print("Worst case: untreated, no deaths or escalations.")
    print()
    print(f"{'disease':<24}{'R0':>6}{'recovery':>10}{'immunity':>10}{'peak':>8}{'at':>9}"
          f"{'steady':>8}{'herd':>7}{'vacc/min':>10}")
    for name, disease in contagious:
        gamma = 1 / disease["recovery_minutes"]
        beta = meetings * disease["contagiousness"]
        r0 = beta / gamma
        immunity = disease["immunity_minutes"]
        w = None if immunity is None else (0.0 if math.isinf(immunity) else 1 / immunity)
        immunity_text = "none" if immunity is None else ("life" if math.isinf(immunity) else f"{immunity:.0f}m")

        steady = steady_infected(r0, gamma, w)
        if r0 <= 1:
            peak_text, at_text = "-", "-"
        else:
            peak, peak_time = simulate_wave(beta, gamma, w or 0.0) if w is not None else (1.0, None)
            peak_text = f"{peak:.0%}"
            at_text = f"{peak_time:.0f}m" if peak_time is not None else "-"
        steady_text = "all" if steady is None else f"{steady:.1%}"

        herd = max(0.0, 1 - 1 / r0)
        vaccine = disease["vaccine_immunity_minutes"]
        if vaccine is None:
            vaccinations = "-"
        elif math.isinf(vaccine):
            vaccinations = "births"
        else:
            vaccinations = f"{herd * 1000 / vaccine:.2f}"

        flag = ""
        if steady is None and r0 > 1:
            flag = "  <- no immunity, infects everyone"
        elif steady > args.max_endemic:
            flag = "  <- endemic"
        print(f"{name:<24}{r0:>6.2f}{disease['recovery_minutes']:>9.0f}m{immunity_text:>10}{peak_text:>8}"
              f"{at_text:>9}{steady_text:>8}{herd:>7.0%}{vaccinations:>10}{flag}")
    print()
    print("peak/at: first wave from 0.1% infected; steady: infected share once settled;")
    print("herd: immune share of the healthy that stops the spread; vacc/min: vaccinations per minute")
    print("per 1000 inhabitants to hold it (births: lifelong vaccine, only newcomers need it)")
    print()

    sizes = [20, 100, 500, 2000]
    print("R0 by social environment size (inhabitants):")
    print(f"{'disease':<24}" + "".join(f"{size:>8}" for size in sizes))
    for name, disease in contagious:
        gamma = 1 / disease["recovery_minutes"]
        r0s = [meetings_per_minute(size, social, meeting_curve) * disease["contagiousness"] / gamma
               for size in sizes]
        print(f"{name:<24}" + "".join(f"{r0:>8.2f}" for r0 in r0s))


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("-p", "--population", type=int, default=1000, help="inhabitants per caste (default 1000)")
    parser.add_argument("-c", "--castes", nargs="+", help="castes in the city (default: all enabled)")
    parser.add_argument("-H", "--health", type=float, default=10, help="average health (default 10)")
    parser.add_argument("-S", "--sanity", type=float, default=10, help="average sanity (default 10)")
    parser.add_argument("--employed", type=float, default=0.5, help="share of inhabitants with a job (default 0.5)")
    parser.add_argument("--animal-farms", type=int, default=0, help="active animal farms, for zoonosis")
    parser.add_argument(
        "--food-risk", type=float, default=0, help="average poisoning risk of the diet, for food poisoning (default 0)"
    )
    parser.add_argument(
        "--water", default="clean-water", help="drinking water, for waterborne diseases (default clean-water)"
    )
    parser.add_argument(
        "--rate", action="append", default=[], metavar="CATEGORY=FACTOR", help="try a factor on a category's rate"
    )
    parser.add_argument(
        "--workload", action="append", default=[], metavar="DISEASE=OPS", help="try another workload for a disease"
    )
    parser.add_argument("--diseases", action="store_true", help="list every disease instead of the city estimate")
    parser.add_argument(
        "--contagion", action="store_true", help="model the spread of the contagious diseases instead"
    )
    parser.add_argument(
        "--neighbours", type=int, default=200, help="inhabitants in a house's social environment (default 200)"
    )
    parser.add_argument(
        "--max-endemic", type=float, default=0.05, help="steady infected share that gets flagged (default 0.05)"
    )
    parser.add_argument(
        "--immunity", action="append", default=[], metavar="DISEASE=MINUTES",
        help="try another immunity duration for a disease (0 = none, inf = lifelong)"
    )
    parser.add_argument(
        "--contagiousness", action="append", default=[], metavar="DISEASE=X",
        help="try another contagiousness for a disease"
    )
    args = parser.parse_args()

    diseases = parse_diseases()
    categories = parse_categories()
    castes = parse_castes()
    work_rates, speed = parse_buildings()
    args.rate = {k: float(v) for k, v in (item.split("=") for item in args.rate)}
    for item in args.workload:
        name, ops = item.split("=")
        diseases[name]["workload"] = float(ops)
    for item in args.immunity:
        name, minutes = item.split("=")
        diseases[name]["immunity_minutes"] = float(minutes) or None
    for item in args.contagiousness:
        name, value = item.split("=")
        diseases[name]["contagiousness"] = float(value)
    args.castes = args.castes or list(castes)
    contamination = parse_water_contamination()
    if args.water not in contamination:
        parser.error(f"unknown drinking water: {args.water} (known: {', '.join(contamination)})")
    args.contamination = contamination[args.water]
    unknown = set(args.castes) - set(castes)
    if unknown:
        parser.error(f"unknown or disabled castes: {', '.join(sorted(unknown))}")

    if args.diseases:
        print_diseases(diseases, categories)
    elif args.contagion:
        print_contagion(args, diseases, castes, parse_meeting_curve())
    else:
        print_city(args, castes, parse_rates(), categories, diseases, work_rates, speed)


if __name__ == "__main__":
    main()
