Neighborhood = {}

function Neighborhood.add_neighborhood_data(entry, type)
    -- TODO
end

function Neighborhood.get_by_type(entry, _type)
    if not entry.neighborhood or not entry.neighborhood[_type] then
        return {}
    end

    local ret = {}

    for unit_number, entity in pairs(entry.neighborhood[_type]) do
        if not entity.valid then
            entry.neighborhood[unit_number] = nil
        else
            table.insert(ret, entity)
        end
    end

    return ret
end

return Neighborhood
