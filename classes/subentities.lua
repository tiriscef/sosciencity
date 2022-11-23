local EK = require("enums.entry-key")
local SubentityType = require("enums.subentity-type")

--- Static class that handles hidden entities that hack additional behaviours.
Subentities = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local often used globals for extreme performance gains

Subentities.subentity_name_lookup = {
    [SubentityType.beacon] = "sosciencity-hidden-beacon",
    [SubentityType.turret_gunfire] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq1] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq2] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq3] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq4] = "gunfire-hq-turret"
}
local subentity_names = Subentities.subentity_name_lookup

local get_type = require("constants.types").get

local get_building_details = require("constants.buildings").get

local max = math.max
local get_subtbl = Tirislib.Tables.get_subtbl
local get_or_create_subentity

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
    local beacon, new = get_or_create_subentity(entry, SubentityType.beacon)

    -- we don't update the beacon if nothing has changed to avoid unnecessary API calls
    if
        not new and speed == entry[EK.speed_bonus] and productivity == entry[EK.productivity_bonus] and
            add_penalty == entry[EK.has_penalty_module]
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
    entry[EK.speed_bonus] = speed
    entry[EK.productivity_bonus] = productivity
    entry[EK.has_penalty_module] = add_penalty
end

---------------------------------------------------------------------------------------------------
-- << hidden electric energy interface >>

local function set_eei_power_usage(eei, usage)
    eei.power_usage = usage
    eei.electric_buffer_size = max(1, usage * 60) -- 1 second
end

--- Checks if the entity is supplied with power. Doesn't assume that the entry has an eei.
--- @param entry Entry
function Subentities.has_power(entry)
    local power_usage = entry[EK.power_usage]
    if not power_usage or power_usage == 0 then
        return true
    end

    local eei, new = get_or_create_subentity(entry, SubentityType.eei)
    if new then
        -- the new eei needs to be told its power usage
        set_eei_power_usage(eei, power_usage)
        -- it had to be recreated, so we just return true
        -- (to avoid that things stop working when another mod keeps deleting the eei)
        return true
    else
        -- check if the buffer is partially filled
        return eei.energy > 0
    end
end

--- Sets the power usage of the entity. Implicitly creates the eei.
--- @param entry Entry
--- @param usage number
function Subentities.set_power_usage(entry, usage)
    local eei, new = get_or_create_subentity(entry, SubentityType.eei)

    -- we don't update the eei if nothing has changed to avoid unnecessary API calls
    if new or entry[EK.power_usage] ~= usage then
        set_eei_power_usage(eei, usage)
        entry[EK.power_usage] = usage
    end
end
local set_power_usage = Subentities.set_power_usage

---------------------------------------------------------------------------------------------------
-- << creation >>

local function get_subentity_name(entry, _type)
    if _type == SubentityType.eei then
        return "sosciencity-hidden-eei-" .. entry[EK.name]
    else
        return subentity_names[_type]
    end
end

local function add(entry, _type)
    local building_details = get_building_details(entry)
    local subentities = get_subtbl(entry, EK.subentities)

    local entity = entry[EK.entity]

    local position = entity.position
    local offsets = building_details.subentity_offsets
    if offsets then
        local offset = offsets[_type]
        if offset then
            position.x = position.x + offset.x
            position.y = position.y + offset.y
        end
    end

    local subentity =
        entity.surface.create_entity(
        {
            name = get_subentity_name(entry, _type),
            position = position,
            force = entity.force
        }
    )

    subentities[_type] = subentity

    return subentity
end

local function add_alt_mode_sprite(entry, name)
    local entity = entry[EK.entity]
    entry[EK.alt_mode_sprite] =
        rendering.draw_sprite(
        {
            sprite = name,
            target = entity,
            surface = entity.surface,
            only_in_alt_mode = true
        }
    )
end

--- Adds all the hidden entities this entry needs to work.
--- @param entry Entry
function Subentities.add_all_for(entry)
    local building_details = get_building_details(entry)
    local power_usage = building_details.power_usage
    if power_usage then
        add(entry, SubentityType.eei)
        set_power_usage(entry, power_usage)
    end

    local subentities = building_details.subentities
    if subentities then
        for _, _type in pairs(subentities) do
            add(entry, _type)
        end
    end

    local type_definition = get_type(entry)
    if type_definition.alt_mode_sprite then
        add_alt_mode_sprite(entry, type_definition.alt_mode_sprite)
    end
end

--- Removes all the hidden entities.
--- @param entry Entry
function Subentities.remove_all_for(entry)
    local subentities = entry[EK.subentities]
    if not subentities then
        return
    end

    for _, subentity in pairs(subentities) do
        if subentity.valid then
            subentity.destroy()
        end
    end
    -- we don't need to destroy sprites when their target entity gets destroyed
end

function Subentities.remove_sprites(entry)
    local sprite_id = entry[EK.alt_mode_sprite]

    if sprite_id then
        rendering.destroy(sprite_id)
    end
end

--- Gets the hidden entity of the given type and if it had to be recreated.\
--- Implicitly creates the subentity when the entry didn't have one.
--- @param entry Entry
--- @param _type SubentityType
function Subentities.get_or_create(entry, _type)
    -- the encapsulating table doesn't even exist, the subentity has to be added
    local subentities = entry[EK.subentities]
    if not subentities then
        return add(entry, _type), true
    end

    local subentity = subentities[_type]
    if subentity ~= nil and subentity.valid then
        return subentity, false
    else
        return add(entry, _type), true
    end
end
get_or_create_subentity = Subentities.get_or_create

local subentity_types_where_active_status_makes_sense = {
    SubentityType.turret_gunfire,
    SubentityType.turret_gunfire_hq1,
    SubentityType.turret_gunfire_hq2,
    SubentityType.turret_gunfire_hq3,
    SubentityType.turret_gunfire_hq4
}

--- Sets the active status of all subentities to the given boolean.
--- @param entry Entry
--- @param is_active boolean
function Subentities.set_active(entry, is_active)
    local subentities = entry[EK.subentities]
    if not subentities then
        return
    end

    for _, _type in pairs(subentity_types_where_active_status_makes_sense) do
        local subentity = subentities[_type]

        if subentity then
            if not subentity.valid then
                subentity = add(entry, _type)
            end

            subentity.active = is_active
        end
    end
end

return Subentities
