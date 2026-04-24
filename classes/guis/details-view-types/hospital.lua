--- Details view for hospitals.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local TypeGroup = require("constants.type-groups")
local type_definitions = require("constants.types").definitions

local get_building_details = Buildings.get

local diseases = Diseases.values
local Entity = Entity
local Gui = Gui
local Neighborhood = Neighborhood
local Register = Register
local floor = math.floor
local format = string.format
local Table = Tirislib.Tables
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << hospital >>

local function update_disease_catalogue(container, entry)
    local tabbed_pane = container.tabpane
    local data_list = Gui.Elements.Tabs.get_content(tabbed_pane, "diseases").diseases

    local statistics = entry[EK.treated]
    local permissions = entry[EK.treatment_permissions]

    for id, disease in pairs(Diseases.values) do
        data_list[tostring(id)].caption = statistics[id] or 0

        if disease.is_treatable then
            data_list[format(Gui.unique_prefix_builder, "treatment-permission", tostring(id))].state =
                permissions[id] == nil and true or permissions[id]
        end
    end
end

local function create_disease_catalogue(container)
    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "diseases", {"sosciencity.diseases"})

    Gui.Elements.Button.page_link(tab, "data", "diseases")

    local data_list = Datalist.create(tab, "diseases", 3)
    data_list.style.column_alignments[2] = "right"

    -- build the header
    local head =
        data_list.add {
        type = "label",
        name = "head",
        caption = {"sosciencity.diseases"}
    }
    head.style.font = "default-bold"
    local head_count =
        data_list.add {
        type = "label",
        name = "head-count"
    }
    head_count.style.minimal_width = 30
    data_list.add {
        type = "label",
        name = "head-permission"
    }

    -- disease entries
    for id, disease in pairs(Diseases.values) do
        local key =
            data_list.add {
            type = "label",
            name = "key-" .. id,
            caption = disease.localised_name,
            tooltip = disease.localised_description
        }
        key.style.horizontally_stretchable = true

        data_list.add {
            type = "label",
            name = tostring(id)
        }

        if disease.is_treatable then
            data_list.add {
                type = "checkbox",
                name = format(Gui.unique_prefix_builder, "treatment-permission", tostring(id)),
                state = true,
                tooltip = {"sosciencity.treatment-permission"},
                tags = {sosciencity_gui_event = "treatment_permission_checkbox", disease_id = id}
            }
        else
            data_list.add {type = "label", name = format(Gui.unique_prefix_builder, "treatment-permission", tostring(id))}
        end
    end
end

Gui.set_checked_state_handler(
    "treatment_permission_checkbox",
    function(event)
        local player_id = event.player_index
        local entry = Register.try_get(storage.details_view[player_id])
        local disease_id = event.element.tags.disease_id
        entry[EK.treatment_permissions][disease_id] = event.element.state
    end
)

local function find_all_neighborhood_diseases(entry)
    local ret = {}

    for _, caste in pairs(Castes.all) do
        for _, house in Neighborhood.iterate_type(entry, caste.type) do
            Table.add(ret, house[EK.diseases])
        end
    end

    return ret
end

local function update_treatment_slots(general, entry)
    local treatments = general.treatments
    treatments.clear()

    local slots = entry[EK.slots]
    for i, slot in pairs(slots) do
        local housing = Register.try_get(slot.uid)
        if housing then
            local housing_type_details = type_definitions[housing[EK.type]]
            local pos = housing[EK.entity].position
            treatments.add {
                type = "label",
                name = "house-" .. i,
                caption = {"sosciencity.slot-house", housing_type_details.localised_name, floor(pos.x), floor(pos.y)}
            }

            local workload, slot_caption, slot_tooltip
            if slot.blood_donation then
                workload = Biology.blood_donation_workload
                slot_caption = {"sosciencity.blood-donation-slot"}
            else
                local disease = diseases[slot.disease_id]
                workload = disease.curing_workload
                slot_caption = disease.localised_name
                slot_tooltip = disease.localised_description
            end

            treatments.add {
                type = "label",
                name = "disease-" .. i,
                caption = slot_caption,
                tooltip = slot_tooltip
            }

            local progress = math.min((slot.work_done or 0) / workload, 1)
            local progressbar =
                treatments.add {
                type = "progressbar",
                name = "progress-" .. i,
                value = progress,
                tooltip = {"sosciencity.slot-progress", floor(progress * 100), workload}
            }
            progressbar.style.horizontally_stretchable = true
            progressbar.style.minimal_width = 100
        end
    end
end

local function update_hospital_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local effective_slots = get_building_details(entry).slots
    Datalist.set_kv_pair_value(building_data, "capacity", {"sosciencity.show-slots", #entry[EK.slots], effective_slots})

    local facility_flow = Datalist.get_kv_value_element(building_data, "facilities")
    facility_flow.clear()
    for _, _type in pairs(TypeGroup.hospital_complements) do
        local has_one = false
        for _, facility in Neighborhood.iterate_type(entry, _type) do
            if Entity.is_active(facility) then
                has_one = true
                break
            end
        end

        if has_one then
            local type_details = type_definitions[_type]

            facility_flow.add {
                type = "label",
                name = tostring(_type),
                caption = type_details.localised_name,
                tooltip = type_details.localised_description
            }
        end
    end

    Datalist.set_kv_pair_value(building_data, "blood_donations", entry[EK.blood_donations])

    local patients = general.patients
    patients.clear()

    local patient_diseases = find_all_neighborhood_diseases(entry)
    for disease_id, count in pairs(patient_diseases) do
        if disease_id ~= DiseaseGroup.HEALTHY then
            local disease = diseases[disease_id]
            local key = format("disease-%d", disease_id)
            Datalist.add_operand_entry(patients, key, disease.localised_name, count)
            Datalist.set_kv_pair_tooltip(patients, key, disease.localised_description)
        end
    end

    update_treatment_slots(general, entry)
    update_disease_catalogue(container, entry)
end

local function create_hospital_debug_tab(tabbed_pane)
    local content = Gui.Elements.Tabs.create(tabbed_pane, "debug", {"city-view.debug-tab"})
    content.add {
        type = "button",
        style = "red_button",
        caption = {"city-view.debug-hospital-complete-go"},
        tooltip = {"city-view.debug-hospital-complete-tooltip"},
        tags = {sosciencity_gui_event = "debug_hospital_complete_slots"}
    }
end

local function create_hospital_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    Datalist.add_kv_flow(building_data, "facilities", {"sosciencity.facilities"})
    if (entry[EK.type] == Type.improvised_hospital) then
        Datalist.set_kv_pair_visibility(building_data, "facilities", false)
    end

    Datalist.add_kv_pair(building_data, "blood_donations", {"sosciencity.blood-donations"})
    Datalist.set_kv_pair_visibility(building_data, "blood_donations", storage.technologies["transfusion-medicine"])

    local textfield =
        Datalist.add_kv_textfield(
        building_data,
        "blood-donation-threshold",
        format(Gui.unique_prefix_builder, "blood-donation-threshold", "hospital"),
        {numeric = true, allow_decimal = false, allow_negative = false},
        {"sosciencity.free-slots-threshold"}
    )
    textfield.text = tostring(entry[EK.blood_donation_threshold])
    textfield.tooltip = {"sosciencity.blood-donation-threshold"}
    textfield.tags = {sosciencity_gui_event = "blood_donation_threshold"}
    building_data["key-blood-donation-threshold"].visible = storage.technologies["transfusion-medicine"]
    textfield.visible = storage.technologies["transfusion-medicine"]

    Gui.Elements.Label.header_label(general, "header-patients", {"sosciencity.patients"})
    Datalist.create(general, "patients")

    Gui.Elements.Label.header_label(general, "header-treatments", {"sosciencity.treatments-in-progress"})
    Datalist.create(general, "treatments", 3)

    create_disease_catalogue(container)

    if DEV_MODE then
        create_hospital_debug_tab(tabbed_pane)
    end

    update_hospital_details(container, entry)
end

Gui.set_gui_confirmed_handler(
    "blood_donation_threshold",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        entry[EK.blood_donation_threshold] = tonumber(event.element.text)
    end
)

if DEV_MODE then
    Gui.set_click_handler(
        "debug_hospital_complete_slots",
        function(event)
            local entry = Register.try_get(storage.details_view[event.player_index])
            if not entry then return end
            local slots = entry[EK.slots]
            local statistics = entry[EK.treated]
            local completed = 0
            for i = #slots, 1, -1 do
                local slot = slots[i]
                if slot.blood_donation then
                    slot.done = true
                else
                    local housing = Register.try_get(slot.uid)
                    if housing then
                        local disease_id = slot.disease_id
                        DiseaseGroup.cure(housing[EK.diseases], disease_id, 1)
                        Inhabitants.apply_cure_side_effects(housing, disease_id, 1, true)
                        statistics[disease_id] = (statistics[disease_id] or 0) + 1
                        Communication.report_treatment(disease_id, 1)
                    end
                end
                table.remove(slots, i)
                completed = completed + 1
            end
            game.players[event.player_index].print({"city-view.debug-hospital-complete-done", completed})
        end
    )
end

Gui.DetailsView.register_type(Type.hospital, {creater = create_hospital_details, updater = update_hospital_details})
Gui.DetailsView.register_type(
    Type.improvised_hospital,
    {creater = create_hospital_details, updater = update_hospital_details}
)
