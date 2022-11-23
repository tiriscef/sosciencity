local EK = require("enums.entry-key")
local Food = require("constants.food")
local Housing = require("constants.housing")
local Castes = require("constants.castes")

local animal_calorie_values = {}

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

    local animal_foods =
        Tirislib.Tables.array_to_lookup {
        "bird-food",
        "fish-food",
        "carnivore-food",
        "herbivore-food"
    }

    local animal_food_recipes =
        Tirislib.Luaq.from(game.recipe_prototypes):where(
        function(_, recipe)
            return animal_foods[recipe.products[1] and recipe.products[1].name or ""] ~= nil
        end
    ):select(
        function(_, recipe)
            local animal_food = recipe.products[1].name
            local calories = get_calories(recipe, "ingredients")

            return {food = animal_food, calories = calories, recipe = recipe.name}
        end
    ):to_array()

    game.write_file(
        "animal-foods.csv",
        Tirislib.String.join(
            "\n",
            "recipe;animal-food;kcal",
            Tirislib.Luaq.from(animal_food_recipes):select(
                function(_, tbl)
                    return string.format("%s;%s;%d", tbl.recipe, tbl.food, tbl.calories)
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

    -- housing
    local housing_data = {}
    for name, housing in pairs(Housing.values) do
        local prototype = game.entity_prototypes[name]
        if prototype ~= nil then
            local size = prototype.tile_height * prototype.tile_width

            local res = name .. ";" .. size .. ";" .. housing.room_count .. ";" .. housing.room_count / size .. ";"

            for caste_id, caste in pairs(Castes.values) do
                if housing.is_improvised or Housing.allowes_caste(housing, caste_id) then
                    local quality_assessment = 0
                    local preferences = caste.housing_preferences
                    for _, quality in pairs(housing.qualities) do
                        quality_assessment = quality_assessment + (preferences[quality] or 0)
                    end

                    local capacity = Housing.get_capacity {[EK.type] = caste_id, [EK.name] = name}

                    res = res .. quality_assessment .. ";" .. capacity .. ";"
                else
                    res = res .. "n/a;n/a;"
                end
            end

            housing_data[#housing_data + 1] = res
        end
    end

    local header = "name;size;rooms;rooms per tile;"
    for _, caste in pairs(Castes.values) do
        header = header .. caste.name .. " happiness;" .. caste.name .. "s/house;"
    end

    game.write_file("housing.csv", Tirislib.String.join("\n", header, housing_data))

    game.print("Wrote balancing data")
end

commands.add_command("sosciencity-balancing", "", write_files)
