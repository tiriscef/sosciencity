local EK = require("enums.entry-key")
local Type = require("enums.type")

local Register = require("classes.register")

local function create_animal_farm(entry)
    entry[EK.houses_animals] = false
end
Register.set_entity_creation_handler(Type.animal_farm, create_animal_farm)

--- Recipe categories that keep animals. Animal farms can also run other recipes (e.g. water plants in the aquafarm).
local husbandry_categories = {
    ["sosciencity-animal-farming"] = true,
    ["sosciencity-water-animal-farming"] = true
}

local function is_husbandry_recipe(recipe)
    for _, category in pairs(recipe.categories) do
        if husbandry_categories[category] then
            return true
        end
    end

    return false
end

local function update_animal_farm(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    local houses_animals =
        recipe ~= nil and
        entity.status == defines.entity_status.working and
        is_husbandry_recipe(recipe)
    local housed_in_the_past = entry[EK.houses_animals]

    if houses_animals and not housed_in_the_past then
        storage.active_animal_farms = storage.active_animal_farms + 1
    elseif not houses_animals and housed_in_the_past then
        storage.active_animal_farms = storage.active_animal_farms - 1
    end

    entry[EK.houses_animals] = houses_animals
end
Register.set_entity_updater(Type.animal_farm, update_animal_farm)

local function remove_animal_farm(entry)
    if entry[EK.houses_animals] then
        storage.active_animal_farms = storage.active_animal_farms - 1
    end
end
Register.set_entity_destruction_handler(Type.animal_farm, remove_animal_farm)
