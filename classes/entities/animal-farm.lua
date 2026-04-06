local EK = require("enums.entry-key")
local Type = require("enums.type")

local function create_animal_farm(entry)
    entry[EK.houses_animals] = false
end
Register.set_entity_creation_handler(Type.animal_farm, create_animal_farm)

local function update_animal_farm(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    local houses_animals =
        recipe and entity.status == defines.entity_status.working and
        Tirislib.String.begins_with(recipe.name, "sos-husbandry-")
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
