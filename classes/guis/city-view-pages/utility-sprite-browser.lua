--- Debug CityView page: browse all utility sprites with their names.

Gui.CityView.add_page {
    name = "utility-sprites",
    category = "debug",
    localised_name = {"city-view.utility-sprites"},
    creator = function(container)
        local mod_data = prototypes.mod_data["sosciencity-utility-sprite-names"]
        if not mod_data then
            container.add {type = "label", caption = "Sprite data missing - load with sosciencity-debug enabled."}
            return
        end

        local names = {}
        for name in pairs(mod_data.data) do
            names[#names + 1] = name
        end
        table.sort(names)

        local grid = container.add {type = "table", column_count = 8}
        grid.style.horizontal_spacing = 4
        grid.style.vertical_spacing = 4

        for _, name in pairs(names) do
            local path = "utility/" .. name
            if not helpers.is_valid_sprite_path(path) then goto continue end

            local cell = grid.add {type = "flow", direction = "vertical"}
            cell.style.horizontal_align = "center"
            cell.style.width = 80

            cell.add {
                type = "sprite-button",
                sprite = path,
                tooltip = name,
                style = "tool_button"
            }
            local label = cell.add {type = "label", caption = name}
            label.style.single_line = true
            label.style.width = 76
            label.style.horizontal_align = "center"

            ::continue::
        end
    end
}
