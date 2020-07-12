---------------------------------------------------------------------------------------------------
-- << items >>
local animals = {
    {name = "primal-quackling", size = 0.2, bird = true, probability = 0.05, group_size = 4},
    {name = "primal-quacker", size = 1, bird = true, probability = 0.12},
    {name = "primal-quackpa", size = 0.8, bird = true},
    {name = "nan-swanling", size = 1, bird = true, probability = 0.04, group_size = 3},
    {name = "nan-swan", size = 1, bird = true, probability = 0.1},
    {name = "elder-nan", size = 1, bird = true},
    {name = "ostrich", size = 1, bird = true, probability = 0.08},
    {name = "young-petunial", size = 1, water_animal = true, probability = 0.05},
    {name = "petunial", size = 1, water_animal = true, probability = 0.05},
    {name = "dolphin", size = 1, water_animal = true, probability = 0.09},
    {name = "myfish", size = 1, fish = true, probability = 0.1, group_size = 5},
    {name = "puffer", size = 1, fish = true, probability = 0.2}
}

Tirislib_Item.batch_create(animals, {subgroup = "sosciencity-fauna", stack_size = 20})

local function is_bird(animal)
    return animal.bird
end

local function is_land_animal(animal)
    return animal.bird
end

local function is_water_animal(animal)
    return animal.water_animal or animal.fish
end

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>
local hunting =
    Tirislib_Recipe.create {
    name = "general-hunting",
    category = "sosciencity-hunting",
    energy_required = 20,
    icon = "__sosciencity-graphics__/graphics/icon/hunting.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna",
    allow_decomposition = false,
    always_show_made_in = true,
    main_product = ""
}:add_catalyst("trap", "item", 0.8, 5)

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
}:add_catalyst("bird-trap", "item", 0.9, 5)

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
}:add_catalyst("fishing-net", "item", 0.8, 5)

local function add_to_gather_recipe(animal)
    local result_prototype = {name = animal.name, amount = 1, probability = animal.probability}

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

local function get_meat_amount(animal)

end

local function get_offal_amount(animal)

end

local function get_slaughter_waste_amount(animal)

end

local function create_slaughter_recipe(animal)
    local item = Tirislib_Item.get_by_name(animal.name)

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
        main_product = ""
    }
    -- TODO results
end

for _, animal in pairs(animals) do
    create_slaughter_recipe(animal)
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

Tirislib_Entity.create {
    type = "fish",
    name = "fishwhirl",
    icon = "__sosciencity-graphics__/graphics/entity/fishwhirl/fishwhirl.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    minable = {
        mining_time = 0.4,
        results = {
            {name = "petunial", amount = 1, probability = 0.02},
            {name = "myfish", amount_min = 2, amount_max = 6, probability = 0.3}
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
