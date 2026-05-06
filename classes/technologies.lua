local UnlockCondition = require("enums.unlock-condition")
local InformationType = require("enums.information-type")

local Castes = require("constants.castes")
local TechEffects = require("constants.tech-effects")

local castes = Castes.values
local Unlocks = require("constants.unlocks")


--- Static class that keeps track of the research state of important technologies.
Technologies = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.technologies: table
        [tech_name]: bool (researched) or int (level)

    storage.gated_technologies: table
        [tech_name]: bool (is it enabled)
]]
-- local often used globals for humongous performance gains

local tracked_techs = {
    ["transfusion-medicine"] = true,
    ["architecture-1"] = true,
    ["architecture-2"] = true,
    ["architecture-3"] = true,
    ["architecture-4"] = true,
    ["architecture-5"] = true,
    ["architecture-6"] = true,
    ["architecture-7"] = true,
    ["moving-efficiency-1"] = true,
    ["moving-efficiency-2"] = true,
    ["moving-efficiency-3"] = true,
    ["passive-redistribution"] = true,
    ["redistribution-efficiency-1"] = true,
    ["redistribution-efficiency-2"] = true,
}

local tracked_multi_level_techs = {
    ["improved-reproductive-healthcare"] = {}
}

-- add caste techs
for _, caste in pairs(Castes.all) do
    tracked_techs[caste.tech_name] = true
    tracked_multi_level_techs[caste.efficiency_tech] = {}
end

local gated_technologies

local floor = math.floor

local function set_locals()
    gated_technologies = storage.gated_technologies
end

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

    -- case two: there are multiple technologies named 'name-number'
    local details = tracked_multi_level_techs[name]
    while techs[name .. "-" .. (level + 1)].researched do
        level = level + 1
    end

    -- for some reason the level of the infinite technology always returns level + 1
    -- and .researched always returns false
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

--- Sets the technology with the given name to enabled such that it can be researched by the player.
--- @param technology_name string
local function enable(technology_name)
    local tech = game.forces.player.technologies[technology_name]
    tech.enabled = true
    gated_technologies[technology_name] = true
    Communication.inform(InformationType.unlocked_gated_technology, tech.localised_name)
end

local unlocking_condition_check_fns = {
    [UnlockCondition.item_acquisition] = function(condition)
        local production_statistics = game.forces.player.get_item_production_statistics("nauvis")

        return production_statistics.get_input_count(condition.item) > 0
    end,
    [UnlockCondition.caste_points] = function(condition)
        return storage.caste_points[condition.caste] >= condition.count
    end,
    [UnlockCondition.caste_population] = function(condition)
        return storage.population[condition.caste] >= condition.count
    end,
    [UnlockCondition.population] = function(condition)
        return Tirislib.Arrays.sum(storage.population) >= condition.count
    end
}

function Technologies.update()
    -- check the gated technologies
    for technology_name, already_enabled in pairs(gated_technologies) do
        if already_enabled then
            goto continue
        end

        for _, condition in pairs(Unlocks.gated_technologies[technology_name]) do
            if not unlocking_condition_check_fns[condition.type](condition) then
                goto continue
            end
        end

        enable(technology_name)

        ::continue::
    end
end

---------------------------------------------------------------------------------------------------
-- << effects >>

--- Returns the downtime multiplier for the current moving-efficiency research level.
--- Multiply base downtime by this value to get the effective downtime.
function Technologies.get_moving_downtime_factor()
    local level = (storage.technologies["moving-efficiency-1"] and 1 or 0)
                + (storage.technologies["moving-efficiency-2"] and 1 or 0)
                + (storage.technologies["moving-efficiency-3"] and 1 or 0)
    return TechEffects.moving_efficiency_factors[level]
end

--- Returns the fraction of total population to redistribute per passive redistribution pass.
function Technologies.get_redistribution_budget_fraction()
    local level = (storage.technologies["redistribution-efficiency-1"] and 1 or 0)
                + (storage.technologies["redistribution-efficiency-2"] and 1 or 0)
    return TechEffects.redistribution_budget_fractions[level]
end

--- Returns whether the given caste's unlock technology has been researched.
--- @param caste_id Type
--- @return boolean
function Technologies.caste_is_researched(caste_id)
    return storage.technologies[castes[caste_id].tech_name] and true or false
end

--- Returns the level of the efficiency technology for the given caste.
--- @param caste_id Type
--- @return integer
function Technologies.get_caste_efficiency_level(caste_id)
    return storage.technologies[castes[caste_id].efficiency_tech]
end

--- Returns the caste point output multiplier for the given caste's current efficiency level.
--- @param caste_id Type
--- @return number
function Technologies.get_caste_efficiency_multiplier(caste_id)
    return 1 + TechEffects.caste_efficiency_points_per_level * storage.technologies[castes[caste_id].efficiency_tech]
end

--- Returns the birth-defect probability multiplier for the current reproductive healthcare level.
--- Multiply any base birth-defect probability by this value.
--- @return number
function Technologies.get_reproductive_healthcare_factor()
    return TechEffects.reproductive_healthcare_level_factor ^ storage.technologies["improved-reproductive-healthcare"]
end

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

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
