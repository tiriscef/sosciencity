require("constants.housing")

local data_details = {}
--[[    ["example-house"] = {
        picture = {

        },
        width = 5,
        height = 5
    }]]
local unlocking_tech = {
    [0] = nil,
    [1] = "clockwork-caste",
    [2] = "ember-caste",
    [3] = "gunfire-caste",
    [4] = "gleam-caste",
    [5] = "foundry-caste",
    [6] = "orchid-caste",
    [7] = "aurora-caste"
}

for house_name, house in pairs(Housing.houses) do
    local orderstring = string.format("%02d", house.contentment) .. "-" .. string.format("%09d", house.room_count)
    local details = data_details[house_name]

    Item:create {
        type = "item",
        name = house_name,
        icon = "__sosciencity__/graphics/icon/" .. house_name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-housing",
        order = orderstring,
        stack_size = details.stack_size or 20,
        place_result = house_name
    }

    RecipeGenerator:create_housing_recipe(house):add_unlock(unlocking_tech[house.tech_level])

    Entity:create {
        type = "container",
        name = house_name,
        order = orderstring,
        icon = "__sosciencity__/graphics/icon/" .. house_name .. ".png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = house_name},
        max_health = 500,
        corpse = "small-remnants", -- TODO
        open_sound = details.open_sound or {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65}, -- TODO sounds
        close_sound = details.close_sound or {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7}, -- TODO
        collision_box = Entity:get_collision_box(details.width, details.height),
        selection_box = Entity:get_selection_box(details.width, details.height),
        inventory_size = 64,
        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
        picture = details[house_name].picture,
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13
    }
end
