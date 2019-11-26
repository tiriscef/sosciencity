Neighborhood = {}

function Neighborhood.add_neighborhood_data(entry, type)
    -- TODO
end

function Neighborhood.get_by_type(entry, type)
    if not entry.neighborhood or not entry.neighborhood[type] then
        return {}
    end

    local ret = {}

    for unit_number, entity in pairs(entry.neighborhood[type]) do
        if not entity.valid then
            entry.neighborhood[unit_number] = nil
        else
            table.insert(ret, entity)
        end
    end

    return ret
end

return Neighborhood
