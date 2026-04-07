local EK = require("enums.entry-key")
local DeconstructionCause = require("enums.deconstruction-cause")

local Helpers = {}

local default_surface_name = "sosciencity-integration-test"

-- Entries created during the current test, for cleanup
local tracked_entries = {}

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
        surface.build_checkerboard({{-100, -100}, {100, 100}})
    end

    tracked_entries = {}
    return surface
end

--- Removes all entries created during this test from the register and destroys their entities.
function Helpers.clean_up()
    for _, entry in pairs(tracked_entries) do
        if Register.try_get(entry[EK.unit_number]) then
            Register.remove_entry(entry, DeconstructionCause.unknown)
        end
        local entity = entry[EK.entity]
        if entity and entity.valid then
            entity.destroy()
        end
    end
    tracked_entries = {}
end

--- Creates an entity on the given surface and registers it.
--- @param surface LuaSurface
--- @param name string entity prototype name
--- @param position table {x, y}
--- @return Entry
function Helpers.create_and_register(surface, name, position)
    local entity = surface.create_entity {
        name = name,
        position = position,
        force = "player"
    }
    assert(entity, "Failed to create entity '" .. name .. "' at {" .. position[1] .. ", " .. position[2] .. "}")

    local entry = Register.add(entity)
    assert(entry, "Failed to register entity '" .. name .. "'")

    tracked_entries[#tracked_entries + 1] = entry
    return entry
end

--- Removes an entry from the register and destroys the entity.
--- @param entry Entry
function Helpers.destroy_entry(entry)
    Register.remove_entry(entry, DeconstructionCause.unknown)
    local entity = entry[EK.entity]
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
    Inhabitants.try_allow_for_caste(entry, caste, false)
    if count > 0 then
        local group = InhabitantGroup.new(caste, count)
        InhabitantGroup.merge(entry, group)
        -- sync census fields that update_housing_census would normally set
        storage.population[caste] = (storage.population[caste] or 0) + count
        entry[EK.official_inhabitants] = count
    end
    return entry
end

--- Resets inhabitants-related global state to a clean baseline.
--- Mirrors what happens on a new game. Tests that need specific tech levels
--- or population counts should set them after calling this.
function Helpers.reset_inhabitants_state()
    Inhabitants.init()
    Inhabitants.load()
end

return Helpers
