local ConnectionType = require("enums.connection-type")
local EK = require("enums.entry-key")

--- Static class that takes care of the relations between entities.
Neighborhood = {}

-- Some entities need to know if there are neighborhood entities (like hospitals) nearby.
-- This class ensures that the neighborhood aware entries have a neighborhood-table with all the neighbors that it is interested in
-- When accessing a neighbor entry it is necessary to check if it's still valid
-- neighborhood: table
--   [entity type]: table of (unit_number, type) pairs
--
-- Future: implement something for entities that are not registered, e.g. trees
--[[
    Data this class stores in storage
    --------------------------------
    storage.subscriptions: table
        [type]: table with (unit_number, ConnectionType)-pairs
]]
-- local often used globals for giant performance gains

local Register = Register
local try_get = Register.try_get
local get_type_definition = require("constants.types").get
local get_building_details = require("constants.buildings").get
local distance = Tirislib.Utils.maximum_metric_distance
local get_subtbl = Tirislib.Tables.get_subtbl
local subscriptions

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    subscriptions = storage.subscriptions
end

function Neighborhood.load()
    set_locals()
end

function Neighborhood.init()
    storage.subscriptions = {}
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << general >>

local function is_in_range(neighbor, entry, range)
    if range == "global" then
        return true
    end

    local neighbor_entity = neighbor[EK.entity]
    local position = neighbor_entity.position
    local x = position.x
    local y = position.y

    -- check all 4 corners of the entry if they are in range
    local bounding_box = entry[EK.entity].selection_box
    local position1 = bounding_box.left_top
    local x1 = position1.x
    local y1 = position1.y
    local position2 = bounding_box.right_bottom
    local x2 = position2.x
    local y2 = position2.y

    return (distance(x, y, x1, y1) < range) or (distance(x, y, x1, y2) < range) or (distance(x, y, x2, y1) < range) or
        (distance(x, y, x2, y2) < range)
end

local function connect_bidirectional(entry, neighbor)
    local building_details = get_building_details(entry)
    local range = building_details.range
    if range and is_in_range(entry, neighbor, range) then
        return true
    end

    building_details = get_building_details(neighbor)
    range = building_details.range
    if range and is_in_range(neighbor, entry, range) then
        return true
    end

    return false
end

local function connect_from_neighbor(entry, neighbor)
    local building_details = get_building_details(neighbor)
    local range = building_details.range
    if range and is_in_range(neighbor, entry, range) then
        return true
    end

    return false
end

local function connect_to_neighbor(entry, neighbor)
    local building_details = get_building_details(entry)
    local range = building_details.range
    if range and is_in_range(entry, neighbor, range) then
        return true
    end

    return false
end

local connect_lookup = {
    [ConnectionType.bidirectional] = connect_bidirectional,
    [ConnectionType.to_neighbor] = connect_to_neighbor,
    [ConnectionType.from_neighbor] = connect_from_neighbor
}

local function can_connect(entry, neighbor, connection_type)
    -- first check if they are on the same surface
    local surface1 = entry[EK.entity].surface.index
    local surface2 = neighbor[EK.entity].surface.index
    if surface1 ~= surface2 then
        return false
    end

    -- call the ConnectionType-specific function
    return connect_lookup[connection_type](entry, neighbor)
end

local function try_connect(entry, neighbor, connection_type)
    if entry ~= neighbor and can_connect(entry, neighbor, connection_type) then
        local entity_type = neighbor[EK.type]
        local neighbors_table = get_subtbl(entry, EK.neighbors)
        local neighbors_of_type = get_subtbl(neighbors_table, entity_type)

        neighbors_of_type[neighbor[EK.unit_number]] = entity_type
    end
end

function Neighborhood.subscribe_to(entry, neighbor_type, connection_type)
    local unit_number = entry[EK.unit_number]
    connection_type = connection_type or ConnectionType.bidirectional

    -- note subscription
    get_subtbl(subscriptions, neighbor_type)[unit_number] = connection_type

    -- find all the neighbors already existing
    for _, possible_neighbor in Register.all_of_type(neighbor_type) do
        try_connect(entry, possible_neighbor, connection_type)
    end
end
local subscribe_to = Neighborhood.subscribe_to

--- Unsubscribes the given entry from the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.unsubscribe_to(entry, _type)
    -- delete neighbors
    entry[EK.neighbors][_type] = nil

    -- delete subscriptions
    local unit_number = entry[EK.unit_number]
    subscriptions[_type][unit_number] = nil
end

--- Removes all the subscriptions of this entry. Must be called when an entry gets deconstructed.
--- @param entry Entry
function Neighborhood.unsubscribe_all(entry)
    local unit_number = entry[EK.unit_number]

    -- delete subscriptions
    for _, subscribers in pairs(subscriptions) do
        subscribers[unit_number] = nil
    end

    -- delete neighbors
    entry[EK.neighbors] = {}
end

--- Adds the given entry to all the entries that are in range and subscribe to the type.
--- @param new_neighbor Entry
local function notify_subscribers(new_neighbor)
    local _type = new_neighbor[EK.type]
    local subscribers = subscriptions[_type]
    if not subscribers then
        return
    end

    for unit_number, connection_type in pairs(subscribers) do
        local subscriber = try_get(unit_number)
        if subscriber then
            try_connect(subscriber, new_neighbor, connection_type)
        end
    end
end

--- Adds the given neighbor to every interested entity in range. Needs to be called when a new entity gets created.
--- @param entry Entry
function Neighborhood.establish_new_neighbor(entry)
    -- Subscribe to the neighbors this entry type needs
    local type_subscriptions = get_type_definition(entry).subscriptions
    if type_subscriptions then
        for _type, connection_type in pairs(type_subscriptions) do
            subscribe_to(entry, _type, connection_type)
        end
    end

    -- Subscribe to the neighbors this custom building needs
    local building_details = get_building_details(entry)
    local workforce = building_details.workforce
    if workforce then
        for _, caste in pairs(workforce.castes) do
            if not type_subscriptions or not type_subscriptions[caste] then
                subscribe_to(entry, caste, ConnectionType.from_neighbor)
            end
        end
    end

    notify_subscribers(entry)
end

---------------------------------------------------------------------------------------------------
-- << interface functions >>

--- Returns a complete list of all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.get_by_type(entry, _type)
    if not entry[EK.neighbors] or not entry[EK.neighbors][_type] then
        return {}
    end

    local neighbor_table = entry[EK.neighbors][_type]
    local ret = {}
    local i = 1

    for unit_number in pairs(neighbor_table) do
        local current_entry = try_get(unit_number)
        if current_entry and current_entry[EK.type] == _type then
            ret[i] = current_entry
            i = i + 1
        else
            neighbor_table[unit_number] = nil
        end
    end

    return ret
end

local function nothing()
end

local function all_of_type_iterator(neighbor_table, key)
    local supposed_type
    key, supposed_type = next(neighbor_table, key)

    if key == nil then
        return nil, nil
    end

    local entry = try_get(key)
    if entry and entry[EK.type] == supposed_type then
        return key, entry
    else
        neighbor_table[key] = nil
        return all_of_type_iterator(neighbor_table, key)
    end
end

--- Lazy iterator over all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.all_of_type(entry, _type)
    if not entry[EK.neighbors] or not entry[EK.neighbors][_type] then
        return nothing
    end

    return all_of_type_iterator, entry[EK.neighbors][_type]
end

-- Thanks to justarandomgeek for this piece of code.
local function all_neighbors_iterator(all_neighbors, key)
    -- get the current neighbor table
    local neighbor_type
    local neighbor_table
    if key ~= nil then
        neighbor_type = key[1]
        neighbor_table = all_neighbors[neighbor_type]
    else
        key = {}
        neighbor_type, neighbor_table = next(all_neighbors)
        if neighbor_type == nil then
            return nil, nil
        end
        key[1] = neighbor_type
    end

    -- get the current neighbor
    local unit_number = next(neighbor_table, key[2])
    while unit_number == nil do
        neighbor_type, neighbor_table = next(all_neighbors, neighbor_type)
        if neighbor_type == nil then
            return nil, nil
        end
        key[1] = neighbor_type
        unit_number = next(neighbor_table)
    end
    key[2] = unit_number

    local entry = try_get(unit_number)
    if entry and entry[EK.type] == neighbor_type then
        return key, entry
    else
        neighbor_table[unit_number] = nil
        return all_neighbors_iterator(all_neighbors, key)
    end
end

--- Lazy iterator over all neighbors.
--- @param entry Entry
function Neighborhood.all(entry)
    if not entry[EK.neighbors] then
        return nothing
    end

    return all_neighbors_iterator, entry[EK.neighbors]
end

--- Counts the neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.get_neighbor_count(entry, _type)
    if not entry[EK.neighbors] or not entry[EK.neighbors][_type] then
        return 0
    end

    local neighbors = entry[EK.neighbors][_type]
    local count = 0

    for unit_number in pairs(neighbors) do
        local neighbor_entry = try_get(unit_number)

        if neighbor_entry and neighbor_entry[EK.type] == _type then
            count = count + 1
        else
            neighbors[unit_number] = nil
        end
    end

    return count
end

return Neighborhood
