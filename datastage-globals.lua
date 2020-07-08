if not Sosciencity_Globals then
    --- Table with centrally defined global values.
    Sosciencity_Globals = {}
end

local default_values = {
    DEBUG = true,
    clockwork_pack = "automation-science-pack",
    orchid_pack = "logistic-science-pack",
    gunfire_pack = "military-science-pack",
    ember_pack = "chemical-science-pack",
    foundry_pack = "production-science-pack",
    gleam_pack = "utility-science-pack",
    aurora_pack = "space-science-pack"
}

default_values.__index = default_values
setmetatable(Sosciencity_Globals, default_values)

return Sosciencity_Globals
