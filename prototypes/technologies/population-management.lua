Tirislib.Technology.create {
    name = "moving-efficiency-1",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"logistic-science-pack", "infrastructure-2"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.moving-efficiency"}
        }
    },
    unit = {
        count = 75,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}
