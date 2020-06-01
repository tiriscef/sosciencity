require("constants.enums")

--- Things that people live in.
Housing = {}

Housing.values = {
    ["test-house"] = {
        room_count = 200,
        comfort = 10,
        caste = Type.clockwork, -- caste which likes this kind of housing
        caste_bonus = 2
    },
    ["improvised-hut"] = {
        room_count = 4,
        comfort = 0,
        caste = Type.clockwork,
        caste_bonus = 2
    }
}
local houses = Housing.values

function Housing.get(entry)
    return houses[entry[EK.name]]
end
local get_housing = Housing.get

function Housing.get_capacity(entry)
    return math.floor(get_housing(entry).room_count / Castes.values[entry[EK.type]].required_room_count)
end
local get_capacity = Housing.get_capacity

function Housing.get_free_capacity(entry)
    return get_capacity(entry) - entry[EK.inhabitants]
end

function Housing.allowes_caste(house, caste_id)
    local caste = Castes(caste_id)
    return (house.comfort >= caste.minimum_comfort) and (house.room_count >= caste.required_room_count)
end

--- Evaluates the effect of the housing on its inhabitants.
--- @param entry Entry
function Housing.evaluate(entry, happiness_summands, sanity_summands)
    local housing = get_housing(entry)
    happiness_summands[HappinessSummand.housing] = housing.comfort
    sanity_summands[SanitySummand.housing] = housing.comfort

    happiness_summands[HappinessSummand.suitable_housing] = (entry[EK.type] == housing.caste) and housing.caste_bonus or 0
end
