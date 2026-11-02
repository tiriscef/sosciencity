--- @class Prototype
Tirislib.Prototype = Tirislib.Prototype or {}

--- The name of the mod that is currently running. Used to set the unofficial 'owner' field for created prototypes.
Tirislib.Prototype.modname = nil

--- Path to the icon to use for placeholder reasons.
Tirislib.Prototype.placeholder_icon = nil

--- Default base path for auto-generated icons (e.g. "__mod__/graphics/icon/").
Tirislib.Prototype.default_icon_path = nil

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
--- Returns a dummy prototype if none was found, so that prototypes can be manipulated without
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

--- Unofficial fields describing a prototype live in its 'mod_metadata' table, meant as a convention any mod can read and write:
--- - owner: name of the mod that created the prototype
--- - is_hack: the prototype is a technical helper, not actual game content, so procedural changes for its type should skip it
--- 'ignore = true' makes Factorio skip the table when checking for unused prototype data
--- (--check-unused-prototype-data), so typos in the official fields aren't drowned out.
local function get_mod_metadata(prototype)
    -- rawget, so dummy prototypes don't hand out their 'nothing' function
    return rawget(prototype, "mod_metadata") or {}
end

--- Returns the name of the mod that created the given prototype with Tirislib, or nil.
--- @param prototype Prototype
--- @return string|nil
function Tirislib.Prototype.get_owner(prototype)
    return get_mod_metadata(prototype).owner
end

--- Checks if the given prototype is a technical helper instead of actual game content.
--- Set by creating it with 'mod_metadata = {is_hack = true}'.
--- @param prototype Prototype
--- @return boolean
function Tirislib.Prototype.is_hack(prototype)
    return get_mod_metadata(prototype).is_hack == true
end

--- Creates the given prototype and adds it to data.raw.
--- @param prototype table
--- @return Prototype Prototype
function Tirislib.Prototype.create(prototype)
    local metadata = get_mod_metadata(prototype)
    metadata.ignore = true
    metadata.owner = metadata.owner or Tirislib.Prototype.modname
    prototype.mod_metadata = metadata

    data:extend {prototype}

    local ret = Tirislib.Prototype.get(prototype.type, prototype.name)
    return ret
end

--- Creates the prototypes in the given array and adds them to data.raw.
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

--- Some functions (mainly those that modify another prototype which might not yet be
--- created) can postpone their execution. They are stored in Prototype.postponed_functions
--- as {fn, arg} entries. A call to finish_postponed will iterate repeatedly over the
--- table and execute the stored functions until no new ones are added.
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

--- Boilerplate function. Has to be called at the end of a data stage.
--- Returns a readable description of every postponed call that is still waiting, e.g.
--- "Recipe.add_unlock(window, infrastucture-1)". After finish_postponed, these are calls that reference
--- a prototype which never got created, mostly typos.
--- @return string[]
function Tirislib.Prototype.describe_postponed()
    local descriptions = {}

    for _, postponed in pairs(Tirislib.Prototype.postponed_functions) do
        local function_name = "<unknown function>"
        for class_name, class in pairs(Tirislib) do
            if type(class) == "table" then
                for name, fn in pairs(class) do
                    if fn == postponed.fn then
                        function_name = class_name .. "." .. name
                    end
                end
            end
        end

        local arguments = {}
        for _, argument in pairs(postponed.arg) do
            if type(argument) == "table" then
                arguments[#arguments + 1] = tostring(argument.name or argument.type or "<table>")
            else
                arguments[#arguments + 1] = tostring(argument)
            end
        end

        descriptions[#descriptions + 1] = string.format("%s(%s)", function_name, table.concat(arguments, ", "))
    end

    return descriptions
end

function Tirislib.Prototype.finish()
    Tirislib.Prototype.finish_postponed()

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
