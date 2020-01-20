require("constants.types")

Housing = {}

Housing.houses = {
    ["test-house"] = {
        room_count = 200,
        tech_level = 0,
        comfort = 5,
        caste = TYPE_CLOCKWORK, -- caste which likes this kind of housing
        caste_bonus = 2
    }
}
local houses = Housing.houses

function Housing.get(entry)
    return houses[entry[ENTITY].name]
end
local get_housing = Housing.get

function Housing.get_capacity(entry)
    return math.floor(get_housing(entry).room_count / Caste.values[entry[TYPE]].required_room_count)
end
local get_capacity = Housing.get_capacity

function Housing.get_free_capacity(entry)
    return get_capacity(entry) - entry[INHABITANTS]
end

function Housing.allowes_caste(house, caste_id)
    local caste = Caste(caste_id)
    return (house.comfort >= caste.minimum_comfort) and (house.room_count >= caste.required_room_count)
end

--- Evaluates the effect of the housing on its inhabitants.
--- @param entry Entry
function Housing.evaluate(entry, happiness_summands, sanity_summands)
    local housing = get_housing(entry)
    happiness_summands[HAPPINESS_HOUSING] = housing.comfort
    sanity_summands[SANITY_HOUSING] = housing.comfort

    happiness_summands[HAPPINESS_SUITABLE_HOUSING] = (entry[TYPE] == housing.caste) and housing.caste_bonus or 0
end
