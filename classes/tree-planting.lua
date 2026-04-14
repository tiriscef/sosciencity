TreePlanting = {}

---------------------------------------------------------------------------------------------------
-- << tree list >>

-- Cached per surface index so trees from other Space Age planets are excluded.
local tree_lists = {}

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

-- Returns the surface property values for the planet associated with this surface,
-- or an empty table if the surface has no planet (e.g. vanilla without Space Age).
local function get_planet_surface_properties(surface)
    local planet = surface.planet
    if planet then
        return planet.prototype.surface_properties
    end
    return {}
end

-- Checks whether all surface_conditions of a prototype are satisfied by the given
-- planet surface properties. Entities with no conditions pass unconditionally.
local function meets_surface_conditions(prototype, planet_properties)
    local conditions = prototype.surface_conditions
    if not conditions or #conditions == 0 then
        return true
    end
    for _, condition in pairs(conditions) do
        local value = planet_properties[condition.property]
        if value == nil or value < condition.min or value > condition.max then
            return false
        end
    end
    return true
end

local function get_tree_list(surface)
    local index = surface.index
    if tree_lists[index] then
        return tree_lists[index]
    end

    local active_controls = surface.map_gen_settings.autoplace_controls
    local planet_properties = get_planet_surface_properties(surface)
    local trees = {}

    for name, prototype in pairs(prototypes.entity) do
        if prototype.type == "tree" and is_plantable_tree(name, prototype) then
            local autoplace = prototype.autoplace_specification

            -- Control-based autoplace: check the control is active on this surface.
            -- Expression-based autoplace: rely on surface_conditions.

            -- If no surface_conditions are defined we have no way to determine surface affinity,
            -- so we exclude rather than guess.

            local fits_surface
            if autoplace.control then
                fits_surface = active_controls[autoplace.control] ~= nil
            else
                local conditions = prototype.surface_conditions
                fits_surface = conditions and #conditions > 0
                    and meets_surface_conditions(prototype, planet_properties)
            end
            if fits_surface then
                trees[#trees + 1] = name
            end
        end
    end

    tree_lists[index] = trees
    return trees
end

local function pick_random_tree(surface)
    local list = get_tree_list(surface)

    if #list == 0 then
        return nil
    end

    return list[math.random(#list)]
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
    local tree_name = pick_random_tree(surface)
    if tree_name then
        for _ = 1, 5 do
            if surface.can_place_entity { name = tree_name, position = position, force = "neutral" } then
                surface.create_entity { name = tree_name, position = position, force = "neutral" }
                return
            end
            tree_name = pick_random_tree(surface)
        end
    end

    -- Could not place any tree - refund the sapling to the player
    if player_index then
        local player = game.get_player(player_index)
        if player then
            player.insert { name = "tree-sapling", count = 1 }
            local key = tree_name and "sosciencity.tree-sapling-placement-failed" or "sosciencity.no-plantable-trees-on-surface"
            player.print({ key })
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

    if #get_tree_list(surface) == 0 then
        player.print({ "sosciencity.no-plantable-trees-on-surface" })
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
                        local tree_name = pick_random_tree(surface)
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
