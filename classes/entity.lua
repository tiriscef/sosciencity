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
local max = math.max
local random = math.random

local get_building_details = Buildings.get

local has_power = Subentities.has_power
local set_beacon_effects = Subentities.set_beacon_effects

local evaluate_workforce = Inhabitants.evaluate_workforce

local get_chest_inventory = Inventories.get_chest_inventory

local Inhabitants = Inhabitants
local Neighborhood = Neighborhood
local Tirislib_Utils = Tirislib_Utils
local Tirislib_Tables = Tirislib_Tables

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

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

local function is_active(entry)
    return has_power(entry) and evaluate_workforce(entry) > 0.999
end

---------------------------------------------------------------------------------------------------
-- << interface for other classes >>

function Entity.is_active(entry)
    return entry[EK.active] or is_active(entry)
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
local composting_coefficient = 1 / 400 / 600

--- Analyzes the given inventory and returns the composting progress per tick and an array of the compostable items.
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

    return item_count * item_type_count * composting_coefficient, compostable_items
end
Entity.analyze_composter_inventory = analyze_composter_inventory

local function compostify_items(inventory, count, compostable_items, entry)
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
end

local function update_composter(entry, delta_ticks)
    local inventory = get_chest_inventory(entry)
    local progress_factor, compostable_items = analyze_composter_inventory(inventory)

    local progress = entry[EK.composting_progress]

    progress = progress + progress_factor * delta_ticks

    if progress >= 1 then
        local to_consume = floor(progress)
        progress = progress - to_consume

        local capacity = get_building_details(entry).capacity
        if capacity > entry[EK.humus] then
            compostify_items(inventory, to_consume, compostable_items, entry)
        end
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
-- << plant care station >>

local function update_plant_care_station(entry, delta_ticks)

end
Register.set_entity_updater(Type.plant_care_station, update_plant_care_station)

local function create_plant_care_station(entry)
    entry[EK.humus_stored] = 0
    entry[EK.humus_mode] = true

    entry[EK.fertiliser_stored] = 0
    entry[EK.fertiliser_mode] = true

    entry[EK.pruning_mode] = true

    entry[EK.workhours] = 0
end
Register.set_entity_destruction_handler(Type.plant_care_station, create_plant_care_station)

local function copy_plant_care_station(source, destination)
    destination[EK.humus_stored] = source[EK.humus_stored]
    destination[EK.humus_mode] = source[EK.humus_mode]

    destination[EK.fertiliser_stored] = source[EK.fertiliser_stored]
    destination[EK.fertiliser_mode] = source[EK.fertiliser_mode]

    destination[EK.pruning_mode] = source[EK.pruning_mode]

    destination[EK.workhours] = source[EK.workhours]
end
Register.set_entity_copy_handler(Type.plant_care_station, copy_plant_care_station)

local function paste_plant_care_station_settings(source, destination)
    destination[EK.humus_mode] = source[EK.humus_mode]
    destination[EK.fertiliser_mode] = source[EK.fertiliser_mode]
    destination[EK.pruning_mode] = source[EK.pruning_mode]
end
Register.set_settings_paste_handler(Type.plant_care_station, Type.plant_care_station, paste_plant_care_station_settings)

---------------------------------------------------------------------------------------------------
-- << cooling warehouse >>


---------------------------------------------------------------------------------------------------
-- << waste dump >>


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
    if not cached_value or global.last_tile_update > entry[EK.last_update] then
        local entity = entry[EK.entity]
        local position = entity.position
        local area = Tirislib_Utils.get_range_bounding_box(position, building_details.range)
        local water_tiles = entity.surface.count_tiles_filtered {area = area, collision_mask = "water-tile"}

        entry[EK.water_tiles] = water_tiles
        return water_tiles
    else
        -- nothing could possibly have changed, return the cached value
        return cached_value
    end
end

local function get_fishing_competition(entry)
    local count = Neighborhood.get_neighbor_count(entry, Type.fishery)
    return 1 / (count + 1), count
end
Entity.get_fishing_competition = get_fishing_competition

local function get_fishery_performance(entry)
    local worker_performance = evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    local water_performance = map_range(water_tiles, 0, building_details.water_tiles, 0, 1)

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
    if not cached_value or global.last_entity_update > entry[EK.last_update] then
        local entity = entry[EK.entity]
        local position = entity.position
        local area = Tirislib_Utils.get_range_bounding_box(position, building_details.range)
        local trees = entity.surface.count_entities_filtered {area = area, type = "tree"}

        entry[EK.tree_count] = trees
        return trees
    else
        return cached_value
    end
end

local function get_hunting_competition(entry)
    local count = Neighborhood.get_neighbor_count(entry, Type.hunting_hut)
    return 1 / (count + 1), count
end
Entity.get_hunting_competition = get_hunting_competition

local function get_hunting_hut_performance(entry)
    local worker_performance = evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local tree_count = get_tree_count(entry, building_details)
    entry[EK.tree_count] = tree_count
    local forest_performance = map_range(tree_count, 0, building_details.tree_count, 0, 1)

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
-- << market >>

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
end
Register.set_entity_updater(Type.hospital, update_hospital)

local function create_hospital(entry)
    entry[EK.workhours] = 0
    entry[EK.treated] = {}
end
Register.set_entity_creation_handler(Type.hospital, create_hospital)

local function copy_hospital(source, destination)
    destination[EK.workhours] = source[EK.workhours]
    destination[EK.treated] = Tirislib_Tables.copy(source[EK.treated])
end
Register.set_entity_copy_handler(Type.hospital, copy_hospital)

---------------------------------------------------------------------------------------------------
-- << upbringing station >>

-- Data structure for a upbringing class object:
-- [1]: tick of creation
-- [2]: GenderGroup

local function get_upbringing_expectations(mode)
    local targeted_portion = (mode == Type.null) and 0 or 0.5

    local ret = {}
    local researched_count = 0
    for _, caste_id in pairs(TypeGroup.breedable_castes) do
        if Inhabitants.caste_is_researched(caste_id) then
            ret[caste_id] = (caste_id == mode) and targeted_portion or 0
            researched_count = researched_count + 1
        end
    end

    for caste_id, probability in pairs(ret) do
        ret[caste_id] = probability + (1 - targeted_portion) / researched_count
    end

    return ret
end
Entity.get_upbringing_expectations = get_upbringing_expectations

local function finish_class(entry, class, mode)
    local probabilities = get_upbringing_expectations(mode)
    local caste = Tirislib_Utils.weighted_random(probabilities, 1)
    local genders = class[2]
    local count = Tirislib_Tables.array_sum(genders)

    local diseases = DiseaseGroup.new(count)
    local sick_count = Tirislib_Utils.coin_flips(Inhabitants.get_birth_defect_probability(), count)
    if sick_count > 0 then
        DiseaseGroup.make_sick_randomly(diseases, DiseaseCategory.birth_defect, sick_count)
    end

    local graduates = InhabitantGroup.new(caste, count, nil, nil, nil, DiseaseGroup.new_at_birth(count), genders)
    Inhabitants.add_to_city(graduates)

    entry[EK.graduates] = entry[EK.graduates] + count
end

Entity.upbringing_time = Time.minute * 5
local upbringing_time = Entity.upbringing_time

local function update_upbringing_station(entry)
    local mode = entry[EK.education_mode]

    -- return if no caste is researched (clockwork has to be researched before all the other castes)
    if not Inhabitants.caste_is_researched(Type.clockwork) then
        return
    end

    if not is_active(entry) then
        return
    end

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
            students = students + Tirislib_Tables.array_sum(class[2])
        end
    end

    -- create new classes
    if current_tick - most_recent_class >= 30 * Time.second then
        local free_capacity = get_building_details(entry).capacity - students
        local hatched, genders = Inventories.hatch_eggs(entry, free_capacity)

        if hatched > 0 then
            classes[#classes + 1] = {current_tick, genders}
        end
    end
end
Register.set_entity_updater(Type.upbringing_station, update_upbringing_station)

local function create_upbringing_station(entry)
    entry[EK.education_mode] = Type.null
    entry[EK.classes] = {}
    entry[EK.graduates] = 0
end
Register.set_entity_creation_handler(Type.upbringing_station, create_upbringing_station)

local function copy_upbringing_station(source, destination)
    destination[EK.mode] = source[EK.mode]
    destination[EK.classes] = Tirislib_Tables.copy(source[EK.classes])
    destination[EK.graduates] = source[EK.graduates]
end
Register.set_entity_copy_handler(Type.upbringing_station, copy_upbringing_station)

local function paste_upbringing_settings(source, destination)
    destination[EK.education_mode] = source[EK.education_mode]
end
Register.set_settings_paste_handler(Type.upbringing_station, Type.upbringing_station, paste_upbringing_settings)

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

local function create_water_distributer(entry)
    entry[EK.water_quality] = 0
    entry[EK.water_name] = nil
end
Register.set_entity_creation_handler(Type.water_distributer, create_water_distributer)

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
