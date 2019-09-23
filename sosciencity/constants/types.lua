-- entities
TYPE_CLOCKWORK = 1
TYPE_EMBER = 2
TYPE_GUNFIRE = 3
TYPE_GLEAM = 4
TYPE_FOUNDRY = 5
TYPE_ORCHID = 6
TYPE_AURORA = 7
TYPE_PLASMA = 8

TYPE_SHOPPING_CENTER = 101
TYPE_WATER_DISTRIBUTION_FACILITY = 102
TYPE_HOSPITAL = 103

TYPE_CLUB = 201
TYPE_SCHOOL = 202
TYPE_BARRACK = 203
TYPE_UNIVERSITY = 204
TYPE_UNIVERSITY_MK02 = 205
TYPE_CITY_HALL = 206
TYPE_RESEARCH_CENTER = 207

TYPE_ASSEMBLY_MACHINE = 1001
TYPE_FURNACE = 1002
TYPE_ROCKET_SILO = 1003
TYPE_MINING_DRILL = 1101
TYPE_LAB = 1102

TYPE_NULL = 9999

--subentities
SUB_BEACON = 1
SUB_EEI = 2

--tastes
TASTE_BITTER = 1
TASTE_NEUTRAL = 2
TASTE_SALTY = 3
TASTE_SOUR = 4
TASTE_SPICY = 5
TASTE_SWEET = 6
TASTE_UMAMI = 7

TYPES = {}
TYPES.entity_type_lookup = {
    types = {
        ["assembly-machine"] = TYPE_ASSEMBLY_MACHINE,
        ["mining-drill"] = TYPE_MINING_DRILL,
        ["lab"] = TYPE_LAB,
        ["rocket-silo"] = TYPE_ROCKET_SILO,
        ["furnace"] = TYPE_FURNACE
    },
    names = {
        ["shopping-center"] = TYPE_SHOPPING_CENTER,
        ["water-distribution-facility"] = TYPE_WATER_DISTRIBUTION_FACILITY,
        ["hospital"] = TYPE_HOSPITAL,
        ["club"] = TYPE_CLUB,
        ["school"] = TYPE_SCHOOL,
        ["barrack"] = TYPE_BARRACK,
        ["university"] = TYPE_UNIVERSITY,
        ["university-mk02"] = TYPE_UNIVERSITY_MK02,
        ["city-hall"] = TYPE_CITY_HALL,
        ["research-center"] = TYPE_CITY_HALL,
    },
    __call = function(self, entity)
        return self.types[entity.type] or self.names[entity.name] or TYPE_NULL
    end
}

function TYPES:get_entity_type(entity)
    return TYPES(entity)
end

TYPES.caste_names = {
    [TYPE_CLOCKWORK] = "clockwork",
    [TYPE_EMBER] = "ember",
    [TYPE_GUNFIRE] = "gunfire",
    [TYPE_GLEAM] = "gleam",
    [TYPE_FOUNDRY] = "foundry",
    [TYPE_ORCHID] = "orchid",
    [TYPE_AURORA] = "aurora",
    __call = function(self, type)
        return self[type]
    end
}

function TYPES:get_caste_name(type)
    return self.caste_names[type]
end

function TYPES:is_housing(type)
    return type < 100
end

function TYPES:entity_is_housing(entity)
    return self.entity_type_lookup(entity) < 100
end

function TYPES:is_civil(type)
    return type < 1000
end

function TYPES:entity_is_civil(entity)
    return self.entity_type_lookup(entity) < 1000
end

function TYPES:entity_is_relevant(entity)
    return self.entity_type_lookup(entity) ~= TYPE_NULL
end

function TYPES:is_affected_by_clockwork(type)
    return type >= TYPE_ASSEMBLY_MACHINE and type <= TYPE_ROCKET_SILO
end

function TYPES:entity_is_affected_by_clockwork(entity)
    local type = self.entity_type_lookup(entity)
    return type >= TYPE_ASSEMBLY_MACHINE and type <= TYPE_ROCKET_SILO
end

TYPES.subentity_lookup = {
    [SUB_BEACON] = "sosciencity-invisible-beacon",
    [SUB_EEI] = "sosciencity-invisible-eei"
}
