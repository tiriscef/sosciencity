require("constants.enums")

Types = {}

---------------------------------------------------------------------------------------------------
-- << type groups >>
TypeGroup = {}

TypeGroup.all_castes = {
    Type.clockwork,
    Type.orchid,
    Type.gunfire,
    Type.ember,
    Type.foundry,
    Type.gleam,
    Type.aurora,
    Type.plasma
}

TypeGroup.affected_by_clockwork = {
    Type.assembling_machine,
    Type.furnace,
    Type.rocket_silo,
    Type.mining_drill,
    Type.farm,
    Type.orangery
}

TypeGroup.inhabitant_subscriptions = {
    Type.market,
    Type.water_distributer,
    Type.hospital,
    Type.dumpster
}

---------------------------------------------------------------------------------------------------
-- << definitions >>
Types.definitions = {
    [Type.empty_house] = {
        altmode_sprite = "empty-caste"
    },
    [Type.clockwork] = {
        altmode_sprite = "clockwork-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.orchid] = {
        altmode_sprite = "orchid-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.gunfire] = {
        altmode_sprite = "gunfire-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.ember] = {
        altmode_sprite = "ember-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.foundry] = {
        altmode_sprite = "foundry-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.gleam] = {
        altmode_sprite = "gleam-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.aurora] = {
        altmode_sprite = "aurora-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.plasma] = {
        altmode_sprite = "plasma-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions
    },
    [Type.market] = {
        localised_name = {"sosciencity-gui.market"},
        localised_description = {"sosciencity-gui.explain-market"},
        signature_color = {r = 1, g = 0.45, b = 0, a = 1}
    },
    [Type.water_distributer] = {
        localised_name = {"sosciencity-gui.water-distributer"},
        localised_description = {"sosciencity-gui.explain-water-distributer"},
        signature_color = {r = 0, g = 0.8, b = 1, a = 1}
    },
    [Type.hospital] = {
        localised_name = {"sosciencity-gui.hospital"},
        localised_description = {"sosciencity-gui.explain-hospital"},
        signature_color = {r = 0.8, g = 0.1, b = 0.1, a = 1}
    },
    [Type.dumpster] = {
        localised_name = {"sosciencity-gui.dumpster"},
        localised_description = {"sosciencity-gui.explain-dumpster"},
        signature_color = {r = 0.8, g = 0.8, b = 0.8, a = 1}
    },
    [Type.pharmacy] = {
        localised_name = {"sosciencity-gui.pharmacy"},
        localised_description = {"sosciencity-gui.explain-pharmacy"}
    },
    [Type.waterwell] = {
        localised_name = {"sosciencity-gui.waterwell"},
        localised_description = {"sosciencity-gui.explain-waterwell"},
        localised_speed_name = {"sosciencity-gui.waterwell-speed"},
        localised_speed_key = "sosciencity-gui.show-waterwell-speed",
        subscriptions = {Type.waterwell},
        signature_color = {r = 0, g = 0, b = 1, a = 1}
    },
    [Type.immigration_port] = {
        localised_name = {"sosciencity-gui.immigration-port"},
        localised_description = {"sosciencity-gui.explain-immigration-port"}
    },
    [Type.fishery] = {
        localised_name = {"sosciencity-gui.fishery"},
        localised_description = {"sosciencity-gui.explain-fishery"},
        subscriptions = {Type.fishery}
    },
    [Type.manufactory] = {
        localised_name = {"sosciencity-gui.manufactory"},
        localised_description = {"sosciencity-gui.explain-manufactory"},
        subscriptions = TypeGroup.all_castes
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

function Types.load()
    -- add the houses to the lookup table
    for name in pairs(Housing.values) do
        lookup_by_name[name] = Type.empty_house
    end

    -- add the functional buildings to the lookup table
    for name, details in pairs(Buildings.values) do
        lookup_by_name[name] = details.type
    end
end

---------------------------------------------------------------------------------------------------
-- << type functions >>
--- Returns the internal type for the given entity.
function Types.get_entity_type(entity)
    local name = entity.name
    local entity_type = entity.type

    -- check the ghost entity type before the other, because otherwise the name lookup would give them the type of the ghosted entity
    if entity_type == "entity-ghost" then
        return Type.null
    end

    return lookup_by_name[name] or lookup_by_entity_type[entity_type] or Type.null
end

-- TODO change these functions, because they are really bad code
function Types.is_inhabited(_type)
    return (_type < 100) and (_type > 0)
end

function Types.is_civil(_type)
    return _type < 1000
end

function Types.is_relevant_to_register(_type)
    return _type < 2000
end

function Types.needs_beacon(_type)
    return (_type >= Type.fishery) and (_type <= Type.orangery)
end

function Types.get(entry)
    return definitions[entry[EK.type]]
end

local meta = {}

function meta:__call(entity)
    return Types.get_entity_type(entity)
end

setmetatable(Types, meta)
