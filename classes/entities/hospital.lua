local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local TypeGroup = require("constants.type-groups")

local get_building_details = Buildings.get
local get_chest_inventory = Inventories.get_chest_inventory
local has_power = Subentities.has_power
local evaluate_workforce = Inhabitants.evaluate_workforce
local Table = Tirislib.Tables

--- Returns the LuaInventory of the given hospital and all hospital complement buildings connected to it.
--- @param entry Entry hospital
--- @return LuaInventory[]
function Entity.get_hospital_inventories(entry)
    local ret = {get_chest_inventory(entry)}

    for _, _type in pairs(TypeGroup.hospital_complements) do
        for _, building in Neighborhood.iterate_type(entry, _type) do
            ret[#ret + 1] = get_chest_inventory(building)
        end
    end

    return ret
end

local function update_hospital(entry, delta_ticks)
    local performance = evaluate_workforce(entry)

    if not has_power(entry) then
        performance = 0
    end

    entry[EK.workhours] = entry[EK.workhours] + performance * delta_ticks * get_building_details(entry).speed
    entry[EK.performance] = performance
end
Register.set_entity_updater(Type.hospital, update_hospital)
Register.set_entity_updater(Type.improvised_hospital, update_hospital)

local function create_hospital(entry)
    entry[EK.workhours] = 0
    entry[EK.treated] = {}
    entry[EK.treatment_permissions] = {}
    entry[EK.blood_donation_threshold] = 100
    entry[EK.blood_donations] = 0

    -- if the hospital doesn't already have filters set up, filter the first slot for medical reports
    local inventory = get_chest_inventory(entry)
    if not inventory.supports_filters() or inventory.is_filtered() then
        return
    end
    inventory.set_filter(1, "medical-report")
end
Register.set_entity_creation_handler(Type.hospital, create_hospital)
Register.set_entity_creation_handler(Type.improvised_hospital, create_hospital)

local function copy_hospital(source, destination)
    destination[EK.workhours] = source[EK.workhours]
    destination[EK.treated] = Table.copy(source[EK.treated])
    destination[EK.treatment_permissions] = Table.copy(source[EK.treatment_permissions])
    destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
    destination[EK.blood_donations] = source[EK.blood_donations]
end
Register.set_entity_copy_handler(Type.hospital, copy_hospital)
Register.set_entity_copy_handler(Type.improvised_hospital, copy_hospital)

local function paste_hospital_settings(source, destination)
    destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
end
Register.set_settings_paste_handler(Type.hospital, Type.hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.hospital, Type.improvised_hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.improvised_hospital, Type.hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.improvised_hospital, Type.improvised_hospital, paste_hospital_settings)
