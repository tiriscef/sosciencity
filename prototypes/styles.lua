local style = data.raw["gui-style"]["default"]

style.sosciencity_header_drag = {
    type = "empty_widget_style",
    parent = "draggable_space",
    horizontally_stretchable = "on"
    --height = 24,
    --left_margin = 4,
    --right_margin = 4
}

style.sosciencity_pages_scroll_pane = {
    type = "scroll_pane_style",
    parent = "list_box_scroll_pane",
    horizontally_stretchable = "stretch_and_expand",
    vertically_stretchable = "stretch_and_expand",
    dont_force_clipping_rect_for_contents = true,
    padding = 0,
    vertical_flow_style = {
        type = "vertical_flow_style",
        vertical_spacing = 4
    }
}
