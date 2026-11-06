local Unlocks = require("constants.unlocks")

local Assert = Tirislib.Testing.Assert

Tirislib.Testing.add_test_case(
    "Every trigger technology unlocks something",
    "content.trigger-technologies",
    function()
        local empty = {}
        for name in pairs(Unlocks.by_item_acquisition) do
            local technology = data.raw.technology[name]
            if not technology or not technology.effects or next(technology.effects) == nil then
                empty[#empty + 1] = name
            end
        end

        table.sort(empty)
        Assert.is_table_empty(empty, "trigger technologies without effects: " .. table.concat(empty, ", "))
    end
)
