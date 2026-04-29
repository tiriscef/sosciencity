local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local Time = require("constants.time")

local get_building_details = Buildings.get
local has_power = Subentities.has_power
local log_item = Statistics.log_item
local floor = math.floor
local min = math.min

---Static class for humus fertilization mechanics.
Entity.Fertilization = {}
local Fertilization = Entity.Fertilization

Fertilization.speed_bonus = 30 --%
Fertilization.workhours = 1 / Time.minute
Fertilization.consumption = 10 / Time.minute --- humus per tick at full operation

--- Consume humus from neighbor fertilization stations to fertilize this farm.
--- Mutates `EK.humus_stored` on contributing stations and logs consumption.
--- @param farm Entry farm-type entry
--- @param delta_ticks integer
--- @return number? speed_bonus percentage (e.g. 18 means +18% speed), or nil if humus mode is off
function Fertilization.consume_for_farm(farm, delta_ticks)
    if not farm[EK.humus_mode] then
        return nil
    end
    if not get_building_details(farm).accepts_plant_care then
        return nil
    end
    if not farm[EK.entity].get_recipe() then
        return nil
    end

    local humus_needed = delta_ticks * Fertilization.consumption
    local percentage_to_consume = 1

    for _, station in Neighborhood.iterate_type(farm, Type.fertilization_station) do
        if station[EK.active] then
            local humus_available = station[EK.humus_stored]
            local percentage_available =
                min(
                    percentage_to_consume,
                    humus_available / humus_needed
                )

            percentage_to_consume = percentage_to_consume - percentage_available
            local consumed_humus = humus_needed * percentage_available
            station[EK.humus_stored] = humus_available - consumed_humus

            log_item("humus", -consumed_humus)

            if percentage_to_consume < 0.0001 then
                break
            end
        end
    end

    local consumed_fraction = 1 - percentage_to_consume
    return consumed_fraction * Fertilization.speed_bonus
end

---------------------------------------------------------------------------------------------------
-- << fertilization station >>

Register.set_entity_updater(
    Type.fertilization_station,
    function(entry, delta_ticks)
        local building_details = get_building_details(entry)

        entry[EK.active] = has_power(entry)

        local humus_stored = entry[EK.humus_stored]
        local free_humus_capacity = building_details.humus_capacity - humus_stored
        if free_humus_capacity >= 10 then
            local inventory = Inventories.get_chest_inventory(entry)
            entry[EK.humus_stored] =
                humus_stored + inventory.remove {name = "humus", count = floor(free_humus_capacity)}
        end
    end
)

Register.set_entity_creation_handler(
    Type.fertilization_station,
    function(entry)
        entry[EK.humus_stored] = 0
    end
)

Register.set_entity_destruction_handler(
    Type.fertilization_station,
    function(entry, cause, event)
        if not entry[EK.entity].valid then
            return
        end

        local humus = floor(entry[EK.humus_stored])

        if cause == DeconstructionCause.destroyed and humus > 0 then
            Inventories.spill_items(entry, "humus", humus / 10)
        end
        if cause == DeconstructionCause.mined and humus > 0 then
            event.buffer.insert {name = "humus", count = humus}
        end
    end
)

Register.set_entity_copy_handler(
    Type.fertilization_station,
    function(source, destination)
        destination[EK.humus_stored] = source[EK.humus_stored]
    end
)
