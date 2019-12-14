Technologies = {}

local relevant_techs = {
    ["clockwork-caste"] = true,
    ["orchid-caste"] = true,
    ["gunfire-caste"] = true,
    ["ember-caste"] = true,
    ["foundry-caste"] = true,
    ["gleam-caste"] = true,
    ["aurora-caste"] = true,
    ["resettlement"] = true,
}

local relevant_multi_level_techs = {

}

---------------------------------------------------------------------------------------------------
-- << general >>
function Technologies.finished(name)
    if relevant_techs[name] then
        global.technologies[name] = true
    end
end

function Technologies.init()
    global.technologies = {}

    local techs = game.forces.player.technologies
    for name, _ in pairs(relevant_techs) do
        global.technologies[name] = techs[name].researched
    end

end

return Technologies
