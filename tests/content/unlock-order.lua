local ProgressionGraph = require("tests.content.progression-graph")

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

--- Recipes that the game or other mods generate for every item or fluid, not meant as a step of progression.
local generated_subgroups = {
    ["fill-barrel"] = true,
    ["empty-barrel"] = true
}

local function is_generated(recipe)
    if generated_subgroups[recipe.subgroup] then
        return true
    end
    for _, category in pairs(recipe.categories or {recipe.category}) do
        if category == "recycling" then
            return true
        end
    end
    return false
end

--- What the trigger of a trigger technology needs, as a fact. Nil if the trigger type isn't checked.
local function get_trigger_requirement(trigger)
    if trigger.type == "craft-item" then
        return "item:" .. (type(trigger.item) == "table" and trigger.item.name or trigger.item)
    elseif trigger.type == "craft-fluid" then
        return "fluid:" .. trigger.fluid
    elseif trigger.type == "build-entity" then
        return "entity:" .. (type(trigger.entity) == "table" and trigger.entity.name or trigger.entity)
    end
end

--- Problems found when the test was written, to be fixed before the alpha release.
--- The test fails on problems that aren't listed and on listed ones that don't occur any more,
--- so remove an entry when fixing it.
--- Keys: "<technology> needs <fact>" for research, "<recipe> from <technology>" for recipes.
local known_research_problems = {}

local known_recipe_problems = {
    ["amylum from medbay"] = true,
    ["analgesics from medbay"] = true,
    ["antiemetics from medbay"] = true,
    ["antihistamines from medbay"] = true,
    ["education-gunfire from gunfire-caste"] = true,
    ["extract-spinal-fluid from ovosynthesis"] = true,
    ["farming-annual-bloomhouse-necrofall from sosciencity-unlock-necrofall"] = true,
    ["huwan-egg-ovosynthesis from ovosynthesis"] = true,
    ["marble1 from clockwork-quarry"] = true,
    ["nutritional-supplements from medbay"] = true,
    ["power-tools from tinkering-workshop"] = true,
    ["power-tools-workshop from tinkering-workshop"] = true,
    ["psych-ward from psychiatry"] = true,
    ["sosciencity-medical-kit1 from medbay"] = true
}

local known_early_recipe_problems = {
    ["antimicrobials from medbay"] = true,
    ["bread from food-processing"] = true,
    ["glass from infrastructure-1"] = true,
    ["glass-mixture from infrastructure-1"] = true,
    ["isotonic-saline-solution from medbay"] = true,
    ["window from infrastructure-1"] = true
}

--- Problems by kind, each {key = string, message = string}.
local research_problems
local recipe_problems
local early_recipe_problems

local tier_states = {}

--- The state of the whole tier of the technology, shared by all technologies of that tier.
local function get_tier_state(technology_name)
    local tier = ProgressionGraph.get_tier(technology_name)
    local state = tier_states[tier]
    if not state then
        state = ProgressionGraph.state_for(tier)
        tier_states[tier] = state
    end
    return state
end

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

local function analyse()
    if research_problems then
        return
    end
    research_problems = {}
    recipe_problems = {}
    early_recipe_problems = {}

    for name, technology in pairs(data.raw.technology) do
        if ProgressionGraph.is_researchable(technology) then
            local state = ProgressionGraph.state_for(ProgressionGraph.get_tier_without(name))

            local requirements = ProgressionGraph.get_research_requirements(technology)
            local trigger_requirement = technology.research_trigger and
                get_trigger_requirement(technology.research_trigger)
            if trigger_requirement then
                requirements[#requirements + 1] = trigger_requirement
            end
            for _, requirement in pairs(requirements) do
                if not state:has(requirement) then
                    research_problems[#research_problems + 1] = {
                        key = name .. " needs " .. requirement,
                        message = string.format(
                            "%s needs %s - root: %s",
                            name,
                            requirement,
                            table.concat(state:find_roots({requirement}), ", ")
                        )
                    }
                end
            end

            state:add_technology(name)
            state:propagate()
            for _, recipe_name in pairs(ProgressionGraph.get_unlocked_recipes(technology)) do
                local recipe = data.raw.recipe[recipe_name]
                if recipe and not recipe.parameter and not is_generated(recipe) then
                    local early_problem = find_recipe_problem(state, recipe_name, name)
                    if early_problem then
                        local tier_problem = find_recipe_problem(get_tier_state(name), recipe_name, name)
                        if tier_problem then
                            recipe_problems[#recipe_problems + 1] = tier_problem
                        else
                            early_recipe_problems[#early_recipe_problems + 1] = early_problem
                        end
                    end
                end
            end
        end
    end
end

--- Asserts that the found problems are exactly the known ones.
local function assert_only_known(problems, known)
    local new = {}
    local found = {}
    for _, problem in pairs(problems) do
        found[problem.key] = true
        if not known[problem.key] then
            new[#new + 1] = problem.message
        end
    end

    local fixed = {}
    for key in pairs(known) do
        if not found[key] then
            fixed[#fixed + 1] = key
        end
    end

    table.sort(new)
    table.sort(fixed)
    Assert.is_table_empty(new, "new problems:\n" .. table.concat(new, "\n"))
    Assert.is_table_empty(fixed, "fixed, remove from the known problems:\n" .. table.concat(fixed, "\n"))
end

Tirislib.Testing.add_test_case(
    "Every technology can be researched with what its science tier makes obtainable",
    "content.unlock-order",
    function()
        analyse()
        assert_only_known(research_problems, known_research_problems)
    end
)

Tirislib.Testing.add_test_case(
    "Every unlocked recipe can be crafted within its science tier",
    "content.unlock-order",
    function()
        analyse()
        assert_only_known(recipe_problems, known_recipe_problems)
    end
)

Tirislib.Testing.add_test_case(
    "Every unlocked recipe can be crafted as soon as its technology is researched",
    "content.unlock-order",
    function()
        analyse()
        assert_only_known(early_recipe_problems, known_early_recipe_problems)
    end
)
