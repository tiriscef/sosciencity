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
    parent = "inside_deep_frame",
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

style.sosciencity_generic_tab_flow = {
    type = "vertical_flow_style",
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}

style.sosciencity_details_view_frame = {
    type = "frame_style",
    width = 350,
    height = 600,
    padding = 4
}

style.sosciencity_heading_1 = {
    type = "label_style",
    font = "heading-1",
    font_color = {255, 230, 192},
    left_margin = 30,
    bottom_margin = 10
}

style.sosciencity_heading_2 = {
    type = "label_style",
    font = "heading-2",
    font_color = {255, 230, 192},
    left_margin = 15,
    top_margin = 20,
    bottom_margin = 10
}

-- the old "heading-3" font that is now gone in Factorio 2.0
Tirislib.Prototype.create {
    type = "font",
    name = "heading-3",
    from = "default-semibold",
    size = 14
}

style.sosciencity_heading_3 = {
    type = "label_style",
    font = "heading-3",
    left_margin = 15,
    top_margin = 10,
    bottom_margin = 5,
    font_color = {255, 230, 192}
}

style.sosciencity_paragraph = {
    type = "label_style",
    single_line = false
}

style.sosciencity_list_flow = {
    type = "vertical_flow_style",
    top_margin = 15,
    bottom_margin = 15
}

style.sosciencity_list_point_flow = {
    type = "horizontal_flow_style",
    vertical_align = "center"
}

style.sosciencity_list_marker = {
    type = "label_style",
    left_margin = 10,
    right_margin = 10,
    font = "default-bold",
    font_color = {255, 230, 192}
}

style.sosciencity_sortable_list = {
    type = "table_style",
    parent = "bordered_table",
    left_cell_padding = 2,
    right_cell_padding = 2,
    top_cell_padding = 1,
    bottom_cell_padding = 1
}

style.sosciencity_sortable_list_head = {
    type = "button_style",
    horizontally_stretchable = "on",
    minimal_width = 28,
    tooltip = "sosciencity.sort-by-this-column"
}

style.sosciencity_sortable_list_row = {
    type = "label_style",
    left_margin = 2,
    right_margin = 2
}

style.sosciencity_page_link_flow = {
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    horizontal_align = "center",
    top_margin = 10,
    bottom_margin = 10
}

style.sosciencity_horizontal_center_flow = {
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    horizontal_align = "center"
}

style.sosciencity_horizontal_right_flow = {
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    horizontal_align = "right"
}

style.sosciencity_calculation_table = {
    type = "table_style",
    parent = "bordered_table",
    left_margin = 20,
    right_margin = 20,
    left_cell_padding = 2,
    right_cell_padding = 2,
    top_cell_padding = 1,
    bottom_cell_padding = 1,
    column_alignments = {{column = 1, alignment = "left"}, {column = 2, alignment = "right"}},
    column_widths = {{column = 2, minimal_width = 100}}
}

style.sosciencity_calculation_table_left = {
    type = "label_style",
    horizontally_stretchable = "on"
}

style.sosciencity_calculation_table_right = {
    type = "label_style"
    --width = 50
}

style.sosciencity_calculation_table_left_head = {
    type = "label_style",
    parent = "sosciencity_calculation_table_left",
    font = "default-bold"
}

style.sosciencity_calculation_table_right_head = {
    type = "label_style",
    parent = "sosciencity_calculation_table_right",
    font = "default-bold"
}
