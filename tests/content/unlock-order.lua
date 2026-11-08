local ProgressionGraph = require("tests.content.progression-graph")
local ScriptedProducts = require("constants.scripted-products")

local Assert = Tirislib.Testing.Assert

--- Checks every technology against what the player can have in its science tier, which is every
--- technology that needs no other science packs. (Only the prerequisites are guaranteed, but checking
--- against them is stricter than the tech tree is meant to be: a player researches most of a tier
--- before moving on.)
---
--- - research: the science packs and the trigger need nothing but the rest of the tier.
---   Otherwise the technology is a deadlock.
--- - recipes: what a technology unlocks can be crafted with the tier, the technology included.
---   Otherwise it needs a later science tier.
--- - early recipes: what a technology unlocks can be crafted right away, without the technologies of the
---   tier that build on it. Otherwise the recipe shows up before the player can use it.

--- Problems that are known and accepted, which should not fail the test.
--- A listed problem that doesn't occur any more fails the test, so the list stays current.
--- Keys: "<technology> needs <fact>" for research, "<recipe> from <technology>" for recipes.
local known_problems = {
    research = {},
    recipe = {},
    early_recipe = {}
}

---------------------------------------------------------------------------------------------------
-- << analysis >>

--- Problems by kind (the keys of known_problems), each {key = string, message = string}.
--- Nil until the first test runs the analysis.
local problems

local function add_problem(kind, problem)
    local list = problems[kind]
    list[#list + 1] = problem
end

--- What researching the technology needs: its science packs and, if it has one, its trigger.
local function get_all_research_requirements(technology)
    local requirements = ProgressionGraph.get_research_requirements(technology)
    local trigger_requirement = ProgressionGraph.get_trigger_requirement(technology)
    if trigger_requirement then
        requirements[#requirements + 1] = trigger_requirement
    end
    return requirements
end

local function check_research(technology_name, technology, state)
    for _, requirement in pairs(get_all_research_requirements(technology)) do
        if not state:has(requirement) then
            add_problem("research", {
                key = technology_name .. " needs " .. requirement,
                message = string.format(
                    "%s needs %s - root: %s",
                    technology_name,
                    requirement,
                    table.concat(state:find_roots({requirement}), ", ")
                )
            })
        end
    end
end

--- The problem if the state can't craft the recipe, nil otherwise.
local function find_recipe_problem(state, recipe_name, technology_name)
    local missing = state:missing_for_recipe(recipe_name)
    if #missing == 0 then
        return nil
    end
    return {
        key = recipe_name .. " from " .. technology_name,
        message = string.format(
            "%s (from %s) needs %s - root: %s",
            recipe_name,
            technology_name,
            table.concat(missing, ", "),
            table.concat(state:find_roots(missing), ", ")
        )
    }
end

local function is_checked_recipe(recipe)
    return recipe and not recipe.parameter and not ProgressionGraph.is_generated_recipe(recipe)
end

--- Checks a recipe the technology unlocks. If the state right after the technology can't craft it,
--- the whole tier decides whether it needs a later tier or only shows up too early.
local function check_unlocked_recipe(recipe_name, technology_name, state)
    local early_problem = find_recipe_problem(state, recipe_name, technology_name)
    if not early_problem then
        return
    end

    local tier_problem =
        find_recipe_problem(ProgressionGraph.get_tier_state(technology_name), recipe_name, technology_name)
    if tier_problem then
        add_problem("recipe", tier_problem)
    else
        add_problem("early_recipe", early_problem)
    end
end

local function check_technology(technology_name, technology)
    local state = ProgressionGraph.state_for(ProgressionGraph.get_tier_without(technology_name))
    check_research(technology_name, technology, state)

    state:add_technology(technology_name)
    state:propagate()
    for _, recipe_name in pairs(ProgressionGraph.get_unlocked_recipes(technology)) do
        if is_checked_recipe(data.raw.recipe[recipe_name]) then
            check_unlocked_recipe(recipe_name, technology_name, state)
        end
    end
end

--- The problems of the given kind. Analyses all technologies on the first call.
local function get_problems(kind)
    if not problems then
        problems = {research = {}, recipe = {}, early_recipe = {}}
        for name, technology in pairs(data.raw.technology) do
            if ProgressionGraph.is_researchable(technology) then
                check_technology(name, technology)
            end
        end
    end
    return problems[kind]
end

---------------------------------------------------------------------------------------------------
-- << tests >>

--- Messages of the problems that aren't known, sorted.
local function get_new_problems(found, known)
    local new = {}
    for _, problem in pairs(found) do
        if not known[problem.key] then
            new[#new + 1] = problem.message
        end
    end
    table.sort(new)
    return new
end

--- Keys of the known problems that weren't found, sorted.
local function get_fixed_problems(found, known)
    local found_keys = {}
    for _, problem in pairs(found) do
        found_keys[problem.key] = true
    end

    local fixed = {}
    for key in pairs(known) do
        if not found_keys[key] then
            fixed[#fixed + 1] = key
        end
    end
    table.sort(fixed)
    return fixed
end

--- Asserts that the found problems of the kind are exactly the known ones.
local function assert_only_known(kind)
    local found = get_problems(kind)
    local new = get_new_problems(found, known_problems[kind])
    local fixed = get_fixed_problems(found, known_problems[kind])
    Assert.is_table_empty(new, "new problems:\n" .. table.concat(new, "\n"))
    Assert.is_table_empty(fixed, "fixed, remove from the known problems:\n" .. table.concat(fixed, "\n"))
end

Tirislib.Testing.add_test_case(
    "Every technology can be researched with what its science tier makes obtainable",
    "content.unlock-order",
    function()
        assert_only_known("research")
    end
)

Tirislib.Testing.add_test_case(
    "Every unlocked recipe can be crafted within its science tier",
    "content.unlock-order",
    function()
        assert_only_known("recipe")
    end
)

Tirislib.Testing.add_test_case(
    "Every unlocked recipe can be crafted as soon as its technology is researched",
    "content.unlock-order",
    function()
        assert_only_known("early_recipe")
    end
)

Tirislib.Testing.add_test_case(
    "A recipe that a building's script only runs with a module needs that module in the progression checks",
    "content.unlock-order",
    function()
        local state = ProgressionGraph.new_state()
        for recipe_name, module in pairs(ScriptedProducts.required_modules) do
            Assert.not_nil(data.raw.recipe[recipe_name], "recipe exists: " .. recipe_name)
            Assert.not_nil(data.raw.module[module] or data.raw.item[module], "module exists: " .. module)
            Assert.contains(state:missing_for_recipe(recipe_name), "item:" .. module, recipe_name)
        end
    end
)
