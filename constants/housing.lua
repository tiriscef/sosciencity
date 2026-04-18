local EK = require("enums.entry-key")

local Castes = require("constants.castes")

--- @class HouseDefinition

--- Things that people live in.
local Housing = {}

-- Per-level cost per room to upgrade from (level-1) to level.
-- Multiply by room_count and ceil to get actual item amounts.
Housing.furniture_costs = {
    [1]  = {
        {name = "furniture", amount = 0.5}
    },
    [2]  = {
        {name = "furniture", amount = 1}
    },
    [3]  = {
        {name = "bed",       amount = 1},
        {name = "furniture", amount = 1.5}
    },
    [4]  = {
        {name = "furniture", amount = 1}
    },
    [5]  = {
        {name = "curtain", amount = 1},
        {name = "stove",   amount = 0.5}
    },
    [6]  = {
        {name = "furniture",       amount = 1},
        {name = "carpet",          amount = 1},
        {name = "air-conditioner", amount = 1 / 3}
    },
    [7]  = {
        {name = "refrigerator", amount = 0.5}
    },
    [8]  = {
        {name = "furniture",       amount = 1},
        {name = "air-conditioner", amount = 1 / 6}
    },
    [9]  = {
        {name = "furniture",       amount = 1},
        {name = "air-conditioner", amount = 1 / 6}
    },
    [10] = {
        {name = "bed",             amount = 2},
        {name = "furniture",       amount = 1},
        {name = "air-conditioner", amount = 1 / 3}
    },
}

-- Maps comfort level → required architecture technology name.
Housing.required_tech = {
    [1]  = "architecture-1",
    [2]  = "architecture-1",
    [3]  = "architecture-2",
    [4]  = "architecture-2",
    [5]  = "architecture-3",
    [6]  = "architecture-3",
    [7]  = "architecture-4",
    [8]  = "architecture-5",
    [9]  = "architecture-6",
    [10] = "architecture-7",
}

-- Highest comfort level defined by furniture_costs.
Housing.max_level = Tirislib.LazyLuaq.from_keyset(Housing.required_tech):max()

--- Returns true if the given comfort level is unlocked (uses cached research state from storage).
--- @param level integer
--- @return boolean
function Housing.is_level_unlocked(level)
    local tech = Housing.required_tech[level]
    return tech == nil or storage.technologies[tech]
end

--- Returns the highest comfort level currently unlocked.
--- @return integer
function Housing.get_max_unlocked_level()
    for level = Housing.max_level, 1, -1 do
        if Housing.is_level_unlocked(level) then
            return level
        end
    end
    return 0
end

Housing.values = {
    ["improvised-hut"] = {
        room_count = 4,
        comfort = 0,
        starting_comfort = 0,
        max_comfort = 1,
        is_improvised = true,
        one_room_per_inhabitant = true,
        qualities = {"cheap", "individualistic", "low"},
        alternatives = {"improvised-hut-2"}
    },
    --[[["improvised-hut-2"] = {
        room_count = 4,
        comfort = 0,
        starting_comfort = 0,
        max_comfort = 3,
        is_improvised = true,
        one_room_per_inhabitant = true,
        qualities = {"cheap", "individualistic", "low"}
    },]]
    --[[["boring-brick-house"] = {
        room_count = 32,
        comfort = 5,
        starting_comfort = 0,
        max_comfort = 8,
        qualities = {"cheap", "simple", "copy-paste"}
    },]]
    ["khrushchyovka"] = {
        room_count = 40,
        comfort = 4,
        starting_comfort = 0,
        max_comfort = 6,
        qualities = {"compact", "simple", "copy-paste", "cheap", "tall"}
    },
    ["sheltered-house"] = {
        room_count = 48,
        comfort = 6,
        starting_comfort = 0,
        max_comfort = 7,
        qualities = {"sheltered", "compact", "simple", "low"}
    },
    ["small-prefabricated-house"] = {
        room_count = 25,
        comfort = 5,
        starting_comfort = 0,
        max_comfort = 8,
        qualities = {"compact", "simple", "copy-paste", "cheap"}
    },
    ["bunkerhouse"] = {
        room_count = 24,
        comfort = 4,
        starting_comfort = 0,
        max_comfort = 7,
        qualities = {"sheltered", "compact", "simple", "low"}
    },
    ["huwanic-mansion"] = {
        room_count = 50,
        comfort = 8,
        starting_comfort = 0,
        max_comfort = 10,
        qualities = {"spacey", "decorated", "individualistic", "pompous", "tall"}
    },
    ["house5"] = {
        room_count = 180,
        comfort = 8,
        starting_comfort = 0,
        max_comfort = 10,
        qualities = {"spacey", "individualistic", "tall"}
    },
    ["house1"] = {
        room_count = 12,
        comfort = 3,
        starting_comfort = 0,
        max_comfort = 6,
        qualities = {"spacey", "technical", "individualistic", "tall"}
    },
    ["big-living-container"] = {
        room_count = 24,
        comfort = 1,
        starting_comfort = 0,
        max_comfort = 4,
        qualities = {"compact", "simple", "cheap"}
    },
    ["living-container"] = {
        room_count = 6,
        comfort = 0,
        starting_comfort = 0,
        max_comfort = 3,
        qualities = {"compact", "simple", "cheap", "low", "copy-paste"}
    },
    ["barrack-container"] = {
        room_count = 40,
        comfort = 3,
        starting_comfort = 0,
        max_comfort = 6,
        qualities = {"compact", "simple", "copy-paste"}
    },
    ["balcony-house"] = {
        room_count = 24,
        comfort = 7,
        starting_comfort = 0,
        max_comfort = 10,
        qualities = {"spacey", "low", "individualistic"}
    },
    ["octopus-complex"] = {
        room_count = 210,
        comfort = 9,
        starting_comfort = 0,
        max_comfort = 10,
        qualities = {"low", "technical", "compact"}
    },
    ["spring-house"] = {
        room_count = 15,
        comfort = 3,
        starting_comfort = 0,
        max_comfort = 6,
        qualities = {"low", "green"}
    },
    ["summer-house"] = {
        room_count = 30,
        comfort = 5,
        starting_comfort = 0,
        max_comfort = 8,
        qualities = {"low", "green", "spacey"}
    },
    ["barrack"] = {
        room_count = 40,
        comfort = 4,
        starting_comfort = 0,
        max_comfort = 6,
        qualities = {"copy-paste", "cheap", "compact", "simple", "low"}
    },
    ["test-house"] = {
        room_count = 200,
        comfort = 10,
        starting_comfort = 0,
        max_comfort = 10,
        qualities = {}
    },
    ["test-house-2"] = {
        room_count = 10,
        comfort = 0,
        starting_comfort = 0,
        max_comfort = 3,
        qualities = {"compact", "simple", "cheap", "copy-paste"}
    },
    ["test-house-3"] = {
        room_count = 20,
        comfort = 3,
        starting_comfort = 0,
        max_comfort = 6,
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
    return house.room_count >= caste.required_room_count
end

--- Returns the items required to upgrade this house from (level-1) to level,
--- with amounts scaled by room_count and ceiling'd to integers.
--- Returns nil if level is 0 or above max_comfort.
--- @param house HouseDefinition
--- @param level integer target comfort level
--- @return table? array of {name, count} pairs
function Housing.get_upgrade_cost(house, level)
    local per_room = Housing.furniture_costs[level]
    if not per_room then
        return nil
    end
    local room_count = house.room_count
    local result = {}
    for _, entry in pairs(per_room) do
        result[#result + 1] = {name = entry.name, count = math.ceil(entry.amount * room_count)}
    end
    return result
end

--- Returns the total items that were spent to reach current_comfort (for refund on deconstruct).
--- @param house HouseDefinition
--- @param current_comfort integer
--- @return table array of {name, count} pairs, merged across all levels
function Housing.get_total_refund(house, current_comfort)
    local totals = {}
    for level = 1, current_comfort do
        local cost = Housing.get_upgrade_cost(house, level)
        if cost then
            for _, item in pairs(cost) do
                totals[item.name] = (totals[item.name] or 0) + item.count
            end
        end
    end
    local result = {}
    for name, count in pairs(totals) do
        result[#result + 1] = {name = name, count = count}
    end
    return result
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
