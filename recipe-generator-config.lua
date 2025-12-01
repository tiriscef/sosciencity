Tirislib.RecipeGenerator.add_themes {
    agriculture = {
        [0] = {
            {type = "fluid", name = "water", amount = 500}
        },
        [1] = {
            {type = "item", name = "humus", amount = 10},
            {type = "fluid", name = "water", amount = 500}
        }
    },
    battery = {
        [2] = {{type = "item", name = "battery", amount = 1}}
    },
    boring = {
        [0] = {
            {type = "item", name = "burner-mining-drill", amount = 1}
        },
        [2] = {
            {type = "item", name = "electric-mining-drill", amount = 1}
        }
    },
    breed_birds = {
        [0] = {
            {type = "item", name = "bird-food", amount = 1},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_carnivores = {
        [0] = {
            {type = "item", name = "carnivore-food", amount = 1},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_fish = {
        [0] = {
            {type = "item", name = "fish-food", amount = 1},
            {type = "fluid", name = "water", amount = 50}
        }
    },
    breed_herbivores = {
        [0] = {
            {type = "item", name = "herbivore-food", amount = 1},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_omnivores = {
        [0] = {
            {type = "item", name = "herbivore-food", amount = 2. / 3},
            {type = "item", name = "carnivore-food", amount = 1. / 3},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_water_carnivores = {
        [0] = {
            {type = "item", name = "carnivore-food", amount = 2. / 3},
            {type = "item", name = "fish-food", amount = 1. / 3},
            {type = "fluid", name = "water", amount = 50}
        }
    },
    breed_water_herbivores = {
        [0] = {
            {type = "item", name = "herbivore-food", amount = 2. / 3},
            {type = "item", name = "fish-food", amount = 1. / 3},
            {type = "fluid", name = "water", amount = 50}
        }
    },
    breed_water_omnivores = {
        [0] = {
            {type = "item", name = "herbivore-food", amount = 1. / 3},
            {type = "item", name = "carnivore-food", amount = 1. / 3},
            {type = "item", name = "fish-food", amount = 1. / 3},
            {type = "fluid", name = "water", amount = 50}
        }
    },
    brick = {
        [0] = {{type = "item", name = "stone-brick", amount = 1}}
    },
    can = {
        [0] = {{type = "item", name = "iron-plate", amount = 1}}
    },
    casing = {
        [0] = {{type = "item", name = "iron-plate", amount = 2}}
    },
    ceramic = {
        [0] = {{type = "item", name = "stone-brick", amount = 1}}
    },
    chest = {
        [0] = {{type = "item", name = "wooden-chest", amount = 1}},
        [1] = {{type = "item", name = "iron-chest", amount = 1}},
        [2] = {{type = "item", name = "steel-chest", amount = 1}}
    },
    cooling_fluid = {
        [0] = {{type = "fluid", name = "petroleum-gas", amount = 1}}
    },
    electronics = {
        [0] = {{type = "item", name = "copper-cable", amount = 2}},
        [1] = {{type = "item", name = "electronic-circuit", amount = 1}},
        [2] = {{type = "item", name = "electronic-circuit", amount = 1}},
        [3] = {{type = "item", name = "electronic-circuit", amount = 1}},
        [4] = {{type = "item", name = "advanced-circuit", amount = 1}},
        [5] = {{type = "item", name = "advanced-circuit", amount = 1}},
        [6] = {{type = "item", name = "processing-unit ", amount = 1}},
        [7] = {{type = "item", name = "processing-unit ", amount = 1}}
    },
    fabric = {
        [0] = {
            {type = "item", name = "cloth", amount = 1},
            {type = "item", name = "yarn", amount = 0.1}
        }
    },
    framework = {
        [0] = {
            {type = "item", name = "iron-stick", amount = 1}
        }
    },
    furnace = {
        [0] = {{type = "item", name = "stone-furnace", amount = 1}},
        [2] = {{type = "item", name = "steel-furnace", amount = 1}},
        [4] = {{type = "item", name = "electric-furnace", amount = 1}}
    },
    gear_wheel = {
        [0] = {
            {type = "item", name = "iron-gear-wheel", amount = 1}
        }
    },
    genetic_neogenesis = {
        [0] = {
            {type = "item", name = "mitochondria", amount = 1},
            {type = "item", name = "nucleobases", amount = 1},
            {type = "item", name = "phospholipids", amount = 1},
            {type = "item", name = "synthetase", amount = 1},
            {type = "item", name = "thermostable-dna-polymerase", amount = 1},
            {type = "item", name = "proteins", amount = 1},
            {type = "item", name = "glass-instruments", amount = 1},
            {type = "item", name = "agarose", amount = 2}
        }
    },
    glass = {
        [0] = {{type = "item", name = "glass", amount = 1}}
    },
    --- for a lack of a better term. like... the stuff that would be smelted to get glass.
    --- vanilla doesn't really have something like that and a lot of mods invent different versions for it
    glass_educt = {
        [0] = {{type = "item", name = "stone", amount = 1}}
    },
    grating = {
        [0] = {{type = "item", name = "iron-stick", amount = 1}}
    },
    gravel = {
        [0] = {{type = "item", name = "stone", amount = 1}}
    },
    gun_turret = {
        [0] = {{type = "item", name = "gun-turret", amount = 1}}
    },
    handle = {
        [0] = {{type = "item", name = "iron-stick", amount = 1}}
    },
    hydrogen = {
        [0] = {{type = "fluid", name = "steam", amount = 1}}
    },
    iron_ore = {
        [0] = {{type = "item", name = "iron-ore", amount = 1}}
    },
    lamp = {
        [0] = {
            {type = "item", name = "small-lamp", amount = 1}
        }
    },
    machine = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 3}
        },
        [1] = {
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 5}
        },
        [2] = {
            {type = "item", name = "steel-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        }
    },
    mechanism = {
        [0] = {
            {type = "item", name = "iron-stick", amount = 1},
            {type = "item", name = "iron-gear-wheel", amount = 1}
        }
    },
    paper_production = {
        [0] = {
            {type = "fluid", name = "steam", amount = 200},
            {type = "fluid", name = "sulfuric-acid", amount = 20}
        }
    },
    phosphorous_source = {
        [0] = {
            {type = "item", name = "stone", amount = 1}
        }
    },
    piping = {
        [0] = {
            {type = "item", name = "pipe", amount = 1}
        }
    },
    plastic = {
        [2] = {
            {type = "item", name = "plastic-bar", amount = 1}
        }
    },
    plating = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 1}
        },
        [2] = {
            {type = "item", name = "steel-plate", amount = 1}
        }
    },
    plating2 = {
        [0] = {
            {type = "item", name = "copper-plate", amount = 1}
        }
    },
    pump = {
        [2] = {
            {type = "item", name = "pump", amount = 1}
        }
    },
    robo_parts = {
        [3] = {
            {type = "item", name = "flying-robot-frame", amount = 1}
        }
    },
    screw_material = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 2}
        },
        [1] = {
            {type = "item", name = "copper-plate", amount = 2}
        },
        [70] = {
            {type = "item", name = "steel-plate", amount = 2}
        }
    },
    soil = {
        [0] = {
            {type = "item", name = "humus", amount = 1}
        }
    },
    stone = {
        [0] = {
            {type = "item", name = "stone", amount = 1}
        }
    },
    tank = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "pipe", amount = 5}
        },
        [2] = {
            {type = "item", name = "storage-tank", amount = 1}
        }
    },
    water = {
        [0] = {{type = "fluid", name = "water", amount = 1}}
    },
    wiring = {
        [0] = {
            {type = "item", name = "copper-cable", amount = 2}
        }
    },
    --- everything that is built to accommodate huwans
    building = {
        [0] = {
            {type = "item", name = "lumber", amount = 10},
            {type = "item", name = "iron-plate", amount = 15},
            {type = "item", name = "glass", amount = 2}
        },
        [1] = {
            {type = "item", name = "lumber", amount = 10},
            {type = "item", name = "stone-brick", amount = 15},
            {type = "item", name = "window", amount = 2}
        },
        [2] = {
            {type = "item", name = "lumber", amount = 10},
            {type = "item", name = "stone-wall", amount = 4},
            {type = "item", name = "window", amount = 2}
        },
        [3] = {
            {type = "item", name = "lumber", amount = 10},
            {type = "item", name = "stone-wall", amount = 5},
            {type = "item", name = "mineral-wool", amount = 2},
            {type = "item", name = "window", amount = 2}
        },
        [4] = {
            {type = "item", name = "steel-plate", amount = 6},
            {type = "item", name = "concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2},
            {type = "item", name = "window", amount = 2}
        },
        [5] = {
            {type = "item", name = "steel-plate", amount = 6},
            {type = "item", name = "concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2},
            {type = "item", name = "window", amount = 2}
        },
        [6] = {
            {type = "item", name = "steel-plate", amount = 8},
            {type = "item", name = "refined-concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2},
            {type = "item", name = "window", amount = 2}
        },
        [7] = {
            {type = "item", name = "steel-plate", amount = 8},
            {type = "item", name = "refined-concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2},
            {type = "item", name = "window", amount = 2}
        }
    },
    cheap_building = {
        [0] = {
            {type = "item", name = "lumber", amount = 8},
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "glass", amount = 1}
        },
        [1] = {
            {type = "item", name = "lumber", amount = 8},
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "window", amount = 1}
        },
        [2] = {
            {type = "item", name = "lumber", amount = 8},
            {type = "item", name = "stone-wall", amount = 3},
            {type = "item", name = "window", amount = 1}
        },
        [3] = {
            {type = "item", name = "lumber", amount = 15},
            {type = "item", name = "stone-wall", amount = 3},
            {type = "item", name = "mineral-wool", amount = 1},
            {type = "item", name = "window", amount = 1}
        },
        [4] = {
            {type = "item", name = "iron-plate", amount = 2},
            {type = "item", name = "concrete", amount = 4},
            {type = "item", name = "mineral-wool", amount = 1},
            {type = "item", name = "window", amount = 1}
        },
        [5] = {
            {type = "item", name = "iron-plate", amount = 2},
            {type = "item", name = "concrete", amount = 4},
            {type = "item", name = "mineral-wool", amount = 1},
            {type = "item", name = "window", amount = 1}
        },
        [6] = {
            {type = "item", name = "steel-plate", amount = 2},
            {type = "item", name = "refined-concrete", amount = 5},
            {type = "item", name = "mineral-wool", amount = 1},
            {type = "item", name = "window", amount = 1}
        },
        [7] = {
            {type = "item", name = "steel-plate", amount = 2},
            {type = "item", name = "refined-concrete", amount = 5},
            {type = "item", name = "mineral-wool", amount = 1},
            {type = "item", name = "window", amount = 1}
        }
    },
    pompous_building = {
        [0] = {
            {type = "item", name = "lumber", amount = 15},
            {type = "item", name = "iron-plate", amount = 20},
            {type = "item", name = "stone-brick", amount = 10},
            {type = "item", name = "glass", amount = 5}
        },
        [1] = {
            {type = "item", name = "lumber", amount = 15},
            {type = "item", name = "iron-plate", amount = 20},
            {type = "item", name = "stone-brick", amount = 10},
            {type = "item", name = "window", amount = 5}
        },
        [2] = {
            {type = "item", name = "lumber", amount = 15},
            {type = "item", name = "steel-plate", amount = 5},
            {type = "item", name = "stone-wall", amount = 10},
            {type = "item", name = "window", amount = 5}
        },
        [3] = {
            {type = "item", name = "lumber", amount = 15},
            {type = "item", name = "steel-plate", amount = 5},
            {type = "item", name = "stone-wall", amount = 10},
            {type = "item", name = "mineral-wool", amount = 4},
            {type = "item", name = "window", amount = 5}
        },
        [4] = {
            {type = "item", name = "lumber", amount = 20},
            {type = "item", name = "steel-plate", amount = 6},
            {type = "item", name = "concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 4},
            {type = "item", name = "window", amount = 5}
        },
        [5] = {
            {type = "item", name = "lumber", amount = 20},
            {type = "item", name = "steel-plate", amount = 6},
            {type = "item", name = "concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 4},
            {type = "item", name = "window", amount = 5}
        },
        [6] = {
            {type = "item", name = "lumber", amount = 25},
            {type = "item", name = "steel-plate", amount = 8},
            {type = "item", name = "refined-concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 5},
            {type = "item", name = "window", amount = 5}
        },
        [7] = {
            {type = "item", name = "lumber", amount = 25},
            {type = "item", name = "steel-plate", amount = 8},
            {type = "item", name = "refined-concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 5},
            {type = "item", name = "window", amount = 5}
        }
    },
    furnishing = {
        [0] = {},
        [1] = {
            {type = "item", name = "furniture", amount = 0.5}
        },
        [2] = {
            {type = "item", name = "furniture", amount = 1.5}
        },
        [3] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 3},
        },
        [4] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 4},
        },
        [5] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 4},
            {type = "item", name = "curtain", amount = 1},
            {type = "item", name = "stove", amount = 1 / 2}
        },
        [6] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 5},
            {type = "item", name = "curtain", amount = 1},
            {type = "item", name = "carpet", amount = 1},
            {type = "item", name = "air-conditioner", amount = 1 / 3},
            {type = "item", name = "stove", amount = 1 / 2}
        },
        [7] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 5},
            {type = "item", name = "curtain", amount = 1},
            {type = "item", name = "carpet", amount = 1},
            {type = "item", name = "air-conditioner", amount = 1 / 3},
            {type = "item", name = "stove", amount = 1 / 2},
            {type = "item", name = "refrigerator", amount = 1 / 2}
        },
        [8] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 6},
            {type = "item", name = "curtain", amount = 1},
            {type = "item", name = "carpet", amount = 1},
            {type = "item", name = "air-conditioner", amount = 0.5},
            {type = "item", name = "stove", amount = 1 / 2},
            {type = "item", name = "refrigerator", amount = 1 / 2}
        },
        [9] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 7},
            {type = "item", name = "curtain", amount = 1},
            {type = "item", name = "carpet", amount = 1},
            {type = "item", name = "air-conditioner", amount = 2 / 3},
            {type = "item", name = "stove", amount = 1 / 2},
            {type = "item", name = "refrigerator", amount = 1 / 2}
        },
        [10] = {
            {type = "item", name = "bed", amount = 3},
            {type = "item", name = "furniture", amount = 8},
            {type = "item", name = "curtain", amount = 1},
            {type = "item", name = "carpet", amount = 1},
            {type = "item", name = "air-conditioner", amount = 1},
            {type = "item", name = "stove", amount = 1 / 2},
            {type = "item", name = "refrigerator", amount = 1 / 2}
        }
    },
    simple_furnishing = {
        [0] = {},
        [1] = {
            {type = "item", name = "furniture", amount = 1 / 2}
        },
        [2] = {
            {type = "item", name = "furniture", amount = 1}
        },
        [3] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 1.5}
        },
        [4] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 2},
        },
        [5] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 2.5}
        },
        [6] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 2.5},
            {type = "item", name = "air-conditioner", amount = 1 / 5},
            {type = "item", name = "stove", amount = 1 / 4}
        },
        [7] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 3},
            {type = "item", name = "air-conditioner", amount = 1 / 5},
            {type = "item", name = "stove", amount = 1 / 4}
        },
        [8] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 3},
            {type = "item", name = "air-conditioner", amount = 1 / 4},
            {type = "item", name = "stove", amount = 1 / 4},
            {type = "item", name = "refrigerator", amount = 1 / 4}
        },
        [9] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 3},
            {type = "item", name = "air-conditioner", amount = 1 / 3},
            {type = "item", name = "stove", amount = 1 / 4},
            {type = "item", name = "refrigerator", amount = 1 / 4},
            {type = "item", name = "sofa", amount = 1 / 4}
        },
        [10] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "furniture", amount = 4},
            {type = "item", name = "air-conditioner", amount = 1 / 2},
            {type = "item", name = "stove", amount = 1 / 4},
            {type = "item", name = "refrigerator", amount = 1 / 4},
            {type = "item", name = "sofa", amount = 1 / 4}
        }
    },
    furnishing_decorated = {
        [0] = {
            {type = "item", name = "painting", amount = 1}
        }
    },
    housing_green = {
        [0] = {
            {type = "item", name = "phytofall-blossom", amount = 1}
        }
    },
    housing_technical = {
        [0] = {
            {type = "item", name = "electronic-circuit", amount = 1}
        }
    },
    housing_sheltered = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 1}
        },
        [2] = {
            {type = "item", name = "steel-plate", amount = 1},
            {type = "item", name = "concrete", amount = 1}
        }
    },
    tall_building_structure = {
        [0] = {
            --{type = "item", name = "iron-stick", amount = 1}
        }
    }
}

Tirislib.RecipeGenerator.add_result_themes {
    sediment = {
        [0] = {
            {type = "item", name = "leafage", amount = 1, probability = 0.2},
            {type = "item", name = "stone", amount = 1, probability = 0.3},
            {type = "item", name = "wood", amount = 1, probability = 0.2},
            {type = "item", name = "queen-algae", amount = 1, probability = 0.2}
        }
    }
}

Tirislib.RecipeGenerator.add_category_aliases {
    dissolving = "crafting-with-fluid",
    drying = "sosciencity-drying-unit",
    filtration = "chemistry",
    fluid_mixing = "chemistry",
    food_processing = "sosciencity-orchid-food-processing",
    handcrafting = "sosciencity-handcrafting",
    milling = "crafting",
    mixing = "crafting",
    plant_oil_extraction = "crafting-with-fluid"
}

Tirislib.RecipeGenerator.add_item_aliases {
    glass = "glass",
    nickel_catalyst = "iron-plate"
}
