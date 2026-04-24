local DiseaseCategory = require("enums.disease-category")
local EK = require("enums.entry-key")
local ImmigrationCause = require("enums.immigration-cause")
local Type = require("enums.type")

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Time = require("constants.time")

local get_building_details = Buildings.get
local is_active = Entity.check_is_active
local circuit_wires = Entity.circuit_wires
local caste_signals = Entity.caste_signals
local Table = Tirislib.Tables
local Utils = Tirislib.Utils
local max = math.max

-- Data structure for a upbringing class object:
-- [1]: tick of creation
-- [2]: table with (item_name, count)-pairs

--- Returns the probabilities that new inhabitants will join the breedable castes with the given caste-focus of the upbringing station.
--- @param mode Type
--- @return table
local function get_upbringing_expectations(mode)
    return Tirislib.LazyLuaq.from(Castes.all)
        :where_key("breedable")
        :where(function(caste) return Inhabitants.caste_is_researched(caste.type) end)
        :select(
            function(caste)
                return mode == caste.type and 4 / 3 + 1 / 3 * Inhabitants.get_caste_efficiency_level(caste.type) or 1,
                    caste.type
            end
        )
        :normalize()
        :to_table()
end
Entity.get_upbringing_expectations = get_upbringing_expectations

local function finish_class(entry, class, mode)
    local count = Table.sum(class[2])

    local genders = GenderGroup.new()
    local diseases = DiseaseGroup.new(count)
    for egg_name, egg_count in pairs(class[2]) do
        GenderGroup.merge(genders, Utils.dice_rolls(Biology.egg_data[egg_name], egg_count, 5))

        local birth_defect_count =
            Utils.coin_flips(
                Biology.egg_data[egg_name].birth_defect_probability *
                0.8 ^ storage.technologies["improved-reproductive-healthcare"],
                egg_count
            )
        if birth_defect_count > 0 then
            DiseaseGroup.make_sick_randomly(diseases, DiseaseCategory.birth_defect, birth_defect_count)
        end
    end

    local caste_probabilities = get_upbringing_expectations(mode)
    local castes = Utils.dice_rolls(caste_probabilities, count, 20, true)

    for caste, caste_count in pairs(castes) do
        local caste_genders = GenderGroup.take(genders, caste_count)
        local caste_diseases = DiseaseGroup.take(diseases, caste_count)

        local graduates = InhabitantGroup.new(caste, caste_count, nil, nil, nil, caste_diseases, caste_genders)
        Inhabitants.add_to_city(graduates)
    end

    entry[EK.graduates] = entry[EK.graduates] + count
    Communication.report_immigration(count, ImmigrationCause.birth)
    Communication.send_notification(
        entry,
        {
            "sosciencity.finished-class",
            Locale.entry_in_chat(entry),
            count,
            Tirislib.Locales.create_enumeration_with_numbers(castes, Locale.caste_short, nil, {"sosciencity.and"}, true)
        }
    )
end
Entity.finish_upbringing_class = finish_class

local function check_circuit_upbringing_station(entry)
    local entity = entry[EK.entity]

    for _, wire in pairs(circuit_wires) do
        local circuit_network = entity.get_circuit_network(wire)
        if circuit_network then
            for type, signal in pairs(caste_signals) do
                local value = circuit_network.get_signal(signal)

                if value > 0 then
                    entry[EK.education_mode] = type
                    return
                end
            end
        end
    end
end

Entity.upbringing_time = 2 * Time.minute
local upbringing_time = Entity.upbringing_time

local function update_upbringing_station(entry)
    local mode = entry[EK.education_mode]
    local details = get_building_details(entry)

    if not is_active(entry) then
        return
    end

    if not storage.technologies["upbringing"] then
        return
    end

    check_circuit_upbringing_station(entry)

    if mode ~= Type.null and not Inhabitants.caste_is_researched(mode) then
        -- the player somehow managed to set the mode to a not researched caste
        entry[EK.education_mode] = Type.null
        mode = Type.null
    end

    local classes = entry[EK.classes]
    local most_recent_class = -30 * Time.second
    local students = 0
    local current_tick = game.tick

    -- update classes
    for i = #classes, 1, -1 do
        local class = classes[i]
        local tick_of_creation = class[1]

        if current_tick - tick_of_creation >= upbringing_time then
            finish_class(entry, class, mode)
            classes[i] = classes[#classes]
            classes[#classes] = nil
        else
            most_recent_class = max(most_recent_class, tick_of_creation)
            students = students + Table.sum(class[2])
        end
    end

    -- create new classes
    if current_tick - most_recent_class >= 10 * Time.second then
        local free_capacity = details.capacity - students
        local eggs = Inventories.remove_eggs(entry, free_capacity)

        if Table.sum(eggs) > 0 then
            classes[#classes + 1] = {current_tick, eggs}
        end
    end

    Subentities.set_power_usage(entry, (#classes > 0) and details.power_usage or details.power_drain or 0)
end
Register.set_entity_updater(Type.upbringing_station, update_upbringing_station)

local function create_upbringing_station(entry)
    entry[EK.education_mode] = Type.null
    entry[EK.classes] = {}
    entry[EK.graduates] = 0
end
Register.set_entity_creation_handler(Type.upbringing_station, create_upbringing_station)

local function copy_upbringing_station(source, destination)
    destination[EK.education_mode] = source[EK.education_mode]
    destination[EK.classes] = Table.copy(source[EK.classes])
    destination[EK.graduates] = source[EK.graduates]
end
Register.set_entity_copy_handler(Type.upbringing_station, copy_upbringing_station)

local function paste_upbringing_settings(source, destination)
    destination[EK.education_mode] = source[EK.education_mode]
end
Register.set_settings_paste_handler(Type.upbringing_station, Type.upbringing_station, paste_upbringing_settings)
