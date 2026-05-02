local Food = require("constants.food")
local Locale = require("classes.locale")

local function make_nutrition_string(nutrition_tags)
    local query = Tirislib.LazyLuaq.from_keyset(nutrition_tags)

    if query:count() == 0 then
        return {"nutrition-tag.none"}
    end

    local localised_tags = query:select(Locale.nutrition_tag):to_array()

    return Tirislib.Locales.create_enumeration(localised_tags, " · ")
end

local function apply_food_fields(prototype, food_def)
    local appeal = food_def.appeal
    local health = food_def.healthiness

    prototype.type = "tool"
    prototype.durability = food_def.calories
    prototype.durability_description_key = "description.food-key"
    prototype.durability_description_value = "description.food-value"
    prototype.infinite = false
    prototype.localised_description = {
        "sosciencity-util.foods",
        {"item-description." .. prototype.name}, -- 1: description
        {"food-category." .. food_def.food_category}, -- 2: category
        {"food-group." .. food_def.group}, -- 3: group
        Locale.taste_category(food_def.taste_category), -- 4: taste
        {"color-scale." .. appeal, {"taste-scale." .. appeal}}, -- 5: colored appeal label
        {"description.sos-details", tostring(appeal)}, -- 6: appeal value
        {"color-scale." .. health, {"health-scale." .. health}}, -- 7: colored health label
        {"description.sos-details", tostring(health)}, -- 8: health value
        make_nutrition_string(food_def.nutrition_tags), -- 9: nutrition tags
        tostring(Tirislib.Utils.round_to_step(food_def.fat / Food.energy_density_fat, 0.1)), -- 10: fat g/100g
        tostring(Tirislib.Utils.round_to_step(food_def.carbohydrates / Food.energy_density_carbohydrates, 0.1)), -- 11: carbs g/100g
        tostring(Tirislib.Utils.round_to_step(food_def.proteins / Food.energy_density_proteins, 0.1)) -- 12: protein g/100g
    }
end

--- Creates a new food item prototype and adds it to data.
--- The prototype's type must be "item" or "tool". "item" is converted to "tool" automatically.
--- @param prototype table Factorio item prototype table (not yet in data.raw)
--- @param food_def table? Food definition; looked up in constants/food.lua by prototype.name if nil
function Sosciencity.create_food_item(prototype, food_def)
    if prototype.type ~= nil and prototype.type ~= "item" and prototype.type ~= "tool" then
        error(
            "Sosciencity.create_food_item: prototype type must be 'item' or 'tool', got: " ..
                tostring(prototype.type)
        )
    end

    food_def = food_def or Food.values[prototype.name]
    if not food_def then
        error("Sosciencity.create_food_item: no food definition found for '" .. prototype.name .. "'")
    end

    apply_food_fields(prototype, food_def)
    data:extend({prototype})
end

--- Converts an already-registered item prototype to a food item.
--- Removes it from data.raw.item and re-registers it as a tool with food fields applied.
--- @param item_name string Name of the item in data.raw.item
--- @param food_def table? Food definition; looked up in constants/food.lua by item_name if nil
function Sosciencity.make_existing_item_food(item_name, food_def)
    local prototype = data.raw["item"][item_name] or data.raw["tool"][item_name]
    if not prototype then
        error("Sosciencity.make_existing_item_food: item '" .. item_name .. "' not found in data.raw")
    end

    food_def = food_def or Food.values[item_name]
    if not food_def then
        error("Sosciencity.make_existing_item_food: no food definition found for '" .. item_name .. "'")
    end

    data.raw["item"][item_name] = nil
    apply_food_fields(prototype, food_def)
    data:extend({prototype})
end
