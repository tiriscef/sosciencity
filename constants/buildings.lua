require("constants.enums")

--- Custom entities.
Buildings = {
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
    ["trash-site"] = {
        type = Type.dumpster,
        range = 25
    },
    ["water-tower"] = {
        type = Type.water_distributer,
        range = 35
    }
}

for _, details in pairs(Buildings) do
    -- convert power usages to J / tick
    if details.power_usage then
        details.power_usage = details.power_usage * 1000 / 60
    end
end
