local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local Food = require("constants.food")
local Time = require("constants.time")

---Static class for the game logic of my entities.
Entity = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.active_animal_farms: integer
        Count of the currently active animal farms that are relevant for the zoonosis mechanic

    storage.active_machine_count: integer
        Count of the machines that were recently active and are relevant for the maintenance mechanic
]]
-- local all the frequently used globals for supercalifragilisticexpialidocious performance gains

local Utils = Tirislib.Utils

local storage
local caste_bonuses

local floor = math.floor

local get_building_details = Buildings.get

local has_power = Subentities.has_power
local set_beacon_effects = Subentities.set_beacon_effects

local evaluate_workforce = Inhabitants.evaluate_workforce

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    storage = _ENV.storage
    caste_bonuses = storage.caste_bonuses
    Entity.caste_bonuses = caste_bonuses
end

function Entity.init()
    set_locals()
    storage.active_animal_farms = 0
    storage.active_machine_count = 0
end

function Entity.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << general helper functions >>

--- Converts a performance value (0-1+) to a beacon speed bonus.
--- @param performance number
--- @return integer
local function get_speed_from_performance(performance)
    return floor(100 * performance - 20)
end
Entity.get_speed_from_performance = get_speed_from_performance

--- Combines multiple percentage bonuses multiplicatively, returning the total bonus as an integer percentage.
--- @param ... number percentage bonuses
--- @return integer combined bonus
local function multiply_percentages(...)
    local ret = 1

    for _, v in pairs({...}) do
        ret = ret * (v / 100 + 1)
    end

    return floor((ret - 1) * 100)
end
Entity.multiply_percentages = multiply_percentages

--- Sets the performance of a crafting machine entry, updating its active status and beacon effects.
--- Deactivates the entity if performance is below 0.2.
--- @param entry Entry
--- @param performance number 0-1+ performance factor
--- @param productivity integer? optional productivity bonus percentage
--- @param consumption integer? optional consumption modifier percentage (negative = less consumption)
local function set_crafting_machine_performance(entry, performance, productivity, consumption)
    entry[EK.performance] = performance

    local entity = entry[EK.entity]

    local is_active = performance > 0.19999

    entry[EK.active] = is_active
    entity.active = is_active
    Subentities.set_active(entry, is_active)

    if consumption then
        entity.consumption_modifier = 1 + consumption / 100
    end

    if is_active then
        set_beacon_effects(entry, get_speed_from_performance(performance), productivity or 0, true)
    end
end
Entity.set_crafting_machine_performance = set_crafting_machine_performance

--- Returns the maintenance performance multiplier based on the clockwork caste bonus.
--- @return number
local function get_maintenance_performance()
    return 1 + caste_bonuses[Type.clockwork] / 100
end
Entity.get_maintenance_performance = get_maintenance_performance

--- Sets the active-status for this building.
--- @param entry Entry
--- @param active boolean
--- @param inactive_custom_status CustomEntityStatus?
local function set_active(entry, active, inactive_custom_status)
    local stored = entry[EK.active]
    if stored ~= active then
        entry[EK.active] = active
        entry[EK.entity].active = active
        Subentities.set_active(entry, active)

        if active == false then
            entry[EK.entity].custom_status = inactive_custom_status
        else
            entry[EK.entity].custom_status = nil
        end
    end
end
Entity.set_active = set_active

--- Generic check for whether a building is functional: has power and sufficient workforce.
--- Used as the default active check for entity types that don't implement their own.
--- @param entry Entry
--- @return boolean
local function is_active(entry)
    return has_power(entry) and evaluate_workforce(entry) > 0.999
end
Entity.check_is_active = is_active

---------------------------------------------------------------------------------------------------
-- << circuit stuff >>

local circuit_wires = {defines.wire_type.red, defines.wire_type.green}
Entity.circuit_wires = circuit_wires

local caste_signals = {
    [Type.clockwork] = {type = "virtual", name = "signal-clockwork"},
    [Type.orchid] = {type = "virtual", name = "signal-orchid"},
    [Type.gunfire] = {type = "virtual", name = "signal-gunfire"},
    [Type.ember] = {type = "virtual", name = "signal-ember"},
    [Type.foundry] = {type = "virtual", name = "signal-foundry"},
    [Type.gleam] = {type = "virtual", name = "signal-gleam"},
    [Type.aurora] = {type = "virtual", name = "signal-aurora"},
    [Type.plasma] = {type = "virtual", name = "signal-plasma"}
}
Entity.caste_signals = caste_signals

---------------------------------------------------------------------------------------------------
-- << interface for other classes >>

--- Returns whether the entry is active, checking the cached value first and falling back to the generic check.
--- For use by other classes (Inhabitants, Inventories, GUIs) to query an entry's functional status.
--- @param entry Entry
--- @return boolean
function Entity.is_active(entry)
    return entry[EK.active] or is_active(entry)
end

---------------------------------------------------------------------------------------------------
-- << active machines logic >>

local active_time_threshold = 2 * Time.minute

--- Initializes the active machine tracking fields for an entry.
--- @param entry Entry
local function create_active_machine_status(entry)
    entry[EK.last_time_active] = -active_time_threshold
end
Entity.create_active_machine_status = create_active_machine_status

--- Updates whether this machine counts as recently active for the maintenance mechanic.
--- Increments/decrements the global active_machine_count accordingly.
--- @param entry Entry
local function update_active_machine_status(entry)
    local entity = entry[EK.entity]
    if entity.status == defines.entity_status.working then
        entry[EK.last_time_active] = game.tick
    end

    local was_active_before = entry[EK.active_machine_status]
    local is_active_now = (game.tick - entry[EK.last_time_active]) < active_time_threshold

    if not was_active_before and is_active_now then
        storage.active_machine_count = storage.active_machine_count + 1
    elseif was_active_before and not is_active_now then
        storage.active_machine_count = storage.active_machine_count - 1
    end

    entry[EK.active_machine_status] = is_active_now
end
Entity.update_active_machine_status = update_active_machine_status

--- Decrements the global active_machine_count if this entry was active. Call on destruction.
--- @param entry Entry
local function remove_active_machine_status(entry)
    if entry[EK.active_machine_status] then
        storage.active_machine_count = storage.active_machine_count - 1
    end
end
Entity.remove_active_machine_status = remove_active_machine_status

---------------------------------------------------------------------------------------------------
-- << shared utilities >>

--- Manipulates the spoil_ticks of all Food item stacks in the given inventory to simulate a slower spoil rate.
--- @param inventory LuaInventory
--- @param delta_ticks integer
--- @param percentage number
function Entity.delay_food_spoilage(inventory, delta_ticks, percentage)
    for i = 1, #inventory do
        local item_stack = inventory[i]

        if not item_stack.valid_for_read then
            goto continue
        end

        local food_definition = Food.values[item_stack.name]
        if not food_definition then
            goto continue
        end

        local spoil_tick = item_stack.spoil_tick
        if spoil_tick == 0 then
            goto continue
        end

        local max_allowed_tick = game.tick + food_definition.max_spoil[item_stack.quality.name]

        item_stack.spoil_tick = math.min(spoil_tick + Utils.round(delta_ticks * percentage), max_allowed_tick)

        ::continue::
    end
end

---------------------------------------------------------------------------------------------------
-- << per-type entity files >>

require("classes.entities.machines")
require("classes.entities.animal-farm")
require("classes.entities.caste-education")
require("classes.entities.city-combinator")
require("classes.entities.composter")
require("classes.entities.cold-storage")
require("classes.entities.fertilization")
require("classes.entities.pruning")
require("classes.entities.farm")
require("classes.entities.immigration-port")
require("classes.entities.kitchen")
require("classes.entities.manufactory")
require("classes.entities.nightclub")
require("classes.entities.social-observatory")
require("classes.entities.fishery")
require("classes.entities.hunting-hut")
require("classes.entities.salt-pond")
require("classes.entities.market")
require("classes.entities.hospital")
require("classes.entities.upbringing")
require("classes.entities.waste-dump")
require("classes.entities.water-distributer")
require("classes.entities.waterwell")
require("classes.entities.fishwhirl")
