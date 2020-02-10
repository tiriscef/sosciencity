Technologies = {}

local relevant_techs = {
    ["resettlement"] = true,
}

-- add caste techs
for _, caste in pairs(Castes.values) do
    relevant_techs[caste.tech_name] = true
end

local relevant_multi_level_techs = {

}

---------------------------------------------------------------------------------------------------
-- << general >>
local function determine_multi_level_tech_level(name)
    local techs = game.force.player.technologies
    local level = 0
    local details = relevant_multi_level_techs[name]

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

function Technologies.finished(name)
    if relevant_techs[name] then
        global.technologies[name] = true
    end

    if relevant_multi_level_techs[name] then
        determine_multi_level_tech_level(name)
    end
end

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
