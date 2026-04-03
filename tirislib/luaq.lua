---------------------------------------------------------------------------------------------------
--- Table query functions.
--- Obviously inspired by .NET's Linq but lacking the lazy evaluation capabilities.
--- @class LuaqQuery
Tirislib.Luaq = {}

Tirislib.Luaq.__index = Tirislib.Luaq

local get_subtbl = Tirislib.Tables.get_subtbl

--- Creates a luaq query for the given source.
--- @param source table
--- @return LuaqQuery
function Tirislib.Luaq.from(source)
    local ret = {
        content = source
    }
    setmetatable(ret, Tirislib.Luaq)

    return ret
end

--- Returns true if there is any element in the given sequence.
--- @return boolean
function Tirislib.Luaq:any()
    return next(self.content) ~= nil
end

--- Returns true if there is any element in the given sequence that makes the given function return a truthy value.
--- @return boolean
function Tirislib.Luaq:any_where(fn, ...)
    for _, element in pairs(self.content) do
        if fn(element, ...) then
            return true
        end
    end

    return false
end

--- Returns the first element of the given sequence.
--- @return any|nil first_element
function Tirislib.Luaq:first()
    return next(self.content)
end

--- Returns the first element where the given function returns a truthy value.
--- @param fn function function with (element, ...) arguments, should return a truthy or falsy value.
--- @param ... any function parameters
--- @return any|nil first_element the first value that the function returns a truthy value on
function Tirislib.Luaq:first_where(fn, ...)
    for _, element in pairs(self.content) do
        if fn(element, ...) then
            return element
        end
    end
end

--- Returns the first n elements
--- @param n number
--- @return LuaqQuery taken the query with the taken elements
function Tirislib.Luaq:take(n)
    local new_content = {}
    local count = 0

    for index, element in pairs(self.content) do
        if count < n then
            new_content[index] = element
            count = count + 1
        else
            break
        end
    end

    self.content = new_content
    return self
end

--- Returns the first n elements where the given function returns a truthy value.
--- @param n integer number of elements
--- @param fn function function with (element, ...) arguments, should return a truthy or falsy value
--- @param ... any function parameters
--- @return LuaqQuery taken the query with the taken elements
function Tirislib.Luaq:take_where(n, fn, ...)
    local new_content = {}
    local count = 0

    for index, element in pairs(self.content) do
        if fn(element, ...) then
            new_content[index] = element
            count = count + 1

            if count >= n then
                break
            end
        end
    end

    self.content = new_content
    return self
end

--- Selects the given key of every element.
--- @param key any
--- @return LuaqQuery
function Tirislib.Luaq:select_key(key)
    local new_content = {}

    for index, element in pairs(self.content) do
        new_content[index] = element[key]
    end

    self.content = new_content
    return self
end

--- Projects the sequence with the given function.
--- @param fn function function with (index, element, ...) arguments, should return the new element first and optionally the new index second
--- @return LuaqQuery
function Tirislib.Luaq:select(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        local new_element, new_index = fn(index, element, ...)
        new_content[new_index or index] = new_element
    end

    self.content = new_content
    return self
end

--- Projects the elements of the sequence with the given function without transforming the indexes.
--- @param fn function function with (element, ...) arguments, should return the new element
--- @return LuaqQuery
function Tirislib.Luaq:select_element(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        new_content[index] = fn(element, ...)
    end

    self.content = new_content
    return self
end

--- Filters the elements of the sequence with the given function.
--- @param fn function function with (index, element, ...) arguments, should return a truthy or falsy value
--- @return LuaqQuery
function Tirislib.Luaq:where(fn, ...)
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
function Tirislib.Luaq:foreach(fn, ...)
    for index, element in pairs(self.content) do
        fn(index, element, ...)
    end

    return self
end

--- Groups the sequence by the return value of the given function.
--- @param fn function
--- @return LuaqQuery
function Tirislib.Luaq:group(fn, ...)
    local new_content = {}

    for index, element in pairs(self.content) do
        local group_index = fn(index, element, ...)
        get_subtbl(new_content, group_index)[index] = element
    end

    self.content = new_content
    return self
end

--- Returns the element that produces the maximal result with the given function.
--- Returns nil if the sequence is empty.
--- @param fn function function with (element, ...) arguments, should return a comparable value
--- @param ... any function parameters
--- @return any|nil max_element
--- @return any|nil max_value
function Tirislib.Luaq:max(fn, ...)
    local candidate = next(self.content)

    if candidate == nil then
        return nil, nil
    end

    local candidate_value = fn(candidate, ...)

    for _, element in pairs(self.content) do
        local value = fn(element, ...)
        if value > candidate_value then
            candidate = element
            candidate_value = value
        end
    end

    return candidate, candidate_value
end

--- Returns the element that produces the minimal result with the given function.
--- Returns nil if the sequence is empty.
--- @param fn function with (element, ...) arguments, should return a comparable value
--- @param ... unknown function parameters
--- @return any|nil min_element
--- @return any|nil min_value
function Tirislib.Luaq:min(fn, ...)
    local candidate = next(self.content)

    if candidate == nil then
        return nil, nil
    end

    local candidate_value = fn(candidate, ...)

    for _, element in pairs(self.content) do
        local value = fn(element, ...)
        if value < candidate_value then
            candidate = element
            candidate_value = value
        end
    end

    return candidate, candidate_value
end

--- Accumulates a value over the sequence.
--- @param seed any the initial value
--- @param fn function with (accumulation, element, ...) arguments, returns an accumulation value
--- @param ... any  function parameters
--- @return any accumulation
function Tirislib.Luaq:aggregate(seed, fn, ...)
    local ret = seed

    for _, element in pairs(self.content) do
        ret = fn(ret, element, ...)
    end

    return ret
end

--- Iterator over the sequence, to use with lua's 'for .. in'-syntax.
--- @return function iterator
--- @return table content
--- @return nil first_index
function Tirislib.Luaq:pairs()
    return next, self.content, nil
end

--- Returns the sequence as a table.
--- @return table
function Tirislib.Luaq:to_table()
    return self.content
end

--- Returns the sequence as an array.
--- @return table
function Tirislib.Luaq:to_array()
    local ret = {}

    for _, element in pairs(self.content) do
        ret[#ret + 1] = element
    end

    return ret
end

--- Calls the given function on the sequence.
--- @param fn function
--- @return any
function Tirislib.Luaq:call(fn, ...)
    return fn(self.content, ...)
end
