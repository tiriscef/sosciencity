local random = math.random
local select = select

---------------------------------------------------------------------------------------------------
--- Just some table helper functions
Tirislib.Tables = Tirislib.Tables or {}

--- Recursively checks if the contents of the given tables are equal.
--- @param lh table
--- @param rh table
--- @return boolean
function Tirislib.Tables.equal(lh, rh)
    if lh == rh then
        return true
    end

    if type(lh) ~= "table" or type(rh) ~= "table" then
        return false
    end

    for k, v in pairs(lh) do
        if type(v) == "table" then
            if not Tirislib.Tables.equal(v, rh[k]) then
                return false
            end
        else
            if v ~= rh[k] then
                return false
            end
        end
    end

    for k in pairs(rh) do
        if lh[k] == nil then
            return false
        end
    end

    return true
end

--- Checks if the contents of the given tables are equal. This method won't check nested tables.. for performance reasons.
--- @param lh table
--- @param rh table
--- @return boolean
function Tirislib.Tables.shallow_equal(lh, rh)
    for k, v in pairs(lh) do
        if v ~= rh[k] then
            return false
        end
    end

    for k in pairs(rh) do
        if lh[k] == nil then
            return false
        end
    end

    return true
end

--- Returns the number of elements in this table.
--- @param tbl table
--- @return integer
function Tirislib.Tables.count(tbl)
    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

--- Returns an array with all the keys of the given table.
--- @param tbl table
--- @return array
function Tirislib.Tables.get_keyset(tbl)
    local ret = {}
    local index = 1

    for key in pairs(tbl) do
        ret[index] = key
        index = index + 1
    end

    return ret
end
local get_keyset = Tirislib.Tables.get_keyset

--- Returns a table with the elements of the given array as keys.
--- @param tbl table
--- @return table
function Tirislib.Tables.to_lookup(tbl)
    local ret = {}

    for _, value in pairs(tbl) do
        ret[value] = true
    end

    return ret
end

--- Clones the table, nested tables will be referenced.
--- @param tbl table
--- @return table
function Tirislib.Tables.copy(tbl)
    local ret = {}

    for key, value in pairs(tbl) do
        ret[key] = value
    end

    return ret
end

local function recursive_copy(tbl, copied)
    local copy = copied[tbl]
    if copy then
        return copy
    end

    local ret = {}
    copied[tbl] = ret

    for key, value in pairs(tbl) do
        if type(value) == "table" then
            ret[key] = recursive_copy(value, copied)
        else
            ret[key] = value
        end
    end

    return ret
end

--- Clones the table and all tables inside.
--- @param tbl table
--- @return table
function Tirislib.Tables.recursive_copy(tbl)
    return recursive_copy(tbl, {})
end
local rec_copy = Tirislib.Tables.recursive_copy

--- Checks if a field of the given table contains the given value.
--- @param tbl table
--- @param element any
--- @return boolean
function Tirislib.Tables.contains(tbl, element)
    for _, value in pairs(tbl) do
        if element == value then
            return true
        end
    end

    return false
end

--- Checks if there is a field with the given key defined for the given table.
--- @param tbl table
--- @param key any
--- @return boolean
function Tirislib.Tables.contains_key(tbl, key)
    return tbl[key] ~= nil
end

--- Returns true if there is any field in the given table.
--- @param tbl table
--- @return boolean
function Tirislib.Tables.any(tbl)
    return next(tbl) ~= nil
end

--- Sets all fields of the given right hand table to the given left hand table.
--- @param tbl table
--- @param fields table
--- @return table
function Tirislib.Tables.set_fields(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            tbl[key] = value
        end
    end

    return tbl
end

--- Sets all fields of the given right hand table to the given left hand table, if they aren't already defined.
--- @param tbl table
--- @param fields table
--- @return table
function Tirislib.Tables.set_fields_passively(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            if tbl[key] == nil then
                tbl[key] = value
            end
        end
    end

    return tbl
end

--- Sets all fields of the given right hand table to the given left hand table. Nested tables will be cloned.
--- @param tbl table
--- @param fields table
--- @return table
function Tirislib.Tables.copy_fields(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            if type(value) == "table" then
                tbl[key] = rec_copy(value)
            else
                tbl[key] = value
            end
        end
    end

    return tbl
end

--- Merges the right hand table into the left hand array.
--- @param lh table
--- @param rh table
--- @return table
function Tirislib.Tables.merge(lh, rh)
    for _, value in pairs(rh) do
        lh[#lh + 1] = value
    end

    return lh
end

--- Calculates the sum of all elements in the given table.
--- @param tbl table
--- @return number
function Tirislib.Tables.sum(tbl)
    local ret = 0.

    for _, value in pairs(tbl) do
        ret = ret + value
    end

    return ret
end
local sum = Tirislib.Tables.sum

--- Normalizes the numeric elements in the given table.<br>
--- Meaning the sum of all elements will be (close to) 1.
--- @param tbl table
function Tirislib.Tables.normalize(tbl)
    local table_sum = sum(tbl)

    if table_sum > 0 then
        for index, value in pairs(tbl) do
            tbl[index] = value / table_sum
        end
    end
end

--- Calculates the product of all elements in the given table.
--- @param tbl table
--- @return number
function Tirislib.Tables.product(tbl)
    local ret = 1.

    for _, value in pairs(tbl) do
        ret = ret * value
    end

    return ret
end

--- Calculates the average of all elements in the given table.
--- Returns 0 for an empty table.
--- @param tbl table
--- @return number
function Tirislib.Tables.average(tbl)
    local ret = 0
    local count = 0

    for _, value in pairs(tbl) do
        ret = ret + value
        count = count + 1
    end

    return count > 0 and ret / count or 0
end

--- Returns an array of all values in the given table.
--- @param tbl table
--- @return array
function Tirislib.Tables.values(tbl)
    local ret = {}
    local i = 1

    for _, value in pairs(tbl) do
        ret[i] = value
        i = i + 1
    end

    return ret
end

--- Returns a new table with keys and values swapped.
--- @param tbl table
--- @return table
function Tirislib.Tables.invert(tbl)
    local ret = {}

    for key, value in pairs(tbl) do
        ret[value] = key
    end

    return ret
end

--- Removes all fields of the given table. Useful if you need to preserve references.
--- @param tbl table
function Tirislib.Tables.empty(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

--- Returns a random key out of the given table, or nil if the table is empty.
--- @param tbl table
--- @return any key
function Tirislib.Tables.pick_random_key(tbl)
    local keys = get_keyset(tbl)
    if #keys == 0 then
        return nil
    end
    return keys[random(#keys)]
end

--- Returns a random value out of the given table, or nil if the table is empty.
--- @param tbl table
--- @return any
function Tirislib.Tables.pick_random_value(tbl)
    local keys = get_keyset(tbl)
    if #keys == 0 then
        return nil
    end
    return tbl[keys[random(#keys)]]
end

--- Returns an array with the given amount of random keys out of the given table.
--- @param tbl table
--- @param n integer
--- @return array
function Tirislib.Tables.pick_n_random_keys(tbl, n)
    local keys = get_keyset(tbl)
    local key_count = #keys
    local ret = {}

    for i = 1, n do
        ret[i] = keys[random(key_count)]
    end

    return ret
end

--- Returns an array with the given amount of random values out of the given table.
--- @param tbl table
--- @param n integer
--- @return array
function Tirislib.Tables.pick_n_random_values(tbl, n)
    local keys = get_keyset(tbl)
    local key_count = #keys
    local ret = {}

    for i = 1, n do
        ret[i] = tbl[keys[random(key_count)]]
    end

    return ret
end

--- Given a table of tables, returns a random subtable. The value behind the given key is the probability weight for each subtable.
--- - The sum of all weights can be given to avoid calculating it multiple times.
--- @param tbl table
--- @param key any
--- @param weight_sum number|nil
--- @return any index
--- @return table subtable
function Tirislib.Tables.pick_random_subtable_weighted_by_key(tbl, key, weight_sum)
    weight_sum = weight_sum or Tirislib.Luaq.from(tbl):select_key(key):call(sum)

    local random_index = random() * weight_sum

    for index, subtable in pairs(tbl) do
        random_index = random_index - subtable[key]

        if random_index <= 0 then
            return index, subtable
        end
    end

    error("pick_random_subtable_weighted_by_key failed to pick a subtable, most likely due to a wrong weight_sum")
end

--- Gets or creates the subtable with the given key.
--- @param tbl table
--- @param key any
--- @return table
function Tirislib.Tables.get_subtbl(tbl, key)
    if tbl[key] == nil then
        tbl[key] = {}
    end

    return tbl[key]
end
local get_subtbl = Tirislib.Tables.get_subtbl

--- Gets or creates the subtable that is nested with the given sequence of keys inside the given table.
--- @param tbl table
--- @return table
function Tirislib.Tables.get_subtbl_recursive(tbl, ...)
    local ret = tbl

    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if ret[key] == nil then
            ret[key] = {}
        end

        ret = ret[key]
    end

    return ret
end

--- Gets the subtable that is nested with the given sequence of keys inside the given table.<br>
--- If there is no subtable with a given key, the function returns nil.
--- @param tbl table?
--- @return table?
function Tirislib.Tables.get_subtbl_recursive_passive(tbl, ...)
    if tbl == nil then
        return nil
    end

    local ret = tbl

    for i = 1, select("#", ...) do
        local key = select(i, ...)
        ret = ret[key]

        if ret == nil then
            return nil
        end
    end

    return ret
end

--- Groups the tables inside the given table by the content of the given key.\
--- In case an inner table doesn't have a value for the given key it gets added to the group of the default_key
--- if one is given.
--- @param tbl table
--- @param key any
--- @param default_key any|nil
--- @return table
function Tirislib.Tables.group_by_key(tbl, key, default_key)
    local ret = {}
    local default_inner = default_key and get_subtbl(ret, default_key)

    for _, current in pairs(tbl) do
        local value = current[key]

        if value then
            local result_inner = get_subtbl(ret, value)
            result_inner[#result_inner + 1] = current
        elseif default_inner then
            default_inner[#default_inner + 1] = current
        end
    end

    return ret
end

--- Adds the contents of the given right hand side table to the given left hand side table.
--- @param lh table
--- @param rh table
function Tirislib.Tables.add(lh, rh)
    for key, value in pairs(rh) do
        lh[key] = (lh[key] or 0) + value
    end
end

--- Subtracts the contents of the given right hand side table from the given left hand side table.
--- @param lh table
--- @param rh table
function Tirislib.Tables.subtract(lh, rh)
    for key, value in pairs(rh) do
        lh[key] = (lh[key] or 0) - value
    end
end

--- Multiplies all containing values of the given table with the given multiplier.
--- @param tbl table
--- @param multiplier number
function Tirislib.Tables.multiply(tbl, multiplier)
    for key, value in pairs(tbl) do
        tbl[key] = value * multiplier
    end
end

--- Returns the union of the values across the given tables as an array.
--- @return array
function Tirislib.Tables.union(...)
    local ret = {}
    local values = {}

    for i = 1, select("#", ...) do
        local current_table = select(i, ...)
        for _, value in pairs(current_table) do
            if values[value] == nil then
                ret[#ret + 1] = value
                values[value] = true
            end
        end
    end

    return ret
end

--- Returns the intersection of the values across the given tables as an array.
--- @return array
function Tirislib.Tables.intersection(...)
    local set_count = select("#", ...)
    local value_counts = {}

    for i = 1, set_count do
        local current_set = select(i, ...)
        for _, value in pairs(current_set) do
            value_counts[value] = (value_counts[value] or 0) + 1
        end
    end

    local ret = {}

    for value, count in pairs(value_counts) do
        if count == set_count then
            ret[#ret + 1] = value
        end
    end

    return ret
end

--- Returns the values present in the vararg tables but not in 'set', as an array.
--- @param set table
--- @return array
function Tirislib.Tables.complement(set, ...)
    local lookup = {}
    for _, v in pairs(set) do
        lookup[v] = true
    end

    local ret = {}

    for i = 1, select("#", ...) do
        local current_set = select(i, ...)
        for _, value in pairs(current_set) do
            if lookup[value] == nil then
                ret[value] = true
            end
        end
    end

    return get_keyset(ret)
end

local function partial_iterator(tbl, index_table)
    local count = index_table[2]
    local key = index_table[1]
    if count > 0 and key ~= nil then
        local value = tbl[key]
        index_table[1] = next(tbl, key)
        index_table[2] = count - 1

        return index_table, value
    end
end

function Tirislib.Tables.iterate_partially(tbl, start, count)
    if tbl[start] == nil then
        start = nil
    end

    local index_table = {start, count}

    return partial_iterator, tbl, index_table
end
