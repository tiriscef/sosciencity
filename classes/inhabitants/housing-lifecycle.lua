local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local HappinessSummand = require("enums.happiness-summand")
local HappinessFactor = require("enums.happiness-factor")
local HealthSummand = require("enums.health-summand")
local HealthFactor = require("enums.health-factor")
local SanitySummand = require("enums.sanity-summand")
local SanityFactor = require("enums.sanity-factor")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Housing = require("constants.housing")

local get_housing_details = Housing.get
local get_capacity = Housing.get_capacity
local Arrays = Tirislib.Arrays
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

local function on_setting_paste_to_inhabited(source, destination)
    destination[EK.housing_priority] = source[EK.housing_priority] or 0
end

local function on_settings_paste_to_empty(source, destination)
    local success = Inhabitants.try_allow_for_caste(destination, source[EK.type], true)

    if success then
        on_setting_paste_to_inhabited(source, destination)
    end
end

--- Creation-Handler for houses.
--- @param entry Entry
function Inhabitants.create_house(entry)
    InhabitantGroup.new_house(entry)
    entry[EK.official_inhabitants] = 0
    entry[EK.caste_points] = 0

    entry[EK.last_age_shift] = game.tick

    entry[EK.happiness_summands] = Arrays.new(Tables.count(HappinessSummand), 0.)
    entry[EK.happiness_factors] = Arrays.new(Tables.count(HappinessFactor), 1.)

    entry[EK.health_summands] = Arrays.new(Tables.count(HealthSummand), 0.)
    entry[EK.health_factors] = Arrays.new(Tables.count(HealthFactor), 1.)

    entry[EK.sanity_summands] = Arrays.new(Tables.count(SanitySummand), 0.)
    entry[EK.sanity_factors] = Arrays.new(Tables.count(SanityFactor), 1.)

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

    update_free_space_status(entry)

    Inhabitants.social_environment_change()
    build_social_environment(entry)

    local housing_details = get_housing_details(entry)
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
    update_housing_census(destination)
end

--- Destruction-Handler for houses.
--- @param entry Entry
--- @param cause DeconstructionCause
function Inhabitants.remove_house(entry, cause)
    Inhabitants.unemploy_all_inhabitants(entry)
    remove_housing_census(entry)

    local unit_number = entry[EK.unit_number]
    local caste_id = entry[EK.type]
    local improvised = get_housing_details(entry).is_improvised
    storage.free_houses[improvised][caste_id][unit_number] = nil

    if cause == DeconstructionCause.destroyed then
        Inhabitants.add_casualty_fear(entry)
    elseif cause == DeconstructionCause.mined then
        add_to_homeless_pool(entry)
    end

    Inhabitants.social_environment_change()

    local housing_details = get_housing_details(entry)
    storage.housing_capacity[entry[EK.type]][housing_details.is_improvised] =
        storage.housing_capacity[entry[EK.type]][housing_details.is_improvised] - get_capacity(entry)
end

--- Blueprint-Handler for houses.
--- @param entry Entry
--- @return table tags
function Inhabitants.blueprint_house(entry)
    return {
        caste = entry[EK.type],
        priority = entry[EK.housing_priority]
    }
end

-- Register event handlers for all inhabited housing types.
local update_house_wrapper = function(entry, delta_ticks) Inhabitants.update_house(entry, delta_ticks) end

for _, caste in pairs(Castes.all) do
    Register.set_entity_creation_handler(caste.type, Inhabitants.create_house)
    Register.set_entity_copy_handler(caste.type, Inhabitants.copy_house)
    Register.set_entity_updater(caste.type, update_house_wrapper)
    Register.set_entity_destruction_handler(caste.type, Inhabitants.remove_house)
    Register.set_settings_paste_handler(caste.type, caste.type, on_setting_paste_to_inhabited)
    Register.set_settings_paste_handler(caste.type, Type.empty_house, on_settings_paste_to_empty)
    Register.set_blueprinted_handler(caste.type, Inhabitants.blueprint_house)
end
