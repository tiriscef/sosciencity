---------------------------------------------------------------------------------------------------
--- Just some string helper functions
Tirislib.String = {}

--- Checks if the given string begins with the given prefix.
--- @param str string
--- @param prefix string
--- @return boolean
function Tirislib.String.begins_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

--- Checks if the given string ends with the given suffix.
--- @param str string
--- @param suffix string
--- @return boolean
function Tirislib.String.ends_with(str, suffix)
    if suffix == "" then
        return true
    end
    return str:sub(-#suffix) == suffix
end

--- Checks if the given string contains the given substring.
--- @param str string
--- @param substring string
--- @return boolean
function Tirislib.String.contains(str, substring)
    return string.find(str, substring, 1, true) ~= nil
end

--- Returns the string with leading and trailing whitespace removed.
--- @param str string
--- @return string
function Tirislib.String.trim(str)
    return str:match("^%s*(.-)%s*$")
end

--- Returns the string with all occurrences of 'from' replaced by 'to'.
--- Both 'from' and 'to' are treated as plain strings, not patterns.
--- @param str string
--- @param from string
--- @param to string
--- @return string
function Tirislib.String.replace(str, from, to)
    if from == "" then
        return str
    end
    local escaped_from = from:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1")
    local escaped_to = to:gsub("%%", "%%%%")
    return (str:gsub(escaped_from, escaped_to))
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
function Tirislib.String.join(separator, ...)
    return join_table(separator, {...}) or ""
end

--- Splits the given string along the given separator and returns an array of the parts.
--- Empty parts (from consecutive separators or leading/trailing separators) are skipped.
--- @param s string
--- @param separator string
--- @return table
function Tirislib.String.split(s, separator)
    local ret = {}
    local sep_len = #separator
    local start = 1

    while true do
        local found = string.find(s, separator, start, true)

        if not found then
            local part = s:sub(start)
            if part ~= "" then
                ret[#ret + 1] = part
            end
            break
        end

        local part = s:sub(start, found - 1)
        if part ~= "" then
            ret[#ret + 1] = part
        end
        
        start = found + sep_len
    end

    return ret
end

--- Inserts the given string at the given position.
--- @param s string
--- @param ins string
--- @param pos integer
--- @return string
function Tirislib.String.insert(s, ins, pos)
    return s:sub(1, pos) .. ins .. s:sub(pos + 1)
end
