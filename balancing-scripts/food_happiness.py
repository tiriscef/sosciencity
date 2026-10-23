"""Estimates the food happiness every caste gets from its diet.

Re-implements the diet logic of classes/inhabitants/housing-needs.lua (diet building and the
happiness part of add_diet_effects). Keep it in sync when that logic changes.

Inputs:
- foods from constants/food.lua, castes from constants/castes.lua
- tiers from the progression snapshot in 0snapshot/ (run generate-snapshot.sh first). Gathered
  foods (listed with "from <entity>" in the snapshot) count as tier 0.

Setups per caste:
- starter: only the gathered foods (tier 0) the caste doesn't dislike
- basic:   median of many random setups of a few tolerable foods (BASIC_FOOD_COUNT) available at the
           caste's unlock tier, counting only setups that cover all essential nutrition tags
- optimal: every food available at the caste's unlock tier
- max:     every food in the game

Usage, from the mod folder:
    python3 balancing-scripts/food_happiness.py
    python3 balancing-scripts/food_happiness.py -s orchid.per_favored=1 -s variety=0.25 -v
    python3 balancing-scripts/food_happiness.py -t insect-meat=0 --tags insect-meat=protein,fat
"""
import argparse
import random
import re
import statistics
from pathlib import Path

MOD = Path(__file__).resolve().parent.parent
SNAPSHOT = MOD / "0snapshot" / "sosciencity-progression-compact"

# number of foods in a "basic setup" - a player who plans a little, but doesn't optimize
BASIC_FOOD_COUNT = {"clockwork": 3, "orchid": 5, "ember": 3, "gunfire": 4, "plasma": 4, "foundry": 6, "gleam": 7}
# happiness per food group above minimum_food_count, hardcoded in housing-needs.lua
DEFAULT_VARIETY_BONUS = 0.5
SAMPLES = 4000

ALL_TAGS = ["protein", "fat", "carb", "vitamin", "fiber", "mineral", "lucidin", "purpurin", "ovolin"]
CASTE_FIELDS = {
    "min_count": "minimum_food_count",
    "per_favored": "happiness_per_favored_food",
    "per_disliked": "happiness_per_disliked_food",
    "per_tag": "happiness_per_nutrition_tag",
    "per_missing": "happiness_per_missing_food",
    "variety": "happiness_per_extra_food_group",
}


def parse_foods():
    src = (MOD / "constants" / "food.lua").read_text()
    foods = {}
    for m in re.finditer(r'\n    \["([\w-]+)"\] = \{(.*?)\n    \}', src, re.S):
        name, body = m.groups()
        if name.startswith("test-food"):
            continue
        foods[name] = {
            "taste": re.search(r"taste_category = Taste\.(\w+)", body).group(1),
            "appeal": float(re.search(r"appeal = ([\d.]+)", body).group(1)),
            "group": re.search(r'group = "([\w-]+)"', body).group(1),
            "tags": set(re.findall(r"NutritionTag\.(\w+)_rich", body)),
        }
    return foods


def parse_castes():
    src = (MOD / "constants" / "castes.lua").read_text()
    castes = {}
    for m in re.finditer(r'\n        name = "(\w+)",(.*?)\n    \}', src, re.S):
        name, body = m.groups()
        if re.search(r"\n\s+enabled = false", body):
            continue
        caste = {
            "behavior": re.search(r"EatingBehavior\.(\w+)", body).group(1),
            "favored": re.search(r"favored_taste = Taste\.(\w+)", body).group(1),
            "disliked": re.search(r"least_favored_taste = Taste\.(\w+)", body).group(1),
            "essential": re.findall(
                r"NutritionTag\.(\w+)_rich", re.search(r"essential_nutrition_tags = \{(.*?)\}", body).group(1)
            ),
        }
        for key, field in CASTE_FIELDS.items():
            value = re.search(rf"\n\s+{field} = (-?[\d.]+)", body)
            caste[key] = float(value.group(1)) if value else None
        if caste["variety"] is None:
            caste["variety"] = DEFAULT_VARIETY_BONUS
        castes[name] = caste
    return castes


def parse_tiers():
    """Returns (first tier of every item, first tier of every caste). Gathered items are tier 0."""
    if not SNAPSHOT.is_dir():
        raise SystemExit(f"No snapshot found in {SNAPSHOT}. Run generate-snapshot.sh first.")
    item_tiers, caste_tiers = {}, {}
    for path in sorted(SNAPSHOT.glob("tier-*.md")):
        tier = int(re.match(r"tier-(\d+)", path.name).group(1))
        text = path.read_text()
        castes = re.search(r"\*\*Castes available:\*\* (.*)", text).group(1)
        for caste in re.findall(r"\w+", castes):
            caste_tiers[caste] = min(caste_tiers.get(caste, tier), tier)
        for m in re.finditer(r"^- \S+ `([\w-]+)`(  from .*)?$", text, re.M):
            name, gathered = m.groups()
            item_tiers[name] = min(item_tiers.get(name, tier), 0 if gathered else tier)
    return item_tiers, caste_tiers


def add_tag_covering(foods, food_list, diet, covered, wanted):
    added = 0
    for name in food_list:
        if all(t in covered for t in wanted):
            break
        if any(t in foods[name]["tags"] and t not in covered for t in wanted):
            diet.append(name)
            covered |= foods[name]["tags"]
            added += 1
    return added


def build_diet(foods, caste, available):
    """available must be sorted by descending appeal, like the inventory scan in the mod."""
    favored = [f for f in available if foods[f]["taste"] == caste["favored"]]
    disliked = [f for f in available if foods[f]["taste"] == caste["disliked"]]
    neutral = [f for f in available if f not in favored and f not in disliked]
    diet, covered = [], set()
    n_disliked = 0
    behavior = caste["behavior"]
    if behavior == "health_conscious":
        add_tag_covering(foods, favored, diet, covered, ALL_TAGS)
        add_tag_covering(foods, neutral, diet, covered, ALL_TAGS)
        n_disliked = add_tag_covering(foods, disliked, diet, covered, caste["essential"])
    elif behavior == "mixed":
        diet += favored
        for f in diet:
            covered |= foods[f]["tags"]
        add_tag_covering(foods, neutral, diet, covered, caste["essential"])
        n_disliked = add_tag_covering(foods, disliked, diet, covered, caste["essential"])
        for f in neutral:
            if len(diet) >= caste["min_count"]:
                break
            if f not in diet:
                diet.append(f)
    else:
        diet = favored + neutral
        for f in diet:
            covered |= foods[f]["tags"]
    return diet, covered, n_disliked


def happiness(foods, caste, available):
    """Returns (total, parts, missing essential tags) of a diet, or None if the caste eats nothing."""
    diet, covered, n_disliked = build_diet(foods, caste, available)
    if not diet:
        return None
    appeals = sorted((foods[f]["appeal"] for f in diet), reverse=True)[:3]
    parts = {"appeal": sum(appeals) / len(appeals)}
    parts["taste"] = sum(1 for f in diet if foods[f]["taste"] == caste["favored"]) * caste["per_favored"]
    parts["disliked"] = n_disliked * caste["per_disliked"]
    variety = len({foods[f]["group"] for f in diet}) - caste["min_count"]
    parts["variety"] = variety * caste["variety"] if variety > 0 else -variety * caste["per_missing"]
    rewarded = ALL_TAGS if caste["behavior"] == "health_conscious" else caste["essential"]
    parts["tags"] = sum(1 for t in rewarded if t in covered) * caste["per_tag"]
    missing = [t for t in caste["essential"] if t not in covered]
    return sum(parts.values()), parts, missing


def by_appeal(foods, names):
    return sorted(names, key=lambda f: -foods[f]["appeal"])


def format_parts(parts):
    return " ".join(f"{k}={v:.1f}" for k, v in parts.items() if v)


def report(foods, castes, item_tiers, caste_tiers, verbose):
    rng = random.Random(42)
    unknown = sorted(f for f in foods if f not in item_tiers)
    if unknown:
        print(f"Foods not in the snapshot (ignored): {', '.join(unknown)}\n")
    foods = {f: data for f, data in foods.items() if f in item_tiers}

    print(f"{'caste':10} {'tier':>4} {'starter':>8} {'basic':>6} {'optimal':>8} {'max':>6}")
    details = []
    for name, caste in castes.items():
        tier = caste_tiers[name]
        tolerable = [f for f in foods if foods[f]["taste"] != caste["disliked"]]

        starter = happiness(foods, caste, by_appeal(foods, [f for f in tolerable if item_tiers[f] == 0]))
        starter_text = f"{starter[0]:.1f}" + ("*" if starter[2] else "") if starter else "-"

        basic_totals, basic_parts = [], {}
        early = [f for f in tolerable if item_tiers[f] <= tier]
        for _ in range(SAMPLES):
            result = happiness(foods, caste, by_appeal(foods, rng.sample(early, BASIC_FOOD_COUNT[name])))
            if result and not result[2]:
                basic_totals.append(result[0])
                for k, v in result[1].items():
                    basic_parts[k] = basic_parts.get(k, 0) + v
        basic_parts = {k: v / len(basic_totals) for k, v in basic_parts.items()}

        optimal = happiness(foods, caste, by_appeal(foods, [f for f in foods if item_tiers[f] <= tier]))
        best = happiness(foods, caste, by_appeal(foods, list(foods)))

        print(
            f"{name:10} {tier:4} {starter_text:>8} {statistics.median(basic_totals):6.1f}"
            f" {optimal[0]:8.1f} {best[0]:6.1f}"
        )
        details.append(
            f"{name}\n"
            f"  starter missing: {', '.join(starter[2]) if starter else '-'}\n"
            f"  basic (mean):    {format_parts(basic_parts)}\n"
            f"  optimal:         {format_parts(optimal[1])}\n"
            f"  max:             {format_parts(best[1])}"
        )
    print("\n* = starter diet misses essential nutrition tags (health malus)")
    if verbose:
        print("\n" + "\n".join(details))


def apply_overrides(castes, overrides):
    """Overrides look like 'orchid.per_favored=1', 'mixed.per_tag=0.5' (eating behavior) or 'variety=0.25' (all)."""
    for override in overrides:
        key, value = override.split("=")
        target, _, field = key.rpartition(".")
        if field not in CASTE_FIELDS:
            raise SystemExit(f"Unknown field '{field}', expected one of {', '.join(CASTE_FIELDS)}")
        for name, caste in castes.items():
            if target in ("", name, caste["behavior"]):
                caste[field] = float(value)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-s", "--set", action="append", default=[], metavar="[CASTE.]FIELD=VALUE",
                        help=f"what-if value; fields: {', '.join(CASTE_FIELDS)}")
    parser.add_argument("-t", "--tier", action="append", default=[], metavar="FOOD=TIER",
                        help="what-if tier of a food (0 = gathered)")
    parser.add_argument("--tags", action="append", default=[], metavar="FOOD=TAG,TAG",
                        help="what-if nutrition tags of a food")
    parser.add_argument("-v", "--verbose", action="store_true", help="show where the happiness comes from")
    args = parser.parse_args()

    castes = parse_castes()
    apply_overrides(castes, args.set)
    foods = parse_foods()
    for override in args.tags:
        food, tags = override.split("=")
        foods[food]["tags"] = set(tags.split(","))
    item_tiers, caste_tiers = parse_tiers()
    for override in args.tier:
        food, tier = override.split("=")
        item_tiers[food] = int(tier)
    report(foods, castes, item_tiers, caste_tiers, args.verbose)


if __name__ == "__main__":
    main()
