require("constants.types")

Housing = {}

Housing.houses = {}
    --[[["example-house"] = {
        room_count,
        tech_level = 0,
        castes = {
            [TYPE_CLOCKWORK] = {
                capacity_multiplier = 2,
                contentment = 1
            }
        },
    }]]

function Housing:__call(registered_entity)
    return self.houses[registered_entity.entity.name]
end

function Housing:get_capacity(registered_entity)
    return Housing(registered_entity).room_count / Caste(registered_entity.type).required_room_count
end

function Housing:get_free_capacity(registered_entity)
    return self:get_capacity(registered_entity) - registered_entity.inhabitants
end
