--- Static class that keeps track of the research state of important technologies.
Technologies = {}

--[[
    Data this class stores in global
    --------------------------------
    global.technologies: table
        [tech_name]: bool (researched) or int (level)
]]
-- local often used functions for humongous performance gains
local relevant_techs = {
    ["resettlement"] = true,
}

-- add caste techs
for _, caste in pairs(Castes.values) do
    relevant_techs[caste.tech_name] = true
end

local relevant_multi_level_techs = {

}

local floor = math.floor

---------------------------------------------------------------------------------------------------
-- << general >>
local function determine_multi_level_tech_level(name)
    local level = 0
    local details = relevant_multi_level_techs[name]
    local techs = game.forces.player.technologies

    while techs[name .. "-" .. (level + 1)].researched do
        level = level + 1
    end

    --for some reason the level of the infinite technology always returns level + 1
    --and .researched always returns false
    if level == details.max_finite_level then
        level = techs[name .. "-" .. (level + 1)].level - 1
    end

    global.technologies[name] = (level > 0) and level or false
end

--- Sets the given binary technologies so they encode the given value.
function Technologies.set_binary_techs(value, name)
    local new_value = value
    local techs = game.forces.player.technologies

    for strength = 0, 20 do
        new_value = floor(value / 2)

        -- if new_value times two doesn't equal value, then the remainder was one
        -- which means that the current binary digit is one and that the corresponding tech should be researched
        techs[strength .. name].researched = (new_value * 2 ~= value)

        strength = strength + 1
        value = new_value
    end
end

--- Event handler function for finished technologies.
function Technologies.finished(name)
    if relevant_techs[name] then
        global.technologies[name] = true
    end

    if relevant_multi_level_techs[name] then
        determine_multi_level_tech_level(name)
    end
end

--- Initialize the technology related contents of global.
function Technologies.init()
    global.technologies = {}
    local techs = game.forces.player.technologies

    for name, _ in pairs(relevant_techs) do
        global.technologies[name] = techs[name].researched
    end

    for name, _ in pairs(relevant_multi_level_techs) do
        determine_multi_level_tech_level(name)
    end
end

return Technologies
