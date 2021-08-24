require("constants.food")

local all_recipes =
    Tirislib_Luaq.from(Tirislib_Recipe.all()):where(
    function(_, recipe)
        return recipe.owner == "sosciencity"
    end
)

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
for _, recipe in all_recipes:pairs() do
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

log(Tirislib_String.join("\n", "Food Producing Recipes:", results))

local animal_calorie_values =
    Tirislib_Luaq.from(all_recipes.content):where(
    function(_, recipe)
        return recipe.category == "sosciencity-slaughter"
    end
):select(
    function(_, recipe)
        local animal = recipe:get_first_ingredient()
        local calories = get_result_calories(recipe)

        return calories, animal
    end
):to_table()

log(
    Tirislib_String.join(
        "\n",
        "Animal-Calorie-equivalents:",
        Tirislib_Luaq.from(animal_calorie_values):select(
            function(animal, calories)
                return string.format("%s: %d kcal", animal, calories)
            end
        )
    )
)

local function get_result_calories_in_form_of_animals(recipe_data)
    local kcal = 0
    for _, result in pairs(recipe_data.results) do
        kcal = kcal + (animal_calorie_values[result.name] or 0)
    end
    return kcal
end

results = {}
for _, recipe in all_recipes:pairs() do
    for difficulty, recipe_data in pairs(recipe:get_recipe_datas()) do
        local kcal = get_result_calories_in_form_of_animals(recipe_data)

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

log(Tirislib_String.join("\n", "Fauna Producing Recipes:", results))

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
