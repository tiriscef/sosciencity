local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local has_power = Subentities.has_power
local try_get = Register.try_get
local floor = math.floor

--- Static class for plant-pruning mechanics.
Entity.Pruning = {}
local Pruning = Entity.Pruning

--- Productivity bonus % granted to a farm by an active pruning station.
Pruning.productivity = 20 --%

--- Effective slot count for a pruning station at the given performance.
--- Performance is floored to the nearest 10% to damp tick-to-tick slot thrashing;
--- shared between the updater and the details GUI.
function Pruning.effective_slots(performance, max_slots)
    return floor(max_slots * floor(performance * 10) / 10)
end

--- Returns the productivity bonus % a farm currently receives from being pruned (0 if not pruned).
--- Releases dangling claims when the claiming station is gone, inactive, or pruning mode is off.
--- @param farm Entry
--- @return integer bonus percentage
function Pruning.get_bonus_for_farm(farm)
    if not (farm[EK.pruning_mode] and get_building_details(farm).accepts_plant_care) then
        if farm[EK.pruned_by] then
            farm[EK.pruned_by] = nil
        end
        return 0
    end

    local pruned_by_uid = farm[EK.pruned_by]
    if not pruned_by_uid then
        return 0
    end

    local station = try_get(pruned_by_uid)
    if station and station[EK.active] then
        return Pruning.productivity
    end

    farm[EK.pruned_by] = nil
    return 0
end

---------------------------------------------------------------------------------------------------
-- << pruning station >>

local function is_valid_prune_target(farm)
    return farm[EK.entity].valid
        and get_building_details(farm).accepts_plant_care
        and farm[EK.pruning_mode]
end

--- Writes a fake-tooltip custom_status showing pruning slot occupancy.
--- @param entry Entry pruning station
--- @param filled integer
--- @param effective_slots integer slots currently usable given performance
--- @param max_slots integer absolute capacity at 100% performance
local function set_pruning_custom_status(entry, filled, effective_slots, max_slots)
    local diode, header
    if effective_slots == 0 then
        diode = defines.entity_status_diode.red
        header = "sosciencity-custom-status.pruning-inactive"
    elseif filled == 0 then
        diode = defines.entity_status_diode.yellow
        header = "sosciencity-custom-status.pruning-idle"
    else
        diode = defines.entity_status_diode.green
        header = "sosciencity-custom-status.pruning-pruning"
    end

    local label = {header}
    if effective_slots < max_slots then
        Tirislib.Locales.append(label, {"sosciencity-custom-status.pruning-slots-capped", filled, effective_slots, max_slots})
    else
        Tirislib.Locales.append(label, {"sosciencity-custom-status.pruning-slots", filled, effective_slots})
    end

    entry[EK.entity].custom_status = {
        diode = diode,
        label = label
    }
end

Register.set_entity_updater(
    Type.pruning_station,
    function(entry, delta_ticks)
        local building_details = get_building_details(entry)
        local performance = evaluate_workforce(entry) * evaluate_worker_happiness(entry) * (has_power(entry) and 1 or 0)
        entry[EK.performance] = performance

        local max_slots = building_details.slots
        local effective_slots = Pruning.effective_slots(performance, max_slots)

        local slots = entry[EK.slots]
        local unit_number = entry[EK.unit_number]
        local neighbor_farms = (entry[EK.neighbors] and entry[EK.neighbors][Type.farm]) or {}

        -- validate existing slots: release any whose target has become invalid or is no longer a neighbor
        for i = #slots, 1, -1 do
            local target_uid = slots[i]
            local target = try_get(target_uid)
            local still_ours = target
                and neighbor_farms[target_uid]
                and is_valid_prune_target(target)
                and target[EK.pruned_by] == unit_number
            if not still_ours then
                if target and target[EK.pruned_by] == unit_number then
                    target[EK.pruned_by] = nil
                end
                table.remove(slots, i)
            end
        end

        -- shrink to effective_slots when performance drops; drop newest claims first so FIFO is preserved
        while #slots > effective_slots do
            local target_uid = slots[#slots]
            slots[#slots] = nil
            local target = try_get(target_uid)
            if target and target[EK.pruned_by] == unit_number then
                target[EK.pruned_by] = nil
            end
        end

        -- claim free neighbor farms up to capacity
        if #slots < effective_slots then
            for _, farm in Neighborhood.iterate_type(entry, Type.farm) do
                if #slots >= effective_slots then
                    break
                end
                if is_valid_prune_target(farm) and not farm[EK.pruned_by] then
                    slots[#slots + 1] = farm[EK.unit_number]
                    farm[EK.pruned_by] = unit_number
                end
            end
        end

        entry[EK.active] = #slots > 0

        set_pruning_custom_status(entry, #slots, effective_slots, max_slots)
    end
)

Register.set_entity_creation_handler(
    Type.pruning_station,
    function(entry)
        entry[EK.slots] = {}
    end
)

Register.set_entity_copy_handler(
    Type.pruning_station,
    function(source, destination)
        -- unit_numbers are stable across Register.clone, so farm back-references to source.unit_number
        -- remain valid for destination as well. When migrating from a pre-slot save, source[EK.slots]
        -- is nil and the creation handler's empty-table default stays.
        if source[EK.slots] then
            destination[EK.slots] = Tirislib.Tables.copy(source[EK.slots])
        end
    end
)
