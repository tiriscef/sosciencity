pcall(require, "__debugadapter__/debugadapter.lua")
pcall(require, "__profiler__/profiler.lua")
--[[
    TODO
        - balance basicly everything
        - diseases
        - custom entity guis
        - city events & communication
]]
---------------------------------------------------------------------------------------------------
-- << helper functions >>
require("lib.utils")

---------------------------------------------------------------------------------------------------
-- << runtime finals >>
require("constants.castes")
require("constants.diseases")
require("constants.types")
require("constants.food")
require("constants.housing")
require("constants.buildings")
require("constants.drinking-water")
require("constants.speakers")
require("constants.garbage")
require("constants.colors")

---------------------------------------------------------------------------------------------------
-- << classes >>
-- EmmyLua stuff
---@class Entity
---@class Entry
---@class Player
---@class Type

local Replacer = require("scripts.control.replacer")
local Register = require("scripts.control.register")
local Technologies = require("scripts.control.technologies")
local Subentities = require("scripts.control.subentities")
local Neighborhood = require("scripts.control.neighborhood")
local Communication = require("scripts.control.communication")
local Inventories = require("scripts.control.inventories")
local Consumption = require("scripts.control.consumption")
local Inhabitants = require("scripts.control.inhabitants")
local Gui = require("scripts.control.gui")

---------------------------------------------------------------------------------------------------
-- << update functions >>
-- entities need to be checked for validity before calling the update-function
-- local all the frequently called functions for miniscule performance gains

local global
local caste_bonuses
local water_values = DrinkingWater.values

local floor = math.floor

local add_fear = Inhabitants.add_fear
local add_casualty_fear = Inhabitants.add_casualty_fear
local ease_fear = Inhabitants.ease_fear

local set_beacon_effects = Subentities.set_beacon_effects

local get_entity_type = Types.get_entity_type
local is_affected_by_clockwork = Types.is_affected_by_clockwork
local is_affected_by_orchid = Types.is_affected_by_orchid
local is_civil = Types.is_civil
local is_inhabited = Types.is_inhabited
local is_relevant_to_register = Types.is_relevant_to_register

local try_get_entry = Register.try_get
local remove_entity = Register.remove_entity
local add_to_register = Register.add

local update_caste_bonuses = Inhabitants.update_caste_bonuses
local immigration = Inhabitants.immigration

local update_city_info = Gui.update_city_info
local update_details_view = Gui.update_details_view

--local replace = Replacer.replace

local update_communication = Communication.update
local log_fluid = Communication.log_fluid
local create_mouseover_highlights = Communication.create_mouseover_highlights
local remove_mouseover_highlights = Communication.remove_mouseover_highlights

local get_building_details = Buildings.get

local has_power = Subentities.has_power

-- Assumes that the entity has a beacon
local function update_entity_with_beacon(entry)
    local _type = entry[EK.type]
    local speed_bonus = 0
    local productivity_bonus = 0
    local use_penalty_module = false

    if is_affected_by_clockwork(_type) then
        speed_bonus = caste_bonuses[Type.clockwork]
        use_penalty_module = global.use_penalty
    end
    if _type == Type.rocket_silo then
        productivity_bonus = caste_bonuses[Type.aurora]
    end
    if is_affected_by_orchid(_type) then
        productivity_bonus = caste_bonuses[Type.orchid]
    end
    if _type == Type.orangery then
        local age = game.tick - entry[EK.tick_of_creation]
        productivity_bonus = productivity_bonus + math.floor(math.sqrt(age)) -- TODO balance
    end

    set_beacon_effects(entry, speed_bonus, productivity_bonus, use_penalty_module)
end

local function update_waterwell(entry, delta_ticks)
    if not has_power(entry) then
        return
    end

    local building_details = get_building_details(entry)
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    local groundwater_volume = (delta_ticks * building_details.speed) / near_count

    local inserted =
        entry[EK.entity].insert_fluid {
        name = "groundwater",
        amount = groundwater_volume
    }
    log_fluid("groundwater", inserted)
end

local function update_water_distributer(entry)
    local entity = entry[EK.entity]

    -- determine and save the type of water that this distributer provides
    -- this is because it's unlikely to ever change (due to the system that prevents fluids from mixing)
    -- but needs to be checked often
    if has_power(entry) then
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

local function update_manufactory(entry)
    local details = get_building_details(entry).workforce
    local performance = Inhabitants.evaluate_workforce(entry, details)

    entry[EK.entity].active = performance > 0.4

    local speed = performance > 0.4 and floor(100 * performance - 20) or 0
    set_beacon_effects(entry, speed, nil, true)
end

local update_functions = {
    [Type.clockwork] = Inhabitants.update_house,
    [Type.ember] = Inhabitants.update_house,
    [Type.gunfire] = Inhabitants.update_house,
    [Type.gleam] = Inhabitants.update_house,
    [Type.foundry] = Inhabitants.update_house,
    [Type.orchid] = Inhabitants.update_house,
    [Type.aurora] = Inhabitants.update_house,
    [Type.plasma] = Inhabitants.update_house,
    [Type.assembling_machine] = update_entity_with_beacon,
    [Type.furnace] = update_entity_with_beacon,
    [Type.rocket_silo] = update_entity_with_beacon,
    [Type.farm] = update_entity_with_beacon,
    [Type.mining_drill] = update_entity_with_beacon,
    [Type.orangery] = update_entity_with_beacon,
    [Type.waterwell] = update_waterwell,
    [Type.water_distributer] = update_water_distributer,
    [Type.manufactory] = update_manufactory
}

---------------------------------------------------------------------------------------------------
-- << event handler functions >>
local function update_cycle()
    local current_tick = game.tick
    ease_fear(current_tick)

    local next_entry = Register.next
    local count = 0
    local index = global.last_index
    local current_entry = try_get_entry(index)
    local number_of_checks = global.updates_per_cycle

    if not current_entry then
        index, current_entry = next_entry() -- begin a new loop at the start (nil as a key returns the first pair)
    end

    while index and count < number_of_checks do
        local _type = current_entry[EK.type]
        local updater = update_functions[_type]
        if updater ~= nil then
            local delta_ticks = current_tick - current_entry[EK.last_update]
            if delta_ticks > 0 then
                updater(current_entry, delta_ticks)
            end
        end

        current_entry[EK.last_update] = current_tick
        index, current_entry = next_entry(index)
        count = count + 1
    end
    global.last_index = index

    immigration(10) -- the time between update_cycles is always 10 ticks
    update_caste_bonuses()
    update_city_info()
    update_details_view()
    update_communication(current_tick)

    global.last_update = current_tick
end

local function update_settings()
    global.updates_per_cycle = settings.global["sosciencity-entity-updates-per-cycle"].value

    global.use_penalty = settings.global["sosciencity-penalty-module"].value

    global.tiriscef = settings.global["sosciencity-allow-tiriscef"].value
    global.profanity = settings.global["sosciencity-allow-profanity"].value

    Communication.settings_update()
end

local function set_locals()
    global = _ENV.global
    caste_bonuses = global.caste_bonuses
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
    Gui.load()
    Inhabitants.load()
    Communication.load()
end

local function on_entity_built(event)
    local entity = event.created_entity

    if not entity or not entity.valid or entity.force.name ~= "player" then
        return
    end

    local entity_type = get_entity_type(entity)

    if is_relevant_to_register(entity_type) then
        add_to_register(entity, entity_type)
    end
end

local function on_clone_built(event)
    local destination = event.destination

    if not destination or not destination.valid or destination.force.name ~= "player" then
        return
    end

    local entity_type = get_entity_type(destination)

    if is_relevant_to_register(entity_type) then
        -- try to copy the source - if possible
        local source = event.source
        if source and source.valid then
            local source_entry = try_get_entry(source.unit_number)
            if source_entry then
                Register.clone(source_entry, destination)
            end
        end

        -- otherwise register the destination entity on it's own
        add_to_register(destination, entity_type)
    end
end

local function on_script_built(event)
    local entity = event.entity

    if not entity or not entity.valid or entity.force.name ~= "player" then
        return
    end

    local entity_type = get_entity_type(entity)

    if is_relevant_to_register(entity_type) then
        add_to_register(entity, entity_type)
    end
end

local function on_entity_removed(event)
    local entity = event.entity -- all removement events use 'entity' as key
    if not entity.valid then
        return
    end

    remove_entity(entity)
end

local function on_entity_died(event)
    local entity = event.entity

    if not entity.valid then
        return
    end

    local unit_number = entity.unit_number
    local entry = try_get_entry(unit_number)
    if entry then
        local _type = entry[EK.type]

        if is_inhabited(_type) then
            add_casualty_fear(entry)
        elseif is_civil(_type) then
            add_fear()
        end
    end

    remove_entity(entity)
end

local function on_entity_mined(event)
    local entity = event.entity
    if not entity.valid then
        return
    end

    local unit_number = entity.unit_number
    local entry = try_get_entry(unit_number)
    if entry and Types.is_inhabited(entry[EK.type]) then
        Inhabitants.try_resettle(entry, unit_number)
    end

    remove_entity(entity)
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
    if is_inhabited(source_type) and destination_type == Type.empty_house then
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

local UNIQUE_PREFIX = Gui.UNIQUE_PREFIX -- greetings to LuziferSenpai
local PREFIX_LENGTH = UNIQUE_PREFIX:len()
local function on_gui_click(event)
    local gui_element = event.element
    local name = gui_element.name

    -- check if it's my gui with my prefix
    if name:sub(1, PREFIX_LENGTH) ~= UNIQUE_PREFIX then
        return
    end
    -- remove the prefix
    name = name:sub(PREFIX_LENGTH + 1)

    -- check Caste assignment buttons
    for caste_id, caste in pairs(Castes.values) do
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
script.on_nth_tick(10, update_cycle)
script.on_event(defines.events.on_runtime_mod_setting_changed, update_settings)

-- placement
-- filter out ghosts because my mod has nothing to do with them
local filter = {{filter = "ghost", invert = true}, {filter = "force", force = "player", mode = "and"}}
script.on_event(defines.events.on_built_entity, on_entity_built, filter)
script.on_event(defines.events.on_robot_built_entity, on_entity_built, filter)
script.on_event(defines.events.on_entity_cloned, on_clone_built)
script.on_event(defines.events.script_raised_built, on_script_built)
script.on_event(defines.events.script_raised_revive, on_script_built)

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
