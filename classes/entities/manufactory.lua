local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local set_crafting_machine_performance = Entity.set_crafting_machine_performance

local function update_manufactory(entry)
    local worker_performance = evaluate_workforce(entry)
    local worker_happiness = evaluate_worker_happiness(entry)

    local performance = worker_performance * worker_happiness
    set_crafting_machine_performance(entry, performance)

    entry[EK.performance_report] = {
        [PK.effects] = {
            {
                [PK.effect] = PE.workforce,
                [PK.value] = worker_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck
            },
            {
                [PK.effect] = PE.worker_happiness,
                [PK.value] = worker_happiness,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            }
        },
        [PK.results] = {
            [Dim.speed] = performance
        }
    }
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

local function create_manufactory(entry)
    entry[EK.performance] = 1
    entry[EK.performance_report] = {[PK.effects] = {}, [PK.results] = {}}
end
Register.set_entity_creation_handler(Type.manufactory, create_manufactory)
