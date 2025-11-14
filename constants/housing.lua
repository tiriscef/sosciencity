local EK = require("enums.entry-key")

local Castes = require("constants.castes")

--- @class HouseDefinition

--- Things that people live in.
local Housing = {}

Housing.values = {
    ["improvised-hut"] = {
        room_count = 4,
        comfort = 0,
        is_improvised = true,
        one_room_per_inhabitant = true,
        qualities = {"cheap", "individualistic", "low"},
        alternatives = {"improvised-hut-2"}
    },
    --[[["improvised-hut-2"] = {
        room_count = 4,
        comfort = 0,
        is_improvised = true,
        one_room_per_inhabitant = true,
        qualities = {"cheap", "individualistic", "low"}
    },]]
    --[[["boring-brick-house"] = {
        room_count = 32,
        comfort = 5,
        qualities = {"cheap", "simple", "copy-paste"}
    },]]
    ["khrushchyovka"] = {
        room_count = 40,
        comfort = 4,
        qualities = {"compact", "simple", "copy-paste", "cheap", "tall"}
    },
    ["sheltered-house"] = {
        room_count = 48,
        comfort = 6,
        qualities = {"sheltered", "compact", "simple", "low"}
    },
    ["small-prefabricated-house"] = {
        room_count = 25,
        comfort = 5,
        qualities = {"compact", "simple", "copy-paste", "cheap"}
    },
    ["bunkerhouse"] = {
        room_count = 24,
        comfort = 4,
        qualities = {"sheltered", "compact", "simple", "low"}
    },
    ["huwanic-mansion"] = {
        room_count = 50,
        comfort = 8,
        qualities = {"spacey", "decorated", "individualistic", "pompous", "tall"}
    },
    ["house5"] = {
        room_count = 180,
        comfort = 8,
        qualities = {"spacey", "individualistic", "tall"}
    },
    ["house1"] = {
        room_count = 12,
        comfort = 3,
        qualities = {"spacey", "technical", "individualistic", "tall"}
    },
    ["big-living-container"] = {
        room_count = 24,
        comfort = 1,
        qualities = {"compact", "simple", "cheap"}
    },
    ["living-container"] = {
        room_count = 6,
        comfort = 0,
        qualities = {"compact", "simple", "cheap", "low", "copy-paste"}
    },
    ["barrack-container"] = {
        room_count = 40,
        comfort = 3,
        qualities = {"compact", "simple", "copy-paste"}
    },
    ["balcony-house"] = {
        room_count = 24,
        comfort = 7,
        qualities = {"spacey", "low", "individualistic"}
    },
    ["octopus-complex"] = {
        room_count = 210,
        comfort = 9,
        qualities = {"low", "technical", "compact"}
    },
    ["spring-house"] = {
        room_count = 15,
        comfort = 3,
        qualities = {"low", "green"}
    },
    ["summer-house"] = {
        room_count = 30,
        comfort = 5,
        qualities = {"low", "green", "spacey"}
    },
    ["barrack"] = {
        room_count = 40,
        comfort = 4,
        qualities = {"copy-paste", "cheap", "compact", "simple", "low"}
    },
    ["test-house"] = {
        room_count = 200,
        comfort = 10,
        qualities = {}
    }
}
local houses = Housing.values
local castes = Castes.values

--- Returns the HouseDefinition for this Entry.
--- @param entry Entry of a house
--- @return HouseDefinition
function Housing.get(entry)
    return houses[entry[EK.name]]
end
local get_housing = Housing.get

--- Returns the maximum capacity that this house can hold.
--- @param entry Entry of a house
--- @return integer
function Housing.get_capacity(entry)
    local housing_details = get_housing(entry)
    local room_count = housing_details.room_count

    if housing_details.one_room_per_inhabitant then
        return room_count
    else
        return math.floor(room_count / castes[entry[EK.type]].required_room_count)
    end
end
local get_capacity = Housing.get_capacity

--- Returns the count of people that can move into the house until it's full.
--- @param entry Entry of a house
--- @return integer
function Housing.get_free_capacity(entry)
    return get_capacity(entry) - entry[EK.inhabitants]
end

--- Checks if the house is suitable for the given caste.
--- @param house HouseDefinition
--- @param caste_id integer
--- @return boolean
function Housing.allowes_caste(house, caste_id)
    local caste = castes[caste_id]
    return (house.comfort >= caste.minimum_comfort) and (house.room_count >= caste.required_room_count)
end

-- values postprocessing
do
    local to_add = {}

    for _, house in pairs(houses) do
        if house.alternatives then
            for i = 1, #house.alternatives do
                to_add[house.alternatives[i]] = house
            end
        end

        table.sort(house.qualities)

        house.is_improvised = house.is_improvised or false
    end

    Tirislib.Tables.set_fields(houses, to_add)

    for name, house in pairs(houses) do
        house.name = name
    end

    Housing.huts =
        Tirislib.LazyLuaq.from(Housing.values):where(
        function(house)
            return house.is_improvised
        end
    ):to_array()
end

return Housing
