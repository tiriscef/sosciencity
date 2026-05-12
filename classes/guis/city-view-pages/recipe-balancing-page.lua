--- Live recipe designer and balancing calculator for the CityView debug category.

local Food = require("constants.food")
local DrinkingWater = require("constants.drinking-water")
local Castes = require("constants.castes")

local CONTEXT = "recipe-balancing"
local NumericTextField = Gui.Elements.NumericTextField
local CONFIRMED_EVENT = "rcbal_value_confirmed"

---------------------------------------------------------------------------------------------------
-- << Data helpers >>
---------------------------------------------------------------------------------------------------

local function get_amount(entry)
    if entry.amount then return entry.amount end
    if entry.amount_min then return (entry.amount_min + entry.amount_max) * 0.5 end
    return 1
end

local function get_probability(entry)
    return entry.probability or 1
end

---------------------------------------------------------------------------------------------------
-- << State collection >>
---------------------------------------------------------------------------------------------------

local function get_recipe_name(player_index)
    local picker = Gui.get_element(CONTEXT, "recipe_picker", player_index)
    return picker and picker.elem_value
end

-- Reads all editable fields. Works without a recipe selected (from-scratch mode).
local function collect_state(player_index)
    local time_el  = Gui.get_element(CONTEXT, "time_field",  player_index)
    local speed_el = Gui.get_element(CONTEXT, "speed_field", player_index)
    local machines_el    = Gui.get_element(CONTEXT, "machines_field",    player_index)
    local productivity_el = Gui.get_element(CONTEXT, "productivity_field", player_index)

    local time  = tonumber(time_el  and time_el.text)  or 1
    local speed = tonumber(speed_el and speed_el.text) or 1
    local num_machines  = tonumber(machines_el    and machines_el.text)    or 1
    local productivity  = tonumber(productivity_el and productivity_el.text) or 0
    if time <= 0 then time = 1 end
    if speed <= 0 then speed = 1 end
    if num_machines <= 0 then num_machines = 1 end
    if productivity < 0 then productivity = 0 end

    local ing_flow  = Gui.get_element(CONTEXT, "ingredients_flow", player_index)
    local prod_flow = Gui.get_element(CONTEXT, "products_flow",    player_index)

    local ingredients = {}
    if ing_flow then
        for _, row in pairs(ing_flow.children) do
            local name = row.item_picker and row.item_picker.elem_value
            if name then
                ingredients[#ingredients + 1] = {
                    name = name,
                    item_type = row.tags.item_type,
                    amount = tonumber(row.amount_field.text) or 0
                }
            end
        end
    end

    local products = {}
    if prod_flow then
        for _, row in pairs(prod_flow.children) do
            local name = row.item_picker and row.item_picker.elem_value
            if name then
                local prob = tonumber(row.prob_field.text) or 1
                products[#products + 1] = {
                    name = name,
                    item_type = row.tags.item_type,
                    amount = tonumber(row.amount_field.text) or 0,
                    prob = math.max(0, math.min(1, prob)),
                    catalyst = tonumber(row.cat_field.text) or 0
                }
            end
        end
    end

    return {
        time = time, speed = speed,
        num_machines = num_machines, productivity = productivity,
        ingredients = ingredients, products = products
    }
end

---------------------------------------------------------------------------------------------------
-- << Metric computation >>
---------------------------------------------------------------------------------------------------

local function rate_per_s(amount, prob, time, speed, num_machines)
    return (amount * prob) / (time / speed) * (num_machines or 1)
end

-- Applies productivity to a product amount, respecting the catalyst portion.
local function effective_product_amount(amount, catalyst, productivity)
    local productive = math.max(0, amount - catalyst)
    return catalyst + productive * (1 + productivity / 100)
end

local function format_rate(n)
    if n == 0 then return "0" end
    if math.abs(n) >= 100 then return string.format("%.1f", n) end
    if math.abs(n) >= 10  then return string.format("%.2f", n) end
    return string.format("%.3f", n)
end

local function format_signed_rate(n)
    if n > 0 then return "+" .. format_rate(n) end
    return format_rate(n)
end

local function format_people(n)
    if n <= 0.005 then return "--" end
    return string.format("%.1f", n)
end

local function compute_metrics(state)
    local kcal_out, kcal_in = 0, 0
    local water_rates = {}
    local has_food, has_water = false, false

    -- net flow per item: keyed by name, value = {name, item_type, rate}
    local flow_by_name = {}

    local function add_flow(name, item_type, delta)
        if not flow_by_name[name] then
            flow_by_name[name] = {name = name, item_type = item_type, rate = 0}
        end
        flow_by_name[name].rate = flow_by_name[name].rate + delta
    end

    for _, p in pairs(state.products) do
        local eff_amount = effective_product_amount(p.amount, p.catalyst, state.productivity)
        local r = rate_per_s(eff_amount, p.prob, state.time, state.speed, state.num_machines)
        add_flow(p.name, p.item_type, r)
        if Food.values[p.name] then
            kcal_out = kcal_out + r * Food.values[p.name].calories
            has_food = true
        end
        if DrinkingWater.values[p.name] then
            water_rates[#water_rates + 1] = {name = p.name, rate = r}
            has_water = true
        end
    end

    for _, i in pairs(state.ingredients) do
        local r = rate_per_s(i.amount, 1, state.time, state.speed, state.num_machines)
        add_flow(i.name, i.item_type, -r)
        if Food.values[i.name] then
            kcal_in = kcal_in + r * Food.values[i.name].calories
            has_food = true
        end
    end

    local flow_rates = {}
    for _, entry in pairs(flow_by_name) do
        flow_rates[#flow_rates + 1] = entry
    end

    return {
        flow_rates = flow_rates,
        kcal_out = kcal_out,
        kcal_in = kcal_in,
        kcal_net = kcal_out - kcal_in,
        water_rates = water_rates,
        has_food = has_food,
        has_water = has_water
    }
end

---------------------------------------------------------------------------------------------------
-- << Lua export >>
---------------------------------------------------------------------------------------------------

local function format_number(n)
    if n == math.floor(n) then return tostring(math.floor(n)) end
    return tostring(n)
end

local function generate_lua_export(state)
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    local catalyst_by_name = {}
    for _, prod in pairs(state.products) do
        if prod.catalyst > 0 then
            catalyst_by_name[prod.name] = prod.catalyst
        end
    end

    add("results = {")
    for _, prod in pairs(state.products) do
        local type_str = prod.item_type == "fluid" and '"fluid"' or '"item"'
        local s = string.format('    {type = %s, name = "%s", amount = %s', type_str, prod.name, format_number(prod.amount))
        if prod.prob < 1 then
            s = s .. string.format(", probability = %s", format_number(prod.prob))
        end
        if prod.catalyst > 0 then
            s = s .. string.format(", ignored_by_productivity = %s, ignored_by_stats = %s", format_number(prod.catalyst), format_number(prod.catalyst))
        end
        add(s .. "},")
    end
    add("},")

    add("ingredients = {")
    for _, ing in pairs(state.ingredients) do
        local type_str = ing.item_type == "fluid" and '"fluid"' or '"item"'
        local s = string.format('    {type = %s, name = "%s", amount = %s', type_str, ing.name, format_number(ing.amount))
        local cat = catalyst_by_name[ing.name]
        if cat then
            s = s .. string.format(", ignored_by_stats = %s", format_number(cat))
        end
        add(s .. "},")
    end
    add("},")

    add(string.format("energy_required = %s,", format_number(state.time)))

    return table.concat(lines, "\n")
end

local function update_lua_export(player_index, state)
    local lua_box = Gui.get_element(CONTEXT, "lua_export", player_index)
    if lua_box then
        lua_box.text = generate_lua_export(state)
    end
end

---------------------------------------------------------------------------------------------------
-- << Results rendering >>
---------------------------------------------------------------------------------------------------

local function add_caste_table(container, row_defs)
    local castes = Castes.all
    local tbl = container.add {
        type = "table",
        column_count = 1 + #castes,
        style = "sosciencity_datalist"
    }

    tbl.add {type = "label", caption = ""}
    for _, caste in pairs(castes) do
        local label = tbl.add {type = "label", caption = caste.localised_name_short, style = "sosciencity_datalist_value"}
        label.style.font = "default-bold"
    end

    for _, row in pairs(row_defs) do
        tbl.add {type = "label", caption = row.label, style = "sosciencity_datalist_value"}
        for _, caste in pairs(castes) do
            tbl.add {type = "label", caption = format_people(row.values[caste.type] or 0), style = "sosciencity_datalist_value"}
        end
    end
end

local function rebuild_results(player_index)
    local results = Gui.get_element(CONTEXT, "results_section", player_index)
    results.clear()

    local state = collect_state(player_index)

    if #state.ingredients == 0 and #state.products == 0 then
        results.add {type = "label", caption = {"city-view.recipe-balancing-pick-recipe"}, style = "sosciencity_paragraph"}
        update_lua_export(player_index, state)
        return
    end

    local metrics = compute_metrics(state)

    -- Throughput section
    local throughput_section = Gui.Elements.CollapsibleSection.heading_2_compact(
        results, {"city-view.recipe-balancing-throughput"}, {collapsed = false}
    )
    for _, fr in pairs(metrics.flow_rates) do
        local row = throughput_section.add {type = "flow", direction = "horizontal"}
        row.style.vertical_align = "center"
        row.add {
            type = "sprite-button",
            sprite = fr.item_type .. "/" .. fr.name,
            style = "slot_button",
            elem_tooltip = {type = fr.item_type, name = fr.name},
            enabled = false
        }
        row.add {type = "label", caption = format_signed_rate(fr.rate) .. " /s", style = "sosciencity_paragraph"}
    end
    if #metrics.flow_rates == 0 then
        throughput_section.add {type = "label", caption = "(no items)", style = "sosciencity_paragraph"}
    end

    -- Food section
    if metrics.has_food then
        local food_section = Gui.Elements.CollapsibleSection.heading_2_compact(
            results, {"city-view.recipe-balancing-food"}, {collapsed = false}
        )
        local dl = Gui.Elements.Datalist.create(food_section, "food_datalist", 2)
        Gui.Elements.Datalist.add_kv_pair(dl, "kcal_out", {"city-view.recipe-balancing-kcal-out"}, format_rate(metrics.kcal_out))
        Gui.Elements.Datalist.add_kv_pair(dl, "kcal_in",  {"city-view.recipe-balancing-kcal-in"},  format_rate(metrics.kcal_in))
        Gui.Elements.Datalist.add_kv_pair(dl, "kcal_net", {"city-view.recipe-balancing-kcal-net"}, format_rate(metrics.kcal_net))

        local fed_out, fed_net = {}, {}
        for _, caste in pairs(Castes.all) do
            local demand_per_s = caste.calorific_demand * 60
            fed_out[caste.type] = demand_per_s > 0 and (metrics.kcal_out / demand_per_s) or 0
            fed_net[caste.type] = demand_per_s > 0 and (metrics.kcal_net / demand_per_s) or 0
        end
        add_caste_table(food_section, {
            {label = {"city-view.recipe-balancing-fed-output"}, values = fed_out},
            {label = {"city-view.recipe-balancing-fed-net"},    values = fed_net}
        })
    end

    -- Water section
    if metrics.has_water then
        local water_section = Gui.Elements.CollapsibleSection.heading_2_compact(
            results, {"city-view.recipe-balancing-water"}, {collapsed = false}
        )
        for _, wr in pairs(metrics.water_rates) do
            local proto = prototypes.fluid[wr.name]
            local dl = Gui.Elements.Datalist.create(water_section, "water_dl_" .. wr.name, 2)
            Gui.Elements.Datalist.add_kv_pair(dl, "rate",
                {"city-view.recipe-balancing-water-rate", proto and proto.localised_name or wr.name},
                format_rate(wr.rate))

            local served = {}
            for _, caste in pairs(Castes.all) do
                local demand_per_s = caste.water_demand * 60
                served[caste.type] = demand_per_s > 0 and (wr.rate / demand_per_s) or 0
            end
            add_caste_table(water_section, {{label = {"city-view.recipe-balancing-served"}, values = served}})
        end
    end

    update_lua_export(player_index, state)
end

---------------------------------------------------------------------------------------------------
-- << Row building >>
---------------------------------------------------------------------------------------------------

-- Adds a single I/O row to flow. Pass entry (from a recipe prototype) to pre-fill it, or nil for a blank row.
local function add_io_row(flow, item_type, is_product, entry)
    local row = flow.add {
        type = "flow",
        direction = "horizontal",
        tags = {item_type = item_type}
    }
    row.style.vertical_align = "center"

    row.add {
        type = "choose-elem-button",
        name = "item_picker",
        elem_type = item_type,
        tags = {sosciencity_gui_event = "rcbal_picker_changed", item_type = item_type}
    }

    row.add {
        type = "label",
        name = "name_label",
        caption = "",
        style = "sosciencity_paragraph"
    }

    local amt = NumericTextField.create(row, "amount_field", {numeric_confirmed_event = CONFIRMED_EVENT, min = 0})
    amt.style.width = 60
    amt.text = "1"

    if is_product then
        row.add {type = "label", caption = {"city-view.recipe-balancing-prob"}}
        local prob = NumericTextField.create(row, "prob_field", {numeric_confirmed_event = CONFIRMED_EVENT, min = 0, max = 1})
        prob.style.width = 50
        prob.text = "1"

        local cat_lbl = row.add {type = "label", caption = {"city-view.recipe-balancing-cat"}, style = "sosciencity_paragraph"}
        cat_lbl.style.font_color = {r = 0.6, g = 0.6, b = 0.6}
        local cat = NumericTextField.create(row, "cat_field", {
            numeric_confirmed_event = CONFIRMED_EVENT,
            min = 0,
            normal_font_color = {r = 0.6, g = 0.6, b = 0.6}
        })
        cat.style.width = 50
        cat.text = "0"
    end

    row.add {
        type = "sprite-button",
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "close_button",
        tags = {sosciencity_gui_event = "rcbal_remove_row"}
    }

    if entry then
        row.item_picker.elem_value = entry.name
        local proto = (item_type == "fluid" and prototypes.fluid[entry.name]) or prototypes.item[entry.name]
        row.name_label.caption = proto and proto.localised_name or entry.name
        amt.text = tostring(get_amount(entry))
        if is_product then
            row.prob_field.text = tostring(get_probability(entry))
            row.cat_field.text = tostring(entry.ignored_by_productivity or 0)
        end
    end

    return row
end

---------------------------------------------------------------------------------------------------
-- << I/O section building >>
---------------------------------------------------------------------------------------------------

-- Builds one ingredient or product column inside io_flow.
local function build_io_column(io_flow, flow_key, header_key, is_product, player_index, entries)
    local section = io_flow.add {type = "flow", direction = "vertical"}
    section.style.right_margin = 8

    section.add {type = "label", caption = header_key, style = "sosciencity_heading_2_compact"}

    local row_flow = section.add {type = "flow", direction = "vertical"}
    Gui.register_element(row_flow, CONTEXT, flow_key, player_index)

    for _, entry in pairs(entries) do
        add_io_row(row_flow, entry.type or "item", is_product, entry)
    end

    local btn_flow = section.add {type = "flow", direction = "horizontal"}
    btn_flow.style.top_padding = 4
    btn_flow.add {
        type = "button",
        caption = {"city-view.recipe-balancing-add-item"},
        tags = {sosciencity_gui_event = "rcbal_add_row", flow_key = flow_key, item_type = "item", is_product = is_product}
    }
    btn_flow.add {
        type = "button",
        caption = {"city-view.recipe-balancing-add-fluid"},
        tags = {sosciencity_gui_event = "rcbal_add_row", flow_key = flow_key, item_type = "fluid", is_product = is_product}
    }
end

-- Clears and rebuilds the I/O rows section. If recipe is provided, pre-fills from prototype.
local function rebuild_io(player_index, recipe)
    local main_flow = Gui.get_element(CONTEXT, "main_flow", player_index)
    local io_section = main_flow.io_section
    io_section.clear()

    local io_flow = io_section.add {type = "flow", direction = "horizontal"}
    io_flow.style.vertical_align = "top"

    build_io_column(io_flow, "ingredients_flow", {"city-view.recipe-balancing-ingredients"},
        false, player_index, recipe and recipe.ingredients or {})

    io_flow.add {type = "line", direction = "vertical"}

    build_io_column(io_flow, "products_flow", {"city-view.recipe-balancing-products"},
        true, player_index, recipe and recipe.products or {})
end

---------------------------------------------------------------------------------------------------
-- << Event handlers >>
---------------------------------------------------------------------------------------------------

-- Loading a recipe auto-populates the editor. Clearing the picker leaves the current rows intact.
Gui.set_elem_changed_handler(
    "rcbal_recipe_changed",
    function(event)
        local player_index = event.player_index
        local recipe_name = event.element.elem_value
        if not recipe_name then return end

        local recipe = prototypes.recipe[recipe_name]
        if not recipe then return end

        local time_field = Gui.get_element(CONTEXT, "time_field", player_index)
        time_field.text = tostring(recipe.energy)

        rebuild_io(player_index, recipe)
        rebuild_results(player_index)
    end
)

-- Reloads the currently selected recipe from its prototype, discarding any edits.
Gui.set_click_handler(
    "rcbal_reset",
    function(event)
        local player_index = event.player_index
        local recipe_name = get_recipe_name(player_index)
        local recipe = recipe_name and prototypes.recipe[recipe_name]

        if recipe then
            local time_field = Gui.get_element(CONTEXT, "time_field", player_index)
            time_field.text = tostring(recipe.energy)
        end

        rebuild_io(player_index, recipe)
        rebuild_results(player_index)
    end
)

-- Wipes the recipe picker, clears all rows, and resets params to defaults.
Gui.set_click_handler(
    "rcbal_clear",
    function(event)
        local player_index = event.player_index

        local picker = Gui.get_element(CONTEXT, "recipe_picker", player_index)
        picker.elem_value = nil

        local time_field = Gui.get_element(CONTEXT, "time_field", player_index)
        time_field.text = "1"
        local speed_field = Gui.get_element(CONTEXT, "speed_field", player_index)
        speed_field.text = "1"
        local machines_field = Gui.get_element(CONTEXT, "machines_field", player_index)
        machines_field.text = "1"
        local productivity_field = Gui.get_element(CONTEXT, "productivity_field", player_index)
        productivity_field.text = "0"

        rebuild_io(player_index, nil)
        rebuild_results(player_index)
    end
)

-- Updates the name label in a row when a different item/fluid was picked.
Gui.set_elem_changed_handler(
    "rcbal_picker_changed",
    function(event)
        local picker = event.element
        local row = picker.parent
        local name = picker.elem_value
        if name then
            local item_type = picker.tags.item_type
            local proto = (item_type == "fluid" and prototypes.fluid[name]) or prototypes.item[name]
            row.name_label.caption = proto and proto.localised_name or name
        else
            row.name_label.caption = ""
        end
        rebuild_results(event.player_index)
    end
)

-- Destroys the row the delete button belongs to.
Gui.set_click_handler(
    "rcbal_remove_row",
    function(event)
        event.element.parent.destroy()
        rebuild_results(event.player_index)
    end
)

-- Appends a blank row to the appropriate flow.
Gui.set_click_handler(
    "rcbal_add_row",
    function(event)
        local tags = event.element.tags
        local flow = Gui.get_element(CONTEXT, tags.flow_key, event.player_index)
        if flow then
            add_io_row(flow, tags.item_type, tags.is_product, nil)
        end
    end
)

NumericTextField.set_confirmed_handler(
    CONFIRMED_EVENT,
    function(event, _result)
        rebuild_results(event.player_index)
    end
)

---------------------------------------------------------------------------------------------------
-- << Page registration >>
---------------------------------------------------------------------------------------------------

Gui.CityView.add_page {
    name = "recipe-balancing",
    category = "debug",
    localised_name = {"city-view.recipe-balancing"},
    creator = function(container)
        local player_index = container.player_index

        local main_flow = container.add {type = "flow", name = "main_flow", direction = "vertical"}
        Gui.register_element(main_flow, CONTEXT, "main_flow", player_index)

        -- Picker + action buttons
        local picker_row = main_flow.add {type = "flow", direction = "horizontal"}
        picker_row.style.vertical_align = "center"

        local recipe_picker = picker_row.add {
            type = "choose-elem-button",
            elem_type = "recipe",
            tags = {sosciencity_gui_event = "rcbal_recipe_changed"}
        }
        Gui.register_element(recipe_picker, CONTEXT, "recipe_picker", player_index)

        picker_row.add {
            type = "button",
            caption = {"city-view.recipe-balancing-reset"},
            tooltip = {"city-view.recipe-balancing-reset-tooltip"},
            tags = {sosciencity_gui_event = "rcbal_reset"}
        }
        picker_row.add {
            type = "button",
            caption = {"city-view.recipe-balancing-clear"},
            tooltip = {"city-view.recipe-balancing-clear-tooltip"},
            tags = {sosciencity_gui_event = "rcbal_clear"}
        }

        -- Params (permanent - not rebuilt with I/O rows)
        local params_flow = main_flow.add {type = "flow", direction = "horizontal"}
        params_flow.style.vertical_align = "center"
        params_flow.style.top_padding = 4

        params_flow.add {type = "label", caption = {"city-view.recipe-balancing-time"}}
        local time_field = NumericTextField.create(params_flow, "time_field", {numeric_confirmed_event = CONFIRMED_EVENT, min = 0})
        time_field.text = "1"
        time_field.style.width = 70
        Gui.register_element(time_field, CONTEXT, "time_field", player_index)

        params_flow.add {type = "label", caption = {"city-view.recipe-balancing-speed"}}
        local speed_field = NumericTextField.create(params_flow, "speed_field", {numeric_confirmed_event = CONFIRMED_EVENT, min = 0})
        speed_field.text = "1"
        speed_field.style.width = 70
        Gui.register_element(speed_field, CONTEXT, "speed_field", player_index)

        params_flow.add {type = "label", caption = {"city-view.recipe-balancing-machines"}}
        local machines_field = NumericTextField.create(params_flow, "machines_field", {numeric_confirmed_event = CONFIRMED_EVENT, min = 0})
        machines_field.text = "1"
        machines_field.style.width = 60
        Gui.register_element(machines_field, CONTEXT, "machines_field", player_index)

        params_flow.add {type = "label", caption = {"city-view.recipe-balancing-productivity"}}
        local productivity_field = NumericTextField.create(params_flow, "productivity_field", {numeric_confirmed_event = CONFIRMED_EVENT, min = 0})
        productivity_field.text = "0"
        productivity_field.style.width = 60
        Gui.register_element(productivity_field, CONTEXT, "productivity_field", player_index)

        -- I/O section (cleared and rebuilt on recipe load)
        main_flow.add {type = "flow", name = "io_section", direction = "vertical"}
        rebuild_io(player_index, nil)

        Gui.Elements.Utils.separator_line(main_flow)

        -- Results (cleared and rebuilt on any value change)
        local results_section = main_flow.add {type = "flow", name = "results_section", direction = "vertical"}
        Gui.register_element(results_section, CONTEXT, "results_section", player_index)

        -- Lua export (permanent, text updated by rebuild_results)
        local lua_section = Gui.Elements.CollapsibleSection.heading_2_compact(
            main_flow, {"city-view.recipe-balancing-lua-export"}, {collapsed = false}
        )
        local lua_box = lua_section.add {type = "text-box", read_only = true}
        lua_box.style.minimal_height = 130
        lua_box.style.horizontally_stretchable = true
        Gui.register_element(lua_box, CONTEXT, "lua_export", player_index)

        rebuild_results(player_index)
    end
}
