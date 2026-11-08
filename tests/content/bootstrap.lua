local ProgressionGraph = require("tests.content.progression-graph")
local Castes = require("constants.castes")

local Assert = Tirislib.Testing.Assert

--- Bootstrap cycles: loops where X is needed to make X, like eggs -> inhabitants -> eggs.
--- The progression graph only derives a fact once one of its rules has everything it needs, so a loop
--- without a way in stays unobtainable by itself. For items that's already part of the unlock-order checks;
--- the loops through people need people as facts, which the graph has for inhabitants of every caste.

--- Why the state has no inhabitants of the caste: the loops without a way in and the roots.
local function describe_missing_inhabitants(state, caste, fact)
    local loops = state:find_cycles({fact})
    return string.format(
        "%s (%s)\nloops without a way in:\n%s\nroot: %s",
        fact,
        caste.tech_name,
        #loops > 0 and table.concat(loops, "\n", 1, math.min(#loops, 10)) or "none",
        table.concat(state:find_roots({fact}), ", ")
    )
end

Tirislib.Testing.add_test_case(
    "Every caste can get inhabitants within the science tier of its caste technology",
    "content.bootstrap",
    function()
        local problems = {}
        for _, caste in pairs(Castes.all) do
            local state = ProgressionGraph.get_tier_state(caste.tech_name)
            local fact = ProgressionGraph.inhabitants_fact(caste.type)
            if not state:has(fact) then
                problems[#problems + 1] = describe_missing_inhabitants(state, caste, fact)
            end
        end
        table.sort(problems)
        Assert.is_table_empty(problems, "castes without inhabitants:\n" .. table.concat(problems, "\n\n"))
    end
)
