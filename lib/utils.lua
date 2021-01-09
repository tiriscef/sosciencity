-- EmmyLua stuff
---@class array

local random = math.random
local abs = math.abs
local max = math.max
local min = math.min
local floor = math.floor

---------------------------------------------------------------------------------------------------
-- << helper functions >>

--- Gets or creates the inner table with the given key.
local function get_inner_table(tbl, key)
    if not tbl[key] then
        tbl[key] = {}
    end

    return tbl[key]
end

---------------------------------------------------------------------------------------------------
--- Table query functions
Tirislib_Luaq = {}

Tirislib_Luaq.__index = Tirislib_Luaq

function Tirislib_Luaq.from(source)
    local ret = {
        content = source
    }
    setmetatable(ret, Tirislib_Luaq)

    return ret
end

function Tirislib_Luaq:select_key(key)
    local new_content = {}

    for index, element in pairs(self.content) do
        new_content[index] = element[key]
    end

    self.content = new_content
    return self
end

function Tirislib_Luaq:select(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        new_content[index] = fn(index, element, ...)
    end

    self.content = new_content
    return self
end

function Tirislib_Luaq:where(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        if fn(index, element, ...) then
            new_content[index] = element
        end
    end

    self.content = new_content
    return self
end

function Tirislib_Luaq:foreach(fn, ...)
    for index, element in pairs(self.content) do
        fn(index, element, ...)
    end
end

function Tirislib_Luaq:group(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        local group_index = fn(index, element, ...)
        get_inner_table(new_content, group_index)[index] = element
    end

    self.content = new_content
    return self
end

function Tirislib_Luaq:to_table()
    return self.content
end

function Tirislib_Luaq:to_array()
    local ret = {}

    for _, element in pairs(self.content) do
        ret[#ret + 1] = element
    end

    return ret
end

function Tirislib_Luaq:call(fn, ...)
    return fn(self.content, ...)
end

---------------------------------------------------------------------------------------------------
--- Just some helper functions
Tirislib_Utils = {}

function Tirislib_Utils.clamp(val, value_min, value_max)
    if val < value_min then
        return value_min
    elseif val > value_max then
        return value_max
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

--- Chooses a random index of the given weights array.
--- @param weights array
--- @param sum number
--- @return integer
function Tirislib_Utils.weighted_random(weights, sum)
    if sum == nil then
        sum = 0
        for i = 1, #weights do
            sum = sum + weights[i]
        end
    end

    local random_index = random() * sum
    local index = 0

    repeat
        index = index + 1
        random_index = random_index - weights[index]
    until random_index <= 0

    return index
end
local weighted_random = Tirislib_Utils.weighted_random

--- Generates the weights array, key-lookup array, result array and the weights sum for the given dice.
local function prepare_dice(dice)
    local weights = {}
    local lookup = {}
    local ret = {}
    local sum = 0

    local index = 1
    for key, probability in pairs(dice) do
        weights[index] = probability
        lookup[index] = key
        ret[key] = 0
        sum = sum + probability

        index = index + 1
    end

    return weights, lookup, ret, sum
end

--- Rolls the given dice the given number of times and returns a table with the number of times
--- each side was the result. For performance reason the function will actually just roll a
--- limited number of times and extrapolate for bigger values.\
--- A dice is defined as a table whose values are the probability weight of the associated key.
--- @param dice table
--- @param count integer
--- @param actual_count integer
--- @return table
function Tirislib_Utils.dice_rolls(dice, count, actual_count)
    actual_count = actual_count or 20

    local weights, lookup, ret, sum = prepare_dice(dice)
    local count_per_roll = 1
    local modulo = 0
    if count > actual_count then
        count_per_roll = floor(count / actual_count)
        modulo = count % actual_count
    end

    for i = 1, min(count, actual_count) do
        local rolled = lookup[weighted_random(weights, sum)]
        ret[rolled] = ret[rolled] + count_per_roll + (i <= modulo and 1 or 0)
    end

    return ret
end

function Tirislib_Utils.coin_flips(probability, count, actual_count)
    actual_count = actual_count or 20

    local successes = 0
    local count_per_coin = 1
    local modulo = 0
    if count > actual_count then
        count_per_coin = floor(count / actual_count)
        modulo = count % actual_count
    end

    for i = 1, min(count, actual_count) do
        local success = (random() < probability)
        if success then
            successes = successes + count_per_coin + (i <= modulo and 1 or 0)
        end
    end

    return successes
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

function Tirislib_Utils.add_random_offset(position, offset)
    position.x = position.x + random(-offset, offset)
    position.y = position.y + random(-offset, offset)
end

function Tirislib_Utils.desync_protection()
    if game then
        error(
            "A function that is supposed to only be called during the control initialization stage got called at a later stage."
        )
    end
end

---------------------------------------------------------------------------------------------------
--- Just some string helper functions
Tirislib_String = {}

function Tirislib_String.begins_with(str, prefix)
    return str:sub(1, prefix:len()) == prefix
end

local function join_single_element(separator, lh, rh)
    if lh then
        if rh then
            return lh .. separator .. rh
        else
            return lh
        end
    else
        return rh
    end
end

local function join_table(separator, tbl)
    local ret

    for _, current in pairs(tbl) do
        if type(current) == "table" then
            ret = join_single_element(separator, ret, join_table(separator, current))
        else
            ret = join_single_element(separator, ret, current)
        end
    end

    return ret
end

--- Returns a string that presents all given elements, separated by the given separator.\
--- Returns an empty string if no elements are given.
--- @param separator string
function Tirislib_String.join(separator, ...)
    return join_table(separator, {...}) or ""
end

---Splits the given string along the given separator and returns an array of the parts.
---@param s string
---@param separator string
---@return table
function Tirislib_String.split(s, separator)
    local ret = {}

    for part in string.gmatch(s, "([^" .. separator .. "]+)") do
        ret[#ret + 1] = part
    end

    return ret
end

---------------------------------------------------------------------------------------------------
--- Just some table helper functions
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

    for key in pairs(tbl) do
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
local sum = Tirislib_Tables.sum

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

function Tirislib_Tables.union_array(lh, rh)
    local ret = {}

    for _, value in pairs(lh) do
        ret[value] = value
    end
    for _, value in pairs(rh) do
        ret[value] = value
    end

    return get_keyset(ret)
end

function Tirislib_Tables.pick_random_key(tbl)
    local keys = get_keyset(tbl)
    return keys[random(#keys)]
end

function Tirislib_Tables.pick_random_value(tbl)
    local keys = get_keyset(tbl)
    return tbl[keys[random(#keys)]]
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

function Tirislib_Tables.pick_random_subtable_weighted_by_key(tbl, key, weight_sum)
    weight_sum = weight_sum or Tirislib_Luaq.from(tbl):select_key(key):call(sum)

    local random_index = random() * weight_sum

    for index, subtable in pairs(tbl) do
        random_index = random_index - subtable[key]

        if random_index <= 0 then
            return index, subtable
        end
    end
end

--- Returns an array with the given number sequence.
--- @param start number
--- @param finish number
--- @param steps number|nil
function Tirislib_Tables.sequence(start, finish, steps)
    local ret = {}
    local i = 1

    steps = steps or 1
    if finish < steps then
        steps = min(steps, -steps)
    end

    for n = start, finish, steps do
        ret[i] = n
        i = i + 1
    end

    return ret
end

Tirislib_Tables.get_inner_table = get_inner_table

--- Groups the tables inside the given table by the content of the given key.\
--- In case an inner table doesn't have a value for the given key it gets added to the group of the default_key
--- if one is given.
--- @param tbl table
--- @param key any
--- @param default_key any|nil
--- @return table
function Tirislib_Tables.group_by_key(tbl, key, default_key)
    local ret = {}
    local default_inner = default_key and get_inner_table(default_key)

    for _, current in pairs(tbl) do
        local value = current[key]

        if value then
            local result_inner = get_inner_table(ret, value)
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
function Tirislib_Tables.add(lh, rh)
    for key, value in pairs(rh) do
        lh[key] = (lh[key] or 0) + value
    end
end

function Tirislib_Tables.multiply(tbl, multiplier)
    for key, value in pairs(tbl) do
        tbl[key] = value * multiplier
    end
end
