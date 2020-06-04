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
        caste_bonus = 2,
        alternatives = {"improvised-hut-2"}
    }
}
local houses = Housing.values

Housing.next = {}

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

-- values postprocessing
do
    local to_add = {}

    for house_name, house in pairs(houses) do
        if house.alternatives then
            local alternatives = house.alternatives
            for i = 1, #alternatives do
                to_add[house.alternatives[i]] = house
                Housing.next[house.alternatives[i]] = house.alternatives[i + 1] or house_name
            end

            Housing.next[house_name] = house.alternatives[1]
            table.insert(house.alternatives, house_name)

            house.alternatives = Tirislib_Tables.array_to_lookup(house.alternatives)
        end
    end

    Tirislib_Tables.set_fields(houses, to_add)
end
