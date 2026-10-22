local EK = require("enums.entry-key")
local RenderingType = require("enums.rendering-type")
local SubentityType = require("enums.subentity-type")

--- Static class that handles hidden entities that hack additional behaviours.
Subentities = {}

--[[
    Data this class stores in storage
    --------------------------------
    nothing
]]
-- local often used globals for extreme performance gains

Subentities.subentity_name_lookup = {
    [SubentityType.turret_gunfire] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq1] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq2] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq3] = "gunfire-hq-turret",
    [SubentityType.turret_gunfire_hq4] = "gunfire-hq-turret"
}
local subentity_names = Subentities.subentity_name_lookup

local get_type = require("constants.types").get

local Buildings = require("constants.buildings")
local get_building_details = Buildings.get
local get_recipe_visualisation_sprite = Buildings.get_recipe_visualisation_sprite
local recipe_visualisation_maps = Buildings.recipe_visualisation_maps

local max = math.max
local get_subtbl = Tirislib.Tables.get_subtbl
local get_or_create_subentity

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
-- << sprites >>

local function add_alt_mode_sprite(entry, name)
    local entity = entry[EK.entity]
    local renderings = get_subtbl(entry, EK.attached_renderings)

    renderings[RenderingType.altmode_sprite] =
        rendering.draw_sprite(
        {
            sprite = name,
            target = entity,
            surface = entity.surface,
            render_layer = "137", -- this should be lower than "entity-info-icon", meaning the blinking "no energy"-warning will be drawn above
            only_in_alt_mode = true
        }
    )
end

local common_sprites = {
    [RenderingType.food_warning] = "virtual-signal/alert-no-food",
    [RenderingType.water_warning] = "virtual-signal/alert-no-water",
    [RenderingType.no_workers] = "virtual-signal/alert-not-enough-workers",
    [RenderingType.breakdown_warning] = "virtual-signal/alert-red" -- TODO: replace placeholder
}
local common_sprite_offsets = {
    [RenderingType.food_warning] = {x = 1.25, y = 0},
    [RenderingType.water_warning] = {x = -1.25, y = 0},
    [RenderingType.no_workers] = {x = 1.25, y = 0},
    [RenderingType.breakdown_warning] = {x = 0, y = 0}
}
local common_sprite_blink_intervals = {
    [RenderingType.food_warning] = 30,
    [RenderingType.water_warning] = 30,
    [RenderingType.no_workers] = 30,
    [RenderingType.breakdown_warning] = 30
}

--- Adds a common sprite to this entity.
--- @param entry Entry
--- @param render_type RenderingType
function Subentities.add_common_sprite(entry, render_type)
    local attached_renders = get_subtbl(entry, EK.attached_renderings)

    -- do nothing if the common sprite already exists, such that this function can be called without checking the state of the common sprite
    if attached_renders[render_type] then
        return
    end

    local entity = entry[EK.entity]

    local render =
        rendering.draw_sprite(
        {
            sprite = common_sprites[render_type],
            target = {entity = entity, offset = common_sprite_offsets[render_type]},
            surface = entity.surface,
            render_layer = "189" -- lower than the default "arrow", so mouseover renderings should be drawn over this
        }
    )
    render.blink_interval = common_sprite_blink_intervals[render_type] or 0
    attached_renders[render_type] = render
end

--- Removes a common sprite from this entity (if one exists, otherwise the call does nothing).
--- @param entry Entry
--- @param render_type RenderingType
function Subentities.remove_common_sprite(entry, render_type)
    local attached_renders = get_subtbl(entry, EK.attached_renderings)
    local render = attached_renders[render_type]

    if render and render.valid then
        render.destroy()
        attached_renders[render_type] = nil
    end
end

---------------------------------------------------------------------------------------------------
-- << recipe visualisation >>

--- Render object slot per map of a recipe visualisation variant.
local recipe_visualisation_renderings = {
    diffuse = RenderingType.recipe_visualisation,
    glow = RenderingType.recipe_visualisation_glow,
    lightmap = RenderingType.recipe_visualisation_light
}

--- Sprite path -> whether the sprite exists. Variants don't need every map.
local sprite_exists = {}

local function has_sprite(path)
    local exists = sprite_exists[path]
    if exists == nil then
        exists = helpers.is_valid_sprite_path(path)
        sprite_exists[path] = exists
    end
    return exists
end

--- Draws the variant of the active recipe on top of the building, one render object per map the variant has.
--- @param entry Entry of a crafting machine
--- @param visualisation RecipeVisualisationDefinition
function Subentities.update_recipe_visualisation(entry, visualisation)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    local variant = recipe and visualisation.by_recipe[recipe.name] or visualisation.default
    local renders = get_subtbl(entry, EK.attached_renderings)

    for map, render_type in pairs(recipe_visualisation_renderings) do
        local sprite = get_recipe_visualisation_sprite(entry[EK.name], variant, map)
        local render = renders[render_type]

        if has_sprite(sprite) then
            if render and render.valid then
                if render.sprite ~= sprite then
                    render.sprite = sprite
                end
            else
                renders[render_type] =
                    rendering.draw_sprite {
                    sprite = sprite,
                    target = entity,
                    surface = entity.surface,
                    render_layer = "object",
                    light_mode = recipe_visualisation_maps[map].light_mode
                }
            end
        elseif render then
            if render.valid then
                render.destroy()
            end
            renders[render_type] = nil
        end
    end
end

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
        entity.surface.create_entity {
        name = get_subentity_name(entry, _type),
        position = position,
        force = entity.force
    }

    subentities[_type] = subentity

    return subentity
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

    local recipe_visualisation = building_details.recipe_visualisation
    if recipe_visualisation then
        Subentities.update_recipe_visualisation(entry, recipe_visualisation)
    end

    local type_definition = get_type(entry)
    if type_definition.alt_mode_sprite then
        add_alt_mode_sprite(entry, type_definition.alt_mode_sprite)
    end
end

--- Removes all the renderings attached to this entity.
--- @param entry any
function Subentities.remove_sprites(entry)
    local attached_renders = entry[EK.attached_renderings]
    if attached_renders then
        for _, render in pairs(attached_renders) do
            -- DELETEME: this is a ~temp fix for factorio 1.1 maps
            if type(render) == "number" then
                local render_obj = rendering.get_object_by_id(render)
                if render_obj then
                    render_obj.destroy()
                end
            elseif render.valid then
                render.destroy()
            end
        end
    end
end
local remove_sprites = Subentities.remove_sprites

--- Removes all the hidden entities.
--- @param entry Entry
function Subentities.remove_all_for(entry)
    local subentities = entry[EK.subentities]
    if subentities then
        for _, subentity in pairs(subentities) do
            if subentity.valid then
                subentity.destroy()
            end
        end
    end

    remove_sprites(entry)
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

---------------------------------------------------------------------------------------------------
-- << state preservation across rebuild and clone >>
--
-- Each entry in `state_handlers` is { serialize = fn(subentity) -> state, restore = fn(subentity, state) }.
-- Subentity types that are intentionally absent:
--   * `turret_gunfire` and the HQ variants - these turrets currently don't use ammo

Subentities.state_handlers = {
    [SubentityType.eei] = {
        serialize = function(eei) return eei.energy end,
        restore = function(eei, energy) eei.energy = energy end
    }
}
local state_handlers = Subentities.state_handlers

--- Captures preservable state from an entry's subentities, or nil if there's nothing to capture.
--- @param entry Entry
--- @return table? state
function Subentities.serialize(entry)
    local subentities = entry[EK.subentities]
    if not subentities then
        return nil
    end

    local state
    for type_id, subentity in pairs(subentities) do
        local handler = state_handlers[type_id]
        if handler and subentity.valid then
            state = state or {}
            state[type_id] = handler.serialize(subentity)
        end
    end

    return state
end

--- Applies previously serialized state to an entry's freshly-created subentities.
--- @param entry Entry
--- @param state table?
function Subentities.restore(entry, state)
    if not state then
        return
    end
    local subentities = entry[EK.subentities]
    if not subentities then
        return
    end

    for type_id, sub_state in pairs(state) do
        local handler = state_handlers[type_id]
        local subentity = subentities[type_id]
        if handler and subentity and subentity.valid then
            handler.restore(subentity, sub_state)
        end
    end
end

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
