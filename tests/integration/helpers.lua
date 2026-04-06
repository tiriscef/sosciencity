local EK = require("enums.entry-key")

local Helpers = {}

local test_surface_name = "sosciencity-integration-test"

--- Creates a fresh surface with lab tiles for integration testing.
--- @return LuaSurface
function Helpers.create_test_surface()
    if game.surfaces[test_surface_name] then
        game.delete_surface(test_surface_name)
    end

    local surface = game.create_surface(test_surface_name)
    surface.generate_with_lab_tiles = true
    surface.build_checkerboard({{-100, -100}, {100, 100}})
    return surface
end

--- Deletes the test surface.
function Helpers.destroy_test_surface()
    if game.surfaces[test_surface_name] then
        game.delete_surface(test_surface_name)
    end
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

    return entry
end

--- Removes an entry from the register and destroys the entity.
--- @param entry Entry
function Helpers.destroy_entry(entry)
    Register.remove_entry(entry, require("enums.deconstruction-cause").unknown)
    local entity = entry[EK.entity]
    if entity and entity.valid then
        entity.destroy()
    end
end

return Helpers
