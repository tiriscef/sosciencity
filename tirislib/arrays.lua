local random = math.random
local min = math.min
local select = select

---------------------------------------------------------------------------------------------------
--- Just some array helper functions
Tirislib.Arrays = Tirislib.Arrays or {}

--- Removes all values of the given array that equal the given value.
--- This function doesn't preserve the original order.
--- @param tbl array
--- @param value any
function Tirislib.Arrays.remove_all(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            tbl[i] = tbl[#tbl]
            tbl[#tbl] = nil
        end
    end
end

--- Returns a table with the elements of the given array as keys.
--- @param array array
--- @return table
function Tirislib.Arrays.to_lookup(array)
    local ret = {}

    for i = 1, #array do
        ret[array[i]] = true
    end

    return ret
end

--- Shuffles the elements of the given array.
--- @param tbl array
--- @return array itself
function Tirislib.Arrays.shuffle(tbl)
    --https://gist.github.com/Uradamus/10323382
    for i = #tbl, 2, -1 do
        local j = random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

--- Merges the right hand array into the left hand array.
--- @param lh array
--- @param rh array
--- @return array lh
function Tirislib.Arrays.merge(lh, rh)
    for i = 1, #rh do
        lh[#lh + 1] = rh[i]
    end

    return lh
end

--- Calculates the sum of all elements in the given array.
--- @param tbl array
--- @return number
function Tirislib.Arrays.sum(tbl)
    local ret = 0.

    for i = 1, #tbl do
        ret = ret + tbl[i]
    end

    return ret
end

--- Calculates the product of all elements in the given array.
--- @param tbl array
--- @return number
function Tirislib.Arrays.product(tbl)
    local ret = 1.

    for i = 1, #tbl do
        ret = ret * tbl[i]
    end

    return ret
end

--- Creates a new array with the given number of predefined elements.
--- @param size integer
--- @param value any
--- @return array
function Tirislib.Arrays.new(size, value)
    local ret = {}

    for i = 1, size do
        ret[i] = value
    end

    return ret
end

--- Creates a new array with the given number of nested tables.
--- @param count integer
--- @return array
function Tirislib.Arrays.new_array_of_arrays(count)
    local ret = {}

    for i = 1, count do
        ret[i] = {}
    end

    return ret
end

--- Returns true if the array contains the given value.
--- @param arr array
--- @param value any
--- @return boolean
function Tirislib.Arrays.contains(arr, value)
    for i = 1, #arr do
        if arr[i] == value then
            return true
        end
    end
    return false
end

--- Returns the index of the first occurrence of the given value, or nil if not found.
--- @param arr array
--- @param value any
--- @return integer?
function Tirislib.Arrays.index_of(arr, value)
    for i = 1, #arr do
        if arr[i] == value then
            return i
        end
    end
    return nil
end

--- Returns the minimum value in the array, or nil if the array is empty.
--- @param arr array
--- @return number?
function Tirislib.Arrays.min(arr)
    if #arr == 0 then
        return nil
    end
    local ret = arr[1]
    for i = 2, #arr do
        if arr[i] < ret then
            ret = arr[i]
        end
    end
    return ret
end

--- Returns the maximum value in the array, or nil if the array is empty.
--- @param arr array
--- @return number?
function Tirislib.Arrays.max(arr)
    if #arr == 0 then
        return nil
    end
    local ret = arr[1]
    for i = 2, #arr do
        if arr[i] > ret then
            ret = arr[i]
        end
    end
    return ret
end

--- Reverses the array in-place.
--- @param arr array
--- @return array itself
function Tirislib.Arrays.reverse(arr)
    local len = #arr
    for i = 1, len / 2 do
        arr[i], arr[len - i + 1] = arr[len - i + 1], arr[i]
    end
    return arr
end

--- Returns an array with the given number sequence.
--- @param start number
--- @param finish number
--- @param steps number|nil
--- @return array
function Tirislib.Arrays.sequence(start, finish, steps)
    local ret = {}
    local i = 1

    steps = steps or 1
    if finish < start then
        steps = min(steps, -steps)
    end

    for n = start, finish, steps do
        ret[i] = n
        i = i + 1
    end

    return ret
end
