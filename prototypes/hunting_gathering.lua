local function create_hunting_gathering_recipe(details)
    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            energy_required = 4,
            allow_decomposition = false,
            always_show_made_in = true,
            main_product = "",
            subgroup = "sosciencity-gathering"
        }
    )

    return Tirislib_Recipe.create(details)
end

create_hunting_gathering_recipe {
    name = "sosciencity-gathering",
    category = "sosciencity-hunting",
    energy_required = 8,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gathering.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "phytofall-blossom", amount = 1, probability = 0.1}
    }
}

create_hunting_gathering_recipe {
    name = "sosciencity-gathering-with-bucket",
    category = "sosciencity-hunting",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gathering.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/bucket.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {

    }
}:add_catalyst("bucket", "item", 1, 0.9, 2, 0.8)

create_hunting_gathering_recipe {
    name = "sosciencity-hunting-with-trap",
    category = "sosciencity-hunting",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/hunting.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/trap.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {

    }
}:add_catalyst("trap", "item", 2, 0.8, 3, 0.6)

create_hunting_gathering_recipe {
    name = "sosciencity-hunting-with-trap-cage",
    category = "sosciencity-hunting",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/hunting.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/trap-cage.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {

    }
}:add_catalyst("trap-cage", "item", 2, 0.8, 3, 0.6)

create_hunting_gathering_recipe {
    name = "sosciencity-fishing-with-fishing-net",
    category = "sosciencity-fishery",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/fishing.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/fishing-net.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {

    }
}:add_catalyst("fishing-net", "item", 1, 0.7, 1, 0.5)

create_hunting_gathering_recipe {
    name = "sosciencity-fishing-with-harpoon",
    category = "sosciencity-fishery",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/fishing.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/harpoon.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {

    }
}:add_catalyst("harpoon", "item", 1, 0.7, 1, 0.5)
