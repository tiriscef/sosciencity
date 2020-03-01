require("constants.enums")

Buildings = {}

--- Custom entities.
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
    ["assembling-machine-2"] = {
        type = Type.manufactory,
        range = 20,
        workforce = {
            count = 20,
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
    return buildings[entry[EK.entity].name]
end
