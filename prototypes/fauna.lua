---------------------------------------------------------------------------------------------------
-- << items >>
local animals = {
    {name = "primal-quackling"},
    {name = "primal-quacker"},
    {name = "primal-quackpa"},
    {name = "nan-swanling"},
    {name = "nan-swan"},
    {name = "elder-nan"}
}

Tirislib_Item.batch_create(animals, {subgroup = "sosciencity-fauna", stack_size = 20})

---------------------------------------------------------------------------------------------------
-- << hunting recipes >>

---------------------------------------------------------------------------------------------------
-- << fishing recipes >>
Tirislib_Recipe.create {
    name = "general-fishing", -- TODO this is just a testing recipe
    category = "sosciencity-fishery",
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = "elder-nan", amount_min = 2, amount_max = 4}
    },
    subgroup = "sosciencity-fauna",
    main_product = "elder-nan"
}

---------------------------------------------------------------------------------------------------
-- << entities >>
-- 'fish' entity to have ducks swimming on water bodies
-- it seems like the factorio engine treads the order-string of the autoplace definition as some kind of ID, so I'm giving them a distinct one to be sure
Tirislib_Entity.create {
    type = "fish",
    name = "primal-quacker",
    icon = "__sosciencity-graphics__/graphics/icon/primal-quacker.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    minable = {mining_time = 0.4, result = "primal-quacker", count = 1},
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
    minable = {mining_time = 0.4, result = "nan-swan", count = 1},
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
