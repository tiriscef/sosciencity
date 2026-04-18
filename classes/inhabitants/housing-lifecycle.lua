local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Housing = require("constants.housing")

local get_housing_details = Housing.get
local get_capacity = Housing.get_capacity
local Tables = Tirislib.Tables
local random = math.random

-- cross-submodule references, set during load
local update_free_space_status
local try_add_to_house
local add_to_homeless_pool
local build_social_environment
local update_housing_census
local remove_housing_census
local disease_progress_updaters

function Inhabitants.load_housing_lifecycle()
    update_free_space_status = Inhabitants.update_free_space_status
    try_add_to_house = Inhabitants.try_add_to_house
    add_to_homeless_pool = Inhabitants.add_to_homeless_pool
    build_social_environment = Inhabitants.build_social_environment
    update_housing_census = Inhabitants.update_housing_census
    remove_housing_census = Inhabitants.remove_housing_census
    disease_progress_updaters = Inhabitants.disease_progress_updaters
end

---------------------------------------------------------------------------------------------------
-- << inhabited house event handlers >>

local function get_player(event)
    return event and event.player_index and game.players[event.player_index]
end

local function clamp_target_comfort(target, house_details)
    return math.min(target or 0, house_details.max_comfort)
end

local function try_upgrade_to_target(entry, player)
    if not player then return end
    while (entry[EK.current_comfort] or 0) < (entry[EK.target_comfort] or 0) do
        if Inhabitants.try_manual_upgrade(entry, player) then return end
    end
end

local function on_setting_paste_to_inhabited(source, destination, event)
    destination[EK.housing_priority] = source[EK.housing_priority] or 0
    destination[EK.target_comfort] = clamp_target_comfort(
        source[EK.target_comfort],
        get_housing_details(destination)
    )
    try_upgrade_to_target(destination, get_player(event))
end

local function on_settings_paste_to_empty(source, destination, event)
    local assigned_house = Inhabitants.try_allow_for_caste(destination, source[EK.type], true)

    if assigned_house then
        on_setting_paste_to_inhabited(source, assigned_house, event)
    else
        destination[EK.target_comfort] = clamp_target_comfort(
            source[EK.target_comfort],
            get_housing_details(destination)
        )
        try_upgrade_to_target(destination, get_player(event))
    end
end

local function on_settings_paste_empty_to_empty(source, destination, event)
    destination[EK.target_comfort] = clamp_target_comfort(
        source[EK.target_comfort],
        get_housing_details(destination)
    )
    try_upgrade_to_target(destination, get_player(event))
end

local function on_settings_paste_empty_to_inhabited(source, destination, event)
    destination[EK.target_comfort] = clamp_target_comfort(
        source[EK.target_comfort],
        get_housing_details(destination)
    )
    try_upgrade_to_target(destination, get_player(event))
end

--- Creation-Handler for houses.
--- @param entry Entry
function Inhabitants.create_house(entry)
    InhabitantGroup.new_house(entry)
    entry[EK.official_inhabitants] = 0
    entry[EK.caste_points] = 0

    entry[EK.last_age_shift] = game.tick

    entry[EK.happiness_summands] = {}
    entry[EK.happiness_factors] = {}

    entry[EK.health_summands] = {}
    entry[EK.health_factors] = {}

    entry[EK.sanity_summands] = {}
    entry[EK.sanity_factors] = {}

    entry[EK.strike_level] = 0
    entry[EK.garbage_progress] = 0

    local progresses = {}
    for disease_category in pairs(disease_progress_updaters) do
        progresses[disease_category] = 0.9 * random()
    end
    entry[EK.disease_progress] = progresses

    entry[EK.employed] = 0
    entry[EK.employments] = {}

    entry[EK.social_progress] = 0
    entry[EK.ga_conceptions] = 0

    entry[EK.blood_donation_progress] = 0.4 * random()

    entry[EK.housing_priority] = 0

    local housing_details = get_housing_details(entry)
    entry[EK.current_comfort] = housing_details.starting_comfort
    entry[EK.target_comfort] = housing_details.starting_comfort

    update_free_space_status(entry)

    Inhabitants.social_environment_change()
    build_social_environment(entry)

    storage.housing_capacity[entry[EK.type]][housing_details.is_improvised] =
        storage.housing_capacity[entry[EK.type]][housing_details.is_improvised] + get_capacity(entry)
end

--- Copy-Handler for houses.
--- @param source Entry
--- @param destination Entry
function Inhabitants.copy_house(source, destination)
    try_add_to_house(destination, source, true)
    destination[EK.last_age_shift] = source[EK.last_age_shift]
    destination[EK.disease_progress] = Tables.copy(source[EK.disease_progress])
    destination[EK.housing_priority] = source[EK.housing_priority] or 0
    destination[EK.current_comfort] = source[EK.current_comfort] or get_housing_details(source).starting_comfort
    destination[EK.target_comfort] = source[EK.target_comfort] or destination[EK.current_comfort]
    update_housing_census(destination)
end

--- Destruction-Handler for houses.
--- @param entry Entry
--- @param cause DeconstructionCause
--- @param event table?
function Inhabitants.remove_house(entry, cause, event)
    Inhabitants.unemploy_all_inhabitants(entry)
    remove_housing_census(entry)

    local unit_number = entry[EK.unit_number]
    local caste_id = entry[EK.type]
    local housing_details = get_housing_details(entry)
    storage.free_houses[housing_details.is_improvised][caste_id][unit_number] = nil

    if cause == DeconstructionCause.destroyed then
        Inhabitants.add_casualty_fear(entry)
    elseif cause == DeconstructionCause.mined then
        add_to_homeless_pool(entry)
        local buffer = event and event.buffer
        if buffer then
            for _, item in pairs(Housing.get_total_refund(housing_details, entry[EK.current_comfort] or 0)) do
                buffer.insert({name = item.name, count = item.count})
            end
        end
    end

    Inhabitants.social_environment_change()

    storage.housing_capacity[entry[EK.type]][housing_details.is_improvised] =
        storage.housing_capacity[entry[EK.type]][housing_details.is_improvised] - get_capacity(entry)
end

--- Blueprint-Handler for houses.
--- @param entry Entry
--- @return table tags
function Inhabitants.blueprint_house(entry)
    return {
        caste = entry[EK.type],
        priority = entry[EK.housing_priority],
        current_comfort = entry[EK.current_comfort],
        target_comfort = entry[EK.target_comfort]
    }
end

Register.set_settings_paste_handler(Type.empty_house, Type.empty_house, on_settings_paste_empty_to_empty)

for _, caste in pairs(Castes.all) do
    Register.set_entity_creation_handler(caste.type, Inhabitants.create_house)
    Register.set_entity_copy_handler(caste.type, Inhabitants.copy_house)
    Register.set_entity_updater(caste.type, Inhabitants.update_house)
    Register.set_entity_destruction_handler(caste.type, Inhabitants.remove_house)
    Register.set_settings_paste_handler(caste.type, caste.type, on_setting_paste_to_inhabited)
    Register.set_settings_paste_handler(caste.type, Type.empty_house, on_settings_paste_to_empty)
    Register.set_settings_paste_handler(Type.empty_house, caste.type, on_settings_paste_empty_to_inhabited)
    Register.set_blueprinted_handler(caste.type, Inhabitants.blueprint_house)
end
