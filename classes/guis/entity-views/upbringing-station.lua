--- Details view for the upbringing station.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local type_definitions = require("constants.types").definitions

local castes = Castes.values
local Entity = Entity
local Upbringing = Entity.Upbringing
local Gui = Gui
local Inhabitants = Inhabitants
local Register = Register
local get_building_details = Buildings.get
local format = string.format
local display_percentage = Tirislib.Locales.display_percentage
local Table = Tirislib.Tables
local Array = Tirislib.Arrays
local Luaq_from = Tirislib.Luaq.from
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << upbringing station >>

local breedable_castes =
    Tirislib.LazyLuaq.from(Castes.all):where_key("breedable"):select_key("type"):to_array()

local function update_upbringing_mode_radiobuttons(entry, mode_flow)
    local mode = entry[EK.education_mode]

    for index, radiobutton in pairs(mode_flow.children) do
        local mode_id = breedable_castes[index]

        if mode_id then
            radiobutton.visible = Technologies.caste_is_researched(mode_id)
            radiobutton.state = (mode == mode_id)
        else
            radiobutton.state = (mode == Type.null)
        end
    end
end

local function update_classes_flow(entry, classes_flow)
    classes_flow.clear()

    local current_tick = game.tick
    local classes = entry[EK.classes]
    local at_least_one = false

    for index, class in pairs(classes) do
        local progress = math.min((current_tick - class[1]) / Upbringing.time, 1)
        local count = Array.sum(class[2])

        local card = classes_flow.add {type = "frame", name = "class-" .. index, direction = "vertical", style = "sosciencity_card_frame"}
        card.style.horizontally_stretchable = true

        card.add {type = "label", name = "label", caption = {"sosciencity.show-class-count", count}}

        local progressbar = card.add {
            type = "progressbar",
            name = "progress",
            value = progress,
            tooltip = {"sosciencity.show-class-progress", math.floor(progress * 100)}
        }
        progressbar.style.horizontally_stretchable = true

        at_least_one = true
    end

    if not at_least_one then
        classes_flow.add {
            name = "no-classes",
            type = "label",
            caption = {"sosciencity.no-classes"}
        }
    end
end

local function update_upbringing_station(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local mode_flow = Datalist.get_kv_value_element(building_data, "mode")
    update_upbringing_mode_radiobuttons(entry, mode_flow)

    local probability_flow = Datalist.get_kv_value_element(building_data, "probabilities")
    local probabilities = Upbringing.get_expectations(entry[EK.education_mode])
    local at_least_one = false

    for _, caste_id in pairs(breedable_castes) do
        local probability = probabilities[caste_id]
        local caste = castes[caste_id]

        local label = probability_flow[caste.name]
        if probability then
            at_least_one = true

            label.caption = {
                "sosciencity.caste-probability",
                caste.localised_name_short,
                display_percentage(probability)
            }
        end
        label.visible = (probability ~= nil)
    end

    probability_flow.no_castes.visible = not at_least_one

    update_classes_flow(entry, general.classes)

    Datalist.set_kv_pair_value(building_data, "graduates", entry[EK.graduates])
end

local function create_upbringing_station(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-upbringing-capacity", get_building_details(entry).capacity}
    )

    -- Mode flow
    local mode_flow = Datalist.add_kv_flow(building_data, "mode", {"sosciencity.mode"})

    for _, caste_id in pairs(breedable_castes) do
        mode_flow.add {
            name = format(Gui.unique_prefix_builder, "education-mode", caste_id),
            type = "radiobutton",
            caption = type_definitions[caste_id].localised_name,
            state = true,
            tags = {sosciencity_gui_event = "education_mode_radiobutton", caste_id = caste_id}
        }
    end

    mode_flow.add {
        name = format(Gui.unique_prefix_builder, "education-mode", Type.null),
        type = "radiobutton",
        caption = {"sosciencity.no-mode"},
        state = true,
        tags = {sosciencity_gui_event = "education_mode_radiobutton", caste_id = Type.null}
    }

    -- expected castes flow
    local probabilities_flow = Datalist.add_kv_flow(building_data, "probabilities", {"sosciencity.expected"})

    probabilities_flow.add {
        name = "no_castes",
        type = "label",
        caption = {"sosciencity.no-castes"}
    }

    for _, caste_id in pairs(breedable_castes) do
        local caste = castes[caste_id]
        probabilities_flow.add {
            name = caste.name,
            type = "label"
        }
    end

    Datalist.add_kv_pair(building_data, "graduates", {"sosciencity.graduates"})

    Gui.Elements.Label.header_label(general, "header-classes", {"sosciencity.classes"})
    general.add {type = "flow", name = "classes", direction = "vertical"}

    if DEV_MODE then
        local debug_tab = Gui.Elements.Tabs.create(tabbed_pane, "debug", {"city-view.debug-tab"}, "sosciencity_details_tab")
        debug_tab.add {
            type = "button",
            style = "red_button",
            caption = {"city-view.debug-upbringing-complete-go"},
            tooltip = {"city-view.debug-upbringing-complete-tooltip"},
            tags = {sosciencity_gui_event = "debug_upbringing_complete_classes"}
        }
    end

    update_upbringing_station(container, entry)
end

Gui.set_checked_state_handler(
    "education_mode_radiobutton",
    function(event)
        if event.element.state then
            local player_id = event.player_index
            local entry = Register.try_get(storage.details_view[player_id])
            entry[EK.education_mode] = event.element.tags.caste_id
            update_upbringing_mode_radiobuttons(entry, event.element.parent)
        end
    end
)

if DEV_MODE then
    Gui.set_click_handler(
        "debug_upbringing_complete_classes",
        function(event)
            local entry = Register.try_get(storage.details_view[event.player_index])
            if not entry then return end
            local classes = entry[EK.classes]
            local completed = 0
            for i = #classes, 1, -1 do
                Upbringing.finish_class(entry, classes[i], entry[EK.education_mode])
                classes[i] = nil
                completed = completed + 1
            end
            game.players[event.player_index].print({"city-view.debug-upbringing-complete-done", completed})
        end
    )
end

Gui.DetailsView.register_type(
    Type.upbringing_station,
    {creater = create_upbringing_station, updater = update_upbringing_station, always_update = true}
)
