local EK = require("enums.entry-key")
local DeconstructionCause = require("enums.deconstruction-cause")

local Helpers = {}

local default_surface_name = "sosciencity-integration-test"

-- Surfaces created during the test run, for final teardown
local test_surfaces = {}

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
        test_surfaces[name] = surface
    end

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

    -- Safety net: destroy any entities that slipped through (sub-entities, etc.).
    -- Factorio defers surface.clear() to the next tick so it doesn't interfere
    -- with surface reuse within the same test run.
    for _, surface in pairs(test_surfaces) do
        if surface.valid then
            surface.clear()
        end
    end

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

--- Removes an entry from the register and destroys the entity.
--- @param entry Entry
function Helpers.destroy_entry(entry)
    local entity = entry[EK.entity]
    Register.remove_entry(entry, DeconstructionCause.unknown)
    if entity and entity.valid then
        entity.destroy()
    end
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
end

return Helpers
