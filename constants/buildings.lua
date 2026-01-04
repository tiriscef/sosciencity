local DiseaseCategory = require("enums.disease-category")
local EK = require("enums.entry-key")
local SubentityType = require("enums.subentity-type")
local Type = require("enums.type")

local Time = require("constants.time")
local Housing = require("constants.housing")

--- Defines the general custom properties for various entities.
local Building = {}

--- Definition table for a Custom Building
--- @class CustomBuildingDefinition
--- @field type Type
--- @field range integer|string tiles in every direction or 'global'
--- @field power_usage number in kW
--- @field speed number in 1/tick, depends on type
--- @field workforce WorkforceDefinition

--- Definition table for a building's workforce
--- @class WorkforceDefinition
--- @field count integer Count of workers needed
--- @field castes Type[] array of casteIDs that can work in this building
--- @field disease_category DiseaseCategory the category of diseases that this work can cause
--- @field disease_frequency number the frequency with which diseases are caused by this work (as progress per worker per tick)

--- The standard range for connections where the huwans are supposed to walk to the entity.
local range_by_foot = 50

--- Values of various custom behaviours I implemented for the Custom Buildings.<br>
--- **range:** number (tiles in every direction) or "global"<br>
--- **power_usage:** number (kW)<br>
--- **speed:** number (1/tick)<br>
--- **workforce:** WorkforceDefinition<br>
--- I'm defining the disease_frequency as progress per tick *when fully staffed*. The postprocessing divides the value by the count.
Building.values = {
    ["algae-farm"] = {
        type = Type.automatic_farm,
        accepts_plant_care = false
    },
    ["aquafarm"] = {
        type = Type.animal_farm,
        range = 50
    },
    ["arboretum"] = {
        type = Type.farm,
        open_environment = true,
        accepts_plant_care = true
    },
    ["architectural-office"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 8,
            castes = {Type.clockwork, Type.gleam, Type.foundry},
            disease_category = DiseaseCategory.office_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["atelier"] = {
        type = Type.manufactory,
        workforce = {
            count = 8,
            castes = {Type.ember},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["bloomhouse"] = {
        type = Type.farm,
        workforce = {
            count = 2,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        },
        accepts_plant_care = true
    },
    ["city-combinator"] = {
        type = Type.city_combinator
    },
    ["clockwork-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.clockwork},
            disease_category = DiseaseCategory.hard_work,
            disease_frequency = 0.2 / Time.minute
        }
    },
    ["clockwork-mines"] = {
        type = Type.manufactory,
        workforce = {
            count = 10,
            castes = {Type.clockwork},
            disease_category = DiseaseCategory.hard_work,
            disease_frequency = 0.2 / Time.minute
        }
    },
    ["clockwork-quarry"] = {
        type = Type.manufactory,
        workforce = {
            count = 10,
            castes = {Type.clockwork},
            disease_category = DiseaseCategory.hard_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["composting-silo"] = {
        type = Type.composter,
        capacity = 5000
    },
    ["composting-silo-output"] = {
        type = Type.composter_output,
        range = 5
    },
    ["cold-storage-warehouse"] = {
        type = Type.cold_storage,
        power_usage = 300,
        spoil_slowdown = 0.9
    },
    ["egg-collecting-station"] = {
        type = Type.egg_collector,
        range = 40
    },
    ["ember-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.ember},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["farm"] = {
        type = Type.farm,
        open_environment = true,
        accepts_plant_care = true
    },
    ["fertilization-station"] = {
        type = Type.fertilization_station,
        range = 30,
        speed = 60 / Time.minute,
        humus_capacity = 1000
    },
    ["fishing-hut"] = {
        type = Type.fishery,
        range = 30,
        water_tiles = 300,
        workforce = {
            count = 4,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.fishing_hut,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["foundry-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.foundry},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["gene-clinic"] = {
        type = Type.gene_clinic,
        range = 7
    },
    ["gleam-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.gleam},
            disease_category = DiseaseCategory.office_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["greenhouse"] = {
        type = Type.farm,
        accepts_plant_care = true
    },
    ["groundwater-pump"] = {
        type = Type.waterwell,
        range = 30
    },
    ["gunfire-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.gunfire},
            disease_category = DiseaseCategory.hard_work,
            disease_frequency = 0.2 / Time.minute
        },
        subentities = {
            SubentityType.turret_gunfire_hq1,
            SubentityType.turret_gunfire_hq2,
            SubentityType.turret_gunfire_hq3,
            SubentityType.turret_gunfire_hq4
        },
        subentity_offsets = {
            [SubentityType.turret_gunfire_hq1] = {x = 3.9, y = 0.4},
            [SubentityType.turret_gunfire_hq2] = {x = 3.9, y = -5.25},
            [SubentityType.turret_gunfire_hq3] = {x = -3.9, y = 0.4},
            [SubentityType.turret_gunfire_hq4] = {x = -3.9, y = -5.25}
        }
    },
    ["hospital"] = {
        type = Type.hospital,
        range = 150,
        speed = 2 / Time.second,
        workforce = {
            count = 10,
            castes = {Type.plasma},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        },
        power_usage = 100
    },
    ["hunting-hut"] = {
        type = Type.hunting_hut,
        range = 30,
        tree_count = 100,
        workforce = {
            count = 4,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.hunting_hut,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["huwanities-faculty"] = {
        type = Type.caste_education_building,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.ember},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.01 / Time.minute
        },
        result_caste = Type.gleam
    },
    ["industrial-animal-farm"] = {
        type = Type.animal_farm,
        range = 50
    },
    ["intensive-care-unit"] = {
        type = Type.intensive_care_unit,
        range = 7
    },
    ["kitchen-for-all"] = {
        type = Type.kitchen_for_all,
        range = range_by_foot,
        inhabitant_count = 20
    },
    ["market-hall"] = {
        type = Type.market,
        range = range_by_foot
    },
    ["medbay"] = {
        type = Type.improvised_hospital,
        range = 50,
        speed = 0.4 / Time.second,
        workforce = {
            count = 5,
            castes = {Type.orchid, Type.plasma},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        },
        power_usage = 50
    },
    ["medical-school"] = {
        type = Type.caste_education_building,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.01 / Time.minute
        },
        result_caste = Type.plasma
    },
    ["military-school"] = {
        type = Type.caste_education_building,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.ember, Type.orchid, Type.clockwork},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.01 / Time.minute
        },
        result_caste = Type.gunfire
    },
    ["mushroom-farm"] = {
        type = Type.automatic_farm,
        accepts_plant_care = false
    },
    ["natural-sciences-faculty"] = {
        type = Type.caste_education_building,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.clockwork},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.01 / Time.minute
        },
        result_caste = Type.foundry
    },
    ["nightclub"] = {
        type = Type.nightclub,
        range = range_by_foot,
        power_usage = 100
    },
    ["orangery"] = {
        type = Type.farm,
        accepts_plant_care = true
    },
    ["orchid-food-factory"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 10,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["orchid-hq"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 20,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.05 / Time.minute
        }
    },
    ["orchid-paradise"] = {
        type = Type.manufactory,
        range = range_by_foot,
        workforce = {
            count = 4,
            castes = {Type.orchid},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.05 / Time.minute
        }
    },
    ["pharmacy"] = {
        type = Type.pharmacy,
        range = 15
    },
    ["psych-ward"] = {
        type = Type.psych_ward,
        range = 7
    },
    ["robo-pruning-station"] = {
        type = Type.pruning_station,
        speed = 120 / Time.minute,
        power_usage = 150
    },
    ["salt-pond"] = {
        type = Type.salt_pond,
        range = 10.5,
        water_tiles = 45
    },
    ["storage-cellar"] = {
        type = Type.cold_storage,
        spoil_slowdown = 0.6
    },
    ["trash-site"] = {
        type = Type.dumpster,
        range = range_by_foot
    },
    ["upbringing-station"] = {
        type = Type.upbringing_station,
        power_usage = 150,
        power_drain = 5,
        capacity = 20
    },
    ["waste-dump"] = {
        type = Type.waste_dump,
        capacity = 200000
    },
    ["water-tower"] = {
        type = Type.water_distributer,
        range = 70
    },
    ["zeppelin-port"] = {
        type = Type.immigration_port,
        interval = 1000,
        random_interval = 1000,
        capacity = 100,
        materials = {
            ["rope"] = 20
        }
    },
    ["test-dumpster"] = {
        type = Type.dumpster,
        range = 42
    },
    ["test-market"] = {
        type = Type.market,
        range = 42
    },
    ["test-hospital"] = {
        type = Type.hospital,
        range = 42,
        speed = 20 / Time.second,
        workforce = {
            count = 20,
            castes = {Type.plasma},
            disease_category = DiseaseCategory.moderate_work,
            disease_frequency = 0.1 / Time.minute
        },
        power_usage = 50
    },
    ["test-psych-ward"] = {
        type = Type.psych_ward,
        range = 42,
        power_usage = 50
    },
    ["test-water-distributer"] = {
        type = Type.water_distributer,
        range = 42
    },
    ["test-fishery"] = {
        type = Type.fishery,
        range = 30,
        water_tiles = 300,
        workforce = {
            count = 20,
            castes = {Type.clockwork},
            disease_category = DiseaseCategory.fishing_hut,
            disease_frequency = 0.1 / Time.minute
        }
    },
    ["test-composter"] = {
        type = Type.composter,
        capacity = 5000
    },
    ["test-compost-output"] = {
        type = Type.composter_output,
        range = 5
    },
    ["test-pharmacy"] = {
        type = Type.pharmacy,
        range = "global"
    },
    ["test-upbringing-station"] = {
        type = Type.upbringing_station,
        power_usage = 100,
        capacity = 40
    },
    ["test-egg-collector"] = {
        type = Type.egg_collector,
        range = 42
    }
}
local buildings = Building.values

-- values postprocessing
for _, details in pairs(Building.values) do
    -- convert power usages to J / tick
    if details.power_usage then
        details.power_usage = details.power_usage * 1000 / Time.second
    end

    if details.workforce then
        details.workforce.disease_frequency = details.workforce.disease_frequency / details.workforce.count
    end
end

local houses = Housing.values
local housing_details = {
    range = range_by_foot, -- range 'by foot'
    power_usage = 1 -- Will be set dynamically, depending on the number of inhabitants. This dummy value will assure the eei is spawned upon placement.
}

--- Returns the Custom Building specification of this entry or an empty table if this entry isn't an actual Custom Building.
function Building.get(entry)
    local name = entry[EK.name]
    return buildings[name] or (houses[name] and housing_details) or {}
end

return Building
