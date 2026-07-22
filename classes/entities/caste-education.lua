local EK = require("enums.entry-key")
local MoveCause = require("enums.move-cause")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local try_get = Register.try_get
local set_active = Entity.set_active

Entity.CasteEducation = {}
local CasteEducation = Entity.CasteEducation

-- crafting categories used by caste education buildings; their education recipes
-- set raise_on_crafted, and control.lua subscribes to the resulting on_crafted_event
local education_categories = {}
for name, details in pairs(Buildings.values) do
    if details.type == Type.caste_education_building then
        education_categories["sosciencity-" .. name] = true
    end
end

--- Whether the given recipe belongs to a caste education building, so its
--- completion should graduate students.
--- @param recipe LuaRecipePrototype
--- @return boolean
function CasteEducation.is_education_recipe(recipe)
    for _, category in pairs(recipe.categories) do
        if education_categories[category] then
            return true
        end
    end
    return false
end

local function update_caste_education_building(entry)
    if Inhabitants.get_workforce_count(entry) > 0 then
        set_active(entry, true)
    else
        set_active(entry, false, {diode = defines.entity_status_diode.red, label = {"sosciencity.no-students"}})
        entry[EK.entity].crafting_progress = 0
    end
end
Register.set_entity_updater(Type.caste_education_building, update_caste_education_building)

--- Graduates the students working in a caste education building into its result
--- caste. Called when one of the building's education recipes finishes crafting.
--- @param event OnRecipeCraftedData
function CasteEducation.on_recipe_crafted(event)
    local entry = try_get(event.entity.unit_number)
    if not entry or entry[EK.type] ~= Type.caste_education_building then
        return
    end

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
        Inhabitants.add_to_city(converted_group, MoveCause.caste_conversion)
    end

    -- deactivate immediately so the building doesn't continue crafting before getting new students
    update_caste_education_building(entry)
end
