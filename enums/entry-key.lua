--- Enum table for entry table keys.
local EK = {}

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
EK.alt_mode_sprite = 8

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
--- the number of workers this entry wants to have
EK.target_worker_count = 52

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
--- available work
EK.workhours = 152

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
--- humus related operation mode for this plant care station
EK.humus_mode = 702
--- speed bonus due to humus
EK.humus_bonus = 703
--- pruning related operation mode for this plant care station
EK.pruning_mode = 704
--- productivity bonus due to pruning
EK.prune_bonus = 705

-- composter

--- produced humus inside this composter
EK.humus = 800
--- progress toward the next composted item
EK.composting_progress = 801
--- progress toward the next spawned necrofall circle
EK.necrofall_progress = 802

-- hospital

--- statistics over treated disease cases as (disease_id, count)-pairs
EK.treated = 900
--- table with treatment permissions for this hospital as (disease_id, boolean)-pairs
EK.treatment_permissions = 901

-- upbringing station

--- the caste the children are educated in
EK.education_mode = 1000
--- the current classes of this upbringing station
EK.classes = 1001
--- the number of upbrought children
EK.graduates = 1002

-- plant care station

--- stored humus in this plant care station
EK.humus_stored = 1100
--- stored fertiliser in this plant care station
--EK.fertiliser_stored = 1102

-- waste dump

--- stored garbage in this waste dump
EK.stored_garbage = 1200
--- operation mode of this waste dump
EK.waste_dump_mode = 1201
--- if the scrap press of this waste dump is activated
EK.press_mode = 1202
--- progress toward the next item that will be stored or put out
EK.store_progress = 1203
--- progress toward the next item that will be turned into garbage
EK.garbagify_progress = 1204

-- animal farm

--- is this animal farm housing animals?
EK.houses_animals = 1300

return EK
