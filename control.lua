local EK = require("enums.entry-key")
local DeconstructionCause = require("enums.deconstruction-cause")

---------------------------------------------------------------------------------------------------
-- << debug stuff >>

if script.active_mods["sosciencity-debug"] then
    DEBUG = true

    -- development tools
    pcall(require, "__profiler__/profiler.lua")

    -- tests
    require("lib.testing")

    commands.add_command(
        "sosciencity-tests",
        "",
        function(input)
            local results
            local group = input.parameter
            if group then
                results = Tiristest.run_group_suite(group, true)
            else
                results = Tiristest.run_all(true)
            end

            game.print(results)
            log(results)
        end
    )

    commands.add_command(
        "sosciencity-tests-debug",
        "",
        function(input)
            local results
            local group = input.parameter
            if group then
                results = Tiristest.run_group_suite(group, false)
            else
                results = Tiristest.run_all(false)
            end

            game.print(results)
            log(results)
        end
    )

    commands.add_command(
        "sosciencity-test-tiristest",
        "",
        function()
            require("tests.testing")
            game.print("tests.testing loaded")
        end
    )
end

---------------------------------------------------------------------------------------------------
-- << helper functions >>

require("lib.utils")

---------------------------------------------------------------------------------------------------
-- << constants >>

local Types = require("constants.types")

---------------------------------------------------------------------------------------------------
-- << classes >>

require("classes.scheduler")
require("classes.weather")
require("classes.replacer")
require("classes.register")
require("classes.technologies")
require("classes.subentities")
require("classes.neighborhood")
require("classes.communication")
require("classes.visualisation")
require("classes.inventories")
require("classes.inhabitants")
require("classes.entity")
require("classes.handcrafting")
require("classes.gui")

---------------------------------------------------------------------------------------------------
-- EmmyLua stuff

---@class Entity
---@class Player
---@class Inventory
---@class Entry
---@class Type
---@class InhabitantGroup
---@class DiseaseGroup
---@class DiseaseID
---@class DiseaseCategory
---@class AgeGroup
---@class GenderGroup


--[[
    Data this script stores in global
    --------------------------------
    global.last_entity_update: tick
    global.last_tile_update: tick
]]
---------------------------------------------------------------------------------------------------
-- local all the frequently called functions for miniscule performance gains

local global

local add_fear = Inhabitants.add_fear
local ease_fear = Inhabitants.ease_fear

local get_entity_type = Types.get_entity_type
local type_definitions = Types.definitions

local try_get_entry = Register.try_get
local remove_entity = Register.remove_entity
local remove_entry = Register.remove_entry
local add_to_register = Register.add
local update_entities = Register.entity_update_cycle
local on_settings_pasted = Register.on_settings_pasted

local unlock_on_mined_entity = Technologies.on_mined_entity
local on_technology_finished = Technologies.finished

local update_inhabitants = Inhabitants.update
local update_city_info = Gui.update_city_info
local update_details_view = Gui.update_details_view
local update_scheduler = Scheduler.update
local update_communication = Communication.update
local update_weather = Weather.update
local update_technologies = Technologies.update

local create_mouseover_highlights = Visualisation.create_mouseover_highlights
local remove_mouseover_highlights = Visualisation.remove_mouseover_highlights

---------------------------------------------------------------------------------------------------
-- << event handler functions >>

local function update_cycle()
    local current_tick = game.tick

    ease_fear(current_tick)
    update_scheduler(current_tick)
    update_weather(current_tick)
    update_inhabitants(current_tick)
    update_entities(current_tick)
    update_technologies()

    update_city_info()
    update_details_view()

    update_communication(current_tick)

    global.last_update = current_tick
end

local function update_settings()
    global.updates_per_cycle = settings.global["sosciencity-entity-updates-per-cycle"].value

    global.maintenance_enabled = settings.global["sosciencity-penalty-module"].value
    global.starting_clockwork_points = settings.global["sosciencity-start-clockwork-points"].value

    global.tiriscef = settings.global["sosciencity-allow-tiriscef"].value
    global.profanity = settings.global["sosciencity-allow-profanity"].value

    Communication.settings_update()
end

local function set_locals()
    global = _ENV.global
end

local function on_load()
    set_locals()

    Scheduler.load()
    Neighborhood.load()
    Technologies.load()
    Register.load()
    Inventories.load()
    Inhabitants.load()
    Gui.load()
    Communication.load()
    Visualisation.load()
    Entity.load()
end

local function init()
    global = _ENV.global
    global.version = game.active_mods["sosciencity"]

    global.last_entity_update = -1
    global.last_tile_update = -1

    Scheduler.init()
    Weather.init()
    Neighborhood.init()
    Technologies.init()
    Register.init()
    Inventories.init()
    Inhabitants.init()
    Gui.init()
    Communication.init()
    Visualisation.init()
    Entity.init()
    Handcrafting.init()

    update_settings()

    global.last_update = game.tick

    on_load()
end

local function on_entity_built(event)
    global.last_entity_update = game.tick

    local entity = event.created_entity

    if not entity or not entity.valid or entity.force.name ~= "player" then
        return
    end

    local entity_type = get_entity_type(entity)
    add_to_register(entity, entity_type)
end

local function on_clone_built(event)
    global.last_entity_update = game.tick

    local destination = event.destination

    if not destination or not destination.valid or destination.force.name ~= "player" then
        return
    end

    local entity_type = get_entity_type(destination)

    -- try to copy the source - if possible
    local source = event.source
    if source and source.valid then
        local source_entry = try_get_entry(source.unit_number)
        if source_entry then
            Register.clone(source_entry, destination)
            return
        end
    end

    -- otherwise register the destination entity on it's own
    add_to_register(destination, entity_type)
end

local function on_script_built(event)
    global.last_entity_update = game.tick

    local entity = event.entity

    if not entity or not entity.valid or entity.force.name ~= "player" then
        return
    end

    local entity_type = get_entity_type(entity)

    add_to_register(entity, entity_type)
end

local function on_entity_removed(event)
    global.last_entity_update = game.tick

    local entity = event.entity -- all removement events use 'entity' as key
    if not entity.valid then
        return
    end

    remove_entity(entity, DeconstructionCause.unknown)
end

local function on_entity_died(event)
    global.last_entity_update = game.tick

    local entity = event.entity

    if not entity.valid then
        return
    end

    local unit_number = entity.unit_number
    local entry = try_get_entry(unit_number)
    if entry then
        local _type = entry[EK.type]

        if type_definitions[_type].is_civil then
            add_fear()
        end

        remove_entry(entry, DeconstructionCause.destroyed)
    end
end

local function on_entity_mined(event)
    global.last_entity_update = game.tick

    local entity = event.entity
    if not entity.valid then
        return
    end

    local unit_number = entity.unit_number
    local entry = try_get_entry(unit_number)
    if entry then
        remove_entry(entry, DeconstructionCause.mined)
    end

    unlock_on_mined_entity(event.buffer)
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

    local source_type = source_entry[EK.type]
    local destination_type = destination_entry[EK.type]

    on_settings_pasted(source_type, source_entry, destination_type, destination_entry)
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

    Communication.say_welcome(player)
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

local function on_research_finished(event)
    on_technology_finished(event.research.name)
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

local function on_tile_update()
    -- just notes the tick of the last tile-change
    -- this allowes me to expensively update tile information only when it's necessary
    global.last_tile_update = game.tick
end

local train_types =
    Tirislib_Tables.array_to_lookup {
    "locomotive",
    "artillery-wagon",
    "cargo-wagon",
    "fluid-wagon"
}

local function on_player_died(event)
    local causing_entity = event.cause

    if not causing_entity then
        return
    end

    if train_types[causing_entity.type] then
        Communication.player_got_run_over()
    end
end

local on_handcrafting = Handcrafting.on_craft

local function on_player_crafted(event)
    local player_id = event.player_index
    local name = event.recipe.name
    on_handcrafting(player_id, name)
end

local on_handcrafting_queue = Handcrafting.on_queued

local function on_player_queued_craft(event)
    local player_id = event.player_index
    local name = event.recipe.name
    local count = event.queued_count
    on_handcrafting_queue(player_id, name, count)
end

local function on_cheat_mode_enabled()
    Technologies.on_cheat_mode_enabled()
end

local function on_cheat_mode_disabled()
    Technologies.on_cheat_mode_disabled()
end

---------------------------------------------------------------------------------------------------
-- << event handler registration >>

-- initialisation
script.on_init(init)
script.on_load(on_load)
script.on_event(defines.events.on_runtime_mod_setting_changed, update_settings)

-- update function
script.on_nth_tick(10, update_cycle)

-- placement
-- filter out ghosts because my mod has nothing to do with them
local filter = {{filter = "ghost", invert = true}, {filter = "force", force = "player", mode = "and"}}
script.on_event(defines.events.on_built_entity, on_entity_built, filter)
script.on_event(defines.events.on_robot_built_entity, on_entity_built, filter)

-- the other events can't be filtered by force
filter = {{filter = "ghost", invert = true}}
script.on_event(defines.events.on_entity_cloned, on_clone_built, filter)
script.on_event(defines.events.script_raised_built, on_script_built, filter)
script.on_event(defines.events.script_raised_revive, on_script_built, filter)

-- removement
script.on_event(defines.events.on_player_mined_entity, on_entity_mined, filter)
script.on_event(defines.events.on_robot_mined_entity, on_entity_mined, filter)
script.on_event(defines.events.on_entity_died, on_entity_died, filter)
script.on_event(defines.events.script_raised_destroy, on_entity_removed, filter)
filter = nil

-- tile updates
script.on_event(defines.events.on_player_built_tile, on_tile_update)
script.on_event(defines.events.on_player_mined_tile, on_tile_update)
script.on_event(defines.events.on_robot_built_tile, on_tile_update)
script.on_event(defines.events.on_robot_mined_tile, on_tile_update)
script.on_event(defines.events.script_raised_set_tiles, on_tile_update)

-- copy-paste settings
script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

-- mod update
script.on_configuration_changed(on_configuration_change)

-- gui creation
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)

-- gui events
script.on_event(defines.events.on_gui_click, Gui.on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, Gui.on_gui_checked_state_changed)
script.on_event(defines.events.on_gui_value_changed, Gui.on_gui_value_changed)

-- research
script.on_event(defines.events.on_research_finished, on_research_finished)

-- selection
script.on_event(defines.events.on_selected_entity_changed, on_selection_changed)

-- tragic player deaths
script.on_event(defines.events.on_player_died, on_player_died)

-- player crafts
script.on_event(defines.events.on_player_crafted_item, on_player_crafted)
script.on_event(defines.events.on_pre_player_crafted_item, on_player_queued_craft)

-- cheat mode
script.on_event(defines.events.on_player_cheat_mode_enabled, on_cheat_mode_enabled)
script.on_event(defines.events.on_player_cheat_mode_disabled, on_cheat_mode_disabled)
