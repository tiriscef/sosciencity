local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")
local WasteDumpOperationMode = require("enums.waste-dump-operation-mode")

local Buildings = require("constants.buildings")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")

local get_building_details = Buildings.get
local get_chest_inventory = Inventories.get_chest_inventory
local log_item = Communication.log_item
local Table = Tirislib.Tables
local floor = math.floor
local min = math.min

local garbage_values = ItemConstants.garbage_values

local function analyze_waste_dump_inventory(inventory)
    local garbage_items = {}
    local garbage_count = 0
    local non_garbage_items = {}

    for item, count in pairs(Inventories.get_contents(inventory)) do
        if garbage_values[item] ~= nil then
            garbage_items[item] = count
            garbage_count = garbage_count + count
        else
            non_garbage_items[item] = count
        end
    end

    return garbage_count, garbage_items, non_garbage_items
end

local function store_garbage(inventory, garbage_items, stored_garbage, to_store)
    for item in pairs(garbage_items) do
        local stored = inventory.remove {name = item, count = to_store}
        stored_garbage[item] = (stored_garbage[item] or 0) + stored
        to_store = to_store - stored

        if to_store < 1 then
            return
        end
    end
end

local function output_garbage(inventory, stored_garbage, to_output)
    for item, count in pairs(stored_garbage) do
        local outputable = min(count, to_output)
        if outputable > 0 then
            local output = inventory.insert {name = item, count = outputable}
            stored_garbage[item] = (count - output > 0) and (count - output) or nil
            to_output = to_output - output

            if to_output < 1 then
                return
            end
        end
    end
end

local function garbagify(inventory, to_garbagify, items, stored_garbage)
    local item_names = Table.get_keyset(items)
    Tirislib.Arrays.shuffle(item_names)

    for _, item_name in pairs(item_names) do
        local garbagified = inventory.remove {name = item_name, count = to_garbagify}
        log_item(item_name, -garbagified)
        log_item("garbage", garbagified)
        stored_garbage.garbage = (stored_garbage.garbage or 0) + garbagified
        to_garbagify = to_garbagify - garbagified

        if to_garbagify < 1 then
            return
        end
    end
end

local dump_store_rate = 200 / Time.second
local dump_output_rate = 400 / Time.second
local press_garbagify_rate = 120 / Time.second

local function update_waste_dump(entry, delta_ticks)
    local mode = entry[EK.waste_dump_mode]
    local store_progress = entry[EK.store_progress]
    local garbagify_progress = entry[EK.garbagify_progress]
    local stored_garbage = entry[EK.stored_garbage]

    local capacity = get_building_details(entry).capacity

    local inventory = get_chest_inventory(entry)
    local garbage_count, garbage_items, non_garbage_items = analyze_waste_dump_inventory(inventory)

    if mode == WasteDumpOperationMode.store then
        store_progress = store_progress + dump_store_rate * delta_ticks

        local to_store = floor(store_progress)
        store_progress = store_progress - to_store

        to_store = min(to_store, capacity - garbage_count)

        if to_store > 0 then
            store_garbage(inventory, garbage_items, stored_garbage, to_store)
        end
    elseif mode == WasteDumpOperationMode.output then
        store_progress = store_progress + dump_output_rate * delta_ticks

        local to_output = floor(store_progress)
        store_progress = store_progress - to_output

        if to_output > 0 then
            output_garbage(inventory, stored_garbage, to_output)
        end
    else
        store_progress = 0
    end

    garbage_count = Table.sum(stored_garbage)

    garbagify_progress =
        garbagify_progress + delta_ticks * (garbage_count / 6000) ^ 0.2 +
        delta_ticks * (entry[EK.press_mode] and press_garbagify_rate or 0)
    local to_garbagify = floor(garbagify_progress)
    garbagify_progress = garbagify_progress - to_garbagify
    if to_garbagify > 0 then
        garbagify(inventory, to_garbagify, non_garbage_items, stored_garbage)
    end

    entry[EK.entity].minable = (garbage_count < 1000)

    --- Garbagified items are stored and can exceed the capacity. This is not ideal but better than stopping the garbagification progress or spilling items.
    --- We try to output items if the capacity is exceeded.
    local over_capacity = Table.sum(stored_garbage) - capacity
    if over_capacity > 0 then
        output_garbage(inventory, stored_garbage, over_capacity)
    end

    entry[EK.store_progress] = store_progress
    entry[EK.garbagify_progress] = garbagify_progress
end
Register.set_entity_updater(Type.waste_dump, update_waste_dump)

local function create_waste_dump(entry)
    entry[EK.stored_garbage] = {}
    entry[EK.waste_dump_mode] = WasteDumpOperationMode.store
    entry[EK.press_mode] = false
    entry[EK.store_progress] = 0
    entry[EK.garbagify_progress] = 0
end
Register.set_entity_creation_handler(Type.waste_dump, create_waste_dump)

local function copy_waste_dump(source, destination)
    destination[EK.stored_garbage] = Table.copy(source[EK.stored_garbage])
    destination[EK.waste_dump_mode] = source[EK.waste_dump_mode]
    destination[EK.press_mode] = source[EK.press_mode]
    destination[EK.store_progress] = source[EK.store_progress]
    destination[EK.garbagify_progress] = source[EK.garbagify_progress]
end
Register.set_entity_copy_handler(Type.waste_dump, copy_waste_dump)

local function paste_waste_dump_settings(source, destination)
    destination[EK.waste_dump_mode] = source[EK.waste_dump_mode]
    destination[EK.press_mode] = source[EK.press_mode]
end
Register.set_settings_paste_handler(Type.waste_dump, Type.waste_dump, paste_waste_dump_settings)

local function remove_waste_dump(entry, cause, event)
    if not entry[EK.entity].valid then
        return
    end

    if cause == DeconstructionCause.destroyed then
        Inventories.spill_item_range(entry, "humus", true)
    end
    if cause == DeconstructionCause.mined then
        for item, count in pairs(entry[EK.stored_garbage]) do
            if count > 0 then
                event.buffer.insert {name = item, count = count}
            end
        end
    end
end
Register.set_entity_destruction_handler(Type.waste_dump, remove_waste_dump)
