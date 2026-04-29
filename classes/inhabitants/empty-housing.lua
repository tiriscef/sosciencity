local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local RenderingType = require("enums.rendering-type")
local Type = require("enums.type")

local Housing = require("constants.housing")

local Tables = Tirislib.Tables
local add_common_sprite = Subentities.add_common_sprite
local remove_common_sprite = Subentities.remove_common_sprite
local try_get = Register.try_get

--- Update handler for empty (unassigned) houses.
--- Checks for nearby water and food sources and sets the is_liveable flag.
--- @param entry Entry
local function update_empty_house(entry)
    local has_water = false
    for _, water_distributer in Neighborhood.iterate_type(entry, Type.water_distributer) do
        if water_distributer[EK.water_name] then
            has_water = true
            break
        end
    end

    if has_water then
        remove_common_sprite(entry, RenderingType.water_warning)
    else
        add_common_sprite(entry, RenderingType.water_warning)
    end

    local has_food = false
    for _, market in Neighborhood.iterate_type(entry, Type.market) do
        if Entity.market_has_food(market) then
            has_food = true
            break
        end
    end

    if has_food then
        remove_common_sprite(entry, RenderingType.food_warning)
    else
        add_common_sprite(entry, RenderingType.food_warning)
    end

    entry[EK.is_liveable] = has_water and has_food
    Inhabitants.try_auto_upgrades(entry)

    local current_comfort = entry[EK.current_comfort] or 0
    local max_comfort = Housing.get(entry).max_comfort
    local label = {
        "sosciencity-custom-status.no-caste-assigned"
    }
    Tirislib.Locales.append(
        label,
        {
            "sosciencity-custom-status.comfort-status",
            {"color-scale." .. current_comfort, {"comfort-scale." .. current_comfort}},
            current_comfort,
            max_comfort
        }
    )

    local trait_upgrades = entry[EK.trait_upgrades]
    if trait_upgrades then
        local trait_list = {""}
        for tag in pairs(trait_upgrades) do
            if #trait_list > 1 then trait_list[#trait_list + 1] = ", " end
            trait_list[#trait_list + 1] = Locale.housing_trait(tag)
        end
        Tirislib.Locales.append(label, {"sosciencity-custom-status.traits-status", trait_list})
    end

    entry[EK.entity].custom_status = {
        diode = defines.entity_status_diode.red,
        label = label
    }
end

Register.set_entity_updater(Type.empty_house, update_empty_house)

--- Creation handler for empty houses. Restores caste, priority, and comfort from blueprint tags if present.
--- Player placement settings (from CityInfo advanced placement mode) are applied as defaults,
--- with blueprint tags taking priority.
--- @param entry Entry
--- @param event table?
local function create_empty_house(entry, event)
    local house_details = Housing.get(entry)
    entry[EK.current_comfort] = house_details.starting_comfort
    entry[EK.target_comfort] = house_details.starting_comfort

    -- Apply player placement settings as initial defaults (blueprint overrides below)
    local player_index = event and event.player_index
    local settings = player_index and storage.placement_settings and storage.placement_settings[player_index]
    if settings then
        entry[EK.target_comfort] = math.min(settings.target_comfort, house_details.max_comfort)
        if settings.target_tags then
            entry[EK.target_tags] = Tables.copy(settings.target_tags)
        end
    end

    local tags = Tables.get_subtbl_recursive_passive(event, "tags", "sosciencity")

    if tags == nil then
        local player = player_index and game.players[player_index]
        if settings and settings.auto_assign_caste then
            local inhabited = Inhabitants.try_allow_for_caste(entry, settings.auto_assign_caste, false)
            Inhabitants.try_upgrade_to_target(inhabited or entry, player)
        else
            Inhabitants.try_upgrade_to_target(entry, player)
        end
        return
    end

    -- Blueprint values win over player settings
    if tags.target_comfort ~= nil then
        entry[EK.target_comfort] = tags.target_comfort
    end
    if tags.target_tags ~= nil then
        entry[EK.target_tags] = Tables.copy(tags.target_tags)
    end
    -- Applied tags from the blueprint source become logistics targets on the new house
    -- (items haven't been spent yet - logistics will deliver and apply them)
    if tags.applied_tags ~= nil then
        local target = entry[EK.target_tags] or {}
        for tag in pairs(tags.applied_tags) do
            target[tag] = true
        end
        entry[EK.target_tags] = target
    end

    local caste = tags.caste
    if caste then
        -- Blueprint caste wins
        local new_entry = Inhabitants.try_allow_for_caste(entry, caste, true)
        if new_entry then
            new_entry[EK.housing_priority] = tags.priority or 0
            -- current_comfort and target_comfort are carried over by try_allow_for_caste
            new_entry[EK.target_comfort] = tags.target_comfort ~= nil and tags.target_comfort or new_entry[EK.current_comfort]
        end
    elseif settings and settings.auto_assign_caste then
        -- No blueprint caste; player setting applies
        Inhabitants.try_allow_for_caste(entry, settings.auto_assign_caste, false)
    end
end

--- Destruction handler for empty houses. Refunds furniture items on mining.
--- @param entry Entry
--- @param cause DeconstructionCause
--- @param event table?
local function remove_empty_house(entry, cause, event)
    if cause == DeconstructionCause.mined then
        local buffer = event and event.buffer
        if buffer then
            local house_details = Housing.get(entry)
            for _, item in pairs(Housing.get_total_refund(house_details, entry[EK.current_comfort] or 0)) do
                buffer.insert({name = item.name, count = item.count})
            end
            local trait_upgrades = entry[EK.trait_upgrades]
            if trait_upgrades then
                for _, item in pairs(Housing.get_tag_refund(house_details, trait_upgrades)) do
                    buffer.insert({name = item.name, count = item.count})
                end
            end
        end
    end
end

--- Blueprint handler for empty houses. Saves current_comfort in tags.
--- @param entry Entry
--- @return table tags
local function blueprint_empty_house(entry)
    return {
        current_comfort = entry[EK.current_comfort],
        target_comfort = entry[EK.target_comfort],
        target_tags = entry[EK.target_tags],
        applied_tags = entry[EK.trait_upgrades]
    }
end

--- Ghost placement handler. Called when a player places a house ghost while in advanced placement
--- mode. Writes the player's placement settings into the ghost's tags so construction robots pick
--- them up when building it. Skips if the ghost already has sosciencity tags (placed from blueprint).
--- @param entity LuaEntity the ghost entity
--- @param event table on_built_entity event
function Inhabitants.on_house_ghost_placed(entity, event)
    if not Housing.values[entity.ghost_name] then
        return
    end

    local existing = entity.tags
    if existing and existing.sosciencity then
        return
    end

    local player_index = event.player_index
    if not player_index then
        return
    end

    local player = game.players[player_index]
    local cursor = player.cursor_stack
    if not (cursor and cursor.valid_for_read and Housing.values[cursor.name]) then
        return
    end

    local settings = storage.placement_settings and storage.placement_settings[player_index]
    if not settings then
        return
    end

    local new_tags = {target_comfort = settings.target_comfort}
    if settings.auto_assign_caste then
        new_tags.caste = settings.auto_assign_caste
    end
    if settings.target_tags then
        new_tags.target_tags = settings.target_tags
    end
    entity.tags = {sosciencity = new_tags}
end

Register.set_entity_creation_handler(Type.empty_house, create_empty_house)
Register.set_entity_destruction_handler(Type.empty_house, remove_empty_house)
Register.set_blueprinted_handler(Type.empty_house, blueprint_empty_house)
