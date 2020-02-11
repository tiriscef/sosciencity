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

Buildings.types = {
    [Type.dumpster] = {
        localised_name = {"sosciencity-gui.dumpster"},
        localised_description = {"sosciencity-gui.explain-dumpster"}
    },
    [Type.market] = {
        localised_name = {"sosciencity-gui.market"},
        localised_description = {"sosciencity-gui.explain-market"}
    },
    [Type.hospital] = {
        localised_name = {"sosciencity-gui.hospital"},
        localised_description = {"sosciencity-gui.explain-hospital"}
    },
    [Type.water_distributer] = {
        localised_name = {"sosciencity-gui.water-distributer"},
        localised_description = {"sosciencity-gui.explain-water-distributer"}
    },
    [Type.waterwell] = {
        localised_name = {"sosciencity-gui.waterwell"},
        localised_description = {"sosciencity-gui.explain-waterwell"},
        localised_speed_name = {"sosciencity-gui.waterwell-speed"},
        localised_speed_key = "sosciencity-gui.show-waterwell-speed"
    }
}

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
    return buildings[entry[EntryKey.entity].name]
end
