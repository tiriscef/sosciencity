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

Gui.CityView.add_page {
    name = "water-distributers",
    category = "buildings",
    localised_name = {"city-view.water-distributers"},
    creator = BuildingOverview.make_creator("water-distributers"),
    enabler = BuildingOverview.make_enabler("water-distributers")
}

Gui.CityView.add_page {
    name = "dumpsters",
    category = "buildings",
    localised_name = {"city-view.dumpsters"},
    creator = BuildingOverview.make_creator("dumpsters"),
    enabler = BuildingOverview.make_enabler("dumpsters")
}

Gui.CityView.add_page {
    name = "waste-dumps",
    category = "buildings",
    localised_name = {"city-view.waste-dumps"},
    creator = BuildingOverview.make_creator("waste-dumps"),
    enabler = BuildingOverview.make_enabler("waste-dumps")
}

Gui.CityView.add_page {
    name = "immigration-ports",
    category = "buildings",
    localised_name = {"city-view.immigration-ports"},
    creator = BuildingOverview.make_creator("immigration-ports"),
    enabler = BuildingOverview.make_enabler("immigration-ports")
}

Gui.CityView.add_page {
    name = "nightclubs",
    category = "buildings",
    localised_name = {"city-view.nightclubs"},
    creator = BuildingOverview.make_creator("nightclubs"),
    enabler = BuildingOverview.make_enabler("nightclubs")
}

Gui.CityView.add_page {
    name = "kitchens-for-all",
    category = "buildings",
    localised_name = {"city-view.kitchens-for-all"},
    creator = BuildingOverview.make_creator("kitchens-for-all"),
    enabler = BuildingOverview.make_enabler("kitchens-for-all")
}

Gui.CityView.add_page {
    name = "egg-collectors",
    category = "buildings",
    localised_name = {"city-view.egg-collectors"},
    creator = BuildingOverview.make_creator("egg-collectors"),
    enabler = BuildingOverview.make_enabler("egg-collectors")
}

Gui.CityView.add_page {
    name = "upbringing-stations",
    category = "buildings",
    localised_name = {"city-view.upbringing-stations"},
    creator = BuildingOverview.make_creator("upbringing-stations"),
    enabler = BuildingOverview.make_enabler("upbringing-stations")
}

Gui.CityView.add_page {
    name = "caste-education-buildings",
    category = "buildings",
    localised_name = {"city-view.caste-education-buildings"},
    creator = BuildingOverview.make_creator("caste-education-buildings"),
    enabler = BuildingOverview.make_enabler("caste-education-buildings")
}

Gui.CityView.add_page {
    name = "manufactories",
    category = "buildings",
    localised_name = {"city-view.manufactories"},
    creator = BuildingOverview.make_creator("manufactories"),
    enabler = BuildingOverview.make_enabler("manufactories")
}

Gui.CityView.add_page {
    name = "social-observatories",
    category = "buildings",
    localised_name = {"city-view.social-observatories"},
    creator = BuildingOverview.make_creator("social-observatories"),
    enabler = BuildingOverview.make_enabler("social-observatories")
}

Gui.CityView.add_page {
    name = "fisheries",
    category = "buildings",
    localised_name = {"city-view.fisheries"},
    creator = BuildingOverview.make_creator("fisheries"),
    enabler = BuildingOverview.make_enabler("fisheries")
}

Gui.CityView.add_page {
    name = "hunting-huts",
    category = "buildings",
    localised_name = {"city-view.hunting-huts"},
    creator = BuildingOverview.make_creator("hunting-huts"),
    enabler = BuildingOverview.make_enabler("hunting-huts")
}

Gui.CityView.add_page {
    name = "farms",
    category = "buildings",
    localised_name = {"city-view.farms"},
    creator = BuildingOverview.make_creator("farms"),
    enabler = BuildingOverview.make_enabler("farms")
}

Gui.CityView.add_page {
    name = "animal-farms",
    category = "buildings",
    localised_name = {"city-view.animal-farms"},
    creator = BuildingOverview.make_creator("animal-farms"),
    enabler = BuildingOverview.make_enabler("animal-farms")
}

Gui.CityView.add_page {
    name = "waterwells",
    category = "buildings",
    localised_name = {"city-view.waterwells"},
    creator = BuildingOverview.make_creator("waterwells"),
    enabler = BuildingOverview.make_enabler("waterwells")
}

Gui.CityView.add_page {
    name = "salt-ponds",
    category = "buildings",
    localised_name = {"city-view.salt-ponds"},
    creator = BuildingOverview.make_creator("salt-ponds"),
    enabler = BuildingOverview.make_enabler("salt-ponds")
}

Gui.CityView.add_page {
    name = "composters",
    category = "buildings",
    localised_name = {"city-view.composters"},
    creator = BuildingOverview.make_creator("composters"),
    enabler = BuildingOverview.make_enabler("composters")
}

Gui.CityView.add_page {
    name = "fertilization-stations",
    category = "buildings",
    localised_name = {"city-view.fertilization-stations"},
    creator = BuildingOverview.make_creator("fertilization-stations"),
    enabler = BuildingOverview.make_enabler("fertilization-stations")
}

Gui.CityView.add_page {
    name = "pruning-stations",
    category = "buildings",
    localised_name = {"city-view.pruning-stations"},
    creator = BuildingOverview.make_creator("pruning-stations"),
    enabler = BuildingOverview.make_enabler("pruning-stations")
}
