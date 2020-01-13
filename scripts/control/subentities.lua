Subentities = {}

Subentities.subentity_name_lookup = {
    [SUB_BEACON] = "sosciencity-hidden-beacon",
    [SUB_EEI] = "sosciencity-hidden-eei"
}

---------------------------------------------------------------------------------------------------
-- << general >>
local function add(entry, _type)
    local subentity =
        entry[ENTITY].surface.create_entity {
        name = Subentities.subentity_name_lookup[_type],
        position = entry[ENTITY].position,
        force = entry[ENTITY].force
    }

    entry[SUBENTITIES][_type] = subentity

    return subentity
end

local function add_sprite(entry, name, alt_mode)
    local sprite_id =
        rendering.draw_sprite {
        sprite = name,
        target = entry[ENTITY],
        surface = entry[ENTITY].surface,
        only_in_alt_mode = (alt_mode or false)
    }

    entry[SPRITE] = sprite_id

    return sprite_id
end

--- Adds all the hidden entities this entry needs to work.
--- @param entry Entry
function Subentities.add_all_for(entry)
    local _type = entry[TYPE]

    if Types.needs_beacon(_type) then
        add(entry, SUB_BEACON)
    end
    if Types.needs_eei(_type) then
        add(entry, SUB_EEI)
    end
    if Types.needs_alt_mode_sprite(_type) then
        add_sprite(entry, Types.type_sprite_pairs[_type], true)
    end
end

--- Removes all the hidden entities.
--- @param entry Entry
function Subentities.remove_all_for(entry)
    for _, subentity in pairs(entry[SUBENTITIES]) do
        if subentity.valid then
            subentity.destroy()
        end
    end
    -- we don't need to destroy sprites when their target entity gets destroyed
end

--- Gets the hidden entity of the given type and if it had to be recreated.
--- @param entry Entry
--- @param _type Type
function Subentities.get(entry, _type)
    if not entry[SUBENTITIES][_type] then
        return
    end

    -- there is the possibility that the subentity gets lost
    if entry[SUBENTITIES][_type].valid then
        return entry[SUBENTITIES][_type], false
    else
        -- in this case we simply create a new one
        return add(entry, _type), true
    end
end
local get = Subentities.get

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

--- Sets the transmitted effects of the hidden beacon. Speed and productivity need to be positive.
--- @param entry Entry
--- @param speed number
--- @param productivity number
--- @param add_penalty boolean
function Subentities.set_beacon_effects(entry, speed, productivity, add_penalty)
    local beacon, new = get(entry, SUB_BEACON)

    -- we don't update the beacon if nothing has changed to avoid unnecessary API calls
    if
        not new and speed == entry[SPEED_BONUS] and productivity == entry[PRODUCTIVITY_BONUS] and
            add_penalty == entry[HAS_PENALTY]
     then
        return
    end

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

    -- save the current beacon settings
    entry[SPEED_BONUS] = speed
    entry[PRODUCTIVITY_BONUS] = productivity
    entry[HAS_PENALTY] = add_penalty
end

---------------------------------------------------------------------------------------------------
-- << hidden electric energy interface >>

--- Checks if the entity is supplied with power. Assumes that the entry has an eei.
--- @param entry Entry
function Subentities.has_power(entry)
    local eei, new = get(entry, SUB_EEI)
    if new then
        -- the new eei needs to be told its power usage
        eei.power_usage = entry[POWER_USAGE]
        -- it had to be recreated, so we just return true
        -- (to avoid that things stop working when another mod keeps deleting the eei)
        return true
    else
        -- check if the buffer is partially filled
        return eei.energy > 0
    end
end

--- Sets the power usage of the entity. Assumes that the entry has an eei.
--- @param entry Entry
--- @param usage number
function Subentities.set_power_usage(entry, usage)
    local eei, new = get(entry, SUB_EEI)

    -- we don't update the eei if nothing has changed to avoid unnecessary API calls
    if new or entry[POWER_USAGE] ~= usage then
        eei.power_usage = usage
        entry[POWER_USAGE] = usage
    end
end

return Subentities
