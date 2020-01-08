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
        ["sprite"]: sprite id

        -- Housing
        ["inhabitants"]: int
        ["happiness"]: float
        ["healthiness"]: float
        ["mental_healthiness"]: float
        ["food"]: table

    food: table
        ["healthiness_dietary"]: float
        ["healthiness_mental"]: float
        ["satisfaction"]: float
        ["count"]: int

    neighborhood: table
        [entity type]: table of (unit_number, entity) pairs

    neighborhood_data: table
        [] TODO

    global.population: table
        [caste_type]: int (count)

    global.effective_population: table
        [caste_type]: float

    global.fear: float

    global.technologies: table
        [tech name]: bool (is researched) or int (research level)

    global.detail_view: table
        [player_index]: unit_number (of the entity the detail view is for)
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
-- EmmyLua stuff
---@class Entry
---@class Entity
---@class Type

local Register = require("scripts.control.register")
local Technologies = require("scripts.control.technologies")
local Subentities = require("scripts.control.subentities")
local Neighborhood = require("scripts.control.neighborhood")
local Diet = require("scripts.control.diet")
local Inhabitants = require("scripts.control.inhabitants")
local Gui = require("scripts.control.gui")
local Communication = require("scripts.control.communication")

---------------------------------------------------------------------------------------------------
-- << update functions >>
-- entities need to be checked for validity before calling the update-function
-- local all the frequently called functions for miniscule performance gains

local global

local get_clockwork_bonus = Inhabitants.get_clockwork_bonus
local get_aurora_bonus = Inhabitants.get_aurora_bonus
local get_orchid_bonus = Inhabitants.get_orchid_bonus
local add_fear = Inhabitants.add_fear

local set_beacon_effects = Subentities.set_beacon_effects

local get_entity_type = Types.get_entity_type
local is_affected_by_clockwork = Types.is_affected_by_clockwork
local is_affected_by_orchid = Types.is_affected_by_orchid
local is_civil = Types.is_civil
local is_inhabited = Types.is_inhabited
local is_relevant_to_register = Types.is_relevant_to_register

local try_get_entry = Register.try_get
local remove_entry = Register.remove_entry

-- Assumes that the entity has a beacon
local function update_entity_with_beacon(entry)
    local _type = entry[TYPE]
    local speed_bonus = 0
    local productivity_bonus = 0
    local use_penalty_module = false

    if is_affected_by_clockwork(_type) then
        speed_bonus = get_clockwork_bonus()
        use_penalty_module = global.use_penalty
    end
    if _type == TYPE_ROCKET_SILO then
        productivity_bonus = get_aurora_bonus()
    end
    if is_affected_by_orchid(_type) then
        productivity_bonus = get_orchid_bonus()
    end
    if _type == TYPE_ORANGERY then
        local age = game.tick - entry[TICK_OF_CREATION]
        productivity_bonus = productivity_bonus + math.floor(math.sqrt(age)) -- TODO balance
    end

    set_beacon_effects(entry, speed_bonus, productivity_bonus, use_penalty_module)
end

local update_function_lookup = {
    [TYPE_CLOCKWORK] = Inhabitants.update_house,
    [TYPE_EMBER] = Inhabitants.update_house,
    [TYPE_GUNFIRE] = Inhabitants.update_house,
    [TYPE_GLEAM] = Inhabitants.update_house,
    [TYPE_FOUNDRY] = Inhabitants.update_house,
    [TYPE_ORCHID] = Inhabitants.update_house,
    [TYPE_AURORA] = Inhabitants.update_house,
    [TYPE_ASSEMBLING_MACHINE] = update_entity_with_beacon,
    [TYPE_FURNACE] = update_entity_with_beacon,
    [TYPE_ROCKET_SILO] = update_entity_with_beacon,
    [TYPE_FARM] = update_entity_with_beacon,
    [TYPE_MINING_DRILL] = update_entity_with_beacon,
    [TYPE_ORANGERY] = update_entity_with_beacon
}

local function update(entry)
    if not entry[ENTITY].valid then
        remove_entry(entry)
        return
    end

    local _type = entry[TYPE]
    local update_function = update_function_lookup[_type]

    if update_function ~= nil then
        local delta_ticks = game.tick - entry[LAST_UPDATE]
        update_function_lookup[_type](entry, delta_ticks)
        entry[LAST_UPDATE] = game.tick
    end
end

---------------------------------------------------------------------------------------------------
-- << event handler functions >>
local ease_fear = Inhabitants.ease_fear
local update_caste_bonuses = Inhabitants.update_caste_bonuses
local update_city_info = Gui.update_city_info
local update_details_view = Gui.update_details_view

local function update_cycle()
    ease_fear()

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

    update_caste_bonuses()
    update_city_info()
    update_details_view()

    global.last_update = game.tick
end

local cycle_frequency = settings.global["sosciencity-entity-update-cycle-frequency"].value
local function update_settings()
    local new_frequency = settings.global["sosciencity-entity-update-cycle-frequency"].value
    if new_frequency ~= cycle_frequency then
        script.on_nth_tick(cycle_frequency, nil) -- unregisters the old frequency
        script.on_nth_tick(new_frequency, update_cycle)
        cycle_frequency = new_frequency
    end

    global.updates_per_cycle = settings.global["sosciencity-entity-updates-per-cycle"].value

    global.use_penalty = settings.global["sosciencity-penalty-module"]
end

local function init()
    global = _ENV.global

    update_settings()

    global.last_update = game.tick

    Inhabitants.init()
    Register.init()
    Technologies.init()
    Gui.init()
end

local function on_load()
    global = _ENV.global

    Register.load()
    Inhabitants.load()
end

local function on_entity_built(event)
    -- https://forums.factorio.com/viewtopic.php?f=34&t=73331#p442695
    local entity = event.entity or event.created_entity or event.destination

    if not entity or not entity.valid then
        return
    end

    local entity_type = get_entity_type(entity)

    if is_relevant_to_register(entity_type) then
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
    local entity = event.entity

    if not entity.valid then
        return
    end

    local entity_type = get_entity_type(entity)
    if is_civil(entity_type) then
        add_fear()
    end

    on_entity_removed(event)
end

local function on_entity_mined(event)
    local entity = event.entity
    if not entity.valid then
        return
    end

    local entry = try_get_entry(entity.unit_number)
    if entry then
        Inhabitants.try_resettle(entry)
    end

    on_entity_removed(event)
end

local function on_entity_settings_pasted(event)
    local source = event.source
    local destination = event.destination

    if not source.valid or not destination.valid then
        return
    end

    local source_entry = try_get_entry(source.unit_number)
    local destination_entry = try_get_entry(destination.unit_number)

    if not source_entry or not destination_entry then
        return
    end

    local source_type = source_entry[TYPE]
    local destination_type = destination_entry[TYPE]
    if is_inhabited(source_type) and destination_type == TYPE_EMPTY_HOUSE then
        Inhabitants.try_allow_for_caste(destination_entry, source_type, true)
    end
end

local function on_configuration_change()
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

    Gui.create_guis_for_player(player)
end

local function on_gui_opened(event)
    if event.gui_type == defines.gui_type.entity then
        local player = game.get_player(event.player_index)
        Gui.open_details_view_for_player(player, event.entity.unit_number)
    end
end

local function on_gui_closed(event)
    if event.gui_type == defines.gui_type.entity then
        local player = game.get_player(event.player_index)
        Gui.close_details_view_for_player(player)
    end
end

local UNIQUE_PREFIX = Gui.UNIQUE_PREFIX -- greetings to LuziferSenpai
local function on_gui_click(event)
    local gui_element = event.element
    local name = gui_element.name

    -- check if it's my gui with my prefix
    if name:sub(1, UNIQUE_PREFIX:len()) ~= UNIQUE_PREFIX then
        return
    end
    -- remove the prefix
    name = name:sub(UNIQUE_PREFIX:len() + 1)

    -- check Caste assignment buttons
    for caste_id, caste in pairs(Caste.values) do
        if name == caste.name then
            Gui.handle_caste_button(event.player_index, caste_id)
        end
    end

    if name == "kickout" then
        Gui.handle_kickout_button(event.player_index, gui_element)
    end
end

local function on_research_finished(event)
    Technologies.finished(event.research.name)
end

---------------------------------------------------------------------------------------------------
-- << event handler registration >>
-- initialisation
script.on_init(init)

-- loading
script.on_load(on_load)

-- update function
script.on_nth_tick(cycle_frequency, update_cycle)
script.on_event(defines.events.on_runtime_mod_setting_changed, update_settings)

-- placement
script.on_event(defines.events.on_built_entity, on_entity_built)
script.on_event(defines.events.on_robot_built_entity, on_entity_built)
script.on_event(defines.events.on_entity_cloned, on_entity_built)
script.on_event(defines.events.script_raised_built, on_entity_built)
script.on_event(defines.events.script_raised_revive, on_entity_built)

-- removement
script.on_event(defines.events.on_player_mined_entity, on_entity_mined)
script.on_event(defines.events.on_robot_mined_entity, on_entity_mined)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

-- copy-paste settings
script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

-- mod update
script.on_configuration_changed(on_configuration_change)

-- gui creation
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)

-- gui events
script.on_event(defines.events.on_gui_click, on_gui_click)

-- keeping track of research
script.on_event(defines.events.on_research_finished, on_research_finished)
