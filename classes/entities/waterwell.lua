local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local ScriptedProducts = require("constants.scripted-products")

local Entity = require("classes.entity")
local Inventories = require("classes.inventories")
local Neighborhood = require("classes.neighborhood")
local Register = require("classes.register")

local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local create_active_machine_status = Entity.create_active_machine_status
local update_active_machine_status = Entity.update_active_machine_status
local remove_active_machine_status = Entity.remove_active_machine_status
local get_breakdown_state = Entity.get_breakdown_state
local set_breakdown_state = Entity.set_breakdown_state
local max = math.max
local required_modules = ScriptedProducts.required_modules

Entity.Waterwell = {}
local Waterwell = Entity.Waterwell

--- Returns the module that the waterwell's current recipe needs and that isn't inserted, or nil.
--- @param entry Entry
--- @return string|nil
function Waterwell.get_missing_module(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    if not recipe then
        return nil
    end
    local module = required_modules[recipe.name]
    if module and not Inventories.assembler_has_module(entity, module) then
        return module
    end
    return nil
end
local get_missing_module = Waterwell.get_missing_module

--- @param other_count integer number of other pumps in range
local function get_competition_performance(other_count)
    -- +1 so it counts itself too
    return (other_count + 1) ^ (-0.45)
end

local function get_waterwell_competition_performance(entry)
    local other_count = Neighborhood.get_neighbor_count(entry, Type.waterwell)
    return get_competition_performance(other_count), other_count
end

local function get_clockwork_boost()
    return 1 + max(0, Entity.caste_bonuses[Type.clockwork]) / 100
end

local function update_waterwell(entry)
    if get_missing_module(entry) then
        set_crafting_machine_performance(entry, 0)
        return
    end

    local competition, _ = get_waterwell_competition_performance(entry)
    set_crafting_machine_performance(entry, competition * get_clockwork_boost())

    set_breakdown_state(entry, get_breakdown_state(entry))

    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function build_waterwell_report(entry)
    if get_missing_module(entry) then
        return {[PK.effects] = {}, [PK.results] = {}}
    end

    local competition, near_count = get_waterwell_competition_performance(entry)
    local boost = get_clockwork_boost()

    return {
        [PK.effects] = {
            {
                [PK.effect] = PE.waterwell_competition,
                [PK.value] = competition,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck,
                [PK.detail] = {"sosciencity.show-waterwell-competition-count", near_count}
            },
            {
                [PK.effect] = PE.maintenance,
                [PK.value] = boost,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            }
        },
        [PK.results] = {[Dim.speed] = competition * boost}
    }
end
Entity.set_performance_report_builder(Type.waterwell, build_waterwell_report)

local function create_waterwell(entry)
    entry[EK.performance] = 1
    create_active_machine_status(entry)
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)

Register.set_entity_destruction_handler(Type.waterwell, remove_active_machine_status)

local function build_waterwell_site_report(entity, building_details)
    local other_count = Neighborhood.count_potential_neighbors(entity, Type.waterwell, building_details.range)
    local speed = Tirislib.Utils.round(100 * get_competition_performance(other_count))

    return {
        {caption = {"sosciencity.site-waterwell-competition", other_count, speed}, ok = other_count == 0}
    }
end
Entity.set_site_report_builder(Type.waterwell, build_waterwell_site_report)
