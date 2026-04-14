---------------------------------------------------------------------------------------------------
-- << water treatment >>

Tirislib.Technology.create {
    name = "drinking-water-treatment",
    icon = "__sosciencity-graphics__/graphics/technology/drinking-water-treatment.png",
    icon_size = 128,
    prerequisites = {"chemical-science-pack"},
    unit = {
        count = 239,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}
