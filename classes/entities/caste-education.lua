local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local try_get = Register.try_get
local set_active = Entity.set_active

local function create_caste_education_building(entry)
    entry[EK.last_products_finished] = entry[EK.entity].products_finished
end
Register.set_entity_creation_handler(Type.caste_education_building, create_caste_education_building)

local function update_caste_education_building(entry)
    local entity = entry[EK.entity]
    local new_finished_products = entity.products_finished

    if entry[EK.last_products_finished] < new_finished_products then
        entry[EK.last_products_finished] = new_finished_products

        local details = get_building_details(entry)
        local converted_group = InhabitantGroup.new(details.result_caste)

        -- remove the employed students from their houses
        for unit_number, student_count in pairs(entry[EK.workers]) do
            local house = try_get(unit_number)
            if house then
                -- take only healthy inhabitants
                local students = InhabitantGroup.take_specific(house, student_count, DiseaseGroup.new(student_count))
                InhabitantGroup.merge(converted_group, students, true, true)
            end
        end
        Inhabitants.unemploy_all_workers(entry)

        Communication.send_notification(
            entry,
            {
                "sosciencity.finished-caste-education",
                Locale.entry_in_chat(entry),
                converted_group[EK.inhabitants],
                Locale.caste(converted_group[EK.type])
            }
        )

        -- add them as the result_caste
        if converted_group[EK.inhabitants] > 0 then
            Inhabitants.add_to_city(converted_group)
        end
    else
        if Inhabitants.get_workforce_count(entry) > 0 then
            set_active(entry, true)
        else
            set_active(entry, false, {diode = defines.entity_status_diode.red, label = {"sosciencity.no-students"}})
            entity.crafting_progress = 0
        end
    end
end
Register.set_entity_updater(Type.caste_education_building, update_caste_education_building)
