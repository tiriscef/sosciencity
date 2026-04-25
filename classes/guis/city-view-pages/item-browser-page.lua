--- Debug page for cheating items into the player's inventory.
--- Only loaded when DEV_MODE is true.

local CONTEXT = "item-browser"
local SLOT_GRID_COLUMNS = 20

---------------------------------------------------------------------------------------------------
-- << Data helpers >>
---------------------------------------------------------------------------------------------------

local function is_sosciencity(proto)
    return proto.subgroup and Tirislib.String.begins_with(proto.subgroup.name, "sosciencity-")
end

local function get_inventory_sort_key(proto)
    return (proto.subgroup and proto.subgroup.order or "") .. "\x00" .. (proto.order or "")
end

---------------------------------------------------------------------------------------------------
-- << Grid rebuild >>
---------------------------------------------------------------------------------------------------

local function rebuild_grid(player_index)
    local search_el        = Gui.get_element(CONTEXT, "search", player_index)
    local mod_el           = Gui.get_element(CONTEXT, "mod_toggle", player_index)
    local missing_el       = Gui.get_element(CONTEXT, "missing_toggle", player_index)
    local sort_el          = Gui.get_element(CONTEXT, "sort_toggle", player_index)
    local grid             = Gui.get_element(CONTEXT, "grid", player_index)
    local count_label      = Gui.get_element(CONTEXT, "count_label", player_index)

    local search_text = search_el.text:lower()
    local sosciencity_only = mod_el.toggled
    local missing_only = missing_el.toggled
    local sort_inventory = sort_el.toggled

    local player = game.players[player_index]

    local items = {}
    for name, proto in pairs(prototypes.item) do
        if not proto.parameter then
            if not sosciencity_only or is_sosciencity(proto) then
                if search_text == "" or name:lower():find(search_text, 1, true) then
                    local count = player.get_item_count(name)
                    if not missing_only or count == 0 then
                        items[#items + 1] = {name = name, proto = proto, count = count}
                    end
                end
            end
        end
    end

    if sort_inventory then
        table.sort(items, function(a, b)
            return get_inventory_sort_key(a.proto) < get_inventory_sort_key(b.proto)
        end)
    else
        table.sort(items, function(a, b) return a.name < b.name end)
    end

    grid.clear()
    for _, item in pairs(items) do
        grid.add {
            type = "sprite-button",
            sprite = "item/" .. item.name,
            number = item.count > 0 and item.count or nil,
            elem_tooltip = {type = "item", name = item.name},
            style = "slot_button",
            tags = {sosciencity_gui_event = "item_browser_click", item_name = item.name}
        }
    end

    count_label.caption = {"city-view.item-browser-count", #items}
end

---------------------------------------------------------------------------------------------------
-- << Event handlers >>
---------------------------------------------------------------------------------------------------

Gui.set_click_handler(
    "item_browser_click",
    function(event)
        local item_name = event.element.tags.item_name
        local proto = prototypes.item[item_name]
        if not proto then return end
        local count = event.shift and proto.stack_size or 1
        game.players[event.player_index].insert({name = item_name, count = count})
    end
)

Gui.set_text_changed_handler(
    "item_browser_search",
    function(event)
        rebuild_grid(event.player_index)
    end
)

Gui.set_click_handler(
    "item_browser_toggle",
    function(event)
        event.element.toggled = not event.element.toggled
        rebuild_grid(event.player_index)
    end
)

---------------------------------------------------------------------------------------------------
-- << Page registration >>
---------------------------------------------------------------------------------------------------

Gui.CityView.add_page {
    name = "item-browser",
    category = "debug",
    localised_name = {"city-view.item-browser"},
    creator = function(container)
        local player_index = container.player_index

        local main_flow = container.add {type = "flow", direction = "vertical"}

        -- Controls row (horizontal)
        local controls = main_flow.add {type = "flow", direction = "horizontal"}
        controls.style.vertical_align = "center"
        controls.style.bottom_padding = 4

        local search = controls.add {
            type = "textfield",
            placeholder_caption = {"city-view.item-browser-search-placeholder"},
            tags = {sosciencity_gui_event = "item_browser_search"}
        }
        search.style.width = 160
        Gui.register_element(search, CONTEXT, "search", player_index)

        local mod_toggle = controls.add {
            type = "button",
            caption = {"city-view.item-browser-sosciencity"},
            tooltip = {"city-view.item-browser-sosciencity-tooltip"},
            toggled = false,
            tags = {sosciencity_gui_event = "item_browser_toggle"}
        }
        Gui.register_element(mod_toggle, CONTEXT, "mod_toggle", player_index)

        local missing_toggle = controls.add {
            type = "button",
            caption = {"city-view.item-browser-missing-only"},
            toggled = false,
            tags = {sosciencity_gui_event = "item_browser_toggle"}
        }
        Gui.register_element(missing_toggle, CONTEXT, "missing_toggle", player_index)

        local sort_toggle = controls.add {
            type = "button",
            caption = {"city-view.item-browser-sort-inventory"},
            tooltip = {"city-view.item-browser-sort-inventory-tooltip"},
            toggled = false,
            tags = {sosciencity_gui_event = "item_browser_toggle"}
        }
        Gui.register_element(sort_toggle, CONTEXT, "sort_toggle", player_index)

        local count_label = controls.add {type = "label", caption = ""}
        Gui.register_element(count_label, CONTEXT, "count_label", player_index)

        -- Item grid
        local grid = main_flow.add {
            type = "table",
            column_count = SLOT_GRID_COLUMNS,
            style = "sosciencity_slot_grid"
        }
        Gui.register_element(grid, CONTEXT, "grid", player_index)

        rebuild_grid(player_index)
    end
}
