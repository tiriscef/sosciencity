--- Overview pages for buildings, one page per type, shown in the "buildings" CityView category.
Gui.BuildingOverview = {}
local BuildingOverview = Gui.BuildingOverview

local EK = require("enums.entry-key")

local Register = Register
local Locale = Locale
local floor = math.floor

local CAMERA_THRESHOLD = 30

-- page_name -> {types, layout, stats_creator}
local page_specs = {}
-- type -> page_name (for DetailsView back button)
local type_to_page = {}

--- Registers a building type for an overview page.
--- @param page_name string  must match the name passed to CityView.add_page
--- @param spec table  {types, layout, stats_creator}
function BuildingOverview.register_type(page_name, spec)
    page_specs[page_name] = spec
    for _, _type in pairs(spec.types) do
        type_to_page[_type] = page_name
    end
end

--- Returns the overview page name for the given type, or nil if none is registered.
function BuildingOverview.get_page_for_type(_type)
    return type_to_page[_type]
end

---------------------------------------------------------------------------------------------------
-- << card creation >>

local function total_count(types)
    local n = 0
    for _, _type in pairs(types) do
        n = n + Register.get_type_count(_type)
    end
    return n
end

local function create_card(container, entry, use_camera)
    local entity = entry[EK.entity]
    local pos = entity.position
    local unit_number = entry[EK.unit_number]

    local card = container.add {
        type = "frame",
        direction = "horizontal",
        style = "sosciencity_card_frame"
    }

    -- thumbnail
    if use_camera then
        local cam = card.add {
            type = "camera",
            name = "thumbnail",
            position = pos,
            surface_index = entity.surface_index,
            zoom = 0.25
        }
        cam.style.minimal_width = 150
        cam.style.minimal_height = 150
    else
        local sprite = card.add {
            type = "sprite",
            name = "thumbnail",
            sprite = "entity/" .. entry[EK.name]
        }
        sprite.style.minimal_width = 150
        sprite.style.minimal_height = 150
    end

    -- right side
    local right = card.add {type = "flow", direction = "vertical"}
    right.style.horizontally_stretchable = true

    -- header row: entity icon + name + position
    local header = right.add {type = "flow", name = "header", direction = "horizontal"}
    header.style.vertical_align = "center"
    local icon = header.add {
        type = "sprite",
        sprite = "entity/" .. entry[EK.name],
        resize_to_sprite = false
    }
    icon.style.width = 24
    icon.style.height = 24
    icon.style.stretch_image_to_widget_size = true
    local name_label = header.add {
        type = "label",
        name = "name_label",
        caption = Locale.entry(entry)
    }
    name_label.style.font = "default-bold"
    local pos_label = header.add {
        type = "label",
        name = "pos_label",
        caption = {"sosciencity.position", floor(pos.x), floor(pos.y)}
    }
    pos_label.style.left_padding = 6

    right.add {type = "line", direction = "horizontal"}

    -- stats section (filled by stats_creator)
    local stats = right.add {type = "flow", name = "stats", direction = "vertical"}

    right.add {type = "line", direction = "horizontal"}

    -- action buttons
    local buttons = right.add {type = "flow", name = "buttons", direction = "horizontal"}
    buttons.add {
        type = "sprite-button",
        sprite = "utility/map",
        tooltip = {"sosciencity.show-on-map"},
        style = "sosciencity_small_button",
        tags = {sosciencity_gui_event = "overview_go_to", unit_number = unit_number}
    }
    buttons.add {
        type = "sprite-button",
        sprite = "utility/search_icon",
        tooltip = {"sosciencity.inspect"},
        style = "sosciencity_small_button",
        tags = {sosciencity_gui_event = "overview_inspect", unit_number = unit_number}
    }

    return stats
end

---------------------------------------------------------------------------------------------------
-- << click handlers >>

Gui.set_click_handler(
    "overview_go_to",
    function(event)
        local player = game.get_player(event.player_index)
        local entry = Register.try_get(event.element.tags.unit_number)
        if entry then
            player.centered_on = entry[EK.entity]
        end
    end
)

Gui.set_click_handler(
    "overview_inspect",
    function(event)
        local player = game.get_player(event.player_index)
        local entry = Register.try_get(event.element.tags.unit_number)
        if entry then
            player.opened = entry[EK.entity]
        end
    end
)

---------------------------------------------------------------------------------------------------
-- << CityView integration >>

--- Returns a creator function for CityView.add_page.
function BuildingOverview.make_creator(page_name)
    return function(container)
        local spec = page_specs[page_name]
        local use_camera = total_count(spec.types) <= CAMERA_THRESHOLD

        local card_container
        if spec.layout == "grid" then
            card_container = container.add {type = "table", column_count = 2}
            card_container.style.horizontally_stretchable = true
        else
            card_container = container.add {type = "flow", direction = "vertical"}
            card_container.style.horizontally_stretchable = true
        end

        for _, _type in pairs(spec.types) do
            for _, entry in Register.iterate_type(_type) do
                local stats_flow = create_card(card_container, entry, use_camera)
                spec.stats_creator(stats_flow, entry)
            end
        end
    end
end

--- Returns an enabler function for CityView.add_page.
--- The page becomes permanently visible once any of its types has ever had an entry.
function BuildingOverview.make_enabler(page_name)
    return function()
        local spec = page_specs[page_name]
        for _, _type in pairs(spec.types) do
            if Register.ever_had_type(_type) then
                return true
            end
        end
        return false
    end
end
