local random = math.random
local abs = math.abs
local max = math.max
local min = math.min
local floor = math.floor
local select = select

---------------------------------------------------------------------------------------------------
-- << helper functions >>

--- Gets or creates the subtable with the given key.
--- @param tbl table
--- @param key any
--- @return table
local function get_subtbl(tbl, key)
    if not tbl[key] then
        tbl[key] = {}
    end

    return tbl[key]
end

---------------------------------------------------------------------------------------------------
--- Table query functions
Tirislib_Luaq = {}

Tirislib_Luaq.__index = Tirislib_Luaq

--- Creates a luaq query for the given source.
--- @param source table
--- @return LuaqQuery
function Tirislib_Luaq.from(source)
    local ret = {
        content = source
    }
    setmetatable(ret, Tirislib_Luaq)

    return ret
end

--- Selects the given key of every element.
--- @param key any
--- @return LuaqQuery
function Tirislib_Luaq:select_key(key)
    local new_content = {}

    for index, element in pairs(self.content) do
        new_content[index] = element[key]
    end

    self.content = new_content
    return self
end

--- Projects the sequence with the given function.
--- @param fn function
--- @return LuaqQuery
function Tirislib_Luaq:select(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        new_content[index] = fn(index, element, ...)
    end

    self.content = new_content
    return self
end

--- Filters the elements of the sequence with the given function.
--- @param fn function
--- @return LuaqQuery
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

--- Calls the given function on every element of the sequence.
--- @param fn function
--- @return LuaqQuery
function Tirislib_Luaq:foreach(fn, ...)
    for index, element in pairs(self.content) do
        fn(index, element, ...)
    end

    return self
end

--- Groups the sequence by the return value of the given function.
--- @param fn function
--- @return LuaqQuery
function Tirislib_Luaq:group(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        local group_index = fn(index, element, ...)
        get_subtbl(new_content, group_index)[index] = element
    end

    self.content = new_content
    return self
end

--- Returns the sequence as a table.
--- @return table
function Tirislib_Luaq:to_table()
    return self.content
end

--- Returns the sequence as an array.
--- @return table
function Tirislib_Luaq:to_array()
    local ret = {}

    for _, element in pairs(self.content) do
        ret[#ret + 1] = element
    end

    return ret
end

--- Calls the given function on the sequence.
--- @param fn function
--- @return any
function Tirislib_Luaq:call(fn, ...)
    return fn(self.content, ...)
end

---------------------------------------------------------------------------------------------------
--- Just some helper functions
Tirislib_Utils = {}

--- Clamps the given value, so it falls in the given interval.
--- @param val number
--- @param value_min number
--- @param value_max number
--- @return number
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

--- Maps the given value, so it falls in the 'to' interval proportional to the 'from' interval.
---@param val number
---@param from_min number
---@param from_max number
---@param to_min number
---@param to_max number
---@return number
function Tirislib_Utils.map_range(val, from_min, from_max, to_min, to_max)
    val = clamp(val, from_min, from_max)
    return to_min + (val - from_min) / (from_max - from_min) * (to_max - to_min)
end

--- Rounds the given value mathematically.
--- @param number number
--- @return number
function Tirislib_Utils.round(number)
    return floor(number + 0.5)
end

--- Returns the average between a and b with the given weights.
--- @param a number
--- @param weight_a number
--- @param b number
--- @param weight_b number
--- @return number
function Tirislib_Utils.weighted_average(a, weight_a, b, weight_b)
    if weight_a == 0 and weight_b == 0 then
        return 0
    end
    return (a * weight_a + b * weight_b) / (weight_a + weight_b)
end

--- Returns the sign of the given number.
--- @param x number
--- @return integer
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
--- - The sum of all weights can be given to avoid calculating it multiple times.
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
--- @param dice table
--- @return table weights
--- @return table key_lookup
--- @return table results
--- @return number sum
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
--- @param actual_count integer|nil defaults to 20
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

--- Flips a coin the given number of times and returns the number of successes.
--- For performance reason the function will actually just roll a limited number
--- of times and extrapolate for bigger values.
--- @param probability number
--- @param count integer
--- @param actual_count integer|nil defaults to 20
--- @return integer success_count
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

--- Returns the probability of at least one success after n tries.
--- @param probability number
--- @param tries number
--- @return number
function Tirislib_Utils.occurence_probability(probability, tries)
    return 1 - (1 - probability) ^ tries
end

--- Returns the greatest number that is a divisor of both given numbers.
--- @param m integer
--- @param n integer
--- @return integer
function Tirislib_Utils.greatest_common_divisor(m, n)
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end
local gcd = Tirislib_Utils.greatest_common_divisor

--- Returns the lowest number that has both given numbers as divisors.
--- @param m integer
--- @param n integer
--- @return integer
function Tirislib_Utils.lowest_common_multiple(m, n)
    return (m ~= 0 and n ~= 0) and m * n / gcd(m, n) or 0
end

--- Returns the maximum metric distance between the given points.
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function Tirislib_Utils.maximum_metric_distance(x1, y1, x2, y2)
    local dist_x = abs(x1 - x2)
    local dist_y = abs(y1 - y2)

    return max(dist_x, dist_y)
end

--- Returns the n metric distance between the given points.
--- @param n number
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function Tirislib_Utils.n_metric_distance(n, x1, y1, x2, y2)
    return ((x1 - x2) ^ n + (y1 - y2) ^ n) ^ (1 / n)
end

--- Returns a bounding box around the given position with the given size.
--- @param position point2d
--- @param range number
--- @return point2d left_top
--- @return point2d right_bottom
function Tirislib_Utils.get_range_bounding_box(position, range)
    local x = position.x
    local y = position.y
    range = range / 2

    return {{x - range, y - range}, {x + range, y + range}}
end

--- Returns the height and width of the given LuaEntity.
--- @param entity LuaEntity
--- @return number height
--- @return number width
function Tirislib_Utils.get_entity_size(entity)
    local selection_box = entity.selection_box
    local left_top = selection_box.left_top
    local right_bottom = selection_box.right_bottom

    return right_bottom.x - left_top.x, right_bottom.y - left_top.y
end

--- Returns the height and width of the given box.
--- @param box table
--- @return number height
--- @return number width
function Tirislib_Utils.get_box_size(box)
    local left_top = box.left_top
    local right_bottom = box.right_bottom

    return right_bottom.x - left_top.x, right_bottom.y - left_top.y
end

--- Adds a random integer offset to the given position.
--- @param position point2d
--- @param offset integer
function Tirislib_Utils.add_random_offset(position, offset)
    position.x = position.x + random(-offset, offset)
    position.y = position.y + random(-offset, offset)
end

--- Checks that it is not the control stage. Otherwise throws an error.\
--- Used to secure that specific functions can only be called during the initialisation stage, as they would otherwise be a cause for desyncs.
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

--- Checks if the given string begins with the given prefix.
--- @param str string
--- @param prefix string
--- @return boolean
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

--- Splits the given string along the given separator and returns an array of the parts.
--- @param s string
--- @param separator string
--- @return table
function Tirislib_String.split(s, separator)
    local ret = {}

    for part in string.gmatch(s, "([^" .. separator .. "]+)") do
        ret[#ret + 1] = part
    end

    return ret
end

--- Inserts the given string at the given position.
--- @param s string
--- @param ins string
--- @param pos integer
--- @return string
function Tirislib_String.insert(s, ins, pos)
    return s:sub(1, pos) .. ins .. s:sub(pos + 1)
end

---------------------------------------------------------------------------------------------------
--- Just some table helper functions
Tirislib_Tables = {}

--- Recursively checks if the contents of the given tables are equal.
--- @param lh table
--- @param rh table
--- @return boolean
function Tirislib_Tables.equal(lh, rh)
    if lh == rh then
        return true
    end

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

--- Checks if the contents of the given tables are equal. This method won't check nested tables.. for performance reasons.
--- @param lh table
--- @param rh table
--- @return boolean
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

--- Returns the number of elements in this table.
--- @param tbl table
--- @return integer
function Tirislib_Tables.count(tbl)
    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

--- Removes all values of the given table that equal the given value.
--- This function doesn't preserve the original order.
--- @param tbl table
--- @param value any
function Tirislib_Tables.remove_all(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            tbl[i] = tbl[#tbl]
            tbl[#tbl] = nil
        end
    end
end

--- Returns an array with all the keys of the given table.
--- @param tbl table
--- @return table
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
--- @param array table
--- @return table
function Tirislib_Tables.array_to_lookup(array)
    local ret = {}

    for i = 1, #array do
        ret[array[i]] = true
    end

    return ret
end
local array_to_lookup = Tirislib_Tables.array_to_lookup

--- Shuffles the elements of the given array.
--- @param tbl array
--- @return array itself
function Tirislib_Tables.shuffle(tbl)
    --https://gist.github.com/Uradamus/10323382
    for i = #tbl, 2, -1 do
        local j = random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

--- Clones the table, nested tables will be referenced.
--- @param tbl table
--- @return table
function Tirislib_Tables.copy(tbl)
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
function Tirislib_Tables.recursive_copy(tbl)
    return recursive_copy(tbl, {})
end
local rec_copy = Tirislib_Tables.recursive_copy

--- Checks if a field of the given table contains the given value.
--- @param tbl table
--- @param element any
--- @return boolean
function Tirislib_Tables.contains(tbl, element)
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
function Tirislib_Tables.contains_key(tbl, key)
    return tbl[key] ~= nil
end

--- Sets all fields of the given right hand table to the given left hand table.
--- @param tbl table
--- @param fields table
--- @return table
function Tirislib_Tables.set_fields(tbl, fields)
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
function Tirislib_Tables.set_fields_passively(tbl, fields)
    if fields ~= nil then
        for key, value in pairs(fields) do
            tbl[key] = (tbl[key] ~= nil) and tbl[key] or value
        end
    end

    return tbl
end

--- Sets all fields of the given right hand table to the given left hand table. Nested tables will be cloned.
--- @param tbl table
--- @param fields table
--- @return table
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

--- Merges the right hand table into the left hand array.
--- @param lh table
--- @param rh table
--- @return table
function Tirislib_Tables.merge(lh, rh)
    for _, value in pairs(rh) do
        lh[#lh + 1] = value
    end

    return lh
end

--- Merges the right hand array into the left hand array.
--- @param lh table
--- @param rh table
--- @return table
function Tirislib_Tables.merge_arrays(lh, rh)
    for i = 1, #rh do
        lh[#lh + 1] = rh[i]
    end

    return lh
end

--- Calculates the sum of all elements in the given table.
--- @param tbl table
--- @return number
function Tirislib_Tables.sum(tbl)
    local ret = 0.

    for _, value in pairs(tbl) do
        ret = ret + value
    end

    return ret
end
local sum = Tirislib_Tables.sum

--- Calculates the sum of all elements in the given array.
--- @param tbl table
--- @return number
function Tirislib_Tables.array_sum(tbl)
    local ret = 0.

    for i = 1, #tbl do
        ret = ret + tbl[i]
    end

    return ret
end

--- Calculates the product of all elements in the given table.
--- @param tbl table
--- @return number
function Tirislib_Tables.product(tbl)
    local ret = 1.

    for _, value in pairs(tbl) do
        ret = ret * value
    end

    return ret
end

--- Calculates the product of all elements in the given array.
--- @param tbl table
--- @return number
function Tirislib_Tables.array_product(tbl)
    local ret = 1.

    for i = 1, #tbl do
        ret = ret * tbl[i]
    end

    return ret
end

--- Removes all fields of the given table. Useful if you need to preserve references.
--- @param tbl table
function Tirislib_Tables.empty(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

--- Creates a new array with the given number of predefined elements.
--- @param size integer
--- @param value any
--- @return table
function Tirislib_Tables.new_array(size, value)
    local ret = {}

    for i = 1, size do
        ret[i] = value
    end

    return ret
end

--- Creates a new array with the given number of nested tables.
--- @param count integer
--- @return table
function Tirislib_Tables.new_array_of_arrays(count)
    local ret = {}

    for i = 1, count do
        ret[i] = {}
    end

    return ret
end

--- Sorts the given array of tables by the given key.
--- - The sorting algorithm is insertion sort because I was too lazy to implement an algorithm for bigger arrays.
---@param array table
---@param key any
---@return table
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

--- Returns the union set of the contents of the given tables.
--- @return array
function Tirislib_Tables.union_array(...)
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

--- Returns the intersection set of the contents of the given tables.
--- @return array
function Tirislib_Tables.intersection_array(...)
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

--- Returns the complement set of content of the given tables.
--- @param set table
--- @return array
function Tirislib_Tables.complement_array(set, ...)
    set = array_to_lookup(set)
    local ret = {}

    for i = 1, select("#", ...) do
        local current_set = select(i, ...)
        for _, value in pairs(current_set) do
            if set[value] == nil then
                ret[value] = true
            end
        end
    end

    return get_keyset(ret)
end

--- Returns a random key out of the given table.
--- @param tbl table
--- @return any key
function Tirislib_Tables.pick_random_key(tbl)
    local keys = get_keyset(tbl)
    return keys[random(#keys)]
end

--- Returns a random value out of the given table.
--- @param tbl table
--- @return any
function Tirislib_Tables.pick_random_value(tbl)
    local keys = get_keyset(tbl)
    return tbl[keys[random(#keys)]]
end

--- Returns an array with the given amount of random keys out of the given table.
--- @param tbl table
--- @param n integer
--- @return array
function Tirislib_Tables.pick_n_random_keys(tbl, n)
    local keys = get_keyset(tbl)
    local key_count = #keys
    local ret = {}

    for i = 1, n do
        ret[i] = keys[random(key_count)]
    end

    return ret
end

--- Returns an array with the given amount of random keys out of the given table.
--- @param tbl any
--- @param n any
--- @return array
function Tirislib_Tables.pick_n_random_values(tbl, n)
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
--- @param tbl any
--- @param key any
--- @param weight_sum number|nil
--- @return any index
--- @return table subtable
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
--- @return array
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

Tirislib_Tables.get_subtbl = get_subtbl

--- Gets or creates the subtable that is nested with the given sequence of keys inside the given table.
--- @param tbl table
--- @return table
function Tirislib_Tables.get_subtbl_recursive(tbl, ...)
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

--- Groups the tables inside the given table by the content of the given key.\
--- In case an inner table doesn't have a value for the given key it gets added to the group of the default_key
--- if one is given.
--- @param tbl table
--- @param key any
--- @param default_key any|nil
--- @return table
function Tirislib_Tables.group_by_key(tbl, key, default_key)
    local ret = {}
    local default_inner = default_key and get_subtbl(default_key)

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
function Tirislib_Tables.add(lh, rh)
    for key, value in pairs(rh) do
        lh[key] = (lh[key] or 0) + value
    end
end

--- Multiplies all containing values of the given table with the given multiplier.
--- @param tbl table
--- @param multiplier number
function Tirislib_Tables.multiply(tbl, multiplier)
    for key, value in pairs(tbl) do
        tbl[key] = value * multiplier
    end
end

local function partial_iterator(tbl, index_table)
    local count = index_table[2]
    if count > 0 then
        local value = tbl[index_table[1]]
        if value then
            index_table[1] = next(tbl, index_table[1])
            index_table[2] = count - 1

            return index_table, value
        end
    end
end

function Tirislib_Tables.iterate_partially(tbl, start, count)
    if tbl[start] == nil then
        start = nil
    end

    local index_table = {start, count}

    return partial_iterator, tbl, index_table
end

---------------------------------------------------------------------------------------------------
--- Just some locale helper functions
Tirislib_Locales = {}

--- Shortens the ""-enumeration to ensure that there aren't more than the allowed number of elements.
--- @param enumeration locale
local function shorten_enumeration(enumeration)
    if #enumeration <= 20 then
        return
    end

    local copy = {}
    for i = 2, #enumeration do
        copy[#copy + 1] = enumeration[i]
        enumeration[i] = nil
    end

    for i = 1, #copy do
        local subtable_index = floor(i / 20) + 2
        if not enumeration[subtable_index] then
            enumeration[subtable_index] = {""}
        end
        local subtable = enumeration[subtable_index]
        subtable[#subtable + 1] = copy[i]
    end

    shorten_enumeration(enumeration)
end

Tirislib_Locales.shorten_enumeration = shorten_enumeration

--- Creates a localised enumeration of the given elements.
--- @param elements array
--- @param separator string|locale
--- @param last_separator string|locale|nil
--- @return locale
function Tirislib_Locales.create_enumeration(elements, separator, last_separator)
    separator = separator or ", "
    local ret = {""}
    local at_least_one = false

    for _, element in pairs(elements) do
        ret[#ret + 1] = element
        ret[#ret + 1] = separator
        at_least_one = true
    end
    ret[#ret] = nil

    if last_separator and #ret > 2 then
        ret[#ret - 1] = last_separator
    end

    if not at_least_one then
        -- the given elements table was empty
        return ""
    end

    shorten_enumeration(ret)

    return ret
end
local create_enumeration = Tirislib_Locales.create_enumeration

--- Creates a localisation for the real world time for the given ticks.
--- @param ticks integer
--- @return locale
function Tirislib_Locales.display_time(ticks)
    local seconds = floor(ticks / 60)
    local minutes = floor(seconds / 60)
    seconds = seconds % 60
    local hours = floor(minutes / 60)
    minutes = minutes % 60

    local points = {}
    if hours > 0 then
        points[#points + 1] = {"sosciencity.xhours", hours}
    end
    if minutes > 0 then
        points[#points + 1] = {"sosciencity.xminutes", minutes}
    end
    if seconds > 0 or #points == 0 then
        points[#points + 1] = {"sosciencity.xseconds", seconds}
    end

    return create_enumeration(points, ", ", {"sosciencity.and"})
end

--- Creates a localisation for the ingame time for the given ticks.
--- @param ticks integer
--- @return locale
function Tirislib_Locales.display_ingame_time(ticks)
    local days = floor(ticks / 25000)
    local weeks = floor(days / 7)
    days = days % 7
    local months = floor(weeks / 4)
    weeks = weeks % 4

    local points = {}
    if months > 0 then
        points[#points + 1] = {"sosciencity.xmonths", months}
    end
    if weeks > 0 then
        points[#points + 1] = {"sosciencity.xweeks", weeks}
    end
    if days > 0 then
        points[#points + 1] = {"sosciencity.xdays", days}
    end
    if #points == 0 then
        points[#points + 1] = {"sosciencity.less-than-a-day"}
    end

    return create_enumeration(points, ", ", {"sosciencity.and"})
end
