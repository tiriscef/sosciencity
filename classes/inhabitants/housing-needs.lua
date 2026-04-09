local EK = require("enums.entry-key")
local HappinessFactor = require("enums.happiness-factor")
local HealthFactor = require("enums.health-factor")
local HealthSummand = require("enums.health-summand")
local RenderingType = require("enums.rendering-type")
local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local Biology = require("constants.biology")
local Castes = require("constants.castes")

local castes = Castes.values
local log_fluid = Communication.log_fluid

---------------------------------------------------------------------------------------------------
-- << water >>

--- Consumes the given amount of drinking water from the given distributer entities. Assumes the distributers do have water.
--- @param distributers Entry[]
--- @param amount number
--- @return number satisfaction a factor from 0 to 1 how much of the given amound was actually consumed
--- @return number quality the average quality of the consumes drinking water
local function consume_water(distributers, amount)
    local to_consume = amount
    local quality = 0

    for _, distributer in pairs(distributers) do
        local water_name = distributer[EK.water_name]

        local consumed = distributer[EK.entity].remove_fluid {name = water_name, amount = to_consume}
        log_fluid(water_name, -consumed)
        quality = quality + consumed * distributer[EK.water_quality]
        to_consume = to_consume - consumed

        if to_consume < 0.0001 then
            break
        end
    end

    return (amount - to_consume) / amount, quality / amount
end

--- Evaluates if the house has access to drinking water, consumes it, and evaluates the effects.
--- @param entry Entry
--- @param delta_ticks number
--- @param happiness_factors table
--- @param health_factors table
--- @param health_summands table
function Inhabitants.evaluate_water(entry, delta_ticks, happiness_factors, health_factors, health_summands)
    local distributers = {}

    -- find the available water distributers, filter out the empty ones
    for _, distributer in Neighborhood.iterate_type(entry, Type.water_distributer) do
        if distributer[EK.water_name] ~= nil then
            distributers[#distributers + 1] = distributer
        end
    end

    table.sort(distributers, function(a, b) return a[EK.water_quality] > b[EK.water_quality] end)

    local water_to_consume = castes[entry[EK.type]].water_demand * entry[EK.inhabitants] * delta_ticks
    local satisfaction, quality

    if water_to_consume > 0 then
        satisfaction, quality = consume_water(distributers, water_to_consume)

        if satisfaction < 0.1 then
            Subentities.add_common_sprite(entry, RenderingType.water_warning)
            Communication.warning(WarningType.no_water, entry)
        else
            Subentities.remove_common_sprite(entry, RenderingType.water_warning)
        end
    else
        -- annoying edge case of no inhabitants
        -- test if there is at least one distributer with water
        local probe = distributers[1]
        if probe and probe[EK.water_name] then
            satisfaction = 1
            quality = probe[EK.water_quality]

            Subentities.remove_common_sprite(entry, RenderingType.water_warning)
        else
            satisfaction = 0
            quality = 0

            Subentities.add_common_sprite(entry, RenderingType.water_warning)
        end
    end

    local has_water = satisfaction > 0
    happiness_factors[HappinessFactor.thirst] = has_water and 1. or Biology.dehydration.happiness_factor
    health_factors[HealthFactor.thirst] = has_water and 1. or Biology.dehydration.health_factor
    health_summands[HealthSummand.water] = quality
end
