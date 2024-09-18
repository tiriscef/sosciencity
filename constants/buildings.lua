local EK = require("enums.entry-key")
local SubentityType = require("enums.subentity-type")
local Type = require("enums.type")

local Time = require("constants.time")
local Housing = require("constants.housing")

--- Defines the general custom properties for various entities.
local Building = {}

local range_by_foot = 50

--- Values of various custom behaviours I implemented for the Custom Buildings.\
--- **range:** number (tiles) or "global"\
--- **power_usage:** number (kW)\
--- **speed:** number (1/tick)
Building.values = {
    ["algae-farm"] = {
        type = Type.automatic_farm,
        accepts_plant_care = false
    },
    ["aquafarm"] = {
        type = Type.animal_farm,
        range = 50
    },
    ["arboretum"] = {
        type = Type.farm,
        open_environment = true,
        accepts_plant_care = true
    },
    ["architectural-office"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 8,
            castes = {Type.clockwork, Type.gleam, Type.foundry}
        }
    },
    ["bloomhouse"] = {
        type = Type.farm,
        workforce = {
            count = 2,
            castes = {Type.orchid}
        },
        accepts_plant_care = true
    },
    ["city-combinator"] = {
        type = Type.city_combinator
    },
    ["clockwork-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.clockwork}
        }
    },
    ["composting-silo"] = {
        type = Type.composter,
        capacity = 5000
    },
    ["composting-silo-output"] = {
        type = Type.composter_output,
        range = 5
    },
    ["cooling-warehouse"] = {
        type = Type.cooling_warehouse
    },
    ["egg-collecting-station"] = {
        type = Type.egg_collector,
        range = 40
    },
    ["ember-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.ember}
        }
    },
    ["farm"] = {
        type = Type.farm,
        open_environment = true,
        accepts_plant_care = true
    },
    ["fishing-hut"] = {
        type = Type.fishery,
        range = 30,
        water_tiles = 300,
        workforce = {
            count = 4,
            castes = {Type.orchid}
        }
    },
    ["foundry-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.foundry}
        }
    },
    ["gene-clinic"] = {
        type = Type.gene_clinic,
        range = 7
    },
    ["gleam-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.gleam}
        }
    },
    ["greenhouse"] = {
        type = Type.farm,
        accepts_plant_care = true
    },
    ["groundwater-pump"] = {
        type = Type.waterwell,
        range = 30
    },
    ["gunfire-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.gunfire}
        },
        subentities = {
            SubentityType.turret_gunfire_hq1,
            SubentityType.turret_gunfire_hq2,
            SubentityType.turret_gunfire_hq3,
            SubentityType.turret_gunfire_hq4
        },
        subentity_offsets = {
            [SubentityType.turret_gunfire_hq1] = {x = 3.9, y = 0.4},
            [SubentityType.turret_gunfire_hq2] = {x = 3.9, y = -5.25},
            [SubentityType.turret_gunfire_hq3] = {x = -3.9, y = 0.4},
            [SubentityType.turret_gunfire_hq4] = {x = -3.9, y = -5.25}
        }
    },
    ["hospital"] = {
        type = Type.hospital,
        range = 150,
        speed = 2 / Time.second,
        workforce = {
            count = 10,
            castes = {Type.plasma}
        },
        power_usage = 100
    },
    ["hunting-hut"] = {
        type = Type.hunting_hut,
        range = 30,
        tree_count = 100,
        workforce = {
            count = 4,
            castes = {Type.orchid}
        }
    },
    ["industrial-animal-farm"] = {
        type = Type.animal_farm,
        range = 50
    },
    ["intensive-care-unit"] = {
        type = Type.intensive_care_unit,
        range = 7
    },
    ["market-hall"] = {
        type = Type.market,
        range = range_by_foot
    },
    ["medbay"] = {
        type = Type.improvised_hospital,
        range = 50,
        speed = 0.4 / Time.second,
        workforce = {
            count = 5,
            castes = {Type.orchid, Type.plasma}
        },
        power_usage = 50
    },
    ["mushroom-farm"] = {
        type = Type.automatic_farm,
        accepts_plant_care = false
    },
    ["nightclub"] = {
        type = Type.nightclub,
        range = range_by_foot,
        power_usage = 100
    },
    ["orangery"] = {
        type = Type.farm,
        accepts_plant_care = true
    },
    ["orchid-food-factory"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.orchid}
        }
    },
    ["orchid-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.orchid}
        }
    },
    ["orchid-plant-care-station"] = {
        type = Type.plant_care_station,
        range = 30,
        speed = 60 / Time.minute,
        humus_capacity = 1000,
        workforce = {
            count = 2,
            castes = {Type.orchid}
        }
    },
    ["pharmacy"] = {
        type = Type.pharmacy,
        range = "global"
    },
    ["psych-ward"] = {
        type = Type.psych_ward,
        range = 7
    },
    ["salt-pond"] = {
        type = Type.salt_pond,
        range = 10.5,
        water_tiles = 45
    },
    ["trash-site"] = {
        type = Type.dumpster,
        range = range_by_foot
    },
    ["upbringing-station"] = {
        type = Type.upbringing_station,
        power_usage = 150,
        power_drain = 5,
        capacity = 20
    },
    ["waste-dump"] = {
        type = Type.waste_dump,
        capacity = 200000
    },
    ["water-tower"] = {
        type = Type.water_distributer,
        range = 70
    },
    ["zeppelin-port"] = {
        type = Type.immigration_port,
        interval = 1000,
        random_interval = 1000,
        capacity = 100,
        materials = {
            ["rope"] = 20
        }
    },
    ["test-dumpster"] = {
        type = Type.dumpster,
        range = 42
    },
    ["test-market"] = {
        type = Type.market,
        range = 42
    },
    ["test-hospital"] = {
        type = Type.hospital,
        range = 42,
        speed = 20 / Time.second,
        workforce = {
            count = 20,
            castes = {Type.plasma}
        },
        power_usage = 50
    },
    ["test-psych-ward"] = {
        type = Type.psych_ward,
        range = 42,
        power_usage = 50
    },
    ["test-water-distributer"] = {
        type = Type.water_distributer,
        range = 42
    },
    ["test-fishery"] = {
        type = Type.fishery,
        range = 30,
        water_tiles = 300,
        workforce = {
            count = 20,
            castes = {Type.clockwork}
        }
    },
    ["test-composter"] = {
        type = Type.composter,
        capacity = 5000
    },
    ["test-compost-output"] = {
        type = Type.composter_output,
        range = 5
    },
    ["test-pharmacy"] = {
        type = Type.pharmacy,
        range = "global"
    },
    ["test-upbringing-station"] = {
        type = Type.upbringing_station,
        power_usage = 100,
        capacity = 40
    },
    ["test-egg-collector"] = {
        type = Type.egg_collector,
        range = 42
    }
}
local buildings = Building.values

-- values postprocessing
for _, details in pairs(Building.values) do
    -- convert power usages to J / tick
    if details.power_usage then
        details.power_usage = details.power_usage * 1000 / Time.second
    end
end

local houses = Housing.values
local housing_details = {
    range = range_by_foot, -- range 'by foot'
    power_usage = 1 -- Will be set dynamically, depending on the number of inhabitants. This dummy value will assure the eei is spawned upon placement.
}

--- Returns the Custom Building specification of this entry or an empty table if this entry isn't an actual Custom Building.
function Building.get(entry)
    local name = entry[EK.name]
    return buildings[name] or (houses[name] and housing_details) or {}
end

return Building
