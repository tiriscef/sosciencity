--- @class Prototype
Tirislib.Prototype = Tirislib.Prototype or {}

--- The name of the mod that is currently running. Used to set the inofficial 'owner' field for created prototypes.
Tirislib.Prototype.modname = nil

--- Path to the icon to use for placeholder reasons.
Tirislib.Prototype.placeholder_icon = nil

--- Class for arrays of prototypes. Setter-functions can be called on them.
--- @class PrototypeArray
Tirislib.PrototypeArray = {}

--- Makes a function call on a PrototypeArray object to a call on every entry instead.
function Tirislib.PrototypeArray:__index(method)
    return function(array, ...)
        for _, entry in pairs(array) do
            entry[method](entry, ...)
        end
    end
end

--- Removes all of my metatables so other mods don't call them accidentally.
local function remove_metatables()
    for _, prototypes in pairs(data.raw) do
        for _, prototype in pairs(prototypes) do
            setmetatable(prototype, nil)
        end
    end
end

local function nothing()
end

local dummy_metatable = {
    __index = function()
        return nothing
    end
}

local dummy_prototype = {}
setmetatable(dummy_prototype, dummy_metatable)

--- Checks if the given Prototype is legit or a dummy.
--- @param prototype Prototype
--- @return boolean
function Tirislib.Prototype.is_dummy(prototype)
    return prototype == dummy_prototype
end

--- Gets the prototype of the specified type (or one of the specified types) out of data.raw.
--- Returns a dummy prototype if no one was found, so that I can manipulate prototypes without
--- checking if they exist.
--- @param prototype_type string|table
--- @param name string
--- @param mt table|nil
--- @return Prototype Prototype prototype or dummy
--- @return boolean found
function Tirislib.Prototype.get(prototype_type, name, mt)
    local ret
    if type(prototype_type) == "string" then
        ret = (data.raw[prototype_type] or {})[name]
    elseif type(prototype_type) == "table" then
        for _, current_type in pairs(prototype_type) do
            ret = (data.raw[current_type] or {})[name]
            if ret then
                break
            end
        end
    end

    if ret then
        setmetatable(ret, mt)
        return ret, true
    else
        return dummy_prototype, false
    end
end

--- Creates the given prototype and adds it to data.raw.
--- @param prototype table
--- @return Prototype Prototype
function Tirislib.Prototype.create(prototype)
    prototype.owner = prototype.owner or Tirislib.Prototype.modname

    data:extend {prototype}

    local ret = Tirislib.Prototype.get(prototype.type, prototype.name)
    return ret
end

--- Creates the prototypes in the given array and add them to data.raw.
--- @param prototypes array
--- @return PrototypeArray created_prototypes
function Tirislib.Prototype.batch_create(prototypes)
    local ret = {}

    for _, prototype in pairs(prototypes) do
        ret[#ret+1] = Tirislib.Prototype.create(prototype)
    end

    setmetatable(ret, Tirislib.PrototypeArray)

    return ret
end

--- Some functions (mainly those who make changes to another prototype which might not
--- yet be created) might postpone their execution.
--- So they will add a table with all the necessary data and a execute-function to the
--- Prototype.postpones_functions table.
--- A call to finish_postponed will iterate repeatedly over the table and execute the
--- stored functions.
Tirislib.Prototype.postponed_functions = Tirislib.Prototype.postponed_functions or {}

--- Postpones the function call to when Tirislib.Prototype.finish gets called. 
--- @param fn function
function Tirislib.Prototype.postpone(fn, ...)
    table.insert(Tirislib.Prototype.postponed_functions, {fn = fn, arg = {...}})
end

-- This assumes that a 'successful' call to a postponed function will not result in
-- another postponed function
function Tirislib.Prototype.finish_postponed()
    local to_do = Tirislib.Prototype.postponed_functions
    local to_do_count = table_size(to_do)
    local last_to_do_count = to_do_count + 1 -- bogus value to ensure that the while loop gets executed

    while to_do_count < last_to_do_count do
        Tirislib.Prototype.postponed_functions = {}
        for _, postponed in pairs(to_do) do
            postponed.fn(table.unpack(postponed.arg))
        end

        to_do = Tirislib.Prototype.postponed_functions
        last_to_do_count = to_do_count
        to_do_count = table_size(to_do)
    end

    return to_do_count == 0 -- return true if there are no more things to do
end

--- A table with all the recipes which should be added to productivity modules
Tirislib.Prototype.productivity_recipes = Tirislib.Prototype.productivity_recipes or {}

--- Adds the given recipe name to the recipe whitelist of productivity modules.
--- @param recipe_name string
function Tirislib.Prototype.add_recipe_to_productivity_modules(recipe_name)
    table.insert(Tirislib.Prototype.productivity_recipes, recipe_name)
end

--- Actually adds the marked recipe names to the whitelist of productivity modules.
function Tirislib.Prototype.finish_productivity_modules()
    for _, _module in Tirislib.Item.iterate("module") do
        if _module.category == "productivity" and _module.limitation then
            Tirislib.Tables.merge(_module.limitation, Tirislib.Prototype.productivity_recipes)
        end
    end
    Tirislib.Prototype.productivity_recipes = {}
end

--- Boilerplate function. Has to be called at the end of a data stage.
function Tirislib.Prototype.finish()
    Tirislib.Prototype.finish_postponed()
    Tirislib.Prototype.finish_productivity_modules()

    remove_metatables()
end

--- Returns a unique name of which no prototype already exists.
--- @param name string
--- @param _type string
--- @return string unique_name
function Tirislib.Prototype.get_unique_name(name, _type)
    if not data.raw[_type] or not data.raw[_type][name] then
        return name
    end

    local i = 1
    while true do
        if not data.raw[_type][name .. i] then
            return name .. i
        end
        i = i + 1
    end
end
