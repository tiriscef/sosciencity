local style = data.raw["gui-style"]["default"]

style.sosciencity_city_view = {
    type = "frame_style",
    height = 800,
    bottom_padding = 4
}

style.sosciencity_city_view_header_flow = {
    type = "horizontal_flow_style",
    horizontal_spacing = 8
}

style.sosciencity_city_view_header_icon = {
    type = "image_style",
    size = 30,
    stretch_image_to_widget_size = true
}

style.sosciencity_city_view_header_drag = {
    type = "empty_widget_style",
    parent = "draggable_space",
    horizontally_stretchable = "on",
    height = 24,
    left_margin = 4,
    right_margin = 4
}

style.sosciencity_city_view_tab_frame = {
    type = "frame_style",
    parent = "inside_deep_frame_for_tabs",
    top_padding = 2
}

style.sosciencity_city_view_tab_flow = {
    type = "horizontal_flow_style",
    horizontal_spacing = 16,
    left_padding = 8,
    right_padding = 8,
    bottom_padding = 4
}

style.sosciencity_city_view_pages_scroll_pane = {
    type = "scroll_pane_style",
    parent = "list_box_scroll_pane",
    horizontally_stretchable = "stretch_and_expand",
    vertically_stretchable = "stretch_and_expand",
    dont_force_clipping_rect_for_contents = true,
    padding = 0,
    vertical_flow_style = {
        type = "vertical_flow_style",
        vertical_spacing = 4
    },
    width = 300
}

style.sosciencity_city_view_page_button = {
    type = "button_style",
    font = "default-listbox",
    horizontal_align = "left",
    horizontally_stretchable = "on",
    horizontally_squashable = "on",
    bottom_margin = -3,
    default_font_color = {227, 227, 227},
    hovered_font_color = {0, 0, 0},
    selected_clicked_font_color = {0.97, 0.54, 0.15},
    selected_font_color = {0.97, 0.54, 0.15},
    selected_hovered_font_color = {0.97, 0.54, 0.15},
    default_graphical_set = {
        corner_size = 8,
        position = {208, 17}
    },
    clicked_graphical_set = {
        corner_size = 8,
        position = {352, 17}
    },
    hovered_graphical_set = {
        base = {
            corner_size = 8,
            position = {34, 17}
        }
    },
    disabled_graphical_set = {
        corner_size = 8,
        position = {17, 17}
    }
}

style.sosciencity_city_view_page_button_selected = {
    type = "button_style",
    parent = "sosciencity_city_view_page_button",
    default_font_color = {0, 0, 0},
    hovered_font_color = {0, 0, 0},
    selected_clicked_font_color = {0, 0, 0},
    selected_font_color = {0, 0, 0},
    selected_hovered_font_color = {0, 0, 0},
    default_graphical_set = {
        corner_size = 8,
        position = {54, 17}
    },
    hovered_graphical_set = {
        corner_size = 8,
        position = {54, 17}
    }
}

style.sosciencity_city_view_page_content_scroll_pane = {
    type = "scroll_pane_style",
    parent = "naked_scroll_pane",
    width = 900,
    padding = 12,
    vertically_stretchable = "on"
}

style.sosciencity_city_view_footer_flow = {
    type = "horizontal_flow_style",
    horizontal_spacing = 8,
    top_padding = 0
}

style.sosciencity_city_view_footer_drag = {
    type = "empty_widget_style",
    parent = "draggable_space",
    horizontally_stretchable = "on",
    height = 20,
    left_margin = 0,
    right_margin = 4
}

style.sosciencity_city_view_footer_label = {
    type = "label_style",
    font = "default-small-semibold"
}

style.sosciencity_datalist = {
    type = "table_style",
    parent = "bordered_table",
    horizontally_stretchable = "on",
    right_cell_padding = 6,
    left_cell_padding = 6
}

style.sosciencity_datalist_value = {
    type = "label_style",
    horizontally_stretchable = "on",
    single_line = false
}

style.sosciencity_standard_tab_flow = {
    type = "vertical_flow_style",
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}
