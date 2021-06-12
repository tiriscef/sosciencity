require("constants.diseases")

---------------------------------------------------------------------------------------------------
-- << items >>

local medicine_items = {
    {name = "artificial-limp"},
    {name = "artificial-heart"},
    {name = "bandage", sprite_variations = {name = "bandage-pile", count = 3}},
    {name = "blood-bag"},
    {name = "psychotropics", sprite_variations = {name = "psychotropics-pile", count = 3}},
    {name = "analgesics", sprite_variations = {name = "analgesics-pile", count = 3}},
    {name = "potent-analgesics", sprite_variations = {name = "potent-analgesics-pile", count = 3}},
    {name = "anesthetics", sprite_variations = {name = "anesthetics-pile", count = 3}},
    {name = "antibiotics", sprite_variations = {name = "antibiotics-pile", count = 3}}
}

local function find_curable_diseases(item_name)
    local ret = {}

    for _, disease in pairs(Diseases.values) do
        if disease.cure_items and disease.cure_items[item_name] then
            ret[#ret + 1] = disease.localised_name
        end
    end

    return ret
end

for _, medicine in pairs(medicine_items) do
    medicine.distinctions = medicine.destinctions or {}
    local distinctions = medicine.distinctions

    distinctions.localised_description = {
        "sosciencity-util.medicine",
        {"item-description." .. medicine.name},
        Tirislib_Locales.create_enumeration(find_curable_diseases(medicine.name), "[color=#FFFFFF], [/color]")
    }
end

Tirislib_Item.batch_create(medicine_items, {subgroup = "sosciencity-medicine", stack_size = 50})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib_RecipeGenerator.create {
    product = "artificial-limp",
    themes = {
        {"structure", 2, 1},
        {"wiring", 1, 1},
        {"electronics", 1, 1}
    },
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "artificial-heart",
    themes = {
        {"casing", 1},
        {"wiring", 2},
        {"electronics", 1},
        {"battery", 1}
    },
    default_theme_level = 4,
    energy_required = 10,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib_RecipeGenerator.create {
    product = "bandage",
    product_amount = 15,
    ingredients = {
        {name = "cloth", amount = 10},
        {name = "steam", amount = 300, type = "fluid"}
    },
    category = "crafting-with-fluid",
    energy_required = 5,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "psychotropics",
    themes = {{"tablet_ingredients", 1}},
    ingredients = {{name = "phytofall-blossom", amount = 2}},
    energy_required = 3,
    allow_productivity = true,
    unlock = "psychiatry"
}

Tirislib_RecipeGenerator.create {
    product = "analgesics",
    themes = {{"tablet_ingredients", 1}},
    --ingredients = {{name = "phytofall-blossom", amount = 2}}, TODO: ingredient
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "potent-analgesics",
    themes = {{"tablet_ingredients", 1}},
    --ingredients = {{name = "phytofall-blossom", amount = 2}}, TODO: ingredient
    energy_required = 3,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib_RecipeGenerator.create {
    product = "anesthetics",
    ingredients = {{name = "clean-water", amount = 2, type = "fluid"}},
    energy_required = 3,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib_RecipeGenerator.create {
    product = "antibiotics",
    themes = {{"tablet_ingredients", 1}},
    --ingredients = {{name = "phytofall-blossom", amount = 2}}, TODO: ingredient
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_Recipe.create {
    name = "donate-blood",
    category = "handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "blood-bag", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/blood-bag.png",
    icon_size = 64,
    subgroup = "sosciencity-medicine",
    main_product = ""
}

data:extend {
    {
        type = "sticker",
        name = "blood-donation-1",
        duration_in_ticks = 60 * 20, -- 20 seconds at 60 ticks per second
        target_movement_modifier_from = 0.8,
        target_movement_modifier_to = 1
    },
    {
        type = "sticker",
        name = "blood-donation-2",
        duration_in_ticks = 60 * 90,
        target_movement_modifier_from = 0.5,
        target_movement_modifier_to = 1
    },
    {
        type = "sticker",
        name = "blood-donation-3",
        duration_in_ticks = 60 * 7,
        target_movement_modifier = 0
    },
    {
        type = "sticker",
        name = "blood-donation-4",
        duration_in_ticks = 60 * 80,
        target_movement_modifier = -1
    },
    {
        type = "sticker",
        name = "blood-donation-5",
        duration_in_ticks = 60 * 45,
        target_movement_modifier = 0
    }
}
