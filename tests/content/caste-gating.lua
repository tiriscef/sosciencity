local ProgressionGraph = require("tests.content.progression-graph")
local Building = require("constants.buildings")

local Assert = Tirislib.Testing.Assert

--- Caste gating: buildings that need workers of a caste, and inhabitants that need a liveable house.
--- The progression graph knows both (working:<entity>, housing:<caste>), so the unlock-order checks already
--- see recipes in machines nobody can staff. This file checks the buildings themselves, which also covers
--- buildings that only work by script, like hospitals.

--- Entities with a workforce that the recipe places, by entity name.
local function get_staffed_buildings(recipe)
    local entities = {}
    for _, result in pairs(recipe.results or {}) do
        local item = result.type ~= "fluid" and Tirislib.Item.get_by_name(result.name)
        local entity_name = item and item.place_result
        local building = entity_name and Building.values[entity_name]
        if building and building.workforce then
            entities[#entities + 1] = entity_name
        end
    end
    return entities
end

--- Problems with the buildings with a workforce that the technology unlocks, as messages.
local function find_unstaffed_buildings(technology_name, technology)
    local problems = {}
    for _, recipe_name in pairs(ProgressionGraph.get_unlocked_recipes(technology)) do
        local recipe = data.raw.recipe[recipe_name]
        if recipe and not ProgressionGraph.is_generated_recipe(recipe) then
            for _, entity_name in pairs(get_staffed_buildings(recipe)) do
                local state = ProgressionGraph.get_tier_state(technology_name)
                local fact = ProgressionGraph.working_fact(entity_name)
                if not state:has(fact) then
                    problems[#problems + 1] = string.format(
                        "%s (from %s) - root: %s",
                        fact,
                        technology_name,
                        table.concat(state:find_roots({fact}), ", ")
                    )
                end
            end
        end
    end
    return problems
end

Tirislib.Testing.add_test_case(
    "Every building with a workforce can be staffed within the science tier that unlocks it",
    "content.caste-gating",
    function()
        local problems = {}
        for name, technology in pairs(data.raw.technology) do
            if ProgressionGraph.is_researchable(technology) then
                Tirislib.Tables.merge(problems, find_unstaffed_buildings(name, technology))
            end
        end
        table.sort(problems)
        Assert.is_table_empty(problems, "buildings without workers:\n" .. table.concat(problems, "\n"))
    end
)
