local Biology = require("constants.biology")
local Food = require("constants.food")
local Time = require("constants.time")

---Static class for the game logic of handcrafting side effects.
Handcrafting = {}

--[[
    Data this class stores in storage
    --------------------------------
    nothing
]]
-- local all the frequently used globals for underrated performance gains

local floor = math.floor
local min = math.min
local format = string.format
local get_subtbl = Tirislib.Tables.get_subtbl

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

function Handcrafting.init()
    storage.blood_donations = {}
end

---------------------------------------------------------------------------------------------------
-- << handcrafting finished stuff >>

local function get_recent_donation_count(player_id)
    local log = get_subtbl(storage.blood_donations, player_id)

    local count = 1 -- set to 1, because the current donation counts
    local current_tick = game.tick

    -- count the past donations
    for i = #log, 1, -1 do
        local passed_ticks = current_tick - log[i]

        if passed_ticks < Time.nauvis_day then
            count = count + 1
        else
            log[i] = log[#log]
            log[#log] = nil
        end
    end

    -- log the current donation
    log[#log + 1] = current_tick

    return count
end

local function blood_donation(player_id, _)
    local count = get_recent_donation_count(player_id)
    local player = game.get_player(player_id)
    local character = player.character

    -- give them stickers
    for i = 1, min(count, 5) do
        character.surface.create_entity {
            name = format("blood-donation-%d", i),
            position = character.position,
            target = character
        }
    end

    -- make them suffer
    local damage = count * 49
    character.damage(damage, character.force)

    player.print {"sosciencity.donate-blood", count}
end

local crafted_lookup = {
    ["donate-blood"] = blood_donation
}

--- Event handler function for finished handcrafts.
function Handcrafting.on_craft(player_id, recipe_name)
    local fn = crafted_lookup[recipe_name]
    if fn then
        fn(player_id, recipe_name)
    end
end

---------------------------------------------------------------------------------------------------
-- << handcrafting queued stuff >>

local function consume_calories_per_craft(player_id, recipe_name, count, calories_per_craft, not_enough_calories_key)
    local player = game.get_player(player_id)
    local inventory = player.get_main_inventory()

    local calories_available = Inventories.count_calories(inventory)
    local actual_crafts = min(floor(calories_available / calories_per_craft), count)

    if actual_crafts < count then
        player.print {not_enough_calories_key, actual_crafts}

        local character = player.character

        -- find the last possible entry in the crafting queue of the given recipe
        local queue = character.crafting_queue
        local crafting_index = #queue
        while queue[crafting_index].recipe ~= recipe_name and crafting_index > 0 do
            crafting_index = crafting_index - 1
        end

        -- if crafting_index is 0 then no entry with the given recipe was found
        -- maybe another mod already cancelled it
        if crafting_index > 0 then
            character.cancel_crafting {
                index = crafting_index,
                count = count - actual_crafts
            }
        end
    end

    Inventories.consume_calories(inventory, actual_crafts * calories_per_craft)

    return actual_crafts
end

local function produce_eggs(player_id, recipe_name, count)
    consume_calories_per_craft(player_id, recipe_name, count, Biology.egg_calories, "sosciencity.less-eggs")
end

local function produce_rations(player_id, recipe_name, count)
    consume_calories_per_craft(
        player_id,
        recipe_name,
        count,
        Food.emergency_ration_calories,
        "sosciencity.less-calorie-consuming-crafts"
    )
end

local queued_lookup = {
    ["lay-egg"] = produce_eggs,
    ["sosciencity-emergency-ration"] = produce_rations
}

function Handcrafting.on_queued(player_id, recipe_name, count)
    local fn = queued_lookup[recipe_name]
    if fn then
        fn(player_id, recipe_name, count)
    end
end

return Handcrafting
