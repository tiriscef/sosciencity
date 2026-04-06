local EK = require("enums.entry-key")
local Type = require("enums.type")

local has_power = Subentities.has_power
local evaluate_workforce = Inhabitants.evaluate_workforce

local function update_nightclub(entry)
    if not has_power(entry) then
        entry[EK.performance] = 0
        return
    end

    local worker_performance = evaluate_workforce(entry)

    -- TODO consume and evaluate drinks

    entry[EK.performance] = worker_performance
end
Register.set_entity_updater(Type.nightclub, update_nightclub)

local function create_nightclub(entry)
    entry[EK.performance] = 0
    Inhabitants.social_environment_change()
end
Register.set_entity_creation_handler(Type.nightclub, create_nightclub)

local function remove_nightclub()
    Inhabitants.social_environment_change()
end
Register.set_entity_destruction_handler(Type.nightclub, remove_nightclub)
