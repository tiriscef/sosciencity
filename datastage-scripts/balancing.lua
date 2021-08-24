require("constants.food")

local function get_result_calories(recipe_data)
    local kcal = 0
    for _, result in pairs(recipe_data.results) do
        if Food.values[result.name] then
            kcal = kcal + Tirislib_RecipeEntry.get_average_yield(result) * Food.values[result.name].calories
        end
    end
    return kcal
end

local results = {}
for _, recipe in Tirislib_Recipe.iterate() do
    if recipe.owner == "sosciencity" then
        for difficulty, recipe_data in pairs(recipe:get_recipe_datas()) do
            local kcal = get_result_calories(recipe_data)

            if kcal > 0 then
                results[#results + 1] =
                    string.format(
                    "%s, difficulty %s, produces %d kcal per cycle, %d kcal per second",
                    recipe.name,
                    difficulty == Tirislib_RecipeDifficulty.expensive and "expensive" or "normal",
                    kcal,
                    kcal / recipe_data.energy_required
                )
            end
        end
    end
end

log(Tirislib_String.join("\n", "Food Producing Recipes:", results))

--[[
local function get_result_mass(recipe, difficulty)
    local ret = 0
    for _, result in pairs(recipe[difficulty].results) do
        ret = ret + (get_animal_size(result.name) or 0) * Tirislib_RecipeEntry.get_average_yield(result)
    end
    return ret
end

local results = {}
for _, recipe in pairs(fauna_producing_recipes) do
    local mass = get_result_mass(recipe, "normal")
    local mass_expensive = get_result_mass(recipe, "expensive")
    local time = recipe:get_field("energy_required", "normal")
    local time_expensive = recipe:get_field("energy_required", "expensive")
    table.insert(
        results,
        string.format(
            "%s produces %d or %d kg per cycle, %d or %d kg per second",
            recipe.name,
            mass,
            mass_expensive,
            mass / time,
            mass_expensive / time_expensive
        )
    )
end

log(Tirislib_String.join("\n", "Fauna Balancing Values:", results))
]]
