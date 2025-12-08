if not Sosciencity_Config then
    --- Table with centrally defined global values.
    Sosciencity_Config = {}
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
    },
    eei_needing_buildings = {},
    buildings_needing_quality_multipliers = {},
    building_stacksize = 50,
    agriculture_pollutes = settings.startup["sosciencity-agriculture-pollution"].value,
    lumber_in_vanilla_recipes = settings.startup["sosciencity-lumber-in-vanilla-recipes"].value
}

--- Creates an Electric Energy Interface for the entity of the given name.
--- @param entity_name string
function default_values.add_eei(entity_name)
    default_values.eei_needing_buildings[entity_name] = true
end

--- Sets the quality multipliers to 1 for the given crafting machine type entity.<br>
--- This function is there to postpone the creation of the multipliers to data-final-fixes, because other mods can create more qualities.
--- @param entity_name string
function default_values.remove_quality_multipliers(entity_name)
    default_values.buildings_needing_quality_multipliers[entity_name] = true
end

if mods["sosciencity-debug"] then
    default_values.DEBUG = true
end

default_values.__index = default_values
setmetatable(Sosciencity_Config, default_values)

return Sosciencity_Config
