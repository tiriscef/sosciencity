local EK = require("enums.entry-key")
local Type = require("enums.type")

local evaluate_workforce = Inhabitants.evaluate_workforce
local set_crafting_machine_performance = Entity.set_crafting_machine_performance

local function update_manufactory(entry)
    local performance = evaluate_workforce(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

local function create_manufactory(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.manufactory, create_manufactory)
