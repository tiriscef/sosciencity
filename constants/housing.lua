require("constants.enums")
require("constants.castes")

--- Things that people live in.
Housing = {}

Housing.values = {
    ["test-house"] = {
        room_count = 200,
        comfort = 10,
        qualities = {}
    },
    ["improvised-hut"] = {
        room_count = 4,
        comfort = 0,
        is_improvised = true,
        one_room_per_inhabitant = true,
        qualities = {"cheap", "individualistic"}
    },
    ["improvised-hut-2"] = {
        room_count = 4,
        comfort = 0,
        is_improvised = true,
        one_room_per_inhabitant = true,
        qualities = {"cheap", "individualistic"}
    },
    ["boring-brick-house"] = {
        room_count = 32,
        comfort = 5,
        qualities = {"cheap"}
    },
    ["khrushchyovka"] = {
        room_count = 25,
        comfort = 4,
        qualities = {"compact", "simple", "copy-paste", "cheap", "tall"}
    },
    ["sheltered-house"] = {
        room_count = 25,
        comfort = 4,
        qualities = {"sheltered", "compact", "simple", "low"}
    },
    ["small-prefabricated-house"] = {
        room_count = 25,
        comfort = 5,
        qualities = {"compact", "simple", "copy-paste", "cheap"}
    },
    ["bunkerhouse"] = {
        room_count = 25,
        comfort = 5,
        qualities = {"sheltered", "compact", "simple", "low"}
    },
    ["huwanic-mansion"] = {
        room_count = 25,
        comfort = 5,
        qualities = {"spacey", "decorated", "individualistic", "pompous", "tall"}
    }
}
local houses = Housing.values

Housing.next = {}

function Housing.get(entry)
    return houses[entry[EK.name]]
end
local get_housing = Housing.get

function Housing.get_capacity(entry)
    local housing_details = get_housing(entry)
    local room_count = housing_details.room_count

    if housing_details.one_room_per_inhabitant then
        return room_count
    else
        return math.floor(room_count / Castes.values[entry[EK.type]].required_room_count)
    end
end
local get_capacity = Housing.get_capacity

function Housing.get_free_capacity(entry)
    return get_capacity(entry) - entry[EK.inhabitants]
end

local castes = Castes.values
function Housing.allowes_caste(house, caste_id)
    local caste = castes[caste_id]
    return (house.comfort >= caste.minimum_comfort) and (house.room_count >= caste.required_room_count)
end

-- values postprocessing
do
    local to_add = {}

    for house_name, house in pairs(houses) do
        house.main_entity = house_name
        local alternatives = house.alternatives
        if alternatives then
            for i = 1, #alternatives do
                to_add[alternatives[i]] = house
                Housing.next[alternatives[i]] = alternatives[i + 1] or house_name
            end

            Housing.next[house_name] = alternatives[1]
            table.insert(alternatives, house_name)

            alternatives = Tirislib_Tables.array_to_lookup(house.alternatives)
        end

        table.sort(house.qualities)

        house.is_improvised = house.is_improvised or false
    end

    Tirislib_Tables.set_fields(houses, to_add)
end
