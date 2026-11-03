local Assert = Tirislib.Testing.Assert

--- Sosciencity recipes that are meant to be available right at the start of a new game.
--- Everything else needs a technology, otherwise it clutters the recipe browser of a new player.
--- A misspelled `unlock` also lands here, because Tirislib silently keeps such a recipe enabled.
local intended_start_recipes = {
    ["lumber"] = true,
    ["sawdust"] = true,
    ["gathering-food"] = true,
    ["gathering-hemp"] = true,
    ["gathering-materials"] = true,
    ["medical-instruments"] = true,
    ["donate-blood"] = true,
    ["sosciencity-medical-kit"] = true,
    ["sosciencity-emergency-ration"] = true
}

Tirislib.Testing.add_test_case(
    "Only intended Sosciencity recipes are enabled at the start",
    "content.start-recipes",
    function()
        local unexpected = {}

        for _, recipe in Tirislib.Recipe.iterate() do
            if recipe.enabled ~= false
                and not recipe.hidden
                and Tirislib.Prototype.get_owner(recipe) == "sosciencity"
                and not intended_start_recipes[recipe.name]
                and recipe.name:sub(1, 5) ~= "test-"
            then
                unexpected[#unexpected + 1] = recipe.name
            end
        end

        table.sort(unexpected)
        Assert.is_table_empty(unexpected, "enabled at start: " .. table.concat(unexpected, ", "))
    end
)

Tirislib.Testing.add_test_case(
    "Iron sticks are unlocked together with the first Sosciencity buildings",
    "content.start-recipes",
    function()
        local technology, found = Tirislib.Technology.get_by_name("infrastructure-1")
        Assert.is_true(found, "infrastructure-1 exists")

        local unlocks_iron_stick = false
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == "iron-stick" then
                unlocks_iron_stick = true
            end
        end
        Assert.is_true(unlocks_iron_stick, "infrastructure-1 unlocks iron-stick")
    end
)
