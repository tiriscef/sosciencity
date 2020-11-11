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
Type.hospital = 103
Type.dumpster = 104
Type.pharmacy = 105
Type.immigration_port = 106
Type.transportation = 107
Type.nightclub = 108

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
--- chest inventory of this entry's entity
EK.chest_inventory = 9

-- neighborhood stuff
--- neighbors as a table with (type, lookup-table of neighbor numbers)-pairs
EK.neighbors = 40
--- the range this entry looks connects with other neighbor entries
EK.range = 41
--- tick of the last time this entity updated it's surrounding unregistered entity information
EK.last_entity_update = 42
--- tick of the last time this entity updated it's surrounding tile information
EK.last_tile_update = 43

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

-- type specific stuff
-- housing
--- if this house is an improvised hut
EK.is_improvised = 203
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
--- the count of inhabitants that are ill
EK.ill = 221
--- the illnesses of the inhabitants as a DiseaseGroup object
EK.diseases = 222
--- the genders of the inhabitants
EK.genders = 223
--- the ages of the inhabitants
EK.ages = 224

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
HappinessSummand.taste = 3
HappinessSummand.food_luxury = 4
HappinessSummand.food_variety = 5
HappinessSummand.no_power = 6
HappinessSummand.power = 7
HappinessSummand.fear = 8
HappinessSummand.ember = 9
HappinessSummand.garbage = 10
HappinessSummand.animal_farms = 11
HappinessSummand.nightclub = 12

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
HealthSummand.animal_farms = 5

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
