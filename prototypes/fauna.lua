---------------------------------------------------------------------------------------------------
-- << items >>
local animals = {
    {name = "primal-quackling", size = 0.4, bird = true, probability = 0.05, group_size = 4},
    {name = "primal-quacker", size = 1.2, bird = true, probability = 0.12},
    {name = "primal-quackpa", size = 1, bird = true},
    {name = "nan-swanling", size = 1, bird = true, probability = 0.04, group_size = 3},
    {name = "nan-swan", size = 12, bird = true, probability = 0.1},
    {name = "elder-nan", size = 10, bird = true},
    {name = "bonesnake", size = 100, bird = true, probability = 0.08},
    {name = "young-petunial", size = 2500, water_animal = true, probability = 0.05},
    {name = "petunial", size = 15000, water_animal = true, probability = 0.05},
    {name = "hellfin", size = 190, water_animal = true, probability = 0.09, group_size = 2},
    {name = "warnal", size = 1000, water_animal = true, probability = 0.09},
    {name = "shellscript", size = 50, water_animal = true, probability = 0.15},
    {name = "dodkopus", size = 40, water_animal = true, probability = 0.15},
    {name = "boofish", size = 3, fish = true, probability = 0.3, group_size = 5},
    {name = "fupper", size = 5, fish = true, probability = 0.5},
    {name = "ultra-squibbel", size = 50, water_animal = true, probability = 0.20},
    {name = "miniscule-squibbel", size = 150, water_animal = true, probability = 0.15}
}

Tirislib_Item.batch_create(animals, {subgroup = "sosciencity-fauna", stack_size = 20})

local function is_bird(animal)
    return animal.bird
end

local function is_land_animal(animal)
    return animal.land_animal
end

local function is_water_animal(animal)
    return animal.water_animal or animal.fish
end

local function get_meat_type(animal)
    -- option to specify it
    if animal.meat then
        return animal.meat
    end

    return (is_bird(animal) and "bird-meat") or (animal.fish and "fish-meat") or "mammal-meat"
end

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>
local hunting =
    Tirislib_Recipe.create {
    name = "hunting-for-mammals",
    category = "sosciencity-hunting",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/hunting.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:add_catalyst("trap", "item", 0.8, 0.7, 5, 6)

local bird_hunting =
    Tirislib_Recipe.create {
    name = "hunting-for-birds",
    category = "sosciencity-hunting",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/hunting.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:add_catalyst("bird-trap", "item", 0.9, 0.8, 2, 3)

local fishing =
    Tirislib_Recipe.create {
    name = "general-fishing",
    category = "sosciencity-fishery",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/fishing.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:add_catalyst("fishing-net", "item", 0.8, 0.7, 2, 3)

local function get_result_prototype(animal)
    return {name = animal.name, amount = animal.group_size or 1, probability = animal.probability}
end

local function add_to_gather_recipe(animal)
    local result_prototype = get_result_prototype(animal)

    if is_land_animal(animal) then
        hunting:add_result(result_prototype)
    end
    if is_bird(animal) then
        bird_hunting:add_result(result_prototype)
    end
    if is_water_animal(animal) then
        fishing:add_result(result_prototype)
    end
end

for _, animal in pairs(animals) do
    if animal.probability then
        add_to_gather_recipe(animal)
    end
end

---------------------------------------------------------------------------------------------------
-- << slaughter recipes >>
local function get_required_energy(animal)
    return animal.size ^ 0.5
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
        energy_required = get_required_energy(animal),
        ingredients = {
            {type = "item", name = animal.name, amount = 1}
        },
        icons = {
            {icon = item.icon},
            {icon = "__sosciencity-graphics__/graphics/icon/slaughter-this.png"}
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

    if is_bird(animal) then
        recipe:add_new_result("feathers", get_feather_amount(animal))
    end

    -- TODO bones
end

for index, animal in pairs(animals) do
    create_slaughter_recipe(animal, index)
end

---------------------------------------------------------------------------------------------------
-- << entities >>
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
