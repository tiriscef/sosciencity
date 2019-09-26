--[[
    Just some general helper functions for tables.
]]
function get_keyset(tbl)
    local ret = {}
    local index = 1
    for key, _ in pairs(tbl) do
        tbl[index] = key
        index = index + 1
    end
    return ret
end

--https://gist.github.com/Uradamus/10323382
function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end