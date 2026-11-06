local Type = require("enums.type")

local Building = require("constants.buildings")
local Housing = require("constants.housing")
local InhabitantsConstants = require("constants.inhabitants")
local Types = require("constants.types")

--- Items and inhabitants that the scripted logic of buildings produces, outside of any recipe.
--- Prototype data doesn't show them, so the progression checks (tests/content) read them from here.
--- A new scripted output needs an entry, otherwise the checks consider the item unobtainable.
local ScriptedProducts = {}

--- @class ScriptedProductDefinition
--- @field item string name of the produced item
--- @field producers Type[] building types whose scripted logic produces the item
--- @field needs_inhabitants boolean? whether the logic only runs with inhabitants, in the house or as patients

--- @type ScriptedProductDefinition[]
ScriptedProducts.values = {
    -- housing-update.lua and consumption.lua
    {item = "garbage", producers = {Type.empty_house}, needs_inhabitants = true},
    {item = "food-leftovers", producers = {Type.empty_house}, needs_inhabitants = true},
    -- housing-environment.lua, into the house or an egg collector nearby
    {item = InhabitantsConstants.egg_fertile, producers = {Type.empty_house}, needs_inhabitants = true},
    -- composter.lua: humus and mold directly, necrofall by spawning necrofall circles to mine
    {item = "humus", producers = {Type.composter}},
    {item = "mold", producers = {Type.composter}},
    {item = "necrofall", producers = {Type.composter}},
    -- hospital.lua: reports from treatments, blood bags from donations
    {item = "medical-report", producers = Types.select("admits_patients"), needs_inhabitants = true},
    {item = InhabitantsConstants.blood_donation_item, producers = Types.select("admits_patients"), needs_inhabitants = true}
}

--- Buildings that hatch eggs into inhabitants of the researched breedable castes and send them to a house (upbringing.lua).
ScriptedProducts.hatcheries = {producers = {Type.upbringing_station}}

--- Recipe categories whose recipes buildings carry out by script instead of crafting them.
--- The recipes only exist to show the costs, like the house upgrades in housing-upgrade-info.lua.
--- @type {category: string, producers: Type[]}[]
ScriptedProducts.crafting_categories = {
    {category = "sosciencity-comfort-upgrade", producers = {Type.empty_house}}
}

--- Recipes that a building's script only lets run with a module inserted, by recipe name.
--- Without the module the building works at zero performance, so the module is a hidden ingredient.
--- @type table<string, string> module item name by recipe name
ScriptedProducts.required_modules = {
    -- waterwell.lua: the groundwater pump only pumps clean water through a water filter
    ["clean-water-from-ground"] = "water-filter"
}

--- Returns what an education recipe turns its students into (caste-education.lua: the building's workers
--- graduate into its result caste when the recipe finishes), or nil if the recipe doesn't educate.
--- @param recipe table recipe prototype
--- @return {result: Type, students: Type[]}?
function ScriptedProducts.get_education(recipe)
    for _, category in pairs(recipe.categories or {recipe.category}) do
        local building = Building.values[category:match("^sosciencity%-(.+)$") or ""]
        if building and building.type == Type.caste_education_building then
            return {result = building.result_caste, students = building.workforce.castes}
        end
    end
end

--- Returns the names of all entities of the producer types of the given definition.
--- @param definition ScriptedProductDefinition|{producers: Type[]}
--- @return string[]
function ScriptedProducts.get_producer_entities(definition)
    local types = {}
    for _, producer_type in pairs(definition.producers) do
        types[producer_type] = true
    end

    local entities = {}
    if types[Type.empty_house] then
        for house_name in pairs(Housing.values) do
            entities[#entities + 1] = house_name
        end
    end
    for entity_name, building in pairs(Building.values) do
        if types[building.type] then
            entities[#entities + 1] = entity_name
        end
    end

    return entities
end

return ScriptedProducts
