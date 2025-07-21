--- @class LazyLuaqQuery
--- Table query functions - with lazily evaluated iterators.<br>
--- Inspired by .NET's Linq.<br>
LazyLuaq = {}
LazyLuaq.__index = LazyLuaq

-- An iterator needs a  'move_next' and a 'reset' function.
-- I didn't feel like writing classes for every iterator and weirdly it was slower in my rudimentary performance tests.
-- That's why I'm just setting them in the table directly.

--- Standard-Iterator using next
--- @return any index
--- @return any value
function LazyLuaq:move_next()
    local index, value = next(self.content, self.last_index)
    self.last_index = index
    return index, value
end

--- Resets the iterator to begin anew.
function LazyLuaq:reset()
    self.last_index = nil

    if not self.is_content_iterator then
        self.content:reset()
    end
end

--- Creates a LazyLuaqQuery that iterates over the given table.
--- @param tbl table
--- @return LazyLuaqQuery
function LazyLuaq.from(tbl)
    local ret = {
        content = tbl,
        is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function move_next_range(self)
    local count = self.last_index or 0
    local value = self.start_value + count * self.step

    if value <= self.end_value then
        self.last_index = count + 1
        return count + 1, value
    end
end

--- Creates a LazyLuaqQuery with the number range from the given starting value to the given end value.
--- @param start_value number
--- @param end_value number
--- @param step number?
--- @return LazyLuaqQuery
function LazyLuaq.range(start_value, end_value, step)
    step = step or 1

    local ret = {
        start_value = start_value,
        end_value = end_value,
        step = step,
        move_next = move_next_range,
        is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function move_next_repeat_element(self)
    local count = self.last_index or 0

    if count < self.times then
        self.last_index = count + 1
        return count + 1, self.element
    end
end

--- Creates a LazyLuaqQuery that repeats the given element the given number of times.
--- @param element any
--- @param times number
--- @return LazyLuaqQuery
function LazyLuaq.repeat_element(element, times)
    local ret = {
        element = element,
        times = times,
        move_next = move_next_repeat_element,
        is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function move_next_repeat_function(self)
    local count = self.last_index or 0

    if count < self.times then
        self.last_index = count + 1
        return count + 1, self.generator()
    end
end

--- Creates a LazyLuaqQuery that repeats the given generator function the given number of times.
--- @param generator function
--- @param times number
--- @return LazyLuaqQuery
function LazyLuaq.repeat_function(generator, times)
    local ret = {
        generator = generator,
        times = times,
        move_next = move_next_repeat_function,
        is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

--- Iterator for use with the 'for .. in' syntax.
--- @return function move_next
--- @return LazyLuaqQuery
function LazyLuaq:iterate()
    self:reset()
    return self.move_next, self
end

--- Returns an array of the resulting sequence.
--- @return array
function LazyLuaq:to_array()
    local ret = {}

    for _, value in self:iterate() do
        ret[#ret + 1] = value
    end

    return ret
end

--- Just dumps the (index, value)-pairs of the sequence into a new table.
--- @return table
function LazyLuaq:to_table()
    local ret = {}

    for index, value in self:iterate() do
        ret[index] = value
    end

    return ret
end

--- Returns a lookup table with the values of the sequence.
--- @return table
function LazyLuaq:to_lookup()
    local ret = {}

    for _, value in self:iterate() do
        ret[value] = true
    end

    return ret
end

--- Creates a dictionary according to the value-selector and index-selector
--- @param value_selector function?
--- @param index_selector function?
--- @return table
function LazyLuaq:to_dictionary(value_selector, index_selector)
    local ret = {}

    for index, value in self:iterate() do
        index = index_selector and index_selector(value, index) or index
        value = value_selector and value_selector(value, index) or value
        ret[index] = value
    end

    return ret
end

--- Applies an accumulator function over the sequence.
--- @param seed any?
--- @param aggregator function
--- @param result_selector function?
--- @return any
function LazyLuaq:aggregate(seed, aggregator, result_selector)
    local ret = seed
    if ret == nil then
        ret = self:first()
    end

    for _, value in self:iterate() do
        ret = aggregator(ret, value)
    end

    if result_selector then
        ret = result_selector(ret)
    end

    return ret
end

--- Returns true if there is at least one element in the query (that fulfills the given condition - if given).
--- @param condition function? condition
--- @return boolean
function LazyLuaq:any(condition)
    if condition then
        for _, value in self:iterate() do
            if condition(value) then
                return true
            end
        end
        return false
    else
        self:reset()
        return self:move_next() ~= nil
    end
end

--- Checks if all elements in the sequence fulfill the given condition.
--- @param condition function
--- @return boolean
function LazyLuaq:all(condition)
    for index, value in self:iterate() do
        if not condition(value, index) then
            return false
        end
    end
    return true
end

--- Returns true if the given element appears in the sequence. Uses default comparator.
--- @param element any
--- @return boolean
function LazyLuaq:contains(element)
    for _, value in self:iterate() do
        if value == element then
            return true
        end
    end

    return false
end

--- Returns the first element (that fulfills the given condition - if given).
--- @param condition function?
--- @return any first_element
function LazyLuaq:first(condition)
    if condition then
        for index, value in self:iterate() do
            if condition(value, index) then
                return value
            end
        end
    else
        self:reset()
        local _, value = self:move_next()
        return value
    end
end

--- Returns the maximum value in the sequence.
--- @return any max_value
--- @return any max_index
function LazyLuaq:max()
    self:reset()
    local candidate_index, candidate = self:move_next()

    for index, value in self:iterate() do
        if value > candidate then
            candidate = value
            candidate_index = index
        end
    end

    return candidate, candidate_index
end

--- Returns the maximum element in the sequence according to the selector function.
--- @param selector function
--- @return any max_element
--- @return any max_index
--- @return any max_value according to the selector
function LazyLuaq:maxBy(selector)
    self:reset()
    local candidate_index, candidate = self:move_next()
    local candidate_value = selector(candidate, candidate_index)

    for index, element in self:iterate() do
        local value = selector(element, index)
        if value > candidate_value then
            candidate = element
            candidate_index = index
            candidate_value = value
        end
    end

    return candidate, candidate_index, candidate_value
end

--- Returns the minimum value in the sequence.
--- @return any min_value
--- @return any min_index
function LazyLuaq:min()
    self:reset()
    local candidate_index, candidate = self:move_next()

    for index, value in self:iterate() do
        if value < candidate then
            candidate = value
            candidate_index = index
        end
    end

    return candidate, candidate_index
end

--- Returns the maximum element in the sequence according to the selector function.
--- @param selector function
--- @return any min_element
--- @return any min_index
--- @return any min_value according to the selector
function LazyLuaq:minBy(selector)
    self:reset()
    local candidate_index, candidate = self:move_next()
    local candidate_value = selector(candidate, candidate_index)

    for index, element in self:iterate() do
        local value = selector(element, index)
        if value < candidate_value then
            candidate = element
            candidate_index = index
            candidate_value = value
        end
    end

    return candidate, candidate_index, candidate_value
end

--- Computes the average of the sequence. A selector function can be given.
--- @param selector function?
--- @return number average
function LazyLuaq:average(selector)
    local sum = 0
    local count = 0

    if selector then
        for _, value in self:iterate() do
            sum = sum + selector(value)
            count = count + 1
        end
    else
        for _, value in self:iterate() do
            sum = sum + value
            count = count + 1
        end
    end

    return sum / count
end

--- Computes the sum of all elements in the sequence.
--- @return number
function LazyLuaq:sum()
    local ret = 0

    for _, value in self:iterate() do
        ret = ret + value
    end

    return ret
end

--- Computes the product of all elements in the sequence.
--- @return number
function LazyLuaq:product()
    local ret = 1

    for _, value in self:iterate() do
        ret = ret * value
    end

    return ret
end

local function where_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    if self.where_fn(value) then
        return index, value
    else
        return self:move_next()
    end
end

--- Filters the sequence based on the condition.
--- @param condition any
--- @return LazyLuaqQuery
function LazyLuaq:where(condition)
    local ret = {
        content = self,
        where_fn = condition,
        move_next = where_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    value = self.selector(value, index)
    return index, value
end

--- Projects all elements of the sequence.
--- @param selector any
--- @return LazyLuaqQuery
function LazyLuaq:select(selector)
    local ret = {
        content = self,
        selector = selector,
        move_next = select_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_many_move_next(self)
    local tbl = self.tbl
    if tbl ~= nil then
        local index, value = next(tbl, self.tbl_index)
        self.tbl_index = index

        if index ~= nil then
            return index, value
        end
    end

    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    self.tbl = self.selector(value, index)
    return select_many_move_next(self)
end

local function select_many_reset(self)
    self.tbl = nil
    self.tbl_index = nil
    self.content:reset()
end

--- Projects all elements of the sequence to another collection and flattens them.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:select_many(selector)
    local ret = {
        content = self,
        selector = selector,
        move_next = select_many_move_next,
        reset = select_many_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function take_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    if self.i < self.n then
        self.i = self.i + 1
        return index, value
    end
end

local function take_reset(self)
    self.i = 0
    self.content:reset()
end

--- Takes the first n elements from the sequence.
--- @param n number
--- @return LazyLuaqQuery
function LazyLuaq:take(n)
    local ret = {
        content = self,
        i = 0,
        n = n,
        move_next = take_move_next,
        reset = take_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function take_while_move_next(self)
    local index, value = self.content:move_next()

    if index == nil or not self.do_take then
        return
    end

    local still_take = self.condition(value, index)
    if still_take then
       return index, value
    else
        self.do_take = false
    end
end

local function take_while_reset(self)
    self.do_take = true
    self.content:reset()
end

--- Takes elements from the sequence until the given condition isn't fulfilled.
--- @param condition function
--- @return LazyLuaqQuery
function LazyLuaq:take_while(condition)
    local ret = {
        content = self,
        do_take = true,
        condition = condition,
        move_next = take_while_move_next,
        reset = take_while_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function skip_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    if self.i < self.n then
        self.i = self.i + 1
        return skip_move_next(self)
    else
        return index, value
    end
end

local function skip_reset(self)
    self.i = 0
    self.content:reset()
end

--- Skips the first n elements from the sequence.
--- @param n number
--- @return LazyLuaqQuery
function LazyLuaq:skip(n)
    local ret = {
        content = self,
        i = 0,
        n = n,
        move_next = skip_move_next,
        reset = skip_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function skip_while_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    if self.do_skip then
        local still_skip = self.condition(value, index)

        if still_skip then
            return skip_while_move_next(self)
        else
            self.do_skip = false
        end
    end

    return index, value
end

local function skip_while_reset(self)
    self.do_skip = true
    self.content:reset()
end

--- Skips the elements of the sequence until the given condition isn't fulfilled.
--- @param condition function
--- @return LazyLuaqQuery
function LazyLuaq:skip_while(condition)
    local ret = {
        content = self,
        do_skip = true,
        condition = condition,
        move_next = skip_while_move_next,
        reset = skip_while_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function concat_move_next(self)
    local index, value = self.left_content:move_next()

    if index ~= nil then
        return index, value
    end

    return self.right_content:move_next()
end

local function concat_reset(self)
    self.left_content:reset()
    self.right_content:reset()
end

--- Combines the sequence with the given other LazyLuaqQuery sequence.
--- @param sequence LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:concat(sequence)
    local ret = {
        left_content = self,
        right_content = sequence,
        move_next = concat_move_next,
        reset = concat_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function chunk_move_next(self)
    local ret = {}
    local count = 0
    local chunk_size = self.chunk_size
    local index, value

    while count < chunk_size do
        index, value = self.content:move_next()

        if index == nil then
            if count > 0 then
                break
            else
                return
            end
        end

        ret[index] = value
        count = count + 1
    end

    self.chunk_index = self.chunk_index + 1
    return self.chunk_index, LazyLuaq.from(ret)
end

local function chunk_reset(self)
    self.chunk_index = 0
    self.content:reset()
end

--- Splits the sequence into chunks of the given number of elements.
--- @param size number
--- @return LazyLuaqQuery
function LazyLuaq:chunk(size)
    if size <= 0 then
        error("Chunk size must be a positive number")
    end

    local ret = {
        content = self,
        chunk_size = size,
        chunk_index = 0,
        move_next = chunk_move_next,
        reset = chunk_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function distinct_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    if self.seen[value] then
        return distinct_move_next(self)
    else
        self.seen[value] = true
        return index, value
    end
end

local function distinct_reset(self)
    self.seen = {}
    self.content:reset()
end

--- Returns the distinct elements of the sequence, skipping returning elements.
--- @return LazyLuaqQuery
function LazyLuaq:distinct()
    local ret = {
        content = self,
        seen = {},
        move_next = distinct_move_next,
        reset = distinct_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function distinct_by_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    local valueKey = self.selector(value)
    if self.seen[valueKey] then
        return distinct_by_move_next(self)
    else
        self.seen[valueKey] = true
        return index, value
    end
end

--- Returns the distinct elements of the sequence according to the given selector function.
---@param selector function
---@return LazyLuaqQuery
function LazyLuaq:distinct_by(selector)
    local ret = {
        content = self,
        seen = {},
        selector = selector,
        move_next = distinct_by_move_next,
        reset = distinct_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

--- Sorts the sequence in ascending order.
--- @param comparator function?
--- @return LazyLuaqQuery
function LazyLuaq:order(comparator)
    local array = self:to_array()

    table.sort(array, comparator)

    return LazyLuaq.from(array)
end

--- Sorts the sequence in ascending order using the keys of the given selector function.
--- @param selector function
--- @param comparator function?
--- @return LazyLuaqQuery
function LazyLuaq:order_by(selector, comparator)
    local array = {}
    local key_lookup = {}
    for index, value in self:iterate() do
        array[#array + 1] = value
        key_lookup[value] = selector(value, index)
    end

    if comparator then
        table.sort(
            array,
            function(a, b)
                return comparator(key_lookup[a], key_lookup[b])
            end
        )
    else
        table.sort(
            array,
            function(a, b)
                return key_lookup[a] < key_lookup[b]
            end
        )
    end

    return LazyLuaq.from(array)
end

--- Sorts the sequence in descending order.
--- @return LazyLuaqQuery
function LazyLuaq:order_descending()
    local array = self:to_array()

    table.sort(
        array,
        function(a, b)
            return a > b
        end
    )

    return LazyLuaq.from(array)
end

--- Sorts the sequence in descending order using the keys of the given selector function.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:order_by_descending(selector)
    local array = {}
    local key_lookup = {}
    for index, value in self:iterate() do
        array[#array + 1] = value
        key_lookup[value] = selector(value, index)
    end

    table.sort(
        array,
        function(a, b)
            return key_lookup[a] > key_lookup[b]
        end
    )

    return LazyLuaq.from(array)
end

--- Groups the sequence by the keys of the given selector function.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:group_by(selector)
    local groups = {}

    for index, value in self:iterate() do
        local key = selector(value, index)
        local group = groups[key]
        if not group then
            groups[key] = {}
            group = groups[key]
        end

        group[index] = value
    end

    for key, group in pairs(groups) do
        groups[key] = LazyLuaq.from(group)
    end

    return LazyLuaq.from(groups)
end
