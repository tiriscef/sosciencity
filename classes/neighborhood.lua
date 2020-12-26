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
    Data this class stores in global
    --------------------------------
    global.subscriptions: table
        [type]: unit_number-lookup table
]]
-- local often used globals for giant performance gains
local Register = Register
local try_get = Register.try_get
local get_type = Types.get
local get_building_details = Buildings.get
local distance = Tirislib_Utils.maximum_metric_distance
local subscriptions

local function set_locals()
    subscriptions = global.subscriptions
end

function Neighborhood.load()
    set_locals()
end

function Neighborhood.init()
    global.subscriptions = {}
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

local function can_connect(entry1, entry2)
    -- first check if they are on the same surface
    local surface1 = entry1[EK.entity].surface.index
    local surface2 = entry2[EK.entity].surface.index
    if surface1 ~= surface2 then
        return false
    end

    -- check if one of the entries can reach the other
    local range = get_building_details(entry1).range
    if range and is_in_range(entry1, entry2, range) then
        return true
    end

    range = get_building_details(entry2).range
    if range and is_in_range(entry2, entry1, range) then
        return true
    end

    return false
end

function Neighborhood.subscribe_to(entry, _type)
    local unit_number = entry[EK.unit_number]

    -- note subscription
    if not subscriptions[_type] then
        subscriptions[_type] = {}
    end
    subscriptions[_type][unit_number] = true

    -- get the neighbors table (and initialise it when needed)
    entry[EK.neighbors] = entry[EK.neighbors] or {}
    local neighbors = entry[EK.neighbors]
    neighbors[_type] = neighbors[_type] or {}
    local neighbors_of_this_type = neighbors[_type]

    -- find all the entries of the given type
    for _, possible_neighbor in Register.all_of_type(_type) do
        if can_connect(entry, possible_neighbor) then
            neighbors_of_this_type[possible_neighbor[EK.unit_number]] = _type
        end
    end
end
local subscribe_to = Neighborhood.subscribe_to

local function subscribe_to_range(entry, types)
    for _, _type in pairs(types) do
        subscribe_to(entry, _type)
    end
end

--- Unsubscribes the given entry from the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.unsubscribe_to(entry, _type)
    local neighbors = entry[EK.neighbors]
    local unit_number = entry[EK.unit_number]

    -- delete neighbors
    neighbors[_type] = nil

    -- delete subscriptions
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
--- @param entry Entry
local function notify_subscribers(entry)
    local _type = entry[EK.type]
    local subscribers = subscriptions[_type]
    if not subscribers then
        return
    end

    local unit_number = entry[EK.unit_number]

    for subscriber_number in pairs(subscribers) do
        local subscriber = try_get(subscriber_number)
        if subscriber then
            subscriber[EK.neighbors][_type][unit_number] = _type
        end
    end
end

--- Adds the given neighbor to every interested entity in range.
--- @param entry Entry
function Neighborhood.establish_new_neighbor(entry)
    -- Subscribe to the neighbors this entry type needs
    local type_subscriptions = get_type(entry).subscriptions

    if type_subscriptions then
        subscribe_to_range(entry, type_subscriptions)
    end

    -- Subscribe to the neighbors this custom building needs
    local building_details = get_building_details(entry)
    if building_details then
        local workforce = building_details.workforce
        if workforce then
            subscribe_to_range(entry, workforce.castes)
        end
    end

    notify_subscribers(entry)
end

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

    for unit_number, _ in pairs(neighbor_table) do
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
