local DeathCause = require("enums.death-cause")
local EK = require("enums.entry-key")
local MoveCause = require("enums.move-cause")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Time = require("constants.time")

local AgeGroup = require("classes.groups.age-group")
local ImmunityGroup = require("classes.groups.immunity-group")
local InhabitantGroup = require("classes.groups.inhabitant-group")
local HousingCore = require("classes.inhabitants.housing-core")

--- Static class that handles the behaviour of the people.
Inhabitants = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.population: table
        [caste_id]: int (inhabitants count)

    storage.housing_capacity: table
        [caste_id]: table
            [bool (improvised)]: integer (capacity of all houses)

    storage.caste_points: table
        [caste_id]: float (total caste bonus points)

    storage.caste_bonuses: table
        [Type.clockwork]: integer (machine speed bonus in %)
        [Type.orchid]: integer (farm productivity bonus in %)
        [Type.gunfire]: integer (turret damage bonus in %)
        [Type.ember]: float (happiness bonus)
        [Type.plasma]: float (health bonus)
        [Type.foundry]: integer (mining productivity bonus in %)
        [Type.gleam]: integer (laboratory productivity bonus in %)
        [Type.aurora]: integer (rocket silo productivity bonus in %)

    storage.immigration: table
        [caste_id]: float (number of immigrants in the next wave)

    storage.free_houses: table
        [bool (improvised)]: table
            [caste_id]: table
                [unit_number]: truthy (lookup)

    storage.fear: float (fear level)

    storage.last_fear_event: tick

    storage.homeless: table
        [caste_id]: InhabitantGroup

    storage.last_social_change: tick

    storage.starting_clockwork_points: number

    storage.passive_redistribution_enabled: bool
]]
-- local often used globals for enormous performance gains

local immigration



local Tables = Tirislib.Tables
local Utils = Tirislib.Utils

local floor = math.floor
local max = math.max
local min = math.min
local shuffle = Tirislib.Arrays.shuffle

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local is_researched = Technologies.caste_is_researched

-- set during load, defined in the part files in classes/inhabitants/, which control.lua loads after this file
local update_caste_bonuses
local add_to_homeless_pool
local update_homelessness

local function set_locals()
    storage = _ENV.storage
    immigration = storage.immigration

    update_caste_bonuses = Inhabitants.update_caste_bonuses
    add_to_homeless_pool = Inhabitants.add_to_homeless_pool
    update_homelessness = Inhabitants.update_homelessness
end

local function new_caste_table()
    return Tirislib.LazyLuaq.from(Castes.all)
        :select(
            function(caste)
                return 0, caste.type
            end
        )
        :to_table()
end

--- Initialize the inhabitants related contents of storage.
function Inhabitants.init()
    storage = _ENV.storage

    storage.fear = 0
    storage.population = new_caste_table()
    storage.housing_capacity = {}
    storage.caste_points = new_caste_table()
    storage.caste_bonuses = new_caste_table()
    storage.immigration = new_caste_table()
    storage.passive_redistribution_enabled = true

    for _, caste in pairs(Castes.all) do
        storage.housing_capacity[caste.type] = {[true] = 0, [false] = 0}
    end

    -- submodule init
    Inhabitants.init_housing_management()
    Inhabitants.init_homelessness()
    Inhabitants.init_housing_environment()

    set_locals()
end

--- Gives the inhabitant groups of saves from before immunities existed an empty ImmunityGroup.
--- Call during on_configuration_changed, before entries get copied.
function Inhabitants.migrate_immunities()
    for _, entry in pairs(storage.register) do
        if entry[EK.diseases] and not entry[EK.immunities] then
            entry[EK.immunities] = ImmunityGroup.new()
        end
    end

    for _, group in pairs(storage.homeless) do
        group[EK.immunities] = group[EK.immunities] or ImmunityGroup.new()
    end
end

--- Converts the AgeGroups of saves from before ages were keyed by hatch day. Those were keyed by age in
--- nauvis weeks, and houses shifted them every week (EK.last_age_shift). Homeless groups never aged.<br>
--- Called by the 0.2.6 migration script, which the engine runs once per save - homeless groups have no marker of
--- their own, so a second call would age them again. Also runs on new games, where it finds nothing to convert.
function Inhabitants.migrate_ages()
    local today = AgeGroup.current_day()

    local function convert(ages, days_since_shift)
        local converted = {}
        for weeks, count in pairs(ages) do
            local hatch_day = today - 7 * weeks - days_since_shift
            converted[hatch_day] = (converted[hatch_day] or 0) + count
        end
        return converted
    end

    for _, entry in pairs(storage.register) do
        local last_shift = entry[EK.last_age_shift]
        if entry[EK.ages] and last_shift then
            entry[EK.ages] = convert(entry[EK.ages], floor((game.tick - last_shift) / Time.nauvis_day))
            entry[EK.last_age_shift] = nil
        end
    end

    for _, group in pairs(storage.homeless) do
        group[EK.ages] = convert(group[EK.ages], 0)
    end
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()

    -- submodule load
    Inhabitants.load_homelessness()
    Inhabitants.load_healthcare()
    Inhabitants.load_housing_management()
    Inhabitants.load_housing_redistribution()
    Inhabitants.load_housing_update()
    Inhabitants.load_housing_lifecycle()
end

---------------------------------------------------------------------------------------------------
-- << immigration >>

--- Processes one immigration wave from the given port, distributing immigrants into free housing.
--- @param immigration_port_details Entry
function Inhabitants.migration_wave(immigration_port_details)
    local capacity = immigration_port_details.capacity
    local order = Tables.get_keyset(immigration)
    shuffle(order)

    for i = 1, #order do
        local caste = order[i]
        local count_immigrated = min(floor(immigration[caste]), capacity)

        capacity = capacity - count_immigrated
        immigration[caste] = immigration[caste] - count_immigrated

        local immigrants = InhabitantGroup.new_immigrant_group(caste, count_immigrated)

        Inhabitants.add_to_city(immigrants, MoveCause.immigration)
    end
end

---------------------------------------------------------------------------------------------------
-- << fear >>

local FEAR_CAP = 10

--- Lowers the population's fear over time. Assumes an update rate of 10 ticks.
--- Fear decreases after 2 minutes without a tragic event; the rate is proportional to the time since the last event.
--- A fear level of 10 will decrease to 0 after roughly 15 minutes.
function Inhabitants.ease_fear(current_tick)
    local coefficient = 8e-8
    local time_since_last_event = current_tick - (storage.last_fear_event or 0)

    if time_since_last_event > Time.nauvis_day then -- 2 minutes
        storage.fear = max(0, storage.fear - time_since_last_event * coefficient)
    end
end

--- Adds fear after a civil building got destroyed.
--- Fear approaches the cap of 10 with diminishing returns: each event closes 10% of the remaining gap.
function Inhabitants.add_fear()
    storage.last_fear_event = game.tick
    storage.fear = FEAR_CAP - (FEAR_CAP - storage.fear) * 0.9
end

--- Adds fear after an inhabited house was destroyed.
--- Closes 15% of the remaining gap to the cap (larger shock than a generic building).
function Inhabitants.add_casualty_fear(destroyed_house)
    storage.last_fear_event = game.tick
    storage.fear = FEAR_CAP - (FEAR_CAP - storage.fear) * 0.85
    Communication.report_death(destroyed_house[EK.inhabitants], DeathCause.killed)
end

---------------------------------------------------------------------------------------------------
-- << general update >>

--- Periodic update: recalculates caste bonuses, handles homelessness, and runs passive redistribution.
--- @param current_tick integer
function Inhabitants.update(current_tick)
    update_caste_bonuses()

    if current_tick % Time.minute == 0 then
        update_homelessness()
    end

    if current_tick % (5 * Time.minute) == 0 then
        Inhabitants.passive_redistribution_pass()
    end
end

---------------------------------------------------------------------------------------------------
-- << public housing API >>

--- Changes the type of the entry to the given caste if it makes sense. Returns true if it did so.
--- @param entry Entry
--- @param caste_id integer
--- @param loud boolean
function Inhabitants.try_allow_for_caste(entry, caste_id, loud)
    if
        entry[EK.type] == Type.empty_house and is_researched(caste_id) and
            HousingCore.allowes_caste(HousingCore.get(entry), caste_id)
     then
        local saved_comfort = entry[EK.current_comfort]
        local saved_target = entry[EK.target_comfort]
        local saved_tags = entry[EK.trait_upgrades]
        local saved_target_tags = entry[EK.target_tags]
        local entity = entry[EK.entity]
        ItemRequests.cancel(entity, entity.get_inventory(defines.inventory.chest), entry)
        local new_entry = Register.change_type(entry, caste_id)
        new_entry[EK.current_comfort] = saved_comfort
        new_entry[EK.target_comfort] = saved_target
        new_entry[EK.trait_upgrades] = saved_tags
        new_entry[EK.target_tags] = saved_target_tags

        if loud then
            Communication.caste_allowed_in(new_entry, caste_id)
        end
        return new_entry
    else
        if loud then
            Communication.caste_not_allowed_in(entry, caste_id)
        end
        return nil
    end
end

--- Adds new inhabitants to the city. First tries to distribute to free houses, then adds the rest to the homeless pool.
--- @param group InhabitantGroup
--- @param move_cause MoveCause reason for the move, determines moving downtime
function Inhabitants.add_to_city(group, move_cause)
    Inhabitants.distribute(group, false, move_cause)
    add_to_homeless_pool(group)
end

return Inhabitants
