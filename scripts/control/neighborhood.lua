Neighborhood = {}

---------------------------------------------------------------------------------------------------
-- << constants >>
--- Table with (neighborhood entity, range) pairs
Neighborhood.active_neighbors = {
    ["bsp"] = 42 -- range in tiles
}
local active_neighbor_ranges = Neighborhood.active_neighbors

--- Table with (entity type, neighborhood specification) pairs
Neighborhood.entity_types_aware_of_neighborhood = {
    [TYPE_CLOCKWORK] = {active_types = {TYPE_HOSPITAL, TYPE_MARKET}}
}
local entity_types_aware_of_neighborhood = Neighborhood.entity_types_aware_of_neighborhood

-- generate (neighbor, interested entity types) lookup table
local function generate_interested_entity_types_lookup()
    local interested_entity_types = {}
    for entity_type, interests in pairs(entity_types_aware_of_neighborhood) do
        for _, neighbor_type in pairs(interests) do
            if not interested_entity_types[neighbor_type] then
                interested_entity_types[neighbor_type] = {}
            end
            table.insert(interested_entity_types[neighbor_type], entity_type)
        end
    end
end
local interested_entity_types = generate_interested_entity_types_lookup()

---------------------------------------------------------------------------------------------------
-- << general >>
-- Some entities need to know if there are neighborhood entities (like hospitals) nearby.
-- This class ensures that the neighborhood aware entries have a neighborhood-table with all the neighbors that it is interested in
-- When accessing a neighbor entry it is necessary to check if it's still valid
--[[
    neighborhood: table
        [entity type]: table of (unit_number, entity) pairs
]]
-- Future: implement something for entities that are not registered, e.g. trees

local function maximum_metric_distance(v1, v2)
    return math.max(math.abs(v1.x - v2.x), math.abs(v1.y - v2.y))
end

local function is_in_range(neighborhood_entry, entry)
    local range = active_neighbor_ranges[neighborhood_entry.entity.name]
    local position1 = neighborhood_entry.entity.position
    local position2 = entry.entity.position
    return maximum_metric_distance(position1, position2) <= range
end

--- Finds and adds all the neighbor entries the given entity is interested in.
--- @param entry Entry
--- @param _type Type
function Neighborhood.add_neighborhood(entry, _type)
    local details = entity_types_aware_of_neighborhood[_type]
    if not details then
        return
    end

    entry.neighborhood = {}

    for _, neighborhood_type in pairs(details.active_types) do
        entry.neighborhood[neighborhood_type] = {}

        for unit_number, neighbor_entry in Register.all_of_type(neighborhood_type) do
            if is_in_range(neighbor_entry, entry) then
                entry.neighborhood[neighborhood_type][unit_number] = neighbor_entry
            end
        end
    end
end

--- Adds the given neighbor to every interested entity in range.
--- @param neighbor_entry Entry
--- @param _type Type
function Neighborhood.establish_new_neighbor(neighbor_entry, _type)
    local range = active_neighbor_ranges[neighbor_entry.entity.name]
    if not range then
        return
    end

    local unit_number = neighbor_entry.entity.unit_number

    for _, interested_type in pairs(interested_entity_types[_type]) do
        for _, current_entry in Register.all_of_type(interested_type) do
            if is_in_range(neighbor_entry, current_entry) then
                if not current_entry.neighborhood[_type] then
                    current_entry.neighborhood[_type] = {}
                end
                current_entry.neighborhood[_type][unit_number] = neighbor_entry
            end
        end
    end
end

--- Returns a complete list of all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.get_by_type(entry, _type)
    if not entry.neighborhood or not entry.neighborhood[_type] then
        return {}
    end

    local ret = {}

    for unit_number, current_entry in pairs(entry.neighborhood[_type]) do
        if not current_entry.entity.valid then
            current_entry.neighborhood[unit_number] = nil
        else
            table.insert(ret, current_entry.entity)
        end
    end

    return ret
end

--- Lazy iterator over all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.all_of_type(entry, _type)
    if not entry.neighborhood or not entry.neighborhood[_type] then
        return function() end
    end

    local index, current_entry
    local table_to_iterate = entry.neighborhood[_type]

    local function _next()
        index, current_entry = next(table_to_iterate, index)

        if not current_entry.entity.valid then
            table_to_iterate[index] = nil
            -- skip this invalid entry
            return _next()
        end

        if index then
            return index, current_entry
        end
    end

    return _next, index, current_entry
end

return Neighborhood
