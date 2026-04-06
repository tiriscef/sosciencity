local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")

local get_building_details = Buildings.get
local get_chest_inventory = Inventories.get_chest_inventory
local floor = math.floor
local min = math.min
local Utils = Tirislib.Utils

---------------------------------------------------------------------------------------------------
-- << composter >>

local function create_composter(entry)
    entry[EK.humus] = 0
    entry[EK.composting_progress] = 0
    entry[EK.necrofall_progress] = 0
end
Register.set_entity_creation_handler(Type.composter, create_composter)

local compost_values = ItemConstants.compost_values
local composting_coefficient = 1 / 400 / 600
local mold_producers = ItemConstants.mold_producers
local necrofall_coefficient = 1 / (10 * Time.minute)
local necrofall_radius = 10 -- tiles

--- Analyzes the given inventory and returns the composting progress per tick and an array of the compostable items.
--- @param content LuaInventory
--- @return number composting_progress per tick
--- @return array compostable_items
local function analyze_composter_inventory(content)
    local item_count = 0
    local item_type_count = 0
    local compostable_items = {}

    for name, count in pairs(content) do
        if compost_values[name] then
            item_count = item_count + count
            item_type_count = item_type_count + 1
            compostable_items[#compostable_items + 1] = name
        end
    end

    return item_count * item_type_count * composting_coefficient, compostable_items
end
Entity.analyze_composter_inventory = analyze_composter_inventory

local function compostify_items(inventory, count, compostable_items, entry, mold_amount)
    Tirislib.Arrays.shuffle(compostable_items)

    local to_remove = count
    for i = 1, #compostable_items do
        local item_name = compostable_items[i]
        local removed = Inventories.try_remove(inventory, item_name, count)

        entry[EK.humus] = entry[EK.humus] + removed * compost_values[item_name]

        if mold_amount < 200 and mold_producers[item_name] then
            mold_amount = mold_amount + Inventories.try_insert(inventory, "mold", min(removed, 200 - mold_amount))
        end

        to_remove = to_remove - removed
        if to_remove == 0 then
            break
        end
    end
end

local function spawn_necrofall(entry, count)
    local entity = entry[EK.entity]
    local position = entity.position
    local surface = entity.surface

    while count > 0 do
        local pos = surface.find_non_colliding_position("trash-site", position, necrofall_radius, 1, false)
        if not pos then
            break
        end
        Utils.add_random_float_offset(pos, 1)

        surface.create_entity {
            name = "necrofall-circle",
            position = pos,
            force = "neutral"
        }

        count = count - 1
    end
end

local function update_composter(entry, delta_ticks)
    local inventory = get_chest_inventory(entry)
    local contents = Inventories.get_contents(inventory)
    local progress_factor, compostable_items = analyze_composter_inventory(contents)

    local progress = entry[EK.composting_progress] + progress_factor * delta_ticks

    if progress >= 1 then
        local to_consume = floor(progress)
        progress = progress - to_consume

        local capacity = get_building_details(entry).capacity
        if capacity > entry[EK.humus] then
            compostify_items(inventory, to_consume, compostable_items, entry, contents["mold"] or 0)
        end
    end

    entry[EK.composting_progress] = progress

    -- check if something is composting at all
    if progress_factor > 0 then
        local necrofall_progress = entry[EK.necrofall_progress] + necrofall_coefficient * delta_ticks

        if necrofall_progress >= 1 then
            local to_spawn = floor(necrofall_progress)

            necrofall_progress = necrofall_progress - to_spawn
            spawn_necrofall(entry, to_spawn)
        end

        entry[EK.necrofall_progress] = necrofall_progress
    end
end
Register.set_entity_updater(Type.composter, update_composter)

local function remove_composter(entry, cause, event)
    if not entry[EK.entity].valid then
        return
    end

    local humus = floor(entry[EK.humus])

    if cause == DeconstructionCause.destroyed and humus > 0 then
        Inventories.spill_items(entry, "humus", humus / 10)
    end
    if cause == DeconstructionCause.mined and humus > 0 then
        event.buffer.insert {name = "humus", count = humus}
    end
end
Register.set_entity_destruction_handler(Type.composter, remove_composter)

local function copy_composter(source, destination)
    destination[EK.composting_progress] = source[EK.composting_progress]
    destination[EK.humus] = source[EK.humus]
    destination[EK.necrofall_progress] = source[EK.necrofall_progress]
end
Register.set_entity_copy_handler(Type.composter, copy_composter)

---------------------------------------------------------------------------------------------------
-- << composter output >>

local function update_composter_output(entry)
    local inventory = get_chest_inventory(entry)

    for _, composter in Neighborhood.iterate_type(entry, Type.composter) do
        local humus_amount = composter[EK.humus]
        local to_output = floor(humus_amount)

        if to_output > 0 then
            local actual_output = Inventories.try_insert(inventory, "humus", to_output)

            composter[EK.humus] = humus_amount - actual_output
        end
    end
end
Register.set_entity_updater(Type.composter_output, update_composter_output)
