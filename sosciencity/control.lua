local dataphase_test = true

if dataphase_test then
    return
end

--[[
    Data structures

    global.register: table
        [LuaEntity.unit_number]: registered_entity

    registered_entity: table
        ["type"]: int/enum
        ["entity"]: LuaEntity
        ["last_update"]: uint (tick)
        ["subentities"]: table of (subentity type, entity) pairs
        ["neighborhood"]: table
        ["neughborhood_data"]: table
        ["flags"]: table of int/enum

        -- Housing
        ["inhabitants"]: int
        ["happiness"]: float
        ["food"]: table

    food: table
        ["healthiness_dietary"]: float
        ["healthiness_mental"]: float
        ["satisfaction"]: float
        ["count"]: int
        ["flags"]: table of strings

    neighborhood: table
        [entity type]: table of (unit_number, entity) pairs

    neighborhood_data: table
        [] TODO

    global.population: table
        [caste_type]: int (count)

    global.effective_population: table
        [caste_type]: float

    global.panic: float

    global.pharmacies: table of unit_numbers
]]
---------------------------------------------------------------------------------------------------
-- << runtime finals >>
require("constants.castes")
require("constants.diseases")
require("constants.types")
require("constants.food")
require("constants.housing")

---------------------------------------------------------------------------------------------------
-- << helper functions >>
require("lib.table")

---------------------------------------------------------------------------------------------------
-- << subentities >>
local function add_subentity(registered_entity, type)
    local subentity =
        registered_entity.entity.surface.create_entity {
        name = Types.subentity_lookup[type],
        position = registered_entity.entity.position,
        force = registered_entity.entity.force
    }

    registered_entity.subentities[type] = subentity
end

-- Assumes that the entry has a beacon.
-- speed and productivity need to be positive
local function set_beacon_effects(registered_entity, speed, productivity, add_penalty)
    local beacon_inventory = registered_entity.subentities[SUB_BEACON].get_module_inventory()
    beacon_inventory.clear()

    if speed and speed > 0 then
        -- ceil to make sure we don't end up attempting to insert 0 modules
        speed = math.ceil(speed)

        beacon_inventory.insert {
            name = "sosciencity-speed-module",
            count = speed % 100
        }
        beacon_inventory.insert {
            name = "sosciencity-speed-module-100",
            count = speed / 100
        }
    end

    if productivity and productivity > 0 then
        -- ceil to make sure we don't end up attempting to insert 0 modules
        productivity = math.ceil(productivity)

        beacon_inventory.insert {
            name = "sosciencity-productivity-module",
            count = productivity % 100
        }
        beacon_inventory.insert {
            name = "sosciencity-productivity-module-100",
            count = productivity / 100
        }
    end

    if add_penalty then
        beacon_inventory.insert {
            name = "sosciencity-speed-penalty-module",
            count = 1
        }
    end
end

-- Checks if the entity is supplied with power. Assumes that the entry has an eei.
local function has_power(registered_entity)
    -- check if the buffer is partially filled
    return registered_entity.subentities[SUB_EEI].power > 0
end

-- Sets the power usage of the entity. Assumes that the entry has an eei.
-- usage seems to be in W
local function set_power_usage(registered_entity, usage)
    registered_entity.subentities[SUB_EEI].power_usage = usage
end

---------------------------------------------------------------------------------------------------
-- << neighborhood functions >>
local function add_neighborhood_data(registered_entity, type)
    -- TODO
end

local function get_neighbors_of_type(registered_entity, type)
    if not registered_entity.neighborhood or not registered_entity.neighborhood[type] then
        return {}
    end

    local ret = {}

    for unit_number, entity in pairs(registered_entity.neighborhood[type]) do
        if not entity.valid then
            registered_entity.neighborhood[unit_number] = nil
        else
            table.insert(ret, entity)
        end
    end

    return ret
end

---------------------------------------------------------------------------------------------------
-- << register system >>
local function add_housing_data(registered_entity)
    registered_entity.happiness = 0
    registered_entity.healthiness = 0
    registered_entity.healthiness_mental = 0
    registered_entity.ideas = 0
    registered_entity.inhabitants = 0
    registered_entity.trend = 0
end

local function establish_registered_entity(entity)
    local type = Types(entity)

    local registered_entity = {
        entity = entity,
        type = type,
        last_update = game.tick,
        subentities = {}
    }

    if Types:is_housing(type) then
        add_housing_data(registered_entity)
    end
    if Types:needs_beacon(type) then
        add_subentity(registered_entity, SUB_BEACON)
    end
    if Types:needs_eei(type) then
        add_subentity(registered_entity, SUB_EEI)
    end
    if Types:needs_neighborhood(type) then
        add_neighborhood_data(registered_entity, type)
    end

    return registered_entity
end

local function add_entity_to_register(entity)
    local registered_entity = establish_registered_entity(entity)
    global.register[entity.unit_number] = registered_entity
end

local function remove_from_register(registered_entity)
    global.register[registered_entity.entity] = nil

    for _, subentity in pairs(registered_entity.subentities) do
        if subentity.valid then
            subentity.destroy()
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << diet functions >>

-- Checks the local market entities if they have different food items and tries to transfer them.
-- Returns true if an item transaction has occured.
local function check_markets(registered_entity, diet, house_inventory)
    local ret = false

    for _, market in pairs(get_neighbors_of_type(registered_entity, NEIGHBOR_MARKET)) do
        local market_inventory = market.get_inventory(defines.inventory.chest)
        local inventory_size = #market_inventory
        local caste = Caste(registered_entity)

        for i = 1, inventory_size do
            local slot = market_inventory[i]
            if slot.valid_for_read then
                local item_name = slot.name
                if
                    Food(item_name) and not diet[item_name] and
                        caste.least_favored_taste ~= Food(item_name).taste_category
                 then
                -- TODO
                end
            end
        end
    end

    return ret
end

-- returns a table with every available food item type as keys
local function get_diet(inventory)
    local diet = {}
    local inventory_size = #inventory

    for i = 1, inventory_size do
        local slot = inventory[i]
        if slot.valid_for_read then -- check if the slot has an item in it
            local item_name = slot.name
            if Food[item_name] and not diet[item_name] then
                diet[item_name] = item_name
            end
        end
    end

    return diet
end

local function get_protein_healthiness(percentage)
    -- this is a cubic spline through the following points:
    -- (0, -1), (0.1, -0.5), (0.2, 1), (0.3, 0), (0.5, -1)
    if percentage < 0.1 then
        return 447.67 * percentage ^ 3 + 0.5232 * percentage - 1
    elseif percentage < 0.2 then
        return -1238.37 * percentage ^ 3 + 505.81 * percentage ^ 2 - 50.05 * percentage + 0.69
    elseif percentage < 0.3 then
        return 1005.81 * percentage ^ 3 - 840.7 * percentage ^ 2 + 219.24 * percentage - 17.27
    elseif percentage < 0.5 then
        return -107.56 * percentage ^ 3 + 161.34 * percentage ^ 2 - 81.37 * percentage + 12.79
    else
        return -1
    end
end

local function get_fat_ratio_healthiness(ratio)
    -- this is a cubic spline through the following points:
    -- (0, -1), (0.375, 1), (0.75, -1)
    if ratio < 0.375 then
        return -18.96 * ratio ^ 3 + 8 * ratio - 1
    elseif ratio < 0.75 then
        return 18.96 * ratio ^ 3 - 42.67 * ratio ^ 2 + 24 * ratio - 3
    else
        return -1
    end
end

-- returns a numerical healthiness value in the range 0 to 1 for the given nutrient combination
-- and adds flags for extreme values.
local function get_nutrient_healthiness(fat, carbohydrates, proteins, flags)
    -- optimal diet consists of 30% fat, 50% carbohydrates and 20% proteins
    -- we focus on a reasonable amount of protein
    local protein_percentage = proteins / (fat + carbohydrates + proteins)
    if protein_percentage < 0.1 then
        table.insert(flags, FLAG_LOW_PROTEIN)
    elseif protein_percentage > 0.4 then
        table.insert(flags, FLAG_HIGH_PROTEIN)
    end

    -- and the fat to carbohydrates ratio (optimum is 0.375)
    local fat_to_carbohydrates_ratio = fat / (fat + carbohydrates)
    if fat_to_carbohydrates_ratio > 0.5 then
        table.insert(flags, FLAG_HIGH_FAT)
    elseif fat_to_carbohydrates_ratio < 0.1 then
        table.insert(flags, FLAG_HIGH_CARBOHYDRATES)
    end

    return 0.25 *
        (2 + get_fat_ratio_healthiness(fat_to_carbohydrates_ratio) + get_protein_healthiness(protein_percentage))
end

local function get_diet_effects(diet, caste_type)
    -- calculate features
    local count = 0
    local intrinsic_healthiness = 0
    local fat = 0
    local carbohydrates = 0
    local proteins = 0
    local taste_quality = 0
    local taste_category_counts = {
        [TASTE_BITTER] = 0,
        [TASTE_NEUTRAL] = 0,
        [TASTE_SALTY] = 0,
        [TASTE_SOUR] = 0,
        [TASTE_SPICY] = 0,
        [TASTE_SWEET] = 0,
        [TASTE_UMAMI] = 0
    }
    local luxority = 0
    local flags = {}
    local caste = Caste(caste_type)

    for item_name, _ in pairs(diet) do
        count = count + 1

        local values = Food.values[item_name]

        intrinsic_healthiness = intrinsic_healthiness + values.healthiness
        fat = fat + values.fat
        carbohydrates = carbohydrates + values.carbohydrates
        proteins = proteins + values.proteins
        taste_quality = taste_quality + values.taste_quality
        taste_category_counts[values.taste_category] = taste_category_counts[values.taste_category] + 1
        luxority = luxority + values.luxority
    end

    local dominant_taste = TASTE_BITTER
    for current_taste_category, current_count in pairs(taste_category_counts) do
        if current_count > taste_category_counts[dominant_taste] then
            dominant_taste = current_taste_category
        end
    end

    intrinsic_healthiness = intrinsic_healthiness / count
    taste_quality = taste_quality / count
    luxority = luxority / count

    -- evaluate features
    local mental_healthiness = 1
    -- TODO scale
    local dietary_healthiness =
        0.5 * (intrinsic_healthiness + get_nutrient_healthiness(fat, carbohydrates, proteins, flags))

    local satisfaction =
        (1 - 0.5 * caste.desire_for_luxority) * taste_quality + 0.5 * caste.desire_for_luxority * luxority

    if count == 1 or taste_category_counts[TASTE_NEUTRAL] == count or dominant_taste == caste.least_favored_taste then
        mental_healthiness = 0
    end

    return {
        healthiness_dietary = dietary_healthiness,
        healthiness_mental = mental_healthiness,
        satisfaction = satisfaction,
        count = count,
        flags = flags
    }
end

local function consume_specific_food(inventory, amount, item_name)
    local inventory_size = #inventory
    local to_consume = amount

    for i = 1, inventory_size do
        local slot = inventory[i]
        if slot.valid_for_read then -- check if the slot has an item in it
            if slot.name == item_name then
                to_consume = to_consume - slot.drain_durability(to_consume)
                if to_consume < 0.001 then
                    return amount -- everything was consumed
                end
            end
        end
    end

    return amount - to_consume
end

-- Tries to consume the given amount of calories. Returns the percentage of the amount that
-- was consumed
local function consume_food(inventory, amount, diet, diet_effects)
    local count = diet_effects.count
    local items = get_keyset(diet)
    local to_consume = amount
    shuffle(items)

    for i = 1, count do
        to_consume = to_consume - consume_specific_food(inventory, to_consume, items[i])
        if to_consume < 0.001 then
            return 1 -- 100% was consumed
        end
    end

    return (amount - to_consume) / amount
end

local function apply_hunger_effects(diet_effects, percentage)
    diet_effects.satisfaction = diet_effects.satisfaction * percentage - 5 * (1 - percentage)
    diet_effects.healthiness_dietary = diet_effects.healthiness_dietary * percentage - 5 * (1 - percentage)

    if percentage < 0.5 then
        table.insert(diet_effects.flags, FLAG_HUNGER)
    end
end

-- Assumes the entity is a housing entity
local function evaluate_diet(registered_entity, delta_ticks)
    local house_inventory = registered_entity.entity.get_inventory(defines.inventory.chest)
    local diet = get_diet(house_inventory)

    check_markets(registered_entity, diet, house_inventory)

    local diet_effects = get_diet_effects(diet, registered_entity.type)

    local to_consume = Caste(registered_entity).calorific_demand * delta_ticks * registered_entity.inhabitants
    local hunger_satisfaction = consume_food(house_inventory, to_consume, diet_effects)
    apply_hunger_effects(diet_effects, hunger_satisfaction)

    return diet_effects
end

---------------------------------------------------------------------------------------------------
-- << hidden technology functions >>
local function set_researched(tech_name, is_researched)
    -- we just do that in every force, because I don't want to support multiple player factions
    for _, force in pairs(game.forces) do
        force.technologies[tech_name].researched = is_researched
    end
end

-- sets the hidden caste-technologies so they encode the given value
local function set_binary_techs(value, name)
    local new_value = value
    local strength = 1

    while value > 0 do
        new_value = value / 2

        -- if new_value times two doesn't equal value, then the remainder was one
        -- which means that the current binary decimal is one and that the corresponding tech should be researched
        set_researched(strength .. name, new_value * 2 ~= value)

        strength = strength * 2
        value = new_value
    end
end

-- Assumes value is an integer
local function set_gunfire_bonus(value)
    set_binary_techs(value, "-gunfire-caste")
    global.gunfire_bonus = value
end

-- Assumes value is an integer
local function set_gleam_bonus(value)
    set_binary_techs(value, "-gleam-caste")
    global.gleam_bonus = value
end

-- Assumes value is an integer
local function set_foundry_bonus(value)
    set_binary_techs(value, "-foundry-caste")
    global.foundry_bonus = value
end

---------------------------------------------------------------------------------------------------
-- << caste bonus functions >>
local function get_clockwork_bonus(effective_population)
    return math.floor(effective_population * 40 / math.max(global.machine_count, 1))
end

local function get_gunfire_bonus(effective_population)
    return math.floor(effective_population * 10 / math.max(global.turret_count, 1)) -- TODO balancing
end

local function get_gleam_bonus(effective_population)
    return math.floor(math.sqrt(effective_population))
end

local function get_foundry_bonus(effective_population)
    return math.floor(effective_population * 5 / math.max(global.mining_drill_count, 1))
end

local function get_aurora_bonus(effective_population)
    return math.floor(math.sqrt(effective_population))
end

---------------------------------------------------------------------------------------------------
-- << resettlement >>
local function resettlement_is_researched()
    for _, force in pairs(game.forces) do
        if force.technologies["resettlement"].researched then
            return true
        end
    end

    return false
end

local function try_resettle(registered_entity)
    if not resettlement_is_researched() or not Types:is_housing(registered_entity.type) then
        return
    end

    for unit_number, registered_entity in pairs(global.register) do
        if registered_entity.entity.valid then
            -- TODO
        else
            remove_from_register(registered_entity)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << panic >>
local function ease_panic()
    local delta_ticks = game.tick - global.last_update

    -- TODO
end

local function add_panic()
    global.last_panic_event = game.tick
    global.panic = global.panic + 1 -- TODO balancing
end

---------------------------------------------------------------------------------------------------
-- << update functions >>
-- entities need to be checked for validity before calling the update-function
local function generate_ideas(registered_entity, delta_ticks)
end

-- Does all the things that are the same for every caste
local function update_house(registered_entity, delta_ticks)
    local diet_effects = evaluate_diet(registered_entity, delta_ticks)
end

local function update_house_clockwork(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

local function update_house_ember(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

local function update_house_gunfire(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

local function update_house_gleam(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

local function update_house_foundry(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

local function update_house_orchid(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

local function update_house_aurora(registered_entity, delta_ticks)
    update_house(registered_entity, delta_ticks)
end

-- Assumes that the entity has a beacon
local function update_entity_with_beacon(registered_entity)
    local speed_bonus = 0
    local productivity_bonus = 0
    local use_pentalty_module = false

    if (Types:is_affected_by_clockwork(registered_entity.type)) then
        speed_bonus = get_clockwork_bonus(global.effective_population[TYPE_CLOCKWORK])
        use_pentalty_module = global.use_penalty
    end
    if registered_entity.type == TYPE_ROCKET_SILO then
        productivity_bonus = get_aurora_bonus(global.effective_population[TYPE_AURORA])
    end

    set_beacon_effects(registered_entity, speed_bonus, productivity_bonus, use_pentalty_module)
end

local update_function_lookup = {
    [TYPE_CLOCKWORK] = update_house_clockwork,
    [TYPE_EMBER] = update_house_ember,
    [TYPE_GUNFIRE] = update_house_gunfire,
    [TYPE_GLEAM] = update_house_gleam,
    [TYPE_FOUNDRY] = update_house_foundry,
    [TYPE_ORCHID] = update_house_orchid,
    [TYPE_AURORA] = update_house_aurora,
    [TYPE_ASSEMBLY_MACHINE] = update_entity_with_beacon,
    [TYPE_FURNACE] = update_entity_with_beacon,
    [TYPE_ROCKET_SILO] = update_entity_with_beacon
}

local function update(registered_entity)
    if not registered_entity.entity.valid then
        remove_from_register(registered_entity)
        return
    end

    local delta_ticks = game.tick - registered_entity.last_update
    update_function_lookup[registered_entity.type](registered_entity, delta_ticks)

    registered_entity.last_update = game.tick
end

local function update_caste_boni()
    -- We check if the boni have actually changed because I think manipulating techs is quite expensive
    local current_gunfire_bonus = get_gunfire_bonus(global.effective_population[TYPE_GUNFIRE])
    if global.gunfire_bonus ~= current_gunfire_bonus then
        set_gunfire_bonus(current_gunfire_bonus)
    end

    local current_gleam_bonus = get_gleam_bonus(global.effective_population[TYPE_GLEAM])
    if global.gleam_bonus ~= current_gleam_bonus then
        set_gleam_bonus(current_gleam_bonus)
    end

    local current_foundry_bonus = get_foundry_bonus(global.effective_population[TYPE_FOUNDRY])
    if global.foundry_bonus ~= current_foundry_bonus then
        set_foundry_bonus(current_foundry_bonus)
    end
end

---------------------------------------------------------------------------------------------------
-- << event handler functions >>
local function init()
    global.version = game.active_mods["sosciencity"]
    global.updates_per_cycle = settings.startup["sosciencity-entity-updates-per-cycle"].value
    global.use_penalty = settings.startup["sosciencity-penalty-module"].value

    global.panic = 0
    global.population = {
        TYPE_CLOCKWORK = 0,
        TYPE_EMBER = 0,
        TYPE_GUNFIRE = 0,
        TYPE_GLEAM = 0,
        TYPE_FOUNDRY = 0,
        TYPE_ORCHID = 0,
        TYPE_AURORA = 0,
        TYPE_PLASMA = 0
    }
    global.effective_population = {
        TYPE_CLOCKWORK = 0,
        TYPE_EMBER = 0,
        TYPE_GUNFIRE = 0,
        TYPE_GLEAM = 0,
        TYPE_FOUNDRY = 0,
        TYPE_ORCHID = 0,
        TYPE_AURORA = 0,
        TYPE_PLASMA = 0
    }
    global.gunfire_bonus = 0
    global.gleam_bonus = 0
    global.foundry_bonus = 0

    global.machine_count = 0
    global.turret_count = 0
    global.mining_drill_count = 0

    global.register = {}

    -- find and register all the machines
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(
            surface.find_entities_filtered {
                type = {
                    "assembling-machine",
                    "rocket-silo",
                    "furnace",
                    "mining-drill",
                    "turret",
                    "ammo-turret",
                    "electric-turret",
                    "fluid-turret"
                }
            }
        ) do
            global.machine_count = global.machine_count + 1
            add_entity_to_register(entity)
        end
    end

    -- count all the mining drills
    for _, surface in pairs(game.surfaces) do
        global.mining_drill_count =
            global.mining_drill_count +
            surface.count_entities_filtered {
                type = {"mining-drill"}
            }
    end

    -- count all the turrets
    for _, surface in pairs(game.surfaces) do
        global.turret_count =
            global.turret_count +
            surface.count_entities_filtered {
                {
                    type = {
                        "turret",
                        "ammo-turret",
                        "electric-turret",
                        "fluid-turret"
                    },
                    force = "player"
                }
            }
    end
end

local function update_cycle()
    local next = next
    local count = 0
    local register = global.register
    local index = global.last_index
    local current_entity
    local number_of_checks = global.updates_per_cycle

    if index and register[index] then
        current_entity = register[index] -- continue looping
    else
        index, current_entity = next(register, nil) -- begin a new loop at the start (nil as a key returns the first pair)
    end

    while index and count < number_of_checks do
        update(current_entity)
        index, current_entity = next(register, index)
        count = count + 1
    end

    update_caste_boni()
    ease_panic()

    global.last_index = index
end

local function on_entity_built(event)
    -- https://forums.factorio.com/viewtopic.php?f=34&t=73331#p442695
    local entity
    if event.created_entity then
        entity = event.created_entity
    elseif event.entity then
        entity = event.entity
    elseif event.destination then
        entity = event.destination
    end

    if not entity or not entity.valid then
        return
    end

    if Types:entity_is_relevant_to_register(entity) then
        add_entity_to_register(entity)
    end

    if entity.type == "mining-drill" then
        global.mining_drill_count = global.mining_drill_count + 1
    end
    if Types:entity_is_affected_by_clockwork(entity) then
        global.machine_count = global.machine_count + 1
    end
    if Types:entity_is_turret(entity) and entity.force then
        global.turret_count = global.turret_count + 1
    end
end

local function on_entity_removed(event)
    local entity = event.entity -- all removement events use entity as key
    if not entity.valid then
        return
    end

    local entry = global.register[entity.unit_number]
    if entry then
        remove_from_register(entry)
    end

    if entity.type == "mining-drill" then
        global.mining_drill_count = global.mining_drill_count - 1
    end
    if Types:entity_is_affected_by_clockwork(entity) then
        global.machine_count = global.machine_count - 1
    end
    if Types:entity_is_turret(entity) then
        global.turret_count = global.turret_count - 1
    end
end

local function on_entity_died(event)
    if not event.entity.valid then
        return
    end

    if Types.entity_is_civil(event.entity) then
        add_panic()
    end

    on_entity_removed(event)
end

local function on_entity_mined(event)
    local entity = event.entity
    if not entity.valid then
        return
    end
    local registered_entity = global.register[entity.unit_number]
    if registered_entity and Types:is_housing(registered_entity.type) then
        try_resettle(registered_entity)
    end

    on_entity_removed(event)
end

local function on_configuration_change(event)
    -- Compare the stored version number with the loaded version to detect a mod update
    if game.active_mods["sosciencity"] ~= global.version then
        global.version = game.active_mods["sosciencity"]

        -- Reset recipes and techs in case I changed something.
        -- I do that a lot and don't want to forget a migration file.
        for _, force in pairs(game.forces) do
            force.reset_recipes()
            force.reset_technologies()
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << event handler registration >>
-- initialisation
script.on_init(init)
local cycle_frequency = settings.startup["sosciencity-entity-update-cycle-frequency"].value
if cycle_frequency == 1 then
    script.on_event(defines.events.on_tick, update_cycle)
else
    script.on_nth_tick(cycle_frequency, update_cycle)
end

-- placement
script.on_event(defines.events.on_built_entity, on_entity_built)
script.on_event(defines.events.on_robot_built_entity, on_entity_built)
script.on_event(defines.events.on_entity_cloned, on_entity_built)
script.on_event(defines.events.script_raised_built, on_entity_built)
script.on_event(defines.events.script_raised_revive, on_entity_built)

-- removing
script.on_event(defines.events.on_player_mined_entity, on_entity_mined)
script.on_event(defines.events.on_robot_mined_entity, on_entity_mined)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

-- mod update
script.on_configuration_changed(on_configuration_change)
