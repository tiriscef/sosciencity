require("constants.types")

Housing = {}

Housing.houses = {
    ["test-house"] = {
        room_count = 2,
        tech_level = 0,
        comfort = 0
    }
}
    --[[["example-house"] = {
        room_count = 42,
        tech_level = 0,
        comfort = 32
    }]]

function Housing:get_capacity(entry)
    return Housing(entry).room_count / Caste(entry.type).required_room_count
end

function Housing:get_free_capacity(entry)
    return self:get_capacity(entry) - entry.inhabitants
end

local meta = {}

function Housing:__call(entry)
    return self.houses[entry.entity.name]
end

setmetatable(Housing, meta)
