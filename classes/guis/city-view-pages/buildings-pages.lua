local Castes = require("constants.castes")
local Type = require("enums.type")

local BuildingOverview = Gui.BuildingOverview

Gui.CityView.add_category("buildings", {"city-view.buildings"})

-- one page per caste housing type
for _, caste in pairs(Castes.all) do
    Gui.CityView.add_page {
        name = caste.name .. "-housing",
        category = "buildings",
        localised_name = {"", caste.localised_name, " ", {"city-view.housing"}},
        creator = BuildingOverview.make_creator(caste.name .. "-housing"),
        enabler = BuildingOverview.make_enabler(caste.name .. "-housing")
    }
end

Gui.CityView.add_page {
    name = "hospitals",
    category = "buildings",
    localised_name = {"city-view.hospitals"},
    creator = BuildingOverview.make_creator("hospitals"),
    enabler = BuildingOverview.make_enabler("hospitals")
}

Gui.CityView.add_page {
    name = "markets",
    category = "buildings",
    localised_name = {"city-view.markets"},
    creator = BuildingOverview.make_creator("markets"),
    enabler = BuildingOverview.make_enabler("markets")
}
