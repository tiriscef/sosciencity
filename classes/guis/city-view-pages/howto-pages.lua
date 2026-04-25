Gui.CityView.add_category("how-tos", {"city-view.how-tos"})

Gui.CityView.add_page {
    name = "introduction",
    category = "how-tos",
    localised_name = {"city-view.introduction"},
    creator = function(container)
        -- BEGIN GENERATED: introduction
        Gui.Elements.Label.heading_1(container, {"city-view.introduction-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text2"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text3"})
        Gui.Elements.Label.heading_2(container, {"city-view.introduction-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text5"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.introduction-text6"},
                {"city-view.introduction-text7"},
                {"city-view.introduction-text8"},
                {"city-view.introduction-text9"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text10"})
        Gui.Elements.Label.heading_2(container, {"city-view.introduction-text11"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text12"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text13"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text14"})
        Gui.Elements.Label.paragraph(container, {"city-view.introduction-text15"})
        -- END GENERATED: introduction
    end
}

Gui.CityView.add_page {
    name = "huwans101",
    category = "how-tos",
    localised_name = {"city-view.huwans101-text1"},
    creator = function(container)
        -- BEGIN GENERATED: huwans101
        Gui.Elements.Label.heading_1(container, {"city-view.huwans101-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text2"})
        Gui.Elements.Label.heading_2(container, {"city-view.huwans101-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text5"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text6"})
        Gui.Elements.Label.heading_3(container, {"city-view.huwans101-text7"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text8"},
                {"city-view.huwans101-text9"}
            }
        )
        Gui.Elements.Label.heading_3(container, {"city-view.huwans101-text10"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text11"},
                {"city-view.huwans101-text12"},
                {"city-view.huwans101-text13"}
            }
        )
        Gui.Elements.Label.heading_3(container, {"city-view.huwans101-text14"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text15"},
                {"city-view.huwans101-text16"},
                {"city-view.huwans101-text17"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text18"})
        Gui.Elements.Label.heading_2(container, {"city-view.huwans101-text19"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text20"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text21"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text22"},
                {"city-view.huwans101-text23"},
                {"city-view.huwans101-text24"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text25"})
        Gui.Elements.Button.page_link(container, "how-tos", "housing")
        Gui.Elements.Label.heading_3(container, {"city-view.huwans101-text27"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text28"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text29"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text30"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text31"})
        Gui.Elements.Label.heading_2(container, {"city-view.huwans101-text32"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text33"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.huwans101-text34"},
                {"city-view.huwans101-text35"},
                {"city-view.huwans101-text36"},
                {"city-view.huwans101-text37"},
                {"city-view.huwans101-text38"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text39"})
        Gui.Elements.Button.page_link(container, "how-tos", "food")
        Gui.Elements.Label.heading_2(container, {"city-view.huwans101-text41"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text42"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text43"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text44"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text45"})
        Gui.Elements.Label.heading_2(container, {"city-view.huwans101-text46"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text47"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text48"})
        Gui.Elements.Label.heading_2(container, {"city-view.huwans101-text49"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text50"})
        Gui.Elements.Label.list(
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
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text57"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text58"})
        Gui.Elements.Label.paragraph(container, {"city-view.huwans101-text59"})
        Gui.Elements.Button.page_link(container, "data", "diseases")
        -- END GENERATED: huwans101
    end
}

Gui.CityView.add_page {
    name = "housing",
    category = "how-tos",
    localised_name = {"city-view.housing-text1"},
    creator = function(container)
        -- BEGIN GENERATED: housing
        Gui.Elements.Label.heading_1(container, {"city-view.housing-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text2"})
        Gui.Elements.Label.heading_2(container, {"city-view.housing-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text4"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.housing-text5"},
                {"city-view.housing-text6"},
                {"city-view.housing-text7"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text8"})
        Gui.Elements.Label.heading_2(container, {"city-view.housing-text9"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text10"})
        Gui.Elements.Label.heading_3(container, {"city-view.housing-text11"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text12"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.housing-text13"},
                {"city-view.housing-text14"},
                {"city-view.housing-text15"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text16"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text17"})
        Gui.Elements.Label.heading_3(container, {"city-view.housing-text18"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text19"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.housing-text20"},
                {"city-view.housing-text21"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text22"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text23"})
        Gui.Elements.Label.heading_3(container, {"city-view.housing-text24"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text25"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.housing-text26"},
                {"city-view.housing-text27"}
            }
        )
        Gui.Elements.Label.heading_3(container, {"city-view.housing-text28"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text29"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.housing-text30"},
                {"city-view.housing-text31"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text32"})
        Gui.Elements.Label.heading_2(container, {"city-view.housing-text33"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text34"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text35"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text36"})
        Gui.Elements.Label.heading_2(container, {"city-view.housing-text37"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text38"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text39"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text40"})
        Gui.Elements.Label.heading_3(container, {"city-view.housing-text41"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text42"})
        Gui.Elements.Label.heading_3(container, {"city-view.housing-text43"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text44"})
        Gui.Elements.Label.heading_2(container, {"city-view.housing-text45"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text46"})
        Gui.Elements.Label.paragraph(container, {"city-view.housing-text47"})
        -- END GENERATED: housing
    end
}

Gui.CityView.add_page {
    name = "work",
    category = "how-tos",
    localised_name = {"city-view.work"},
    creator = function(container)
        -- BEGIN GENERATED: work
        Gui.Elements.Label.heading_1(container, {"city-view.work-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.work-text2"})
        Gui.Elements.Label.heading_2(container, {"city-view.work-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.work-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.work-text5"})
        Gui.Elements.Label.paragraph(container, {"city-view.work-text6"})
        Gui.Elements.Label.heading_2(container, {"city-view.work-text7"})
        Gui.Elements.Label.paragraph(container, {"city-view.work-text8"})
        Gui.Elements.Label.paragraph(container, {"city-view.work-text9"})
        -- END GENERATED: work
    end
}

Gui.CityView.add_page {
    name = "maintenance",
    category = "how-tos",
    localised_name = {"city-view.maintenance-text1"},
    creator = function(container)
        -- BEGIN GENERATED: maintenance
        Gui.Elements.Label.heading_1(container, {"city-view.maintenance-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.maintenance-text2"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.maintenance-text3"},
                {"city-view.maintenance-text4"},
                {"city-view.maintenance-text5"},
                {"city-view.maintenance-text6"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.maintenance-text7"})
        -- END GENERATED: maintenance
    end
}

Gui.CityView.add_page {
    name = "competition",
    category = "how-tos",
    localised_name = {"city-view.competition-text1"},
    creator = function(container)
        -- BEGIN GENERATED: competition
        Gui.Elements.Label.heading_1(container, {"city-view.competition-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.competition-text2"})
        Gui.Elements.Label.paragraph(container, {"city-view.competition-text3"})
        Gui.Elements.Label.heading_2(container, {"city-view.competition-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.competition-text5"})
        Gui.Elements.Label.paragraph(container, {"city-view.competition-text6"})
        -- END GENERATED: competition
    end
}

Gui.CityView.add_page {
    name = "composting",
    category = "how-tos",
    localised_name = {"city-view.composting-text1"},
    creator = function(container)
        -- BEGIN GENERATED: composting
        Gui.Elements.Label.heading_1(container, {"city-view.composting-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text2"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text5"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text6"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text7"})
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text8"})
        Gui.Elements.Button.page_link(container, "data", "compost")
        Gui.Elements.Label.paragraph(container, {"city-view.composting-text10"})
        -- END GENERATED: composting
    end
}

Gui.CityView.add_page {
    name = "blood-donations",
    category = "how-tos",
    localised_name = {"city-view.blood-donations-text1"},
    creator = function(container)
        -- BEGIN GENERATED: blood-donations
        Gui.Elements.Label.heading_1(container, {"city-view.blood-donations-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.blood-donations-text2"})
        Gui.Elements.Label.paragraph(container, {"city-view.blood-donations-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.blood-donations-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.blood-donations-text5"})
        -- END GENERATED: blood-donations
    end
}

Gui.CityView.add_page {
    name = "fear",
    category = "how-tos",
    localised_name = {"city-view.fear-text1"},
    creator = function(container)
        -- BEGIN GENERATED: fear
        Gui.Elements.Label.heading_1(container, {"city-view.fear-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text2"})
        Gui.Elements.Label.heading_2(container, {"city-view.fear-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text4"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text5"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.fear-text6"},
                {"city-view.fear-text7"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text8"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text9"})
        Gui.Elements.Label.heading_2(container, {"city-view.fear-text10"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text11"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text12"})
        Gui.Elements.Label.heading_2(container, {"city-view.fear-text13"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text14"})
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text15"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.fear-text16"},
                {"city-view.fear-text17"},
                {"city-view.fear-text18"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.fear-text19"})
        -- END GENERATED: fear
    end
}

Gui.CityView.add_page {
    name = "strike",
    category = "how-tos",
    localised_name = {"city-view.strike-text1"},
    creator = function(container)
        -- BEGIN GENERATED: strike
        Gui.Elements.Label.heading_1(container, {"city-view.strike-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text2"})
        Gui.Elements.Label.heading_2(container, {"city-view.strike-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text4"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.strike-text5"},
                {"city-view.strike-text6"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text7"})
        Gui.Elements.Label.heading_2(container, {"city-view.strike-text8"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text9"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text10"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text11"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text12"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text13"})
        Gui.Elements.Label.heading_2(container, {"city-view.strike-text14"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text15"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text16"})
        Gui.Elements.Label.heading_2(container, {"city-view.strike-text17"})
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text18"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.strike-text19"},
                {"city-view.strike-text20"},
                {"city-view.strike-text21"},
                {"city-view.strike-text22"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.strike-text23"})
        -- END GENERATED: strike
    end
}

Gui.CityView.add_page {
    name = "food",
    category = "how-tos",
    localised_name = {"city-view.food-text1"},
    creator = function(container)
        -- BEGIN GENERATED: food
        Gui.Elements.Label.heading_1(container, {"city-view.food-text1"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text2"})
        Gui.Elements.Label.heading_2(container, {"city-view.food-text3"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text4"})
        Gui.Elements.Label.heading_3(container, {"city-view.food-text5"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text6"})
        Gui.Elements.Label.heading_3(container, {"city-view.food-text7"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text8"})
        Gui.Elements.Label.heading_3(container, {"city-view.food-text9"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text10"})
        Gui.Elements.Label.heading_2(container, {"city-view.food-text11"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text12"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.food-text13"},
                {"city-view.food-text14"},
                {"city-view.food-text15"},
                {"city-view.food-text16"}
            }
        )
        Gui.Elements.Label.heading_2(container, {"city-view.food-text17"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text18"})
        Gui.Elements.Label.heading_2(container, {"city-view.food-text19"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text20"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.food-text21"},
                {"city-view.food-text22"},
                {"city-view.food-text23"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.food-text24"})
        Gui.Elements.Label.heading_2(container, {"city-view.food-text25"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text26"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.food-text27"},
                {"city-view.food-text28"},
                {"city-view.food-text29"}
            }
        )
        Gui.Elements.Label.heading_2(container, {"city-view.food-text30"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text31"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.food-text32"},
                {"city-view.food-text33"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.food-text34"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text35"})
        Gui.Elements.Label.heading_2(container, {"city-view.food-text36"})
        Gui.Elements.Label.paragraph(container, {"city-view.food-text37"})
        Gui.Elements.Label.list(
            container,
            {
                {"city-view.food-text38"},
                {"city-view.food-text39"}
            }
        )
        Gui.Elements.Label.paragraph(container, {"city-view.food-text40"})
        -- END GENERATED: food
    end
}
