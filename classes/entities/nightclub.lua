local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local has_power = Subentities.has_power
local evaluate_workforce = Inhabitants.evaluate_workforce

-- 1000 mixtapes: 156%
-- 10000 mixtapes: 200%

local culture_coefficient = 0.1
local culture_exponent = 0.25

local function get_culture_bonus()
    local stats = game.forces.player.get_item_production_statistics("nauvis")
    local total_mixtapes = stats.get_output_count("mixtape")

    if total_mixtapes <= 0 then
        return 1
    end

    return 1 + culture_coefficient * total_mixtapes ^ culture_exponent
end

local function update_nightclub(entry)
    if not has_power(entry) then
        entry[EK.performance] = 0
        return
    end

    local worker_performance = evaluate_workforce(entry)
    entry[EK.performance] = worker_performance * get_culture_bonus()
end
Register.set_entity_updater(Type.nightclub, update_nightclub)

local function build_nightclub_report(entry)
    if not has_power(entry) then
        return {
            [PK.effects] = {{[PK.effect] = PE.power, [PK.value] = 0, [PK.dimension] = Dim.speed, [PK.combination] = Comb.bottleneck}},
            [PK.results] = {[Dim.speed] = 0}
        }
    end

    local worker_performance = evaluate_workforce(entry)
    local culture_bonus = get_culture_bonus()

    return {
        [PK.effects] = {
            {
                [PK.effect] = PE.workforce,
                [PK.value] = worker_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck
            },
            {
                [PK.effect] = PE.culture_bonus,
                [PK.value] = culture_bonus,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            }
        },
        [PK.results] = {[Dim.speed] = worker_performance * culture_bonus}
    }
end
Entity.set_performance_report_builder(Type.nightclub, build_nightclub_report)

local function create_nightclub(entry)
    entry[EK.performance] = 0
    Inhabitants.social_environment_change()
end
Register.set_entity_creation_handler(Type.nightclub, create_nightclub)

local function remove_nightclub()
    Inhabitants.social_environment_change()
end
Register.set_entity_destruction_handler(Type.nightclub, remove_nightclub)
