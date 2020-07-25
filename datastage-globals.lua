if not Sosciencity_Globals then
    --- Table with centrally defined global values.
    Sosciencity_Globals = {}
end

local default_values = {
    DEBUG = false,
    clockwork_pack = "automation-science-pack",
    orchid_pack = "logistic-science-pack",
    gunfire_pack = "military-science-pack",
    ember_pack = "chemical-science-pack",
    foundry_pack = "production-science-pack",
    gleam_pack = "utility-science-pack",
    aurora_pack = "space-science-pack",
    blueprint_on_belt = {
        {size = 64, filename = "__sosciencity-graphics__/graphics/icon/blueprint-1.png", scale = 0.25},
        {size = 64, filename = "__sosciencity-graphics__/graphics/icon/blueprint-2.png", scale = 0.25},
        {size = 64, filename = "__sosciencity-graphics__/graphics/icon/blueprint-3.png", scale = 0.25},
        {size = 64, filename = "__sosciencity-graphics__/graphics/icon/blueprint-4.png", scale = 0.25}
    }
}
if mods["sosciencity-debug"] then
    default_values.DEBUG = true
end

default_values.__index = default_values
setmetatable(Sosciencity_Globals, default_values)

return Sosciencity_Globals