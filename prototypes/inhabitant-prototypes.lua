local Biology = require("constants.biology")

---------------------------------------------------------------------------------------------------
-- << items >>

local items = {
    {
        name = "hehe",
        sprite_variations = {name = "hehe", count = 3, include_icon = true}
    },
    {
        name = "huwan-egg",
        sprite_variations = {name = "huwan-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.any"}}
        }
    },
    {
        name = "huwan-agender-egg",
        sprite_variations = {name = "huwan-agender-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-1"}}
        }
    },
    {
        name = "huwan-fale-egg",
        sprite_variations = {name = "huwan-fale-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-2"}}
        }
    },
    {
        name = "huwan-pachin-egg",
        sprite_variations = {name = "huwan-pachin-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-3"}}
        }
    },
    {
        name = "huwan-ga-egg",
        sprite_variations = {name = "huwan-ga-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-4"}}
        }
    }
}

Tirislib.Item.batch_create(items, {subgroup = "sosciencity-inhabitants", stack_size = 10})

Tirislib.RecipeGenerator.create {
    product = "hehe",
    themes = {{"plating", 2}, {"plating2", 4}, {"glass", 2}, {"wiring", 1}},
    energy_required = 1,
    unlock = "upbringing"
}

Tirislib.Recipe.create {
    name = "lay-egg",
    category = "sosciencity-handcrafting",
    enabled = true,
    energy_required = 1,
    ingredients = {
        {type = "item", name = "hehe", amount = 1}
    },
    results = {
        {type = "item", name = "huwan-agender-egg", amount_min = 1, amount_max = 3},
        {type = "item", name = "hehe", amount = 1, probability = 0.9}
    },
    icon = "__sosciencity-graphics__/graphics/icon/huwan-agender-egg.png",
    icon_size = 64,
    subgroup = "sosciencity-inhabitants",
    main_product = "",
    localised_description = {"recipe-description.lay-egg", tostring(Biology.egg_calories)}
}:add_unlock("upbringing")

for index, egg in pairs({"huwan-agender-egg", "huwan-fale-egg", "huwan-pachin-egg", "huwan-ga-egg"}) do
    Tirislib.RecipeGenerator.create {
        product = egg,
        energy_required = 120,
        ingredients = {
            {type = "item", name = "blood-bag", amount = 1},
            {type = "item", name = "huwan-genome", amount = 1}
        },
        themes = {{"genetic_neogenesis", 1}},
        category = "sosciencity-reproductive-gene-lab",
        localised_name = {"recipe-name.in-vitro-reproduction", {"sosciencity.gender-" .. (index)}},
        unlock = "huwan-genetic-neogenesis"
    }
end
