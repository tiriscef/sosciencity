local Castes = require("constants.castes")
local Color = require("constants.color")

local TIER_LABELS = {
    fine   = {"city-view.pop-history-fine"},
    medium = {"city-view.pop-history-medium"},
    coarse = {"city-view.pop-history-coarse"}
}

-- accent period in bars: fine = every 10 min, medium = every full hour, coarse = every full day
local TIER_ACCENT_PERIOD = {
    fine   = 10,
    medium = 6,
    coarse = 24
}

local CONTEXT = "pop_history"

-- index 1 = total, 2+ = Castes.all[i-1]
local caste_dd_items
local function get_caste_dd_items()
    if caste_dd_items then return caste_dd_items end
    caste_dd_items = {{"city-view.total"}}
    for _, caste in pairs(Castes.all) do
        caste_dd_items[#caste_dd_items + 1] = caste.localised_name
    end
    return caste_dd_items
end

local function get_value(snapshot, caste_index)
    if not snapshot then return 0 end
    if caste_index == 1 then
        local total = 0
        for _, count in pairs(snapshot) do
            total = total + count
        end
        return total
    end
    local caste = Castes.all[caste_index - 1]
    return snapshot[caste.type] or 0
end

local function make_bar_tooltip(tier, n_ago, value)
    return {"city-view.pop-history-bar-tooltip", Tirislib.Locales.display_time(n_ago * tier.interval), value}
end

local function rebuild_chart(bars_flow, left_label, tier_index, caste_index)
    local tier = Statistics.population_history_tiers[tier_index]

    local samples = {}
    for n = tier.size, 1, -1 do
        local snapshot = Statistics.get_population_snapshot(tier.name, n)
        if snapshot then
            local v = get_value(snapshot, caste_index)
            samples[#samples + 1] = {
                value = v,
                tooltip = make_bar_tooltip(tier, n, v)
            }
        end
    end

    left_label.caption = #samples > 0
        and {"city-view.pop-history-chart-start", Tirislib.Locales.display_time(#samples * tier.interval)}
        or ""

    local period = TIER_ACCENT_PERIOD[tier.name]
    Gui.Elements.BarChart.render(bars_flow, samples, {
        height = 400,
        total_width = 876, -- The exact width of the page flow including the margin
        color = function(index) return index % period == 1 and Color.light_blue or Color.light_teal end,
        gap = 0
    })
end

local function create_page(container)
    Gui.Elements.Label.heading_1(container, {"city-view.pop-history"})

    local player_index = container.player_index

    local controls = container.add {type = "flow", direction = "horizontal"}
    controls.style.vertical_align = "center"
    controls.add {type = "label", caption = {"city-view.pop-history-show"}}

    local caste_dd = controls.add {
        type = "drop-down",
        items = get_caste_dd_items(),
        selected_index = 1,
        tags = {sosciencity_gui_event = "pop_history_selector_changed"}
    }

    controls.add {type = "label", caption = {"city-view.pop-history-over"}}

    local tier_items = {}
    for _, t in pairs(Statistics.population_history_tiers) do
        tier_items[#tier_items + 1] = TIER_LABELS[t.name]
    end
    local tier_dd = controls.add {
        type = "drop-down",
        items = tier_items,
        selected_index = 1,
        tags = {sosciencity_gui_event = "pop_history_selector_changed"}
    }

    local bars_flow = Gui.Elements.BarChart.create(container)

    local time_labels = container.add {type = "flow", direction = "horizontal"}
    time_labels.style.horizontally_stretchable = true
    local left_label = time_labels.add {type = "label"}
    local spacer = time_labels.add {type = "empty-widget"}
    spacer.style.horizontally_stretchable = true
    time_labels.add {type = "label", caption = {"city-view.pop-history-chart-end"}}

    Gui.register_element(caste_dd, CONTEXT, "caste_dd", player_index)
    Gui.register_element(tier_dd, CONTEXT, "tier_dd", player_index)
    Gui.register_element(bars_flow, CONTEXT, "bars_flow", player_index)
    Gui.register_element(left_label, CONTEXT, "time_left_label", player_index)

    rebuild_chart(bars_flow, left_label, 1, 1)
end

Gui.set_selection_state_changed_handler(
    "pop_history_selector_changed",
    function(event)
        local pi = event.player_index
        local caste_dd = Gui.get_element(CONTEXT, "caste_dd", pi)
        local tier_dd = Gui.get_element(CONTEXT, "tier_dd", pi)
        local bars_flow = Gui.get_element(CONTEXT, "bars_flow", pi)
        local left_label = Gui.get_element(CONTEXT, "time_left_label", pi)

        if not (caste_dd and tier_dd and bars_flow and left_label) then return end
        
        rebuild_chart(bars_flow, left_label, tier_dd.selected_index, caste_dd.selected_index)
    end
)

Gui.CityView.add_page {
    name = "pop-history",
    category = "statistics",
    localised_name = {"city-view.pop-history"},
    creator = create_page
}
