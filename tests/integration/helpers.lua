local EK = require("enums.entry-key")
local PK = require("enums.performance-key")
local DeconstructionCause = require("enums.deconstruction-cause")

local Helpers = {}

local default_surface_name = "sosciencity-integration-test"

-- Surfaces created during the test run, for final teardown
local test_surfaces = {}

local position_counter = 0
local position_stride = 5

--- Returns a test surface with lab tiles, creating it on first call per name.
--- Note: Factorio defers surface deletion (and clear()) to a future tick, so we cannot
--- delete and recreate a surface with the same name within the same tick. Instead, surfaces
--- are created once and reused. Test isolation is achieved by explicitly cleaning up
--- registered entries via clean_up().
--- @param name string? surface name, defaults to "sosciencity-integration-test"
--- @return LuaSurface
function Helpers.create_test_surface(name)
    name = name or default_surface_name

    local surface = game.surfaces[name]

    if not surface then
        surface = game.create_surface(name)
        surface.generate_with_lab_tiles = true
        surface.build_checkerboard({ { -100, -100 }, { 100, 100 } })
    end
    test_surfaces[name] = surface

    Helpers.reset_inhabitants_state()
    return surface
end

--- Removes all entries created during this test from the register and destroys their entities.
--- Clears the surface afterward to catch any sub-entities.
function Helpers.clean_up()
    -- Just remove everything in the register.
    for _, entry in pairs(storage.register) do
        local entity = entry[EK.entity]
        Register.remove_entry(entry, DeconstructionCause.unknown)
        if entity and entity.valid then
            entity.destroy()
        end
    end

    -- Safety net: destroy any entities that slipped through (sub-entities, combinators
    -- wired up in tests, etc.). We iterate find_entities_filtered instead of surface.clear()
    -- because surface.clear() is deferred to the next game tick, which would destroy
    -- entities created by the next test when tick-advancing tests are in the suite.
    for _, surface in pairs(test_surfaces) do
        if surface.valid then
            for _, entity in pairs(surface.find_entities_filtered({})) do
                if entity.valid then
                    entity.destroy()
                end
            end
        end
    end

    position_counter = 0
    Helpers.reset_inhabitants_state()
end

--- Deletes all test surfaces. Call this at the end of a full test run so
--- the surfaces do not persist in the save and their entities stop generating alerts.
function Helpers.delete_test_surfaces()
    for name, surface in pairs(test_surfaces) do
        if surface.valid then
            game.delete_surface(surface)
        end
        test_surfaces[name] = nil
    end
end

--- Creates an entity on the given surface and registers it.
--- @param surface LuaSurface
--- @param name string entity prototype name
--- @param position table {x, y}
--- @param _type Type? entry type to register the entity as
--- @return Entry
function Helpers.create_and_register(surface, name, position, _type)
    local entity = surface.create_entity {
        name = name,
        position = position,
        force = "player"
    }
    assert(entity, "Failed to create entity '" .. name .. "' at {" .. position[1] .. ", " .. position[2] .. "}")

    local entry = Register.add(entity, _type)
    assert(entry, "Failed to register entity '" .. name .. "'")

    return entry
end

--- Creates an entity without registering it. Use when a test needs to control the exact
--- registration moment, e.g. to mutate entity state before Register.add sees it.
--- @param surface LuaSurface
--- @param name string entity prototype name
--- @param position table {x, y}
--- @return LuaEntity
function Helpers.create_unregistered(surface, name, position)
    local entity = surface.create_entity {
        name = name,
        position = position,
        force = "player"
    }
    assert(entity, "Failed to create entity '" .. name .. "' at {" .. position[1] .. ", " .. position[2] .. "}")
    return entity
end

--- Returns the next non-overlapping position for placing test entities.
--- Positions reset to the origin when clean_up() is called.
--- @return table {x, y}
function Helpers.next_position()
    local pos = {position_counter * position_stride, 0}
    position_counter = position_counter + 1
    return pos
end

--- Triggers a full update cycle on an entry.
--- Use this instead of Register.update_entry(entry, game.tick) in tests.
--- Register.update_entry skips the updater when delta_ticks = 0
--- @param entry Entry
function Helpers.update_entry(entry)
    Register.update_entry(entry, entry[EK.last_update] + 1)
end

--- Removes an entry from the register and destroys the entity.
--- @param entry Entry
function Helpers.destroy_entry(entry)
    local entity = entry[EK.entity]
    Register.remove_entry(entry, DeconstructionCause.unknown)
    if entity and entity.valid then
        entity.destroy()
    end
end

--- Asserts that an entry is currently in the register.
--- @param entry Entry
--- @param message string?
function Helpers.assert_is_registered(entry, message)
    local unit_number = entry[EK.unit_number]
    Tirislib.Testing.Assert.not_nil(
        Register.try_get(unit_number),
        message or ("expected entry " .. unit_number .. " to be in the register")
    )
end

--- Asserts that an entry is no longer in the register.
--- @param entry Entry
--- @param message string?
function Helpers.assert_not_registered(entry, message)
    local unit_number = entry[EK.unit_number]
    Tirislib.Testing.Assert.is_nil(
        Register.try_get(unit_number),
        message or ("expected entry " .. unit_number .. " to not be in the register")
    )
end

--- Creates a test-house, assigns it to a caste, and populates it with healthy inhabitants.
--- Properly updates population tracking and official_inhabitants.
--- @param surface LuaSurface
--- @param position table {x, y}
--- @param caste Type caste id (must be researched in storage.technologies)
--- @param count integer number of inhabitants
--- @return Entry the populated house entry
function Helpers.create_inhabited_house(surface, position, caste, count)
    local entry = Helpers.create_and_register(surface, "test-house", position)
    local inhabited = Inhabitants.try_allow_for_caste(entry, caste, false)
    assert(inhabited, "create_inhabited_house: try_allow_for_caste failed for caste " .. tostring(caste))

    if count > 0 then
        local group = InhabitantGroup.new(caste, count)
        InhabitantGroup.merge(inhabited, group)
        -- sync census fields that update_housing_census would normally set
        storage.population[caste] = (storage.population[caste] or 0) + count
        inhabited[EK.official_inhabitants] = count
    end
    return inhabited
end

--- Resets inhabitants-related global state to a clean baseline.
--- Mirrors what happens on a new game. Tests that need specific tech levels
--- or population counts should set them after calling this.
function Helpers.reset_inhabitants_state()
    Inhabitants.init()
    Inhabitants.load()
    Entity.load()
end

--- Finds an effect entry by ID inside a performance report, or nil if absent.
--- @param report table performance report from Entity.build_performance_report
--- @param effect_id integer PE enum value
--- @return table?
function Helpers.find_effect(report, effect_id)
    for _, eff in pairs(report[PK.effects]) do
        if eff[PK.effect] == effect_id then
            return eff
        end
    end
    return nil
end

--- Returns true if any slot in the inventory has a filter set to the given item name.
--- @param inventory LuaInventory
--- @param item_name string
--- @return boolean
function Helpers.has_filter_for(inventory, item_name)
    for i = 1, #inventory do
        local filter = inventory.get_filter(i)
        if filter and filter.name == item_name then
            return true
        end
    end
    return false
end

return Helpers
