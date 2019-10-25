--<< Just some helper functions >>
Utils = {}

function Utils.weighted_average(a, weight_a, b, weight_b)
    return (a * weight_a + b * weight_b) / (weight_a + weight_b)
end

--<< Just some table helper functions >>
Tables = {}

function Tables.get_keyset(tbl)
    local ret = {}
    local index = 1

    for key, _ in pairs(tbl) do
        tbl[index] = key
        index = index + 1
    end

    return ret
end

--https://gist.github.com/Uradamus/10323382
function Tables.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

-- clones the table, tables inside will be referenced
function Tables.copy(tbl)
    local ret = {}

    for key, value in pairs(tbl) do
        ret[key] = value
    end

    return ret
end

-- clones the table and all tables inside
-- assumes that there are no circular structures
function Tables.recursive_copy(tbl)
    local ret = {}

    for key, value in pairs(tbl) do
        if type(value) == "table" then
            ret[key] = Tables.recursive_copy(value)
        else
            ret[key] = value
        end
    end

    return ret
end

function Tables.contains(tbl, element)
    for _, value in pairs(tbl) do
        if element == value then
            return true
        end
    end

    return false
end

function Tables.contains_key(tbl, key)
    return tbl[key] ~= nil
end