---------------------------------------------------------------------------------------------------
-- << enums >>
-- (except that lua doesn't have enums and all these are just shouty globals)
Types = {}

--<< entities >>
TYPE_EMPTY_HOUSE = 0
TYPE_CLOCKWORK = 1
TYPE_ORCHID = 2
TYPE_GUNFIRE = 3
TYPE_EMBER = 4
TYPE_FOUNDRY = 5
TYPE_GLEAM = 6
TYPE_AURORA = 7
TYPE_PLASMA = 8

TYPE_MARKET = 101
TYPE_WATER_DISTRIBUTER = 102
TYPE_HOSPITAL = 103
TYPE_PHARMACY = 104
TYPE_DUMPSTER = 105

TYPE_CLUB = 201
TYPE_SCHOOL = 202
TYPE_BARRACK = 203
TYPE_UNIVERSITY = 204
TYPE_UNIVERSITY_MK02 = 205
TYPE_CITY_HALL = 206
TYPE_RESEARCH_CENTER = 207

TYPE_ASSEMBLING_MACHINE = 1001
TYPE_FURNACE = 1002
TYPE_ROCKET_SILO = 1003
TYPE_MINING_DRILL = 1004
TYPE_FARM = 1005
TYPE_ORANGERY = 1006

TYPE_TURRET = 1100

TYPE_LAB = 2002

TYPE_NULL = 9999

--<< subentities >>
SUB_BEACON = 10001
SUB_EEI = 10002

--<< tastes >>
TASTE_BITTER = 20001
TASTE_NEUTRAL = 20002
TASTE_SALTY = 20003
TASTE_SOUR = 20004
TASTE_SPICY = 20005
TASTE_SWEET = 20006
TASTE_UMAMI = 20007

--<< entry keys >>
-- general
TYPE = 1
ENTITY = 2
LAST_UPDATE = 3
SUBENTITIES = 4
SPRITE = 5
ALTMODE_SPRITE = 6
NEIGHBORHOOD = 7
-- housing
INHABITANTS = 8
HAPPINESS = 9
HAPPINESS_SUMMANDS = 10
HAPPINESS_FACTORS = 11
HEALTH = 12
HEALTH_SUMMANDS = 13
HEALTH_FACTORS = 14
SANITY = 15
SANITY_SUMMANDS = 16
SANITY_FACTORS = 17
TREND = 18
IDEAS = 19
GARBAGE = 20
-- subentity stuff
POWER_USAGE = 100
SPEED_BONUS = 200
PRODUCTIVITY_BONUS = 201
HAS_PENALTY = 202
TICK_OF_CREATION = 300

--<< happiness summands >>
HAPPINESS_HOUSING = 1
HAPPINESS_SUITABLE_HOUSING = 2
HAPPINESS_TASTE = 3
HAPPINESS_FOOD_LUXURY = 4
HAPPINESS_FOOD_VARIETY = 5
HAPPINESS_NO_POWER = 6
HAPPINESS_POWER = 7
HAPPINESS_FEAR = 8
HAPPINESS_EMBER = 9

Types.happiness_summands_count = 9

--<< happiness factors >>
HAPPINESS_NOT_ENOUGH_FOOD_VARIETY = 1
HAPPINESS_HUNGER = 2
HAPPINESS_HEALTH = 3
HAPPINESS_SANITY = 4

Types.happiness_factors_count = 4

--<< health summands >>
HEALTH_NUTRIENTS = 1
HEALTH_FOOD = 2
HEALTH_FEAR = 3

Types.health_summands_count = 3

--<< health factors >>
HEALTH_HUNGER = 1

Types.health_factors_count = 1

--<< sanity summands >>
SANITY_HOUSING = 1
SANITY_TASTE = 2
SANITY_FAV_TASTE = 3
SANITY_NO_VARIETY = 4
SANITY_LEAST_FAV_TASTE = 5
SANITY_JUST_NEUTRAL = 6
SANITY_SINGLE_FOOD = 7
SANITY_FEAR = 8

Types.sanity_summands_count = 8

--<< sanity factors >>
SANITY_HUNGER = 1

Types.sanity_factors_count = 1

---------------------------------------------------------------------------------------------------
-- << lookup tables >>
Types.taste_names = {
    [TASTE_BITTER] = "bitter",
    [TASTE_NEUTRAL] = "neutral",
    [TASTE_SALTY] = "salty",
    [TASTE_SOUR] = "sour",
    [TASTE_SPICY] = "spicy",
    [TASTE_SWEET] = "sweet",
    [TASTE_UMAMI] = "umami"
}

Types.altmode_sprites = {
    [TYPE_EMPTY_HOUSE] = "empty-caste",
    [TYPE_CLOCKWORK] = "clockwork-caste",
    [TYPE_EMBER] = "ember-caste",
    [TYPE_GUNFIRE] = "gunfire-caste",
    [TYPE_GLEAM] = "gleam-caste",
    [TYPE_FOUNDRY] = "foundry-caste",
    [TYPE_ORCHID] = "orchid-caste",
    [TYPE_AURORA] = "aurora-caste"
}
local altmode_sprites = Types.altmode_sprites

local lookup_by_entity_type = {
    ["assembling-machine"] = TYPE_ASSEMBLING_MACHINE,
    ["mining-drill"] = TYPE_MINING_DRILL,
    ["lab"] = TYPE_LAB,
    ["rocket-silo"] = TYPE_ROCKET_SILO,
    ["furnace"] = TYPE_FURNACE,
    ["ammo-turret"] = TYPE_TURRET,
    ["electric-turret"] = TYPE_TURRET,
    ["fluid-turret"] = TYPE_TURRET,
    ["turret"] = TYPE_TURRET
}

local lookup_by_name = {
    ["farm"] = TYPE_FARM,
    ["greenhouse"] = TYPE_FARM
}

local houses
---------------------------------------------------------------------------------------------------
-- << type functions >>
function Types.init()
    houses = Housing.houses

    -- add the functional buildings to the lookup table
    for name, details in pairs(Buildings) do
        lookup_by_name[name] = details.type
    end
end

function Types.get_entity_type(entity)
    local name = entity.name
    local entity_type = entity.type

    -- check the ghost entity type before the other, because otherwise the name lookup would give them the type of the ghosted entity
    if entity_type == "entity-ghost" then
        return TYPE_NULL
    end

    if houses[name] then
        return TYPE_EMPTY_HOUSE
    end

    return lookup_by_name[name] or lookup_by_entity_type[entity_type] or TYPE_NULL
end

function Types.is_housing(_type)
    return _type < 100
end

function Types.is_inhabited(_type)
    return (_type < 100) and (_type > 0)
end

function Types.is_civil(_type)
    return _type < 1000
end

function Types.is_relevant_to_register(_type)
    return _type < 2000
end

function Types.is_affected_by_clockwork(_type)
    return (_type >= TYPE_ASSEMBLING_MACHINE) and (_type <= TYPE_ORANGERY)
end

function Types.is_affected_by_orchid(_type)
    return (_type >= TYPE_FARM) and (_type <= TYPE_ORANGERY)
end

function Types.needs_beacon(_type)
    return (_type >= TYPE_ASSEMBLING_MACHINE) and (_type <= TYPE_ORANGERY)
end

function Types.needs_eei(_type)
    return _type < 1000
end

function Types.needs_sprite(name)
    return false
end

function Types.get_sprite(name)
    if houses[name] then
        return "sprite-" .. name
    end
end

function Types.needs_alt_mode_sprite(_type)
    return altmode_sprites[_type] ~= nil
end

function Types.needs_neighborhood(_type) -- I might need to add more
    return Types.is_housing(_type)
end

local meta = {}

function meta:__call(entity)
    return Types.get_entity_type(entity)
end

setmetatable(Types, meta)
