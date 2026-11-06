local ProgressionGraph = require("tests.content.progression-graph")
local Castes = require("constants.castes")

local Assert = Tirislib.Testing.Assert

--- Bootstrap cycles: loops where X is needed to make X, like eggs -> inhabitants -> eggs.
--- The progression graph only derives a fact once one of its rules has everything it needs, so a loop
--- without a way in stays unobtainable by itself. For items that's already part of the unlock-order checks;
--- the loops through people need people as facts, which the graph has for inhabitants of every caste.

Tirislib.Testing.add_test_case(
    "Every caste can get inhabitants within the science tier of its caste technology",
    "content.bootstrap",
    function()
        for _, caste in pairs(Castes.all) do
            local state = ProgressionGraph.state_for(ProgressionGraph.get_tier(caste.tech_name))
            local fact = ProgressionGraph.inhabitants_fact(caste.type)
            local message = fact
            if not state:has(fact) then
                local loops = state:find_cycles({fact})
                message = string.format(
                    "%s (%s)\nloops without a way in:\n%s\nroot: %s",
                    fact,
                    caste.tech_name,
                    #loops > 0 and table.concat(loops, "\n", 1, math.min(#loops, 10)) or "none",
                    table.concat(state:find_roots({fact}), ", ")
                )
            end
            Assert.is_true(state:has(fact), message)
        end
    end
)
