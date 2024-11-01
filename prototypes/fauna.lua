local Unlocks = require("constants.unlocks")
local Food = require("constants.food")

---------------------------------------------------------------------------------------------------
-- << items >>

local animals = {
    {
        name = "primal-quackling",
        size = 20,
        bird = true,
        metabolism_coefficient = 1.7,
        unlock = Unlocks.get_tech_name("primal-quacker"),
        food_theme = "breed_birds"
    },
    {
        name = "primal-quacker",
        size = 40,
        bird = true,
        metabolism_coefficient = 1.5,
        unlock = Unlocks.get_tech_name("primal-quacker"),
        food_theme = "breed_birds"
    },
    {
        name = "primal-quackpa",
        size = 50,
        bird = true,
        metabolism_coefficient = 4,
        unlock = Unlocks.get_tech_name("primal-quacker"),
        food_theme = "breed_birds"
    },
    {
        name = "nan-swanling",
        size = 20,
        bird = true,
        metabolism_coefficient = 1.7,
        unlock = Unlocks.get_tech_name("nan-swan"),
        food_theme = "breed_birds"
    },
    {
        name = "nan-swan",
        size = 60,
        bird = true,
        metabolism_coefficient = 1.5,
        unlock = Unlocks.get_tech_name("nan-swan"),
        food_theme = "breed_birds"
    },
    {
        name = "elder-nan",
        size = 70,
        bird = true,
        metabolism_coefficient = 3.5,
        unlock = Unlocks.get_tech_name("nan-swan"),
        food_theme = "breed_birds"
    },
    {
        name = "smol-bonesnake",
        size = 20,
        bird = true,
        unlock = Unlocks.get_tech_name("bonesnake"),
        food_theme = "breed_birds"
    },
    {
        name = "bonesnake",
        size = 160,
        bird = true,
        unlock = Unlocks.get_tech_name("bonesnake"),
        food_theme = "breed_birds"
    },
    {
        name = "elder-bonesnake",
        size = 170,
        bird = true,
        unlock = Unlocks.get_tech_name("bonesnake"),
        food_theme = "breed_birds"
    },
    {
        name = "young-petunial",
        size = 2000,
        water_animal = true,
        metabolism_coefficient = 1.2,
        unlock = Unlocks.get_tech_name("petunial"),
        food_theme = "breed_water_herbivores"
    },
    {
        name = "petunial",
        size = 10000,
        water_animal = true,
        unlock = Unlocks.get_tech_name("petunial"),
        food_theme = "breed_water_herbivores"
    },
    {
        name = "hellfin",
        size = 190,
        water_animal = true,
        group_size = 4,
        unlock = Unlocks.get_tech_name("hellfin"),
        food_theme = "breed_water_carnivores"
    },
    {
        name = "warnal",
        size = 1000,
        water_animal = true,
        unlock = Unlocks.get_tech_name("warnal"),
        food_theme = "breed_water_carnivores"
    },
    {
        name = "shellscript",
        size = 70,
        water_animal = true,
        group_size = 4,
        unlock = Unlocks.get_tech_name("shellscript"),
        food_theme = "breed_water_herbivores"
    },
    {
        name = "boofish",
        size = 20,
        fish = true,
        group_size = 5,
        unlock = Unlocks.get_tech_name("boofish"),
        food_theme = "breed_fish"
    },
    {
        name = "fupper",
        size = 40,
        fish = true,
        unlock = Unlocks.get_tech_name("fupper"),
        food_theme = "breed_fish"
    },
    {
        name = "dodkopus",
        size = 80,
        water_animal = true,
        slaughter_byproducts = {{name = "ink", amount = 3}},
        unlock = Unlocks.get_tech_name("dodkopus"),
        food_theme = "breed_water_carnivores"
    },
    {
        name = "ultra-squibbel",
        size = 100,
        water_animal = true,
        slaughter_byproducts = {{name = "ink", amount = 10}},
        not_breedable = true,
        unlock = Unlocks.get_tech_name("squibbel"),
        food_theme = "breed_water_omnivores"
    },
    {
        name = "miniscule-squibbel",
        size = 250,
        water_animal = true,
        slaughter_byproducts = {{name = "ink", amount = 4}},
        unlock = Unlocks.get_tech_name("squibbel"),
        food_theme = "breed_water_omnivores"
    },
    {
        name = "cabar",
        size = 40,
        unlock = Unlocks.get_tech_name("cabar"),
        food_theme = "breed_herbivores"
    },
    {
        name = "caddle",
        size = 30,
        carnivore = true,
        unlock = Unlocks.get_tech_name("caddle"),
        food_theme = "breed_carnivores"
    },
    {
        name = "river-horse",
        size = 750,
        sprite_variations = {name = "river-horse-on-belt", count = 1},
        unlock = Unlocks.get_tech_name("river-horse"),
        food_theme = "breed_herbivores"
    }
    --[[    {
        name = "vels-ant",
        size = 10,
        insect = true,
        probability = 0.5
    }]]
}

local function get_stack_size(animal)
    local size = animal.size

    if size <= 20 then
        return 200
    elseif size <= 100 then
        return 50
    elseif size <= 500 then
        return 20
    else
        return 10
    end
end

for _, animal in pairs(animals) do
    animal.distinctions = animal.distinctions or {}
    local distinctions = animal.distinctions

    distinctions.stack_size = get_stack_size(animal)
end

Tirislib.Item.batch_create(animals, {subgroup = "sosciencity-fauna", stack_size = 20})

local function get_animal_definition(name)
    for _, current_animal in pairs(animals) do
        if current_animal.name == name then
            return current_animal
        end
    end
end

local animal_calorie_values = {}

---------------------------------------------------------------------------------------------------
-- << slaughter recipes >>

local function get_required_energy_slaughter(animal)
    return math.ceil(animal.size ^ 0.5)
end

local function get_meat_type(animal)
    -- option to specify it
    if animal.meat then
        return animal.meat
    end

    return (animal.bird and "bird-meat") or (animal.fish and "fish-meat") or (animal.insect and "insect-meat") or
        "mammal-meat"
end

-- the meat, offal and waste products are about 10kg each
-- the size of the animals is in kg
local function get_meat_amount(animal)
    return animal.size * 0.05
end

local function get_offal_amount(animal)
    return animal.size * 0.03
end

local function get_slaughter_waste_amount(animal)
    return animal.size * 0.02
end

local function create_slaughter_recipe(animal, index)
    local item = Tirislib.Item.get_by_name(animal.name)

    local recipe =
        Tirislib.Recipe.create {
        name = "slaughter-" .. animal.name,
        category = "sosciencity-slaughter",
        energy_required = get_required_energy_slaughter(animal),
        ingredients = {
            {type = "item", name = animal.name, amount = 1}
        },
        icons = {
            {icon = item.icon},
            {
                icon = "__sosciencity-graphics__/graphics/icon/slaughter.png",
                scale = 0.3,
                shift = {-8, -8},
                tint = {r = 1, g = 0.2, b = 0.2}
            }
        },
        icon_size = 64,
        subgroup = "sosciencity-slaughter",
        main_product = "",
        order = string.format("%03d", index),
        localised_name = {"recipe-name.slaughter", item:get_localised_name()},
        localised_description = {"recipe-description.slaughter"}
    }

    local meat = get_meat_type(animal)
    recipe:add_new_result(meat, get_meat_amount(animal))
    recipe:add_new_result("offal", get_offal_amount(animal))
    recipe:add_new_result("slaughter-waste", get_slaughter_waste_amount(animal))

    if animal.slaughter_byproducts then
        recipe:add_result_range(animal.slaughter_byproducts)
    end

    if animal.unlock then
        recipe:add_unlock(animal.unlock)
    end

    animal_calorie_values[animal.name] =
        Tirislib.Luaq.from(recipe.results):select(
        function(_, result)
            return Tirislib.RecipeEntry.get_average_yield(result) *
                (Food.values[result.name] and Food.values[result.name].calories or 0)
        end
    ):call(Tirislib.Tables.sum)
end

for index, animal in pairs(animals) do
    create_slaughter_recipe(animal, index)
end

---------------------------------------------------------------------------------------------------
-- << breeding recipes >>

local function is_water_animal(animal)
    return animal.water_animal or animal.fish
end

local function get_calories_needed(recipe_data)
    local ret = 0

    for _, result in pairs(recipe_data.results) do
        local name = result.name
        local amount = Tirislib.RecipeEntry.get_max_yield(result)
        if Food.values[name] then
            ret = ret + Food.values[name].calories * amount
        end
        if animal_calorie_values[name] then
            ret = ret + animal_calorie_values[name] * amount
        end
    end

    for _, ingredient in pairs(recipe_data.ingredients) do
        local name = ingredient.name
        local amount = Tirislib.RecipeEntry.get_max_yield(ingredient)
        if Food.values[name] then
            ret = ret - Food.values[name].calories * amount
        end
        if animal_calorie_values[name] then
            ret = ret - animal_calorie_values[name] * amount * 0.9
        end
    end

    return ret
end

local CALORIES_PER_FOOD_ITEM = 3000

local function add_food(recipe, animal)
    local calories = {}
    for difficulty, recipe_data in pairs(recipe:get_recipe_datas()) do
        calories[difficulty] = get_calories_needed(recipe_data)
    end

    Tirislib.RecipeGenerator.add_ingredient_theme(
        recipe,
        {
            animal.food_theme,
            calories[Tirislib.RecipeDifficulty.normal] / CALORIES_PER_FOOD_ITEM,
            calories[Tirislib.RecipeDifficulty.expensive] / CALORIES_PER_FOOD_ITEM
        }
    )
end

local function create_husbandry_recipe(details)
    local animal = get_animal_definition(details.product)
    local animal_item = Tirislib.Item.get_by_name(details.product)
    local item = Tirislib.Item.get_by_name(animal_item.name)

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            name = Tirislib.Prototype.get_unique_name("sos-husbandry-" .. animal_item.name, "recipe"),
            product = details.old_animal or details.keeping_animal,
            category = is_water_animal(animal) and "sosciencity-water-animal-farming" or "sosciencity-animal-farming",
            energy_required = 30,
            localised_name = {
                details.style == "breeding" and "recipe-name.animal-breeding" or "recipe-name.animal-keeping",
                animal_item:get_localised_name()
            },
            localised_description = "",
            icons = {
                {icon = item.icon},
                {
                    icon = details.style == "breeding" and "__sosciencity-graphics__/graphics/icon/breeding.png" or
                        "__sosciencity-graphics__/graphics/icon/keeping.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            unlock = animal.unlock
        }
    )

    local recipe = Tirislib.RecipeGenerator.create(details)
    add_food(recipe, animal)
    return recipe
end

create_husbandry_recipe {
    product = "primal-quackling",
    product_min = 80,
    product_max = 100,
    ingredients = {
        {name = "primal-egg", amount = 20}
    },
    style = "breeding"
}

create_husbandry_recipe {
    product = "primal-quacker",
    product_min = 90,
    product_max = 100,
    ingredients = {
        {type = "item", name = "primal-quackling", amount = 100}
    },
    style = "breeding"
}

create_husbandry_recipe {
    product = "primal-quacker",
    product_amount = 90,
    ingredients = {
        {type = "item", name = "primal-quacker", amount = 100}
    },
    byproducts = {
        {name = "primal-quackpa", amount_min = 8, amount_max = 10},
        {name = "primal-egg", amount_min = 80, amount_max = 120}
    }
}

create_husbandry_recipe {
    product = "nan-swanling",
    product_min = 80,
    product_max = 100,
    ingredients = {
        {name = "nan-egg", amount = 20}
    },
    style = "breeding"
}

create_husbandry_recipe {
    product = "nan-swan",
    product_min = 60,
    product_max = 75,
    ingredients = {
        {type = "item", name = "nan-swanling", amount = 75}
    },
    style = "breeding"
}

create_husbandry_recipe {
    product = "nan-swan",
    product_amount = 70,
    ingredients = {
        {type = "item", name = "nan-swan", amount = 75}
    },
    byproducts = {
        {name = "elder-nan", amount_min = 4, amount_max = 5},
        {name = "nan-egg", amount_min = 30, amount_max = 60}
    }
}

create_husbandry_recipe {
    product = "smol-bonesnake",
    product_min = 80,
    product_max = 100,
    ingredients = {
        {name = "bone-egg", amount = 20}
    },
    style = "breeding"
}

create_husbandry_recipe {
    product = "bonesnake",
    product_min = 23,
    product_max = 25,
    ingredients = {
        {type = "item", name = "smol-bonesnake", amount = 25}
    },
    style = "breeding"
}

create_husbandry_recipe {
    product = "bonesnake",
    product_amount = 20,
    ingredients = {
        {type = "item", name = "bonesnake", amount = 25}
    },
    byproducts = {
        {name = "elder-bonesnake", amount_min = 4, amount_max = 5},
        {name = "bone-egg", amount_min = 10, amount_max = 15}
    }
}

create_husbandry_recipe {
    product = "cabar",
    product_min = 20,
    product_max = 40,
    ingredients = {
        {type = "item", name = "cabar", amount = 4}
    }
}

create_husbandry_recipe {
    product = "caddle",
    product_min = 20,
    product_max = 34,
    ingredients = {
        {type = "item", name = "caddle", amount = 16}
    }
}

create_husbandry_recipe {
    product = "river-horse",
    product_min = 8,
    product_max = 12,
    ingredients = {
        {type = "item", name = "river-horse", amount = 6}
    }
}

create_husbandry_recipe {
    product = "young-petunial",
    product_min = 0,
    product_max = 2,
    ingredients = {
        {name = "petunial", amount = 2}
    },
    byproducts = {
        {name = "petunial", amount = 2, probability = 0.95}
    },
    energy_required = 60,
    style = "breeding"
}

create_husbandry_recipe {
    product = "petunial",
    product_amount = 1,
    ingredients = {
        {type = "item", name = "young-petunial", amount = 8}
    },
    byproducts = {
        {type = "item", name = "young-petunial", amount = 7}
    },
    energy_required = 60
}

create_husbandry_recipe {
    product = "hellfin",
    product_min = 14,
    product_max = 34,
    ingredients = {
        {type = "item", name = "hellfin", amount = 18}
    }
}

create_husbandry_recipe {
    product = "warnal",
    product_min = 5,
    product_max = 7,
    ingredients = {
        {type = "item", name = "warnal", amount = 5}
    }
}

create_husbandry_recipe {
    product = "shellscript",
    product_min = 30,
    product_max = 60,
    ingredients = {
        {type = "item", name = "shellscript", amount = 20}
    },
    energy_required = 60
}

create_husbandry_recipe {
    product = "boofish",
    product_min = 150,
    product_max = 200,
    ingredients = {
        {type = "item", name = "boofish", amount = 100}
    }
}

create_husbandry_recipe {
    product = "fupper",
    product_min = 60,
    product_max = 90,
    ingredients = {
        {type = "item", name = "fupper", amount = 50}
    }
}

create_husbandry_recipe {
    product = "dodkopus",
    product_min = 18,
    product_max = 22,
    ingredients = {
        {type = "item", name = "dodkopus", amount = 18}
    }
}

create_husbandry_recipe {
    product = "ultra-squibbel",
    product_min = 12,
    product_max = 16,
    ingredients = {
        {type = "item", name = "ultra-squibbel", amount = 10},
        {type = "item", name = "miniscule-squibbel", amount = 2}
    },
    byproducts = {
        {type = "item", name = "miniscule-squibbel", amount = 2},
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.2}
    }
}

---------------------------------------------------------------------------------------------------
-- << entities >>

if settings.startup["sosciencity-modify-environment"].value then
    -- 'fish' entity to have ducks swimming on water bodies
    -- it seems like the factorio engine treats the order-string of the autoplace definition as some kind of ID, so I'm giving them a distinct one to be sure
    Tirislib.Entity.create {
        type = "fish",
        name = "fishwhirl",
        icon = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl-1.png",
        icon_size = 128,
        flags = {"placeable-neutral", "not-on-map"},
        minable = {
            mining_time = 0.4,
            results = {
                {type = "item", name = "boofish", amount_min = 5, amount_max = 15},
                {type = "item", name = "fupper", amount = 4, amount_max = 10},
                {type = "item", name = "dodkopus", amount = 1, probability = 0.2},
                {type = "item", name = "shellscript", amount = 3, probability = 0.5},
                {type = "item", name = "ultra-squibbel", amount = 1, probability = 0.2},
                {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.2}
            }
        },
        max_health = 40,
        subgroup = "creatures",
        order = "b",
        collision_box = {{-1, -1}, {1, 1}},
        selection_box = {{-0.666, -0.666}, {0.666, 0.666}},
        pictures = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl-1.png",
                width = 128,
                height = 128,
                scale = 1. / 3.,
                tint = {r = 1, g = 1, b = 1, a = 0.25}
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl-2.png",
                width = 128,
                height = 128,
                scale = 1. / 3.,
                tint = {r = 1, g = 1, b = 1, a = 0.25}
            }
        },
        autoplace = {
            order = "sosciencity-c",
            influence = 0.003
        },
        created_effect = {
            type = "direct",
            action_delivery = {
                type = "instant",
                source_effects = {
                    type = "script",
                    effect_id = "sosciencity-fishwhirl-creation"
                }
            }
        }
    }
end
