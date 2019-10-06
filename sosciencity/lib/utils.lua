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
