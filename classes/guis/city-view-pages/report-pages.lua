Gui.CityView.add_category("statistics", {"city-view.statistics"})

Gui.CityView.add_page {
    name = "overview",
    category = "statistics",
    localised_name = {"sosciencity.overview"},
    creator = function(container)
        -- TODO
    end
}

Gui.CityView.add_page {
    name = "census-report",
    category = "statistics",
    localised_name = {"report-name.census"},
    creator = function(container)
        --TODO
    end
}

Gui.CityView.add_page {
    name = "healthcare-report",
    category = "statistics",
    localised_name = {"report-name.healthcare"},
    creator = function(container)
        --TODO
    end
}
