---------------------------------------------------------------------------------------------------
-- << items >>
local animals = {
    {
        name = "primal-quackling",
        size = 5,
        bird = true,
        probability = 0.15,
        group_size = 7,
        preform = "primal-egg",
        metabolism_coefficient = 1.7
    },
    {
        name = "primal-quacker",
        size = 24,
        bird = true,
        probability = 0.12,
        preform = "primal-quackling",
        metabolism_coefficient = 1.5
    },
    {
        name = "primal-quackpa",
        size = 28,
        bird = true,
        preform = "primal-quacker",
        metabolism_coefficient = 4,
        breeding_byproducts = {{name = "primal-egg", amount = 5}}
    },
    {
        name = "nan-swanling",
        size = 10,
        bird = true,
        probability = 0.1,
        group_size = 3,
        preform = "nan-egg",
        metabolism_coefficient = 1.7
    },
    {
        name = "nan-swan",
        size = 40,
        bird = true,
        probability = 0.2,
        preform = "nan-swanling",
        metabolism_coefficient = 1.5
    },
    {
        name = "elder-nan",
        size = 45,
        bird = true,
        preform = "nan-swan",
        metabolism_coefficient = 3.5,
        breeding_byproducts = {{name = "nan-egg", amount = 3}}
    },
    {
        name = "smol-bonesnake",
        size = 15,
        bird = true,
        probability = 0.1,
        group_size = 5
    },
    {
        name = "bonesnake",
        -- TODO old form
        size = 100,
        bird = true,
        preform = "smol-bonesnake",
        probability = 0.15
    },
    {
        name = "young-petunial",
        size = 2500,
        water_animal = true,
        probability = 0.05,
        metabolism_coefficient = 1.2
    },
    {
        name = "petunial",
        size = 15000,
        water_animal = true,
        probability = 0.05,
        preform = "young-petunial"
    },
    {
        name = "hellfin",
        size = 190,
        water_animal = true,
        probability = 0.09,
        group_size = 4
    },
    {
        name = "warnal",
        size = 1000,
        water_animal = true,
        probability = 0.09
    },
    {
        name = "shellscript",
        size = 50,
        water_animal = true,
        probability = 0.15,
        group_size = 4
    },
    {
        name = "boofish",
        size = 3,
        fish = true,
        probability = 0.3,
        group_size = 5
    },
    {
        name = "fupper",
        size = 5,
        fish = true,
        probability = 0.5
    },
    {
        name = "dodkopus",
        size = 40,
        water_animal = true,
        probability = 0.15,
        slaughter_byproducts = {{name = "ink", amount = 3}}
    },
    {
        name = "ultra-squibbel",
        size = 50,
        water_animal = true,
        probability = 0.20,
        slaughter_byproducts = {{name = "ink", amount = 10}},
        not_breedable = true
    },
    {
        name = "miniscule-squibbel",
        size = 150,
        water_animal = true,
        probability = 0.15,
        slaughter_byproducts = {{name = "ink", amount = 4}},
        breeding_byproducts = {{name = "ultra-squibbel", amount = 0.5}}
    },
    {
        name = "cabar",
        size = 20,
        probability = 0.2,
        min_group_size = 1,
        max_group_size = 7
    },
    {
        name = "caddle",
        size = 20,
        probability = 0.15,
        group_size = 2
    }
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

Tirislib_Item.batch_create(animals, {subgroup = "sosciencity-fauna", stack_size = 20})

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

local fauna_producing_recipes = {}

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>
local megafauna_hunting =
    Tirislib_Recipe.create {
    name = "hunting-for-megafauna",
    category = "sosciencity-hunting",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/hunting.png",
    icon_size = 64,
    subgroup = "sosciencity-gathering",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:create_difficulties()
megafauna_hunting:multiply_expensive_field("energy_required", 2)
megafauna_hunting:add_catalyst("trap", "item", 5, 0.8, 6, 0.7)
table.insert(fauna_producing_recipes, megafauna_hunting)

local makrofauna_hunting =
    Tirislib_Recipe.create {
    name = "hunting-for-makrofauna",
    category = "sosciencity-hunting",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/hunting.png",
    icon_size = 64,
    subgroup = "sosciencity-gathering",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:create_difficulties()
makrofauna_hunting:multiply_expensive_field("energy_required", 2)
makrofauna_hunting:add_catalyst("trap-cage", "item", 2, 0.9, 3, 0.8)
table.insert(fauna_producing_recipes, makrofauna_hunting)

local mikrofauna_hunting =
    Tirislib_Recipe.create {
    name = "hunting-for-mikrofauna",
    category = "sosciencity-hunting",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/hunting.png",
    icon_size = 64,
    subgroup = "sosciencity-gathering",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:create_difficulties()
makrofauna_hunting:multiply_expensive_field("energy_required", 2)
makrofauna_hunting:add_catalyst("trap-bucket", "item", 10, 0.9, 15, 0.8)
table.insert(fauna_producing_recipes, mikrofauna_hunting)

local fishing =
    Tirislib_Recipe.create {
    name = "general-fishing",
    category = "sosciencity-fishery",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/fishing.png",
    icon_size = 64,
    subgroup = "sosciencity-gathering",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:create_difficulties()
fishing:multiply_expensive_field("energy_required", 2)
fishing:add_catalyst("fishing-net", "item", 2, 0.8, 3, 0.7)
table.insert(fauna_producing_recipes, fishing)

local function get_result_prototype(animal)
    return {
        name = animal.name,
        amount = animal.group_size or (not animal.min_group_size) and 1,
        probability = animal.probability,
        amount_min = animal.min_group_size,
        amount_max = animal.max_group_size
    }
end

local function add_to_gather_recipe(animal)
    local result_prototype = get_result_prototype(animal)

    if is_water_animal(animal) then
        fishing:add_result(result_prototype)
        return
    end
    if animal.size >= 100 then
        megafauna_hunting:add_result(result_prototype)
    end
    if animal.size < 100 and animal.size >= 10 then
        makrofauna_hunting:add_result(result_prototype)
    else
        mikrofauna_hunting:add_result(result_prototype)
    end
end

for _, animal in pairs(animals) do
    if animal.probability then
        add_to_gather_recipe(animal)
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
    local item = Tirislib_Item.get_by_name(animal.name)

    local recipe =
        Tirislib_Recipe.create {
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
                scale = 0.25,
                shift = {-8, -8},
                tint = {r = 1, g = 0.2, b = 0.2, a = 0.8}
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

    if animal.bird then
        recipe:add_new_result("feathers", get_feather_amount(animal))
    end

    if animal.slaughter_byproducts then
        recipe:add_result_range(animal.slaughter_byproducts)
    end
end

for index, animal in pairs(animals) do
    create_slaughter_recipe(animal, index)
end

---------------------------------------------------------------------------------------------------
-- << breeding recipes >>
local food_item_weight = 50
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
    return math.ceil(count * get_weight_gain(animal) * (animal.metabolism_coefficient or 2) / food_item_weight)
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

    return {theme, get_food_amount(animal, count), animal.level or 0}
end

local function create_breeding_recipe(animal)
    local cycle_amount = get_cycle_animal_amount(animal)
    local energy = get_required_energy_breeding(animal)

    local recipe =
        Tirislib_RecipeGenerator.create {
        product = animal.name,
        product_amount = cycle_amount,
        category = is_water_animal(animal) and "sosciencity-water-animal-farming" or "sosciencity-animal-farming",
        byproducts = animal.breeding_byproducts or nil,
        themes = {get_food_theme(animal, cycle_amount)},
        energy_required = energy
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

    table.insert(fauna_producing_recipes, recipe)
end

for index, animal in pairs(animals) do
    if not animal.not_breedable then
        create_breeding_recipe(animal)
    end
end

---------------------------------------------------------------------------------------------------
-- << entities >>

if settings.startup["sosciencity-modify-environment"].value then
    -- 'fish' entity to have ducks swimming on water bodies
    -- it seems like the factorio engine treats the order-string of the autoplace definition as some kind of ID, so I'm giving them a distinct one to be sure
    Tirislib_Entity.create {
        type = "fish",
        name = "primal-quacker",
        icon = "__sosciencity-graphics__/graphics/icon/primal-quacker.png",
        icon_size = 64,
        flags = {"placeable-neutral", "not-on-map"},
        minable = {
            mining_time = 0.4,
            results = {
                {name = "primal-quacker", amount = 1},
                {name = "primal-quackling", amount_min = 0, amount_max = 5}
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
            influence = 0.01
        },
        localised_name = {"item-name.primal-quacker"}
    }

    Tirislib_Entity.create {
        type = "fish",
        name = "nan-swan",
        icon = "__sosciencity-graphics__/graphics/icon/nan-swan.png",
        icon_size = 64,
        flags = {"placeable-neutral", "not-on-map"},
        minable = {
            mining_time = 0.4,
            results = {
                {name = "nan-swan", amount = 1},
                {name = "nan-swanling", amount_min = 0, amount_max = 3}
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
            influence = 0.005
        },
        localised_name = {"item-name.nan-swan"}
    }

    local fishwhirl =
        Tirislib_Entity.create {
        type = "fish",
        name = "fishwhirl",
        icon = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl.png",
        icon_size = 64,
        flags = {"placeable-neutral", "not-on-map"},
        minable = {
            mining_time = 0.4,
            results = {}
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

    for _, animal in pairs(animals) do
        if animal.probability and is_water_animal(animal) then
            local result_prototype = get_result_prototype(animal)
            fishwhirl:add_mining_result(result_prototype)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << balance information >>

if Sosciencity_Config.BALANCING then
    local function get_animal_size(animal_name)
        for _, animal in pairs(animals) do
            if animal.name == animal_name then
                return animal.size
            end
        end
    end

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
end
