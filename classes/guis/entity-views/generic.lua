--- Details view and building overview registrations for fully generic building types.

local Type = require("enums.type")

local Gui = Gui

local generic_spec = {creater = Gui.DetailsView.create_general, updater = Gui.DetailsView.update_general}
Gui.DetailsView.register_type(Type.mining_drill, generic_spec)
Gui.DetailsView.register_type(Type.assembling_machine, generic_spec)
Gui.DetailsView.register_type(Type.furnace, generic_spec)
Gui.DetailsView.register_type(Type.rocket_silo, generic_spec)
Gui.DetailsView.register_type(Type.caste_education_building, generic_spec)
Gui.DetailsView.register_type(Type.composter_output, generic_spec)
Gui.DetailsView.register_type(Type.egg_collector, generic_spec)
Gui.DetailsView.register_type(Type.pharmacy, generic_spec)
Gui.DetailsView.register_type(Type.psych_ward, generic_spec)
Gui.DetailsView.register_type(Type.manufactory, generic_spec)
Gui.DetailsView.register_type(Type.social_observatory, generic_spec)
Gui.DetailsView.register_type(Type.nightclub, generic_spec)
Gui.DetailsView.register_type(Type.animal_farm, generic_spec)
Gui.DetailsView.register_type(Type.fishery, generic_spec)
Gui.DetailsView.register_type(Type.hunting_hut, generic_spec)

local BuildingOverview = Gui.BuildingOverview
local generic_overview_creator = BuildingOverview.generic_stats_creator

BuildingOverview.register_type("nightclubs", {types = {Type.nightclub}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("egg-collectors", {types = {Type.egg_collector}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("manufactories", {types = {Type.manufactory}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("social-observatories", {types = {Type.social_observatory}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("caste-education-buildings", {types = {Type.caste_education_building}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("animal-farms", {types = {Type.animal_farm}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("fisheries", {types = {Type.fishery}, layout = "list", stats_creator = generic_overview_creator})
BuildingOverview.register_type("hunting-huts", {types = {Type.hunting_hut}, layout = "list", stats_creator = generic_overview_creator})
