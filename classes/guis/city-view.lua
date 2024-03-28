local CITY_VIEW_NAME = "sosciencity-city-view"

local function create_city_view(player)
    local city_view_frame =
        player.gui.screen.add {
        type = "frame",
        name = CITY_VIEW_NAME,
        direction = "vertical"
    }

    -- This triggers the on_gui_opened event upon which other mods might delete the city view, so we check if it's still there
    player.opened = city_view_frame
    if not city_view_frame.valid then
        return
    end

    local header =
        city_view_frame.add {
        type = "flow",
        name = "header",
        direction = "horizontal"
    }
    header.drag_target = city_view_frame

    header.add {
        type = "label",
        ignored_by_interaction = true,
        caption = {"sosciencity.city"}
    }
    header.add {
        type = "empty-widget",
        ignored_by_interaction = true,
        style = "sosciencity_header_drag"
    }
    header.add {
        type = "sprite-button",
        name = "sosciencity-close-city-view",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "close_button"
    }

    local content_flow =
        city_view_frame.add {
        type = "flow",
        name = "content-flow",
        direction = "horizontal"
    }

    local pages_frame =
        content_flow.add {
        type = "frame",
        name = "pages-frame",
        direction = "vertical",
        style = "inside_deep_frame"
    }
    local pages_scroll_pane =
        pages_frame.add {
        type = "scroll-pane",
        name = "pages-scroll-pane",
        direction = "vertical",
        vertical_scroll_policy = "auto",
        style = "sosciencity_pages_scroll_pane"
    }
    -- populate it with pages here

    local content_frame =
        content_flow.add {
        type = "frame",
        name = "content-frame",
        direction = "vertical",
        style = "inside_shallow_frame"
    }
    local content_scroll_pane =
        content_frame.add {
        type = "scroll-pane",
        name = "content-scroll-pane",
        style = "naked_scroll_pane"
    }

    city_view_frame.force_auto_center()
end

local function toggle_city_view_opened(player)
    local gui = player.gui.screen[CITY_VIEW_NAME]
    if gui then
        gui.destroy()
    else
        create_city_view(player)
    end
end

local function handle_toggle_events(_, _, player_id)
    toggle_city_view_opened(game.players[player_id])
end

-- events that should open or close the city view
Gui.set_click_handler("sosciencity-open-city-view", handle_toggle_events)
Gui.set_click_handler("sosciencity-close-city-view", handle_toggle_events)
Gui.add_gui_closed_handler(
    function(_, event)
        local element = event.element
        if element and element.name == CITY_VIEW_NAME then
            element.destroy()
        end
    end
)
