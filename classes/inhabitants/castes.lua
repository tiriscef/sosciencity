local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local Castes = require("constants.castes")

local castes = Castes.values
local Tables = Tirislib.Tables
local Utils = Tirislib.Utils
local floor = math.floor
local floor_to_step = Utils.floor_to_step
local map_range = Utils.map_range
local max = math.max

local set_binary_techs = Technologies.set_binary_techs

---------------------------------------------------------------------------------------------------
-- << caste research >>

--- Checks if the given caste has been researched by the player.
--- @param caste_id Type
--- @return boolean
function Inhabitants.caste_is_researched(caste_id)
    return storage.technologies[castes[caste_id].tech_name] and true or false
end

--- Returns the level of the efficiency technology for the given caste.
--- @param caste_id Type
--- @return integer
function Inhabitants.get_caste_efficiency_level(caste_id)
    return storage.technologies[castes[caste_id].efficiency_tech]
end

--- Returns the total number of inhabitants.
--- @param pop table? population table, defaults to storage.population
--- @return integer
function Inhabitants.get_population_count(pop)
    return Tables.sum(pop or storage.population)
end

--- Converts happiness and strike level to the caste bonus point multiplier.
--- Above the strike threshold, happiness contributes 0.1 per point.
--- Below it, the multiplier drops sharply and scales with how settled the strike is.
--- @param happiness number
--- @param strike_level number 0 (no strike) to 1 (full strike)
--- @param caste table
--- @return number
local function get_caste_bonus_multiplier(happiness, strike_level, caste)
    if happiness >= caste.strike_begin_threshold then
        return 1 + (happiness - caste.strike_begin_threshold) * 0.1
    else
        return strike_level * caste.full_strike_point_multiplier
    end
end
Inhabitants.get_caste_bonus_multiplier = get_caste_bonus_multiplier

---------------------------------------------------------------------------------------------------
-- << caste bonus calculations >>

--- Gets the Clockwork caste bonus.
--- @param points number? clockwork caste points, defaults to storage value
--- @param maintenance_cost integer? active machine count, defaults to storage value
--- @return integer
local function get_clockwork_bonus(points, maintenance_cost)
    points = points or storage.caste_points[Type.clockwork]
    maintenance_cost = maintenance_cost or storage.active_machine_count

    if storage.maintenance_enabled then
        local maintenance_points = points + storage.starting_clockwork_points

        if maintenance_cost > maintenance_points then
            return floor(map_range(maintenance_cost, maintenance_points, max(1, 2 * maintenance_points), 0, -60))
        end

        points = points - max(0, maintenance_cost - storage.starting_clockwork_points)
    end

    return floor(5 * (max(0, points) / max(1, maintenance_cost)) ^ 0.8)
end
Inhabitants.get_clockwork_bonus = get_clockwork_bonus

--- Gets the Orchid caste bonus.
--- @param points number? orchid caste points, defaults to storage value
--- @return integer
local function get_orchid_bonus(points)
    points = points or storage.caste_points[Type.orchid]
    return floor(max(0, points) ^ 0.5)
end
Inhabitants.get_orchid_bonus = get_orchid_bonus

--- Gets the Gunfire caste bonus.
--- @param points number? gunfire caste points, defaults to storage value
--- @param turret_count integer? number of turrets, defaults to current count
--- @return integer
local function get_gunfire_bonus(points, turret_count)
    points = points or storage.caste_points[Type.gunfire]
    turret_count = turret_count or Register.get_type_count(Type.turret)
    return floor(10 * max(0, points) / max(turret_count, 1))
end
Inhabitants.get_gunfire_bonus = get_gunfire_bonus

--- Gets the Ember caste bonus.
--- @param points number? ember caste points, defaults to storage value
--- @param pop table? population table, defaults to storage.population
--- @return number
local function get_ember_bonus(points, pop)
    points = points or storage.caste_points[Type.ember]
    pop = pop or storage.population
    local non_ember_population = Tables.sum(pop) - pop[Type.ember]
    if non_ember_population > 0 then
        return floor_to_step((3 * max(0, points) / non_ember_population) ^ 0.6, 0.1)
    else
        return 0
    end
end
Inhabitants.get_ember_bonus = get_ember_bonus

--- Gets the Foundry caste bonus.
--- @param points number? foundry caste points, defaults to storage value
--- @return integer
local function get_foundry_bonus(points)
    points = points or storage.caste_points[Type.foundry]
    return floor(max(0, points * 5) ^ 0.5)
end
Inhabitants.get_foundry_bonus = get_foundry_bonus

--- Gets the Gleam caste bonus.
--- @param points number? gleam caste points, defaults to storage value
--- @return integer
local function get_gleam_bonus(points)
    points = points or storage.caste_points[Type.gleam]
    return floor(max(0, points) ^ 0.5)
end
Inhabitants.get_gleam_bonus = get_gleam_bonus

--- Gets the Aurora caste bonus.
--- @param points number? aurora caste points, defaults to storage value
--- @return integer
local function get_aurora_bonus(points)
    points = points or storage.caste_points[Type.aurora]
    return floor(max(0, points) ^ 0.5)
end
Inhabitants.get_aurora_bonus = get_aurora_bonus

--- Gets the Plasma caste bonus.
--- @param points number? plasma caste points, defaults to storage value
--- @param pop table? population table, defaults to storage.population
--- @return number
local function get_plasma_bonus(points, pop)
    points = points or storage.caste_points[Type.plasma]
    pop = pop or storage.population
    local non_plasma_population = Tables.sum(pop) - pop[Type.plasma]
    if non_plasma_population > 0 then
        return floor_to_step((max(0, points) / non_plasma_population) ^ 0.5, 0.1)
    else
        return 0
    end
end
Inhabitants.get_plasma_bonus = get_plasma_bonus

---------------------------------------------------------------------------------------------------
-- << caste bonus update >>

--- Updates all the caste bonuses and applies the ones that are implemented as hidden technologies.
local function update_caste_bonuses()
    local caste_bonuses = storage.caste_bonuses

    local old_clockwork_bonus = caste_bonuses[Type.clockwork]
    local new_clockwork_bonus = get_clockwork_bonus()
    caste_bonuses[Type.clockwork] = new_clockwork_bonus

    if old_clockwork_bonus >= 0 and new_clockwork_bonus < 0 then
        Communication.warning(WarningType.insufficient_maintenance)
    end
    if new_clockwork_bonus <= -40 then
        Communication.warning(WarningType.badly_insufficient_maintenance)
    end

    caste_bonuses[Type.orchid] = get_orchid_bonus()
    caste_bonuses[Type.ember] = get_ember_bonus()
    --caste_bonuses[Type.aurora] = get_aurora_bonus()
    caste_bonuses[Type.plasma] = get_plasma_bonus()

    -- hidden technology based bonuses
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = get_gunfire_bonus()
    if caste_bonuses[Type.gunfire] ~= current_gunfire_bonus then
        set_binary_techs(current_gunfire_bonus, "-gunfire-caste")
        caste_bonuses[Type.gunfire] = current_gunfire_bonus
    end

    local current_foundry_bonus = get_foundry_bonus()
    if caste_bonuses[Type.foundry] ~= current_foundry_bonus then
        set_binary_techs(current_foundry_bonus, "-foundry-caste")
        caste_bonuses[Type.foundry] = current_foundry_bonus
    end

    local current_gleam_bonus = get_gleam_bonus()
    if caste_bonuses[Type.gleam] ~= current_gleam_bonus then
        set_binary_techs(current_gleam_bonus, "-gleam-caste")
        caste_bonuses[Type.gleam] = current_gleam_bonus
    end
end
Inhabitants.update_caste_bonuses = update_caste_bonuses
