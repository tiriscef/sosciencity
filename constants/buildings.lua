require("constants.enums")

--- Defines the general custom properties for various entities.
Buildings = {}

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
            count = 10,
            castes = {Type.clockwork}
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
    ["groundwater-pump"] = {
        type = Type.waterwell,
        range = 64,
        power_usage = 250,
        speed = 120
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

function Buildings.get(entry)
    return buildings[entry[EK.name]]
end
