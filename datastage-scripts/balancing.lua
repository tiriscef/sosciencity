local Food = require("constants.food")

local all_recipes =
    Tirislib.Luaq.from(Tirislib.Recipe.all()):where(
    function(_, recipe)
        return recipe.owner == "sosciencity"
    end
)

local function get_result_calories(recipe_data)
    local kcal = 0
    for _, result in pairs(recipe_data.results) do
        if Food.values[result.name] then
            kcal = kcal + Tirislib.RecipeEntry.get_average_yield(result) * Food.values[result.name].calories
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
                "%s;%s;%d;%d",
                recipe.name,
                difficulty == Tirislib.RecipeDifficulty.expensive and "expensive" or "normal",
                kcal,
                kcal / recipe_data.energy_required
            )
        end
    end
end

log(Tirislib.String.join("\n", "Food Producing Recipes:", "name;difficulty;kcal per cycle;kcal per second", results))

local animal_calorie_values =
    Tirislib.Luaq.from(all_recipes.content):where(
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
    Tirislib.String.join(
        "\n",
        "Animal-Calorie-equivalents:",
        Tirislib.Luaq.from(animal_calorie_values):select(
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
                difficulty == Tirislib.RecipeDifficulty.expensive and "expensive" or "normal",
                kcal,
                kcal / recipe_data.energy_required
            )
        end
    end
end

log(Tirislib.String.join("\n", "Fauna Producing Recipes:", results))
