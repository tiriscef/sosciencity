Inhabitants = {}

---------------------------------------------------------------------------------------------------
-- << general >>
local caste_tech_names = {
    [TYPE_CLOCKWORK] = "clockwork-caste",
    [TYPE_EMBER] = "ember-caste",
    [TYPE_GUNFIRE] = "gunfire-caste",
    [TYPE_GLEAM] = "gleam-caste",
    [TYPE_FOUNDRY] = "foundry-caste",
    [TYPE_ORCHID] = "orchid-caste",
    [TYPE_AURORA] = "aurora-caste"
}

function Inhabitants.caste_is_researched(caste_id)
    return global.technologies[caste_tech_names[caste_id]]
end

function Inhabitants.get_population_count()
    local population_count = 0

    for id, _ in pairs(Types.caste_names) do
        population_count = population_count + global.population[id]
    end

    return population_count
end

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
function Inhabitants.try_add_to_house(entry, count, happiness, healthiness, healthiness_mental)
    local count_moving_in = math.min(count, Housing.get_free_capacity(entry))

    if count_moving_in == 0 then
        return 0
    end

    global.effective_population[entry.type] =
        global.effective_population[entry.type] -
        entry.inhabitants * get_effective_population_multiplier(entry.happiness)

    happiness = happiness or DEFAULT_HAPPINESS
    healthiness = healthiness or DEFAULT_HEALTHINESS
    healthiness_mental = healthiness_mental or DEFAULT_HEALTHINESS_MENTAL

    entry.happiness = Tirislib_Utils.weighted_average(entry.happiness, entry.inhabitants, happiness, count_moving_in)
    entry.healthiness = Tirislib_Utils.weighted_average(entry.healthiness, entry.inhabitants, healthiness, count_moving_in)
    entry.healthiness_mental =
        Tirislib_Utils.weighted_average(entry.healthiness_mental, entry.inhabitants, healthiness_mental, count_moving_in)
    entry.inhabitants = entry.inhabitants + count_moving_in

    global.population[entry.type] = global.population[entry.type] + count_moving_in
    global.effective_population[entry.type] =
        global.effective_population[entry.type] +
        entry.inhabitants * get_effective_population_multiplier(entry.happiness)

    return count_moving_in
end

function Inhabitants.remove(entry, count)
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

function Inhabitants.remove_house(entry)
    Inhabitants.remove(entry, entry.inhabitants)
end

local INFLUX_COEFFICIENT = 1. / 60 -- TODO balance
local MINIMAL_HAPPINESS = 5

function Inhabitants.get_trend(entry, delta_ticks)
    return INFLUX_COEFFICIENT * delta_ticks * (entry.happiness - MINIMAL_HAPPINESS)
end

---------------------------------------------------------------------------------------------------
-- << resettlement >>
-- looks for housings to move the inhabitants of this entry to
-- returns the number of resettled inhabitants
function Inhabitants.try_resettle(entry)
    if not global.technologies["resettlement"] or not Types.is_inhabited(entry.type) then
        return 0
    end

    local to_resettle = entry.inhabitants
    for _, current_entry in Register.all_of_type(entry.type) do
        local resettled_count =
            Inhabitants.try_add_to_house(
            current_entry,
            to_resettle,
            entry.happiness,
            entry.healthiness,
            entry.mental_healthiness
        )
        to_resettle = to_resettle - resettled_count

        if to_resettle == 0 then
            break
        end
    end

    return entry.inhabitants - to_resettle
end

---------------------------------------------------------------------------------------------------
-- << caste bonus functions >>
-- sets the hidden caste-technologies so they encode the given value
local function set_binary_techs(value, name)
    local new_value = value
    local strength = 0
    local techs = game.forces.player.technologies

    while value > 0 and strength <= 20 do
        new_value = math.floor(value / 2)

        -- if new_value times two doesn't equal value, then the remainder was one
        -- which means that the current binary decimal is one and that the corresponding tech should be researched
        techs[strength .. name].researched = (new_value * 2 ~= value)

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

function Inhabitants.update_caste_bonuses()
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = Inhabitants.get_gunfire_bonus()
    if global.gunfire_bonus ~= current_gunfire_bonus then
        set_gunfire_bonus(current_gunfire_bonus)
    end

    local current_gleam_bonus = Inhabitants.get_gleam_bonus()
    if global.gleam_bonus ~= current_gleam_bonus then
        set_gleam_bonus(current_gleam_bonus)
    end

    local current_foundry_bonus = Inhabitants.get_foundry_bonus()
    if global.foundry_bonus ~= current_foundry_bonus then
        set_foundry_bonus(current_foundry_bonus)
    end
end

function Inhabitants.get_clockwork_bonus()
    return math.floor(global.effective_population[TYPE_CLOCKWORK] * 40 / math.max(global.machine_count, 1))
end

function Inhabitants.get_orchid_bonus()
    return math.floor(math.sqrt(global.effective_population[TYPE_ORCHID]))
end

function Inhabitants.get_gunfire_bonus()
    return math.floor(global.effective_population[TYPE_GUNFIRE] * 10 / math.max(global.turret_count, 1)) -- TODO balancing
end

function Inhabitants.get_ember_bonus()
    return math.floor(math.sqrt(global.effective_population[TYPE_EMBER] / Inhabitants.get_population_count()))
end

function Inhabitants.get_foundry_bonus()
    return math.floor(global.effective_population[TYPE_FOUNDRY] * 5)
end

function Inhabitants.get_gleam_bonus()
    return math.floor(math.sqrt(global.effective_population[TYPE_GLEAM]))
end

function Inhabitants.get_aurora_bonus()
    return math.floor(math.sqrt(global.effective_population[TYPE_AURORA]))
end

local bonus_function_lookup = {
    [TYPE_CLOCKWORK] = Inhabitants.get_clockwork_bonus,
    [TYPE_ORCHID] = Inhabitants.get_orchid_bonus,
    [TYPE_GUNFIRE] = Inhabitants.get_gunfire_bonus,
    [TYPE_EMBER] = Inhabitants.get_ember_bonus,
    [TYPE_FOUNDRY] = Inhabitants.get_foundry_bonus,
    [TYPE_GLEAM] = Inhabitants.get_gleam_bonus,
    [TYPE_AURORA] = Inhabitants.get_aurora_bonus
}

function Inhabitants.get_caste_bonus(caste_id)
    return bonus_function_lookup[caste_id]()
end

---------------------------------------------------------------------------------------------------
-- << panic >>
function Inhabitants.ease_panic()
    local delta_ticks = game.tick - global.last_update

    -- TODO
end

function Inhabitants.add_panic()
    global.last_panic_event = game.tick
    global.panic = global.panic + 1 -- TODO balancing
end

function Inhabitants.init()
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
