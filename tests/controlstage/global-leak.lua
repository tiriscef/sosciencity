local Assert = Tirislib.Testing.Assert

-- Global leak check: every global name has to be on one of the lists below.
-- A new module is `local X = {}` ... `return X` and consumed with `require`, so it never needs an entry here.

--- Globals provided by Lua and Factorio. A new Factorio version may add some.
local ENGINE_GLOBALS = {
    -- Lua
    "_G",
    "_VERSION",
    "assert",
    "bit32",
    "collectgarbage",
    "debug",
    "error",
    "getmetatable",
    "ipairs",
    "load",
    "loadstring",
    "math",
    "next",
    "package",
    "pairs",
    "pcall",
    "print",
    "rawequal",
    "rawget",
    "rawlen",
    "rawset",
    "require",
    "select",
    "setmetatable",
    "string",
    "table",
    "tonumber",
    "tostring",
    "type",
    "unpack",
    "xpcall",
    -- Factorio
    "commands",
    "defines",
    "game",
    "helpers",
    "localised_print",
    "log",
    "prototypes",
    "rcon",
    "remote",
    "rendering",
    "script",
    "serpent",
    "settings",
    "storage",
    "table_size"
}

--- Globals the mod defines on purpose.
local INTENDED_GLOBALS = {
    "Tirislib"
}

local function to_set(...)
    local set = {}
    for _, list in pairs({...}) do
        for _, name in pairs(list) do
            set[name] = true
        end
    end
    return set
end

--- Returns the sorted names of the given keys, so failure messages are stable.
local function sorted_names(names)
    table.sort(names)
    return table.concat(names, ", ")
end

Tirislib.Testing.add_test_case(
    "no global outside the allowlists",
    "global-leak",
    function()
        local allowed = to_set(ENGINE_GLOBALS, INTENDED_GLOBALS)
        local unexpected = {}
        for name in pairs(_G) do
            if not allowed[name] then
                unexpected[#unexpected + 1] = tostring(name)
            end
        end

        Assert.is_table_empty(
            unexpected,
            "unexpected globals (make them local and use require): " .. sorted_names(unexpected)
        )
    end
)
