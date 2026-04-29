local floor = math.floor
local round = Tirislib.Utils.round

---------------------------------------------------------------------------------------------------
--- Just some locale helper functions
Tirislib.Locales = {}

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
        local subtable_index = floor((i - 1) / 20) + 2
        if not enumeration[subtable_index] then
            enumeration[subtable_index] = {""}
        end
        local subtable = enumeration[subtable_index]
        subtable[#subtable + 1] = copy[i]
    end

    shorten_enumeration(enumeration)
end

Tirislib.Locales.shorten_enumeration = shorten_enumeration

--- Creates a localised enumeration of the given elements.
--- @param elements array
--- @param separator string|locale|nil
--- @param last_separator string|locale|nil
--- @return locale
function Tirislib.Locales.create_enumeration(elements, separator, last_separator)
    separator = separator or ", "
    local ret = {""}
    local at_least_one = false

    for _, element in pairs(elements) do
        ret[#ret + 1] = element
---@diagnostic disable-next-line: assign-type-mismatch
        ret[#ret + 1] = separator
        at_least_one = true
    end
    ret[#ret] = nil

    -- #ret == 2 means a single element {"", e1} - no separator to replace
    if last_separator and #ret > 2 then
---@diagnostic disable-next-line: assign-type-mismatch
        ret[#ret - 1] = last_separator
    end

    if not at_least_one then
        -- the given elements table was empty
---@diagnostic disable-next-line: return-type-mismatch
        return ""
    end

    shorten_enumeration(ret)

    return ret
end
local create_enumeration = Tirislib.Locales.create_enumeration

--- Creates a localised enumeration of the given elements.
--- - Needs Sosciencity's locales
--- @param elements table (element, number)-pairs
--- @param fn function|nil function that returns a locale for the element
--- @param separator string|locale|nil
--- @param last_separator string|locale|nil
--- @param pruning boolean if 0 elements are to be ignored
--- @return locale
function Tirislib.Locales.create_enumeration_with_numbers(elements, fn, separator, last_separator, pruning)
    local finished_elements = {}

    for element, number in pairs(elements) do
        if not pruning or number ~= 0 then
            finished_elements[#finished_elements + 1] = {
                "sosciencity.value-with-unit",
                number,
                fn and fn(element) or element
            }
        end
    end

    return create_enumeration(finished_elements, separator, last_separator)
end

--- Creates a localisation for the real world time for the given ticks.
--- - Needs Sosciencity's locales
--- @param ticks integer
--- @return locale
function Tirislib.Locales.display_time(ticks)
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
--- - Needs Sosciencity's locales
--- @param ticks integer
--- @return locale
function Tirislib.Locales.display_ingame_time(ticks)
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

--- Creates a localisation for the given item stack.
--- - Needs Sosciencity's locales
--- - Data stage variant: count is converted to string, as Factorio 2.0 does not allow numbers in locales at data stage.
--- @param item string
--- @param count integer
--- @return locale
function Tirislib.Locales.display_item_stack_datastage(item, count)
    return {"sosciencity.xitems", tostring(count), item, {"item-name." .. item}}
end

--- Creates a localisation for the given fluid stack.
--- - Needs Sosciencity's locales
--- - Data stage variant: count is converted to string, as Factorio 2.0 does not allow numbers in locales at data stage.
--- @param fluid string
--- @param count integer
--- @return locale
function Tirislib.Locales.display_fluid_stack_datastage(fluid, count)
    return {"sosciencity.xfluids", tostring(count), fluid, {"fluid-name." .. fluid}}
end

--- Creates a localisation for the given item stack.
--- - Needs Sosciencity's locales
--- @param item string
--- @param count integer
--- @return locale
function Tirislib.Locales.display_item_stack(item, count)
    return {"sosciencity.xitems", count, item, prototypes.item[item].localised_name}
end

--- Creates a localisation for the given fluid stack.
--- - Needs Sosciencity's locales
--- @param fluid string
--- @param count integer
--- @return locale
function Tirislib.Locales.display_fluid_stack(fluid, count)
    return {"sosciencity.xfluids", count, fluid, prototypes.fluid[fluid].localised_name}
end

--- Creates a localisation for the given value.
--- @param percentage number
--- @return locale
function Tirislib.Locales.display_percentage(percentage)
    return {"sosciencity.percentage", tostring(round(percentage * 100))}
end

--- Formats a number as a string with an explicit sign (e.g. "+5", "-3", "+0").
--- Useful for displaying stat modifiers.
--- @param number number
--- @return string
function Tirislib.Locales.display_signed_number(number)
    if number >= 0 then
        return "+" .. tostring(number)
    else
        return tostring(number)
    end
end

local function transform_to_enumeration(locale)
    if locale[1] == "" then
        return
    end
    local locale_copy = Tirislib.Tables.copy(locale)
    Tirislib.Tables.empty(locale)

    locale[1] = ""
    locale[2] = locale_copy
end

--- Appends the given elements to the given locale table.
--- @param locale locale
function Tirislib.Locales.append(locale, ...)
    transform_to_enumeration(locale)

    for _, v in pairs {...} do
        locale[#locale + 1] = v
    end
    shorten_enumeration(locale)
end

--- Prepends the given elements to the given locale table.
--- @param locale locale
function Tirislib.Locales.prepend(locale, ...)
    transform_to_enumeration(locale)

    local args = {...}
    for i = #args, 1, -1 do
        table.insert(locale, 2, args[i])
    end
    shorten_enumeration(locale)
end
