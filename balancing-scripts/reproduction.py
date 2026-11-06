"""Estimates how fast huwans conceive eggs.

Re-implements social_meeting and evaluate_social_environment of classes/inhabitants/housing-environment.lua
and the reproduction postprocessing of constants/inhabitants.lua. Keep it in sync when that logic changes.

Inputs:
- birth rate target, reference social value, reference meeting rate and meeting exponent from
  constants/inhabitants.lua (overridable with the flags below)
- egg gender distributions from constants/inhabitants.lua (egg_data)
- caste social coefficients from constants/castes.lua
- nutrition conception factors from constants/inhabitants.lua

Model:
- A house has meetings at a rate of K * V^EXPONENT, V = inhabitants * social coefficient of its social
  environment. K is set so that the reference social value has the reference meeting rate.
- Per meeting, every ga that has a partner and hasn't conceived this cycle (1 nauvis day) conceives with
  the chance p. The partner rate is min(fale / ga, pachin / ga, 1) of the environment.
- p is derived from the target: the natural huwan-egg gender mix in the reference environment conceives
  TARGET eggs per inhabitant per nauvis day.
- Births per inhabitant per day = ga share * partner rate * (1 - (1 - p * factor)^meetings per cycle).
  House size doesn't matter any more.
- Not modelled: egg calories, egg collectors and the 20 egg limit of a house, hatching, birth defects, deaths.

Usage, from the mod folder:
    python3 balancing-scripts/reproduction.py
    python3 balancing-scripts/reproduction.py --target 0.02 --exponent 0.3 --meetings 20
    python3 balancing-scripts/reproduction.py --mix 0.1,0.3,0.3,0.3
"""
import argparse
import math
import re
from pathlib import Path

MOD = Path(__file__).resolve().parent.parent

TICKS_PER_DAY = 25000
TICKS_PER_HOUR = 216000
GENDERS = ["agender", "fale", "pachin", "ga"]

SIZES = [4, 20, 50, 200, 500, 2000, 5000]


def parse_egg_mixes():
    """Returns the gender shares by egg name."""
    src = (MOD / "constants" / "inhabitants.lua").read_text()
    block = src[src.index("InhabitantsConstants.egg_data = {") :]
    mixes = {}
    for name, body in re.findall(r'\["([\w-]+)"\] = \{\s*genders = \{(.*?)\}', block, re.S):
        shares = dict(re.findall(r"\[Gender\.(\w+)\] = ([\d.]+)", body))
        mixes[name] = {gender: float(shares[gender]) for gender in GENDERS}
    return mixes


def parse_social_coefficients():
    src = (MOD / "constants" / "castes.lua").read_text()
    coefficients = {}
    for m in re.finditer(r'\n        name = "(\w+)",(.*?)\n    \}', src, re.S):
        name, body = m.groups()
        if re.search(r"\n\s+enabled = false", body):
            continue
        coefficients[name] = float(re.search(r"social_coefficient = ([\d.]+)", body).group(1))
    return coefficients


def parse_reproduction_constants():
    """Returns the reproduction targets of constants/inhabitants.lua, rates per nauvis day."""
    src = (MOD / "constants" / "inhabitants.lua").read_text()

    def constant(name):
        return re.search(rf"InhabitantsConstants\.{name} = ([^\n]+)", src).group(1).strip()

    def per_day(name):
        return float(re.fullmatch(r"([\d.]+) / Time\.nauvis_day", constant(name)).group(1))

    if constant("ga_reproduction_cycle") != "Time.nauvis_day":
        raise SystemExit("the model assumes a ga reproduction cycle of one nauvis day")
    return {
        "reference": float(constant("reference_social_value")),
        "meetings": per_day("reference_meeting_rate"),
        "exponent": float(constant("meeting_exponent")),
        "target": per_day("birth_rate"),
    }


def parse_max_conception_factor():
    """Returns the conception factor of a diet that covers every nutrition tag with a conception factor."""
    src = (MOD / "constants" / "inhabitants.lua").read_text()
    factor = 1.0
    for value in re.findall(r"\[NutritionTag\.\w+\]\s*= \{[^}]*conception_rate_factor = ([\d.]+)", src):
        factor *= float(value)
    return factor


def eligible_share(mix):
    """Share of the inhabitants that are gas with a partner."""
    ga = mix["ga"]
    if ga == 0:
        return 0.0
    return ga * min(mix["fale"] / ga, mix["pachin"] / ga, 1)


def births_per_day(mix, meetings, p, factor=1.0):
    """Eggs conceived per inhabitant per nauvis day."""
    chance = min(1.0, p * factor)
    return eligible_share(mix) * (1 - (1 - chance) ** meetings)


def doubling_hours(rate):
    if rate <= 0:
        return math.inf
    days = math.log(2) / math.log(1 + rate)
    return days * TICKS_PER_DAY / TICKS_PER_HOUR


def main():
    constants = parse_reproduction_constants()
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument(
        "--target", type=float, default=constants["target"],
        help=f"eggs per inhabitant per nauvis day in the reference (mod: {constants['target']:g})"
    )
    parser.add_argument(
        "--exponent", type=float, default=constants["exponent"],
        help=f"exponent of the meeting curve (mod: {constants['exponent']:g})"
    )
    parser.add_argument(
        "--meetings", type=float, default=constants["meetings"],
        help=f"meetings per nauvis day in the reference environment (mod: {constants['meetings']:g})"
    )
    parser.add_argument(
        "--reference", type=float, default=constants["reference"],
        help=f"reference social value (mod: {constants['reference']:g})"
    )
    parser.add_argument(
        "--mix", action="append", default=[], metavar="A,F,P,G",
        help="also show a custom gender mix (agender, fale, pachin, ga shares)"
    )
    args = parser.parse_args()

    mixes = parse_egg_mixes()
    natural = mixes["huwan-egg"]
    shown = {"natural huwan-egg": natural, "best lab mix": {"agender": 0, "fale": 1 / 3, "pachin": 1 / 3, "ga": 1 / 3}}
    # single-gender eggs can't reproduce on their own
    shown.update({name: mix for name, mix in mixes.items() if name != "huwan-egg" and max(mix.values()) < 1})
    for item in args.mix:
        shares = [float(x) for x in item.split(",")]
        total = sum(shares)
        shown[f"custom {item}"] = {gender: share / total for gender, share in zip(GENDERS, shares)}

    reference = args.reference
    reference_meetings = args.meetings
    k = reference_meetings / reference ** args.exponent

    def meetings(v):
        return k * v ** args.exponent

    eligible = eligible_share(natural)
    per_ga = args.target / eligible
    if per_ga >= 1:
        parser.error(f"target {args.target} is unreachable: only {eligible:.0%} of the natural mix are gas with a partner")
    p = 1 - (1 - per_ga) ** (1 / reference_meetings)

    print(f"Reference: {reference:g} inhabitants (social coefficient 1), "
          f"{reference_meetings:.1f} meetings per nauvis day, curve V^{args.exponent:g}")
    print(f"Target: {args.target:.2%} eggs per inhabitant per nauvis day for the natural huwan-egg mix")
    print(f"-> {eligible:.0%} of the natural mix are gas with a partner, each conceives with {per_ga:.1%} per cycle")
    print(f"-> conception chance per meeting: p = {p:.4f}")
    print(f"   (in the mod: meeting_coefficient = {k / TICKS_PER_DAY:.3g} per tick, conception_rate = {p:.4g})")
    print()

    print("Eggs per 100 inhabitants per nauvis day, by social environment size (inhabitants * social coefficient):")
    print(f"{'gender mix':<32}" + "".join(f"{size:>7}" for size in SIZES) + f"{'doubling':>10}")
    for name, mix in shown.items():
        rates = [births_per_day(mix, meetings(size), p) for size in SIZES]
        doubling = doubling_hours(births_per_day(mix, meetings(reference), p))
        doubling_text = f"{doubling:.1f} h" if math.isfinite(doubling) else "never"
        print(f"{name:<32}" + "".join(f"{rate * 100:>7.2f}" for rate in rates) + f"{doubling_text:>10}")
    print(f"{'meetings per day':<32}" + "".join(f"{meetings(size):>7.1f}" for size in SIZES))
    print("doubling: hours of play until the population doubles in the reference, if every egg hatches")
    print()

    factor = parse_max_conception_factor()
    best = births_per_day(shown["best lab mix"], meetings(reference), p, factor)
    print(f"Fully optimised (best lab mix, conception factor {factor:g} from the diet, reference environment): "
          f"{best:.2%} per day, doubling in {doubling_hours(best):.1f} h")
    print()

    print(f"Natural mix in an environment of {reference:g} inhabitants of one caste:")
    for caste, coefficient in sorted(parse_social_coefficients().items(), key=lambda x: x[1]):
        rate = births_per_day(natural, meetings(reference * coefficient), p)
        print(f"  {caste:<12} social coefficient {coefficient:<4g} {rate:.2%} per day")


if __name__ == "__main__":
    main()
