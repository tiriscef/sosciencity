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
        range = 42
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
    ["arboretum"] = {type = Type.farm},
    ["architectural-office"] = {
        type = Type.manufactory,
        range = 50,
        workforce = {
            count = 8,
            castes = {Type.clockwork, Type.gleam, Type.foundry}
        }
    },
    ["farm"] = {type = Type.farm},
    ["greenhouse"] = {type = Type.farm},
    ["groundwater-pump"] = {
        type = Type.waterwell,
        range = 64
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
    ["orangery"] = {Type.orangery},
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
        details.power_usage = details.power_usage * 1000 / 60.
    end

    -- convert speed from x / sec to x / tick
    if details.speed then
        details.speed = details.speed / 60.
    end
end

--- Returns the Custom Building specification of this entry or an empty table if this entry isn't an actual Custom Building.
function Buildings.get(entry)
    return buildings[entry[EK.name]] or {}
end
