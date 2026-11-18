local CityView = require("classes.guis.city-view")
local Elements = require("classes.guis.elements")

CityView.add_category("how-tos", {"city-view.how-tos"})

CityView.add_page {
    name = "introduction",
    category = "how-tos",
    localised_name = {"city-view.introduction"},
    creator = function(container)
        -- BEGIN GENERATED: introduction
        Elements.Label.heading_1(container, {"city-view.introduction-text1"})
        Elements.Label.paragraph(container, {"city-view.introduction-text2"})
        Elements.Label.paragraph(container, {"city-view.introduction-text3"})
        Elements.Label.heading_2(container, {"city-view.introduction-text4"})
        Elements.Label.paragraph(container, {"city-view.introduction-text5"})
        Elements.Label.list(
            container,
            {
                {"city-view.introduction-text6"},
                {"city-view.introduction-text7"},
                {"city-view.introduction-text8"},
                {"city-view.introduction-text9"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.introduction-text10"})
        Elements.Label.heading_2(container, {"city-view.introduction-text11"})
        Elements.Label.paragraph(container, {"city-view.introduction-text12"})
        Elements.Label.paragraph(container, {"city-view.introduction-text13"})
        Elements.Label.paragraph(container, {"city-view.introduction-text14"})
        Elements.Label.paragraph(container, {"city-view.introduction-text15"})
        -- END GENERATED: introduction
    end
}

CityView.add_page {
    name = "huwans101",
    category = "how-tos",
    localised_name = {"city-view.huwans101-text1"},
    creator = function(container)
        -- BEGIN GENERATED: huwans101
        Elements.Label.heading_1(container, {"city-view.huwans101-text1"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text2"})
        Elements.Label.heading_2(container, {"city-view.huwans101-text3"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text4"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text5"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text6"})
        Elements.Label.heading_3(container, {"city-view.huwans101-text7"})
        Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text8"},
                {"city-view.huwans101-text9"}
            }
        )
        Elements.Label.heading_3(container, {"city-view.huwans101-text10"})
        Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text11"},
                {"city-view.huwans101-text12"},
                {"city-view.huwans101-text13"}
            }
        )
        Elements.Label.heading_3(container, {"city-view.huwans101-text14"})
        Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text15"},
                {"city-view.huwans101-text16"},
                {"city-view.huwans101-text17"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.huwans101-text18"})
        Elements.Label.heading_2(container, {"city-view.huwans101-text19"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text20"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text21"})
        Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text22"},
                {"city-view.huwans101-text23"},
                {"city-view.huwans101-text24"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.huwans101-text25"})
        Elements.Button.page_link(container, "how-tos", "housing")
        Elements.Label.heading_3(container, {"city-view.huwans101-text27"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text28"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text29"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text30"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text31"})
        Elements.Label.heading_2(container, {"city-view.huwans101-text32"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text33"})
        Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text34"},
                {"city-view.huwans101-text35"},
                {"city-view.huwans101-text36"},
                {"city-view.huwans101-text37"},
                {"city-view.huwans101-text38"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.huwans101-text39"})
        Elements.Button.page_link(container, "how-tos", "food")
        Elements.Label.heading_2(container, {"city-view.huwans101-text41"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text42"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text43"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text44"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text45"})
        Elements.Label.heading_2(container, {"city-view.huwans101-text46"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text47"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text48"})
        Elements.Label.heading_2(container, {"city-view.huwans101-text49"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text50"})
        Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text51"},
                {"city-view.huwans101-text52"},
                {"city-view.huwans101-text53"},
                {"city-view.huwans101-text54"},
                {"city-view.huwans101-text55"},
                {"city-view.huwans101-text56"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.huwans101-text57"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text58"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text59"})
        Elements.Label.paragraph(container, {"city-view.huwans101-text60"})
        Elements.Button.page_link(container, "how-tos", "healthcare")
        Elements.Button.page_link(container, "data", "diseases")
        -- END GENERATED: huwans101
    end
}

CityView.add_page {
    name = "housing",
    category = "how-tos",
    localised_name = {"city-view.housing-text1"},
    creator = function(container)
        -- BEGIN GENERATED: housing
        Elements.Label.heading_1(container, {"city-view.housing-text1"})
        Elements.Label.paragraph(container, {"city-view.housing-text2"})
        Elements.Label.heading_2(container, {"city-view.housing-text3"})
        Elements.Label.paragraph(container, {"city-view.housing-text4"})
        Elements.Label.list(
            container,
            {
                {"city-view.housing-text5"},
                {"city-view.housing-text6"},
                {"city-view.housing-text7"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.housing-text8"})
        Elements.Label.heading_2(container, {"city-view.housing-text9"})
        Elements.Label.paragraph(container, {"city-view.housing-text10"})
        Elements.Label.heading_3(container, {"city-view.housing-text11"})
        Elements.Label.paragraph(container, {"city-view.housing-text12"})
        Elements.Label.list(
            container,
            {
                {"city-view.housing-text13"},
                {"city-view.housing-text14"},
                {"city-view.housing-text15"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.housing-text16"})
        Elements.Label.paragraph(container, {"city-view.housing-text17"})
        Elements.Label.heading_3(container, {"city-view.housing-text18"})
        Elements.Label.paragraph(container, {"city-view.housing-text19"})
        Elements.Label.list(
            container,
            {
                {"city-view.housing-text20"},
                {"city-view.housing-text21"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.housing-text22"})
        Elements.Label.paragraph(container, {"city-view.housing-text23"})
        Elements.Label.heading_3(container, {"city-view.housing-text24"})
        Elements.Label.paragraph(container, {"city-view.housing-text25"})
        Elements.Label.list(
            container,
            {
                {"city-view.housing-text26"},
                {"city-view.housing-text27"}
            }
        )
        Elements.Label.heading_3(container, {"city-view.housing-text28"})
        Elements.Label.paragraph(container, {"city-view.housing-text29"})
        Elements.Label.list(
            container,
            {
                {"city-view.housing-text30"},
                {"city-view.housing-text31"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.housing-text32"})
        Elements.Label.heading_2(container, {"city-view.housing-text33"})
        Elements.Label.paragraph(container, {"city-view.housing-text34"})
        Elements.Label.paragraph(container, {"city-view.housing-text35"})
        Elements.Label.paragraph(container, {"city-view.housing-text36"})
        Elements.Label.heading_2(container, {"city-view.housing-text37"})
        Elements.Label.paragraph(container, {"city-view.housing-text38"})
        Elements.Label.paragraph(container, {"city-view.housing-text39"})
        Elements.Label.paragraph(container, {"city-view.housing-text40"})
        Elements.Label.heading_3(container, {"city-view.housing-text41"})
        Elements.Label.paragraph(container, {"city-view.housing-text42"})
        Elements.Label.heading_3(container, {"city-view.housing-text43"})
        Elements.Label.paragraph(container, {"city-view.housing-text44"})
        Elements.Label.heading_2(container, {"city-view.housing-text45"})
        Elements.Label.paragraph(container, {"city-view.housing-text46"})
        Elements.Label.paragraph(container, {"city-view.housing-text47"})
        Elements.Label.heading_2(container, {"city-view.housing-text48"})
        Elements.Label.paragraph(container, {"city-view.housing-text49"})
        Elements.Label.heading_3(container, {"city-view.housing-text50"})
        Elements.Label.list(
            container,
            {
                {"city-view.housing-text51"},
                {"city-view.housing-text52"}
            }
        )
        Elements.Label.heading_3(container, {"city-view.housing-text53"})
        Elements.Label.paragraph(container, {"city-view.housing-text54"})
        Elements.Label.heading_3(container, {"city-view.housing-text55"})
        Elements.Label.paragraph(container, {"city-view.housing-text56"})
        -- END GENERATED: housing
    end
}

CityView.add_page {
    name = "food",
    category = "how-tos",
    localised_name = {"city-view.food-text1"},
    creator = function(container)
        -- BEGIN GENERATED: food
        Elements.Label.heading_1(container, {"city-view.food-text1"})
        Elements.Label.paragraph(container, {"city-view.food-text2"})
        Elements.Label.heading_2(container, {"city-view.food-text3"})
        Elements.Label.paragraph(container, {"city-view.food-text4"})
        Elements.Label.heading_3(container, {"city-view.food-text5"})
        Elements.Label.paragraph(container, {"city-view.food-text6"})
        Elements.Label.heading_3(container, {"city-view.food-text7"})
        Elements.Label.paragraph(container, {"city-view.food-text8"})
        Elements.Label.heading_3(container, {"city-view.food-text9"})
        Elements.Label.paragraph(container, {"city-view.food-text10"})
        Elements.Label.heading_2(container, {"city-view.food-text11"})
        Elements.Label.paragraph(container, {"city-view.food-text12"})
        Elements.Label.list(
            container,
            {
                {"city-view.food-text13"},
                {"city-view.food-text14"},
                {"city-view.food-text15"},
                {"city-view.food-text16"}
            }
        )
        Elements.Label.heading_2(container, {"city-view.food-text17"})
        Elements.Label.paragraph(container, {"city-view.food-text18"})
        Elements.Label.heading_2(container, {"city-view.food-text19"})
        Elements.Label.paragraph(container, {"city-view.food-text20"})
        Elements.Label.list(
            container,
            {
                {"city-view.food-text21"},
                {"city-view.food-text22"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.food-text23"})
        Elements.Label.paragraph(container, {"city-view.food-text24"})
        Elements.Label.list(
            container,
            {
                {"city-view.food-text25"},
                {"city-view.food-text26"},
                {"city-view.food-text27"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.food-text28"})
        Elements.Label.heading_2(container, {"city-view.food-text29"})
        Elements.Label.paragraph(container, {"city-view.food-text30"})
        Elements.Label.list(
            container,
            {
                {"city-view.food-text31"},
                {"city-view.food-text32"},
                {"city-view.food-text33"}
            }
        )
        Elements.Label.heading_2(container, {"city-view.food-text34"})
        Elements.Label.paragraph(container, {"city-view.food-text35"})
        Elements.Label.list(
            container,
            {
                {"city-view.food-text36"},
                {"city-view.food-text37"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.food-text38"})
        Elements.Label.paragraph(container, {"city-view.food-text39"})
        Elements.Label.heading_2(container, {"city-view.food-text40"})
        Elements.Label.paragraph(container, {"city-view.food-text41"})
        Elements.Label.list(
            container,
            {
                {"city-view.food-text42"},
                {"city-view.food-text43"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.food-text44"})
        -- END GENERATED: food
    end
}

CityView.add_page {
    name = "healthcare",
    category = "how-tos",
    localised_name = {"city-view.healthcare-text1"},
    creator = function(container)
        -- BEGIN GENERATED: healthcare
        Elements.Label.heading_1(container, {"city-view.healthcare-text1"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text2"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text3"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text4"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text5"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text6"})
        Elements.Label.list(
            container,
            {
                {"city-view.healthcare-text7"},
                {"city-view.healthcare-text8"},
                {"city-view.healthcare-text9"},
                {"city-view.healthcare-text10"},
                {"city-view.healthcare-text11"},
                {"city-view.healthcare-text12"},
                {"city-view.healthcare-text13"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.healthcare-text14"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text15"})
        Elements.Button.page_link(container, "data", "diseases")
        Elements.Label.heading_2(container, {"city-view.healthcare-text17"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text18"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text19"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text20"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text21"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text22"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text23"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text24"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text25"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text26"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text27"})
        Elements.Label.list(
            container,
            {
                {"city-view.healthcare-text28"},
                {"city-view.healthcare-text29"},
                {"city-view.healthcare-text30"},
                {"city-view.healthcare-text31"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.healthcare-text32"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text33"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text34"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text35"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text36"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text37"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text38"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text39"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text40"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text41"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text42"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text43"})
        Elements.Label.heading_2(container, {"city-view.healthcare-text44"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text45"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text46"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text47"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text48"})
        Elements.Label.list(
            container,
            {
                {"city-view.healthcare-text49"},
                {"city-view.healthcare-text50"},
                {"city-view.healthcare-text51"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.healthcare-text52"})
        Elements.Label.paragraph(container, {"city-view.healthcare-text53"})
        -- END GENERATED: healthcare
    end
}

CityView.add_page {
    name = "work",
    category = "how-tos",
    localised_name = {"city-view.work"},
    creator = function(container)
        -- BEGIN GENERATED: work
        Elements.Label.heading_1(container, {"city-view.work-text1"})
        Elements.Label.paragraph(container, {"city-view.work-text2"})
        Elements.Label.heading_2(container, {"city-view.work-text3"})
        Elements.Label.paragraph(container, {"city-view.work-text4"})
        Elements.Label.paragraph(container, {"city-view.work-text5"})
        Elements.Label.paragraph(container, {"city-view.work-text6"})
        Elements.Label.heading_2(container, {"city-view.work-text7"})
        Elements.Label.paragraph(container, {"city-view.work-text8"})
        Elements.Label.paragraph(container, {"city-view.work-text9"})
        -- END GENERATED: work
    end
}

CityView.add_page {
    name = "maintenance",
    category = "how-tos",
    localised_name = {"city-view.maintenance-text1"},
    creator = function(container)
        -- BEGIN GENERATED: maintenance
        Elements.Label.heading_1(container, {"city-view.maintenance-text1"})
        Elements.Label.paragraph(container, {"city-view.maintenance-text2"})
        Elements.Label.list(
            container,
            {
                {"city-view.maintenance-text3"},
                {"city-view.maintenance-text4"},
                {"city-view.maintenance-text5"},
                {"city-view.maintenance-text6"},
                {"city-view.maintenance-text7"},
                {"city-view.maintenance-text8"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.maintenance-text9"})
        -- END GENERATED: maintenance
    end
}

CityView.add_page {
    name = "competition",
    category = "how-tos",
    localised_name = {"city-view.competition-text1"},
    creator = function(container)
        -- BEGIN GENERATED: competition
        Elements.Label.heading_1(container, {"city-view.competition-text1"})
        Elements.Label.paragraph(container, {"city-view.competition-text2"})
        Elements.Label.paragraph(container, {"city-view.competition-text3"})
        Elements.Label.heading_2(container, {"city-view.competition-text4"})
        Elements.Label.paragraph(container, {"city-view.competition-text5"})
        Elements.Label.paragraph(container, {"city-view.competition-text6"})
        -- END GENERATED: competition
    end
}

CityView.add_page {
    name = "composting",
    category = "how-tos",
    localised_name = {"city-view.composting-text1"},
    creator = function(container)
        -- BEGIN GENERATED: composting
        Elements.Label.heading_1(container, {"city-view.composting-text1"})
        Elements.Label.paragraph(container, {"city-view.composting-text2"})
        Elements.Label.paragraph(container, {"city-view.composting-text3"})
        Elements.Label.paragraph(container, {"city-view.composting-text4"})
        Elements.Label.paragraph(container, {"city-view.composting-text5"})
        Elements.Label.paragraph(container, {"city-view.composting-text6"})
        Elements.Label.paragraph(container, {"city-view.composting-text7"})
        Elements.Label.paragraph(container, {"city-view.composting-text8"})
        Elements.Button.page_link(container, "data", "compost")
        Elements.Label.paragraph(container, {"city-view.composting-text10"})
        -- END GENERATED: composting
    end
}

CityView.add_page {
    name = "blood-donations",
    category = "how-tos",
    localised_name = {"city-view.blood-donations-text1"},
    creator = function(container)
        -- BEGIN GENERATED: blood-donations
        Elements.Label.heading_1(container, {"city-view.blood-donations-text1"})
        Elements.Label.paragraph(container, {"city-view.blood-donations-text2"})
        Elements.Label.paragraph(container, {"city-view.blood-donations-text3"})
        Elements.Label.paragraph(container, {"city-view.blood-donations-text4"})
        Elements.Label.paragraph(container, {"city-view.blood-donations-text5"})
        -- END GENERATED: blood-donations
    end
}

CityView.add_page {
    name = "fear",
    category = "how-tos",
    localised_name = {"city-view.fear-text1"},
    creator = function(container)
        -- BEGIN GENERATED: fear
        Elements.Label.heading_1(container, {"city-view.fear-text1"})
        Elements.Label.paragraph(container, {"city-view.fear-text2"})
        Elements.Label.heading_2(container, {"city-view.fear-text3"})
        Elements.Label.paragraph(container, {"city-view.fear-text4"})
        Elements.Label.paragraph(container, {"city-view.fear-text5"})
        Elements.Label.list(
            container,
            {
                {"city-view.fear-text6"},
                {"city-view.fear-text7"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.fear-text8"})
        Elements.Label.paragraph(container, {"city-view.fear-text9"})
        Elements.Label.heading_2(container, {"city-view.fear-text10"})
        Elements.Label.paragraph(container, {"city-view.fear-text11"})
        Elements.Label.paragraph(container, {"city-view.fear-text12"})
        Elements.Label.heading_2(container, {"city-view.fear-text13"})
        Elements.Label.paragraph(container, {"city-view.fear-text14"})
        Elements.Label.paragraph(container, {"city-view.fear-text15"})
        Elements.Label.list(
            container,
            {
                {"city-view.fear-text16"},
                {"city-view.fear-text17"},
                {"city-view.fear-text18"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.fear-text19"})
        -- END GENERATED: fear
    end
}

CityView.add_page {
    name = "strike",
    category = "how-tos",
    localised_name = {"city-view.strike-text1"},
    creator = function(container)
        -- BEGIN GENERATED: strike
        Elements.Label.heading_1(container, {"city-view.strike-text1"})
        Elements.Label.paragraph(container, {"city-view.strike-text2"})
        Elements.Label.heading_2(container, {"city-view.strike-text3"})
        Elements.Label.paragraph(container, {"city-view.strike-text4"})
        Elements.Label.list(
            container,
            {
                {"city-view.strike-text5"},
                {"city-view.strike-text6"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.strike-text7"})
        Elements.Label.heading_2(container, {"city-view.strike-text8"})
        Elements.Label.paragraph(container, {"city-view.strike-text9"})
        Elements.Label.paragraph(container, {"city-view.strike-text10"})
        Elements.Label.paragraph(container, {"city-view.strike-text11"})
        Elements.Label.paragraph(container, {"city-view.strike-text12"})
        Elements.Label.paragraph(container, {"city-view.strike-text13"})
        Elements.Label.heading_2(container, {"city-view.strike-text14"})
        Elements.Label.paragraph(container, {"city-view.strike-text15"})
        Elements.Label.paragraph(container, {"city-view.strike-text16"})
        Elements.Label.heading_2(container, {"city-view.strike-text17"})
        Elements.Label.paragraph(container, {"city-view.strike-text18"})
        Elements.Label.list(
            container,
            {
                {"city-view.strike-text19"},
                {"city-view.strike-text20"},
                {"city-view.strike-text21"},
                {"city-view.strike-text22"}
            }
        )
        Elements.Label.paragraph(container, {"city-view.strike-text23"})
        -- END GENERATED: strike
    end
}
