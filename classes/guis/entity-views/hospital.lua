--- Details views for hospitals and their wards.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local InhabitantsConstants = require("constants.inhabitants")
local Types = require("constants.types")
local type_definitions = Types.definitions
local ward_types = Types.select("is_hospital_ward")

-- classes
local DevMode = require("classes.dev-mode")

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
-- << beds >>

local function add_bed_card(flow, name, housing, caption, tooltip, work_done, workload)
    local housing_type_details = type_definitions[housing[EK.type]]
    local pos = housing[EK.entity].position

    local card = flow.add {type = "frame", name = name, direction = "vertical", style = "sosciencity_card_frame"}
    card.style.horizontally_stretchable = true

    local label = card.add {
        type = "label",
        name = "label",
        caption = {"", {"sosciencity.slot-house", housing_type_details.localised_name, floor(pos.x), floor(pos.y)}, "  ", caption},
        tooltip = tooltip
    }
    label.style.single_line = false

    local progress = math.min(work_done / workload, 1)
    local progressbar = card.add {
        type = "progressbar",
        name = "progress",
        value = progress,
        tooltip = {"sosciencity.slot-progress", floor(progress * 100), workload}
    }
    progressbar.style.horizontally_stretchable = true
end

--- Adds a card with the patient and the progress for every occupied bed of the given bed building.
local function add_bed_cards(flow, bed_building)
    for i, slot in pairs(bed_building[EK.slots]) do
        local housing = Register.try_get(slot.uid)
        if housing then
            local disease = diseases[slot.disease_id]
            add_bed_card(
                flow,
                "slot-" .. i,
                housing,
                disease.localised_name,
                disease.localised_description,
                slot.work_done or 0,
                disease.curing_workload
            )
        end
    end

    for i, slot in pairs(bed_building[EK.donation_slots]) do
        local housing = Register.try_get(slot.uid)
        if housing then
            add_bed_card(
                flow,
                "donation-" .. i,
                housing,
                {"sosciencity.blood-donation-slot"},
                nil,
                slot.work_done or 0,
                InhabitantsConstants.blood_donation_workload
            )
        end
    end

    for i, slot in pairs(bed_building[EK.vaccination_slots]) do
        local housing = Register.try_get(slot.uid)
        if housing then
            add_bed_card(
                flow,
                "vaccination-" .. i,
                housing,
                {"sosciencity.vaccination-slot", {"item-name." .. slot.vaccine}},
                nil,
                slot.work_done or 0,
                InhabitantsConstants.vaccination_workload
            )
        end
    end
end

local function get_bed_caption(bed_building)
    return {"sosciencity.show-beds", Entity.Hospital.get_occupied_bed_count(bed_building), Entity.Hospital.get_bed_count(bed_building)}
end

---------------------------------------------------------------------------------------------------
-- << hospital >>

--- Returns all the wards connected to the given hospital, active or not.
local function get_connected_wards(hospital)
    local ret = {}
    for _, _type in pairs(ward_types) do
        for _, ward in Neighborhood.iterate_type(hospital, _type) do
            ret[#ret + 1] = ward
        end
    end
    return ret
end

local function update_disease_catalogue(container, entry, wards)
    local tabbed_pane = container.tabpane
    local data_list = Gui.Elements.Tabs.get_content(tabbed_pane, "diseases").diseases

    local statistics = entry[EK.treated]
    local permissions = entry[EK.treatment_permissions]

    for id, disease in pairs(Diseases.values) do
        local treated = statistics[id] or 0
        for _, ward in pairs(wards) do
            treated = treated + (ward[EK.treated][id] or 0)
        end
        data_list[tostring(id)].caption = treated

        if disease.is_treatable then
            data_list[format(Gui.unique_prefix_builder, "treatment-permission", tostring(id))].state =
                permissions[id] == nil and true or permissions[id]
        end
    end
end

local function create_disease_catalogue(container)
    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "diseases", {"sosciencity.diseases"}, "sosciencity_details_tab")

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

local function update_hospital_treatments(general, entry, wards)
    local treatments = general.treatments
    treatments.clear()

    add_bed_cards(treatments, entry)

    for _, ward in pairs(wards) do
        local unit_number = ward[EK.unit_number]
        local pos = ward[EK.entity].position
        local caption = {
            "",
            {
                "sosciencity.ward-beds",
                type_definitions[ward[EK.type]].localised_name,
                floor(pos.x),
                floor(pos.y),
                Entity.Hospital.get_occupied_bed_count(ward),
                Entity.Hospital.get_bed_count(ward)
            }
        }
        if not ward[EK.active] then
            caption[#caption + 1] = " "
            caption[#caption + 1] = {"sosciencity.ward-inactive"}
        end

        local heading = treatments.add {type = "label", name = "ward-" .. unit_number, caption = caption}
        heading.style.font = "default-bold"
        heading.style.top_margin = 8

        local ward_flow = treatments.add {type = "flow", name = "ward-beds-" .. unit_number, direction = "vertical"}
        add_bed_cards(ward_flow, ward)
    end
end

local function update_hospital_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local wards = get_connected_wards(entry)

    Datalist.set_kv_pair_value(building_data, "capacity", get_bed_caption(entry))

    -- one label per ward type with at least one active ward
    local ward_flow = Datalist.get_kv_value_element(building_data, "wards")
    ward_flow.clear()
    for _, ward in pairs(wards) do
        local _type = ward[EK.type]
        if ward[EK.active] and not ward_flow[tostring(_type)] then
            local type_details = type_definitions[_type]
            ward_flow.add {
                type = "label",
                name = tostring(_type),
                caption = type_details.localised_name,
                tooltip = type_details.localised_description
            }
        end
    end
    Datalist.set_kv_pair_visibility(building_data, "wards", #ward_flow.children > 0)

    local blood_donations = entry[EK.blood_donations]
    local vaccinations = entry[EK.vaccinations]
    for _, ward in pairs(wards) do
        blood_donations = blood_donations + ward[EK.blood_donations]
        vaccinations = vaccinations + ward[EK.vaccinations]
    end
    Datalist.set_kv_pair_value(building_data, "blood_donations", blood_donations)
    Datalist.set_kv_pair_value(building_data, "vaccinations", vaccinations)

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

    update_hospital_treatments(general, entry, wards)
    update_disease_catalogue(container, entry, wards)
end

local function create_hospital_debug_tab(tabbed_pane)
    local content = Gui.Elements.Tabs.create(tabbed_pane, "debug", {"city-view.debug-tab"}, "sosciencity_details_tab")
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
    Datalist.add_kv_flow(building_data, "wards", {"sosciencity.wards"})

    Datalist.add_kv_pair(building_data, "blood_donations", {"sosciencity.blood-donations"})
    Datalist.set_kv_pair_visibility(building_data, "blood_donations", storage.technologies["transfusion-medicine"])

    Datalist.add_kv_pair(building_data, "vaccinations", {"sosciencity.vaccinations"})
    Datalist.set_kv_pair_visibility(building_data, "vaccinations", storage.technologies["vaccination"])

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
    general.add {type = "flow", name = "treatments", direction = "vertical"}

    create_disease_catalogue(container)

    if DevMode.is_active() then
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

Gui.set_click_handler(
    "debug_hospital_complete_slots",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end

        -- fill up the work of every bed, the next updates of the bed buildings finish them
        local completed = 0
        local bed_buildings = get_connected_wards(entry)
        bed_buildings[#bed_buildings + 1] = entry
        for _, bed_building in pairs(bed_buildings) do
            for _, slot in pairs(bed_building[EK.slots]) do
                slot.work_done = diseases[slot.disease_id].curing_workload
                completed = completed + 1
            end
            for _, slot in pairs(bed_building[EK.donation_slots]) do
                slot.work_done = InhabitantsConstants.blood_donation_workload
                completed = completed + 1
            end
            for _, slot in pairs(bed_building[EK.vaccination_slots]) do
                slot.work_done = InhabitantsConstants.vaccination_workload
                completed = completed + 1
            end
        end
        game.players[event.player_index].print({"city-view.debug-hospital-complete-done", completed})
    end
)

Gui.DetailsView.register_type(Type.hospital, {creater = create_hospital_details, updater = update_hospital_details})
Gui.DetailsView.register_type(
    Type.improvised_hospital,
    {creater = create_hospital_details, updater = update_hospital_details}
)

---------------------------------------------------------------------------------------------------
-- << wards >>

local function update_ward_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(container.tabpane, "general")
    local building_data = general.building

    Datalist.set_kv_pair_value(building_data, "capacity", get_bed_caption(entry))
    Datalist.set_kv_pair_value(building_data, "blood_donations", entry[EK.blood_donations])
    Datalist.set_kv_pair_value(building_data, "vaccinations", entry[EK.vaccinations])

    local hospital_flow = Datalist.get_kv_value_element(building_data, "hospitals")
    hospital_flow.clear()
    for _, hospital in Neighborhood.iterate_type(entry, Type.hospital) do
        local pos = hospital[EK.entity].position
        hospital_flow.add {
            type = "label",
            name = tostring(hospital[EK.unit_number]),
            caption = {"sosciencity.slot-house", type_definitions[Type.hospital].localised_name, floor(pos.x), floor(pos.y)}
        }
    end
    if #hospital_flow.children == 0 then
        hospital_flow.add {type = "label", name = "none", caption = {"sosciencity.no-connected-hospital"}}
    end

    local treatments = general.treatments
    treatments.clear()
    add_bed_cards(treatments, entry)
end

local function create_ward_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    Datalist.add_kv_flow(building_data, "hospitals", {"sosciencity.connected-hospitals"})

    Datalist.add_kv_pair(building_data, "blood_donations", {"sosciencity.blood-donations"})
    Datalist.set_kv_pair_visibility(
        building_data,
        "blood_donations",
        type_definitions[entry[EK.type]].treats_general_medicine == true and storage.technologies["transfusion-medicine"] ~= nil
    )

    Datalist.add_kv_pair(building_data, "vaccinations", {"sosciencity.vaccinations"})
    Datalist.set_kv_pair_visibility(
        building_data,
        "vaccinations",
        type_definitions[entry[EK.type]].treats_general_medicine == true and storage.technologies["vaccination"] ~= nil
    )

    Gui.Elements.Label.header_label(general, "header-treatments", {"sosciencity.treatments-in-progress"})
    general.add {type = "flow", name = "treatments", direction = "vertical"}

    update_ward_details(container, entry, player_id)
end

for _, _type in pairs(ward_types) do
    Gui.DetailsView.register_type(_type, {creater = create_ward_details, updater = update_ward_details})
end

---------------------------------------------------------------------------------------------------
-- << building overview >>

local overview_types = {Type.hospital, Type.improvised_hospital}
for _, _type in pairs(ward_types) do
    overview_types[#overview_types + 1] = _type
end

Gui.BuildingOverview.register_type("hospitals", {
    types = overview_types,
    layout = "grid",
    stats_creator = function(flow, entry)
        flow.add {
            type = "label",
            caption = get_bed_caption(entry)
        }
    end
})
