TreePlanting = {}

---------------------------------------------------------------------------------------------------
-- << tree list >>

local tree_list = {}

local dead_keywords = {"dead", "dry", "stump", "burnt"}

local function is_plantable_tree(name, prototype)
    if prototype.autoplace_specification == nil then
        return false
    end
    for _, keyword in pairs(dead_keywords) do
        if name:find(keyword, 1, true) then
            return false
        end
    end
    return true
end

for name, prototype in pairs(prototypes.entity) do
    if prototype.type == "tree" and is_plantable_tree(name, prototype) then
        tree_list[#tree_list + 1] = name
    end
end


local function pick_random_tree()
    return tree_list[math.random(#tree_list)]
end

---------------------------------------------------------------------------------------------------
-- << individual sapling placement >>

-- Called from on_entity_built when the sosciencity-tree-sapling marker entity is placed.
-- Destroys the marker and swaps it for a random natural tree.
function TreePlanting.on_sapling_placed(entity, event)
    local surface = entity.surface
    local position = entity.position
    local player_index = event.player_index

    entity.destroy()

    -- Try a handful of different trees; placement can fail if the tile is e.g. rock
    for _ = 1, 5 do
        local tree_name = pick_random_tree()
        if surface.can_place_entity { name = tree_name, position = position, force = "neutral" } then
            surface.create_entity { name = tree_name, position = position, force = "neutral" }
            return
        end
    end

    -- Could not place any tree - refund the sapling to the player
    if player_index then
        local player = game.get_player(player_index)
        if player then
            player.insert { name = "tree-sapling", count = 1 }
            player.print({ "sosciencity.tree-sapling-placement-failed" })
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << forestry selection tool: grid+jitter area filling >>

local cell_size = 2 -- tiles between grid points
local plant_probability = 0.65 -- fraction of grid cells where a tree is attempted

local function plant_in_area(player, surface, area)
    local sapling_count = player.get_item_count("tree-sapling")
    if sapling_count == 0 then
        player.print({ "sosciencity.no-tree-saplings" })
        return
    end

    local left_top = area.left_top
    local right_bottom = area.right_bottom

    local saplings_used = 0

    local x = left_top.x
    while x < right_bottom.x do
        local y = left_top.y
        while y < right_bottom.y do
            if saplings_used >= sapling_count then
                break
            end

            if math.random() < plant_probability then
                local px = x + math.random() * cell_size
                local py = y + math.random() * cell_size
                local pos = { x = px, y = py }

                -- Only plant on natural tiles (not player-placed concrete/stone)
                local tile = surface.get_tile(pos)
                if tile.prototype.autoplace_specification then
                    for _ = 1, 3 do
                        local tree_name = pick_random_tree()
                        if surface.can_place_entity { name = tree_name, position = pos, force = "neutral" } then
                            surface.create_entity { name = tree_name, position = pos, force = "neutral" }
                            saplings_used = saplings_used + 1
                            break
                        end
                    end
                end
            end

            y = y + cell_size
        end
        if saplings_used >= sapling_count then
            break
        end
        x = x + cell_size
    end

    if saplings_used > 0 then
        player.remove_item { name = "tree-sapling", count = saplings_used }
        player.print({ "sosciencity.trees-planted", saplings_used })
    else
        player.print({ "sosciencity.no-space-for-trees" })
    end
end

function TreePlanting.on_area_selected(event)
    if event.item ~= "forestry-selection-tool" then
        return
    end

    local player = game.get_player(event.player_index)
    if not player then
        return
    end

    plant_in_area(player, event.surface, event.area)
end
