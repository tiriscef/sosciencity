local Condition = require("enums.condition")
local InformationType = require("enums.information-type")

local Castes = require("constants.castes")
local Unlocks = require("constants.unlocks")

--- Static class that keeps track of the research state of important technologies.
Technologies = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.technologies: table
        [tech_name]: bool (researched) or int (level)

    storage.unlocked: table
        [tech_name]: bool (is it unlocked)

    storage.gated_technologies: table
        [tech_name]: bool (is it enabled)
]]
-- local often used globals for humongous performance gains

local tracked_techs = {
    ["transfusion-medicine"] = true
}

-- add caste techs
for _, caste in pairs(Castes.values) do
    tracked_techs[caste.tech_name] = true
end

local tracked_multi_level_techs = {
    ["clockwork-caste-efficiency"] = {},
    ["orchid-caste-efficiency"] = {},
    ["gunfire-caste-efficiency"] = {},
    ["ember-caste-efficiency"] = {},
    ["foundry-caste-efficiency"] = {},
    ["gleam-caste-efficiency"] = {},
    ["aurora-caste-efficiency"] = {},
    ["plasma-caste-efficiency"] = {},
    ["improved-reproductive-healthcare"] = {}
}

local gated_technologies
local unlocks = Unlocks.by_item_aquisition
local unlocked

local floor = math.floor

---------------------------------------------------------------------------------------------------
-- << general >>

local function determine_tech_level(name)
    local level = 0
    local techs = game.forces.player.technologies

    -- case one: the technology consists of just one infinite tech
    local tech = techs[name]
    if tech then
        return tech.level - 1
    end

    local details = tracked_multi_level_techs[name]
    while techs[name .. "-" .. (level + 1)].researched do
        level = level + 1
    end

    --for some reason the level of the infinite technology always returns level + 1
    --and .researched always returns false
    if level == details.max_finite_level then
        level = techs[name .. "-" .. (level + 1)].level - 1
    end

    return level
end

--- Sets the given binary technologies so they encode the given value.
function Technologies.set_binary_techs(value, name)
    local new_value = value
    local techs = game.forces.player.technologies

    for strength = 0, 20 do
        new_value = floor(value / 2)

        -- if new_value times two doesn't equal value, then the remainder was one
        -- which means that the current lowest binary digit is one and that the corresponding tech should be researched
        techs[strength .. name].researched = (new_value * 2 ~= value)

        value = new_value
    end
end

--- Event handler function for finished technologies.
function Technologies.finished(name)
    if tracked_techs[name] then
        storage.technologies[name] = true
    end

    if tracked_multi_level_techs[name] then
        storage.technologies[name] = determine_tech_level(name)
    end
end

local function unlock(technology_name)
    local tech = game.forces.player.technologies[technology_name]
    tech.researched = true
    unlocked[technology_name] = true
    Communication.inform(InformationType.acquisition_unlock, tech.localised_name)
end

local function enable(technology_name)
    local tech = game.forces.player.technologies[technology_name]
    tech.enabled = true
    gated_technologies[technology_name] = true
    Communication.inform(InformationType.unlocked_gated_technology, tech.localised_name)
end

local condition_fns = {
    [Condition.caste_points] = function(details)
        return storage.caste_points[details.caste] >= details.count
    end
}

function Technologies.update()
    local production

    -- check if the required item was acquired by crafting (shows in the production statistic)
    for technology_name, already_unlocked in pairs(unlocked) do
        if not already_unlocked then
            production = production or game.forces.player.item_production_statistics
            if production.get_input_count(unlocks[technology_name]) > 0 then
                unlock(technology_name)
            end
        end
    end

    -- check the gated technologies
    for technology_name, already_enabled in pairs(gated_technologies) do
        if not already_enabled then
            local met = true

            for _, condition in pairs(Unlocks.gated_technologies[technology_name]) do
                met = met and condition_fns[condition.type](condition)
            end

            if met then
                enable(technology_name)
            end
        end
    end
end

function Technologies.on_mined_entity(inventory)
    for technology_name, already_unlocked in pairs(unlocked) do
        if not already_unlocked then
            if inventory.get_item_count(unlocks[technology_name]) > 0 then
                unlock(technology_name)
            end
        end
    end
end

function Technologies.on_cheat_mode_enabled()
    for technology_name in pairs(unlocked) do
        game.forces.player.technologies[technology_name].researched = true
    end
end

function Technologies.on_cheat_mode_disabled()
    for technology_name, already_unlocked in pairs(unlocked) do
        game.forces.player.technologies[technology_name].researched = already_unlocked
    end
end

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    unlocked = storage.unlocked
    gated_technologies = storage.gated_technologies
end

function Technologies.init()
    local techs = game.forces.player.technologies

    -- tracked technologies
    storage.technologies = {}

    for name in pairs(tracked_techs) do
        storage.technologies[name] = techs[name].researched
    end

    for name in pairs(tracked_multi_level_techs) do
        storage.technologies[name] = determine_tech_level(name)
    end

    -- unlockables
    storage.unlocked = {}

    for tech_name in pairs(unlocks) do
        storage.unlocked[tech_name] = techs[tech_name].researched
    end

    -- gated technologies
    storage.gated_technologies = {}

    for tech_name in pairs(Unlocks.gated_technologies) do
        storage.gated_technologies[tech_name] = techs[tech_name].enabled
    end

    set_locals()
end

function Technologies.load()
    set_locals()
end

return Technologies
