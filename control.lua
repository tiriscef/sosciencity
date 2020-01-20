local dataphase_test = false

if dataphase_test then
    return
end
pcall(require, "__debugadapter__/debugadapter.lua")
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
        ["sanity"]: float

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

    global.highlights: table
        [player_index]: table of renderer-ids
]]
---------------------------------------------------------------------------------------------------
-- << runtime finals >>
require("constants.castes")
require("constants.diseases")
require("constants.types")
require("constants.food")
require("constants.housing")
require("constants.buildings")

---------------------------------------------------------------------------------------------------
-- << helper functions >>
require("lib.utils")

---------------------------------------------------------------------------------------------------
-- << classes >>
-- EmmyLua stuff
---@class Entry
---@class Entity
---@class Type

local Replacer = require("scripts.control.replacer")
local Register = require("scripts.control.register")
local Technologies = require("scripts.control.technologies")
local Subentities = require("scripts.control.subentities")
local Neighborhood = require("scripts.control.neighborhood")
local Communication = require("scripts.control.communication")
local Inventories = require("scripts.control.inventories")
local Diet = require("scripts.control.diet")
local Inhabitants = require("scripts.control.inhabitants")
local Gui = require("scripts.control.gui")

---------------------------------------------------------------------------------------------------
-- << update functions >>
-- entities need to be checked for validity before calling the update-function
-- local all the frequently called functions for miniscule performance gains

local global
local register
local caste_bonuses

local add_fear = Inhabitants.add_fear
local ease_fear = Inhabitants.ease_fear

local set_beacon_effects = Subentities.set_beacon_effects

local get_entity_type = Types.get_entity_type
local is_affected_by_clockwork = Types.is_affected_by_clockwork
local is_affected_by_orchid = Types.is_affected_by_orchid
local is_civil = Types.is_civil
local is_inhabited = Types.is_inhabited
local is_relevant_to_register = Types.is_relevant_to_register

local try_get_entry = Register.try_get
local remove_entry = Register.remove_entry
local add_to_register = Register.add

local update_caste_bonuses = Inhabitants.update_caste_bonuses

local update_city_info = Gui.update_city_info
local update_details_view = Gui.update_details_view

local replace = Replacer.replace

local create_mouseover_highlights = Communication.create_mouseover_highlights
local remove_mouseover_highlights = Communication.remove_mouseover_highlights

-- Assumes that the entity has a beacon
local function update_entity_with_beacon(entry)
    local _type = entry[TYPE]
    local speed_bonus = 0
    local productivity_bonus = 0
    local use_penalty_module = false

    if is_affected_by_clockwork(_type) then
        speed_bonus = caste_bonuses[TYPE_CLOCKWORK]
        use_penalty_module = global.use_penalty
    end
    if _type == TYPE_ROCKET_SILO then
        productivity_bonus = caste_bonuses[TYPE_AURORA]
    end
    if is_affected_by_orchid(_type) then
        productivity_bonus = caste_bonuses[TYPE_ORCHID]
    end
    if _type == TYPE_ORANGERY then
        local age = game.tick - entry[TICK_OF_CREATION]
        productivity_bonus = productivity_bonus + math.floor(math.sqrt(age)) -- TODO balance
    end

    set_beacon_effects(entry, speed_bonus, productivity_bonus, use_penalty_module)
end

local update_functions = {
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

---------------------------------------------------------------------------------------------------
-- << event handler functions >>
local function update_cycle()
    ease_fear()

    local current_tick = game.tick
    local next_entry = Register.next
    local count = 0
    local index = global.last_index
    local current_entry = try_get_entry(index)
    local number_of_checks = global.updates_per_cycle

    if not current_entry then
        index, current_entry = next_entry() -- begin a new loop at the start (nil as a key returns the first pair)
    end

    while index and count < number_of_checks do
        local _type = current_entry[TYPE]
        local updater = update_functions[_type]
        if updater ~= nil then
            local delta_ticks = current_tick - current_entry[LAST_UPDATE]
            updater(current_entry, delta_ticks)
            current_entry[LAST_UPDATE] = current_tick
        end

        index, current_entry = next_entry(index)
        count = count + 1
    end
    global.last_index = index

    update_caste_bonuses()
    update_city_info()
    update_details_view()

    global.last_update = current_tick
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

    global.use_penalty = settings.global["sosciencity-penalty-module"].value
end

local function set_locals()
    global = _ENV.global
    caste_bonuses = global.caste_bonuses
    register = global.register
end

local function init()
    global = _ENV.global
    Types.init()
    Neighborhood.init()

    update_settings()

    Inhabitants.init()
    Register.init()
    Technologies.init()
    Gui.init()
    Communication.init()

    set_locals()
    global.last_update = game.tick
end

local function on_load()
    set_locals()

    Types.init()
    Neighborhood.init()
    Register.load()
    Inhabitants.load()
    Communication.load()
end

local function on_entity_built(event)
    -- https://forums.factorio.com/viewtopic.php?f=34&t=73331#p442695
    local entity = event.entity or event.created_entity or event.destination

    if not entity or not entity.valid then
        return
    end

    --[[if replace(entity) then
        return
    end]]
    local entity_type = get_entity_type(entity)

    if is_relevant_to_register(entity_type) then
        add_to_register(entity)
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

    Register.remove_entity(entity)
end

local function on_entity_mined(event)
    local entity = event.entity
    if not entity.valid then
        return
    end

    local unit_number = entity.unit_number
    local entry = try_get_entry(unit_number)
    if entry and Types.is_inhabited(entry[TYPE]) then
        Inhabitants.try_resettle(entry, unit_number)
    end

    Register.remove_entity(entity)
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

local function on_selection_changed(event)
    local index = event.player_index
    local player = game.get_player(index)
    local selected_entity = player.selected

    remove_mouseover_highlights(index)

    if selected_entity then
        create_mouseover_highlights(index, selected_entity)
    end
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
-- filter out ghosts because my mod has nothing to do with them
local filter = {{filter = "ghost", invert = true}}
script.on_event(defines.events.on_built_entity, on_entity_built, filter)
script.on_event(defines.events.on_robot_built_entity, on_entity_built, filter)
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

-- selection stuff
script.on_event(defines.events.on_selected_entity_changed, on_selection_changed)
