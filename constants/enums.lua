---------------------------------------------------------------------------------------------------
-- << enums >>
-- (except that lua doesn't have enums and all these are just global tables)

--<< entities >>
--- Enum table for registered entity types.
Type = {}

Type.empty_house = 0
Type.clockwork = 1
Type.orchid = 2
Type.gunfire = 3
Type.ember = 4
Type.foundry = 5
Type.gleam = 6
Type.aurora = 7
Type.plasma = 8

Type.market = 101
Type.water_distributer = 102
Type.hospital = 103
Type.dumpster = 104
Type.pharmacy = 105

Type.waterwell = 201

Type.assembling_machine = 1001
Type.furnace = 1002
Type.rocket_silo = 1003
Type.mining_drill = 1004
Type.farm = 1005
Type.orangery = 1006

Type.turret = 1100

Type.lab = 2002

Type.null = 9999

--<< subentities >>
--- Enum table for subentity types.
SubentityType = {}

SubentityType.beacon = 1
SubentityType.eei = 2

--<< tastes >>
--- Enum table for tastes.
Taste = {}

Taste.bitter = 1
Taste.neutral = 2
Taste.salty = 3
Taste.sour = 4
Taste.spicy = 5
Taste.sweet = 6
Taste.umami = 7

--<< entry keys >>
--- Enum table for entry table keys.
EntryKey = {}

-- general
EntryKey.type = 1
EntryKey.entity = 2
EntryKey.last_update = 3
EntryKey.subentities = 4
EntryKey.neighbors = 5

-- housing
EntryKey.inhabitants = 6
EntryKey.happiness = 7
EntryKey.happiness_summands = 8
EntryKey.happiness_factors = 9
EntryKey.health = 10
EntryKey.health_summands = 11
EntryKey.health_factors = 12
EntryKey.sanity = 13
EntryKey.sanity_summands = 14
EntryKey.sanity_factors = 15
EntryKey.emigration_trend = 16
EntryKey.idea_progress = 17
EntryKey.garbage_progress = 18

-- water distributer
EntryKey.water_quality = 6
EntryKey.water_name = 7

-- subentity stuff
EntryKey.power_usage = 100
EntryKey.speed_bonus = 200
EntryKey.productivity_bonus = 201
EntryKey.has_penalty_module = 202
EntryKey.tick_of_creation = 300

--<< happiness summands >>
--- Enum table for happiness summands.
HappinessSummand = {}

HappinessSummand.housing = 1
HappinessSummand.suitable_housing = 2
HappinessSummand.taste = 3
HappinessSummand.food_luxury = 4
HappinessSummand.food_variety = 5
HappinessSummand.no_power = 6
HappinessSummand.power = 7
HappinessSummand.fear = 8
HappinessSummand.ember = 9
HappinessSummand.garbage = 10

HappinessSummand.count = 10

--<< happiness factors >>
--- Enum table for happiness factors.
HappinessFactor = {}

HappinessFactor.not_enough_food_variety = 1
HappinessFactor.hunger = 2
HappinessFactor.thirst = 3
HappinessFactor.health = 4
HappinessFactor.sanity = 5

HappinessFactor.count = 5

--<< health summands >>
--- Enum table for health summands.
HealthSummand = {}

HealthSummand.nutrients = 1
HealthSummand.food = 2
HealthSummand.fear = 3

HealthSummand.count = 3

--<< health factors >>
--- Enum table for health factors.
HealthFactor = {}

HealthFactor.hunger = 1
HealthFactor.water = 2

HealthFactor.count = 2

--<< sanity summands >>
--- Enum table for sanity summands.
SanitySummand = {}

SanitySummand.housing = 1
SanitySummand.taste = 2
SanitySummand.favorite_taste = 3
SanitySummand.no_variety = 4
SanitySummand.disliked_taste = 5
SanitySummand.just_neutral = 6
SanitySummand.single_food = 7
SanitySummand.fear = 8

SanitySummand.count = 8

--<< sanity factors >>
--- Enum table for sanity factors.
SanityFactor = {}

SanityFactor.hunger = 1
SanityFactor.thirst = 2

SanityFactor.count = 2