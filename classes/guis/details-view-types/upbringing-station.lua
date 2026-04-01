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
local Gui = Gui
local Inhabitants = Inhabitants
local Register = Register
local get_building_details = Buildings.get
local format = string.format
local display_percentage = Tirislib.Locales.display_percentage
local Table = Tirislib.Tables
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
            radiobutton.visible = Inhabitants.caste_is_researched(mode_id)
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
        local percentage = (current_tick - class[1]) / Entity.upbringing_time
        local count = Table.array_sum(class[2])
        classes_flow.add {
            name = tostring(index),
            type = "label",
            caption = {"sosciencity.show-class", count, display_percentage(percentage)}
        }

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
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local mode_flow = Datalist.get_kv_value_element(building_data, "mode")
    update_upbringing_mode_radiobuttons(entry, mode_flow)

    local probability_flow = Datalist.get_kv_value_element(building_data, "probabilities")
    local probabilities = Entity.get_upbringing_expectations(entry[EK.education_mode])
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

    update_classes_flow(entry, Datalist.get_kv_value_element(building_data, "classes"))

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

    Datalist.add_kv_flow(building_data, "classes", {"sosciencity.classes"})
    Datalist.add_kv_pair(building_data, "graduates", {"sosciencity.graduates"})

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

Gui.DetailsView.register_type(
    Type.upbringing_station,
    {creater = create_upbringing_station, updater = update_upbringing_station, always_update = true}
)
