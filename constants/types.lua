require("constants.enums")

Types = {}
---------------------------------------------------------------------------------------------------
-- << lookup tables >>
Types.altmode_sprites = {
    [Type.empty_house] = "empty-caste",
    [Type.clockwork] = "clockwork-caste",
    [Type.ember] = "ember-caste",
    [Type.gunfire] = "gunfire-caste",
    [Type.gleam] = "gleam-caste",
    [Type.foundry] = "foundry-caste",
    [Type.orchid] = "orchid-caste",
    [Type.aurora] = "aurora-caste"
}
local altmode_sprites = Types.altmode_sprites

local lookup_by_entity_type = {
    ["assembling-machine"] = Type.assembling_machine,
    ["mining-drill"] = Type.mining_drill,
    ["lab"] = Type.lab,
    ["rocket-silo"] = Type.rocket_silo,
    ["furnace"] = Type.furnace,
    ["ammo-turret"] = Type.turret,
    ["electric-turret"] = Type.turret,
    ["fluid-turret"] = Type.turret,
    ["turret"] = Type.turret
}

local lookup_by_name = {
    ["farm"] = Type.farm,
    ["greenhouse"] = Type.farm,
    ["arboretum"] = Type.farm
}

local houses
---------------------------------------------------------------------------------------------------
-- << type functions >>
function Types.init()
    houses = Housing.values

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
        return Type.null
    end

    if houses[name] then
        return Type.empty_house
    end

    return lookup_by_name[name] or lookup_by_entity_type[entity_type] or Type.null
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

Types.types_affected_by_clockwork = {
    Type.assembling_machine,
    Type.furnace,
    Type.rocket_silo,
    Type.mining_drill,
    Type.farm,
    Type.orangery
}

function Types.is_affected_by_clockwork(_type)
    return (_type >= Type.assembling_machine) and (_type <= Type.orangery)
end

function Types.is_affected_by_orchid(_type)
    return (_type >= Type.farm) and (_type <= Type.orangery)
end

function Types.needs_beacon(_type)
    return (_type >= Type.assembling_machine) and (_type <= Type.orangery)
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
