local random = math.random
local abs = math.abs
local max = math.max
local floor = math.floor

--<< Just some helper functions >>
Tirislib_Utils = {}

function Tirislib_Utils.clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end
local clamp = Tirislib_Utils.clamp

function Tirislib_Utils.map_range(val, from_min, from_max, to_min, to_max)
    val = clamp(val, from_min, from_max)
    return to_min + (val - from_min) / (from_max - from_min) * (to_max - to_min)
end

function Tirislib_Utils.round(number)
    return floor(number + 0.5)
end

function Tirislib_Utils.weighted_average(a, weight_a, b, weight_b)
    if weight_a == 0 and weight_b == 0 then
        return 0
    end
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

function Tirislib_Utils.weighted_random(weights)
    local sum = 0
    for i = 1, #weights do
        sum = sum + weights[i]
    end

    local random_index = random(sum)
    local index = 0

    repeat
        index = index + 1
        random_index = random_index - weights[index]
    until random_index < 1

    return index
end

function Tirislib_Utils.maximum_metric_distance(x1, y1, x2, y2)
    local dist_x = abs(x1 - x2)
    local dist_y = abs(y1 - y2)

    return max(dist_x, dist_y)
end

function Tirislib_Utils.get_range_bounding_box(position, range)
    local x = position.x
    local y = position.y
    range = range / 2

    return {{x - range, y - range}, {x + range, y + range}}
end

function Tirislib_Utils.get_size(entity)
    local selection_box = entity.selection_box
    local left_top = selection_box.left_top
    local right_bottom = selection_box.right_bottom

    return right_bottom.x - left_top.x, right_bottom.y - left_top.y
end

function Tirislib_Utils.desync_protection()
    if game then
        error(
            "A function that is supposed to only be called during the control initialization stage got called at a later stage."
        )
    end
end

--<< Just some string helper functions >>
Tirislib_String = {}

function Tirislib_String.begins_with(str, prefix)
    return str:sub(1, prefix:len()) == prefix
end

local function string_join(separator, lh, rh)
    if lh then
        return lh .. separator .. rh
    else
        return rh
    end
end

function Tirislib_String.join(separator, ...)
    local ret

    for _, current in pairs({...}) do
        if type(current) == "table" then
            ret = string_join(separator, ret, Tirislib_String.join(separator, unpack(current)))
        else
            ret = string_join(separator, ret, current)
        end
    end

    return ret
end

--<< Just some table helper functions >>
Tirislib_Tables = {}

function Tirislib_Tables.equal(lh, rh)
    if type(lh) ~= "table" or type(rh) ~= "table" then
        return false
    end

    for k, v in pairs(lh) do
        if type(v) == "table" then
            if not Tirislib_Tables.equal(v, rh[k]) then
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

function Tirislib_Tables.shallow_equal(lh, rh)
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

function Tirislib_Tables.count(tbl)
    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

--- Removes all values of the given table that equal the given value.
--- This function doesn't preserve the original order.
function Tirislib_Tables.remove_all(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            tbl[i] = tbl[#tbl]
            tbl[#tbl] = nil
        end
    end
end

--- Returns an array with all the keys of the given table.
function Tirislib_Tables.get_keyset(tbl)
    local ret = {}
    local index = 1

    for key, _ in pairs(tbl) do
        ret[index] = key
        index = index + 1
    end

    return ret
end
local get_keyset = Tirislib_Tables.get_keyset

--- Returns a table with the elements of the given array as keys.
function Tirislib_Tables.array_to_lookup(array)
    local ret = {}

    for i = 1, #array do
        ret[array[i]] = true
    end

    return ret
end

--https://gist.github.com/Uradamus/10323382
function Tirislib_Tables.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = random(i)
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
local rec_copy = Tirislib_Tables.recursive_copy

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

function Tirislib_Tables.set_fields(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            tbl[key] = value
        end
    end

    return tbl
end

function Tirislib_Tables.set_fields_passively(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            tbl[key] = tbl[key] or value
        end
    end

    return tbl
end

function Tirislib_Tables.copy_fields(tbl, fields)
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

function Tirislib_Tables.merge(lh, rh)
    for _, value in pairs(rh) do
        lh[#lh + 1] = value
    end

    return lh
end

function Tirislib_Tables.merge_arrays(lh, rh)
    for i = 1, #rh do
        lh[#lh + 1] = rh[i]
    end

    return lh
end

function Tirislib_Tables.sum(tbl)
    local ret = 0.

    for _, value in pairs(tbl) do
        ret = ret + value
    end

    return ret
end

function Tirislib_Tables.array_sum(tbl)
    local ret = 0.

    for i = 1, #tbl do
        ret = ret + tbl[i]
    end

    return ret
end

function Tirislib_Tables.product(tbl)
    local ret = 1.

    for _, value in pairs(tbl) do
        ret = ret * value
    end

    return ret
end

function Tirislib_Tables.array_product(tbl)
    local ret = 1.

    for i = 1, #tbl do
        ret = ret * tbl[i]
    end

    return ret
end

function Tirislib_Tables.empty(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

function Tirislib_Tables.new_array(size, value)
    local ret = {}

    for i = 1, size do
        ret[i] = value
    end

    return ret
end

function Tirislib_Tables.new_array_of_arrays(count)
    local ret = {}

    for i = 1, count do
        ret[i] = {}
    end

    return ret
end

function Tirislib_Tables.insertion_sort_by_key(array, key)
    local length = #array

    for j = 2, length do
        local current = array[j]
        local current_value = array[j][key]
        local i = j - 1

        while i > 0 and array[i][key] < current_value do
            array[i + 1] = array[i]
            i = i - 1
        end
        array[i + 1] = current
    end

    return array
end

function Tirislib_Tables.has_numeric_key(tbl)
    for key in pairs(tbl) do
        if type(key) == "number" then
            return true
        end
    end

    return false
end

function Tirislib_Tables.union_array(lhs, rhs)
    local ret = {}

    for _, value in pairs(lhs) do
        ret[value] = value
    end
    for _, value in pairs(rhs) do
        ret[value] = value
    end

    return get_keyset(ret)
end

function Tirislib_Tables.pick_random_key(tbl)
    local keys = get_keyset(tbl)
    return keys[random(#keys)]
end

function Tirislib_Tables.pick_n_random_keys(tbl, n)
    local keys = get_keyset(tbl)
    local key_count = #keys
    local ret = {}

    for i = 1, n do
        ret[i] = keys[random(key_count)]
    end

    return ret
end

function Tirislib_Tables.sequence(start, finish)
    local ret = {}

    for i = 0, finish - start do
        ret[i + 1] = start + i
    end

    return ret
end
