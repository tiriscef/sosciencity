local Buildings = require("constants.buildings")
local Housing = require("constants.housing")

local Assert = Tirislib.Testing.Assert

Tirislib.Testing.add_test_case(
    "Every building with a range shows it while being placed, houses included",
    "content.placement-range",
    function()
        local names = {}
        for name in pairs(Buildings.values) do
            names[name] = true
        end
        for name in pairs(Housing.values) do
            names[name] = true
        end

        local missing = {}
        for name in pairs(names) do
            local entity, found = Tirislib.Entity.get_by_name(name)
            if found and Buildings.get_by_name(name).range and not entity.radius_visualisation_specification then
                missing[#missing + 1] = name
            end
        end

        table.sort(missing)
        Assert.is_table_empty(missing, "no range shown while placing: " .. table.concat(missing, ", "))
    end
)
