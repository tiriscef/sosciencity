Subentities = {}

Subentities.subentity_name_lookup = {
    [SUB_BEACON] = "sosciencity-hidden-beacon",
    [SUB_EEI] = "sosciencity-hidden-eei"
}

---------------------------------------------------------------------------------------------------
-- << general >>
local function add(registered_entity, _type)
    local subentity =
        registered_entity.entity.surface.create_entity {
        name = Subentities.subentity_name_lookup[_type],
        position = registered_entity.entity.position,
        force = registered_entity.entity.force
    }

    registered_entity.subentities[_type] = subentity

    return subentity
end

local function add_sprite(registered_entity, name, alt_mode)
    local sprite_id = rendering.draw_sprite {
        sprite = name,
        target = registered_entity.entity,
        surface = registered_entity.entity.surface,
        only_in_alt_mode = (alt_mode or false)
    }

    registered_entity.sprite = sprite_id

    return sprite_id
end

function Subentities:add_all_for(registered_entity)
    if Types:needs_beacon(registered_entity.type) then
        add(registered_entity, SUB_BEACON)
    end
    if Types:needs_eei(registered_entity.type) then
        add(registered_entity, SUB_EEI)
    end
    if Types:needs_alt_mode_sprite(registered_entity.type) then
        add_sprite(registered_entity, Types.caste_sprites[registered_entity.type], true)
    end
end

function Subentities:get(registered_entity, _type)
    -- there is the possibility that 
    local subentity = registered_entity.subentities[_type] or add(registered_entity, _type)
    return subentity
end

---------------------------------------------------------------------------------------------------
-- << hidden beacons >>
local SPEED_MODULE_NAME = "-sosciencity-speed"
local PRODUCTIVITY_MODULE_NAME = "-sosciencity-productivity"
local PENALTY_MODULE_NAME = "sosciencity-penalty"

local MAX_MODULE_STRENGTH = 14

-- assumes that value is an integer
local function set_binary_modules(beacon_inventory, module_name, value)
    local new_value = value
    local strength = 0

    while value > 0 and strength <= MAX_MODULE_STRENGTH do
        new_value = math.floor(value / 2)

        if new_value * 2 ~= value then
            beacon_inventory.insert {
                name = strength .. module_name,
                count = 1
            }
        end

        strength = strength + 1
        value = new_value
    end
end

-- speed and productivity need to be positive
function Subentities:set_beacon_effects(registered_entity, speed, productivity, add_penalty)
    local beacon = Subentities:get(registered_entity, SUB_BEACON)

    local beacon_inventory = beacon.get_module_inventory()
    beacon_inventory.clear()

    if speed and speed > 0 then
        set_binary_modules(beacon_inventory, SPEED_MODULE_NAME, speed)
    end
    if productivity and productivity > 0 then
        set_binary_modules(beacon_inventory, PRODUCTIVITY_MODULE_NAME, productivity)
    end

    if add_penalty then
        beacon_inventory.insert {name = PENALTY_MODULE_NAME}
    end
end

---------------------------------------------------------------------------------------------------
-- << hidden electric energy interface >>

-- Checks if the entity is supplied with power. Assumes that the entry has an eei.
function Subentities:has_power(registered_entity)
    -- check if the buffer is partially filled
    return Subentities:get(registered_entity, SUB_EEI).power > 0
end

-- Gets the current power usage of a housing entity
local function get_residential_power_consumption(registered_entity)
    local usage_per_inhabitant = Caste(registered_entity).power_demand
    return -1 * registered_entity.inhabitants * usage_per_inhabitant
end

-- Sets the power usage of the entity. Assumes that the entry has an eei.
-- usage seems to be in W
function Subentities:set_power_usage(registered_entity, usage)
    usage = usage or get_residential_power_consumption(registered_entity)
    Subentities:get(registered_entity, SUB_EEI).power_usage = usage
end
