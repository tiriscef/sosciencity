local EK = require("enums.entry-key")
local DeconstructionCause = require("enums.deconstruction-cause")

---------------------------------------------------------------------------------------------------
-- << helper functions >>

require("tirislib.init")

---------------------------------------------------------------------------------------------------
-- << debug stuff >>

DEBUG = false

if script.active_mods["sosciencity-debug"] then
    DEBUG = true

    -- development tools
    pcall(require, "__profiler__/profiler.lua")

    commands.add_command(
        "sosciencity-tests",
        "",
        function(input)
            local results
            local group = input.parameter
            if group then
                results = Tirislib.Testing.run_group_suite(group, true)
            else
                results = Tirislib.Testing.run_all(true)
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
                results = Tirislib.Testing.run_group_suite(group, false)
            else
                results = Tirislib.Testing.run_all(false)
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
-- << Events >>

--- Static class for registering event handlers.
Events = {}

local on_init_handlers = {}

--- Adds a function to be called during the init-Phase.
--- @param fn function
function Events.set_on_init_handler(fn)
    Tirislib.Utils.desync_protection()
    on_init_handlers[#on_init_handlers + 1] = fn
end

local on_script_trigger_handlers = {}

--- Adds a function to be called when a script trigger with a specified id is being... triggered.
--- @param id string
--- @param fn function
function Events.set_script_trigger_handler(id, fn)
    Tirislib.Utils.desync_protection()
    on_script_trigger_handlers[id] = fn
end

---------------------------------------------------------------------------------------------------
-- << constants >>

local Types = require("constants.types")

---------------------------------------------------------------------------------------------------
-- << classes >>

require("classes.locale")
require("classes.scheduler")
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

--[[
    Data this script stores in storage
    --------------------------------
    storage.last_entity_update: tick
    storage.last_tile_update: tick
]]
---------------------------------------------------------------------------------------------------
-- local all the frequently called functions for miniscule performance gains

local storage

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
local update_gui = Gui.update_guis
local update_scheduler = Scheduler.update
local update_communication = Communication.update
local update_technologies = Technologies.update

local create_mouseover_highlights = Visualisation.create_mouseover_highlights
local remove_mouseover_highlights = Visualisation.remove_mouseover_highlights

---------------------------------------------------------------------------------------------------
-- << event handler functions >>

local function update_cycle()
    local current_tick = game.tick

    ease_fear(current_tick)
    update_scheduler(current_tick)
    update_inhabitants(current_tick)
    update_entities(current_tick)
    update_technologies()

    update_gui()

    update_communication(current_tick)

    storage.last_update = current_tick
end

local function update_settings()
    storage.updates_per_cycle = settings.global["sosciencity-entity-updates-per-cycle"].value

    storage.maintenance_enabled = settings.global["sosciencity-penalty-module"].value
    storage.starting_clockwork_points = settings.global["sosciencity-start-clockwork-points"].value

    storage.tiriscef = settings.global["sosciencity-allow-tiriscef"].value
    storage.profanity = settings.global["sosciencity-allow-profanity"].value

    Communication.settings_update()
end

local function set_locals()
    storage = _ENV.storage
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
    storage = _ENV.storage
    storage.version = script.active_mods["sosciencity"]

    storage.last_entity_update = -1
    storage.last_tile_update = -1

    Scheduler.init()
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

    storage.last_update = game.tick

    on_load()

    for _, fn in pairs(on_init_handlers) do
        fn()
    end
end

local function on_entity_built(event)
    storage.last_entity_update = game.tick

    local entity = event.entity

    if not entity or not entity.valid then
        return
    end

    local entity_type = get_entity_type(entity)

    add_to_register(entity, entity_type, event)
end

local function on_clone_built(event)
    storage.last_entity_update = game.tick

    local destination = event.destination

    if not destination or not destination.valid then
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
    add_to_register(destination, entity_type, event)
end

local function on_entity_removed(event)
    storage.last_entity_update = game.tick

    local entity = event.entity -- all removement events use 'entity' as key
    if not entity.valid then
        return
    end

    remove_entity(entity, DeconstructionCause.unknown)
end

local function on_entity_died(event)
    storage.last_entity_update = game.tick

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

        remove_entry(entry, DeconstructionCause.destroyed, event)
    end
end

local function on_entity_mined(event)
    storage.last_entity_update = game.tick

    local entity = event.entity
    if not entity.valid then
        return
    end

    local unit_number = entity.unit_number
    local entry = try_get_entry(unit_number)
    if entry then
        remove_entry(entry, DeconstructionCause.mined, event)
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
    if script.active_mods["sosciencity"] ~= storage.version then
        local old_version = storage.version
        storage.version = script.active_mods["sosciencity"]

        Communication.say("tiriscef.", "migration1")
        Communication.say("tiriscef.", "migration2")

        local version_notes = {}

        for version, note in pairs(version_notes) do
            if Tirislib.Utils.version_is_smaller_than(old_version, version) then
                game.print(string.format("Version %s Info: %s", version, note))
            end
        end

        -- Reset recipes and techs in case I changed something.
        -- I do that a lot and don't want to forget a migration file.
        for _, force in pairs(game.forces) do
            force.reset_recipes()
            force.reset_technologies()
            force.reset_technology_effects()
        end

        Gui.reset_guis()

        -- Rebuild entries
        local old_register = Tirislib.Tables.copy(storage.register)

        for _, entry in pairs(old_register) do
            Register.remove_entry(entry, DeconstructionCause.mod_update)
            if entry[EK.entity].valid then
                Register.clone(entry, entry[EK.entity])
            end
        end

        Technologies.init()

        -- don't know why, but the migration script doesn't activate for some saves
        -- TODO: remove this after some updates maybe
        storage.active_machine_count = storage.active_machine_count or 0
    end
end

local function on_player_created(event)
    local index = event.player_index
    local player = game.get_player(index)

    Gui.create_guis(player)

    Communication.say_welcome(player)
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
    -- this allows me to expensively update tile information only when it's necessary
    storage.last_tile_update = game.tick
end

local train_types =
    Tirislib.Tables.array_to_lookup {
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

local function on_script_trigger(event)
    local fn = on_script_trigger_handlers[event.effect_id]

    if fn then
        fn(event)
    end
end

local function on_player_setup_blueprint(event)
    local blueprint = event.stack or event.record
    if not blueprint then
        return
    end

    local entities = blueprint.get_blueprint_entities()
    if not entities then
        return
    end

    for index, blueprint_entity in pairs(entities) do
        local entity = event.surface.find_entity(blueprint_entity.name, blueprint_entity.position)
        if not entity then
            goto continue
        end

        local entry = try_get_entry(entity.unit_number)
        if not entry then
            goto continue
        end

        Register.on_blueprinted(entry, blueprint, index)

        ::continue::
    end
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
-- filter out ghosts because Sosciencity has nothing to do with them
local filter = {{filter = "ghost", invert = true}}
script.on_event(defines.events.on_built_entity, on_entity_built, filter)
script.on_event(defines.events.on_robot_built_entity, on_entity_built, filter)
script.on_event(defines.events.script_raised_built, on_entity_built, filter)
script.on_event(defines.events.script_raised_revive, on_entity_built, filter)
script.on_event(defines.events.on_entity_cloned, on_clone_built, filter)

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

-- player creation
script.on_event(defines.events.on_player_created, on_player_created)

-- gui events
script.on_event(defines.events.on_gui_opened, Gui.on_gui_opened)
script.on_event(defines.events.on_gui_closed, Gui.on_gui_closed)
script.on_event(defines.events.on_gui_click, Gui.on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, Gui.on_gui_checked_state_changed)
script.on_event(defines.events.on_gui_value_changed, Gui.on_gui_value_changed)
script.on_event(defines.events.on_gui_confirmed, Gui.on_gui_confirmed)

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

-- trigger events
script.on_event(defines.events.on_script_trigger_effect, on_script_trigger)

-- player creates a blueprint
script.on_event(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)

---------------------------------------------------------------------------------------------------
-- << balancing stuff >>

if script.active_mods["sosciencity-balancing"] then
    require("balancing")
end
