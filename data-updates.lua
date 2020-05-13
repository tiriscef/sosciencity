require("lib.init")

item_operations = {}
recipe_operations = {}

require("scripts.data-updates.science-pack-ingredients")
require("scripts.data-updates.launchable-items")
require("scripts.data-updates.gunfire-techs")
require("scripts.data-updates.loot")
require("scripts.data-updates.fawoxylas")

--<< looping through items >>
local item_types = require("lib.prototype-types.item-types")

for _, item_type in pairs(item_types) do
    for _, current_item in Tirislib_Item.pairs(item_type) do
        for _, operation in pairs(item_operations) do
            operation.func(current_item, operation.details)
        end
    end
end

--<< looping through recipes >>
for _, current_recipe in Tirislib_Recipe.pairs() do
    for _, operation in pairs(recipe_operations) do
        operation.func(current_recipe, operation.details)
    end
end

--<< handcrafting category >>
-- add it to all the prototypes the player can be in
-- this is in data-updates to give other mods a chance to add their own characters and or god controllers
for _, character in Tirislib_Entity.pairs("character") do
    character:add_crafting_category("handcrafting")
end
for _, controller in Tirislib_Entity.pairs("god-controller") do
    -- technically a god controller isn't an entity, but adding a category works the same for them
    controller:add_crafting_category("handcrafting")
end

Tirislib_Prototype.finish()
