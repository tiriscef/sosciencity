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
    Inhabitants.try_auto_upgrade(entry)

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
    entry[EK.entity].custom_status = {
        diode = defines.entity_status_diode.red,
        label = label
    }
end

Register.set_entity_updater(Type.empty_house, update_empty_house)

--- Creation handler for empty houses. Restores caste, priority, and comfort from blueprint tags if present.
--- @param entry Entry
--- @param event table?
local function create_empty_house(entry, event)
    local house_details = Housing.get(entry)
    entry[EK.current_comfort] = house_details.starting_comfort
    entry[EK.target_comfort] = house_details.starting_comfort

    local tags = Tables.get_subtbl_recursive_passive(event, "tags", "sosciencity")

    if tags == nil then
        return
    end

    entry[EK.target_comfort] = tags.target_comfort or house_details.starting_comfort

    local caste = tags.caste
    if caste then
        local new_entry = Inhabitants.try_allow_for_caste(entry, caste, true)

        if new_entry then
            new_entry[EK.housing_priority] = tags.priority
            -- current_comfort and target_comfort are carried over by try_allow_for_caste
            new_entry[EK.target_comfort] = tags.target_comfort or new_entry[EK.current_comfort]
        end
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
        end
    end
end

--- Blueprint handler for empty houses. Saves current_comfort in tags.
--- @param entry Entry
--- @return table tags
local function blueprint_empty_house(entry)
    return {
        current_comfort = entry[EK.current_comfort],
        target_comfort = entry[EK.target_comfort]
    }
end

Register.set_entity_creation_handler(Type.empty_house, create_empty_house)
Register.set_entity_destruction_handler(Type.empty_house, remove_empty_house)
Register.set_blueprinted_handler(Type.empty_house, blueprint_empty_house)
