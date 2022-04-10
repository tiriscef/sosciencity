local Food = require("constants.food")

local animal_calorie_values

local function get_amount(entry)
    local probability = (entry.probability or 1)
    if entry.amount then
        return probability * entry.amount
    end
    if entry.amount_min then
        return (entry.amount_min + entry.amount_max) * 0.5 * probability
    end

    error("something seems off, a recipe didn't have a readable ingredient/result entry")
end

local function get_calories(recipe, key)
    local calories = 0
    for _, entry in pairs(recipe[key]) do
        if Food.values[entry.name] then
            calories = calories + get_amount(entry) * Food.values[entry.name].calories
        end
        if animal_calorie_values[entry.name] then
            calories = calories + get_amount(entry) * animal_calorie_values[entry.name]
        end
    end
    return calories
end

local function write_files()
    animal_calorie_values = {}

    -- find and write the animal-calorific-equivalents
    animal_calorie_values =
        Tirislib.Luaq.from(game.recipe_prototypes):where(
        function(_, recipe)
            return recipe.category == "sosciencity-slaughter"
        end
    ):select(
        function(_, recipe)
            local animal = recipe.ingredients[1].name
            local calories = get_calories(recipe, "products")

            return calories, animal
        end
    ):to_table()

    game.write_file(
        "animal-values.csv",
        Tirislib.String.join(
            "\n",
            "animal;kcal",
            Tirislib.Luaq.from(animal_calorie_values):select(
                function(animal, calories)
                    return string.format("%s;%d", animal, calories)
                end
            )
        )
    )

    -- find and write the calorie-changing-recipes
    local results = {}
    for _, recipe in pairs(game.recipe_prototypes) do
        local calories_in = get_calories(recipe, "ingredients")
        local calories_out = get_calories(recipe, "products")

        if calories_in ~= 0 or calories_out ~= 0 then
            local diff = calories_out - calories_in
            local diff_per_sec = diff / recipe.energy
            results[#results + 1] =
                string.format(
                "%s;%s;%d;%d;%d;%d;%d",
                recipe.name,
                recipe.category,
                diff,
                diff / recipe.energy,
                calories_in,
                calories_out,
                diff_per_sec / (8 * 9.6)
            )
        end
    end

    game.write_file(
        "food-recipes.csv",
        Tirislib.String.join(
            "\n",
            "name;category;calorific difference;per second;calories in;calories out;clockworkers feeded",
            results
        )
    )

    game.write_file(
        "food-items.csv",
        Tirislib.String.join(
            "\n",
            "name;calories per item",
            Tirislib.Luaq.from(Food.values):select(
                function(name, food)
                    return name .. ";" .. food.calories
                end
            ):to_array()
        )
    )
end

commands.add_command("sosciencity-balancing", "", write_files)
