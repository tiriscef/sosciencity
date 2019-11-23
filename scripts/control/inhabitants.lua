Inhabitants = {}

---------------------------------------------------------------------------------------------------
-- << inhabitant functions >>
function Inhabitants:add_inhabitants(registered_entity, count, happiness, healthiness, healthiness_mental)
    local count_moving_in = math.min(count, Housing:get_free_capacity(registered_entity))

    if count_moving_in == 0 then
        return 0
    end

    registered_entity.happiness =
        Utils.weighted_average(
        registered_entity.happiness,
        registered_entity.inhabitants,
        happiness,
        count_moving_in
    )
    registered_entity.healthiness =
        Utils.weighted_average(
        registered_entity.healthiness,
        registered_entity.inhabitants,
        healthiness,
        count_moving_in
    )
    registered_entity.healthiness_mental =
        Utils.weighted_average(
        registered_entity.healthiness_mental,
        registered_entity.inhabitants,
        healthiness_mental,
        count_moving_in
    )
    registered_entity.inhabitants = registered_entity.inhabitants + count_moving_in

    return count_moving_in
end

local INFLUX_COEFFICIENT = 1. / 60 -- TODO balance
local MINIMAL_HAPPINESS = 5

function Inhabitants:get_trend(registered_entity, delta_ticks)
    return INFLUX_COEFFICIENT * delta_ticks * (registered_entity.happiness - MINIMAL_HAPPINESS)
end