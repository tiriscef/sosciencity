Prototype = {}

function Prototype:get(name, prototype_type)
    if type(prototype_type) == "string" then
        res = data.raw[prototype_type][name]
    elseif type(prototype_type) == "table" then
        for _, ctype in pairs(prototype_type) do
            res = data.raw[ctype][name]
            if res then return res end
        end
    end

    if not res then
        error("Couldn't find a prototype with the name '" .. name .. "'")
    end
    return res
end

require("lib.recipe")
require("lib.item")
require("lib.entity")
require("lib.technology")
require("lib.fluid")
