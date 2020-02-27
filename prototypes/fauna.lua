Tirislib_Entity.create {
    type = "fish",
    name = "primal-quacker",
    icon = "__base__/graphics/icons/fish.png",
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
            priority = "extra-high",
            width = 64,
            height = 128,
            scale = 1./4.
        },
    },
    autoplace = {influence = 0.01}
}
