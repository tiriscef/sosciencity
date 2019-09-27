--[[
    Some functions (mainly those who make changes to another prototype which might not
    yet be created) might postpone their execution.
    So they will add a table with all the necessary data and a execute-function to the
    Prototype.postpones_functions table.

    A call to finish_postponed will iterate repeatedly over the table and execute the
    stored functions.
]]
Prototype = {
    postponed_functions = {}
}

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
    local todo = self.postponed_functions
    local todo_count = table_size(todo)
    local last_todo_count = todo_count + 1 -- bogus value to ensure that the while loop gets executed

    while todo_count < last_todo_count do
        self.postponed_functions = {}
        for _, func in pairs(todo) do
            func:execute()
        end

        todo = self.postponed_functions
        last_todo_count = todo_count
        todo_count = table_size(todo)
    end

    return todo_count == 0 -- return true if there are no more things to do
end
