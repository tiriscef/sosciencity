---------------------------------------------------------------------------------------------------
-- << enums >>

local ConnectionType = require("enums.connection-type")
local EK = require("enums.entry-key")
local Type = require("enums.type")

---------------------------------------------------------------------------------------------------
-- << constants >>

local Buildings = require("constants.buildings")
local Color = require("constants.color")
local Housing = require("constants.housing")
local TypeGroup = require("constants.type-groups")

---------------------------------------------------------------------------------------------------
-- << definitions >>

--- Entry type definitions
local Types = {}

local inhabitant_subscriptions = {
    [Type.market] = ConnectionType.bidirectional,
    [Type.water_distributer] = ConnectionType.from_neighbor,
    [Type.dumpster] = ConnectionType.bidirectional,
    [Type.nightclub] = ConnectionType.to_neighbor,
    [Type.egg_collector] = ConnectionType.to_neighbor,
    [Type.hospital] = ConnectionType.bidirectional,
    [Type.animal_farm] = ConnectionType.from_neighbor
}

local hospital_subscriptions = {}
for _, _type in pairs(TypeGroup.hospital_complements) do
    hospital_subscriptions[_type] = ConnectionType.from_neighbor
end

--- Type definitions\
--- **altmode_sprite:** name of the sprite that should be shown in altmode\
--- **subscriptions:** types that this type subscribes to by default\
--- **is_civil:** is this type is part of the soscietal infrastructure\
--- **is_inhabited:** do people live in this entity\
--- **affected_by_clockwork:** is this machine affected by the clockwork-maintenance-mechanic\
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
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.clockwork"}
    },
    [Type.orchid] = {
        altmode_sprite = "orchid-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.orchid"}
    },
    [Type.gunfire] = {
        altmode_sprite = "gunfire-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.gunfire"}
    },
    [Type.ember] = {
        altmode_sprite = "ember-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.ember"}
    },
    [Type.foundry] = {
        altmode_sprite = "foundry-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.foundry"}
    },
    [Type.gleam] = {
        altmode_sprite = "gleam-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.gleam"}
    },
    [Type.aurora] = {
        altmode_sprite = "aurora-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.aurora"}
    },
    [Type.plasma] = {
        altmode_sprite = "plasma-caste",
        subscriptions = inhabitant_subscriptions,
        is_civil = true,
        is_inhabited = true,
        localised_name = {"caste-name.plasma"}
    },
    [Type.market] = {
        localised_name = {"sosciencity.market"},
        localised_description = {"sosciencity.explain-market"},
        signature_color = Color.orange,
        subscriptions = {
            [Type.clockwork] = ConnectionType.bidirectional,
            [Type.orchid] = ConnectionType.bidirectional,
            [Type.gunfire] = ConnectionType.bidirectional,
            [Type.ember] = ConnectionType.bidirectional,
            [Type.foundry] = ConnectionType.bidirectional,
            [Type.gleam] = ConnectionType.bidirectional,
            [Type.aurora] = ConnectionType.bidirectional,
            [Type.plasma] = ConnectionType.bidirectional
        },
        is_civil = true
    },
    [Type.composter] = {
        localised_name = {"sosciencity.composter"},
        localised_description = {"sosciencity.explain-composter"},
        signature_color = Color.brown
    },
    [Type.composter_output] = {
        localised_name = {"sosciencity.composter-output"},
        localised_description = {"sosciencity.explain-composter-output"},
        signature_color = Color.brown,
        subscriptions = {
            [Type.composter] = ConnectionType.bidirectional
        }
    },
    [Type.water_distributer] = {
        localised_name = {"sosciencity.water-distributer"},
        localised_description = {"sosciencity.explain-water-distributer"},
        signature_color = Color.light_teal,
        subscriptions = {
            [Type.clockwork] = ConnectionType.to_neighbor,
            [Type.orchid] = ConnectionType.to_neighbor,
            [Type.gunfire] = ConnectionType.to_neighbor,
            [Type.ember] = ConnectionType.to_neighbor,
            [Type.foundry] = ConnectionType.to_neighbor,
            [Type.gleam] = ConnectionType.to_neighbor,
            [Type.aurora] = ConnectionType.to_neighbor,
            [Type.plasma] = ConnectionType.to_neighbor
        },
        is_civil = true
    },
    [Type.dumpster] = {
        localised_name = {"sosciencity.dumpster"},
        localised_description = {"sosciencity.explain-dumpster"},
        signature_color = Color.grey,
        subscriptions = {
            [Type.clockwork] = ConnectionType.bidirectional,
            [Type.orchid] = ConnectionType.bidirectional,
            [Type.gunfire] = ConnectionType.bidirectional,
            [Type.ember] = ConnectionType.bidirectional,
            [Type.foundry] = ConnectionType.bidirectional,
            [Type.gleam] = ConnectionType.bidirectional,
            [Type.aurora] = ConnectionType.bidirectional,
            [Type.plasma] = ConnectionType.bidirectional
        },
        is_civil = true
    },
    [Type.immigration_port] = {
        localised_name = {"sosciencity.immigration-port"},
        localised_description = {"sosciencity.explain-immigration-port"},
        is_civil = true
    },
    [Type.nightclub] = {
        localised_name = {"sosciencity.nightclub"},
        localised_description = {"sosciencity.explain-nightclub"},
        signature_color = Color.purple,
        subscriptions = {
            [Type.clockwork] = ConnectionType.from_neighbor,
            [Type.orchid] = ConnectionType.from_neighbor,
            [Type.gunfire] = ConnectionType.from_neighbor,
            [Type.ember] = ConnectionType.from_neighbor,
            [Type.foundry] = ConnectionType.from_neighbor,
            [Type.gleam] = ConnectionType.from_neighbor,
            [Type.aurora] = ConnectionType.from_neighbor,
            [Type.plasma] = ConnectionType.from_neighbor
        },
        is_civil = true
    },
    [Type.egg_collector] = {
        localised_name = {"sosciencity.egg-collector"},
        localised_description = {"sosciencity.explain-egg-collector"},
        is_civil = true
    },
    [Type.upbringing_station] = {
        localised_name = {"sosciencity.upbringing-station"},
        localised_description = {"sosciencity.explain-upbringing-station"},
        is_civil = true
    },
    [Type.pharmacy] = {
        localised_name = {"sosciencity.pharmacy"},
        localised_description = {"sosciencity.explain-pharmacy"},
        is_civil = true
    },
    [Type.hospital] = {
        localised_name = {"sosciencity.hospital"},
        localised_description = {"sosciencity.explain-hospital"},
        localised_speed_name = {"sosciencity.rate"},
        localised_speed_key = "sosciencity.show-hospital-rate",
        signature_color = Color.darkish_red,
        subscriptions = hospital_subscriptions,
        is_civil = true
    },
    [Type.psych_ward] = {
        localised_name = {"item-name.psych-ward"},
        localised_description = {"item-description.psych-ward"},
        signature_color = Color.darkish_red,
        is_civil = true
    },
    [Type.intensive_care_unit] = {
        localised_name = {"item-name.intensive-care-unit"},
        localised_description = {"item-description.intensive-care-unit"},
        signature_color = Color.darkish_red,
        is_civil = true
    },
    [Type.gene_clinic] = {
        localised_name = {"item-name.gene-clinic"},
        localised_description = {"item-description.gene-clinic"},
        signature_color = Color.darkish_red,
        is_civil = true
    },
    [Type.waterwell] = {
        localised_name = {"sosciencity.waterwell"},
        localised_description = {"sosciencity.explain-waterwell"},
        subscriptions = {
            [Type.waterwell] = ConnectionType.bidirectional
        },
        signature_color = Color.blue,
        is_civil = true
    },
    [Type.fishery] = {
        localised_name = {"sosciencity.fishery"},
        localised_description = {"sosciencity.explain-fishery"},
        subscriptions = {
            [Type.fishery] = ConnectionType.bidirectional
        },
        is_civil = true
    },
    [Type.hunting_hut] = {
        localised_name = {"sosciencity.hunting-hut"},
        localised_description = {"sosciencity.explain-hunting-hut"},
        subscriptions = {
            [Type.hunting_hut] = ConnectionType.bidirectional
        },
        is_civil = true
    },
    [Type.manufactory] = {
        localised_name = {"sosciencity.manufactory"},
        localised_description = {"sosciencity.explain-manufactory"},
        is_civil = true
    },
    [Type.assembling_machine] = {
        localised_name = {"sosciencity.machine"},
        localised_description = {"sosciencity.explain-machine"}
    },
    [Type.furnace] = {
        localised_name = {"sosciencity.machine"},
        localised_description = {"sosciencity.explain-machine"}
    },
    [Type.rocket_silo] = {
        localised_name = {"sosciencity.machine"},
        localised_description = {"sosciencity.explain-machine"}
    },
    [Type.mining_drill] = {
        localised_name = {"sosciencity.machine"},
        localised_description = {"sosciencity.explain-machine"}
    },
    [Type.farm] = {
        localised_name = {"sosciencity.farm"},
        localised_description = {"sosciencity.explain-farm"},
        subscriptions = {
            [Type.plant_care_station] = ConnectionType.from_neighbor
        }
    },
    [Type.animal_farm] = {
        signature_color = Color.brown
    },
    [Type.turret] = {},
    [Type.lab] = {
        localised_name = {"sosciencity.lab"},
        localised_description = {"sosciencity.explain-lab"}
    },
    [Type.plant_care_station] = {
        localised_name = {"sosciencity.plant-care-station"},
        localised_description = {"sosciencity.explain-plant-care-station"},
        localised_speed_name = {"sosciencity.work-rate"},
        localised_speed_key = "sosciencity.display-work-rate",
        is_civil = true,
        subscriptions = {
            [Type.farm] = ConnectionType.to_neighbor
        },
        signature_color = Color.yellowish_green
    },
    [Type.cooling_warehouse] = {
        localised_name = {"sosciencity.cooling-warehouse"},
        localised_description = {"sosciencity.explain-cooling-warehouse"}
    },
    [Type.waste_dump] = {
        localised_name = {"sosciencity.waste-dump"},
        localised_description = {"sosciencity.explain-waste-dump"}
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

-- add the houses to the lookup table
for name in pairs(Housing.values) do
    lookup_by_name[name] = Type.empty_house
end

-- add the functional buildings to the lookup table
for name, details in pairs(Buildings.values) do
    lookup_by_name[name] = details.type
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

--- Returns the type definition of the given entity
function Types.get(entry)
    return definitions[entry[EK.type]]
end

return Types
