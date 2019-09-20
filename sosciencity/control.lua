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
        ["subentities"]: table of subentities
        
        -- Housing
        ["inhabitants"]: int
        ["happiness"]: float
        ["food"]: table

    subentity: table
        ["type"]: int/enum
        ["entity"]: LuaEntity

    food: table
        ["healthiness"]: float
        ["healthiness_mental"]: float
        ["taste_category"]: string
        ["taste_quality"]: float
        ["luxority"]: float

    global.inhabitants: table
        [caste_type]: int (count)

    global.panic: double
]]

--[[ runtime finals ]]
require("constants.castes")
require("constants.diseases")
require("constants.entity_types")
require("constants.food")
require("constants.housing")

--[[ register system ]]
local function get_starting_diet(type)

end

local function add_housing_data(registered_entity)
    registered_entity.inhabitants = 0
    registered_entity.trend = 0
    registered_entity.diet = get_starting_diet(registered_entity.type)

    return registered_entity
end

local function establish_registered_entity(entity)
    local type = TYPES(entity)

    local registered_entity = {
        entity = entity,
        type = type,
        last_update = game.tick,
        subentities = {}
    }
    
    if is_housing(type) then
        add_housing_data(registered_entity)
    end

    return registered_entity
end

local function add_entity_to_register(entity)
    local registered_entity = establish_registered_entity(entity)
    global.register[entity.unit_number] = registered_entity
    refresh(registered_entity)
end

local function remove_from_register(registered_entity)
    global.register[registered_entity.entity] = nil

    for _, subentity in pairs(registered_entity.subentities) do
        if subentity.entity.valid then
            subentity.entity.destroy()
        end
    end
end

--[[ update functions ]]
-- entities need to be checked for validity before calling the update-function
local function has_power(entity)
    return entity-power > 0
end

local function update_house_clockwork(registered_entity)
end

local function update_house_ember(registered_entity)
end

local function update_house_gunfire(registered_entity)
end

local function update_house_gleam(registered_entity)
end

local function update_house_foundry(registered_entity)
end

local function update_house_orchid(registered_entity)
end

local function update_house_aurora(registered_entity)
end

local update_function_lookup = {
    [TYPE_CLOCKWORK] = update_house_clockwork,
    [TYPE_EMBER] = update_house_ember,
    [TYPE_GUNFIRE] = update_house_gunfire,
    [TYPE_GLEAM] = update_house_gleam,
    [TYPE_FOUNDRY] = update_house_foundry,
    [TYPE_ORCHID] = update_house_orchid,
    [TYPE_AURORA] = update_house_aurora,
    [TYPE_SHOPPING_CENTER] = update_shopping_center,
    [TYPE_WATER_DISTRIBUTION_FACILITY] = update_water_distribution_facility,
    [TYPE_ASSEMBLY_MACHINE] = update_assembly_machine,
    [TYPE_MINING_DRILL] = update_mining_drill,
    [TYPE_LAB] = update_lab
}

local function update(registered_entity)
    if not registered_entity.entity.valid then
        remove_from_register(registered_entity)
        return
    end

    update_function_lookup[registered_entity.type](registered_entity)
end

--[[ event handler functions ]]
local function init()
    global.version = game.active_mods["sosciencity"]
    global.updates_per_cycle = settings.startup["sosciencity-entity-updates-per-cycle"].value

    global.register = {}
    -- TODO: find and register all relevant entities

    global.panic = 0
    global.inhabitants = {
        TYPE_CLOCKWORK = 0,
        TYPE_EMBER = 0,
        TYPE_GUNFIRE = 0,
        TYPE_GLEAM = 0,
        TYPE_FOUNDRY = 0,
        TYPE_ORCHID = 0,
        TYPE_AURORA = 0,
        TYPE_PLASMA = 0
    }
end

local function load()
    global.updates_per_cycle = settings.startup["sosciencity-entity-updates-per-cycle"].value
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

    global.last_index = index
end

local function on_entity_built(event)
    --https://forums.factorio.com/viewtopic.php?f=34&t=73331#p442695
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

    if TYPES:entity_is_relevant(entity) then
        add_to_register(entity)
    end
end

local function on_entity_removed(event)
    local entity = event.entity -- all removement events use entity as key

    if global.register[entity.unit_number] then
        remove_from_register(entity)
    end
end

local function on_entity_died(event)
    if TYPES.entity_is_civil(event.entity) then
        -- TODO create panic
    end

    on_entity_removed(event)
end

local function on_entity_mined(event)
    if TYPES.entity_is_housing(event.entity) then
        -- TODO resettlement
    end

    on_entity_removed(event)
end

local function on_configuration_change(event)
    -- Compare the stored version number with the loaded version to detect a mod update
    if game.active_mods["sosciencity"] ~= global.version then
        global.version = game.active_mods["sosciencity"]

        -- Reset recipes, techs and tech effects in case I changed something. 
        -- I do that a lot and don't want to forget a migration file. 
        for _, force in pairs(game.forces) do
            force.reset_recipes()
            force.reset_technologies()
            force.reset_technology_effects()
        end
    end
end

--[[ event handler registration ]]
-- initialisation
script.on_init(init)
script.on_load(load)
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