local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")
local Buildings = require("constants.buildings")

local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local get_building_details = Buildings.get
local set_crafting_machine_performance = Entity.set_crafting_machine_performance

local function update_manufactory(entry)
    local worker_performance = evaluate_workforce(entry)
    local worker_happiness = evaluate_worker_happiness(entry)

    local performance = worker_performance * worker_happiness

    local mining_productivity_bonus = nil
    if get_building_details(entry).profits_from_mining_productivity then
        mining_productivity_bonus = math.floor(entry[EK.entity].force.mining_drill_productivity_bonus * 100)
    end

    set_crafting_machine_performance(entry, performance, mining_productivity_bonus)

    local effects = {
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
    }

    if mining_productivity_bonus then
        effects[#effects + 1] = {
            [PK.effect] = PE.mining_productivity,
            [PK.value] = mining_productivity_bonus,
            [PK.dimension] = Dim.productivity,
            [PK.combination] = Comb.flat
        }
    end

    entry[EK.performance_report] = {
        [PK.effects] = effects,
        [PK.results] = {
            [Dim.speed] = performance,
            [Dim.productivity] = mining_productivity_bonus
        }
    }
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

local function create_manufactory(entry)
    entry[EK.performance] = 1
    entry[EK.performance_report] = {[PK.effects] = {}, [PK.results] = {}}
end
Register.set_entity_creation_handler(Type.manufactory, create_manufactory)
