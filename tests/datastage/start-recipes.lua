local Assert = Tirislib.Testing.Assert

--- Sosciencity recipes that are meant to be available right at the start of a new game.
--- Everything else needs a technology, otherwise it clutters the recipe browser of a new player.
--- A misspelled `unlock` also lands here, because Tirislib silently keeps such a recipe enabled.
local intended_start_recipes = {
    ["lumber"] = true,
    ["sawdust"] = true,
    ["lumber-from-tiriscefing-willow-wood"] = true, -- willow wood comes from gathering materials
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

--- Whether some technology unlocks the given recipe.
local function is_unlocked_by_technology(recipe_name)
    for _, technology in Tirislib.Technology.iterate() do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                return true
            end
        end
    end
    return false
end

Tirislib.Testing.add_test_case(
    "Every Sosciencity wood can be turned into lumber once it is obtainable",
    "content.start-recipes",
    function()
        local missing = {}

        for _, item in Tirislib.Item.iterate() do
            if Tirislib.Prototype.get_owner(item) == "sosciencity" and item.name:sub(-5) == "-wood" then
                local recipe, found = Tirislib.Recipe.get_by_name("lumber-from-" .. item.name)
                if not found then
                    missing[#missing + 1] = item.name .. " (no recipe)"
                elseif recipe.enabled == false and not is_unlocked_by_technology(recipe.name) then
                    missing[#missing + 1] = item.name .. " (never unlocked)"
                end
            end
        end

        table.sort(missing)
        Assert.is_table_empty(missing, "no lumber for: " .. table.concat(missing, ", "))
    end
)
