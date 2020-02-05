require("constants.types")

--- Custom entities.
Buildings = {
    ["test-dumpster"] = {
        type = TYPE_DUMPSTER,
        range = 42
    },
    ["test-market"] = {
        type = TYPE_MARKET,
        range = 42
    },
    ["test-hospital"] = {
        type = TYPE_HOSPITAL,
        range = 42
    },
    ["test-water-distributer"] = {
        type = TYPE_WATER_DISTRIBUTER,
        range = 42
    },
    ["trash-site"] = {
        type = TYPE_DUMPSTER,
        range = 25
    },
    ["water-tower"] = {
        type = TYPE_WATER_DISTRIBUTER,
        range = 35
    }
}

for _, details in pairs(Buildings) do
    -- convert power usages to J / tick
    if details.power_usage then
        details.power_usage = details.power_usage * 1000 / 60
    end
end
