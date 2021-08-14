if not Sosciencity_Config then
    --- Table with centrally defined global values.
    Sosciencity_Config = {}
end

local default_values = {
    DEBUG = false,
    BALANCING = false,
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
    },
    eei_sizes = {},
    building_stacksize = 50,
    add_glass = true,
    glass_compatibility_mode = false
}

function default_values.add_eei_size(width, height)
    local eei_sizes = default_values.eei_sizes
    if not eei_sizes[width] then
        eei_sizes[width] = {}
    end

    eei_sizes[width][height] = true
end

if mods["sosciencity-debug"] then
    default_values.DEBUG = true
end
if mods["sosciencity-balancing"] then
    default_values.BALANCING = true
end

default_values.__index = default_values
setmetatable(Sosciencity_Config, default_values)

return Sosciencity_Config
