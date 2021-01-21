---Static class for the game logic of handcrafting side effects.
Handcrafting = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local all the frequently used globals for underrated performance gains

local floor = math.floor
local min = math.min
local format = string.format
local get_inner_table = Tirislib_Tables.get_inner_table

function Handcrafting.init()
    global.blood_donations = {}
end

local function get_recent_donation_count(player_id)
    local log = get_inner_table(global.blood_donations, player_id)

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

local function blood_donation(player_id)
    local count = get_recent_donation_count(player_id)
    local player = game.players[player_id]
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

    player.print {"sosciencity-gui.donate-blood", count}
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

local function produce_eggs(player_id, recipe_name, count)
    local player = game.players[player_id]
    local inventory = player.get_main_inventory()

    local calories = Inventories.count_calories(inventory)
    local possible_eggs = min(floor(calories / Biology.egg_calories), count)

    if possible_eggs < count then
        player.print {"sosciencity-gui.less-eggs", possible_eggs}

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
                count = count - possible_eggs
            }
        end
    end

    Inventories.consume_calories(inventory, possible_eggs * Biology.egg_calories)
end

local queued_lookup = {
    ["lay-egg"] = produce_eggs
}

function Handcrafting.on_queued(player_id, recipe_name, count)
    local fn = queued_lookup[recipe_name]
    if fn then
        fn(player_id, recipe_name, count)
    end
end

return Handcrafting
