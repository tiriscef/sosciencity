---Static class for the game logic of my entities.
Entity = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local all the frequently used globals for supercalifragilisticexpialidocious performance gains
local global
local caste_bonuses
local flora = Biology.flora
local water_values = DrinkingWater.values

local floor = math.floor
local map_range = Tirislib_Utils.map_range
local min = math.min
local random = math.random

local get_building_details = Buildings.get

local has_power = Subentities.has_power
local set_beacon_effects = Subentities.set_beacon_effects

local Inhabitants = Inhabitants
local Neighborhood = Neighborhood
local Tirislib_Utils = Tirislib_Utils

local function set_locals()
    global = _ENV.global
    caste_bonuses = global.caste_bonuses
end

function Entity.init()
    set_locals()
end

function Entity.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << general helper functions >>
local function get_speed_from_performance(performance)
    return floor(100 * performance - 20)
end

local function multiply_percentages(...)
    local ret = 1

    for _, v in pairs({...}) do
        ret = ret * (v / 100 + 1)
    end

    return floor((ret - 1) * 100)
end

local function set_crafting_machine_performance(entry, performance, productivity)
    entry[EK.performance] = performance

    local entity = entry[EK.entity]

    local is_active = performance >= 0.2
    entity.active = is_active

    if is_active then
        set_beacon_effects(entry, get_speed_from_performance(performance), productivity or 0, true)
    end
end

local function get_maintainance_performance()
    return 1 + (caste_bonuses[Type.clockwork] - (global.use_penalty and 80 or 0)) / 100
end

---------------------------------------------------------------------------------------------------
-- << beaconed machines >>
local function update_machine(entry)
    set_beacon_effects(entry, caste_bonuses[Type.clockwork], 0, global.use_penalty)
end
Register.set_entity_updater(Type.assembling_machine, update_machine)
Register.set_entity_updater(Type.furnace, update_machine)
Register.set_entity_updater(Type.mining_drill, update_machine)

local function update_rocket_silo(entry)
    set_beacon_effects(entry, caste_bonuses[Type.clockwork], caste_bonuses[Type.aurora], global.use_penalty)
end
Register.set_entity_updater(Type.rocket_silo, update_rocket_silo)

---------------------------------------------------------------------------------------------------
-- << composting >>
local function create_composter(entry)
    entry[EK.humus] = 0
    entry[EK.composting_progress] = 0
end
Register.set_entity_creation_handler(Type.composter, create_composter)

local compost_values = ItemConstants.compost_values
local function analyze_composter_inventory(inventory)
    local content = inventory.get_contents()
    local item_count = 0
    local item_type_count = 0
    local compostable_items = {}

    for name, count in pairs(content) do
        if compost_values[name] then
            item_count = item_count + count
            item_type_count = item_type_count + 1
            compostable_items[#compostable_items + 1] = name
        end
    end

    return item_count, item_type_count, compostable_items
end

local function remove_composted_items(inventory, count, compostable_items, entry)
    Tirislib_Tables.shuffle(compostable_items)

    local to_remove = count
    for i = 1, #compostable_items do
        local item_name = compostable_items[i]
        local removed = Inventories.try_remove(inventory, item_name, count)

        entry[EK.humus] = entry[EK.humus] + removed * compost_values[item_name]

        to_remove = to_remove - removed
        if to_remove == 0 then
            break
        end
    end

    return count - to_remove
end

local composting_coefficient = 1 / 400 / 600

local function update_composter(entry, delta_ticks)
    local inventory = Inventories.get_chest_inventory(entry)
    local item_count, item_type_count, compostable_items = analyze_composter_inventory(inventory)

    local progress = entry[EK.composting_progress]

    progress = progress + item_count * item_type_count * delta_ticks * composting_coefficient

    if progress >= 1 then
        progress = progress - remove_composted_items(inventory, floor(progress), compostable_items, entry)
    end

    entry[EK.composting_progress] = progress
end
Register.set_entity_updater(Type.composter, update_composter)

local function remove_composter(entry)
    local humus = floor(entry[EK.humus])

    if humus > 0 then
        Inventories.spill_items(entry, "humus", humus)
    end
end
Register.set_entity_destruction_handler(Type.composter, remove_composter)

local function copy_composter(source, destination)
    destination[EK.composting_progress] = source[EK.composting_progress]
    destination[EK.humus] = source[EK.humus]
end
Register.set_entity_copy_handler(Type.composter, copy_composter)

-- << composter output >>
local function update_composter_output(entry)
    local inventory = Inventories.get_chest_inventory(entry)

    for _, composter in Neighborhood.all_of_type(entry, Type.composter) do
        local humus_amount = composter[EK.humus]
        local to_output = floor(humus_amount)

        if to_output > 0 then
            local actual_output = Inventories.try_insert(inventory, "humus", to_output)

            composter[EK.humus] = humus_amount - actual_output
        end
    end
end
Register.set_entity_updater(Type.composter_output, update_composter_output)

---------------------------------------------------------------------------------------------------
-- << farms >>
local get_species = Biology.get_species

local function species_change(entry, new_species)
    entry[EK.species] = new_species
    entry[EK.biomass] = 0
end

local function biomass_to_productivity(biomass)
    return floor(biomass ^ 0.2)
end

-- put an alias in the global table so the gui can get this value
Entity.biomass_to_productivity = biomass_to_productivity

local function update_farm(entry, delta_ticks)
    local entity = entry[EK.entity]
    local species_name = get_species(entity.get_recipe())

    local productivity = caste_bonuses[Type.ember]
    local performance = 1

    if species_name ~= entry[EK.species] then
        species_change(entry, species_name)
    end

    if species_name then
        local species_details = flora[species_name]

        if species_details.persistent then
            local biomass = entry[EK.biomass] + delta_ticks * species_details.growth_coefficient
            entry[EK.biomass] = biomass

            productivity = multiply_percentages(productivity, floor(biomass ^ 0.2))
        end
    end

    set_crafting_machine_performance(entry, performance, productivity)
end
Register.set_entity_updater(Type.farm, update_farm)

---------------------------------------------------------------------------------------------------
-- << immigration port >>
local function schedule_immigration_wave(entry, building_details)
    entry[EK.next_wave] =
        (entry[EK.next_wave] or game.tick) + building_details.interval + random(building_details.random_interval) - 1
end

local function create_immigration_port(entry)
    schedule_immigration_wave(entry, get_building_details(entry))
end
Register.set_entity_creation_handler(Type.immigration_port, create_immigration_port)

local function update_immigration_port(entry, _, current_tick)
    local tick_next_wave = entry[EK.next_wave]
    if current_tick >= tick_next_wave then
        local building_details = get_building_details(entry)
        if Inventories.try_remove_item_range(entry, building_details.materials) then
            Inhabitants.migration_wave(building_details)
        end

        schedule_immigration_wave(entry, building_details)
    end
end
Register.set_entity_updater(Type.immigration_port, update_immigration_port)

---------------------------------------------------------------------------------------------------
-- << manufactory >>
local function update_manufactory(entry)
    Inhabitants.update_workforce(entry)
    local performance = Inhabitants.evaluate_workforce(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

---------------------------------------------------------------------------------------------------
-- << nightclub >>
local function update_nightclub(entry)
    if not has_power(entry) then
        entry[EK.performance] = 0
        return
    end

    local worker_performance = Inhabitants.evaluate_workforce(entry)

    -- TODO consume and evaluate drinks

    entry[EK.performance] = worker_performance
end
Register.set_entity_updater(Type.nightclub, update_nightclub)

local function create_nightclub(entry)
    entry[EK.performance] = 0
end
Register.set_entity_creation_handler(Type.nightclub, create_nightclub)

---------------------------------------------------------------------------------------------------
-- << fishery >>
local function get_water_tiles(entry, building_details)
    if global.last_tile_update > (entry[EK.last_tile_update] or -1) then
        local entity = entry[EK.entity]
        local position = entity.position
        local surface = entity.surface
        local area = Tirislib_Utils.get_range_bounding_box(position, building_details.range)
        local water_tiles = surface.count_tiles_filtered {area = area, collision_mask = "water-tile"}

        entry[EK.water_tiles] = water_tiles
        entry[EK.last_tile_update] = game.tick
        return water_tiles
    else
        -- nothing could possibly have changed, return the cached value
        return entry[EK.water_tiles]
    end
end

local function get_fishery_performance(entry)
    local worker_performance = Inhabitants.evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    local water_performance = map_range(water_tiles, 0, building_details.water_tiles, 0, 1)

    local neighborhood_performance = 1 / (Neighborhood.get_neighbor_count(entry, Type.fishery) + 1)

    return min(worker_performance, water_performance) * neighborhood_performance
end

local function update_fishery(entry)
    Inhabitants.update_workforce(entry)
    local performance = get_fishery_performance(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.fishery, update_fishery)

local function create_fishery(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.fishery, create_fishery)

---------------------------------------------------------------------------------------------------
-- << hunting hut >>
local function get_tree_count(entry, building_details)
    local entity = entry[EK.entity]
    local position = entity.position
    local surface = entity.surface
    local area = Tirislib_Utils.get_range_bounding_box(position, building_details.range)
    return surface.count_entities_filtered {area = area, type = "tree"}
end

local function get_hunting_hut_performance(entry)
    local worker_performance = Inhabitants.evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local tree_count = get_tree_count(entry, building_details)
    entry[EK.tree_count] = tree_count
    local forest_performance = map_range(tree_count, 0, building_details.tree_count, 0, 1)

    local neighborhood_performance = 1 / (Neighborhood.get_neighbor_count(entry, Type.hunting_hut) + 1)

    return min(worker_performance, forest_performance) * neighborhood_performance
end

local function update_hunting_hut(entry)
    Inhabitants.update_workforce(entry)
    local performance = get_hunting_hut_performance(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.hunting_hut, update_hunting_hut)

local function create_hunting_hut(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.hunting_hut, create_hunting_hut)

---------------------------------------------------------------------------------------------------
-- << market >>
Register.set_entity_creation_handler(Type.market, Inventories.cache_contents)
Register.set_entity_updater(Type.market, Inventories.cache_contents)

---------------------------------------------------------------------------------------------------
-- << water distributer >>
local function update_water_distributer(entry)
    local entity = entry[EK.entity]

    -- determine and save the type of water that this distributer provides
    -- this is because it's unlikely to ever change (due to the system that prevents fluids from mixing)
    -- but needs to be checked often
    if has_power(entry) then
        for fluid_name in pairs(entity.get_fluid_contents()) do
            local water_value = water_values[fluid_name]
            if water_value then
                entry[EK.water_quality] = water_value.health
                entry[EK.water_name] = fluid_name
                return
            end
        end
    end
    entry[EK.water_quality] = 0
    entry[EK.water_name] = nil
end
Register.set_entity_updater(Type.water_distributer, update_water_distributer)

---------------------------------------------------------------------------------------------------
-- << waterwell >>
local function get_waterwell_competition_performance(entry)
    -- +1 so it counts itself too
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    return near_count ^ (-0.65)
end

Entity.get_waterwell_competition_performance = get_waterwell_competition_performance

local function update_waterwell(entry)
    local performance = get_waterwell_competition_performance(entry) * min(1, get_maintainance_performance())
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function create_waterwell(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)
