require("constants.enums")

--- Defines the general custom properties for various entities.
Buildings = {}

--- Values of various custom behaviours I implemented for the Custom Buildings.\
--- **range:** number (tiles) or "global"\
--- **power_usage:** number (kW)\
--- **speed:** number (1/s)
Buildings.values = {
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
        speed = 20,
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
    },
    ["arboretum"] = {
        type = Type.farm
    },
    ["architectural-office"] = {
        type = Type.manufactory,
        range = 50,
        workforce = {
            count = 8,
            castes = {Type.clockwork, Type.gleam, Type.foundry}
        }
    },
    ["bloomhouse"] = {
        type = Type.farm
    },
    ["farm"] = {
        type = Type.farm
    },
    ["fishing-hut"] = {
        type = Type.fishery,
        range = 30,
        water_tiles = 300,
        workforce = {
            count = 4,
            castes = {Type.clockwork}
        }
    },
    ["greenhouse"] = {
        type = Type.farm
    },
    ["groundwater-pump"] = {
        type = Type.waterwell,
        range = 64
    },
    ["hunting-hut"] = {
        type = Type.hunting_hut,
        range = 30,
        tree_count = 100,
        workforce = {
            count = 4,
            castes = {Type.clockwork}
        }
    },
    ["industrial-animal-farm"] = {
        type = Type.animal_farm,
        range = 50
    },
    ["market-hall"] = {
        type = Type.market,
        range = 42
    },
    ["nightclub"] = {
        type = Type.nightclub,
        power_usage = 100,
        range = 50
    },
    ["orangery"] = {
        Type.farm
    },
    ["orchid-paradise"] = {
        Type.manufactory,
        workforce = {
            count = 7,
            castes = {Type.orchid}
        }
    },
    ["trash-site"] = {
        type = Type.dumpster,
        range = 25
    },
    ["water-tower"] = {
        type = Type.water_distributer,
        range = 35,
        power_usage = 50
    },
    ["zeppelin-port"] = {
        type = Type.immigration_port,
        interval = 1000,
        random_interval = 1000,
        capacity = 100,
        materials = {
            ["rope"] = 20
        }
    }
}
local buildings = Buildings.values

-- values postprocessing
for _, details in pairs(Buildings.values) do
    -- convert power usages to J / tick
    if details.power_usage then
        details.power_usage = details.power_usage * 1000 / Time.second
    end

    -- convert speed from x / sec to x / tick
    if details.speed then
        details.speed = details.speed / Time.second
    end
end

--- Returns the Custom Building specification of this entry or an empty table if this entry isn't an actual Custom Building.
function Buildings.get(entry)
    return buildings[entry[EK.name]] or {}
end
