local Housing = require("constants.housing")
local HousingTrait = require("enums.housing-trait")
local Locale = require("classes.locale")

local unlocks = {
    [0] = "infrastructure-1",
    [1] = "architecture-1",
    [2] = "architecture-2",
    [3] = "architecture-3",
    [4] = "architecture-4",
    [5] = "architecture-5",
    [6] = "architecture-6",
    [7] = "architecture-7"
}

local function get_inventory_size(house_def)
    return 10 * math.ceil(1 + math.log(house_def.room_count, 10))
end

local function get_order(house_def)
    return string.format("%02d", house_def.comfort) .. string.format("%09d", house_def.room_count)
end

local function get_localised_traits(house_def)
    local ret = {""}

    for _, trait in pairs(house_def.traits) do
        ret[#ret + 1] = Locale.housing_trait(trait)
        ret[#ret + 1] = "  "
    end

    return ret
end

local function get_localised_description(house_name, house_def, details)
    local ret = {""}

    if details.description_prefix then
        ret[#ret + 1] = details.description_prefix
    end

    Tirislib.Locales.append(
        ret,
        {
            "sosciencity-util.housing",
            tostring(house_def.room_count),
            {"color-scale." .. house_def.max_comfort, {"comfort-scale." .. house_def.max_comfort}},
            {"description.sos-details", tostring(house_def.max_comfort)},
            get_localised_traits(house_def)
        },
        "\n\n",
        {
            "sosciencity-util.official-looking-point",
            {"sosciencity.range"},
            {"sosciencity.show-range", tostring(100)} -- 2 times the "by foot"-range (50)
        },
        "\n",
        {"sosciencity.grey", {"range-description.housing"}}
    )

    return ret
end

local function create_item(house_name, house_def, details)
    local item_prototype =
        Tirislib.Item.create {
        type = "item",
        name = house_name,
        icon = "__sosciencity-graphics__/graphics/icon/" .. (details.icon or house_name) .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-housing",
        order = get_order(house_def),
        stack_size = details.stack_size or Sosciencity.Config.building_stacksize,
        place_result = house_name,
        pictures = Sosciencity.Config.blueprint_on_belt
    }

    Tirislib.Tables.set_fields(item_prototype, details.item_fields)
end

local trait_effect_on_recipe = {
    [HousingTrait.sheltered] = function(recipe_details, house_def, tech_level)
        table.insert(recipe_details.ingredients, {theme = "housing_sheltered", amount = house_def.room_count, level = tech_level})
    end,
    [HousingTrait.green] = function(recipe_details, house_def, tech_level)
        -- Not an architectural trait anymore
    end,
    [HousingTrait.technical] = function(recipe_details, house_def, tech_level)
        -- Not an architectural trait anymore
    end,
    [HousingTrait.spacey] = function(recipe_details, house_def, tech_level)
        recipe_details.ingredients[1].amount = recipe_details.ingredients[1].amount * 1.25
    end,
    [HousingTrait.compact] = function(recipe_details, house_def, tech_level)
        recipe_details.ingredients[1].amount = recipe_details.ingredients[1].amount * 0.8
    end,
    [HousingTrait.decorated] = function(recipe_details, house_def, tech_level)
        -- Not an architectural trait anymore
    end,
    [HousingTrait.simple] = function(recipe_details, house_def, tech_level)
        -- furnishing is no longer part of the base recipe (handled by runtime upgrades)
    end,
    [HousingTrait.individualistic] = function(recipe_details, house_def, tech_level)
        recipe_details.energy_required = recipe_details.energy_required * 3
    end,
    [HousingTrait.copy_paste] = function(recipe_details, house_def, tech_level)
        recipe_details.energy_required = recipe_details.energy_required / 2
    end,
    [HousingTrait.pompous] = function(recipe_details, house_def, tech_level)
        recipe_details.ingredients[1].theme = "pompous_building"
    end,
    [HousingTrait.cheap] = function(recipe_details, house_def, tech_level)
        recipe_details.ingredients[1].theme = "cheap_building"
    end,
    [HousingTrait.tall] = function(recipe_details, house_def, tech_level)
        table.insert(recipe_details.ingredients, {theme = "tall_building_structure", amount = house_def.room_count, level = tech_level})
    end,
    [HousingTrait.low] = function(recipe_details, house_def, tech_level)
        -- no idea
    end
}

local function create_recipe(house_name, house_def, details)
    local tech_level = details.tech_level

    local recipe_details = {
        results = {
            {type = "item", name = house_name, amount = 1}
        },
        ingredients = {
            {theme = "building", amount = house_def.room_count * 0.5, level = tech_level},
            {type = "item", name = "architectural-concept", amount = 1}
        },
        unlock = unlocks[tech_level],
        energy_required = house_def.room_count / 5
    }

    for _, trait in pairs(house_def.traits) do
        trait_effect_on_recipe[trait](recipe_details, house_def, tech_level)
    end

    Tirislib.RecipeGenerator.create(recipe_details)
end

local function create_entity(house_name, house_def, details)
    local entity =
        Tirislib.Entity.create {
        type = "container",
        name = house_name,
        order = get_order(house_def),
        icon = "__sosciencity-graphics__/graphics/icon/" .. (details.icon or house_name) .. ".png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5},
        max_health = 500,
        corpse = "small-remnants",
        open_sound = details.open_sound or {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
        close_sound = details.close_sound or {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
        inventory_size = get_inventory_size(house_def),
        inventory_type = "with_filters_and_bar",
        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
        picture = details.picture,
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13,
        localised_name = {"entity-name." .. details.main_entity},
        localised_description = get_localised_description(house_name, house_def, details)
    }:set_size(details.width, details.height)

    local mining_result = details.mining_result or {type = "item", name = details.main_entity, amount = 1}
    entity:add_mining_result(mining_result)
end

--- Creates a full house prototype: item, recipe, and entity.
--- @param house_name string
--- @param details table Prototype details: picture, width, height, tech_level; optionally icon, main_entity,
---   mining_result, description_prefix, open_sound, close_sound, stack_size, item_fields.
--- @param house_def HouseDefinition? House definition; looked up in constants/housing.lua by house_name if nil
function Sosciencity.create_house(house_name, details, house_def)
    house_def = house_def or Housing.values[house_name]
    if not house_def then
        error("Sosciencity.create_house: no house definition found for '" .. house_name .. "'")
    end

    details.main_entity = details.main_entity or house_name
    create_item(house_name, house_def, details)
    create_recipe(house_name, house_def, details)
    create_entity(house_name, house_def, details)
    Sosciencity.Config.add_eei(house_name)
end

--- Creates a house entity only, without an item or recipe.
--- Use for improvised buildings and house variants that share an item with another house.
--- Set details.main_entity to the shared house name to inherit its localised_name and mining result.
--- @param house_name string
--- @param details table Prototype details: picture, width, height; optionally icon, main_entity,
---   mining_result, description_prefix, open_sound, close_sound.
--- @param house_def HouseDefinition? House definition; looked up in constants/housing.lua by house_name if nil
function Sosciencity.create_house_entity(house_name, details, house_def)
    house_def = house_def or Housing.values[house_name]
    if not house_def then
        error("Sosciencity.create_house_entity: no house definition found for '" .. house_name .. "'")
    end

    details.main_entity = details.main_entity or house_name
    create_entity(house_name, house_def, details)
    Sosciencity.Config.add_eei(house_name)
end
