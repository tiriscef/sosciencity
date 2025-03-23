local DeconstructionCause = require("enums.deconstruction-cause")
local DiseaseCategory = require("enums.disease-category")
local EK = require("enums.entry-key")
local ImmigrationCause = require("enums.immigration-cause")
local Type = require("enums.type")
local WasteDumpOperationMode = require("enums.waste-dump-operation-mode")

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local DrinkingWater = require("constants.drinking-water")
local Food = require("constants.food")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")
local TypeGroup = require("constants.type-groups")

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

local Inhabitants = Inhabitants
local Neighborhood = Neighborhood
local Utils = Tirislib.Utils
local Table = Tirislib.Tables

local storage
local caste_bonuses
local flora = Biology.flora
local water_values = DrinkingWater.values

local floor = math.floor
local map_range = Utils.map_range
local min = math.min
local max = math.max
local random = math.random

local get_building_details = Buildings.get

local has_power = Subentities.has_power
local set_beacon_effects = Subentities.set_beacon_effects

local evaluate_workforce = Inhabitants.evaluate_workforce

local get_chest_inventory = Inventories.get_chest_inventory

local log_item = Communication.log_item

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    storage = _ENV.storage
    caste_bonuses = storage.caste_bonuses
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

    local is_active = performance > 0.19999

    entry[EK.active] = is_active
    entity.active = is_active
    Subentities.set_active(entry, is_active)

    if is_active then
        set_beacon_effects(entry, get_speed_from_performance(performance), productivity or 0, true)
    end
end

local function get_maintenance_performance()
    return 1 + caste_bonuses[Type.clockwork] / 100
end

local function is_active(entry)
    return has_power(entry) and evaluate_workforce(entry) > 0.999
end

---------------------------------------------------------------------------------------------------
-- << circuit stuff >>

local circuit_wires = {defines.wire_type.red, defines.wire_type.green}

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

---------------------------------------------------------------------------------------------------
-- << interface for other classes >>

function Entity.is_active(entry)
    return entry[EK.active] or is_active(entry)
end

---------------------------------------------------------------------------------------------------
-- << active machines logic >>

local active_time_threshold = 2 * Time.minute

local function create_active_machine_status(entry)
    entry[EK.last_time_active] = -active_time_threshold
end

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

local function remove_active_machine_status(entry)
    if entry[EK.active_machine_status] then
        storage.active_machine_count = storage.active_machine_count - 1
    end
end

---------------------------------------------------------------------------------------------------
-- << beaconed machines >>

Register.set_entity_creation_handler(Type.assembling_machine, create_active_machine_status)
Register.set_entity_creation_handler(Type.furnace, create_active_machine_status)
Register.set_entity_creation_handler(Type.mining_drill, create_active_machine_status)
Register.set_entity_creation_handler(Type.rocket_silo, create_active_machine_status)

local function update_machine(entry)
    local clockwork_bonus = caste_bonuses[Type.clockwork]
    local penalty_module_needed = (clockwork_bonus < 0)
    if penalty_module_needed then
        clockwork_bonus = clockwork_bonus + 80
    end

    set_beacon_effects(entry, clockwork_bonus, 0, penalty_module_needed)
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.assembling_machine, update_machine)
Register.set_entity_updater(Type.furnace, update_machine)
Register.set_entity_updater(Type.mining_drill, update_machine)

local function update_rocket_silo(entry)
    local clockwork_bonus = caste_bonuses[Type.clockwork]
    local use_penalty_module = (clockwork_bonus < 0)
    if use_penalty_module then
        clockwork_bonus = clockwork_bonus + 80
    end

    set_beacon_effects(entry, clockwork_bonus, caste_bonuses[Type.aurora], use_penalty_module)
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.rocket_silo, update_rocket_silo)

Register.set_entity_destruction_handler(Type.assembling_machine, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.furnace, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.mining_drill, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.rocket_silo, remove_active_machine_status)

---------------------------------------------------------------------------------------------------
-- << animal farms >>

local function create_animal_farm(entry)
    entry[EK.houses_animals] = false
end
Register.set_entity_creation_handler(Type.animal_farm, create_animal_farm)

local function update_animal_farm(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    local houses_animals =
        recipe and entity.status == defines.entity_status.working and
        Tirislib.String.begins_with(recipe.name, "sos-husbandry-")
    local housed_in_the_past = entry[EK.houses_animals]

    if houses_animals and not housed_in_the_past then
        storage.active_animal_farms = storage.active_animal_farms + 1
    elseif not houses_animals and housed_in_the_past then
        storage.active_animal_farms = storage.active_animal_farms - 1
    end

    entry[EK.houses_animals] = houses_animals
end
Register.set_entity_updater(Type.animal_farm, update_animal_farm)

local function remove_animal_farm(entry)
    if entry[EK.houses_animals] then
        storage.active_animal_farms = storage.active_animal_farms - 1
    end
end
Register.set_entity_destruction_handler(Type.animal_farm, remove_animal_farm)

---------------------------------------------------------------------------------------------------
-- << city combinator >>

local function update_city_combinator(entry)
    --[[local control_behavior = entry[EK.entity].get_control_behavior()

    for type, signal in pairs(caste_signals) do
        if Inhabitants.caste_is_researched(type) then
            control_behavior.set_signal(type, {signal = signal, count = storage.population[type]})
        end
    end]]

    -- TODO: This doesn't work anymore and I currently have no clue how to implement this in factorio 2
end
--Register.set_entity_updater(Type.city_combinator, update_city_combinator)

---------------------------------------------------------------------------------------------------
-- << composting >>

local function create_composter(entry)
    entry[EK.humus] = 0
    entry[EK.composting_progress] = 0
    entry[EK.necrofall_progress] = 0
end
Register.set_entity_creation_handler(Type.composter, create_composter)

local compost_values = ItemConstants.compost_values
local composting_coefficient = 1 / 400 / 600
local mold_producers = ItemConstants.mold_producers
local necrofall_coefficient = 1 / (10 * Time.minute)
local necrofall_radius = 10 -- tiles

--- Analyzes the given inventory and returns the composting progress per tick and an array of the compostable items.
--- @param content Inventory
--- @return number composting_progress per tick
--- @return array compostable_items
local function analyze_composter_inventory(content)
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

    return item_count * item_type_count * composting_coefficient, compostable_items
end
Entity.analyze_composter_inventory = analyze_composter_inventory

local function compostify_items(inventory, count, compostable_items, entry, mold_amount)
    Table.shuffle(compostable_items)

    local to_remove = count
    for i = 1, #compostable_items do
        local item_name = compostable_items[i]
        local removed = Inventories.try_remove(inventory, item_name, count)

        entry[EK.humus] = entry[EK.humus] + removed * compost_values[item_name]

        if mold_amount < 200 and mold_producers[item_name] then
            mold_amount = mold_amount + Inventories.try_insert(inventory, "mold", min(removed, 200 - mold_amount))
        end

        to_remove = to_remove - removed
        if to_remove == 0 then
            break
        end
    end
end

local function spawn_necrofall(entry, count)
    local entity = entry[EK.entity]
    local position = entity.position
    local surface = entity.surface

    while count > 0 do
        local pos = surface.find_non_colliding_position("trash-site", position, necrofall_radius, 1, false)
        if not pos then
            break
        end
        Utils.add_random_float_offset(pos, 1)

        surface.create_entity {
            name = "necrofall-circle",
            position = pos,
            force = "neutral"
        }

        count = count - 1
    end
end

local function update_composter(entry, delta_ticks)
    local inventory = get_chest_inventory(entry)
    local contents = Inventories.get_contents(inventory)
    local progress_factor, compostable_items = analyze_composter_inventory(contents)

    local progress = entry[EK.composting_progress] + progress_factor * delta_ticks

    if progress >= 1 then
        local to_consume = floor(progress)
        progress = progress - to_consume

        local capacity = get_building_details(entry).capacity
        if capacity > entry[EK.humus] then
            compostify_items(inventory, to_consume, compostable_items, entry, contents["mold"] or 0)
        end
    end

    entry[EK.composting_progress] = progress

    -- check if something is composting at all
    if progress_factor > 0 then
        local necrofall_progress = entry[EK.necrofall_progress] + necrofall_coefficient * delta_ticks

        if necrofall_progress >= 1 then
            local to_spawn = floor(necrofall_progress)

            necrofall_progress = necrofall_progress - to_spawn
            spawn_necrofall(entry, to_spawn)
        end

        entry[EK.necrofall_progress] = necrofall_progress
    end
end
Register.set_entity_updater(Type.composter, update_composter)

local function remove_composter(entry, cause)
    if not entry[EK.entity].valid then
        return
    end

    local humus = floor(entry[EK.humus])

    if cause ~= DeconstructionCause.mod_update and humus > 0 then
        Inventories.spill_items(entry, "humus", humus)
    end
end
Register.set_entity_destruction_handler(Type.composter, remove_composter)

local function copy_composter(source, destination)
    destination[EK.composting_progress] = source[EK.composting_progress]
    destination[EK.humus] = source[EK.humus]
    destination[EK.necrofall_progress] = source[EK.necrofall_progress]
end
Register.set_entity_copy_handler(Type.composter, copy_composter)

-- << composter output >>

local function update_composter_output(entry)
    local inventory = get_chest_inventory(entry)

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

local function update_farm(entry, delta_ticks)
    local entity = entry[EK.entity]
    local building_details = get_building_details(entry)
    local recipe = entity.get_recipe()
    local species_name = get_species(recipe)

    local productivity = caste_bonuses[Type.orchid]
    local performance = evaluate_workforce(entry)

    if species_name ~= entry[EK.species] then
        entry[EK.species] = species_name
        entry[EK.biomass] = 0
    end

    local accepts_plant_care = building_details.accepts_plant_care

    if accepts_plant_care and recipe and entry[EK.humus_mode] then
        local humus_needed = delta_ticks * Entity.humus_fertilitation_consumption
        local workhours_needed = delta_ticks * Entity.humus_fertilization_workhours

        local percentage_to_consume = 1

        for _, fertilization_station in Neighborhood.all_of_type(entry, Type.fertilization_station) do
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
        local workhours_needed = delta_ticks * Entity.pruning_workhours
        local workhours_consumed = 0

        for _, pruning_station in Neighborhood.all_of_type(entry, Type.pruning_station) do
            local consumed = min(pruning_station[EK.workhours], workhours_needed - workhours_consumed)

            pruning_station[EK.workhours] = pruning_station[EK.workhours] - consumed
            workhours_consumed = workhours_consumed + consumed

            if workhours_needed - workhours_consumed < 0.0001 then
                break
            end
        end

        local pruning_bonus = map_range(workhours_consumed, 0, workhours_needed, 0, Entity.pruning_productivity)
        entry[EK.prune_bonus] = pruning_bonus
        productivity = multiply_percentages(productivity, pruning_bonus)
    else
        entry[EK.prune_bonus] = nil
    end

    if species_name then
        local flora_details = flora[species_name]

        if flora_details.required_module then
            performance =
                performance * (Inventories.assembler_has_module(entity, flora_details.required_module) and 1 or 0)
        end

        if building_details.open_environment then
            -- TODO: new system for inconsistent outdoor growth
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

        local performance = Inhabitants.evaluate_workforce(entry)
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
    function(entry, cause)
        if not entry[EK.entity].valid then
            return
        end

        local humus = floor(entry[EK.humus_stored])

        if cause ~= DeconstructionCause.mod_update and humus > 0 then
            Inventories.spill_items(entry, "humus", humus, true)
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

Register.set_entity_updater(
    Type.pruning_station,
    function(entry, delta_ticks)
        local building_details = get_building_details(entry)
        local performance = Inhabitants.evaluate_workforce(entry) * (has_power(entry) and 1 or 0)
        entry[EK.performance] = performance
        entry[EK.workhours] = entry[EK.workhours] + performance * delta_ticks * building_details.speed
    end
)

Register.set_entity_creation_handler(
    Type.pruning_station,
    function(entry)
        entry[EK.workhours] = 0
    end
)

Register.set_entity_copy_handler(
    Type.pruning_station,
    function(source, destination)
        destination[EK.workhours] = source[EK.workhours]
    end
)

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
    local performance = evaluate_workforce(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

local function create_manufactory(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.manufactory, create_manufactory)

---------------------------------------------------------------------------------------------------
-- << nightclub >>

local function update_nightclub(entry)
    if not has_power(entry) then
        entry[EK.performance] = 0
        return
    end

    local worker_performance = evaluate_workforce(entry)

    -- TODO consume and evaluate drinks

    entry[EK.performance] = worker_performance
end
Register.set_entity_updater(Type.nightclub, update_nightclub)

local function create_nightclub(entry)
    entry[EK.performance] = 0
    Inhabitants.social_environment_change()
end
Register.set_entity_creation_handler(Type.nightclub, create_nightclub)

local function remove_nightclub()
    Inhabitants.social_environment_change()
end
Register.set_entity_destruction_handler(Type.nightclub, remove_nightclub)

---------------------------------------------------------------------------------------------------
-- << fishery >>

local function get_water_tiles(entry, building_details)
    local cached_value = entry[EK.water_tiles]
    if not cached_value or storage.last_tile_update > entry[EK.last_update] then
        local entity = entry[EK.entity]
        local position = entity.position
        local area = Utils.get_range_bounding_box(position, building_details.range)
        local water_tiles = entity.surface.count_tiles_filtered {area = area, collision_mask = "water_tile"}

        entry[EK.water_tiles] = water_tiles
        return water_tiles
    else
        -- nothing could possibly have changed, return the cached value
        return cached_value
    end
end

local function get_fishing_competition(entry)
    local count = Neighborhood.get_neighbor_count(entry, Type.fishery)
    return (count + 1) ^ (-0.35), count
end
Entity.get_fishing_competition = get_fishing_competition

local function get_fishery_performance(entry)
    local worker_performance = evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    local water_performance = water_tiles / building_details.water_tiles

    local neighborhood_performance = get_fishing_competition(entry)

    return min(worker_performance, water_performance) * neighborhood_performance
end

local function update_fishery(entry)
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
    local cached_value = entry[EK.tree_count]
    if not cached_value or storage.last_entity_update > entry[EK.last_update] then
        local entity = entry[EK.entity]
        local position = entity.position
        local area = Utils.get_range_bounding_box(position, building_details.range)
        local trees = entity.surface.count_entities_filtered {area = area, type = "tree"}

        entry[EK.tree_count] = trees
        return trees
    else
        return cached_value
    end
end

local function get_hunting_competition(entry)
    local count = Neighborhood.get_neighbor_count(entry, Type.hunting_hut)
    return (count + 1) ^ (-0.35), count
end
Entity.get_hunting_competition = get_hunting_competition

local function get_hunting_hut_performance(entry)
    local worker_performance = evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local tree_count = get_tree_count(entry, building_details)
    entry[EK.tree_count] = tree_count
    local forest_performance = tree_count / building_details.tree_count

    local neighborhood_performance = get_hunting_competition(entry)

    return min(worker_performance, forest_performance) * neighborhood_performance
end

local function update_hunting_hut(entry)
    local performance = get_hunting_hut_performance(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.hunting_hut, update_hunting_hut)

local function create_hunting_hut(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.hunting_hut, create_hunting_hut)

---------------------------------------------------------------------------------------------------
-- << salt pond >>

local function update_salt_pond(entry)
    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    local water_performance = map_range(water_tiles, 0, building_details.water_tiles, 0, 1)
    set_crafting_machine_performance(entry, water_performance)
end
Register.set_entity_updater(Type.salt_pond, update_salt_pond)

local function create_salt_pond(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.salt_pond, create_salt_pond)

---------------------------------------------------------------------------------------------------
-- << market >>

function Entity.market_has_food(entry)
    for item in pairs(entry[EK.inventory_contents]) do
        if Food.values[item] then
            return true
        end
    end
end

Register.set_entity_creation_handler(Type.market, Inventories.cache_contents)
Register.set_entity_updater(Type.market, Inventories.cache_contents)

---------------------------------------------------------------------------------------------------
-- << hospital >>

function Entity.get_hospital_inventories(entry)
    local ret = {get_chest_inventory(entry)}

    for _, _type in pairs(TypeGroup.hospital_complements) do
        for _, building in Neighborhood.all_of_type(entry, _type) do
            ret[#ret + 1] = get_chest_inventory(building)
        end
    end

    return ret
end

local function update_hospital(entry, delta_ticks)
    local performance = evaluate_workforce(entry)

    if not has_power(entry) then
        performance = 0
    end

    entry[EK.workhours] = entry[EK.workhours] + performance * delta_ticks * get_building_details(entry).speed
    entry[EK.performance] = performance
end
Register.set_entity_updater(Type.hospital, update_hospital)
Register.set_entity_updater(Type.improvised_hospital, update_hospital)

local function create_hospital(entry)
    entry[EK.workhours] = 0
    entry[EK.treated] = {}
    entry[EK.treatment_permissions] = {}
    entry[EK.blood_donation_threshold] = 100
    entry[EK.blood_donations] = 0
end
Register.set_entity_creation_handler(Type.hospital, create_hospital)
Register.set_entity_creation_handler(Type.improvised_hospital, create_hospital)

local function copy_hospital(source, destination)
    destination[EK.workhours] = source[EK.workhours]
    destination[EK.treated] = Table.copy(source[EK.treated])
    destination[EK.treatment_permissions] = Table.copy(source[EK.treatment_permissions])
    destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
    destination[EK.blood_donations] = source[EK.blood_donations]
end
Register.set_entity_copy_handler(Type.hospital, copy_hospital)
Register.set_entity_copy_handler(Type.improvised_hospital, copy_hospital)

local function paste_hospital_settings(source, destination)
    destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
end
Register.set_settings_paste_handler(Type.hospital, Type.hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.hospital, Type.improvised_hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.improvised_hospital, Type.hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.improvised_hospital, Type.improvised_hospital, paste_hospital_settings)

---------------------------------------------------------------------------------------------------
-- << upbringing station >>

-- Data structure for a upbringing class object:
-- [1]: tick of creation
-- [2]: GenderGroup

local caste_is_researched = Inhabitants.caste_is_researched
local get_caste_efficiency = Inhabitants.get_caste_efficiency

local function get_researched_castes()
    local ret = {}

    for _, caste_id in pairs(TypeGroup.breedable_castes) do
        if caste_is_researched(caste_id) then
            ret[#ret + 1] = caste_id
        end
    end

    return ret
end

local function get_upbringing_expectations(mode)
    local researched_castes = get_researched_castes()
    local number_of_unresearched_castes = #researched_castes

    local targeted_chance = 0
    if mode ~= Type.null then
        targeted_chance = 1 - 0.4 / (0.125 * get_caste_efficiency(mode) + 1)
        number_of_unresearched_castes = number_of_unresearched_castes - 1

        if number_of_unresearched_castes == 0 then
            targeted_chance = 1
        end
    end

    local untargeted_chance = (1 - targeted_chance) / number_of_unresearched_castes

    local ret = {}

    for _, caste_id in pairs(researched_castes) do
        if caste_id == mode then
            ret[caste_id] = targeted_chance
        else
            ret[caste_id] = untargeted_chance
        end
    end

    return ret
end
Entity.get_upbringing_expectations = get_upbringing_expectations

local function finish_class(entry, class, mode)
    local genders = class[2]
    local count = Table.array_sum(genders)
    local probabilities = get_upbringing_expectations(mode)
    local castes = Utils.dice_rolls(probabilities, count)
    local birth_defect_probability = Inhabitants.get_birth_defect_probability()

    for caste, caste_count in pairs(castes) do
        if caste_count > 0 then
            local caste_genders = GenderGroup.take(genders, caste_count)
            local caste_diseases = DiseaseGroup.new(caste_count)
            local sick_count = Utils.coin_flips(birth_defect_probability, caste_count)
            if sick_count > 0 then
                DiseaseGroup.make_sick_randomly(caste_diseases, DiseaseCategory.birth_defect, sick_count)
            end

            local graduates = InhabitantGroup.new(caste, caste_count, nil, nil, nil, caste_diseases, caste_genders)
            Inhabitants.add_to_city(graduates)
        end
    end

    entry[EK.graduates] = entry[EK.graduates] + count
    Communication.report_immigration(count, ImmigrationCause.birth)
    Communication.send_notification(
        entry,
        {
            "sosciencity.finished-class",
            count,
            Tirislib.Locales.create_enumeration_with_numbers(castes, Locale.caste_short, nil, {"sosciencity.and"}, true)
        }
    )
end

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
            students = students + Table.array_sum(class[2])
        end
    end

    -- create new classes
    if current_tick - most_recent_class >= 10 * Time.second then
        local free_capacity = details.capacity - students
        local hatched, genders = Inventories.hatch_eggs(entry, free_capacity)

        if hatched > 0 then
            classes[#classes + 1] = {current_tick, genders}
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

---------------------------------------------------------------------------------------------------
-- << waste dump >>

local garbage_values = ItemConstants.garbage_values

local function analyze_waste_dump_inventory(inventory)
    local garbage_items = {}
    local garbage_count = 0
    local non_garbage_items = {}

    for item, count in pairs(Inventories.get_contents(inventory)) do
        if garbage_values[item] ~= nil then
            garbage_items[item] = count
            garbage_count = garbage_count + count
        else
            non_garbage_items[item] = count
        end
    end

    return garbage_count, garbage_items, non_garbage_items
end

local function store_garbage(inventory, garbage_items, stored_garbage, to_store)
    for item in pairs(garbage_items) do
        local stored = inventory.remove {name = item, count = to_store}
        stored_garbage[item] = (stored_garbage[item] or 0) + stored
        to_store = to_store - stored

        if to_store < 1 then
            return
        end
    end
end

local function output_garbage(inventory, stored_garbage, to_output)
    for item, count in pairs(stored_garbage) do
        local outputable = min(count, to_output)
        if outputable > 0 then
            local output = inventory.insert {name = item, count = outputable}
            stored_garbage[item] = (count - output > 0) and (count - output) or nil
            to_output = to_output - output

            if to_output < 1 then
                return
            end
        end
    end
end

local function garbagify(inventory, to_garbagify, items, stored_garbage)
    local item_names = Table.get_keyset(items)
    Table.shuffle(item_names)

    for _, item_name in pairs(item_names) do
        local garbagified = inventory.remove {name = item_name, count = to_garbagify}
        log_item(item_name, -garbagified)
        log_item("garbage", garbagified)
        stored_garbage.garbage = (stored_garbage.garbage or 0) + garbagified
        to_garbagify = to_garbagify - garbagified

        if to_garbagify < 1 then
            return
        end
    end
end

local dump_store_rate = 200 / Time.second
local dump_output_rate = 400 / Time.second
local press_garbagify_rate = 120 / Time.second

local function update_waste_dump(entry, delta_ticks)
    local mode = entry[EK.waste_dump_mode]
    local store_progress = entry[EK.store_progress]
    local garbagify_progress = entry[EK.garbagify_progress]
    local stored_garbage = entry[EK.stored_garbage]

    local capacity = get_building_details(entry).capacity

    local inventory = get_chest_inventory(entry)
    local garbage_count, garbage_items, non_garbage_items = analyze_waste_dump_inventory(inventory)

    if mode == WasteDumpOperationMode.store then
        store_progress = store_progress + dump_store_rate * delta_ticks

        local to_store = floor(store_progress)
        store_progress = store_progress - to_store

        to_store = min(to_store, capacity - garbage_count)

        if to_store > 0 then
            store_garbage(inventory, garbage_items, stored_garbage, to_store)
        end
    elseif mode == WasteDumpOperationMode.output then
        store_progress = store_progress + dump_output_rate * delta_ticks

        local to_output = floor(store_progress)
        store_progress = store_progress - to_output

        if to_output > 0 then
            output_garbage(inventory, stored_garbage, to_output)
        end
    else
        store_progress = 0
    end

    garbage_count = Table.sum(stored_garbage)

    garbagify_progress =
        garbagify_progress + delta_ticks * (garbage_count / 6000) ^ 0.2 +
        delta_ticks * (entry[EK.press_mode] and press_garbagify_rate or 0)
    local to_garbagify = floor(garbagify_progress)
    garbagify_progress = garbagify_progress - to_garbagify
    if to_garbagify > 0 then
        garbagify(inventory, to_garbagify, non_garbage_items, stored_garbage)
    end

    entry[EK.entity].minable = (garbage_count < 1000)

    --- Garbagified items are stored and can exceed the capacity. This is not ideal but better than stopping the garbagification progress or spilling items.
    --- We try to output items if the capacity is exceeded.
    local over_capacity = Table.sum(stored_garbage) - capacity
    if over_capacity > 0 then
        output_garbage(inventory, stored_garbage, over_capacity)
    end

    entry[EK.store_progress] = store_progress
    entry[EK.garbagify_progress] = garbagify_progress
end
Register.set_entity_updater(Type.waste_dump, update_waste_dump)

local function create_waste_dump(entry)
    entry[EK.stored_garbage] = {}
    entry[EK.waste_dump_mode] = WasteDumpOperationMode.store
    entry[EK.press_mode] = false
    entry[EK.store_progress] = 0
    entry[EK.garbagify_progress] = 0
end
Register.set_entity_creation_handler(Type.waste_dump, create_waste_dump)

local function copy_waste_dump(source, destination)
    destination[EK.stored_garbage] = Table.copy(source[EK.stored_garbage])
    destination[EK.waste_dump_mode] = source[EK.waste_dump_mode]
    destination[EK.press_mode] = source[EK.press_mode]
    destination[EK.store_progress] = source[EK.store_progress]
    destination[EK.garbagify_progress] = source[EK.garbagify_progress]
end
Register.set_entity_copy_handler(Type.waste_dump, copy_waste_dump)

local function paste_waste_dump_settings(source, destination)
    destination[EK.waste_dump_mode] = source[EK.waste_dump_mode]
    destination[EK.press_mode] = source[EK.press_mode]
end
Register.set_settings_paste_handler(Type.waste_dump, Type.waste_dump, paste_waste_dump_settings)

local function remove_waste_dump(entry, cause)
    if not entry[EK.entity].valid then
        return
    end

    if cause ~= DeconstructionCause.mod_update then
        Inventories.spill_item_range(entry, entry[EK.stored_garbage], true)
    end
end
Register.set_entity_destruction_handler(Type.waste_dump, remove_waste_dump)

---------------------------------------------------------------------------------------------------
-- << water distributer >>

local function update_water_distributer(entry)
    local entity = entry[EK.entity]

    -- determine and save the type of water that this distributer provides
    -- this is because it's unlikely to ever change (due to the system that prevents fluids from mixing)
    -- but needs to be checked often
    if is_active(entry) then
        for fluid_name in pairs(entity.get_fluid_contents()) do
            local water_value = water_values[fluid_name]
            if water_value then
                entry[EK.water_quality] = water_value
                entry[EK.water_name] = fluid_name
                return
            end
        end
    end

    -- no water was found
    entry[EK.water_quality] = -1000
    entry[EK.water_name] = nil
end
Register.set_entity_updater(Type.water_distributer, update_water_distributer)

Register.set_entity_creation_handler(Type.water_distributer, update_water_distributer)

---------------------------------------------------------------------------------------------------
-- << waterwell >>

local function get_waterwell_competition_performance(entry)
    -- +1 so it counts itself too
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    return near_count ^ (-0.45)
end

Entity.get_waterwell_competition_performance = get_waterwell_competition_performance

local function update_waterwell(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    if
        recipe and recipe.name == "clean-water-from-ground" and
            not Inventories.assembler_has_module(entity, "water-filter")
     then
        set_crafting_machine_performance(entry, 0)
        return
    end

    local performance = min(get_waterwell_competition_performance(entry), get_maintenance_performance())
    set_crafting_machine_performance(entry, performance)
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function create_waterwell(entry)
    entry[EK.performance] = 1
    create_active_machine_status(entry)
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)

Register.set_entity_destruction_handler(Type.waterwell, remove_active_machine_status)

---------------------------------------------------------------------------------------------------
-- << fishwhirl >>

Events.set_on_init_handler(
    function()
        for _, surface in pairs(game.surfaces) do
            for _, entity in pairs(surface.find_entities_filtered {name = "fishwhirl"}) do
                entity.active = false
            end
        end
    end
)

Events.set_script_trigger_handler(
    "sosciencity-fishwhirl-creation",
    function(event)
        event.source_entity.active = false
    end
)
