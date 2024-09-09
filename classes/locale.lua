local Castes = require("constants.castes")
local EK = require("enums.entry-key")

--- Static class that creates locales specific to Sosciencity.
Locale = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local often used globals for hard to quantify performance gains

local castes = Castes.values
local format = string.format

-- TODO XXX: migrate random locale functions from all around the code to this class

function Locale.caste(caste_id, short)
    if short then
        return castes[caste_id].localised_name_short
    else
        return castes[caste_id].localised_name
    end
end

function Locale.caste_short(caste_id)
    return castes[caste_id].localised_name_short
end

function Locale.entry(entry)
    local entity = entry[EK.entity]
    local position = entity.position
    return {"sosciencity.entry-representation", entity.localised_name, position.x, position.y}
end

function Locale.entry_in_chat(entry)
    local entity = entry[EK.entity]
    local position = entity.position
    return {"sosciencity.display-entry", entity.localised_name, position.x, position.y, entity.surface.name}
end

function Locale.integer_summand(number)
    if number > 0 then
        return format("[color=0,1,0]%+d[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+d[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0[/color]"
    end
end

function Locale.summand(number)
    if number > 0 then
        return format("[color=0,1,0]%+.1f[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+.1f[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0.0[/color]"
    end
end

function Locale.factor(number)
    if number > 1 then
        return format("[color=0,1,0]×%.1f[/color]", number)
    elseif number < 1 then
        return format("[color=1,0,0]×%.1f[/color]", number)
    else -- number equals 1
        return "[color=0.8,0.8,0.8]1.0[/color]"
    end
end

function Locale.comfort(comfort)
    return {"", comfort, "  -  ", {"comfort-scale." .. comfort}}
end

function Locale.migration(number)
    return format("%+.1f", number)
end

function Locale.convergence(current, target, step)
    step = step or 0.1
    return {
        "sosciencity.convergenting-value",
        Tirislib.Utils.round_to_step(current, step),
        Tirislib.Utils.round_to_step(target, step)
    }
end

function Locale.materials(materials)
    local ret = {""}
    local first = true
    local item_prototypes = game.item_prototypes

    for material, count in pairs(materials) do
        local entry = {""}

        if not first then
            entry[#entry + 1] = "\n"
        end
        first = false

        entry[#entry + 1] = count
        entry[#entry + 1] = " × "

        entry[#entry + 1] = format("[item=%s] ", material)
        entry[#entry + 1] = item_prototypes[material].localised_name

        ret[#ret + 1] = entry
    end

    -- otherwise this would could exceed the maximum of 20 entries
    Tirislib.Locales.shorten_enumeration(ret)

    return ret
end

return Locale
