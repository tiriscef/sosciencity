--[[
    Some functions (mainly those who make changes to another prototype which might not
    yet be created) might postpone their execution.
    So they will add a table with all the necessary data and a execute-function to the
    Prototype.postpones_functions table.

    A call to finish_postponed will iterate repeatedly over the table and execute the
    stored functions.
]] --
Prototype = {}

Prototype.postponed_functions = {}

function Prototype:get(name, prototype_type)
    if type(prototype_type) == "string" then
        return data.raw[prototype_type][name]
    elseif type(prototype_type) == "table" then
        for _, ctype in pairs(prototype_type) do
            local res = data.raw[ctype][name]
            if res then
                return res
            end
        end
    end

    return nil
end

function Prototype:postpone(func)
    table.insert(self.postponed_functions, func)
end

-- This assumes that a 'successful' call to a postponed function will not result in
-- another postponed function
function Prototype:finish_postponed()
    local to_do = self.postponed_functions
    local to_do_count = table_size(to_do)
    local last_to_do_count = to_do_count + 1 -- bogus value to ensure that the while loop gets executed

    while to_do_count < last_to_do_count do
        self.postponed_functions = {}
        for _, func in pairs(to_do) do
            func:execute()
        end

        to_do = self.postponed_functions
        last_to_do_count = to_do_count
        to_do_count = table_size(to_do)
    end

    return to_do_count == 0 -- return true if there are no more things to do
end
