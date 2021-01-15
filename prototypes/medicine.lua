require("constants.diseases")

---------------------------------------------------------------------------------------------------
-- << items >>

local medicine_items = {
    {name = "artificial-limp"},
    {name = "blood-bag"},
    {name = "psychotropics", sprite_variations = {name = "psychotropics-pile", count = 3}}
}

local function find_curable_diseases(item_name)
    local ret = {""}
    local first = true

    for _, disease in pairs(Diseases.values) do
        if disease.cure_items and disease.cure_items[item_name] then
            if not first then
                ret[#ret + 1] = "[color=#FFFFFF] - [/color]"
            end

            ret[#ret + 1] = disease.localised_name
            first = false
        end
    end

    return ret
end

for _, medicine in pairs(medicine_items) do
    medicine.distinctions = medicine.destinctions or {}
    local distinctions = medicine.distinctions

    distinctions.localised_description = {
        "item-description.medicine",
        {"item-description." .. medicine.name},
        find_curable_diseases(medicine.name)
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
    unlock = "plasma-caste"
}

Tirislib_RecipeGenerator.create {
    product = "psychotropics",
    energy_required = 3,
    allow_productivity = true,
    unlock = "plasma-caste"
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
