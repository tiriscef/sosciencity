require("constants.types")

Housing = {}

Housing.houses = {}
    --[[["example-house"] = {
        room_number,
        tech_level = 0,
        castes = {
            [TYPE_CLOCKWORK] = {
                capacity_multiplier = 2,
                contentment = 1
            }
        },
    }]]

function Housing:get_capacity(registered_entity)
    -- TODO
end

function Housing:get_free_capacity(registered_entity)
    
end
