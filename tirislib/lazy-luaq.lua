--- @class LazyLuaqQuery
--- Table query functions - with lazily evaluated iterators.<br>
--- Inspired by .NET's Linq.<br>
local LazyLuaq = {}
LazyLuaq.__index = LazyLuaq

Tirislib = Tirislib or {}
Tirislib.LazyLuaq = LazyLuaq

-- An iterator needs a 'move_next' and a 'reset' function.
-- I didn't feel like writing classes for every iterator and weirdly it was slower in my rudimentary performance tests.
-- That's why I'm just setting them in the table directly.

-- A LazyLuaqQuery iteration cannot be iterated 'twice' at the same time.
-- So nested iterations like this don't work:
--
-- for _, i in query:iterate() do
--     for _, i in query:iterate() do
--         -- this results in an endless iteration
--     end
-- end
--
-- This is pretty unfortunate, but a design decision to use the Query-Object to hold the iteration index.
-- The other option would have been to create a index-table for the iterations.
-- But this would limit the querys to arrays and not allow sequences where the indexes are important.
--
-- A workaround is to copy the query with the copy() function.

--- Resets the iterator to begin anew.
function LazyLuaq:reset()
    self.last_index = nil

    if not self.is_content_iterator then
        self.content:reset()
    end
end

--- Returns a copy of the given query.
--- @return LazyLuaqQuery
function LazyLuaq:copy()
    local ret = {}

    for i, v in pairs(self) do
        if getmetatable(v) == LazyLuaq then
            ret[i] = v:copy()
        else
            ret[i] = v
        end
    end

    setmetatable(ret, LazyLuaq)

    return ret
end

--- Returns a string representation of the query by materializing its elements.
--- @return string
function LazyLuaq:__tostring()
    return string.format("LazyLuaqQuery%s", serpent.line(self:to_table()))
end

---------------------------------------------------------------------------------------------------
--- Helper functions

local function pack(...)
    return {...}
end

local function lookup(elements)
    if getmetatable(elements) == LazyLuaq then
        return elements:to_lookup()
    else
        local ret = {}
        for _, value in pairs(elements) do
            ret[value] = true
        end
        return ret
    end
end

local function identity(...)
    return ...
end

---------------------------------------------------------------------------------------------------
--- Generators

local function from_move_next(self)
    -- the stop flag is there to make the iterator actually stop after a complete iteration
    -- otherwise the next-function would start anew when it gets nil as index
    if self.stop then
        return
    end

    local index, element = next(self.content, self.last_index)
    self.last_index = index
    if index == nil then
        self.stop = true
    end
    return index, element
end

local function from_reset(self)
    self.stop = false
    self.last_index = nil
end

--- Creates a LazyLuaqQuery that iterates over the given table.
--- @param tbl table
--- @return LazyLuaqQuery
function LazyLuaq.from(tbl)
    local ret = {
        content = tbl,
        is_content_iterator = true,
        stop = false,
        move_next = from_move_next,
        reset = from_reset
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

local function iterator_move_next(self)
    local last_index = self.last_index or self.initial_index
    local index, element = self.fn(self.param, last_index)

    if index == nil then
        return
    end

    if element == nil then
        element = index
        index = (self.last_index or self.initial_index or 0) + 1
    end

    self.last_index = index
    return index, element
end

--- Creates a LazyLuaqQuery from any iterator that can be used with the 'for ... in' syntax.<br>
--- It doesn't really work with iterators that have more than 2 returns. But those wouldn't necessarily work with LazyLuaq in general.<br>
--- If the iterator only returns one element, a numbered index is being added.<br>
--- Usage is like: `LazyLuaq.from_iterator(pairs(tbl))`
--- @param fn function? iterator-function
--- @param param any
--- @param initial_index any
--- @return LazyLuaqQuery
function LazyLuaq.from_iterator(fn, param, initial_index)
    local ret = {
        move_next = iterator_move_next,
        fn = fn,
        param = param,
        initial_index = initial_index,
        is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

---------------------------------------------------------------------------------------------------
--- Functions using the iterators
--- -> Execution is immediate

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
--- @param element any? Defaults to true
--- @return table
function LazyLuaq:to_lookup(element)
    if element == nil then
        element = true
    end

    local ret = {}

    for _, value in self:iterate() do
        ret[value] = element
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
--- If no seed is provided, the first element is used as the seed and accumulation starts from the second element.
--- @param aggregator function
--- @param seed any?
--- @param result_selector function?
--- @return any
function LazyLuaq:aggregate(aggregator, seed, result_selector)
    self:reset()

    local ret = seed
    if ret == nil then
        local _, first = self:move_next()
        ret = first
    end

    while true do
        local index, value = self:move_next()
        if index == nil then
            break
        end
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

--- Returns the number of elements in the sequence.<br>
--- This is calculated by iterating over the sequence.
--- @return integer
function LazyLuaq:count()
    local ret = 0

    for _ in self:iterate() do
        ret = ret + 1
    end

    return ret
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

--- Returns the last element (that fulfills the given condition - if given).
--- @param condition function?
function LazyLuaq:last(condition)
    if condition then
        local last_element
        for index, element in self:iterate() do
            if condition(element, index) then
                last_element = element
            end
        end
        return last_element
    else
        local last_element
        for _, element in self:iterate() do
            last_element = element
        end
        return last_element
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
function LazyLuaq:max_by(selector)
    self:reset()
    local candidate_index, candidate = self:move_next()
    if candidate == nil then
        return
    end
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

--- Returns a sequence with all maximal elements according to the selector function.
--- @param selector function?
--- @return LazyLuaqQuery
function LazyLuaq:maxima(selector)
    selector = selector or identity

    local ret = {}

    self:reset()
    local _, first_element = self:move_next()
    local max_value = selector(first_element)

    for index, element in self:iterate() do
        local value = selector(element, index)
        if value > max_value then
            ret = {}
            ret[#ret + 1] = element
            max_value = value
        elseif value == max_value then
            ret[#ret + 1] = element
        end
    end

    return LazyLuaq.from(ret)
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

--- Returns the minimum element in the sequence according to the selector function.
--- @param selector function
--- @return any min_element
--- @return any min_index
--- @return any min_value according to the selector
function LazyLuaq:min_by(selector)
    self:reset()
    local candidate_index, candidate = self:move_next()
    if candidate == nil then
        return
    end
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

--- Returns a sequence with all minimal elements according to the selector function.
--- @param selector function?
--- @return LazyLuaqQuery
function LazyLuaq:minima(selector)
    selector = selector or identity

    local ret = {}

    self:reset()
    local _, first_element = self:move_next()
    local min_value = selector(first_element)

    for index, element in self:iterate() do
        local value = selector(element, index)
        if value < min_value then
            ret = {}
            ret[#ret + 1] = element
            min_value = value
        elseif value == min_value then
            ret[#ret + 1] = element
        end
    end

    return LazyLuaq.from(ret)
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

--- Calls the given function for every element in the sequence.
--- @param fn function
function LazyLuaq:for_each(fn)
    for _, value in self:iterate() do
        fn(value)
    end
end

---------------------------------------------------------------------------------------------------
--- Functions extending the iterators
--- -> Execution is deferred

local function where_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if self.where_fn(value, index) then
            return index, value
        end
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

local function where_key_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if value[self.key] then
            return index, value
        end
    end
end

--- Filters the sequence of tables based on if the value for the given key is truthy.
--- @param key any
--- @return LazyLuaqQuery
function LazyLuaq:where_key(key)
    local ret = {
        content = self,
        key = key,
        move_next = where_key_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    local new_value, new_index = self.selector(value, index)
    return (new_index ~= nil and new_index or index), new_value
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

local function select_key_move_next(self)
    local index, value = self.content:move_next()

    if index == nil then
        return
    end

    value = value[self.key]
    return index, value
end

--- Selects the key of the table-elements of the sequence.
--- @param key any
--- @return LazyLuaqQuery
function LazyLuaq:select_key(key)
    local ret = {
        content = self,
        key = key,
        move_next = select_key_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_many_move_next(self)
    while true do
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
        self.tbl_index = nil
    end
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

local function choose_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        local condition_met, projection = self.selector(value, index)

        if condition_met then
            return index, projection
        end
    end
end

--- Filters and projects the elements of the sequence.
--- @param selector function should return a (boolean, any) tuple
--- @return LazyLuaqQuery
function LazyLuaq:choose(selector)
    local ret = {
        content = self,
        selector = selector,
        move_next = choose_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function choose_key_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        local kv = value[self.key]

        if kv then
            return index, kv
        end
    end
end

--- Filters and projects the sequence of tables by the value of the given key.
--- @param key any
--- @return LazyLuaqQuery
function LazyLuaq:choose_key(key)
    local ret = {
        content = self,
        key = key,
        move_next = choose_key_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function take_move_next(self)
    if self.i < self.n then
        self.i = self.i + 1
        return self.content:move_next()
    end
end

local function take_reset(self)
    self.content:reset()
    self.i = 0
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
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if self.i < self.n then
            self.i = self.i + 1
        else
            return index, value
        end
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
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if self.do_skip then
            if not self.condition(value, index) then
                self.do_skip = false
                return index, value
            end
        else
            return index, value
        end
    end
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
    if self.in_first then
        local index, value = self.content:move_next()

        if index ~= nil then
            return index, value
        end
        self.in_first = false
    end

    return self.second:move_next()
end

local function concat_reset(self)
    self.in_first = true
    self.content:reset()
    self.second:reset()
end

--- Combines the sequence with the given other sequence.
--- @param sequence LazyLuaqQuery|table|array
--- @return LazyLuaqQuery
function LazyLuaq:concat(sequence)
    if getmetatable(sequence) ~= LazyLuaq then
        sequence = LazyLuaq.from(sequence)
    end

    local ret = {
        content = self,
        second = sequence,
        in_first = true,
        move_next = concat_move_next,
        reset = concat_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

--- Prepends the given sequence's elements to this sequence.
--- @param sequence LazyLuaqQuery|table|array
--- @return LazyLuaqQuery
function LazyLuaq:prepend(sequence)
    if getmetatable(sequence) ~= LazyLuaq then
        sequence = LazyLuaq.from(sequence)
    end

    return sequence:concat(self)
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
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if not self.seen[value] then
            self.seen[value] = true
            return index, value
        end
    end
end

local function seen_deleting_reset(self)
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
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function distinct_by_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        local valueKey = self.selector(value)
        if not self.seen[valueKey] then
            self.seen[valueKey] = true
            return index, value
        end
    end
end

--- Returns the distinct elements of the sequence according to the given selector function.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:distinct_by(selector)
    local ret = {
        content = self,
        seen = {},
        selector = selector,
        move_next = distinct_by_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function duplicates_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if self.seen[value] then
            return index, value
        else
            self.seen[value] = true
        end
    end
end

--- Returns the duplicate elements of the sequence, skipping first occuring elements.
--- @return LazyLuaqQuery
function LazyLuaq:duplicates()
    local ret = {
        content = self,
        seen = {},
        move_next = duplicates_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function duplicates_by_move_next(self)
    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        local valueKey = self.selector(value)
        if self.seen[valueKey] then
            return index, value
        else
            self.seen[valueKey] = true
        end
    end
end

--- Returns the duplicate elements of the sequence according to the given selector function.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:duplicates_by(selector)
    local ret = {
        content = self,
        seen = {},
        selector = selector,
        move_next = duplicates_by_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function except_move_next(self)
    if self.lookup == nil then
        self.lookup = lookup(self.elements)
    end

    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if not self.lookup[value] then
            return index, value
        end
    end
end

local function lookup_deleting_reset(self)
    self.lookup = nil
    self.content:reset()
end

--- Produces the set difference of two sequences.
--- @param elements table|LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:except(elements)
    local ret = {
        content = self:distinct(),
        move_next = except_move_next,
        elements = elements,
        reset = lookup_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function lookup_with_selector(elements, selector)
    if getmetatable(elements) == LazyLuaq then
        return elements:select(selector):to_lookup()
    else
        local ret = {}
        for _, value in pairs(elements) do
            ret[selector(value)] = true
        end
        return ret
    end
end

local function except_by_move_next(self)
    if self.lookup == nil then
        self.lookup = lookup_with_selector(self.elements, self.selector)
    end

    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        local valueKey = self.selector(value)
        if not self.lookup[valueKey] then
            return index, value
        end
    end
end

--- Produces the set difference of two sequences according to the given selector function.
--- @param elements table|LazyLuaqQuery
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:except_by(elements, selector)
    local ret = {
        content = self:distinct_by(selector),
        move_next = except_by_move_next,
        elements = elements,
        selector = selector,
        reset = lookup_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

--- Produces the set union of two sequences.
--- @param elements table|LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:union(elements)
    if getmetatable(elements) ~= LazyLuaq then
        elements = LazyLuaq.from(elements)
    end
    local self_distinct = self:distinct()
    local elements_distinct = elements:distinct()

    return self_distinct:concat(elements_distinct:except(self_distinct))
end

--- Produces the set union of two sequences according to the given selector function.
--- @param elements table|LazyLuaqQuery
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:union_by(elements, selector)
    if getmetatable(elements) ~= LazyLuaq then
        elements = LazyLuaq.from(elements)
    end
    local self_distinct = self:distinct_by(selector)
    local elements_distinct = elements:distinct_by(selector)

    return self_distinct:concat(elements_distinct:except_by(self_distinct, selector))
end

local function intersect_move_next(self)
    if self.lookup == nil then
        self.lookup = lookup(self.elements)
    end

    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        if self.lookup[value] then
            return index, value
        end
    end
end

--- Produces the set intersection of two sequences.
--- @param elements table|LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:intersect(elements)
    local ret = {
        content = self:distinct(),
        move_next = intersect_move_next,
        elements = elements,
        reset = lookup_deleting_reset -- both just need to delete the lookup table
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function intersect_by_move_next(self)
    if self.lookup == nil then
        self.lookup = lookup_with_selector(self.elements, self.selector)
    end

    while true do
        local index, value = self.content:move_next()

        if index == nil then
            return
        end

        local valueKey = self.selector(value)
        if self.lookup[valueKey] then
            return index, value
        end
    end
end

--- Produces the set intersection of two sequences.
--- @param elements table|LazyLuaqQuery
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:intersect_by(elements, selector)
    local ret = {
        content = self:distinct_by(selector),
        move_next = intersect_by_move_next,
        elements = elements,
        selector = selector,
        reset = lookup_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

--- Produces the set symmetric difference of two sequences.
--- @param elements table|LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:symmetric_difference(elements)
    if getmetatable(elements) ~= LazyLuaq then
        elements = LazyLuaq.from(elements)
    end
    local left_distinct = self:distinct()
    local right_distinct = elements:distinct()

    local left = left_distinct:except(right_distinct)
    local right = right_distinct:copy():except(left_distinct)

    return left:concat(right)
end

--- Produces the set symmetric difference of two sequences according to the given selector function.
--- @param elements table|LazyLuaqQuery
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:symmetric_difference_by(elements, selector)
    if getmetatable(elements) ~= LazyLuaq then
        elements = LazyLuaq.from(elements)
    end
    local left_distinct = self:distinct_by(selector)
    local right_distinct = elements:distinct_by(selector)

    local left = left_distinct:except_by(right_distinct, selector)
    local right = right_distinct:copy():except_by(left_distinct, selector)

    return left:concat(right)
end

local function interleave_move_next(self)
    while true do
        -- if all sequences are finished, stop
        if #self.sequences == #self.finished_sequences then
            return
        end

        -- iterate the sequences first
        local sequence_index, sequence = next(self.sequences, self.last_sequence_index)
        self.last_sequence_index = sequence_index

        -- if sequence_index is nil, we reached the end of the sequences and loop around
        if sequence_index == nil or self.finished_sequences[sequence_index] then
            -- continue to loop around or skip finished sequences
        else
            local index, value = sequence:move_next()
            if index ~= nil then
                return index, value
            else
                -- this sequence is over, iterate to the next
                self.finished_sequences[sequence_index] = true
            end
        end
    end
end

local function interleave_reset(self)
    for i = 1, #self.sequences do
        self.sequences[i]:reset()
    end

    self.finished_sequences = {}
    self.last_sequence_index = nil
end

--- Interleaves the sequence with one or more others.
--- @param ... LazyLuaqQuery|table|array
--- @return LazyLuaqQuery
function LazyLuaq:interleave(...)
    local sequences = {self, ...}
    for i = 2, #sequences do
        local sequence = sequences[i]
        if getmetatable(sequence) ~= LazyLuaq then
            sequences[i] = LazyLuaq.from(sequence)
        end
    end

    local ret = {
        sequences = sequences,
        move_next = interleave_move_next,
        reset = interleave_reset,
        finished_sequences = {}
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function zip_move_next(self)
    local _, left = self.content:move_next()
    if left == nil then
        return
    end
    local _, right = self.second:move_next()
    if right ~= nil then
        self.i = self.i + 1
        return self.i, self.selector(left, right)
    end
end

local function zip_reset(self)
    self.i = 0
    self.content:reset()
    self.second:reset()
end

--- Combines two sequences element-wise until one ends.<br>
--- A selector function can be given. Otherwise returns an array with the 2 elements.
--- @param sequence LazyLuaqQuery|table|array
--- @param selector function?
--- @return LazyLuaqQuery
function LazyLuaq:zip(sequence, selector)
    selector = selector or pack

    if getmetatable(sequence) ~= LazyLuaq then
        sequence = LazyLuaq.from(sequence)
    end

    local ret = {
        content = self,
        second = sequence,
        selector = selector,
        i = 0,
        move_next = zip_move_next,
        reset = zip_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function pairwise_move_next(self)
    if self.last_element == nil then
        local _
        _, self.last_element = self.content:move_next()
    end

    local _, element = self.content:move_next()
    if element ~= nil then
        self.i = self.i + 1
        local previous = self.last_element
        self.last_element = element
        return self.i, self.selector(previous, element)
    end
end

local function pairwise_reset(self)
    self.last_element = nil
    self.i = 0
    self.content:reset()
end

--- Returns a sequence resulting from applying a function to each element with its previous element.
--- @param selector function?
--- @return LazyLuaqQuery
function LazyLuaq:pairwise(selector)
    selector = selector or pack

    local ret = {
        content = self,
        selector = selector,
        i = 0,
        last_element = nil,
        move_next = pairwise_move_next,
        reset = pairwise_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

---------------------------------------------------------------------------------------------------
--- Functions returning new iterators
--- -> Execution is immediate
---
local function pair_table(value, index)
    return {value, index}
end

local function unpack_pair_table(t)
    return t[1], t[2]
end

--- Immediately executes the iterator and returns a new LazyLuaqQuery with the results.<br>
--- Can be useful to cache the results of an expensive query that needs to be iterated multiple times.
--- @return LazyLuaqQuery
function LazyLuaq:cache_execution()
    local arr = self:select(pair_table):to_array()
    return LazyLuaq.from(arr):select(unpack_pair_table)
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
    local keys = {}
    for index, value in self:iterate() do
        local i = #array + 1
        array[i] = value
        keys[i] = selector(value, index)
    end

    -- Build an index array and sort that, so duplicate values don't collide
    local indices = {}
    for i = 1, #array do
        indices[i] = i
    end

    if comparator then
        table.sort(
            indices,
            function(a, b)
                return comparator(keys[a], keys[b])
            end
        )
    else
        table.sort(
            indices,
            function(a, b)
                return keys[a] < keys[b]
            end
        )
    end

    local sorted = {}
    for i = 1, #indices do
        sorted[i] = array[indices[i]]
    end

    return LazyLuaq.from(sorted)
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
    local keys = {}
    for index, value in self:iterate() do
        local i = #array + 1
        array[i] = value
        keys[i] = selector(value, index)
    end

    local indices = {}
    for i = 1, #array do
        indices[i] = i
    end

    table.sort(
        indices,
        function(a, b)
            return keys[a] > keys[b]
        end
    )

    local sorted = {}
    for i = 1, #indices do
        sorted[i] = array[indices[i]]
    end

    return LazyLuaq.from(sorted)
end

--- Sorts the sequence in ascending order and only returns up to the given count of top elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- @param count integer
--- @return LazyLuaqQuery
function LazyLuaq:partial_sort(count)
    local ret = {}

    for _, element in self:iterate() do
        local inserted = false
        for i = 1, #ret do
            if ret[i] < element then
                table.insert(ret, i, element)
                inserted = true
                break
            end
        end

        if #ret < count and not inserted then
            ret[#ret + 1] = element
        end

        if #ret > count then
            ret[#ret] = nil
        end
    end

    return LazyLuaq.from(ret)
end

--- Sorts the sequence in ascending order using the keys generated by the given selector function and only returns up to the given count of top elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- @param count integer
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:partial_sort_by(count, selector)
    local ret = {}
    local keys = {}

    for index, element in self:iterate() do
        local key = selector(element, index)
        local inserted = false
        for i = 1, #ret do
            if keys[i] < key then
                table.insert(ret, i, element)
                table.insert(keys, i, key)
                inserted = true
                break
            end
        end

        if #ret < count and not inserted then
            ret[#ret + 1] = element
            keys[#keys + 1] = key
        end

        if #ret > count then
            ret[#ret] = nil
            keys[#keys] = nil
        end
    end

    return LazyLuaq.from(ret)
end

--- Sorts the sequence in descending order and only returns up to the given count of elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- @param count integer
--- @return LazyLuaqQuery
function LazyLuaq:partial_sort_descending(count)
    local ret = {}

    for _, element in self:iterate() do
        local inserted = false
        for i = 1, #ret do
            if ret[i] > element then
                table.insert(ret, i, element)
                inserted = true
                break
            end
        end

        if #ret < count and not inserted then
            ret[#ret + 1] = element
        end

        if #ret > count then
            ret[#ret] = nil
        end
    end

    return LazyLuaq.from(ret)
end

--- Sorts the sequence in descending order using the keys generated by the given selector function and only returns up to the given count of top elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- @param count integer
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:partial_sort_by_descending(count, selector)
    local ret = {}
    local keys = {}

    for index, element in self:iterate() do
        local key = selector(element, index)
        local inserted = false
        for i = 1, #ret do
            if keys[i] > key then
                table.insert(ret, i, element)
                table.insert(keys, i, key)
                inserted = true
                break
            end
        end

        if #ret < count and not inserted then
            ret[#ret + 1] = element
            keys[#keys + 1] = key
        end

        if #ret > count then
            ret[#ret] = nil
            keys[#keys] = nil
        end
    end

    return LazyLuaq.from(ret)
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

local random = math.random

--- Shuffles the elements of this sequence.
function LazyLuaq:shuffle()
    local array = self:to_array()

    for i = #array, 2, -1 do
        local j = random(i)
        array[i], array[j] = array[j], array[i]
    end

    return LazyLuaq.from(array)
end

local function reverse_move_next(self)
    local index = self.last_index
    if index == nil then
        index = #self.content
    end

    if index > 0 then
        self.last_index = index - 2
        return self.content[index], self.content[index - 1]
    end
end

--- Returns the sequence in reversed order.
--- @return LazyLuaqQuery
function LazyLuaq:reverse()
    local array = {}

    for k, v in self:iterate() do
        array[#array + 1] = v
        array[#array + 1] = k
    end

    local ret = {
        content = array,
        move_next = reverse_move_next,
        is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

--- Normalizes the (numeric) sequence.<br>
--- Meaning the sum of all elements will be (close to) 1.
--- @return LazyLuaqQuery
function LazyLuaq:normalize()
    local sum = self:sum()

    if sum > 0 then
        return self:select(
            function(element)
                return element / sum
            end
        )
    else
        return self
    end
end
