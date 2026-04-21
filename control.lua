---------------------------------------------------------------------------------------------------
-- << helper functions >>

require("tirislib.init")

---------------------------------------------------------------------------------------------------
-- << enums, constants >>

local EK = require("enums.entry-key")
local DeconstructionCause = require("enums.deconstruction-cause")
local Housing = require("constants.housing")

---------------------------------------------------------------------------------------------------
-- << development feature flags >>

DEBUG = script.active_mods["sosciencity-debug"] ~= nil
BALANCING = script.active_mods["sosciencity-balancing"] ~= nil

if BALANCING then
    BalancingData = {
        scripted_items = {}, -- item/fluid name → unlock condition ("always" or tech_name)
        scripted_techs = {}, -- tech_name → human-readable description of unlock condition
        register_scripted_item = function(name, unlock_condition)
            BalancingData.scripted_items[name] = unlock_condition or "always"
        end,
        register_scripted_tech = function(tech_name, description)
            BalancingData.scripted_techs[tech_name] = description
        end
    }

    BalancingData.register_scripted_item("garbage", "upbringing")
    BalancingData.register_scripted_item("food-leftovers", "upbringing")
    BalancingData.register_scripted_item("humus", "composting-silo")
    BalancingData.register_scripted_item("necrofall", "composting-silo")
    BalancingData.register_scripted_item("medical-report", "medbay")
else
    BalancingData = {
        register_scripted_item = function() end,
        register_scripted_tech = function() end
    }
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
    if on_script_trigger_handlers[id] then
        error("Duplicate script_trigger handler registration for id '" .. tostring(id) .. "'")
    end
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
require("classes.statistics")
require("classes.communication")
require("classes.visualisation")
require("classes.item-requests")
require("classes.inventories")
require("classes.inhabitants")
require("classes.entity")
require("classes.handcrafting")
require("classes.gui")
require("classes.tree-planting")

if DEBUG then
    require("tests.load-tests")
    require("tests.controlstage.load-tests")

    commands.add_command(
        "sosciencity-tests",
        "",
        function(input)
            local results
            local group = input.parameter
            if group then
                results = Tirislib.Testing.run_group_suite(group, true)
            else
                results = Tirislib.Testing.run_all_except_group("integration", true)
            end

            game.print(results)
            log(results)
            helpers.write_file("test-results.txt", results)
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
                results = Tirislib.Testing.run_all_except_group("integration", false)
            end

            game.print(results)
            log(results)
            helpers.write_file("test-results.txt", results)
        end
    )

    require("tests.integration.load-tests")
    local IntegrationHelpers = require("tests.integration.helpers")

    commands.add_command(
        "sosciencity-integration-tests",
        "",
        function(input)
            local results
            local group = input.parameter
            if group then
                results = Tirislib.Testing.run_group_suite(group, true)
            else
                results = Tirislib.Testing.run_group_suite("integration", true)
            end

            game.print(results)
            log(results)
            helpers.write_file("test-results.txt", results)

            IntegrationHelpers.delete_test_surfaces()
        end
    )
end

if BALANCING then
    require("balancing")
end

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

local on_technology_finished = Technologies.finished

local update_inhabitants = Inhabitants.update
local update_gui = Gui.update_guis
local update_scheduler = Scheduler.update
local update_statistics = Statistics.update
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

    update_statistics(current_tick)
    update_communication(current_tick)

    storage.last_update = current_tick
end

local function update_settings()
    storage.updates_per_cycle = settings.global["sosciencity-entity-updates-per-cycle"].value

    storage.maintenance_enabled = settings.global["sosciencity-penalty-module"].value
    storage.starting_clockwork_points = settings.global["sosciencity-start-clockwork-points"].value

    storage.tiriscef = settings.global["sosciencity-allow-tiriscef"].value

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
    Statistics.load()
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
    Statistics.init()
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

    -- If more handlers for ghosts or specific entity names arise, 
    -- then we should add a handler-register pattern to the Register class for those.
    -- For now these 2 are fine I guess.

    if entity.type == "entity-ghost" then
        Inhabitants.on_house_ghost_placed(entity, event)
        return
    end

    -- Tree sapling marker: immediately swap for a random natural tree
    if entity.name == "sosciencity-tree-sapling" then
        TreePlanting.on_sapling_placed(entity, event)
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

    on_settings_pasted(source_type, source_entry, destination_type, destination_entry, event)
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
            Register.remove_entry(entry, DeconstructionCause.mod_update, nil, true)
            if entry[EK.entity].valid then
                Register.clone(entry, entry[EK.entity])
            end
        end

        Technologies.init()

        -- don't know why, but the migration script doesn't activate for some saves
        -- TODO: remove this after some updates maybe
        storage.active_machine_count = storage.active_machine_count or 0
        storage.placement_settings = storage.placement_settings or {}

        -- Phase 1 of housing comfort rework: set current_comfort from old fixed comfort values
        if old_version and Tirislib.Utils.version_is_smaller_than(old_version, "0.2.2") then
            local housing_values = Housing.values
            for _, entry in pairs(storage.register) do
                local house = housing_values[entry[EK.name]]
                if house then
                    entry[EK.current_comfort] = house.comfort
                end
            end
        end

        -- Phase 2: initialise target_comfort for existing saves
        if old_version and Tirislib.Utils.version_is_smaller_than(old_version, "0.2.3") then
            for _, entry in pairs(storage.register) do
                if Housing.values[entry[EK.name]] then
                    entry[EK.target_comfort] = entry[EK.current_comfort] or 0
                end
            end
        end
    end

    Statistics.migrate()
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
    Tirislib.Arrays.to_lookup {
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
-- on_built_entity handles both real entities and house ghosts (tag injection)
script.on_event(defines.events.on_built_entity, on_entity_built)
-- robots and scripts only ever place real entities, so filter out ghosts for them
local filter = {{filter = "ghost", invert = true}}
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

-- advanced placement mode: show/hide CityInfo placement controls when holding a house item
local function on_cursor_stack_changed(event)
    local player = game.players[event.player_index]
    local cursor = player.cursor_stack
    local holding_house = cursor and cursor.valid_for_read and Housing.values[cursor.name]

    if holding_house then
        if not storage.placement_settings[event.player_index] then
            storage.placement_settings[event.player_index] = {target_comfort = 0, auto_assign_caste = nil}
        end
        Gui.CityInfo.set_placement_mode(player, true)
    else
        Gui.CityInfo.set_placement_mode(player, false)
    end
end
script.on_event(defines.events.on_player_cursor_stack_changed, on_cursor_stack_changed)

-- gui events
script.on_event(defines.events.on_gui_opened, Gui.on_gui_opened)
script.on_event(defines.events.on_gui_closed, Gui.on_gui_closed)
script.on_event(defines.events.on_gui_click, Gui.on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, Gui.on_gui_checked_state_changed)
script.on_event(defines.events.on_gui_value_changed, Gui.on_gui_value_changed)
script.on_event(defines.events.on_gui_confirmed, Gui.on_gui_confirmed)
script.on_event(defines.events.on_gui_text_changed, Gui.on_gui_text_changed)
script.on_event(defines.events.on_gui_elem_changed, Gui.on_gui_elem_changed)
script.on_event(defines.events.on_gui_selection_state_changed, Gui.on_gui_selection_state_changed)

-- research
script.on_event(defines.events.on_research_finished, on_research_finished)

-- selection
script.on_event(defines.events.on_selected_entity_changed, on_selection_changed)

-- tragic player deaths
script.on_event(defines.events.on_player_died, on_player_died)

-- player crafts
script.on_event(defines.events.on_player_crafted_item, on_player_crafted)
script.on_event(defines.events.on_pre_player_crafted_item, on_player_queued_craft)

-- trigger events
script.on_event(defines.events.on_script_trigger_effect, on_script_trigger)

-- player creates a blueprint
script.on_event(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)

-- forestry selection tool
script.on_event(defines.events.on_player_selected_area, TreePlanting.on_area_selected)
script.on_event(defines.events.on_player_alt_selected_area, TreePlanting.on_area_selected)
