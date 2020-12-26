require("constants.enums")
require("constants.colors")

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
    Type.waterwell
}

TypeGroup.inhabitant_subscriptions = {
    Type.market,
    Type.water_distributer,
    Type.hospital,
    Type.dumpster,
    Type.nightclub,
    Type.animal_farm
}

---------------------------------------------------------------------------------------------------
-- << definitions >>
--- Type definitions\
--- **altmode_sprite:** name of the sprite that should be shown in altmode\
--- **subscriptions:** types that this type subscribes to by default\
--- **is_civil:** is this type is part of the soscietal infrastructure\
--- **is_inhabited:** do people live in this entity\
--- **affected_by_clockwork:** is this machine affected by the clockwork-maintainance-mechanic\
--- **signature_color:** color for this entity, for displaying purposes\
--- **localised_name:** localised name for this type\
--- **localised_description:** localised description for this type
Types.definitions = {
    [Type.empty_house] = {
        altmode_sprite = "empty-caste",
        is_civil = true
    },
    [Type.clockwork] = {
        altmode_sprite = "clockwork-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.clockwork"}
    },
    [Type.orchid] = {
        altmode_sprite = "orchid-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.orchid"}
    },
    [Type.gunfire] = {
        altmode_sprite = "gunfire-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.gunfire"}
    },
    [Type.ember] = {
        altmode_sprite = "ember-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.ember"}
    },
    [Type.foundry] = {
        altmode_sprite = "foundry-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.foundry"}
    },
    [Type.gleam] = {
        altmode_sprite = "gleam-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.gleam"}
    },
    [Type.aurora] = {
        altmode_sprite = "aurora-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.aurora"}
    },
    [Type.plasma] = {
        altmode_sprite = "plasma-caste",
        subscriptions = TypeGroup.inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.plasma"}
    },
    [Type.market] = {
        localised_name = {"sosciencity-gui.market"},
        localised_description = {"sosciencity-gui.explain-market"},
        signature_color = Colors.orange,
        is_civil = true
    },
    [Type.composter] = {
        localised_name = {"sosciencity-gui.composter"},
        localised_description = {"sosciencity-gui.explain-composter"},
        signature_color = Colors.brown
    },
    [Type.composter_output] = {
        localised_name = {"sosciencity-gui.composter-output"},
        localised_description = {"sosciencity-gui.explain-composter-output"},
        signature_color = Colors.brown,
        subscriptions = {Type.composter}
    },
    [Type.water_distributer] = {
        localised_name = {"sosciencity-gui.water-distributer"},
        localised_description = {"sosciencity-gui.explain-water-distributer"},
        signature_color = Colors.light_teal,
        is_civil = true
    },
    [Type.hospital] = {
        localised_name = {"sosciencity-gui.hospital"},
        localised_description = {"sosciencity-gui.explain-hospital"},
        signature_color = Colors.darkish_red,
        is_civil = true
    },
    [Type.dumpster] = {
        localised_name = {"sosciencity-gui.dumpster"},
        localised_description = {"sosciencity-gui.explain-dumpster"},
        signature_color = Colors.grey,
        is_civil = true
    },
    [Type.pharmacy] = {
        localised_name = {"sosciencity-gui.pharmacy"},
        localised_description = {"sosciencity-gui.explain-pharmacy"},
        is_civil = true
    },
    [Type.immigration_port] = {
        localised_name = {"sosciencity-gui.immigration-port"},
        localised_description = {"sosciencity-gui.explain-immigration-port"},
        is_civil = true
    },
    [Type.nightclub] = {
        localised_name = {"sosciencity-gui.nightclub"},
        localised_description = {"sosciencity-gui.explain-nightclub"},
        signature_color = Colors.purple,
        is_civil = true
    },
    [Type.waterwell] = {
        localised_name = {"sosciencity-gui.waterwell"},
        localised_description = {"sosciencity-gui.explain-waterwell"},
        subscriptions = {Type.waterwell},
        signature_color = Colors.blue,
        is_civil = true
    },
    [Type.fishery] = {
        localised_name = {"sosciencity-gui.fishery"},
        localised_description = {"sosciencity-gui.explain-fishery"},
        subscriptions = {Type.fishery},
        is_civil = true
    },
    [Type.hunting_hut] = {
        localised_name = {"sosciencity-gui.hunting-hut"},
        localised_description = {"sosciencity-gui.explain-hunting-hut"},
        subscriptions = {Type.hunting_hut},
        is_civil = true
    },
    [Type.manufactory] = {
        localised_name = {"sosciencity-gui.manufactory"},
        localised_description = {"sosciencity-gui.explain-manufactory"},
        subscriptions = TypeGroup.all_castes,
        is_civil = true
    },
    [Type.assembling_machine] = {
        localised_name = {"sosciencity-gui.machine"},
        localised_description = {"sosciencity-gui.explain-machine"}
    },
    [Type.furnace] = {
        localised_name = {"sosciencity-gui.machine"},
        localised_description = {"sosciencity-gui.explain-machine"}
    },
    [Type.rocket_silo] = {
        localised_name = {"sosciencity-gui.machine"},
        localised_description = {"sosciencity-gui.explain-machine"}
    },
    [Type.mining_drill] = {
        localised_name = {"sosciencity-gui.machine"},
        localised_description = {"sosciencity-gui.explain-machine"}
    },
    [Type.farm] = {},
    [Type.animal_farm] = {
        signature_color = Colors.brown
    },
    [Type.turret] = {},
    [Type.lab] = {
        localised_name = {"sosciencity-gui.lab"},
        localised_description = {"sosciencity-gui.explain-lab"}
    }
}
local definitions = Types.definitions

for _, type in pairs(TypeGroup.affected_by_clockwork) do
    definitions[type].affected_by_clockwork = true
end

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

local lookup_by_name = {}

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

function Types.get(entry)
    return definitions[entry[EK.type]]
end

local meta = {}

function meta:__call(entity)
    return Types.get_entity_type(entity)
end

setmetatable(Types, meta)
