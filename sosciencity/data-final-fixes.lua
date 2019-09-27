require("lib.init")

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

--[[ find all turrets and add them to the hidden gunfire techs ]]
local gunfire_techs = {}
for i = 0, 20 do
    local strength = 2 ^ i

    table.insert(gunfire_techs, {strength = strength, prototype = Technology:get(strength .. "-gunfire-caste")})
end

local turret_types = require("lib.prototype-types.turret-types")

local function add_turret_to_gunfire(turret)
    for _, gunfire_tech in pairs(gunfire_techs) do
        gunfire_tech:add_effect {
            type = "turret-attack",
            modifier = gunfire_tech.strength,
            turret_id = turret.name
        }
    end
end

for _, turret_type in pairs(turret_types) do
    for _, turret in pairs(data.raw[turret_type]) do
        if turret.subgroup ~= "enemies" then -- vanilla worms are coded as turrets
            add_turret_to_gunfire(turret)
        end
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

    for _, character in pairs(data.raw["character"]) do
        Entity.add_crafting_category(character, "handcrafting")
    end
    for _, controller in pairs(data.raw["god-controller"]) do
        -- technically a god controller isn't an entity, but adding a category works the same for them
        Entity.add_crafting_category(controller, "handcrafting")
    end
end
