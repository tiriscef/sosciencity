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

-- Index semantics
--
-- Unlike .NET's IEnumerable which carries only values, every element in a LazyLuaqQuery is an
-- (index, value) pair - because that is what Lua's next() yields and discarding the index would
-- make the library useless for dictionary-like tables.
--
-- Index semantics: operations preserve the original index by default.
-- Exceptions are marked "Index-replacing" in their docstrings:
--   zip, pairwise    - merge two sequences into new composite elements.
--   order*, shuffle  - position after reordering becomes the new index.
--   partial_sort*    - same as above.
--
-- Terminal functions let you choose what to do with the index:
--   to_array()  - discards indices, collects values into a consecutive array.
--   to_table()  - preserves the index->value mapping as-is. 
--                 Duplicate indices silently overwrite!

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

-- Internal state fields on query objects are prefixed with _ to avoid shadowing LazyLuaq methods.
-- Public iterator protocol fields are move_next and reset (no prefix).

--- Resets the iterator to begin anew.
function LazyLuaq:reset()
    self._last_index = nil

    if not self._is_content_iterator then
        self._content:reset()
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
    if self._stop then
        return
    end

    local index, element = next(self._content, self._last_index)
    self._last_index = index
    if index == nil then
        self._stop = true
    end
    return index, element
end

local function from_reset(self)
    self._stop = false
    self._last_index = nil
end

--- Creates a LazyLuaqQuery that iterates over the given table.
--- @param tbl table
--- @return LazyLuaqQuery
function LazyLuaq.from(tbl)
    local ret = {
        _content = tbl,
        _is_content_iterator = true,
        _stop = false,
        move_next = from_move_next,
        reset = from_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function from_keyset_move_next(self)
    if self._stop then return end
    local key = next(self._content, self._last_index)
    self._last_index = key
    if key == nil then
        self._stop = true
        return
    end
    self._seq = self._seq + 1
    return self._seq, key
end

local function from_keyset_reset(self)
    self._stop = false
    self._last_index = nil
    self._seq = 0
end

--- Creates a LazyLuaqQuery that iterates over the keys of a lookup table (keyset).
--- Unlike from(), which yields (key, value), from_keyset() yields (i, key),
--- so callbacks receive the key as their first argument. Useful for sets like {[name]=true}.
--- @param tbl table
--- @return LazyLuaqQuery
function LazyLuaq.from_keyset(tbl)
    local ret = {
        _content = tbl,
        _is_content_iterator = true,
        _stop = false,
        _seq = 0,
        move_next = from_keyset_move_next,
        reset = from_keyset_reset
    }
    setmetatable(ret, LazyLuaq)
    return ret
end

local function move_next_range(self)
    local count = self._last_index or 0
    local value = self._start_value + count * self._step

    if value <= self._end_value then
        self._last_index = count + 1
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
        _start_value = start_value,
        _end_value = end_value,
        _step = step,
        move_next = move_next_range,
        _is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function move_next_repeat_element(self)
    local count = self._last_index or 0

    if count < self._times then
        self._last_index = count + 1
        return count + 1, self._element
    end
end

--- Creates a LazyLuaqQuery that repeats the given element the given number of times.
--- @param element any
--- @param times number
--- @return LazyLuaqQuery
function LazyLuaq.repeat_element(element, times)
    local ret = {
        _element = element,
        _times = times,
        move_next = move_next_repeat_element,
        _is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function move_next_repeat_function(self)
    local count = self._last_index or 0

    if count < self._times then
        self._last_index = count + 1
        return count + 1, self._generator()
    end
end

--- Creates a LazyLuaqQuery that repeats the given generator function the given number of times.
--- @param generator function
--- @param times number
--- @return LazyLuaqQuery
function LazyLuaq.repeat_function(generator, times)
    local ret = {
        _generator = generator,
        _times = times,
        move_next = move_next_repeat_function,
        _is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function iterator_move_next(self)
    local pos = (self._cache_pos or 0) + 1

    if pos <= #self._cache_indices then
        self._cache_pos = pos
        return self._cache_indices[pos], self._cache_values[pos]
    end

    if self._iterator_exhausted then
        return
    end

    local real_last = self._real_last_index or self._initial_index
    local index, element = self._fn(self._param, real_last)

    if index == nil then
        self._iterator_exhausted = true
        return
    end

    if element == nil then
        element = index
        index = (self._real_last_index or self._initial_index or 0) + 1
    end

    self._real_last_index = index
    local cache_pos = #self._cache_indices + 1
    self._cache_indices[cache_pos] = index
    self._cache_values[cache_pos] = element
    self._cache_pos = cache_pos
    return index, element
end

local function iterator_reset(self)
    self._cache_pos = nil
    -- _real_last_index, _iterator_exhausted and the cache arrays are preserved:
    -- reset rewinds to the start of the cache without re-calling the iterator.
end

--- Creates a LazyLuaqQuery from any iterator that can be used with the 'for ... in' syntax.<br>
--- It doesn't really work with iterators that have more than 2 returns. But those wouldn't necessarily work with LazyLuaq in general.<br>
--- If the iterator only returns one element, a numbered index is being added.<br>
--- Usage is like: `LazyLuaq.from_iterator(pairs(tbl))`<br>
--- **Caching:** elements are cached on first pass. Resetting rewinds to the cached data without
--- re-calling the iterator, so mutations to the underlying source after the first pass are not visible.
--- This is intentional: many iterators are single-pass and cannot be restarted.
--- @param fn function? iterator-function
--- @param param any
--- @param initial_index any
--- @return LazyLuaqQuery
function LazyLuaq.from_iterator(fn, param, initial_index)
    local ret = {
        move_next = iterator_move_next,
        reset = iterator_reset,
        _fn = fn,
        _param = param,
        _initial_index = initial_index,
        _cache_indices = {},
        _cache_values = {},
        _is_content_iterator = true
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
--- Duplicate indices silently overwrite!
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
        local new_index = index_selector and index_selector(value, index) or index
        local new_value = value_selector and value_selector(value, index) or value
        ret[new_index] = new_value
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

--- Returns a table mapping keys (produced by the selector) to their occurrence count in the sequence.
--- @param selector function
--- @return table
function LazyLuaq:count_by(selector)
    local ret = {}
    for index, value in self:iterate() do
        local key = selector(value, index)
        ret[key] = (ret[key] or 0) + 1
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

--- Returns the element at the given 1-based position, or nil if the sequence is shorter.
--- @param n integer
--- @return any
function LazyLuaq:element_at(n)
    local i = 0
    for _, value in self:iterate() do
        i = i + 1
        if i == n then
            return value
        end
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

--- Returns the single element in the sequence (that fulfills the condition - if given).
--- Errors if the sequence contains zero or more than one matching element.
--- @param condition function?
--- @return any
function LazyLuaq:single(condition)
    self:reset()

    if condition then
        local result
        local found = false
        while true do
            local index, value = self:move_next()
            if index == nil then break end
            if condition(value, index) then
                if found then error("single: sequence contains more than one matching element") end
                result = value
                found = true
            end
        end
        if not found then error("single: sequence contains no matching element") end
        return result
    else
        local _, first = self:move_next()
        if first == nil then error("single: sequence is empty") end
        local _, second = self:move_next()
        if second ~= nil then error("single: sequence contains more than one element") end
        return first
    end
end

--- Returns the maximum value in the sequence.
--- @return any max_value
--- @return any max_index
function LazyLuaq:max()
    local candidate_index, candidate

    for index, value in self:iterate() do
        if candidate == nil or value > candidate then
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
    local candidate_index, candidate, candidate_value

    for index, element in self:iterate() do
        local value = selector(element, index)
        if candidate == nil or value > candidate_value then
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
    local max_value

    for index, element in self:iterate() do
        local value = selector(element, index)
        if max_value == nil or value > max_value then
            ret = {[index] = element}
            max_value = value
        elseif value == max_value then
            ret[index] = element
        end
    end

    return LazyLuaq.from(ret)
end

--- Returns the minimum value in the sequence.
--- @return any min_value
--- @return any min_index
function LazyLuaq:min()
    local candidate_index, candidate

    for index, value in self:iterate() do
        if candidate == nil or value < candidate then
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
    local candidate_index, candidate, candidate_value

    for index, element in self:iterate() do
        local value = selector(element, index)
        if candidate == nil or value < candidate_value then
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
    local min_value

    for index, element in self:iterate() do
        local value = selector(element, index)
        if min_value == nil or value < min_value then
            ret = {[index] = element}
            min_value = value
        elseif value == min_value then
            ret[index] = element
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
        for index, value in self:iterate() do
            sum = sum + selector(value, index)
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
    for index, value in self:iterate() do
        fn(value, index)
    end
end

---------------------------------------------------------------------------------------------------
--- Functions extending the iterators
--- -> Execution is deferred

local function tap_move_next(self)
    local index, value = self._content:move_next()
    if index ~= nil then
        self._fn(value, index)
        return index, value
    end
end

--- Calls the given function for every element as it passes through without modifying the sequence.
--- @param fn function
--- @return LazyLuaqQuery
function LazyLuaq:tap(fn)
    local ret = {
        _content = self,
        _fn = fn,
        move_next = tap_move_next
    }
    setmetatable(ret, LazyLuaq)
    return ret
end

local function where_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if self._where_fn(value, index) then
            return index, value
        end
    end
end

--- Filters the sequence based on the condition.
--- @param condition any
--- @return LazyLuaqQuery
function LazyLuaq:where(condition)
    local ret = {
        _content = self,
        _where_fn = condition,
        move_next = where_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function where_key_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if value[self._key] then
            return index, value
        end
    end
end

--- Filters the sequence of tables based on if the value for the given key is truthy.
--- @param key any
--- @return LazyLuaqQuery
function LazyLuaq:where_key(key)
    local ret = {
        _content = self,
        _key = key,
        move_next = where_key_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_move_next(self)
    local index, value = self._content:move_next()

    if index == nil then
        return
    end

    local new_value, new_index = self._selector(value, index)
    return (new_index ~= nil and new_index or index), new_value
end

--- Projects all elements of the sequence.
--- If the selector returns a second value, it replaces the index.
--- @param selector any
--- @return LazyLuaqQuery
function LazyLuaq:select(selector)
    local ret = {
        _content = self,
        _selector = selector,
        move_next = select_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_key_move_next(self)
    local index, value = self._content:move_next()

    if index == nil then
        return
    end

    value = value[self._key]
    return index, value
end

--- Selects the key of the table-elements of the sequence.
--- @param key any
--- @return LazyLuaqQuery
function LazyLuaq:select_key(key)
    local ret = {
        _content = self,
        _key = key,
        move_next = select_key_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function select_many_move_next(self)
    while true do
        local tbl = self._tbl
        if tbl ~= nil then
            local index, value
            if getmetatable(tbl) == LazyLuaq then
                index, value = tbl:move_next()
            else
                index, value = next(tbl, self._tbl_index)
                self._tbl_index = index
            end

            if index ~= nil then
                return index, value
            end
        end

        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        self._tbl = self._selector(value, index)
        self._tbl_index = nil
    end
end

local function select_many_reset(self)
    self._tbl = nil
    self._tbl_index = nil
    self._content:reset()
end

--- Projects all elements of the sequence to another collection and flattens them.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:select_many(selector)
    local ret = {
        _content = self,
        _selector = selector,
        move_next = select_many_move_next,
        reset = select_many_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function choose_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        local condition_met, projection = self._selector(value, index)

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
        _content = self,
        _selector = selector,
        move_next = choose_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function choose_key_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        local kv = value[self._key]

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
        _content = self,
        _key = key,
        move_next = choose_key_move_next
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function take_move_next(self)
    if self._i < self._n then
        self._i = self._i + 1
        return self._content:move_next()
    end
end

local function take_reset(self)
    self._content:reset()
    self._i = 0
end

--- Takes the first n elements from the sequence.
--- @param n number
--- @return LazyLuaqQuery
function LazyLuaq:take(n)
    local ret = {
        _content = self,
        _i = 0,
        _n = n,
        move_next = take_move_next,
        reset = take_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function take_while_move_next(self)
    local index, value = self._content:move_next()

    if index == nil or not self._do_take then
        return
    end

    local still_take = self._condition(value, index)
    if still_take then
        return index, value
    else
        self._do_take = false
    end
end

local function take_while_reset(self)
    self._do_take = true
    self._content:reset()
end

--- Takes elements from the sequence until the given condition isn't fulfilled.
--- @param condition function
--- @return LazyLuaqQuery
function LazyLuaq:take_while(condition)
    local ret = {
        _content = self,
        _do_take = true,
        _condition = condition,
        move_next = take_while_move_next,
        reset = take_while_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function skip_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if self._i < self._n then
            self._i = self._i + 1
        else
            return index, value
        end
    end
end

local function skip_reset(self)
    self._i = 0
    self._content:reset()
end

--- Skips the first n elements from the sequence.
--- @param n number
--- @return LazyLuaqQuery
function LazyLuaq:skip(n)
    local ret = {
        _content = self,
        _i = 0,
        _n = n,
        move_next = skip_move_next,
        reset = skip_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function skip_while_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if self._do_skip then
            if not self._condition(value, index) then
                self._do_skip = false
                return index, value
            end
        else
            return index, value
        end
    end
end

local function skip_while_reset(self)
    self._do_skip = true
    self._content:reset()
end

--- Skips the elements of the sequence until the given condition isn't fulfilled.
--- @param condition function
--- @return LazyLuaqQuery
function LazyLuaq:skip_while(condition)
    local ret = {
        _content = self,
        _do_skip = true,
        _condition = condition,
        move_next = skip_while_move_next,
        reset = skip_while_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function concat_move_next(self)
    if self._in_first then
        local index, value = self._content:move_next()

        if index ~= nil then
            return index, value
        end
        self._in_first = false
    end

    return self._second:move_next()
end

local function concat_reset(self)
    self._in_first = true
    self._content:reset()
    self._second:reset()
end

--- Combines the sequence with the given other sequence.
--- @param sequence LazyLuaqQuery|table|array
--- @return LazyLuaqQuery
function LazyLuaq:concat(sequence)
    if getmetatable(sequence) ~= LazyLuaq then
        sequence = LazyLuaq.from(sequence)
    end

    local ret = {
        _content = self,
        _second = sequence,
        _in_first = true,
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
    local chunk_size = self._chunk_size
    local index, value

    while count < chunk_size do
        index, value = self._content:move_next()

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

    self._chunk_index = self._chunk_index + 1
    return self._chunk_index, LazyLuaq.from(ret)
end

local function chunk_reset(self)
    self._chunk_index = 0
    self._content:reset()
end

--- Splits the sequence into chunks of the given number of elements.
--- @param size number
--- @return LazyLuaqQuery
function LazyLuaq:chunk(size)
    if size <= 0 then
        error("Chunk size must be a positive number")
    end

    local ret = {
        _content = self,
        _chunk_size = size,
        _chunk_index = 0,
        move_next = chunk_move_next,
        reset = chunk_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function distinct_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if not self._seen[value] then
            self._seen[value] = true
            return index, value
        end
    end
end

local function seen_deleting_reset(self)
    self._seen = {}
    self._content:reset()
end

--- Returns the distinct elements of the sequence, skipping returning elements.
--- @return LazyLuaqQuery
function LazyLuaq:distinct()
    local ret = {
        _content = self,
        _seen = {},
        move_next = distinct_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function distinct_by_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        local valueKey = self._selector(value)
        if not self._seen[valueKey] then
            self._seen[valueKey] = true
            return index, value
        end
    end
end

--- Returns the distinct elements of the sequence according to the given selector function.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:distinct_by(selector)
    local ret = {
        _content = self,
        _seen = {},
        _selector = selector,
        move_next = distinct_by_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function duplicates_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if self._seen[value] then
            return index, value
        else
            self._seen[value] = true
        end
    end
end

--- Returns the duplicate elements of the sequence, skipping first occuring elements.
--- @return LazyLuaqQuery
function LazyLuaq:duplicates()
    local ret = {
        _content = self,
        _seen = {},
        move_next = duplicates_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function duplicates_by_move_next(self)
    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        local valueKey = self._selector(value)
        if self._seen[valueKey] then
            return index, value
        else
            self._seen[valueKey] = true
        end
    end
end

--- Returns the duplicate elements of the sequence according to the given selector function.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:duplicates_by(selector)
    local ret = {
        _content = self,
        _seen = {},
        _selector = selector,
        move_next = duplicates_by_move_next,
        reset = seen_deleting_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function except_move_next(self)
    if self._lookup == nil then
        self._lookup = lookup(self._elements)
    end

    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if not self._lookup[value] then
            return index, value
        end
    end
end

local function lookup_deleting_reset(self)
    self._lookup = nil
    self._content:reset()
end

--- Produces the set difference of two sequences.
--- @param elements table|LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:except(elements)
    local ret = {
        _content = self:distinct(),
        move_next = except_move_next,
        _elements = elements,
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
    if self._lookup == nil then
        self._lookup = lookup_with_selector(self._elements, self._selector)
    end

    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        local valueKey = self._selector(value)
        if not self._lookup[valueKey] then
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
        _content = self:distinct_by(selector),
        move_next = except_by_move_next,
        _elements = elements,
        _selector = selector,
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
    if self._lookup == nil then
        self._lookup = lookup(self._elements)
    end

    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        if self._lookup[value] then
            return index, value
        end
    end
end

--- Produces the set intersection of two sequences.
--- @param elements table|LazyLuaqQuery
--- @return LazyLuaqQuery
function LazyLuaq:intersect(elements)
    local ret = {
        _content = self:distinct(),
        move_next = intersect_move_next,
        _elements = elements,
        reset = lookup_deleting_reset -- both just need to delete the lookup table
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function intersect_by_move_next(self)
    if self._lookup == nil then
        self._lookup = lookup_with_selector(self._elements, self._selector)
    end

    while true do
        local index, value = self._content:move_next()

        if index == nil then
            return
        end

        local valueKey = self._selector(value)
        if self._lookup[valueKey] then
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
        _content = self:distinct_by(selector),
        move_next = intersect_by_move_next,
        _elements = elements,
        _selector = selector,
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
        if #self._sequences == #self._finished_sequences then
            return
        end

        -- iterate the sequences first
        local sequence_index, sequence = next(self._sequences, self._last_sequence_index)
        self._last_sequence_index = sequence_index

        -- if sequence_index is nil, we reached the end of the sequences and loop around
        if sequence_index == nil or self._finished_sequences[sequence_index] then
            -- continue to loop around or skip finished sequences
        else
            local index, value = sequence:move_next()
            if index ~= nil then
                return index, value
            else
                -- this sequence is over, iterate to the next
                self._finished_sequences[sequence_index] = true
            end
        end
    end
end

local function interleave_reset(self)
    for i = 1, #self._sequences do
        self._sequences[i]:reset()
    end

    self._finished_sequences = {}
    self._last_sequence_index = nil
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
        _sequences = sequences,
        move_next = interleave_move_next,
        reset = interleave_reset,
        _finished_sequences = {}
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function zip_move_next(self)
    local _, left = self._content:move_next()
    if left == nil then
        return
    end
    local _, right = self._second:move_next()
    if right ~= nil then
        self._i = self._i + 1
        return self._i, self._selector(left, right)
    end
end

local function zip_reset(self)
    self._i = 0
    self._content:reset()
    self._second:reset()
end

--- Combines two sequences element-wise until one ends.<br>
--- A selector function can be given. Otherwise returns an array with the 2 elements.
--- Index-replacing: yields sequential integer indices.
--- @param sequence LazyLuaqQuery|table|array
--- @param selector function?
--- @return LazyLuaqQuery
function LazyLuaq:zip(sequence, selector)
    selector = selector or pack

    if getmetatable(sequence) ~= LazyLuaq then
        sequence = LazyLuaq.from(sequence)
    end

    local ret = {
        _content = self,
        _second = sequence,
        _selector = selector,
        _i = 0,
        move_next = zip_move_next,
        reset = zip_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function pairwise_move_next(self)
    if self._last_element == nil then
        local _
        _, self._last_element = self._content:move_next()
    end

    local _, element = self._content:move_next()
    if element ~= nil then
        self._i = self._i + 1
        local previous = self._last_element
        self._last_element = element
        return self._i, self._selector(previous, element)
    end
end

local function pairwise_reset(self)
    self._last_element = nil
    self._i = 0
    self._content:reset()
end

--- Returns a sequence resulting from applying a function to each element with its previous element.
--- Index-replacing: yields sequential integer indices.
--- @param selector function?
--- @return LazyLuaqQuery
function LazyLuaq:pairwise(selector)
    selector = selector or pack

    local ret = {
        _content = self,
        _selector = selector,
        _i = 0,
        _last_element = nil,
        move_next = pairwise_move_next,
        reset = pairwise_reset
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function window_move_next(self)
    local buf = self._buf
    local size = self._size

    repeat
        local index, value = self._content:move_next()
        if index == nil then return end
        buf[self._head] = value
        self._head = (self._head % size) + 1
        if self._filled < size then
            self._filled = self._filled + 1
        end
    until self._filled == size

    local window = {}
    local head = self._head
    for i = 1, size do
        window[i] = buf[((head - 1 + i - 1) % size) + 1]
    end

    self._i = self._i + 1
    return self._i, LazyLuaq.from(window)
end

local function window_reset(self)
    self._buf = {}
    self._head = 1
    self._filled = 0
    self._i = 0
    self._content:reset()
end

--- Returns a sliding window of the given size over the sequence.
--- Each element is a LazyLuaqQuery containing the window's values in order.
--- @param size integer
--- @return LazyLuaqQuery
function LazyLuaq:window(size)
    if size <= 0 then
        error("Window size must be a positive number")
    end
    local ret = {
        _content = self,
        _size = size,
        _buf = {},
        _head = 1,
        _filled = 0,
        _i = 0,
        move_next = window_move_next,
        reset = window_reset
    }
    setmetatable(ret, LazyLuaq)
    return ret
end

local SCAN_NO_SEED = {}

local function scan_move_next(self)
    local index, value = self._content:move_next()
    if index == nil then return end

    if self._acc == SCAN_NO_SEED then
        self._acc = value
    else
        self._acc = self._aggregator(self._acc, value)
    end
    return index, self._acc
end

local function scan_reset(self)
    self._acc = self._seed
    self._content:reset()
end

--- Returns a sequence of running accumulations.
--- If no seed is given, the first element is emitted as-is and accumulation starts from the second.
--- @param aggregator function
--- @param seed any?
--- @return LazyLuaqQuery
function LazyLuaq:scan(aggregator, seed)
    local initial = seed ~= nil and seed or SCAN_NO_SEED
    local ret = {
        _content = self,
        _aggregator = aggregator,
        _seed = initial,
        _acc = initial,
        move_next = scan_move_next,
        reset = scan_reset
    }
    setmetatable(ret, LazyLuaq)
    return ret
end

-- Materializes the upstream content and performs a single sort using all accumulated sort levels.
-- Called on the first move_next of an ordered query.
local function ordered_do_sort(self)
    local array = {}
    for _, value in self._upstream:iterate() do
        array[#array + 1] = value
    end

    -- Compute keys for every sort level at once
    local all_keys = {}
    for l, level in pairs(self._sort_levels) do
        local keys = {}
        for i, value in pairs(array) do
            keys[i] = level.selector(value)
        end
        all_keys[l] = keys
    end

    -- Build an index array and sort that, so duplicate values don't collide
    local indices = {}
    for i = 1, #array do
        indices[i] = i
    end

    local levels = self._sort_levels
    table.sort(indices, function(a, b)
        for l, level in pairs(levels) do
            local ka, kb = all_keys[l][a], all_keys[l][b]
            if ka ~= kb then
                if level.comparator then
                    if level.comparator(ka, kb) then return true end
                    if level.comparator(kb, ka) then return false end
                elseif level.descending then
                    return ka > kb
                else
                    return ka < kb
                end
            end
        end
        return false
    end)

    local sorted = {}
    for i = 1, #indices do
        sorted[i] = array[indices[i]]
    end

    self._materialized = sorted
end

local function ordered_move_next(self)
    if not self._materialized then
        ordered_do_sort(self)
    end
    self._index = self._index + 1
    if self._index <= #self._materialized then
        return self._index, self._materialized[self._index]
    end
end

local function ordered_reset(self)
    self._index = 0
    self._materialized = nil
end

local function create_ordered_query(upstream, sort_levels)
    local query = {
        _is_ordered_query = true,
        _sort_levels = sort_levels,
        _upstream = upstream,
        _materialized = nil,
        _index = 0,
        _is_content_iterator = true,
        move_next = ordered_move_next,
        reset = ordered_reset
    }
    setmetatable(query, LazyLuaq)
    return query
end

--- Sorts the sequence in ascending order using the keys of the given selector function.<br>
--- Sorting is deferred until first iteration. Chain with then_by/then_by_descending for multi-level sorting.
--- Index-replacing: yields sequential integer indices.
--- @param selector function
--- @param comparator function?
--- @return LazyLuaqQuery
function LazyLuaq:order_by(selector, comparator)
    return create_ordered_query(self, {{ selector = selector, comparator = comparator, descending = false }})
end

--- Sorts the sequence in descending order.
--- Sorting is deferred until first iteration. Chain with then_by/then_by_descending for multi-level sorting.
--- Index-replacing: yields sequential integer indices.
--- @return LazyLuaqQuery
function LazyLuaq:order_descending()
    return create_ordered_query(self, {{ selector = identity, descending = true }})
end

--- Sorts the sequence in descending order using the keys of the given selector function.<br>
--- Sorting is deferred until first iteration. Chain with then_by/then_by_descending for multi-level sorting.
--- Index-replacing: yields sequential integer indices.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:order_by_descending(selector)
    return create_ordered_query(self, {{ selector = selector, descending = true }})
end

--- Adds a secondary ascending sort level to an ordered query. Can only be called after order_by or order_by_descending.
--- @param selector function
--- @param comparator function?
--- @return LazyLuaqQuery
function LazyLuaq:then_by(selector, comparator)
    assert(self._is_ordered_query, "then_by can only be called after order_by, order_by_descending, then_by, or then_by_descending")

    local levels = {}
    for i, level in pairs(self._sort_levels) do
        levels[i] = level
    end
    levels[#levels + 1] = { selector = selector, comparator = comparator, descending = false }

    return create_ordered_query(self._upstream, levels)
end

--- Adds a secondary descending sort level to an ordered query. Can only be called after order_by or order_by_descending.
--- @param selector function
--- @return LazyLuaqQuery
function LazyLuaq:then_by_descending(selector)
    assert(self._is_ordered_query, "then_by_descending can only be called after order_by, order_by_descending, then_by, or then_by_descending")

    local levels = {}
    for i, level in pairs(self._sort_levels) do
        levels[i] = level
    end
    levels[#levels + 1] = { selector = selector, descending = true }

    return create_ordered_query(self._upstream, levels)
end

---------------------------------------------------------------------------------------------------
--- Functions returning new iterators
--- -> Execution is immediate

--- Immediately executes the iterator and returns a new LazyLuaqQuery with the results.<br>
--- Can be useful to cache the results of an expensive query that needs to be iterated multiple times.
--- @return LazyLuaqQuery
function LazyLuaq:cache_execution()
    local indices = {}
    local values = {}
    for index, value in self:iterate() do
        local pos = #indices + 1
        indices[pos] = index
        values[pos] = value
    end
    local ret = {
        _cache_indices = indices,
        _cache_values = values,
        _iterator_exhausted = true,
        move_next = iterator_move_next,
        reset = iterator_reset,
        _is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)
    return ret
end

--- Sorts the sequence in ascending order.
--- Index-replacing: yields sequential integer indices.
--- @param comparator function?
--- @return LazyLuaqQuery
function LazyLuaq:order(comparator)
    local array = self:to_array()

    table.sort(array, comparator)

    return LazyLuaq.from(array)
end

--- Sorts the sequence in ascending order and only returns up to the given count of top elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- Index-replacing: yields sequential integer indices.
--- @param count integer
--- @return LazyLuaqQuery
function LazyLuaq:partial_sort(count)
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

--- Sorts the sequence in ascending order using the keys generated by the given selector function and only returns up to the given count of top elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- Index-replacing: yields sequential integer indices.
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

--- Sorts the sequence in descending order and only returns up to the given count of elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- Index-replacing: yields sequential integer indices.
--- @param count integer
--- @return LazyLuaqQuery
function LazyLuaq:partial_sort_descending(count)
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

--- Sorts the sequence in descending order using the keys generated by the given selector function and only returns up to the given count of top elements.<br>
--- This uses an insertion-sort-like approach and should be performant for small counts.<br>
--- For big counts a combination of order and take should be better.
--- Index-replacing: yields sequential integer indices.
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
--- Index-replacing: yields sequential integer indices.
--- @return LazyLuaqQuery
function LazyLuaq:shuffle()
    local array = self:to_array()

    for i = #array, 2, -1 do
        local j = random(i)
        array[i], array[j] = array[j], array[i]
    end

    return LazyLuaq.from(array)
end

local function reverse_move_next(self)
    local index = self._last_index
    if index == nil then
        index = #self._content
    end

    if index > 0 then
        self._last_index = index - 2
        return self._content[index], self._content[index - 1]
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
        _content = array,
        move_next = reverse_move_next,
        _is_content_iterator = true
    }
    setmetatable(ret, LazyLuaq)

    return ret
end

local function normalize_materialize(self)
    local indices = {}
    local values = {}
    local sum = 0
    for index, value in self._upstream:iterate() do
        local pos = #values + 1
        indices[pos] = index
        values[pos] = value
        sum = sum + value
    end
    self._mat_indices = indices
    self._mat_values = values
    self._sum = sum
end

local function normalize_move_next(self)
    if not self._mat_indices then
        normalize_materialize(self)
    end
    self._pos = self._pos + 1
    local orig_index = self._mat_indices[self._pos]
    if orig_index ~= nil then
        local value = self._mat_values[self._pos]
        return orig_index, self._sum > 0 and value / self._sum or value
    end
end

local function normalize_reset(self)
    self._pos = 0
    self._mat_indices = nil
    self._mat_values = nil
end

--- Normalizes the (numeric) sequence.<br>
--- Meaning the sum of all elements will be (close to) 1.<br>
--- Materialization is deferred until first iteration.
--- @return LazyLuaqQuery
function LazyLuaq:normalize()
    local ret = {
        _upstream = self,
        _pos = 0,
        _is_content_iterator = true,
        move_next = normalize_move_next,
        reset = normalize_reset
    }
    setmetatable(ret, LazyLuaq)
    return ret
end
