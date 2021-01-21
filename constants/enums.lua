---------------------------------------------------------------------------------------------------
-- << enums >>
-- (except that lua doesn't have enums and all these are just global tables)

--<< entities >>
--- Enum table for registered entity types.
Type = {}

-- housing types
Type.empty_house = 0
Type.clockwork = 1
Type.orchid = 2
Type.gunfire = 3
Type.ember = 4
Type.foundry = 5
Type.gleam = 6
Type.aurora = 7
Type.plasma = 8

-- civil types
Type.market = 101
Type.water_distributer = 102
Type.dumpster = 104
Type.immigration_port = 106
Type.transportation = 107
Type.nightclub = 108

Type.egg_collector = 197
Type.upbringing_station = 198
Type.pharmacy = 199
Type.hospital = 200
Type.psych_ward = 201

-- crafting machines
Type.assembling_machine = 1001
Type.furnace = 1002
Type.rocket_silo = 1003
Type.mining_drill = 1004
-- ..with custom behaviour
Type.manufactory = 1101
Type.fishery = 1102
Type.hunting_hut = 1103
Type.farm = 1104
Type.animal_farm = 1106
Type.waterwell = 1107

Type.composter = 1110
Type.composter_output = 1111

Type.turret = 2000
Type.lab = 2001

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
Taste.acidic = 4
Taste.spicy = 5
Taste.fruity = 6
Taste.umami = 7
Taste.soily = 8
Taste.weirdly_chemical = 9

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
--- id of this entry's altmode sprite
EK.altmode_sprite = 8

-- inventory stuff
--- contents of this entry's entity's inventory for lazily evaluated inventories
EK.inventory_contents = 30

-- neighborhood stuff
--- neighbors as a table with (type, lookup-table of neighbor numbers)-pairs
EK.neighbors = 40

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

-- general Custom Building related stuff
--- performance of the custom building
EK.performance = 150
--- is this entity active?
EK.active = 151

-- type specific stuff
-- housing
--- inhabitants this house has during the last update
EK.official_inhabitants = 204
--- points this house provides to the caste bonus
EK.caste_points = 205
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
--- the illnesses of the inhabitants as a DiseaseGroup object
EK.diseases = 222
--- the progresses toward the next disease case as a table of (disease category, float)-pairs
EK.disease_progress = 223
--- the progress toward the next natural recovery
EK.recovery_progress = 224
--- the genders of the inhabitants
EK.genders = 225
--- the ages of the inhabitants
EK.ages = 226
--- the tick of the last age shift
EK.last_age_shift = 227
--- the entries that make up the social environment as an array of unit_numbers
EK.social_environment = 228
--- the progress toward the next social event
EK.social_progress = 229
--- the number of gas that conceived this ga cycle
EK.ga_conceptions = 230

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

-- hunting hut
--- tree count in environment
EK.tree_count = 600

-- farms
--- living biomass in this farm
EK.biomass = 700
--- currently cultivated species
EK.species = 701

-- composter
--- produced humus inside this composter
EK.humus = 800
--- progress toward the next composted item
EK.composting_progress = 801

-- hospital
--- available operations in this hospital
EK.operations = 900
--- statistics over treated disease cases as (disease_id, count)-pairs
EK.treated = 901

-- upbringing station
--- the caste the children are educated in
EK.education_mode = 1000
--- the current classes of this upbringing station
EK.classes = 1001
--- the number of upbrought children
EK.graduates = 1002

--<< causes >>
--- Enum table for destruction causes
DestructionCause = {}

DestructionCause.unknown = 0
DestructionCause.mined = 1
DestructionCause.destroyed = 2
DestructionCause.type_change = 3

--- Enum table for emigration causes
EmigrationCause = {}

EmigrationCause.unknown = 0
EmigrationCause.unhappy = 1
EmigrationCause.homeless = 2

--- Enum table for dead inhabitants
DeathCause = {}

DeathCause.unknown = 0
DeathCause.old_age = 1
DeathCause.illness = 2
DeathCause.killed = 3

--<< happiness summands >>
--- Enum table for happiness summands.
HappinessSummand = {}

HappinessSummand.housing = 1
HappinessSummand.suitable_housing = 2
HappinessSummand.health = 3
HappinessSummand.sanity = 4
HappinessSummand.taste = 5
HappinessSummand.food_luxury = 6
HappinessSummand.food_variety = 7
HappinessSummand.no_power = 8
HappinessSummand.power = 9
HappinessSummand.fear = 10
HappinessSummand.ember = 11
HappinessSummand.garbage = 12
HappinessSummand.gross_industry = 13
HappinessSummand.nightclub = 14

--<< happiness factors >>
--- Enum table for happiness factors.
HappinessFactor = {}

HappinessFactor.not_enough_food_variety = 1
HappinessFactor.hunger = 2
HappinessFactor.thirst = 3
HappinessFactor.bad_health = 4
HappinessFactor.bad_sanity = 5

--<< health summands >>
--- Enum table for health summands.
HealthSummand = {}

HealthSummand.nutrients = 1
HealthSummand.food = 2
HealthSummand.fear = 3
HealthSummand.plasma = 4
HealthSummand.gross_industry = 5
HealthSummand.water = 6

--<< health factors >>
--- Enum table for health factors.
HealthFactor = {}

HealthFactor.hunger = 1
HealthFactor.thirst = 2

--<< sanity summands >>
--- Enum table for sanity summands.
SanitySummand = {}

SanitySummand.innate = 1
SanitySummand.social_environment = 2
SanitySummand.housing = 3
SanitySummand.taste = 4
SanitySummand.favorite_taste = 5
SanitySummand.no_variety = 6
SanitySummand.disliked_taste = 7
SanitySummand.just_neutral = 8
SanitySummand.single_food = 9
SanitySummand.fear = 10

--<< sanity factors >>
--- Enum table for sanity factors.
SanityFactor = {}

--SanityFactor.hunger = 1
--SanityFactor.thirst = 2

--<< inhabitant genders >>
--- Enum table for genders
Gender = {}

Gender.neutral = 1
Gender.fale = 2
Gender.pachin = 3
Gender.ga = 4

--<< climate >>
--- Enum table for temperatures
Climate = {}

Climate.hot = 1
Climate.moderate = 2
Climate.cold = 3

--- Enum table for humidity
Humidity = {}

Humidity.humid = 1
Humidity.moderate = 2
Humidity.dry = 3

--- Enum table for disease categories
DiseaseCategory = {}

--- consequences of bad healthiness
DiseaseCategory.health = 1
--- consequences of bad sanity
DiseaseCategory.sanity = 2
--- consequences of work related accidents
DiseaseCategory.accident = 3
