local random = math.random
local abs = math.abs
local max = math.max
local min = math.min
local ceil = math.ceil
local floor = math.floor

---------------------------------------------------------------------------------------------------
--- Just some helper functions
Tirislib.Utils = {}

--- Just returns the arguments.<br>
--- (Weird how often you need something like this.)
--- @param ... any
--- @return any same
function Tirislib.Utils.identity(...)
    return ...
end

--- Clamps the given value, so it falls in the given interval.
--- @param val number
--- @param value_min number
--- @param value_max number
--- @return number
function Tirislib.Utils.clamp(val, value_min, value_max)
    if val < value_min then
        return value_min
    elseif val > value_max then
        return value_max
    else
        return val
    end
end
local clamp = Tirislib.Utils.clamp

--- Maps the given value, so it falls in the 'to' interval proportional to the 'from' interval.
---@param val number
---@param from_min number
---@param from_max number
---@param to_min number
---@param to_max number
---@return number
function Tirislib.Utils.map_range(val, from_min, from_max, to_min, to_max)
    if from_min == from_max then
        return to_min
    end
    val = clamp(val, min(from_min, from_max), max(from_min, from_max))
    return to_min + (val - from_min) / (from_max - from_min) * (to_max - to_min)
end

--- Rounds the given value mathematically (half away from zero).
--- @param number number
--- @return integer
function Tirislib.Utils.round(number)
    return (number >= 0) and floor(number + 0.5) or ceil(number - 0.5)
end
local round = Tirislib.Utils.round

--- Rounds the given value to the closest multiple of 'step'.
--- @param number number
--- @param step number
--- @return number
function Tirislib.Utils.round_to_step(number, step)
    return step * floor(number / step + 0.5)
end

--- Floors the given value to the closest lower multiple of 'step'.
--- @param number number
--- @param step number
--- @return number
function Tirislib.Utils.floor_to_step(number, step)
    return step * floor(number / step)
end

--- Ceils the given value to the closest higher multiple of 'step'.
--- @param number number
--- @param step number
--- @return number
function Tirislib.Utils.ceil_to_step(number, step)
    return step * ceil(number / step)
end

--- Famous smoothstep function.
--- Expects x in [0, 1]; results are undefined outside that range.
--- @param x number
--- @return number
function Tirislib.Utils.smoothstep(x)
    return x * x * (3 - 2 * x)
end

--- Famous variant of the smoothstep function.
--- Expects x in [0, 1]; results are undefined outside that range.
--- @param x number
--- @return number
function Tirislib.Utils.smootherstep(x)
    return x * x * x * (x * (6 * x - 15) + 10)
end

--- Returns the average between a and b with the given weights.
--- @param a number
--- @param weight_a number
--- @param b number
--- @param weight_b number
--- @return number
function Tirislib.Utils.weighted_average(a, weight_a, b, weight_b)
    if weight_a == 0 and weight_b == 0 then
        return 0
    end
    return (a * weight_a + b * weight_b) / (weight_a + weight_b)
end

--- Returns the sign of the given number.
--- @param x number
--- @return integer
function Tirislib.Utils.sgn(x)
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
--- @param sum number|nil
--- @return integer
function Tirislib.Utils.weighted_random(weights, sum)
    if sum == nil then
        sum = 0
        for i = 1, #weights do
            sum = sum + weights[i]
        end
    end

    if sum == 0 then
        error("weighted_random called with all-zero weights")
    end

    local random_index = random() * sum
    local index = 0

    repeat
        index = index + 1
        random_index = random_index - weights[index]
    until random_index <= 0

    return index
end
local weighted_random = Tirislib.Utils.weighted_random

--- Generates the weights array, key-lookup array, result array and the weights sum for the given dice.
--- @param dice table
--- @param omit_zero_entries boolean?
--- @return table weights
--- @return table key_lookup
--- @return table results
--- @return number sum
local function prepare_dice(dice, omit_zero_entries)
    local weights = {}
    local lookup = {}
    local ret = {}
    local sum = 0

    local index = 1
    for key, probability in pairs(dice) do
        weights[index] = probability
        lookup[index] = key
        ret[key] = not omit_zero_entries and 0 or nil
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
--- @param actual_count integer? defaults to 20
--- @param omit_zero_entries boolean?
--- @return table
function Tirislib.Utils.dice_rolls(dice, count, actual_count, omit_zero_entries)
    actual_count = actual_count or 20

    local weights, lookup, ret, sum = prepare_dice(dice, omit_zero_entries)
    local count_per_roll = 1
    local modulo = 0
    if count > actual_count then
        count_per_roll = floor(count / actual_count)
        modulo = count % actual_count
    end

    for i = 1, min(count, actual_count) do
        local rolled = lookup[weighted_random(weights, sum)]
        ret[rolled] = (ret[rolled] or 0) + count_per_roll + (i <= modulo and 1 or 0)
    end

    return ret
end

--- Flips a coin the given number of times and returns the number of successes.
--- For performance reason the function will actually just roll a limited number
--- of times and extrapolate for bigger values.
--- @param probability number
--- @param count integer
--- @param actual_count integer? defaults to 20
--- @return integer success_count
function Tirislib.Utils.coin_flips(probability, count, actual_count)
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
local coin_flips = Tirislib.Utils.coin_flips

--- Flips a coin the given number of times and returns the number of successes.<br>
--- Implements an 'overcrit'-logic, meaning probabilities over 100% will guarantee one success per 100% and flip with the remaining percentage.
--- @param probability number
--- @param count integer
--- @param actual_count integer?
function Tirislib.Utils.coin_flips_overcrit(probability, count, actual_count)
    local guaranteed = floor(probability)
    probability = probability - guaranteed

    return coin_flips(probability, count, actual_count) + guaranteed
end

--- Returns an integer in the given intervall that is different that the given number n.
--- @param value_min integer
--- @param value_max integer
--- @param n integer
--- @return integer
function Tirislib.Utils.random_different(value_min, value_max, n)
    if value_min == value_max then
        return value_min
    end

    local ret = random(value_min, value_max - 1)

    if ret >= n then
        return ret + 1
    else
        return ret
    end
end

--- Returns the probability of at least one success after n tries.
--- @param probability number
--- @param tries number
--- @return number
function Tirislib.Utils.occurrence_probability(probability, tries)
    return 1 - (1 - probability) ^ tries
end

--- Returns the greatest number that is a divisor of both given numbers.
--- @param m integer
--- @param n integer
--- @return integer
function Tirislib.Utils.greatest_common_divisor(m, n)
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end
local gcd = Tirislib.Utils.greatest_common_divisor

--- Returns the lowest number that has both given numbers as divisors.
--- @param m integer
--- @param n integer
--- @return integer
function Tirislib.Utils.lowest_common_multiple(m, n)
    return (m ~= 0 and n ~= 0) and m * n / gcd(m, n) or 0
end

--- Returns the maximum metric distance between the given points.
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function Tirislib.Utils.maximum_metric_distance(x1, y1, x2, y2)
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
function Tirislib.Utils.n_metric_distance(n, x1, y1, x2, y2)
    return (abs(x1 - x2) ^ n + abs(y1 - y2) ^ n) ^ (1 / n)
end

--- Returns a bounding box around the given position with the given size.
--- @param position point2d
--- @param range number
--- @return BoundingBox
function Tirislib.Utils.get_range_bounding_box(position, range)
    local x = position.x
    local y = position.y

    return {{x - range, y - range}, {x + range, y + range}}
end

--- Returns the height and width of the given LuaEntity.
--- @param entity LuaEntity
--- @return number height
--- @return number width
function Tirislib.Utils.get_entity_size(entity)
    local selection_box = entity.selection_box
    local left_top = selection_box.left_top
    local right_bottom = selection_box.right_bottom

    return right_bottom.x - left_top.x, right_bottom.y - left_top.y
end

--- Returns the height and width of the given box.
--- @param box table
--- @return number height
--- @return number width
function Tirislib.Utils.get_box_size(box)
    local left_top = box.left_top
    local right_bottom = box.right_bottom

    return right_bottom.x - left_top.x, right_bottom.y - left_top.y
end

--- Adds a random integer offset to the given position.
--- @param position point2d
--- @param offset integer
function Tirislib.Utils.add_random_offset(position, offset)
    position.x = position.x + random(-offset, offset)
    position.y = position.y + random(-offset, offset)
end

--- Adds a random floating point offset to the given position.
--- @param position point2d
--- @param offset number
function Tirislib.Utils.add_random_float_offset(position, offset)
    position.x = position.x + random() * 2 * offset - offset
    position.y = position.y + random() * 2 * offset - offset
end

--- Gets a sprite "shift" vector from the entity's bounding box center coordinates and the sprite's size.
--- @param center table in tiles
--- @param height number in tiles
--- @param width number in tiles
--- @return table shift
function Tirislib.Utils.center_coordinates_to_shift(center, height, width)
    return {width / 2 - center[1], height / 2 - center[2]}
end

--- Updates a progress value inside the given table and returns the number of full progresses.
--- @param tbl table
--- @param key any
--- @param delta_progress number
--- @return integer full_progresses
function Tirislib.Utils.update_progress(tbl, key, delta_progress)
    local progress = tbl[key] + delta_progress
    local full_progress = floor(progress)
    tbl[key] = progress - full_progress
    return full_progress
end

--- Returns true if the game is currently in the data stage.
function Tirislib.Utils.is_data_stage()
    return (data ~= nil)
end

--- Returns true if the game is currently in the control stage.
function Tirislib.Utils.is_control_stage()
    return (data == nil)
end

--- Checks that it is not the control stage. Otherwise throws an error.\
--- Used to secure that specific functions can only be called during the initialisation stage, as they would otherwise be a cause for desyncs.
function Tirislib.Utils.desync_protection()
    if game then
        error(
            "A function that is supposed to only be called during the control initialization stage got called at a later stage."
        )
    end
end

--- Returns true, if the left hand version string represents a smaller version than the right hand one.
--- @param lh string
--- @param rh string
--- @return boolean
function Tirislib.Utils.version_is_smaller_than(lh, rh)
    local lh_splited = Tirislib.String.split(lh, ".")
    local rh_splited = Tirislib.String.split(rh, ".")

    local len = max(#lh_splited, #rh_splited)
    for i = 1, len do
        local lh_number = tonumber(lh_splited[i]) or 0
        local rh_number = tonumber(rh_splited[i]) or 0
        if lh_number < rh_number then
            return true
        elseif lh_number > rh_number then
            return false
        end
        -- continue when equal
    end

    return false
end
