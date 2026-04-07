local EK = require("enums.entry-key")
local RenderingType = require("enums.rendering-type")
local Type = require("enums.type")

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

    entry[EK.entity].custom_status = {
        diode = defines.entity_status_diode.red,
        label = {"sosciencity-custom-status.no-caste-assigned"}
    }
end

Register.set_entity_updater(Type.empty_house, update_empty_house)

--- Creation handler for empty houses. Restores caste and priority from blueprint tags if present.
--- @param entry Entry
--- @param event table?
local function create_empty_house(entry, event)
    local tags = Tables.get_subtbl_recursive_passive(event, "tags", "sosciencity")

    if tags == nil then
        return
    end

    local caste = tags.caste
    if caste then
        local success = Inhabitants.try_allow_for_caste(entry, caste, true)

        if success then
            entry = try_get(entry[EK.unit_number])
            local priority = tags.priority
            entry[EK.housing_priority] = priority
        end
    end
end

Register.set_entity_creation_handler(Type.empty_house, create_empty_house)
