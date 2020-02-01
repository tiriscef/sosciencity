Neighborhood = {}

local Register = Register
local try_get = Register.try_get

local abs = math.abs
local max = math.max
---------------------------------------------------------------------------------------------------
-- << constants >>
--- Table with (neighborhood entity, range) pairs
local active_neighbor_ranges
local function generate_active_neighbor_ranges_lookup()
    active_neighbor_ranges = {}

    for name, details in pairs(Buildings) do
        active_neighbor_ranges[name] = details.range
    end
end

--- Table with (entity type, neighborhood specification) pairs
Neighborhood.entity_types_aware_of_neighborhood = {
    [TYPE_CLOCKWORK] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_ORCHID] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_GUNFIRE] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_EMBER] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_FOUNDRY] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_GLEAM] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_AURORA] = {active_types = {TYPE_MARKET, TYPE_WATER_DISTRIBUTER, TYPE_HOSPITAL, TYPE_DUMPSTER}},
    [TYPE_WATERWELL] = {active_types = {TYPE_WATERWELL}}
}
local entity_types_aware_of_neighborhood = Neighborhood.entity_types_aware_of_neighborhood

--- Table with (building, interested entity types) pairs
local interested_entity_types
local function generate_interested_entity_types_lookup()
    interested_entity_types = {}

    for entity_type, interests in pairs(entity_types_aware_of_neighborhood) do
        for _, neighbor_type in pairs(interests.active_types) do
            if not interested_entity_types[neighbor_type] then
                interested_entity_types[neighbor_type] = {}
            end
            table.insert(interested_entity_types[neighbor_type], entity_type)
        end
    end
end

function Neighborhood.init()
    generate_active_neighbor_ranges_lookup()
    generate_interested_entity_types_lookup()
end

---------------------------------------------------------------------------------------------------
-- << general >>
-- Some entities need to know if there are neighborhood entities (like hospitals) nearby.
-- This class ensures that the neighborhood aware entries have a neighborhood-table with all the neighbors that it is interested in
-- When accessing a neighbor entry it is necessary to check if it's still valid
-- neighborhood: table
--   [entity type]: table of (unit_number, type) pairs
--
-- Future: implement something for entities that are not registered, e.g. trees

local function maximum_metric_distance(x1, y1, x2, y2)
    local dist_x = abs(x1 - x2)
    local dist_y = abs(y1 - y2)

    return max(dist_x, dist_y)
end

local function is_in_range(neighborhood_entry, entry)
    local neighbor_entity = neighborhood_entry[ENTITY]
    local range = active_neighbor_ranges[neighbor_entity.name]
    local position = neighbor_entity.position
    local x = position.x
    local y = position.y

    -- check all 4 corners of the entry if they are in range
    local bounding_box = entry[ENTITY].selection_box
    local position1 = bounding_box.left_top
    local x1 = position1.x
    local y1 = position1.y
    local position2 = bounding_box.right_bottom
    local x2 = position2.x
    local y2 = position2.y

    return (maximum_metric_distance(x, y, x1, y1) < range) or (maximum_metric_distance(x, y, x1, y2) < range) or
        (maximum_metric_distance(x, y, x2, y1) < range) or
        (maximum_metric_distance(x, y, x2, y2) < range)
end

--- Finds and adds all the neighbor entries the given entity is interested in.
--- @param entry Entry
--- @param _type Type
function Neighborhood.add_neighborhood(entry, _type)
    local details = entity_types_aware_of_neighborhood[_type]
    if not details then
        return
    end

    entry[NEIGHBORHOOD] = {}
    local neighborhood_table = entry[NEIGHBORHOOD]

    for _, neighbor_type in pairs(details.active_types) do
        neighborhood_table[neighbor_type] = {}
        local type_table = neighborhood_table[neighbor_type]

        for unit_number, neighbor_entry in Register.all_of_type(neighbor_type) do
            if is_in_range(neighbor_entry, entry) then
                type_table[unit_number] = neighbor_type
            end
        end
    end
end

--- Adds the given neighbor to every interested entity in range.
--- @param neighbor_entry Entry
--- @param _type Type
function Neighborhood.establish_new_neighbor(neighbor_entry, _type)
    if not active_neighbor_ranges[neighbor_entry[ENTITY].name] then
        return
    end

    local unit_number = neighbor_entry[ENTITY].unit_number

    for _, interested_type in pairs(interested_entity_types[_type]) do
        for _, current_entry in Register.all_of_type(interested_type) do
            if is_in_range(neighbor_entry, current_entry) then
                if not current_entry[NEIGHBORHOOD][_type] then
                    current_entry[NEIGHBORHOOD][_type] = {}
                end
                current_entry[NEIGHBORHOOD][_type][unit_number] = _type
            end
        end
    end
end

--- Returns a complete list of all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.get_by_type(entry, _type)
    if not entry[NEIGHBORHOOD] or not entry[NEIGHBORHOOD][_type] then
        return {}
    end

    local neighbor_table = entry[NEIGHBORHOOD][_type]
    local ret = {}
    local i = 1

    for unit_number, _ in pairs(neighbor_table) do
        local current_entry = try_get(unit_number)
        if current_entry and current_entry[TYPE] == _type then
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
    if entry and entry[TYPE] == supposed_type then
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
    if not entry[NEIGHBORHOOD] or not entry[NEIGHBORHOOD][_type] then
        return nothing
    end

    return all_of_type_iterator, entry[NEIGHBORHOOD][_type]
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
    if entry and entry[TYPE] == neighbor_type then
        return key, entry
    else
        neighbor_table[unit_number] = nil
        return all_neighbors_iterator(all_neighbors, key)
    end
end

--- Lazy iterator over all neighbors.
--- @param entry Entry
function Neighborhood.all(entry)
    if not entry[NEIGHBORHOOD] then
        return nothing
    end

    return all_neighbors_iterator, entry[NEIGHBORHOOD]
end

function Neighborhood.get_neighbor_count(entry, _type)
    if not entry[NEIGHBORHOOD] or not entry[NEIGHBORHOOD][_type] then
        return 0
    end

    local neighbors = entry[NEIGHBORHOOD][_type]
    local count = 0

    for unit_number in pairs(neighbors) do
        local neighbor_entry = try_get(unit_number)

        if neighbor_entry and neighbor_entry[TYPE] == _type then
            count = count + 1
        else
            neighbors[unit_number] = nil
        end
    end

    return count
end

return Neighborhood
