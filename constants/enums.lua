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
Type.immigration_port = 106
Type.transportation = 107

Type.waterwell = 201

Type.fishery = 999
Type.manufactory = 1000
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
EK = {}

-- general
--- type of this entry
EK.type = 1
--- LuaEntity of this entry
EK.entity = 2
--- unit_number of this entries entity
EK.unit_number = 3
--- name of this entries entity
EK.name = 4
--- tick of the last entry update
EK.last_update = 5
--- tick of the creation of this entry
EK.tick_of_creation = 6
--- table with (subentity_type, subentity)-pairs
EK.subentities = 7

-- neighborhood stuff
--- neighbors as a table with (type, lookup-table of neighbor numbers)-pairs
EK.neighbors = 40
--- the range this entry looks connects with other neighbor entries
EK.range = 41
--- tick of the last time this entity updated it's surrounding tile information
EK.last_tile_update = 42

-- workforce
--- the number of workers employed by this entry
EK.worker_count = 50
--- workers as a table of (housing_number, count)-pairs
EK.workers = 51

-- subentity stuff
--- the current power usage of this entries eei
EK.power_usage = 100
--- the current speed bonus of this entries beacon
EK.speed_bonus = 101
--- the current productivity bonus of this entries beacon
EK.productivity_bonus = 102
--- if this entries beacon has a penalty module
EK.has_penalty_module = 103

-- type specific stuff
-- housing
--- points this house provides to the caste bonus
EK.points = 205
--- inhabitant count of this entry
EK.inhabitants = 206
--- current happiness of this entries inhabitants
EK.happiness = 207
--- array with happiness influences
EK.happiness_summands = 208
--- array with multiplying happiness influences
EK.happiness_factors = 209
--- current health of this entries inhabitants
EK.health = 210
--- array with health influences
EK.health_summands = 211
--- array with multiplying health influences
EK.health_factors = 212
--- current sanity of this entries inhabitants
EK.sanity = 213
--- array with sanity influences
EK.sanity_summands = 214
--- array with multiplying sanity influences
EK.sanity_factors = 215
--- the trend toward the next emigrating inhabitant
EK.emigration_trend = 216
--- the progress toward the next produced garbage item
EK.garbage_progress = 218
--- the count of inhabitants that are employed
EK.employed = 219
--- the employments of this entry as table of (building number, count)-pairs
EK.employments = 220
--- the count of inhabitants that are ill
EK.ill = 221
--- the illnesses of this entry as a DiseaseGroup object
EK.illnesses = 222

-- water distributer
--- quality of the water this distributer provides
EK.water_quality = 300
--- name of the water this distributer provides
EK.water_name = 301

-- immigration port
--- tick of the next immigration wave
EK.next_wave = 400

-- fishery
--- water tile count in environment
EK.water_tiles = 500

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

--<< happiness factors >>
--- Enum table for happiness factors.
HappinessFactor = {}

HappinessFactor.not_enough_food_variety = 1
HappinessFactor.hunger = 2
HappinessFactor.thirst = 3
HappinessFactor.health = 4
HappinessFactor.sanity = 5

--<< health summands >>
--- Enum table for health summands.
HealthSummand = {}

HealthSummand.nutrients = 1
HealthSummand.food = 2
HealthSummand.fear = 3
HealthSummand.plasma = 4

--<< health factors >>
--- Enum table for health factors.
HealthFactor = {}

HealthFactor.hunger = 1
HealthFactor.water = 2

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

--<< sanity factors >>
--- Enum table for sanity factors.
SanityFactor = {}

SanityFactor.hunger = 1
SanityFactor.thirst = 2
