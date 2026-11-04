local Biology = require("constants.biology")
local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << items >>

local flora_items = {
    {
        name = "leafage",
        sprite_variations = {name = "leafage", count = 3, include_icon = true},
        fuel_value = "500kJ",
        fuel_categories = {"chemical"}
    },
    {
        name = "hardcorn-punk",
        sprite_variations = {name = "hardcorn-punk-pile", count = 3}
    },
    {
        name = "plemnemm-cotton",
        sprite_variations = {name = "plemnemm-cotton-pile", count = 4}
    },
    {
        name = "tiriscefing-willow-wood",
        wood = true
    },
    {
        name = "cherry-wood",
        wood = true
    },
    {
        name = "olive-wood",
        wood = true
    },
    {
        name = "ortrot-wood",
        wood = true
    },
    {
        name = "avocado-wood",
        wood = true
    },
    {
        name = "zetorn-wood",
        wood = true
    },
    {
        name = "sugar-cane",
        sprite_variations = {name = "sugar-cane", count = 3, include_icon = true}
    },
    {
        name = "gingil-hemp",
        sprite_variations = {name = "gingil-hemp-pile", count = 3}
    },
    {
        name = "wild-flowers",
        sprite_variations = {name = "wild-flowers", count = 5, include_icon = true}
    },
    {
        name = "necrofall",
        sprite_variations = {name = "necrofall-pile", count = 4}
    },
    {
        name = "phytofall-blossom",
        sprite_variations = {name = "phytofall-blossom-pile", count = 4}
    },
    {
        name = "chromafall",
        sprite_variations = {name = "chromafall-pile", count = 4}
    },
    -- chronofall is on hold until perfume is in scope (after the alpha)
    -- {
    --     name = "chronofall",
    --     sprite_variations = {name = "chronofall-pile", count = 4}
    -- },
    {
        name = "heliofall",
        sprite_variations = {name = "heliofall-pile", count = 4}
    },
    {
        name = "ignivern",
        sprite_variations = {name = "ignivern", count = 3, include_icon = true}
    }
}

--- names of the flora items that are wood, they get a lumber recipe further down
local wood_items = {}

for _, item in pairs(flora_items) do
    if item.wood then
        item.fuel_value = "2MJ"
        item.fuel_categories = {"chemical"}
        item.wood = nil
        wood_items[#wood_items + 1] = item.name
    end
end

Tirislib.Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

Sosciencity.make_existing_item_food("ignivern")

---------------------------------------------------------------------------------------------------
-- << farming recipes >>

local function add_general_growing_attributes(details, plant_details)
    if plant_details.required_module then
        Tirislib.Locales.append(
            details.localised_description,
            "\n\n",
            {
                "sosciencity.module-required",
                Tirislib.Locales.display_item_stack_datastage(plant_details.required_module, 1)
            }
        )
    end
end

local function create_annual_recipe(details)
    local product_name = details.product
    local mult = details.output_multiplier or 1
    details.product = nil
    details.output_multiplier = nil

    local product = Tirislib.Item.get_by_name(product_name)
    local plant_details = Biology.flora[product_name]
    local energy_required = 200 / plant_details.growth_coefficient

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        name = "farming-annual-" .. product_name,
        results = {
            {type = "item", name = product_name, amount_min = 0, amount_max = 100 * mult, product = true},
            {type = "item", name = product_name, amount_min = 0, amount_max = 100 * mult},
            {type = "item", name = "leafage",    amount_min = 1, amount_max = 40}
        },
        ingredients = {
            {type = "item", name = product_name, amount = 10 * mult}
        },
        energy_required = energy_required,
        localised_name = {"recipe-name.annual", product:get_localised_name()},
        localised_description = {"recipe-description.annual", product:get_localised_name()},
        category = "sosciencity-farming-annual",
        subgroup = "sosciencity-flora",
        icon = product.icon,
        icon_size = 64,
        unlock = "open-environment-farming",
        auto_recycle = false
    })

    add_general_growing_attributes(details, plant_details)
    return Tirislib.RecipeGenerator.create(details):add_category_layer("farming")
end

local function create_perennial_recipe(details)
    local product_name = details.product
    local mult = details.output_multiplier or 1
    details.product = nil
    details.output_multiplier = nil

    local product = Tirislib.Item.get_by_name(product_name)
    local plant_details = Biology.flora[product_name]

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        name = "farming-perennial-" .. product_name,
        results = {
            {type = "item", name = product_name, amount_min = 5 * mult, amount_max = 10 * mult, product = true},
            {type = "item", name = "leafage",    amount = 1}
        },
        energy_required = 25,
        localised_name = {"recipe-name.perennial", product:get_localised_name()},
        localised_description = {"recipe-description.perennial", product:get_localised_name()},
        category = "sosciencity-farming-perennial",
        subgroup = "sosciencity-flora-perennial",
        icon = product.icon,
        icon_size = 64,
        unlock = "open-environment-farming",
        auto_recycle = false
    })

    add_general_growing_attributes(details, plant_details)
    return Tirislib.RecipeGenerator.create(details):add_category_layer("farming")
end

local function create_perennial_crop_recipe(details)
    local product_name = details.product
    local mult = details.output_multiplier or 1
    details.product = nil
    details.output_multiplier = nil

    local product = Tirislib.Item.get_by_name(product_name)
    local plant_details = Biology.flora[product_name]

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        name = "farming-perennial-crop-" .. product_name,
        results = {
            {type = "item", name = product_name, amount_min = 5 * mult, amount_max = 10 * mult, product = true},
            {type = "item", name = "leafage",    amount = 1}
        },
        energy_required = 25,
        localised_name = {"recipe-name.perennial-crop", product:get_localised_name()},
        localised_description = {"recipe-description.perennial-crop", product:get_localised_name()},
        category = "sosciencity-farming-perennial-crop",
        subgroup = "sosciencity-flora",
        icon = product.icon,
        icon_size = 64,
        unlock = "open-environment-farming",
        auto_recycle = false
    })

    add_general_growing_attributes(details, plant_details)
    return Tirislib.RecipeGenerator.create(details):add_category_layer("farming")
end

local function create_annual_bloomhouse_recipe(details)
    local product_name = details.product
    local mult = details.output_multiplier or 1
    details.product = nil
    details.output_multiplier = nil

    local product = Tirislib.Item.get_by_name(product_name)
    local plant_details = Biology.flora[product_name]
    local energy_required = 200 / plant_details.growth_coefficient

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        name = "farming-annual-bloomhouse-" .. product_name,
        results = {
            {type = "item", name = product_name, amount_min = 50 * mult, amount_max = 100 * mult, product = true},
            {type = "item", name = product_name, amount_min = 50 * mult, amount_max = 100 * mult},
            {type = "item", name = "leafage",    amount_min = 1,         amount_max = 40},
            {type = "item", name = "pot",        amount_min = 19,        amount_max = 20}
        },
        ingredients = {
            {type = "item", name = product_name, amount = 10},
            {type = "item", name = "pot",        amount = 20}
        },
        energy_required = energy_required,
        localised_name = {"recipe-name.annual-bloomhouse", product:get_localised_name()},
        localised_description = {"recipe-description.annual-bloomhouse", product:get_localised_name()},
        category = "sosciencity-bloomhouse-annual",
        subgroup = "sosciencity-flora-bloomhouse",
        icon = product.icon,
        icon_size = 64,
        unlock = "indoor-growing",
        auto_recycle = false
    })

    add_general_growing_attributes(details, plant_details)
    return Tirislib.RecipeGenerator.create(details):add_category_layer("farming")
end

local function create_identification_recipe(details)
    local product_name = details.product
    details.product = nil

    local product = Tirislib.Item.get_by_name(product_name)

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        results = {
            {type = "item", name = product_name, amount = 1}
        },
        energy_required = 8,
        localised_name = {"recipe-name.flora-identification", product:get_localised_name()},
        localised_description = {"recipe-description.flora-identification", product:get_localised_name()},
        category = "sosciencity-caste-ember",
        subgroup = "sosciencity-neogenesis-recipes",
        icon = product.icon,
        icon_size = 64,
        auto_recycle = false
    })

    return Tirislib.RecipeGenerator.create(details):add_category_layer("plant-neogenesis")
end

local function create_neogenesis_recipe(details)
    local product_name = details.product
    details.product = nil

    local product = Tirislib.Item.get_by_name(product_name)

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        results = {
            {type = "item", name = product_name,       amount = 1, product = true},
            {type = "item", name = "empty-hard-drive", amount = 1, independent_probability = 0.9}
        },
        ingredients = {
            {theme = "genetic_neogenesis", amount = 1},
            {type = "item",                name = "chloroplasts", amount = 1},
            {type = "item",                name = "plant-genome", amount = 1}
        },
        energy_required = 10,
        localised_name = {"recipe-name.neogenesis", product:get_localised_name()},
        localised_description = {"recipe-description.neogenesis", product:get_localised_name()},
        category = "sosciencity-phyto-gene-lab",
        subgroup = "sosciencity-neogenesis-recipes",
        icon = product.icon,
        icon_size = 64,
        unlock = "genetic-neogenesis",
        auto_recycle = false
    })

    return Tirislib.RecipeGenerator.create(details):add_category_layer("plant-neogenesis")
end

-- apple
create_perennial_recipe {
    product = "apple",
    output_multiplier = 1.4,
    ingredients = {{type = "fluid", name = "water", amount = 75}},
    results = {{type = "item", name = "ortrot-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("apple")
}

create_neogenesis_recipe {
    product = "apple",
    unlock = "ortrot-variations"
}

-- avocado
create_perennial_recipe {
    product = "avocado",
    output_multiplier = 0.8,
    ingredients = {{type = "fluid", name = "water", amount = 150}},
    results = {{type = "item", name = "avocado-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("avocado")
}

create_neogenesis_recipe {
    product = "avocado"
}

-- bell pepper
create_annual_recipe {
    product = "bell-pepper",
    output_multiplier = 1.5,
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("bell-pepper")
}

create_neogenesis_recipe {
    product = "bell-pepper",
    unlock = "nightshades"
}

-- blue grapes
create_annual_recipe {
    product = "blue-grapes",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = "open-environment-farming"
}

-- brutal pumpkin
create_annual_recipe {
    product = "brutal-pumpkin",
    unlock = Unlocks.get_tech_name("brutal-pumpkin")
}

create_identification_recipe {
    product = "brutal-pumpkin",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 20},
        {type = "item", name = "humus",              amount = 40}
    },
    unlock = "explore-alien-flora-2"
}

-- cherry
create_perennial_recipe {
    product = "cherry",
    output_multiplier = 1.6,
    ingredients = {{type = "fluid", name = "water", amount = 75}},
    results = {{type = "item", name = "cherry-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("cherry")
}

create_neogenesis_recipe {
    product = "cherry"
}

-- chickpea
create_annual_recipe {
    product = "chickpea",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = "hummus"
}

create_neogenesis_recipe {
    product = "chickpea",
    unlock = "hummus"
}

-- chromafall
create_annual_bloomhouse_recipe {
    product = "chromafall",
    ingredients = {{type = "fluid", name = "water", amount = 200}}
}

create_identification_recipe {
    product = "chromafall",
    ingredients = {
        {type = "item", name = "wild-flowers",    amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "humus",           amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- eggplant
create_annual_recipe {
    product = "eggplant",
    output_multiplier = 1.5,
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("eggplant")
}

create_neogenesis_recipe {
    product = "eggplant",
    unlock = "nightshades"
}

-- gingil hemp
create_annual_recipe {
    product = "gingil-hemp",
    output_multiplier = 1.5
}

-- hardcorn punk
create_annual_recipe {
    product = "hardcorn-punk",
    ingredients = {{type = "fluid", name = "water", amount = 1000}},
    unlock = Unlocks.get_tech_name("hardcorn-punk")
}

create_identification_recipe {
    product = "hardcorn-punk",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 10},
        {type = "item", name = "leafage",            amount = 200}
    },
    unlock = "food-processing"
}

-- heliofall
create_annual_bloomhouse_recipe {
    product = "heliofall",
    ingredients = {{type = "fluid", name = "water", amount = 300}}
}

create_identification_recipe {
    product = "heliofall",
    ingredients = {
        {type = "item", name = "wild-flowers",    amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "humus",           amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- lemon
create_perennial_recipe {
    product = "lemon",
    output_multiplier = 1.6,
    results = {{type = "item", name = "zetorn-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("lemon")
}

create_neogenesis_recipe {
    product = "lemon",
    unlock = "zetorn-variations"
}

-- liontooth
create_annual_recipe {
    product = "liontooth",
    output_multiplier = 1.5,
    unlock = "open-environment-farming"
}

-- manok
create_annual_recipe {
    product = "manok",
    ingredients = {{type = "fluid", name = "water", amount = 1000}},
    unlock = Unlocks.get_tech_name("manok")
}

create_identification_recipe {
    product = "manok",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 10},
        {type = "item", name = "humus",              amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- necrofall
create_annual_bloomhouse_recipe {
    product = "necrofall",
    ingredients = {{type = "fluid", name = "water", amount = 200}},
    unlock = Unlocks.get_tech_name("necrofall")
}

-- olive
create_perennial_recipe {
    product = "olive",
    results = {{type = "item", name = "olive-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("olive")
}

create_neogenesis_recipe {
    product = "olive"
}

-- orange
create_perennial_recipe {
    product = "orange",
    results = {{type = "item", name = "zetorn-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("orange")
}

create_neogenesis_recipe {
    product = "orange",
    unlock = "zetorn-variations"
}

-- ortrot
create_perennial_recipe {
    product = "ortrot",
    ingredients = {{type = "fluid", name = "water", amount = 75}},
    results = {{type = "item", name = "ortrot-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("ortrot")
}

create_identification_recipe {
    product = "ortrot",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 20},
        {type = "item", name = "humus",              amount = 40}
    },
    unlock = "explore-alien-flora-2"
}

-- phytofall blossom
create_annual_bloomhouse_recipe {
    product = "phytofall-blossom",
    ingredients = {{type = "fluid", name = "water", amount = 200}}
}

create_identification_recipe {
    product = "phytofall-blossom",
    ingredients = {
        {type = "item", name = "wild-flowers",    amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "humus",           amount = 40}
    },
    unlock = "orchid-caste"
}

-- potato
create_annual_recipe {
    product = "potato",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("potato")
}

create_neogenesis_recipe {
    product = "potato",
    unlock = "nightshades"
}

-- razha bean
create_annual_recipe {
    product = "razha-bean",
    ingredients = {{type = "fluid", name = "water", amount = 1000}},
    unlock = "open-environment-farming"
}

-- sesame
create_annual_recipe {
    product = "sesame",
    ingredients = {{type = "fluid", name = "water", amount = 1000}},
    unlock = "hummus"
}

create_neogenesis_recipe {
    product = "sesame",
    unlock = "hummus"
}

-- sugar beet
create_annual_recipe {
    product = "sugar-beet",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("sugar-beet")
}

create_neogenesis_recipe {
    product = "sugar-beet"
}

-- sugar cane
create_annual_recipe {
    product = "sugar-cane",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("sugar-cane")
}

create_neogenesis_recipe {
    product = "sugar-cane"
}

-- tello
create_annual_recipe {
    product = "tello-fruit",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("tello-fruit")
}

create_identification_recipe {
    product = "tello-fruit",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 10},
        {type = "item", name = "humus",              amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- tomato
create_annual_recipe {
    product = "tomato",
    output_multiplier = 1.5,
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("tomato")
}

create_neogenesis_recipe {
    product = "tomato",
    unlock = "nightshades"
}

-- plemnemm cotton
create_annual_recipe {
    product = "plemnemm-cotton",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    output_multiplier = 2
}

-- tiriscefing willow
create_perennial_recipe {
    product = "tiriscefing-willow-wood",
    results = {{type = "item", name = "fawoxylas", amount = 5, independent_probability = 0.5}}
}

-- unnamed fruit
create_annual_recipe {
    product = "unnamed-fruit",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = "open-environment-farming"
}

-- weird berry
create_annual_recipe {
    product = "weird-berry",
    ingredients = {{type = "fluid", name = "water", amount = 500}},
    unlock = Unlocks.get_tech_name("weird-berry")
}

create_identification_recipe {
    product = "weird-berry",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 10},
        {type = "item", name = "humus",              amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- zetorn
create_perennial_recipe {
    product = "zetorn",
    results = {{type = "item", name = "zetorn-wood", amount = 1, independent_probability = 0.2}},
    unlock = Unlocks.get_tech_name("zetorn")
}

create_identification_recipe {
    product = "zetorn",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study",    amount = 10},
        {type = "item", name = "humus",              amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- ignivern
create_perennial_crop_recipe {
    product = "ignivern",
    unlock = "explore-alien-flora-1"
}

---------------------------------------------------------------------------------------------------
-- << mushroom >>

local function create_mushroom_recipe(details)
    local product_name = details.product
    local mult = details.output_multiplier or 1
    details.product = nil
    details.output_multiplier = nil

    local product = Tirislib.Item.get_by_name(product_name)
    local plant_details = Biology.flora[product_name]
    local energy_required = 30 / plant_details.growth_coefficient

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        name = "farming-mushroom-" .. product_name,
        results = {
            {type = "item", name = product_name, amount_min = 40 * mult, amount_max = 60 * mult, product = true},
            {type = "item", name = product_name, amount_min = 40 * mult, amount_max = 60 * mult}
        },
        energy_required = energy_required,
        localised_name = {"recipe-name.farm-mushroom", product:get_localised_name()},
        localised_description = {"recipe-description.annual", product:get_localised_name()},
        category = "sosciencity-mushroom-farm",
        subgroup = "sosciencity-mushrooms",
        icon = product.icon,
        icon_size = 64,
        unlock = "basic-biotechnology",
        auto_recycle = false
    })

    add_general_growing_attributes(details, plant_details)
    return Tirislib.RecipeGenerator.create(details):add_category_layer("farming")
end

-- fawoxylas
create_mushroom_recipe {
    product = "fawoxylas",
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 30}
    },
    unlock = "mushroom-farming"
}

-- pocelial
create_mushroom_recipe {
    product = "pocelial",
    ingredients = {
        {type = "fluid", name = "water", amount = 300},
        {type = "item",  name = "humus", amount = 20}
    },
    unlock = "mushroom-farming"
}

-- red hatty
create_mushroom_recipe {
    product = "red-hatty",
    ingredients = {
        {type = "fluid", name = "water", amount = 300},
        {type = "item",  name = "humus", amount = 20}
    },
    unlock = "mushroom-farming"
}

-- birdsnake
create_mushroom_recipe {
    product = "birdsnake",
    ingredients = {
        {type = "fluid",  name = "water", amount = 300},
        {type = "item",   name = "humus", amount = 10},
        {theme = "stone", amount = 10}
    },
    unlock = "mushroom-farming"
}

---------------------------------------------------------------------------------------------------
-- << algae >>

local function create_algae_recipe(details)
    local product_name = details.product
    local mult = details.output_multiplier or 1
    details.product = nil
    details.output_multiplier = nil

    local product = Tirislib.Item.get_by_name(product_name)
    local plant_details = Biology.flora[product_name]
    local energy_required = 120 / plant_details.growth_coefficient

    Tirislib.RecipeGenerator.merge_prototypes(details, {
        name = "farming-algae-" .. product_name,
        results = {
            {type = "item", name = product_name, amount_min = 20 * mult, amount_max = 40 * mult, product = true},
            {type = "item", name = product_name, amount_min = 20 * mult, amount_max = 40 * mult}
        },
        energy_required = energy_required,
        localised_name = {"recipe-name.farm-algae", product:get_localised_name()},
        localised_description = {"recipe-description.farm-algae", product:get_localised_name()},
        category = "sosciencity-algae-farm",
        subgroup = "sosciencity-algae",
        icon = product.icon,
        icon_size = 64,
        do_index_fluid_ingredients = true,
        do_index_fluid_results = true,
        unlock = "basic-biotechnology",
        auto_recycle = false
    })

    add_general_growing_attributes(details, plant_details)
    return Tirislib.RecipeGenerator.create(details):add_category_layer("farming")
end

-- endower flower
create_algae_recipe {
    product = "endower-flower",
    ingredients = {{type = "fluid", name = "water", amount = 5000}},
    unlock = "algae-farming"
}

-- pyrifera
create_algae_recipe {
    product = "pyrifera",
    output_multiplier = 2,
    ingredients = {{type = "fluid", name = "water", amount = 5000}},
    unlock = "algae-farming"
}

-- queen algae
create_algae_recipe {
    product = "queen-algae",
    ingredients = {{type = "fluid", name = "water", amount = 5000}},
    unlock = "algae-farming"
}

---------------------------------------------------------------------------------------------------
-- << mix sorting recipes >>

Tirislib.RecipeGenerator.create {
    name = "sort-edible-plants",
    energy_required = 4,
    category = "sosciencity-sorting-machine",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 4}
    },
    results = {
        {type = "item", name = "leafage",       amount = 1},
        {type = "item", name = "liontooth",     amount_min = 0, amount_max = 5},
        {type = "item", name = "razha-bean",    amount_min = 0, amount_max = 4},
        {type = "item", name = "unnamed-fruit", amount_min = 0, amount_max = 5},
        {type = "item", name = "blue-grapes",   amount_min = 0, amount_max = 4}
    },
    icon = "__sosciencity-graphics__/graphics/icon/wild-edible-plants.png",
    icon_size = 64,
    subgroup = "sosciencity-neogenesis-recipes",
    main_product = "",
    order = "00001",
    localised_name = {"recipe-name.flora-sorting", {"item-name.wild-edible-plants"}},
    localised_description = {"recipe-description.flora-sorting"},
    unlock = "open-environment-farming",
    auto_recycle = false,
    allow_productivity = false
}:add_category_layer("plant-neogenesis")

Tirislib.RecipeGenerator.create {
    name = "sort-fungi",
    energy_required = 4,
    category = "sosciencity-sorting-machine",
    ingredients = {
        {type = "item", name = "wild-fungi", amount = 4}
    },
    results = {
        {type = "item", name = "leafage",   amount = 1},
        {type = "item", name = "fawoxylas", amount_min = 0, amount_max = 4},
        {type = "item", name = "pocelial",  amount_min = 0, amount_max = 4},
        {type = "item", name = "red-hatty", amount_min = 0, amount_max = 4},
        {type = "item", name = "birdsnake", amount_min = 0, amount_max = 4}
    },
    icon = "__sosciencity-graphics__/graphics/icon/wild-fungi.png",
    icon_size = 64,
    subgroup = "sosciencity-neogenesis-recipes",
    main_product = "",
    order = "00002",
    localised_name = {"recipe-name.flora-sorting", {"item-name.wild-fungi"}},
    localised_description = {"recipe-description.flora-sorting"},
    unlock = "mushroom-farming",
    auto_recycle = false,
    allow_productivity = false
}:add_category_layer("plant-neogenesis")

Tirislib.RecipeGenerator.create {
    name = "sort-algae",
    energy_required = 4,
    category = "sosciencity-sorting-machine",
    ingredients = {
        {type = "item", name = "wild-algae", amount = 4}
    },
    results = {
        {type = "item", name = "leafage",        amount = 1},
        {type = "item", name = "queen-algae",    amount_min = 0, amount_max = 4},
        {type = "item", name = "pyrifera",       amount_min = 0, amount_max = 4},
        {type = "item", name = "endower-flower", amount_min = 0, amount_max = 2}
    },
    icon = "__sosciencity-graphics__/graphics/icon/wild-algae.png",
    icon_size = 64,
    subgroup = "sosciencity-neogenesis-recipes",
    main_product = "",
    order = "00003",
    localised_name = {"recipe-name.flora-sorting", {"item-name.wild-algae"}},
    localised_description = {"recipe-description.flora-sorting"},
    unlock = "algae-farming",
    auto_recycle = false,
    allow_productivity = false
}:add_category_layer("plant-neogenesis")

---------------------------------------------------------------------------------------------------
-- << processing recipes >>

--- Unlocks the lumber recipe of a wood together with the recipes that produce that wood.
--- Stays enabled if the wood is obtainable from the start (e.g. willow wood from gathering).
--- Postponed, because the unlocks of the producing recipes may be postponed themselves.
--- @param lumber_recipe RecipePrototype
--- @param wood_name string
local function unlock_with_wood_sources(lumber_recipe, wood_name)
    local technologies = {}

    for _, source in Tirislib.Recipe.iterate() do
        if source.name ~= lumber_recipe.name and not source.hidden and Tirislib.Recipe.has_result(source, wood_name) then
            if source.enabled ~= false then
                return
            end

            for _, technology in Tirislib.Technology.iterate() do
                for _, effect in pairs(technology.effects or {}) do
                    if effect.type == "unlock-recipe" and effect.recipe == source.name then
                        technologies[technology.name] = true
                    end
                end
            end
        end
    end

    for technology_name in pairs(technologies) do
        Tirislib.Recipe.add_unlock(lumber_recipe, technology_name)
    end
end

for _, wood_name in pairs(wood_items) do
    local lumber_recipe =
        Tirislib.RecipeGenerator.create {
        name = "lumber-from-" .. wood_name,
        results = {
            {type = "item", name = "lumber",  amount = 3, product = true},
            {type = "item", name = "sawdust", amount = 1}
        },
        ingredients = {
            {type = "item", name = wood_name, amount = 1}
        },
        category = "sosciencity-wood-processing",
        allow_productivity = true,
        auto_recycle = false
    }:add_ingredient_layer(wood_name)

    Tirislib.Prototype.postpone(unlock_with_wood_sources, lumber_recipe, wood_name)
end

---------------------------------------------------------------------------------------------------
-- << saplings >>

Tirislib.Prototype.create {
    name = "sosciencity-saplings",
    type = "module-category"
}

local saplings = {
    {
        name = "apple-sapling",
        effect = {}
    },
    {
        name = "avocado-sapling",
        effect = {}
    },
    {
        name = "cherry-sapling",
        effect = {}
    },
    {
        name = "lemon-sapling",
        effect = {}
    },
    {
        name = "orange-sapling",
        effect = {}
    },
    {
        name = "ortrot-sapling",
        effect = {}
    },
    {
        name = "zetorn-sapling",
        effect = {}
    }
}

for _, sapling in pairs(saplings) do
    -- search the flora item that needs this sapling
    for flora_name, details in pairs(Biology.flora) do
        if details.required_module == sapling.name then
            local flora_item = Tirislib.Item.get_by_name(flora_name)
            sapling.localised_description = {"sosciencity.sapling", flora_item:get_localised_name()}

            sapling.icons = {
                {
                    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png"
                },
                {
                    icon = flora_item.icon,
                    scale = 0.3,
                    shift = {-8, 8}
                }
            }
        end
    end

    sapling.sprite_variations = {name = "sapling", count = 3}
end

Tirislib.Item.batch_create(
    saplings,
    {
        type = "module",
        effect = {},
        category = "sosciencity-saplings",
        tier = 1,
        subgroup = "sosciencity-saplings",
        stack_size = 10
    }
)

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "apple-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "ortrot-sapling", amount = 1},
        {type = "item",  name = "apple",          amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 2,
    unlock = Unlocks.get_tech_name("apple"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "avocado-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "pot",     amount = 1},
        {type = "item",  name = "avocado", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 1,
    unlock = Unlocks.get_tech_name("avocado"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "cherry-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "pot",    amount = 1},
        {type = "item",  name = "cherry", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 1,
    unlock = Unlocks.get_tech_name("cherry"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "lemon-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "zetorn-sapling", amount = 1},
        {type = "item",  name = "lemon",          amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 2,
    unlock = Unlocks.get_tech_name("lemon"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "orange-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "zetorn-sapling", amount = 1},
        {type = "item",  name = "orange",         amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 2,
    unlock = Unlocks.get_tech_name("orange"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "ortrot-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "pot",    amount = 1},
        {type = "item",  name = "ortrot", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    unlock = Unlocks.get_tech_name("ortrot"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "zetorn-sapling", amount = 1}
    },
    ingredients = {
        {theme = "soil", amount = 10},
        {type = "item",  name = "pot",    amount = 1},
        {type = "item",  name = "zetorn", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    unlock = Unlocks.get_tech_name("zetorn"),
    auto_recycle = false
}

---------------------------------------------------------------------------------------------------
-- << necrofall decorative >>

local sounds = require("__base__.prototypes.entity.sounds")

Tirislib.Entity.create {
    name = "necrofall-circle",
    type = "simple-entity",
    flags = {"placeable-neutral", "placeable-off-grid"},
    collision_mask = {
        layers = {
            item = true,
            meltable = true,
            object = true,
            water_tile = true,
            is_object = true,
            is_lower_object = true
        }
    },
    --collision_mask = {"item-layer", "object-layer", "water-tile"},
    count_as_rock_for_filtered_deconstruction = true,
    subgroup = "grass",
    minable = {
        mining_particle = "wooden-particle",
        mining_time = 1,
        results = {
            {type = "item", name = "necrofall", amount_min = 10, amount_max = 15},
            {type = "item", name = "leafage",   amount_min = 10, amount_max = 15}
        }
    },
    mined_sound = sounds.tree_leaves,
    mining_sound = {
        variations = {
            {
                filename = "__core__/sound/mining-wood-1.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-2.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-3.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-4.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-5.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-6.ogg",
                volume = 0.4
            }
        }
    },
    pictures = {
        {
            filename = "__sosciencity-graphics__/graphics/entity/necrofall-circle/necrofall-circle-1.png",
            width = 256,
            height = 256,
            shift = {0.0, 0.0},
            scale = 0.25
        },
        {
            filename = "__sosciencity-graphics__/graphics/entity/necrofall-circle/necrofall-circle-2.png",
            width = 256,
            height = 256,
            shift = {0.0, 0.0},
            scale = 0.25
        },
        {
            filename = "__sosciencity-graphics__/graphics/entity/necrofall-circle/necrofall-circle-3.png",
            width = 256,
            height = 256,
            shift = {0.0, 0.0},
            scale = 0.25
        }
    },
    render_layer = "transport-belt"
}:set_size(1.8, 1.8):copy_icon_from_item("necrofall")

---------------------------------------------------------------------------------------------------
-- << tree planting >>

-- Invisible marker entity: placed by the tree-sapling item, swapped for a real tree
-- by the tree-planting class in the control stage.
Tirislib.Entity.create {
    type = "simple-entity-with-owner",
    name = "sosciencity-tree-sapling",
    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "not-on-map"},
    render_layer = "object",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
    collision_mask = {
        layers = {
            object = true,
            water_tile = true,
            is_object = true
        }
    },
    picture = {
        filename = "__sosciencity-graphics__/graphics/icon/sapling-1.png",
        width = 64,
        height = 64,
        scale = 0.5
    },
    max_health = 1
}

Tirislib.Item.create {
    type = "item",
    name = "tree-sapling",
    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png",
    icon_size = 64,
    subgroup = "sosciencity-saplings",
    order = "zzz",
    place_result = "sosciencity-tree-sapling",
    stack_size = 50
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "tree-sapling", amount = 1}
    },
    ingredients = {
        {type = "item", name = "leafage", amount = 10},
        {type = "item", name = "humus",   amount = 10},
        {type = "item", name = "pot",     amount = 1}
    },
    category = "sosciencity-bloomhouse-annual",
    energy_required = 20,
    subgroup = "sosciencity-flora-bloomhouse",
    unlock = "indoor-growing",
    auto_recycle = false
}

Tirislib.Prototype.create {
    type = "selection-tool",
    name = "forestry-selection-tool",
    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png",
    icon_size = 64,
    flags = {"not-stackable", "spawnable"},
    subgroup = "sosciencity-saplings",
    order = "zzza",
    stack_size = 1,
    select = {
        border_color = {0.2, 0.8, 0.2},
        mode = {"any-tile"},
        cursor_box_type = "entity"
    },
    alt_select = {
        border_color = {0.1, 0.6, 0.1},
        mode = {"any-tile"},
        cursor_box_type = "entity"
    }
}

Tirislib.Prototype.create {
    type = "shortcut",
    name = "sosciencity-forestry-tool",
    action = "spawn-item",
    item_to_spawn = "forestry-selection-tool",
    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png",
    icon_size = 64,
    small_icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png",
    small_icon_size = 64,
    technology_to_unlock = "indoor-growing",
    -- otherwise it stays unlocked in every new game once it was researched in any save
    unavailable_until_unlocked = true
}
