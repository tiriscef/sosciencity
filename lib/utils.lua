--<< Just some helper functions >>
Tirislib_Utils = {}

function Tirislib_Utils.weighted_average(a, weight_a, b, weight_b)
    return (a * weight_a + b * weight_b) / (weight_a + weight_b)
end

function Tirislib_Utils.sgn(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

--<< Just some table helper functions >>
Tirislib_Tables = {}

function Tirislib_Tables.get_keyset(tbl)
    local ret = {}
    local index = 1

    for key, _ in pairs(tbl) do
        ret[index] = key
        index = index + 1
    end

    return ret
end

--https://gist.github.com/Uradamus/10323382
function Tirislib_Tables.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

-- clones the table, tables inside will be referenced
function Tirislib_Tables.copy(tbl)
    local ret = {}

    for key, value in pairs(tbl) do
        ret[key] = value
    end

    return ret
end

-- clones the table and all tables inside
-- assumes that there are no circular structures
function Tirislib_Tables.recursive_copy(tbl)
    local ret = {}

    for key, value in pairs(tbl) do
        if type(value) == "table" then
            ret[key] = Tirislib_Tables.recursive_copy(value)
        else
            ret[key] = value
        end
    end

    return ret
end

function Tirislib_Tables.contains(tbl, element)
    for _, value in pairs(tbl) do
        if element == value then
            return true
        end
    end

    return false
end

function Tirislib_Tables.contains_key(tbl, key)
    return tbl[key] ~= nil
end

function Tirislib_Tables.merge(lh, rh)
    for _, value in pairs(rh) do
        table.insert(lh, value)
    end

    return lh
end

function Tirislib_Tables.set_fields(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            tbl[key] = value
        end
    end

    return tbl
end

function Tirislib_Tables.sum(tbl)
    local ret = 0.

    for _, value in pairs(tbl) do
        ret = ret + value
    end

    return ret
end
