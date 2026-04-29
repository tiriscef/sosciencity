local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Time = require("constants.time")

local get_building_details = Buildings.get
local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local multiply_percentages = Entity.multiply_percentages
local Fertilization = Entity.Fertilization
local Pruning = Entity.Pruning
local flora = Biology.flora
local floor = math.floor
local get_species = Biology.get_species

---Static class for farm-specific mechanics.
Entity.Farm = {}
local Farm = Entity.Farm

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
Farm.biomass_to_productivity = biomass_to_productivity

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

local function evaluate_growth_variance(flora_details)
    local gv = flora_details.growth_variance
    return square_wave(
        game.tick + gv.time_offset,
        gv.min_value,
        gv.max_value,
        gv.hold_time_max,
        gv.slope_down_time,
        gv.hold_time_min,
        gv.slope_up_time
    )
end

local function record_effect(effects, effect_id, value, dim, comb, detail)
    effects[#effects + 1] = {
        [PK.effect] = effect_id,
        [PK.value] = value,
        [PK.dimension] = dim,
        [PK.combination] = comb,
        [PK.detail] = detail
    }
end

local function update_farm(entry, delta_ticks)
    local entity = entry[EK.entity]
    local building_details = get_building_details(entry)
    local recipe = entity.get_recipe()
    local species_name = get_species(recipe)

    if species_name ~= entry[EK.species] then
        entry[EK.species] = species_name
        entry[EK.biomass] = 0
    end

    local effects = {}

    -- speed: workforce coverage gates a chain of multipliers (worker happiness, humus, growth variance, etc.)
    local workforce = evaluate_workforce(entry)
    local happiness = evaluate_worker_happiness(entry)
    record_effect(effects, PE.workforce, workforce, Dim.speed, Comb.bottleneck)
    record_effect(effects, PE.worker_happiness, happiness, Dim.speed, Comb.multiplier)
    local performance = workforce * happiness

    local humus_bonus = Fertilization.consume_for_farm(entry, delta_ticks)
    entry[EK.humus_bonus] = humus_bonus
    if humus_bonus then
        local mult = 1 + humus_bonus / 100
        record_effect(effects, PE.humus_fertilization, mult, Dim.speed, Comb.multiplier)
        performance = performance * mult
    end

    -- productivity: caste bonus + pruning + biomass; biomass is appended after speed is finalized
    local productivity = Entity.caste_bonuses[Type.orchid]
    record_effect(effects, PE.orchid_caste_bonus, productivity, Dim.productivity, Comb.flat)

    local pruning_bonus = Pruning.get_bonus_for_farm(entry)
    entry[EK.prune_bonus] = pruning_bonus > 0 and pruning_bonus or nil
    if pruning_bonus > 0 then
        productivity = multiply_percentages(productivity, pruning_bonus)
        record_effect(effects, PE.pruning, pruning_bonus, Dim.productivity, Comb.flat)
    end

    -- species-dependent effects: required-module gate, growth variance, persistent biomass
    if species_name then
        local flora_details = flora[species_name]

        if flora_details.required_module
            and not Inventories.assembler_has_module(entity, flora_details.required_module) then
            record_effect(effects, PE.required_module, 0, Dim.speed, Comb.bottleneck)
            performance = 0
        end

        if building_details.open_environment and flora_details.growth_variance then
            local mult = evaluate_growth_variance(flora_details)
            record_effect(effects, PE.growth_variance, mult, Dim.speed, Comb.multiplier)
            performance = performance * mult
        end

        if flora_details.persistent then
            local biomass = entry[EK.biomass]
            if entity.status == defines.entity_status.working then
                biomass = biomass + delta_ticks * flora_details.growth_coefficient * performance / Time.second
            end
            entry[EK.biomass] = biomass

            local biomass_bonus = biomass_to_productivity(biomass)
            if biomass_bonus > 0 then
                productivity = multiply_percentages(productivity, biomass_bonus)
                record_effect(effects, PE.biomass, biomass_bonus, Dim.productivity, Comb.flat)
            end
        end
    end

    entry[EK.performance_report] = {
        [PK.effects] = effects,
        [PK.results] = {[Dim.speed] = performance, [Dim.productivity] = productivity}
    }
    set_crafting_machine_performance(entry, performance, productivity)
end
Register.set_entity_updater(Type.farm, update_farm)

local function create_farm(entry)
    entry[EK.performance] = 1
    entry[EK.performance_report] = {[PK.effects] = {}, [PK.results] = {}}

    if get_building_details(entry).accepts_plant_care then
        entry[EK.humus_mode] = true
        entry[EK.pruning_mode] = true
    end
end
Register.set_entity_creation_handler(Type.farm, create_farm)

local function copy_farm(source, destination)
    destination[EK.biomass] = source[EK.biomass]

    destination[EK.humus_mode] = source[EK.humus_mode]
    destination[EK.pruning_mode] = source[EK.pruning_mode]

    -- preserve claim back-reference; stations keep pointing at this farm because unit_number is stable
    destination[EK.pruned_by] = source[EK.pruned_by]
end
Register.set_entity_copy_handler(Type.farm, copy_farm)

local function paste_farm_settings(source, destination)
    if get_building_details(destination).accepts_plant_care then
        destination[EK.humus_mode] = source[EK.humus_mode]
        destination[EK.pruning_mode] = source[EK.pruning_mode]
    end
end
Register.set_settings_paste_handler(Type.farm, Type.farm, paste_farm_settings)
