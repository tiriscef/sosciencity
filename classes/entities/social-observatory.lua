local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local Castes = require("constants.castes")

local min = math.min
local max = math.max

local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local get_building_details = Buildings.get
local set_crafting_machine_performance = Entity.set_crafting_machine_performance

local function get_all_neighbor_houses(entry)
    return Tirislib.LazyLuaq.from(Castes.all)
        :select_many(function(caste) return Neighborhood.get_by_type(entry, caste.type) end)
end

local function update_social_observatory(entry)
    local building_details = get_building_details(entry)
    local houses = get_all_neighbor_houses(entry)

    local total_population = houses:select_key(EK.inhabitants):sum()
    local target = building_details.target_population
    local population_performance = total_population / (total_population + target)

    local worker_performance = evaluate_workforce(entry)
    local worker_happiness = evaluate_worker_happiness(entry)

    local observatory_count = Neighborhood.get_neighbor_count(entry, Type.social_observatory)
    local competition = (observatory_count + 1) ^ (-0.35)

    local performance = min(worker_performance, population_performance) * competition * worker_happiness

    local unique_castes = houses:distinct_by(function(house) return house[EK.type] end):count()
    local productivity = max(0, unique_castes - building_details.min_castes) * building_details.caste_bonus

    set_crafting_machine_performance(entry, performance, productivity)
end
Register.set_entity_updater(Type.social_observatory, update_social_observatory)

local function build_social_observatory_report(entry)
    local building_details = get_building_details(entry)
    local houses = get_all_neighbor_houses(entry)

    local total_population = houses:select_key(EK.inhabitants):sum()
    local target = building_details.target_population
    local population_performance = total_population / (total_population + target)

    local worker_performance = evaluate_workforce(entry)
    local worker_happiness = evaluate_worker_happiness(entry)

    local observatory_count = Neighborhood.get_neighbor_count(entry, Type.social_observatory)
    local competition = (observatory_count + 1) ^ (-0.35)

    local performance = min(worker_performance, population_performance) * competition * worker_happiness

    local unique_castes = houses:distinct_by(function(house) return house[EK.type] end):count()
    local productivity = max(0, unique_castes - building_details.min_castes) * building_details.caste_bonus

    return {
        [PK.effects] = {
            {
                [PK.effect] = PE.workforce,
                [PK.value] = worker_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck
            },
            {
                [PK.effect] = PE.nearby_population,
                [PK.value] = population_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck,
                [PK.detail] = {"sosciencity.show-nearby-population", total_population}
            },
            {
                [PK.effect] = PE.observatory_competition,
                [PK.value] = competition,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier,
                [PK.detail] = {"sosciencity.show-observatory-competition", observatory_count}
            },
            {
                [PK.effect] = PE.worker_happiness,
                [PK.value] = worker_happiness,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            },
            {
                [PK.effect] = PE.caste_diversity,
                [PK.value] = productivity,
                [PK.dimension] = Dim.productivity,
                [PK.combination] = Comb.flat,
                [PK.detail] = {"sosciencity.show-caste-diversity", unique_castes, building_details.min_castes}
            }
        },
        [PK.results] = {[Dim.speed] = performance, [Dim.productivity] = productivity}
    }
end
Entity.set_performance_report_builder(Type.social_observatory, build_social_observatory_report)

Register.set_entity_creation_handler(
    Type.social_observatory,
    function(entry) entry[EK.performance] = 1 end
)
