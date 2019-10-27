require("constants.types")

Housing = {}

Housing.houses = {}
    --[[["example-house"] = {
        room_count = 42,
        tech_level = 0,
        comfort = 32
    }]]

function Housing:get_capacity(registered_entity)
    return Housing(registered_entity).room_count / Caste(registered_entity.type).required_room_count
end

function Housing:get_free_capacity(registered_entity)
    return self:get_capacity(registered_entity) - registered_entity.inhabitants
end

local meta = {}

function Housing:__call(registered_entity)
    return self.houses[registered_entity.entity.name]
end

setmetatable(Housing, meta)
