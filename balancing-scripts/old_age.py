"""Estimates how long huwans live and what they die of, once old age exists.

Models the old age design of memory/project_old_age.md before it is implemented in the mod. The parameters
are proposals (PROPOSED below); when phase 4 moves them into constants/inhabitants.lua, read them from
there instead. Ordinary disease cases come from disease_rates.py, the birth rate from reproduction.py.

Inputs:
- diseases, disease categories, base rates, caste susceptibilities, workplaces and bed speed via disease_rates.py
- the birth rate target from constants/inhabitants.lua via reproduction.py
- the old age parameters below (overridable with flags)

Model, per huwan of age a (nauvis days) in a house with health H and sanity S:
- Onset O = onset + health_shift * (H - 10) + sanity_shift * (S - 10), with H and S capped at shift_cap (40).
  Realistic good cities reach about 25, 40 is hard to reach. For a Gompertz curve, delaying the onset
  by X days is the same as dividing the hazards by 2^(X / D), so this is the only knob health and sanity need.
- Frailty f(a) = 2^((a - O) / D): doubles every D days.
- Natural death ("passed away in their sleep"): natural_rate * f(a) per day, no hospital involved.
- Old age disease: old_age_rate * f(a) cases per day, one generic disease until real ones exist.
- Age-scaled lethality: every death chance of a disease case is min(1, base * max(1, f(a))).
  No care: base = lethality, rolled when a disease with natural recovery ends; diseases without natural
  recovery never end untreated. One level of escalation and complication is added.
  Full care: every treatable case is treated, base = complication_lethality (or the default for diseases
  without one), plus one level of complication.
- Survival from day a to a + 1: exp(-(sum of the death hazards)), deaths tracked by cause.
- Population: births b per huwan per day, independent of age. The stable growth rate r solves the
  Euler-Lotka equation 1 = b * sum S(a) e^(-r a); the age pyramid is then S(a) e^(-r a).
- Not modelled: hatching delay, egg limits, the one-disease-per-patient rule, waiting for a bed, infections.

Usage, from the mod folder:
    python3 balancing-scripts/old_age.py
    python3 balancing-scripts/old_age.py -H 20 -S 15
    python3 balancing-scripts/old_age.py --onset 100 --doubling 15 --old-age-complication-lethality 0.3
    python3 balancing-scripts/old_age.py --sweep
"""
import argparse
import math
from collections import defaultdict

import disease_rates
import reproduction

TICKS_PER_DAY = 25000
TICKS_PER_HOUR = 216000
MINUTES_PER_DAY = TICKS_PER_DAY / disease_rates.TICKS_PER_MINUTE
MAX_AGE = 2000

# proposals, phase 4 moves them into constants/inhabitants.lua
PROPOSED = {
    "onset": 170,  # days; frailty is 1 at this age (health = sanity = 10)
    "doubling": 45,  # days until frailty doubles
    "health_shift": 3,  # days of later onset per health point above 10
    "sanity_shift": 1.5,  # days of later onset per sanity point above 10
    "shift_cap": 40,  # health and sanity above this count as this for the onset
    "natural_rate": 0.001,  # natural deaths per huwan per day at the onset
    "old_age_rate": 0.005,  # old age disease cases per huwan per day at the onset
    "old_age_lethality": 0.8,
    "old_age_complication_lethality": 0.08,
    "default_complication_lethality": 0.01,  # for diseases that don't define one
    "old_age_workload": 4,  # operations to treat the generic old age disease
}

CAUSES = ["natural", "old age disease", "other diseases"]
SWEEP = [0, 5, 10, 15, 20, 25, 30, 40, 50]


def death_chance(base, frailty):
    return min(1.0, base * max(1.0, frailty))


def case_death_chance(name, diseases, frailty, care, default_complication_lethality):
    """Chance that one case of the disease kills the huwan, incl. one level of escalation/complication."""
    disease = diseases[name]

    def own(d):
        if care and d["treatable"]:
            lethality = d["complication_lethality"]
            return death_chance(default_complication_lethality if lethality is None else lethality, frailty)
        if d["recovery_minutes"] is None:
            return 0.0  # never ends untreated
        return death_chance(d["lethality"], frailty)

    chance = own(disease)
    if not care and disease["recovery_minutes"] is None:
        return chance
    follow_ups = [(disease["complication"], disease["complication_probability"])]
    if not (care and disease["treatable"]):
        follow_ups.append((disease["escalation"], disease["escalation_probability"]))
    for follow_up, probability in follow_ups:
        if follow_up:
            chance += (1 - chance) * probability * own(diseases[follow_up])
    return chance


def ordinary_cases_per_day(params, health, sanity, data):
    """Ordinary disease cases per huwan per day by disease name."""
    castes, base_rates, categories, work_rates = data["castes"], data["base_rates"], data["categories"], data["work_rates"]
    city = argparse.Namespace(
        castes=params.castes, health=health, sanity=sanity, employed=params.employed, population=1,
        animal_farms=0, food_risk=0, contamination=0, rate={},
    )
    per_minute = disease_rates.split_by_disease(
        disease_rates.city_cases(city, castes, base_rates, work_rates), categories
    )
    return {name: rate * MINUTES_PER_DAY / len(params.castes) for name, rate in per_minute.items()}


def life_table(params, health, sanity, care, data):
    """Returns (survival by age, deaths by age and cause, old age cases by age per living huwan)."""
    diseases = data["diseases"]
    cases = ordinary_cases_per_day(params, health, sanity, data)
    cap = params.shift_cap
    onset = params.onset + params.health_shift * (min(health, cap) - 10) + params.sanity_shift * (min(sanity, cap) - 10)
    old_age_base = params.old_age_complication_lethality if care else params.old_age_lethality

    survival = [1.0]
    deaths = []
    old_age_cases = []
    for age in range(MAX_AGE):
        frailty = 2 ** ((age - onset) / params.doubling)
        hazards = {
            "natural": params.natural_rate * frailty,
            "old age disease": params.old_age_rate * frailty * death_chance(old_age_base, frailty),
            "other diseases": sum(
                rate * case_death_chance(name, diseases, frailty, care, params.default_complication_lethality)
                for name, rate in cases.items()
            ),
        }
        total = sum(hazards.values())
        died = survival[-1] * (1 - math.exp(-total))
        deaths.append({cause: died * h / total if total else 0 for cause, h in hazards.items()})
        old_age_cases.append(params.old_age_rate * frailty)
        survival.append(survival[-1] - died)
        if survival[-1] < 1e-9:
            break
    return survival, deaths, old_age_cases


def life_expectancy(survival):
    # deaths happen during the day, on average in its middle
    return sum(survival[1:]) + 0.5


def age_at_dead_share(survival, share):
    for age, alive in enumerate(survival):
        if alive <= 1 - share:
            return age
    return math.inf


def growth_rate(survival, birth_rate):
    """Solves 1 = b * sum S(a) e^(-r a) for r by bisection."""
    def excess(r):
        return birth_rate * sum(s * math.exp(-r * a) for a, s in enumerate(survival)) - 1

    low, high = -1.0, 1.0
    for _ in range(100):
        mid = (low + high) / 2
        if excess(mid) > 0:
            low = mid
        else:
            high = mid
    return (low + high) / 2


def hours(days):
    return days * TICKS_PER_DAY / TICKS_PER_HOUR


def print_scenarios(params, data, birth_rate):
    print(f"Health {params.health:g}, sanity {params.sanity:g}, castes: {', '.join(params.castes)}, "
          f"{params.employed:.0%} employed")
    print()
    header = f"{'':<36}{'no care':>14}{'full care':>14}"
    print(header)
    results = {}
    for care in (False, True):
        results[care] = life_table(params, params.health, params.sanity, care, data)

    def row(label, fn, fmt):
        print(f"{label:<36}" + "".join(f"{fmt(fn(*results[care])):>14}" for care in (False, True)))

    row("life expectancy (days)", lambda s, d, o: life_expectancy(s), lambda x: f"{x:.0f}")
    row("  in hours of play", lambda s, d, o: hours(life_expectancy(s)), lambda x: f"{x:.1f}")
    for share in (0.1, 0.5, 0.9):
        row(f"{share:.0%} have died at age", lambda s, d, o, share=share: age_at_dead_share(s, share), lambda x: f"{x}")
    for cause in CAUSES:
        row(f"died of {cause}", lambda s, d, o, cause=cause: sum(x[cause] for x in d), lambda x: f"{x:.0%}")
    print()

    print(f"Population with {birth_rate:.2%} births per huwan per nauvis day, every egg hatched:")
    for care in (False, True):
        survival, deaths, old_age_cases = results[care]
        r = growth_rate(survival, birth_rate)
        pyramid = [s * math.exp(-r * a) for a, s in enumerate(survival[:-1])]
        total = sum(pyramid)
        death_rate = birth_rate - (math.exp(r) - 1)
        doubling = f"doubling {hours(math.log(2) / r):.1f} h" if r > 0 else "shrinking"
        cases = sum(p * c for p, c in zip(pyramid, old_age_cases)) / total
        print(f"  {'full care' if care else 'no care':<10} net growth {math.exp(r) - 1:+.2%} per day ({doubling}), "
              f"deaths {death_rate:.2%} per day; stationary population: deaths {1 / life_expectancy(survival):.2%} per day")
        if care:
            per_thousand = cases * 1000
            demand = disease_rates.bed_demand(
                {"old-age-disease": per_thousand / MINUTES_PER_DAY},
                {"old-age-disease": {"treatable": True, "bed": disease_rates.GENERAL, "workload": params.old_age_workload,
                                     "complication": None}},
                data["speed"],
            )
            print(f"             old age cases per 1000 huwans: {per_thousand:.1f} per day, "
                  f"busy beds: {demand[disease_rates.GENERAL]:.2f} ({params.old_age_workload:g} operations each)")
            share_old = sum(p for a, p in enumerate(pyramid) if a >= params.onset) / total
            print(f"             share of huwans older than the onset: {share_old:.1%}")


def print_sweep(params, data):
    for care in (False, True):
        print(f"Life expectancy in days, {'full care' if care else 'no care'} (rows: health, columns: sanity)")
        print(f"{'':>8}" + "".join(f"{s:>8}" for s in SWEEP))
        for health in SWEEP:
            values = [life_expectancy(life_table(params, health, sanity, care, data)[0]) for sanity in SWEEP]
            print(f"{health:>8}" + "".join(f"{v:>8.0f}" for v in values))
        print()


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    for key, value in PROPOSED.items():
        parser.add_argument(f"--{key.replace('_', '-')}", type=float, default=value, help=f"(proposal: {value:g})")
    parser.add_argument("-H", "--health", type=float, default=10, help="average health (default 10)")
    parser.add_argument("-S", "--sanity", type=float, default=10, help="average sanity (default 10)")
    parser.add_argument("-c", "--castes", nargs="+", help="castes in the city (default: all enabled)")
    parser.add_argument("--employed", type=float, default=0.5, help="share of inhabitants with a job (default 0.5)")
    parser.add_argument("--birth-rate", type=float, help="births per huwan per nauvis day (default: the mod's target)")
    parser.add_argument("--sweep", action="store_true", help="life expectancy over health and sanity instead")
    params = parser.parse_args()

    castes = disease_rates.parse_castes()
    params.castes = params.castes or list(castes)
    unknown = set(params.castes) - set(castes)
    if unknown:
        parser.error(f"unknown or disabled castes: {', '.join(sorted(unknown))}")
    work_rates, speed = disease_rates.parse_buildings()
    data = {
        "diseases": disease_rates.parse_diseases(),
        "categories": disease_rates.parse_categories(),
        "base_rates": disease_rates.parse_rates(),
        "castes": castes,
        "work_rates": work_rates,
        "speed": speed,
    }
    birth_rate = params.birth_rate or reproduction.parse_reproduction_constants()["target"]

    print("Old age: onset {onset:g} days, frailty doubles every {doubling:g} days, onset +{health_shift:g} days per "
          "health and +{sanity_shift:g} per sanity point above 10 (counted up to {shift_cap:g})".format(**vars(params)))
    print("At the onset: natural deaths {natural_rate:g}, old age cases {old_age_rate:g} per huwan per day; "
          "old age disease lethality {old_age_lethality:g} untreated, {old_age_complication_lethality:g} treated; "
          "default complication lethality {default_complication_lethality:g}".format(**vars(params)))
    print()
    if params.sweep:
        print_sweep(params, data)
    else:
        print_scenarios(params, data, birth_rate)


if __name__ == "__main__":
    main()
