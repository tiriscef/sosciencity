---Static class for the scripting game logic of my entities.
Entity = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local all the frequently called functions for supercalifragilisticexpialidocious performance gains
local global
local caste_bonuses
local water_values = DrinkingWater.values

local floor = math.floor
local random = math.random

local set_beacon_effects = Subentities.set_beacon_effects

local is_affected_by_clockwork = Types.is_affected_by_clockwork
local is_affected_by_orchid = Types.is_affected_by_orchid

local log_fluid = Communication.log_fluid

local get_building_details = Buildings.get

local has_power = Subentities.has_power

local function set_locals()
    global = _ENV.global
    caste_bonuses = global.caste_bonuses
end

function Entity.init()
    set_locals()
end

function Entity.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << beaconed machine >>
local function update_entity_with_beacon(entry)
    local _type = entry[EK.type]
    local speed_bonus = 0
    local productivity_bonus = 0
    local use_penalty_module = false

    if is_affected_by_clockwork(_type) then
        speed_bonus = caste_bonuses[Type.clockwork]
        use_penalty_module = global.use_penalty
    end
    if _type == Type.rocket_silo then
        productivity_bonus = caste_bonuses[Type.aurora]
    end
    if is_affected_by_orchid(_type) then
        productivity_bonus = caste_bonuses[Type.orchid]
    end
    if _type == Type.orangery then
        local age = game.tick - entry[EK.tick_of_creation]
        productivity_bonus = productivity_bonus + math.floor(math.sqrt(age)) -- TODO balance
    end

    set_beacon_effects(entry, speed_bonus, productivity_bonus, use_penalty_module)
end
Register.set_entity_updater(Type.assembling_machine, update_entity_with_beacon)
Register.set_entity_updater(Type.furnace, update_entity_with_beacon)
Register.set_entity_updater(Type.rocket_silo, update_entity_with_beacon)
Register.set_entity_updater(Type.farm, update_entity_with_beacon)
Register.set_entity_updater(Type.mining_drill, update_entity_with_beacon)
Register.set_entity_updater(Type.orangery, update_entity_with_beacon)

---------------------------------------------------------------------------------------------------
-- << immigration port >>
local function schedule_immigration_wave(entry, building_details)
    entry[EK.next_wave] = (entry[EK.next_wave] or game.tick) + building_details.interval + random(building_details.random_interval) - 1
end

local function create_immigration_port(entry)
    schedule_immigration_wave(entry, get_building_details(entry))
end
Register.set_entity_creation_handler(Type.immigration_port, create_immigration_port)

local function update_immigration_port(entry, delta_ticks, current_tick)
    local tick_next_wave = entry[EK.next_wave]
    if current_tick >= tick_next_wave then
        local building_details = get_building_details(entry)
        if Inventories.try_remove_item_range(entry, building_details.materials) then
            Inhabitants.migration_wave(building_details)
        end

        schedule_immigration_wave(entry, building_details)
    end
end
Register.set_entity_updater(Type.immigration_port, update_immigration_port)

---------------------------------------------------------------------------------------------------
-- << manufactory >>
local function update_manufactory(entry)
    Inhabitants.update_workforce(entry)
    local performance = Inhabitants.evaluate_workforce(entry)

    entry[EK.entity].active = performance > 0.4

    local speed = performance > 0.4 and floor(100 * performance - 20) or 0
    set_beacon_effects(entry, speed, 0, true)
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

---------------------------------------------------------------------------------------------------
-- << water distributer >>
local function update_water_distributer(entry)
    local entity = entry[EK.entity]

    -- determine and save the type of water that this distributer provides
    -- this is because it's unlikely to ever change (due to the system that prevents fluids from mixing)
    -- but needs to be checked often
    if has_power(entry) then
        for fluid_name in pairs(entity.get_fluid_contents()) do
            local water_value = water_values[fluid_name]
            if water_value then
                entry[EK.water_quality] = water_value.health
                entry[EK.water_name] = fluid_name
                return
            end
        end
    end
    entry[EK.water_quality] = 0
    entry[EK.water_name] = nil
end
Register.set_entity_updater(Type.water_distributer, update_water_distributer)

---------------------------------------------------------------------------------------------------
-- << waterwell >>
local function update_waterwell(entry, delta_ticks)
    if not has_power(entry) then
        return
    end

    local building_details = get_building_details(entry)
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    local groundwater_volume = (delta_ticks * building_details.speed) / near_count

    local inserted =
        entry[EK.entity].insert_fluid {
        name = "groundwater",
        amount = groundwater_volume
    }
    log_fluid("groundwater", inserted)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)
