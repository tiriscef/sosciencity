-- entities
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
TYPE_WATER_DISTRIBUTION_FACILITY = 102
TYPE_HOSPITAL = 103
TYPE_PHARMACY = 104

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

TYPE_TURRET = 1100

TYPE_LAB = 2002

TYPE_NULL = 9999

-- subentities
SUB_BEACON = 1
SUB_EEI = 2
SUB_ALT_MODE_SPRITE = 3

-- neighborhood
NEIGHBOR_MARKET = 1

-- tastes
TASTE_BITTER = 1
TASTE_NEUTRAL = 2
TASTE_SALTY = 3
TASTE_SOUR = 4
TASTE_SPICY = 5
TASTE_SWEET = 6
TASTE_UMAMI = 7

-- flags
FLAG_LOW_PROTEIN = 1
FLAG_HIGH_PROTEIN = 2
FLAG_HIGH_FAT = 3
FLAG_HIGH_CARBOHYDRATES = 4
FLAG_HUNGER = 5
FLAG_NO_POWER = 6

Types = {}
Types.entity_type_lookup = {
    types = {
        ["assembling-machine"] = TYPE_ASSEMBLING_MACHINE,
        ["mining-drill"] = TYPE_MINING_DRILL,
        ["lab"] = TYPE_LAB,
        ["rocket-silo"] = TYPE_ROCKET_SILO,
        ["furnace"] = TYPE_FURNACE,
        ["ammo-turret"] = TYPE_TURRET,
        ["electric-turret"] = TYPE_TURRET,
        ["fluid-turret"] = TYPE_TURRET,
        ["turret"] = TYPE_TURRET
    },
    names = {
        -- TODO add the names from housing
        ["test-house"] = TYPE_EMPTY_HOUSE,
        ["market"] = TYPE_MARKET,
        ["water-distribution-facility"] = TYPE_WATER_DISTRIBUTION_FACILITY,
        ["hospital"] = TYPE_HOSPITAL,
        ["club"] = TYPE_CLUB,
        ["school"] = TYPE_SCHOOL,
        ["barrack"] = TYPE_BARRACK,
        ["university"] = TYPE_UNIVERSITY,
        ["university-mk02"] = TYPE_UNIVERSITY_MK02,
        ["city-hall"] = TYPE_CITY_HALL,
        ["research-center"] = TYPE_CITY_HALL
    }
}

function Types.get_entity_type(entity)
    return Types.entity_type_lookup.names[entity.name] or Types.entity_type_lookup.types[entity.type] or TYPE_NULL
end

function Types.is_housing(_type)
    return _type < 100
end

function Types.is_inhabited(_type)
    return (_type < 100) and (_type ~= 0)
end

function Types.is_civil(_type)
    return _type < 1000
end

function Types.is_relevant_to_register(_type)
    return _type < 2000
end

function Types.is_affected_by_clockwork(_type)
    return (_type >= TYPE_ASSEMBLING_MACHINE) and (_type <= TYPE_MINING_DRILL)
end

function Types.needs_beacon(_type)
    return (_type >= TYPE_ASSEMBLING_MACHINE) and (_type <= TYPE_MINING_DRILL)
end

function Types.needs_eei(_type)
    return _type < 1000
end

function Types.needs_alt_mode_sprite(_type)
    return _type < 100
end

Types.taste_names = {
    [TASTE_BITTER] = "bitter",
    [TASTE_NEUTRAL] = "neutral",
    [TASTE_SALTY] = "salty",
    [TASTE_SOUR] = "sour",
    [TASTE_SPICY] = "spicy",
    [TASTE_SWEET] = "sweet",
    [TASTE_UMAMI] = "umami"
}

function Types.needs_neighborhood(_type) -- I might need to add more
    return Types.is_housing(_type)
end

Types.caste_names = {
    [TYPE_CLOCKWORK] = "clockwork",
    [TYPE_ORCHID] = "orchid",
    [TYPE_GUNFIRE] = "gunfire",
    [TYPE_EMBER] = "ember",
    [TYPE_FOUNDRY] = "foundry",
    [TYPE_GLEAM] = "gleam",
    [TYPE_AURORA] = "aurora"
}

function Types.get_caste_name(_type)
    return Types.caste_names[_type]
end

setmetatable(
    Types.caste_names,
    {
        __call = function(_, _type)
            return Types.get_caste_name(_type)
        end
    }
)

Types.caste_sprites = {
    [TYPE_EMPTY_HOUSE] = "empty-caste",
    [TYPE_CLOCKWORK] = "clockwork-caste",
    [TYPE_EMBER] = "ember-caste",
    [TYPE_GUNFIRE] = "gunfire-caste",
    [TYPE_GLEAM] = "gleam-caste",
    [TYPE_FOUNDRY] = "foundry-caste",
    [TYPE_ORCHID] = "orchid-caste",
    [TYPE_AURORA] = "aurora-caste"
}

local meta = {}

function meta:__call(entity)
    return Types.get_entity_type(entity)
end

setmetatable(Types, meta)
