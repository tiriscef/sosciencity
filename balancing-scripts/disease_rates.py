"""Estimates how often huwans get sick and how many hospital beds that keeps busy.

Re-implements the disease progress functions of classes/inhabitants/healthcare.lua
(get_*_disease_progress and the workplace accident progress). Keep it in sync when that logic changes.

Inputs:
- diseases and disease categories from constants/diseases.lua
- base disease rates from constants/inhabitants.lua
- disease susceptibilities from constants/castes.lua (a multiplier on the frequency: higher = more cases)
- workplace disease rates from constants/buildings.lua
- bed speed from constants/buildings.lua (the hospital's speed; every bed building should have the same)

Model:
- New cases per minute come from the health, sanity and accident categories of every inhabitant, and from
  the workplaces of the employed ones (an average job, as if there was one of every workplace).
- Bed demand is the bed-minutes those cases need per minute, assuming every treatable case gets a bed
  right away. That's an upper bound: natural recovery only cuts it short for patients who wait.
  Complications of treatments are added (one level deep); escalations are left out, because they only
  happen to untreated cases.
- Not modelled: malnutrition/dehydration (only without food/water), birth defects (per birth), infections
  (social contagion), food and water poisoning, zoonosis unless --animal-farms is given.

Usage, from the mod folder:
    python3 balancing-scripts/disease_rates.py
    python3 balancing-scripts/disease_rates.py -c plasma -H 20 -S 15 --employed 0.6
    python3 balancing-scripts/disease_rates.py --diseases
    python3 balancing-scripts/disease_rates.py --rate sanity=0.5 --workload depression=10
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
    """Evaluates expressions like '3 * Time.nauvis_week' to ticks."""
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
    return castes


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
    for category, factor in args.rate.items():
        category_rates[category] *= factor
    if args.animal_farms:
        zoonosis = TICKS_PER_MINUTE * math.sqrt(args.animal_farms) * base_rates["zoonosis"]
        category_rates["zoonosis"] += args.population * len(args.castes) * zoonosis
    return category_rates


def print_city(args, castes, base_rates, categories, diseases, work_rates, speed):
    population = args.population * len(args.castes)
    category_rates = city_cases(args, castes, base_rates, work_rates)
    cases = split_by_disease(category_rates, categories)
    demand = bed_demand(cases, diseases, speed)

    print(f"City: {args.population} inhabitants each of {', '.join(args.castes)} ({population} total)")
    print(f"health {args.health}, sanity {args.sanity}, {args.employed:.0%} employed, bed speed {speed:g} op/min")
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
    for name, disease in diseases.items():
        if disease["escalation"]:
            escalation_of[disease["escalation"]].append(name)

    print(f"{'disease':<28}{'bed':<13}{'ops':>4}{'recovery':>10}{'lethal':>8}  sources")
    for name, disease in sorted(diseases.items(), key=lambda x: x[1]["id"]):
        recovery = f"{disease['recovery_minutes']:.0f} min" if disease["recovery_minutes"] else "never"
        workload = f"{disease['workload']:g}" if disease["treatable"] else "-"
        sources = direct[name] + [f"escalation of {e}" for e in escalation_of[name]]
        flag = ""
        # design rule: specialised diseases need a long natural recovery or have to be preventable escalations
        if (
            disease["bed"] != GENERAL
            and direct[name]
            and disease["recovery_minutes"]
            and disease["recovery_minutes"] < 60
        ):
            flag = "  <- specialised, short recovery, not only an escalation"
        print(
            f"{name:<28}{disease['bed']:<13}{workload:>4}{recovery:>10}{disease['lethality']:>8.0%}  "
            f"{', '.join(sources) or '-'}{flag}"
        )


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("-p", "--population", type=int, default=1000, help="inhabitants per caste (default 1000)")
    parser.add_argument("-c", "--castes", nargs="+", help="castes in the city (default: all enabled)")
    parser.add_argument("-H", "--health", type=float, default=10, help="average health (default 10)")
    parser.add_argument("-S", "--sanity", type=float, default=10, help="average sanity (default 10)")
    parser.add_argument("--employed", type=float, default=0.5, help="share of inhabitants with a job (default 0.5)")
    parser.add_argument("--animal-farms", type=int, default=0, help="active animal farms, for zoonosis")
    parser.add_argument(
        "--rate", action="append", default=[], metavar="CATEGORY=FACTOR", help="try a factor on a category's rate"
    )
    parser.add_argument(
        "--workload", action="append", default=[], metavar="DISEASE=OPS", help="try another workload for a disease"
    )
    parser.add_argument("--diseases", action="store_true", help="list every disease instead of the city estimate")
    args = parser.parse_args()

    diseases = parse_diseases()
    categories = parse_categories()
    castes = parse_castes()
    work_rates, speed = parse_buildings()
    args.rate = {k: float(v) for k, v in (item.split("=") for item in args.rate)}
    for item in args.workload:
        name, ops = item.split("=")
        diseases[name]["workload"] = float(ops)
    args.castes = args.castes or list(castes)
    unknown = set(args.castes) - set(castes)
    if unknown:
        parser.error(f"unknown or disabled castes: {', '.join(sorted(unknown))}")

    if args.diseases:
        print_diseases(diseases, categories)
    else:
        print_city(args, castes, parse_rates(), categories, diseases, work_rates, speed)


if __name__ == "__main__":
    main()
