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
function Housing.get_capacity(entry)
    return math.floor(Housing(entry).room_count / Caste(entry.type).required_room_count)
end

function Housing.get_free_capacity(entry)
    return Housing.get_capacity(entry) - entry.inhabitants
end

function Housing.allowes_caste(house, caste_id)
    local caste = Caste(caste_id)
    return (house.comfort >= caste.minimum_comfort) and (house.room_count >= caste.required_room_count)
end

local meta = {}

function meta:__call(entry)
    return Housing.houses[entry.entity.name]
end

setmetatable(Housing, meta)
