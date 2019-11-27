local dataphase_test = false

if dataphase_test then
    return
end

--[[
    TODO
        - city info gui
        - house details gui
        - caste selection (+ gui)
        - balance basicly everything
        - diseases
        - indicators
]]

--[[
    Data structures

    global.Register. table
        [LuaEntity.unit_number]: entry

    global.register_by_type: table
        [type]: table of unit_numbers

    entry: table
        ["type"]: int/enum
        ["entity"]: LuaEntity
        ["last_update"]: uint (tick)
        ["subentities"]: table of (subentity type, entity) pairs
        ["neighborhood"]: table
        ["neughborhood_data"]: table
        ["flags"]: table of int/enum
        ["sprite"]: sprite id

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

    Neighborhood. table
        [entity type]: table of (unit_number, entity) pairs

    neighborhood_data: table
        [] TODO

    global.population: table
        [caste_type]: int (count)

    global.effective_population: table
        [caste_type]: float

    global.panic: float
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
require("lib.utils")

---------------------------------------------------------------------------------------------------
-- << classes >>
local Register = require("scripts.control.register")
local Subentities = require("scripts.control.subentities")
local Neighborhood = require("scripts.control.neighborhood")
local Inhabitants = require("scripts.control.inhabitants")
local Gui = require("scripts.control.gui")

---------------------------------------------------------------------------------------------------
-- << update functions >>
-- entities need to be checked for validity before calling the update-function

local function update_house(entry, delta_ticks)
    local diet_effects = Diet.evaluate(entry, delta_ticks)
    -- TODO happiness, healthiness, diseases, ideas, tralala

    entry.trend = entry.trend + Inhabitants.get_trend(entry, delta_ticks)
    if entry.trend >= 1 then
        -- let people move in
        Inhabitants.try_add_to_house(entry, math.floor(entry.trend))
        entry.trend = entry.trend - math.floor(entry.trend)
    elseif entry.trend <= - 1 then
        -- let people move out
        Inhabitants.remove(entry, -math.ceil(entry.trend))
        entry.trend = entry.trend - math.ceil(entry.trend)
    end

    Subentities.set_power_usage(entry)
end

-- Assumes that the entity has a beacon
local function update_entity_with_beacon(entry)
    local speed_bonus = 0
    local productivity_bonus = 0
    local use_penalty_module = false

    if Types.is_affected_by_clockwork(entry.type) then
        speed_bonus = Inhabitants.get_clockwork_bonus(global.effective_population[TYPE_CLOCKWORK])
        use_penalty_module = global.use_penalty
    end
    if entry.type == TYPE_ROCKET_SILO then
        productivity_bonus = Inhabitants.get_aurora_bonus(global.effective_population[TYPE_AURORA])
    end

    Subentities.set_beacon_effects(entry, speed_bonus, productivity_bonus, use_penalty_module)
end

local update_function_lookup = {
    [TYPE_CLOCKWORK] = update_house,
    [TYPE_EMBER] = update_house,
    [TYPE_GUNFIRE] = update_house,
    [TYPE_GLEAM] = update_house,
    [TYPE_FOUNDRY] = update_house,
    [TYPE_ORCHID] = update_house,
    [TYPE_AURORA] = update_house,
    [TYPE_ASSEMBLING_MACHINE] = update_entity_with_beacon,
    [TYPE_FURNACE] = update_entity_with_beacon,
    [TYPE_ROCKET_SILO] = update_entity_with_beacon
}

local function update(entry)
    if not entry.entity.valid then
        Register.remove_entry(entry)
        return
    end

    local update_function = update_function_lookup[entry.type]

    if update_function ~= nil then
        local delta_ticks = game.tick - entry.last_update
        update_function_lookup[entry.type](entry, delta_ticks)
        entry.last_update = game.tick
    end
end

---------------------------------------------------------------------------------------------------
-- << event handler functions >>
local function init()
    global.version = game.active_mods["sosciencity"]
    global.updates_per_cycle = settings.startup["sosciencity-entity-updates-per-cycle"].value
    global.use_penalty = settings.startup["sosciencity-penalty-module"].value

    global.last_update = game.tick

    Inhabitants.init()
    Register.init()
end

local function update_cycle()
    local next = next
    local count = 0
    local register = global.register
    local index = global.last_index
    local current_entry
    local number_of_checks = global.updates_per_cycle

    if index and register[index] then
        current_entry = register[index] -- continue looping
    else
        index, current_entry = next(register, nil) -- begin a new loop at the start (nil as a key returns the first pair)
    end

    while index and count < number_of_checks do
        update(current_entry)
        index, current_entry = next(register, index)
        count = count + 1
    end
    global.last_index = index

    Inhabitants.update_caste_bonuses()
    Inhabitants.ease_panic()

    Gui.update_city_info()

    global.last_update = game.tick
end

local function on_entity_built(event)
    -- https://forums.factorio.com/viewtopic.php?f=34&t=73331#p442695
    local entity = event.entity or event.created_entity or event.destination

    if not entity or not entity.valid then
        return
    end

    local entity_type = Types(entity)

    if Types.is_relevant_to_register(entity_type) then
        Register.add(entity)
    end
end

local function on_entity_removed(event)
    local entity = event.entity -- all removement events use 'entity' as key
    if not entity.valid then
        return
    end

    Register.remove_entity(entity)
end

local function on_entity_died(event)
    if not event.entity.valid then
        return
    end

    local entity = event.entity
    local entity_type = Types(entity)
    if Types.is_civil(entity_type) then
        Inhabitants.add_panic()
    end

    on_entity_removed(event)
end

local function on_entity_mined(event)
    local entity = event.entity
    if not entity.valid then
        return
    end

    local entry = global.register[entity.unit_number]
    if entry then
        Inhabitants.try_resettle(entry)
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

local function on_player_created(event)
    local index = event.player_index
    local player = game.get_player(index)

    Gui.create_city_info_for(player)
end

---------------------------------------------------------------------------------------------------
-- << event handler registration >>
-- initialisation
script.on_init(init)

-- update function
local cycle_frequency = settings.startup["sosciencity-entity-update-cycle-frequency"].value
script.on_nth_tick(cycle_frequency, update_cycle)

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

-- gui creation
script.on_event(defines.events.on_player_created, on_player_created)