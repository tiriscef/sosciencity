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

    return {"sosciencity.display-entry", entity.localised_name, position.x, position.y, entity.surface.name}
end

return Locale
