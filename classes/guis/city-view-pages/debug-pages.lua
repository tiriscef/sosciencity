--- Broadcast debug actions for the CityView — population/disease manipulation for testing.
--- Only loaded when DEV_MODE is true (either sosciencity-debug or sosciencity-balancing active).

---------------------------------------------------------------------------------------------------
-- << Constants >>
---------------------------------------------------------------------------------------------------

local EK = require("enums.entry-key")
local Castes = require("constants.castes")

local CONTEXT = "debug-broadcast"
local HEALTHY = DiseaseGroup.HEALTHY

local shuffle = Tirislib.Arrays.shuffle

local CollapsibleSection = Gui.Elements.CollapsibleSection
local NumericTextField = Gui.Elements.NumericTextField
local DebugWidgets = Gui.DebugWidgets

---------------------------------------------------------------------------------------------------
-- << UI builders >>
---------------------------------------------------------------------------------------------------

local function build_spawn_section(content, player_index)
    local section = CollapsibleSection.heading_1_compact(content, {"city-view.debug-spawn"}, {collapsed = false})

    local caste_row = DebugWidgets.labelled(section, "city-view.debug-spawn-caste")
    local caste_dd = caste_row.add {type = "drop-down", items = DebugWidgets.caste_items, selected_index = 1}
    Gui.register_element(caste_dd, CONTEXT, "spawn_caste", player_index)

    local count_row = DebugWidgets.labelled(section, "city-view.debug-spawn-count")
    local count_field = NumericTextField.create(count_row)
    count_field.text = "1"
    Gui.register_element(count_field, CONTEXT, "spawn_count", player_index)

    local hhs_row = DebugWidgets.labelled(section, "city-view.debug-spawn-hhs")
    local happiness = NumericTextField.create(hhs_row)
    happiness.text = "10"
    Gui.register_element(happiness, CONTEXT, "spawn_happiness", player_index)
    local health = NumericTextField.create(hhs_row)
    health.text = "10"
    Gui.register_element(health, CONTEXT, "spawn_health", player_index)
    local sanity = NumericTextField.create(hhs_row)
    sanity.text = "10"
    Gui.register_element(sanity, CONTEXT, "spawn_sanity", player_index)

    section.add {
        type = "button",
        style = "red_button",
        caption = {"city-view.debug-spawn-go"},
        tooltip = {"city-view.debug-spawn-tooltip"},
        tags = {sosciencity_gui_event = "debug_spawn_go"}
    }
end

local function build_infect_section(content, player_index)
    local section = CollapsibleSection.heading_1_compact(content, {"city-view.debug-infect"}, {collapsed = false})

    local scope_dd, target_dd = DebugWidgets.build_scope_picker(section, CONTEXT, "infect_target")
    Gui.register_element(scope_dd, CONTEXT, "infect_scope", player_index)
    Gui.register_element(target_dd, CONTEXT, "infect_target", player_index)

    local count_row = DebugWidgets.labelled(section, "city-view.debug-infect-count")
    local count_field = NumericTextField.create(count_row)
    count_field.text = "1"
    Gui.register_element(count_field, CONTEXT, "infect_count", player_index)

    section.add {
        type = "button",
        style = "red_button",
        caption = {"city-view.debug-infect-go"},
        tooltip = {"city-view.debug-infect-tooltip"},
        tags = {sosciencity_gui_event = "debug_infect_go"}
    }
end

local function build_homelessness_section(content)
    local section = CollapsibleSection.heading_1_compact(content, {"city-view.debug-homelessness"}, {collapsed = false})
    section.add {
        type = "button",
        style = "red_button",
        caption = {"city-view.debug-homelessness-go"},
        tooltip = {"city-view.debug-homelessness-tooltip"},
        tags = {sosciencity_gui_event = "debug_homelessness_go"}
    }
end

---------------------------------------------------------------------------------------------------
-- << Action logic >>
---------------------------------------------------------------------------------------------------

local function read_numeric(element)
    return tonumber(element.text)
end

local function gather_diseaseable_entries()
    local entries = {}
    for _, caste in pairs(Castes.all) do
        for _, entry in Register.iterate_type(caste.type) do
            if entry[EK.diseases][HEALTHY] > 0 then
                entries[#entries + 1] = entry
            end
        end
    end
    return entries
end

local function apply_infection(entries, total, scope_idx, target_idx)
    local remaining = total
    local sickened_total = 0
    for _, entry in pairs(entries) do
        if remaining == 0 then break end
        local actually = DebugWidgets.apply_infection_to_entry(entry[EK.diseases], remaining, scope_idx, target_idx)
        remaining = remaining - actually
        sickened_total = sickened_total + actually
    end
    return sickened_total
end

---------------------------------------------------------------------------------------------------
-- << Event handlers >>
---------------------------------------------------------------------------------------------------

Gui.set_click_handler(
    "debug_spawn_go",
    function(event)
        local player = game.players[event.player_index]
        local caste_dd = Gui.get_element(CONTEXT, "spawn_caste", event.player_index)
        local count = read_numeric(Gui.get_element(CONTEXT, "spawn_count", event.player_index))
        local happiness = read_numeric(Gui.get_element(CONTEXT, "spawn_happiness", event.player_index))
        local health = read_numeric(Gui.get_element(CONTEXT, "spawn_health", event.player_index))
        local sanity = read_numeric(Gui.get_element(CONTEXT, "spawn_sanity", event.player_index))

        if not count or count < 1 or not happiness or not health or not sanity then
            player.print({"city-view.debug-invalid-count"})
            return
        end

        local caste_id = DebugWidgets.caste_ids[caste_dd.selected_index]
        local group = InhabitantGroup.new(caste_id, count, happiness, health, sanity)
        Inhabitants.add_to_city(group)
        player.print({"city-view.debug-spawn-done", count, Castes.values[caste_id].localised_name})
    end
)

Gui.set_click_handler(
    "debug_infect_go",
    function(event)
        local player = game.players[event.player_index]
        local scope_idx = Gui.get_element(CONTEXT, "infect_scope", event.player_index).selected_index
        local target_idx = Gui.get_element(CONTEXT, "infect_target", event.player_index).selected_index
        local count = read_numeric(Gui.get_element(CONTEXT, "infect_count", event.player_index))

        if not count or count < 1 then
            player.print({"city-view.debug-invalid-count"})
            return
        end

        local entries = gather_diseaseable_entries()
        if #entries == 0 then
            player.print({"city-view.debug-infect-noop"})
            return
        end

        shuffle(entries)
        local sickened = apply_infection(entries, count, scope_idx, target_idx)
        if sickened == 0 then
            player.print({"city-view.debug-infect-noop"})
        else
            player.print({"city-view.debug-infect-done", sickened, count})
        end
    end
)

Gui.set_click_handler(
    "debug_homelessness_go",
    function(event)
        Inhabitants.update_homelessness()
        game.players[event.player_index].print({"city-view.debug-homelessness-done"})
    end
)

---------------------------------------------------------------------------------------------------
-- << Page registration >>
---------------------------------------------------------------------------------------------------

Gui.CityView.add_page {
    name = "debug-broadcast",
    category = "debug",
    localised_name = {"city-view.debug-broadcast"},
    creator = function(container)
        local main_flow = container.add {type = "flow", direction = "vertical"}
        build_spawn_section(main_flow, container.player_index)
        build_infect_section(main_flow, container.player_index)
        build_homelessness_section(main_flow)
    end
}
