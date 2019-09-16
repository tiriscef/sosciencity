item_operations = {}
recipe_operations = {}

require("scripts.data-final-fixes.science-pack-ingredients")
require("scripts.data-final-fixes.launchable-items")

--[[ looping through items ]]
local item_types = require("lib.prototypes-types.item-types")

for _, item_type in pairs(item_types) do
    for _, item in pairs(data.raw[item_type]) do
        local current_item = Item.from_prototype(item)

        for _, operation in pairs(item_operations) do
            operation.func(current_item, operation.details)
        end
    end
end

--[[ looping through recipes ]]
for _, recipe in pairs(data.raw.recipe) do
    local current_recipe = Recipe.from_prototype(recipe)

    for _, operation in pairs(recipe_operations) do
        operation.func(current_recipe, operation.details)
    end
end

--[[ handcrafting category ]]
-- add it when no other mod did so
if not data.raw["recipe-category"]["handcrafting"] then
    data:extend {
        {
            type = "recipe-category",
            name = "handcrafting"
        }
    }

    for _, player in DATA:pairs("character") do
        player.crafting_categories = player:get_field("crafting_categories", default) + "handcrafting"
    end
    for _, controller in DATA:pairs("god-controller") do
        controller.crafting_categories = controller:get_field("crafting_categories", default) + "handcrafting"
    end
end
