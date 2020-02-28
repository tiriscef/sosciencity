---------------------------------------------------------------------------------------------------
-- << items >>
local animals = {
    {name = "primal-quackling"},
    {name = "primal-quacker"},
    {name = "primal-quackpa"},
    {name = "nan-swanling"},
    {name = "nan-swan"}
}

Tirislib_Item.batch_create(animals, {subgroup = "sosciencity-fauna", stack_size = 20})

---------------------------------------------------------------------------------------------------
-- << entities >>
-- 'fish' entity to have ducks swimming on water bodies
Tirislib_Entity.create {
    type = "fish",
    name = "primal-quacker",
    icon = "__sosciencity-graphics__/graphics/icon/primal-quacker.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    minable = {mining_time = 0.4, result = "primal-quacker", count = 1},
    max_health = 20,
    subgroup = "creatures",
    order = "b-a",
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
    autoplace = {influence = 0.01}
}
