Inhabitants = {}

---------------------------------------------------------------------------------------------------
-- << inhabitant functions >>
local function get_effective_population_multiplier(happiness)
    return math.min(1, 1 + (happiness - 5) * 0.1)
end

local DEFAULT_HAPPINESS = 5
local DEFAULT_HEALTHINESS = 5
local DEFAULT_HEALTHINESS_MENTAL = 10

-- Tries to add the specified amount of inhabitants to the house-entry
-- Returns the number of inhabitants that were added
function Inhabitants:try_add_to_house(entry, count, happiness, healthiness, healthiness_mental)
    local count_moving_in = math.min(count, Housing:get_free_capacity(entry))

    if count_moving_in == 0 then
        return 0
    end

    global.effective_population[entry.type] =
        global.effective_population[entry.type] -
        entry.inhabitants * get_effective_population_multiplier(entry.happiness)

    happiness = happiness or DEFAULT_HAPPINESS
    healthiness = healthiness or DEFAULT_HEALTHINESS
    healthiness_mental = healthiness_mental or DEFAULT_HEALTHINESS_MENTAL

    entry.happiness = Utils.weighted_average(entry.happiness, entry.inhabitants, happiness, count_moving_in)
    entry.healthiness = Utils.weighted_average(entry.healthiness, entry.inhabitants, healthiness, count_moving_in)
    entry.healthiness_mental =
        Utils.weighted_average(entry.healthiness_mental, entry.inhabitants, healthiness_mental, count_moving_in)
    entry.inhabitants = entry.inhabitants + count_moving_in

    global.population[entry.type] = global.population[entry.type] + count_moving_in
    global.effective_population[entry.type] =
        global.effective_population[entry.type] +
        entry.inhabitants * get_effective_population_multiplier(entry.happiness)

    return count_moving_in
end

function Inhabitants:remove(entry, count)
    local count_moving_out = math.min(entry.inhabitants, count)

    if count_moving_out == 0 then
        return 0
    end

    global.effective_population[entry.type] =
        global.effective_population[entry.type] -
        count_moving_out * get_effective_population_multiplier(entry.happiness)
    global.population[entry.type] = global.population[entry.type] - count_moving_out
    entry.inhabitants = entry.inhabitants - count_moving_out

    return count_moving_out
end

function Inhabitants:remove_house(entry)
    Inhabitants:remove(entry, entry.inhabitants)
end

local INFLUX_COEFFICIENT = 1. / 60 -- TODO balance
local MINIMAL_HAPPINESS = 5

function Inhabitants:get_trend(entry, delta_ticks)
    return INFLUX_COEFFICIENT * delta_ticks * (entry.happiness - MINIMAL_HAPPINESS)
end

---------------------------------------------------------------------------------------------------
-- << resettlement >>
local function resettlement_is_researched(force)
    return force.technologies["resettlement"].researched
end

-- looks for housings to move the inhabitants of this entry to
-- returns the number of resettled inhabitants
function Inhabitants.try_resettle(entry)
    if not resettlement_is_researched(entry.entity.force) or not Types:is_inhabited(entry.type) then
        return 0
    end

    local to_resettle = entry.inhabitants
    for _, current_entry in Register:all_of_type(entry.type) do
        local resettled_count = Inhabitants:try_add_to_house(current_entry, to_resettle, entry.happiness, entry.healthiness, entry.mental_healthiness)
        to_resettle = to_resettle - resettled_count

        if to_resettle == 0 then
            break
        end
    end

    return entry.inhabitants - to_resettle
end

---------------------------------------------------------------------------------------------------
-- << caste bonus functions >>
local function set_researched(tech_name, is_researched)
    -- we just do that in every force, because I don't want to support multiple player factions
    for _, force in pairs(game.forces) do
        force.technologies[tech_name].researched = is_researched
    end
end

-- sets the hidden caste-technologies so they encode the given value
local function set_binary_techs(value, name)
    local new_value = value
    local strength = 0

    while value > 0 and strength <= 20 do
        new_value = math.floor(value / 2)

        -- if new_value times two doesn't equal value, then the remainder was one
        -- which means that the current binary decimal is one and that the corresponding tech should be researched
        set_researched(strength .. name, new_value * 2 ~= value)

        strength = strength + 1
        value = new_value
    end
end

-- Assumes value is an integer
local function set_gunfire_bonus(value)
    set_binary_techs(value, "-gunfire-caste")
    global.gunfire_bonus = value
end

-- Assumes value is an integer
local function set_gleam_bonus(value)
    set_binary_techs(value, "-gleam-caste")
    global.gleam_bonus = value
end

-- Assumes value is an integer
local function set_foundry_bonus(value)
    set_binary_techs(value, "-foundry-caste")
    global.foundry_bonus = value
end

function Inhabitants:update_caste_bonuses()
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = Inhabitants:get_gunfire_bonus(global.effective_population[TYPE_GUNFIRE])
    if global.gunfire_bonus ~= current_gunfire_bonus then
        set_gunfire_bonus(current_gunfire_bonus)
    end

    local current_gleam_bonus = Inhabitants:get_gleam_bonus(global.effective_population[TYPE_GLEAM])
    if global.gleam_bonus ~= current_gleam_bonus then
        set_gleam_bonus(current_gleam_bonus)
    end

    local current_foundry_bonus = Inhabitants:get_foundry_bonus(global.effective_population[TYPE_FOUNDRY])
    if global.foundry_bonus ~= current_foundry_bonus then
        set_foundry_bonus(current_foundry_bonus)
    end
end

function Inhabitants:get_clockwork_bonus(effective_population)
    return math.floor(effective_population * 40 / math.max(global.machine_count, 1))
end

function Inhabitants:get_gunfire_bonus(effective_population)
    return math.floor(effective_population * 10 / math.max(global.turret_count, 1)) -- TODO balancing
end

function Inhabitants:get_gleam_bonus(effective_population)
    return math.floor(math.sqrt(effective_population))
end

function Inhabitants:get_foundry_bonus(effective_population)
    return math.floor(effective_population * 5)
end

function Inhabitants:get_aurora_bonus(effective_population)
    return math.floor(math.sqrt(effective_population))
end

---------------------------------------------------------------------------------------------------
-- << panic >>
function Inhabitants:ease_panic()
    local delta_ticks = game.tick - global.last_update

    -- TODO
end

function Inhabitants:add_panic()
    global.last_panic_event = game.tick
    global.panic = global.panic + 1 -- TODO balancing
end

function Inhabitants:init()
    global.panic = 0
    global.population = {
        [TYPE_CLOCKWORK] = 0,
        [TYPE_EMBER] = 0,
        [TYPE_GUNFIRE] = 0,
        [TYPE_GLEAM] = 0,
        [TYPE_FOUNDRY] = 0,
        [TYPE_ORCHID] = 0,
        [TYPE_AURORA] = 0,
        [TYPE_PLASMA] = 0
    }
    global.effective_population = {
        [TYPE_CLOCKWORK] = 0,
        [TYPE_EMBER] = 0,
        [TYPE_GUNFIRE] = 0,
        [TYPE_GLEAM] = 0,
        [TYPE_FOUNDRY] = 0,
        [TYPE_ORCHID] = 0,
        [TYPE_AURORA] = 0,
        [TYPE_PLASMA] = 0
    }
    global.gunfire_bonus = 0
    global.gleam_bonus = 0
    global.foundry_bonus = 0
end

return Inhabitants
