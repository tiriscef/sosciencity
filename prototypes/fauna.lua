local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << items >>

local animals = {
    {
        name = "primal-quackling",
        size = 20,
        bird = true,
        preform = "primal-egg",
        metabolism_coefficient = 1.7,
        unlock = Unlocks.get_tech_name("primal-quacker")
    },
    {
        name = "primal-quacker",
        size = 40,
        bird = true,
        preform = "primal-quackling",
        metabolism_coefficient = 1.5,
        unlock = Unlocks.get_tech_name("primal-quacker")
    },
    {
        name = "primal-quackpa",
        size = 50,
        bird = true,
        preform = "primal-quacker",
        metabolism_coefficient = 4,
        breeding_byproducts = {{name = "primal-egg", amount = 5}},
        unlock = Unlocks.get_tech_name("primal-quacker")
    },
    {
        name = "nan-swanling",
        size = 20,
        bird = true,
        preform = "nan-egg",
        metabolism_coefficient = 1.7,
        unlock = Unlocks.get_tech_name("nan-swan")
    },
    {
        name = "nan-swan",
        size = 60,
        bird = true,
        preform = "nan-swanling",
        metabolism_coefficient = 1.5,
        unlock = Unlocks.get_tech_name("nan-swan")
    },
    {
        name = "elder-nan",
        size = 70,
        bird = true,
        preform = "nan-swan",
        metabolism_coefficient = 3.5,
        breeding_byproducts = {{name = "nan-egg", amount = 3}},
        unlock = Unlocks.get_tech_name("nan-swan")
    },
    {
        name = "smol-bonesnake",
        size = 20,
        bird = true,
        unlock = Unlocks.get_tech_name("bonesnake")
    },
    {
        name = "bonesnake",
        -- TODO old form
        size = 160,
        bird = true,
        preform = "smol-bonesnake",
        unlock = Unlocks.get_tech_name("bonesnake")
    },
    {
        name = "young-petunial",
        size = 2000,
        water_animal = true,
        metabolism_coefficient = 1.2,
        unlock = Unlocks.get_tech_name("petunial")
    },
    {
        name = "petunial",
        size = 10000,
        water_animal = true,
        preform = "young-petunial",
        unlock = Unlocks.get_tech_name("petunial")
    },
    {
        name = "hellfin",
        size = 190,
        water_animal = true,
        group_size = 4,
        unlock = Unlocks.get_tech_name("hellfin")
    },
    {
        name = "warnal",
        size = 1000,
        water_animal = true,
        unlock = Unlocks.get_tech_name("warnal")
    },
    {
        name = "shellscript",
        size = 70,
        water_animal = true,
        group_size = 4,
        unlock = Unlocks.get_tech_name("shellscript")
    },
    {
        name = "boofish",
        size = 20,
        fish = true,
        group_size = 5,
        unlock = Unlocks.get_tech_name("boofish")
    },
    {
        name = "fupper",
        size = 40,
        fish = true,
        unlock = Unlocks.get_tech_name("fupper")
    },
    {
        name = "dodkopus",
        size = 80,
        water_animal = true,
        slaughter_byproducts = {{name = "ink", amount = 3}},
        unlock = Unlocks.get_tech_name("dodkopus")
    },
    {
        name = "ultra-squibbel",
        size = 100,
        water_animal = true,
        slaughter_byproducts = {{name = "ink", amount = 10}},
        not_breedable = true,
        unlock = Unlocks.get_tech_name("squibbel")
    },
    {
        name = "miniscule-squibbel",
        size = 250,
        water_animal = true,
        slaughter_byproducts = {{name = "ink", amount = 4}},
        breeding_byproducts = {{name = "ultra-squibbel", amount = 0.5}},
        unlock = Unlocks.get_tech_name("squibbel")
    },
    {
        name = "cabar",
        size = 40,
        min_group_size = 1,
        max_group_size = 7,
        unlock = Unlocks.get_tech_name("cabar")
    },
    {
        name = "caddle",
        size = 30,
        carnivore = true,
        min_group_size = 1,
        max_group_size = 4,
        unlock = Unlocks.get_tech_name("caddle")
    },
    {
        name = "river-horse",
        size = 750,
        min_group_size = 3,
        max_group_size = 6,
        sprite_variations = {name = "river-horse-on-belt", count = 1},
        unlock = Unlocks.get_tech_name("river-horse")
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

local function is_water_animal(animal)
    return animal.water_animal or animal.fish
end

local function get_meat_type(animal)
    -- option to specify it
    if animal.meat then
        return animal.meat
    end

    return (animal.bird and "bird-meat") or (animal.fish and "fish-meat") or (animal.insect and "insect-meat") or
        "mammal-meat"
end

local function get_preform(animal)
    local preform_name = animal.preform
    if preform_name then
        for _, current_animal in pairs(animals) do
            if current_animal.name == preform_name then
                return current_animal
            end
        end
    end
end


---------------------------------------------------------------------------------------------------
-- << slaughter recipes >>

local function get_required_energy_slaughter(animal)
    return math.ceil(animal.size ^ 0.5)
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

local function get_feather_amount(animal)
    return animal.size ^ 0.7
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

    --[[if animal.bird then
        recipe:add_new_result("feathers", get_feather_amount(animal))
    end]]

    if animal.slaughter_byproducts then
        recipe:add_result_range(animal.slaughter_byproducts)
    end

    if animal.unlock then
        recipe:add_unlock(animal.unlock)
    end
end

for index, animal in pairs(animals) do
    create_slaughter_recipe(animal, index)
end

---------------------------------------------------------------------------------------------------
-- << breeding recipes >>

local farm_size = 2000

local function get_weight_gain(animal)
    local weight = animal.size
    local preform = get_preform(animal)
    if preform then
        weight = weight - preform.size
    end

    return weight
end

local function get_food_amount(animal, count)
    return math.ceil(count * get_weight_gain(animal) / (animal.metabolism_coefficient or 1))
end

local function get_cycle_animal_amount(animal)
    return math.ceil(farm_size / (10 * animal.size ^ (2 / 3)))
end

local function get_required_energy_breeding(animal)
    return 30 * math.max(1, math.ceil(math.log(animal.size)))
end

local function get_food_theme(animal, count)
    local theme
    if animal.carnivore then
        theme = "breed_carnivores"
    elseif animal.omnivore then
        theme = "breed_omnivores"
    elseif animal.bird then
        theme = "breed_birds"
    elseif animal.fish then
        theme = "breed_fish"
    else
        theme = "breed_herbivores"
    end

    return {theme, get_food_amount(animal, count), nil, animal.level or 0}
end

local function create_breeding_recipe(animal)
    local item = Tirislib.Item.get_by_name(animal.name)

    local cycle_amount = get_cycle_animal_amount(animal)
    local energy = get_required_energy_breeding(animal)

    local recipe =
        Tirislib.RecipeGenerator.create {
        product = animal.name,
        product_amount = cycle_amount,
        category = is_water_animal(animal) and "sosciencity-water-animal-farming" or "sosciencity-animal-farming",
        byproducts = animal.breeding_byproducts or nil,
        themes = {get_food_theme(animal, cycle_amount)},
        energy_required = energy,
        unlock = animal.unlock,
        icons = {
            {icon = item.icon},
            {
                icon = "__sosciencity-graphics__/graphics/icon/farming.png",
                scale = 0.3,
                shift = {-8, -8}
            }
        },
    }

    if animal.preform then
        recipe:add_new_ingredient(animal.preform, cycle_amount)
    end

    if animal.breeding_byproducts then
        for _, byproduct in pairs(animal.breeding_byproducts) do
            byproduct.amount = math.ceil((byproduct.amount or 1) * cycle_amount)
        end
        recipe:add_result_range(animal.breeding_byproducts)
    end
end

for _, animal in pairs(animals) do
    if not animal.not_breedable then
        create_breeding_recipe(animal)
    end
end

---------------------------------------------------------------------------------------------------
-- << entities >>

if settings.startup["sosciencity-modify-environment"].value then
    -- 'fish' entity to have ducks swimming on water bodies
    -- it seems like the factorio engine treats the order-string of the autoplace definition as some kind of ID, so I'm giving them a distinct one to be sure
    Tirislib.Entity.create {
        type = "fish",
        name = "primal-quacker",
        icon = "__sosciencity-graphics__/graphics/icon/primal-quacker.png",
        icon_size = 64,
        flags = {"placeable-neutral", "not-on-map"},
        minable = {
            mining_time = 0.4,
            results = {
                {name = "primal-quacker", amount = 1},
                {name = "primal-quackling", amount_min = 0, amount_max = 10}
            }
        },
        max_health = 20,
        subgroup = "creatures",
        order = "a",
        collision_box = {{-0.75, -0.75}, {0.75, 0.75}},
        selection_box = {{-0.5, -0.3}, {0.5, 0.3}},
        pictures = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/primal-quacker/primal-quacker.png",
                width = 64,
                height = 128,
                scale = 1. / 4.
            }
        },
        autoplace = {
            order = "sosciencity-a",
            influence = 0.001
        },
        localised_name = {"item-name.primal-quacker"}
    }

    Tirislib.Entity.create {
        type = "fish",
        name = "nan-swan",
        icon = "__sosciencity-graphics__/graphics/icon/nan-swan.png",
        icon_size = 64,
        flags = {"placeable-neutral", "not-on-map"},
        minable = {
            mining_time = 0.4,
            results = {
                {name = "nan-swan", amount = 1},
                {name = "nan-swanling", amount_min = 0, amount_max = 7}
            }
        },
        max_health = 40,
        subgroup = "creatures",
        order = "b",
        collision_box = {{-1, -1}, {1, 1}},
        selection_box = {{-0.666, -0.4}, {0.666, 0.4}},
        pictures = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/nan-swan/nan-swan.png",
                width = 64,
                height = 128,
                scale = 1. / 3.
            }
        },
        autoplace = {
            order = "sosciencity-b",
            influence = 0.001
        },
        localised_name = {"item-name.nan-swan"}
    }

    Tirislib.Entity.create {
        type = "fish",
        name = "fishwhirl",
        icon = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl.png",
        icon_size = 64,
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
        selection_box = {{-0.666, -0.4}, {0.666, 0.4}},
        pictures = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl.png",
                width = 128,
                height = 128,
                scale = 1. / 3.
            }
        },
        autoplace = {
            order = "sosciencity-c",
            influence = 0.007
        }
    }
end
