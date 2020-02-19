require("constants.enums")

Types = {}

Types.definitions = {
    [Type.empty_house] = {altmode_sprite = "empty-caste"},
    [Type.clockwork] = {altmode_sprite = "clockwork-caste"},
    [Type.orchid] = {altmode_sprite = "orchid-caste"},
    [Type.gunfire] = {altmode_sprite = "gunfire-caste"},
    [Type.ember] = {altmode_sprite = "ember-caste"},
    [Type.foundry] = {altmode_sprite = "foundry-caste"},
    [Type.gleam] = {altmode_sprite = "gleam-caste"},
    [Type.aurora] = {altmode_sprite = "aurora-caste"},
    [Type.plasma] = {altmode_sprite = "plasma-caste"},
    [Type.market] = {
        localised_name = {"sosciencity-gui.market"},
        localised_description = {"sosciencity-gui.explain-market"}
    },
    [Type.water_distributer] = {
        localised_name = {"sosciencity-gui.water-distributer"},
        localised_description = {"sosciencity-gui.explain-water-distributer"}
    },
    [Type.hospital] = {
        localised_name = {"sosciencity-gui.hospital"},
        localised_description = {"sosciencity-gui.explain-hospital"}
    },
    [Type.dumpster] = {
        localised_name = {"sosciencity-gui.dumpster"},
        localised_description = {"sosciencity-gui.explain-dumpster"}
    },
    [Type.pharmacy] = {
        localised_name = {"sosciencity-gui.pharmacy"},
        localised_description = {"sosciencity-gui.explain-pharmacy"}
    },
    [Type.waterwell] = {
        localised_name = {"sosciencity-gui.waterwell"},
        localised_description = {"sosciencity-gui.explain-waterwell"},
        localised_speed_name = {"sosciencity-gui.waterwell-speed"},
        localised_speed_key = "sosciencity-gui.show-waterwell-speed"
    },
    [Type.immigration_port] = {
        localised_name = {"sosciencity-gui.immigration-port"},
        localised_description = {"sosciencity-gui.explain-immigration-port"}
    },
    [Type.assembling_machine] = {},
    [Type.furnace] = {},
    [Type.rocket_silo] = {},
    [Type.mining_drill] = {},
    [Type.farm] = {},
    [Type.orangery] = {},
    [Type.turret] = {},
    [Type.lab] = {}
}
local definitions = Types.definitions

---------------------------------------------------------------------------------------------------
-- << lookup tables >>
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
function Types.init()
    houses = Housing.values

    -- add the functional buildings to the lookup table
    for name, details in pairs(Buildings.values) do
        lookup_by_name[name] = details.type
    end
end

---------------------------------------------------------------------------------------------------
-- << type functions >>
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
    return definitions[_type].altmode_sprite ~= nil
end

local meta = {}

function meta:__call(entity)
    return Types.get_entity_type(entity)
end

setmetatable(Types, meta)
