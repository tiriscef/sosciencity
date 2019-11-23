Neighborhood = {}

function Neighborhood:add_neighborhood_data(registered_entity, type)
    -- TODO
end

function Neighborhood:get_by_type(registered_entity, type)
    if not registered_entity.neighborhood or not registered_entity.neighborhood[type] then
        return {}
    end

    local ret = {}

    for unit_number, entity in pairs(registered_entity.neighborhood[type]) do
        if not entity.valid then
            registered_entity.neighborhood[unit_number] = nil
        else
            table.insert(ret, entity)
        end
    end

    return ret
end
