local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Time = require("constants.time")

local get_building_details = Buildings.get
local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local multiply_percentages = Entity.multiply_percentages
local has_power = Subentities.has_power
local log_item = Statistics.log_item
local flora = Biology.flora
local Utils = Tirislib.Utils
local map_range = Utils.map_range
local floor = math.floor
local min = math.min
local max = math.max
local get_species = Biology.get_species

---------------------------------------------------------------------------------------------------
-- << farms >>

local function biomass_to_productivity(biomass)
    biomass = biomass - 1000
    if biomass > 0 then
        return floor(biomass ^ 0.2)
    else
        return 0
    end
end

-- put an alias in the Entity table so the gui can get this value
Entity.biomass_to_productivity = biomass_to_productivity

Entity.pruning_productivity = 20 --%
Entity.pruning_workhours = 5 / Time.minute

Entity.humus_fertilization_speed = 30 --%
Entity.humus_fertilization_workhours = 1 / Time.minute
Entity.humus_fertilitation_consumption = 10 / Time.minute

local function square_wave(
    tick,
    min_value,
    max_value,
    hold_time_max,
    slope_down_time,
    hold_time_min,
    slope_up_time,
    interpolate)
    if not interpolate then
        interpolate = Tirislib.Utils.identity
    end

    local cycle_time = tick % (hold_time_max + slope_down_time + hold_time_min + slope_up_time)

    if cycle_time < hold_time_max then
        -- phase 1: holding the max value
        return max_value
    elseif cycle_time < hold_time_max + slope_down_time then
        -- phase 2: interpolating to min value
        local progress = (cycle_time - hold_time_max) / slope_down_time
        return max_value - (max_value - min_value) * interpolate(progress)
    elseif cycle_time < hold_time_max + slope_down_time + hold_time_min then
        -- phase 3: holding the min value
        return min_value
    else
        -- phase 4: interpolating back to max value
        local progress = (cycle_time - (hold_time_max + slope_down_time + hold_time_min)) / slope_up_time
        return min_value + (max_value - min_value) * interpolate(progress)
    end
end

local function update_farm(entry, delta_ticks)
    local entity = entry[EK.entity]
    local building_details = get_building_details(entry)
    local recipe = entity.get_recipe()
    local species_name = get_species(recipe)

    local productivity = Entity.caste_bonuses[Type.orchid]
    local performance = evaluate_workforce(entry) * evaluate_worker_happiness(entry)

    if species_name ~= entry[EK.species] then
        entry[EK.species] = species_name
        entry[EK.biomass] = 0
    end

    local accepts_plant_care = building_details.accepts_plant_care

    if accepts_plant_care and recipe and entry[EK.humus_mode] then
        local humus_needed = delta_ticks * Entity.humus_fertilitation_consumption
        local workhours_needed = delta_ticks * Entity.humus_fertilization_workhours

        local percentage_to_consume = 1

        for _, fertilization_station in Neighborhood.iterate_type(entry, Type.fertilization_station) do
            local humus_available = fertilization_station[EK.humus_stored]
            local workhours_available = fertilization_station[EK.workhours]

            local percentage_available =
                min(
                    percentage_to_consume,
                    humus_available / humus_needed * percentage_to_consume,
                    workhours_available / workhours_needed * percentage_to_consume
                )

            percentage_to_consume = percentage_to_consume - percentage_available
            local consumed_humus = humus_needed * percentage_available
            fertilization_station[EK.humus_stored] = humus_available - consumed_humus
            fertilization_station[EK.workhours] = workhours_available - workhours_needed * percentage_available

            log_item("humus", -consumed_humus)

            if percentage_to_consume < 0.0001 then
                break
            end
        end

        local humus_bonus = map_range(percentage_to_consume, 1, 0, 0, Entity.humus_fertilization_speed)
        entry[EK.humus_bonus] = humus_bonus
        performance = performance * map_range(percentage_to_consume, 1, 0, 1, 1 + humus_bonus / 100)
    else
        entry[EK.humus_bonus] = nil
    end

    if accepts_plant_care and recipe and entry[EK.pruning_mode] then
        local pruned_by_uid = entry[EK.pruned_by]
        local is_pruned = false

        if pruned_by_uid then
            local station = Register.try_get(pruned_by_uid)
            if station and station[EK.active] then
                is_pruned = true
            else
                entry[EK.pruned_by] = nil
            end
        end

        local pruning_bonus = is_pruned and Entity.pruning_productivity or 0
        entry[EK.prune_bonus] = pruning_bonus
        productivity = multiply_percentages(productivity, pruning_bonus)
    else
        entry[EK.prune_bonus] = nil
        -- release any dangling claim when pruning mode is off
        if entry[EK.pruned_by] then
            entry[EK.pruned_by] = nil
        end
    end

    if species_name then
        local flora_details = flora[species_name]

        if flora_details.required_module and not Inventories.assembler_has_module(entity, flora_details.required_module) then
            performance = 0
        end

        if building_details.open_environment and flora_details.growth_variance then
            local growth_variance = flora_details.growth_variance
            performance =
                performance *
                square_wave(
                    game.tick + growth_variance.time_offset,
                    growth_variance.min_value,
                    growth_variance.max_value,
                    growth_variance.hold_time_max,
                    growth_variance.slope_down_time,
                    growth_variance.hold_time_min,
                    growth_variance.slope_up_time
                )
        end

        if flora_details.persistent then
            local biomass = entry[EK.biomass]
            if entity.status == defines.entity_status.working then
                biomass = biomass + delta_ticks * flora_details.growth_coefficient * performance / Time.second
            end
            entry[EK.biomass] = biomass

            productivity = multiply_percentages(productivity, biomass ^ 0.2)
        end
    end

    set_crafting_machine_performance(entry, performance, productivity)
end
Register.set_entity_updater(Type.farm, update_farm)
Register.set_entity_updater(Type.automatic_farm, update_farm)

local function create_farm(entry)
    entry[EK.performance] = 1

    if get_building_details(entry).accepts_plant_care then
        entry[EK.humus_mode] = true
        entry[EK.pruning_mode] = true
    end
end
Register.set_entity_creation_handler(Type.farm, create_farm)
Register.set_entity_creation_handler(Type.automatic_farm, create_farm)

local function copy_farm(source, destination)
    destination[EK.biomass] = source[EK.biomass]

    destination[EK.humus_mode] = source[EK.humus_mode]
    destination[EK.pruning_mode] = source[EK.pruning_mode]

    -- preserve claim back-reference; stations keep pointing at this farm because unit_number is stable
    destination[EK.pruned_by] = source[EK.pruned_by]
end
Register.set_entity_copy_handler(Type.farm, copy_farm)
Register.set_entity_copy_handler(Type.automatic_farm, copy_farm)

local function paste_farm_settings(source, destination)
    if get_building_details(destination).accepts_plant_care then
        destination[EK.humus_mode] = source[EK.humus_mode]
        destination[EK.pruning_mode] = source[EK.pruning_mode]
    end
end
Register.set_settings_paste_handler(Type.farm, Type.farm, paste_farm_settings)
-- at the moment: no paste handler for automatic_farms because these cannot have humus/pruning modes and that's all the handler does

---------------------------------------------------------------------------------------------------
-- << fertilization station >>

Register.set_entity_updater(
    Type.fertilization_station,
    function(entry, delta_ticks)
        local building_details = get_building_details(entry)

        local performance = Inhabitants.evaluate_workforce(entry) * Inhabitants.evaluate_worker_happiness(entry)
        entry[EK.performance] = performance

        entry[EK.workhours] = entry[EK.workhours] + performance * delta_ticks * building_details.speed

        local humus_stored = entry[EK.humus_stored]
        local free_humus_capacity = building_details.humus_capacity - humus_stored
        if free_humus_capacity >= 1 then
            local inventory = Inventories.get_chest_inventory(entry)
            entry[EK.humus_stored] =
                humus_stored + inventory.remove {name = "humus", count = floor(free_humus_capacity)}
        end
    end
)

Register.set_entity_creation_handler(
    Type.fertilization_station,
    function(entry)
        entry[EK.humus_stored] = 0

        --entry[EK.fertiliser_stored] = 0

        entry[EK.workhours] = 0
    end
)

Register.set_entity_destruction_handler(
    Type.fertilization_station,
    function(entry, cause, event)
        if not entry[EK.entity].valid then
            return
        end

        local humus = floor(entry[EK.humus_stored])

        if cause == DeconstructionCause.destroyed and humus > 0 then
            Inventories.spill_items(entry, "humus", humus / 10)
        end
        if cause == DeconstructionCause.mined and humus > 0 then
            event.buffer.insert {name = "humus", count = humus}
        end
    end
)

Register.set_entity_copy_handler(
    Type.fertilization_station,
    function(source, destination)
        destination[EK.humus_stored] = source[EK.humus_stored]

        --destination[EK.fertiliser_stored] = source[EK.fertiliser_stored]

        destination[EK.workhours] = source[EK.workhours]
    end
)

---------------------------------------------------------------------------------------------------
-- << pruning station >>

local try_get = Register.try_get

local function is_valid_prune_target(farm)
    return farm[EK.entity].valid
        and get_building_details(farm).accepts_plant_care
        and farm[EK.pruning_mode]
end

Register.set_entity_updater(
    Type.pruning_station,
    function(entry, delta_ticks)
        local building_details = get_building_details(entry)
        local performance = evaluate_workforce(entry) * evaluate_worker_happiness(entry) * (has_power(entry) and 1 or 0)
        entry[EK.performance] = performance

        local max_slots = building_details.slots
        -- 10%-floor on performance damps tick-to-tick slot thrashing
        local effective_slots = floor(max_slots * floor(performance * 10) / 10)

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
