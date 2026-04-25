--- Shared debug GUI widgets: dropdown data, scope picker, gender/age pickers, per-entry infect/cure primitives.
--- Consumed by both the city-view broadcast page (Surface 2) and the detail-view debug tabs (Surface 3).
--- Only usable when DEV_MODE is true (both consumers are DEV_MODE-gated).

local EK = require("enums.entry-key")
local DiseaseCategory = require("enums.disease-category")
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local Biology = require("constants.biology")

local random = math.random
local min = math.min
local floor = math.floor
local dice_rolls = Tirislib.Utils.dice_rolls

Gui.DebugWidgets = {}
local DebugWidgets = Gui.DebugWidgets

---------------------------------------------------------------------------------------------------
-- << Shared dropdown data (built once at require-time, deterministic across players) >>
---------------------------------------------------------------------------------------------------

DebugWidgets.caste_ids = {}
DebugWidgets.caste_items = {}
for i, caste in pairs(Castes.all) do
    DebugWidgets.caste_ids[i] = caste.type
    DebugWidgets.caste_items[i] = caste.localised_name
end

DebugWidgets.disease_ids = {}
DebugWidgets.disease_items = {}
for id in pairs(Diseases.values) do
    DebugWidgets.disease_ids[#DebugWidgets.disease_ids + 1] = id
end
table.sort(DebugWidgets.disease_ids, function(a, b) return Diseases.values[a].name < Diseases.values[b].name end)
for i, id in pairs(DebugWidgets.disease_ids) do
    DebugWidgets.disease_items[i] = Diseases.values[id].localised_name
end

DebugWidgets.category_ids = {}
DebugWidgets.category_items = {}
for name, id in pairs(DiseaseCategory) do
    DebugWidgets.category_ids[#DebugWidgets.category_ids + 1] = id
    DebugWidgets.category_items[#DebugWidgets.category_items + 1] = {"city-view.debug-infect-cat-" .. name}
end

---------------------------------------------------------------------------------------------------
-- << Layout helper >>
---------------------------------------------------------------------------------------------------

--- Adds a labelled horizontal row to `parent` and returns it. Subsequent children of the row
--- appear to the right of the label.
--- @param parent LuaGuiElement
--- @param caption_key string locale key under [city-view]
--- @param stacked boolean?
--- @return LuaGuiElement row
function DebugWidgets.labelled(parent, caption_key, stacked)
    local row = parent.add {type = "flow", direction = stacked and "vertical" or "horizontal"}
    row.style.vertical_align = "center"
    if not stacked then
        row.style.horizontal_spacing = 6
    end
    row.add {type = "label", caption = {caption_key}}
    return row
end

---------------------------------------------------------------------------------------------------
-- << Scope picker widget >>
---------------------------------------------------------------------------------------------------

local SCOPE_ITEMS = {
    {"city-view.debug-infect-scope-specific"},
    {"city-view.debug-infect-scope-category"},
    {"city-view.debug-infect-scope-any"}
}

--- Builds a scope dropdown and a companion target dropdown. Returns both; the caller is responsible
--- for registering the target dropdown at `(target_context, target_key, player_id)` so the shared
--- selection-state handler can rewrite it when the scope changes.
--- @param parent LuaGuiElement container for the two rows (scope + target).
--- @param target_context any Gui.register_element context for the target dropdown.
--- @param target_key string Gui.register_element key for the target dropdown.
--- @return LuaGuiElement scope_dd
--- @return LuaGuiElement target_dd
function DebugWidgets.build_scope_picker(parent, target_context, target_key)
    local scope_row = DebugWidgets.labelled(parent, "city-view.debug-infect-scope")
    local scope_dd = scope_row.add {
        type = "drop-down",
        items = SCOPE_ITEMS,
        selected_index = 1,
        tags = {
            sosciencity_gui_event = "debug_scope_picker_changed",
            target_context = target_context,
            target_key = target_key
        }
    }

    local target_row = DebugWidgets.labelled(parent, "city-view.debug-infect-target")
    local target_dd = target_row.add {
        type = "drop-down",
        items = DebugWidgets.disease_items,
        selected_index = 1
    }

    return scope_dd, target_dd
end

Gui.set_selection_state_changed_handler(
    "debug_scope_picker_changed",
    function(event)
        local tags = event.element.tags
        local target_dd = Gui.get_element(tags.target_context, tags.target_key, event.player_index)
        if not target_dd then return end
        local scope_idx = event.element.selected_index
        if scope_idx == 1 then
            target_dd.items = DebugWidgets.disease_items
            target_dd.enabled = true
        elseif scope_idx == 2 then
            target_dd.items = DebugWidgets.category_items
            target_dd.enabled = true
        else
            target_dd.items = {{"city-view.debug-infect-any"}}
            target_dd.enabled = false
        end
        target_dd.selected_index = 1
    end
)

---------------------------------------------------------------------------------------------------
-- << Gender picker widget >>
---------------------------------------------------------------------------------------------------

local GENDER_ITEMS = {
    {"city-view.debug-spawn-gender-even"},
    {"city-view.debug-spawn-gender-agender"},
    {"city-view.debug-spawn-gender-fale"},
    {"city-view.debug-spawn-gender-pachin"},
    {"city-view.debug-spawn-gender-ga"},
    {"city-view.debug-spawn-gender-egg"}
}

local EGG_ENTRIES = {}
for name, data in pairs(Biology.egg_data) do
    EGG_ENTRIES[#EGG_ENTRIES + 1] = {name = name, genders = data.genders}
end

local EGG_DD_ITEMS = {}
for i, egg in pairs(EGG_ENTRIES) do
    EGG_DD_ITEMS[i] = egg.name -- the localised name is 'Huwan Egg' for each one. So we just use the prototype name instead
end

--- Builds a gender dropdown and a companion egg sub-dropdown on a single labelled row.
--- The egg sub-dropdown is disabled until "Egg-based" is selected in the gender dropdown.
--- Caller is responsible for registering both returned elements.
--- @param parent LuaGuiElement
--- @param egg_context any context for Gui.register_element for the egg dropdown
--- @param egg_key string key for Gui.register_element for the egg dropdown
--- @return LuaGuiElement gender_dd
--- @return LuaGuiElement egg_dd
function DebugWidgets.build_gender_picker(parent, egg_context, egg_key, stacked)
    if stacked then
        parent.add {type = "label", caption = {"city-view.debug-spawn-gender"}}
        local gender_dd = parent.add {
            type = "drop-down",
            items = GENDER_ITEMS,
            selected_index = 1,
            tags = {
                sosciencity_gui_event = "debug_gender_picker_changed",
                egg_context = egg_context,
                egg_key = egg_key
            }
        }
        local egg_dd = parent.add {type = "drop-down", items = EGG_DD_ITEMS, selected_index = 1, enabled = false}
        return gender_dd, egg_dd
    end
    local row = DebugWidgets.labelled(parent, "city-view.debug-spawn-gender")
    local gender_dd = row.add {
        type = "drop-down",
        items = GENDER_ITEMS,
        selected_index = 1,
        tags = {
            sosciencity_gui_event = "debug_gender_picker_changed",
            egg_context = egg_context,
            egg_key = egg_key
        }
    }
    local egg_dd = row.add {type = "drop-down", items = EGG_DD_ITEMS, selected_index = 1, enabled = false}
    return gender_dd, egg_dd
end

Gui.set_selection_state_changed_handler(
    "debug_gender_picker_changed",
    function(event)
        local tags = event.element.tags
        local egg_dd = Gui.get_element(tags.egg_context, tags.egg_key, event.player_index)
        if egg_dd then
            egg_dd.enabled = event.element.selected_index == 6
        end
    end
)

--- Builds the GenderGroup for the given picker selection.
--- @param gender_idx integer selected index of the gender dropdown
--- @param egg_idx integer selected index of the egg sub-dropdown
--- @param count integer number of inhabitants
--- @return GenderGroup
function DebugWidgets.make_gender_group(gender_idx, egg_idx, count)
    if gender_idx == 1 then
        local base = floor(count / 4)
        local rem = count % 4
        return GenderGroup.new(
            base + (rem > 0 and 1 or 0),
            base + (rem > 1 and 1 or 0),
            base + (rem > 2 and 1 or 0),
            base
        )
    elseif gender_idx == 2 then return GenderGroup.new(count, 0, 0, 0)
    elseif gender_idx == 3 then return GenderGroup.new(0, count, 0, 0)
    elseif gender_idx == 4 then return GenderGroup.new(0, 0, count, 0)
    elseif gender_idx == 5 then return GenderGroup.new(0, 0, 0, count)
    else
        return dice_rolls(EGG_ENTRIES[egg_idx].genders, count, 20)
    end
end

---------------------------------------------------------------------------------------------------
-- << Age picker widget >>
---------------------------------------------------------------------------------------------------

local AGE_ITEMS = {
    {"city-view.debug-spawn-age-zero"},
    {"city-view.debug-spawn-age-random"},
    {"city-view.debug-spawn-age-fixed"}
}

--- Builds an age dropdown and a companion numeric field on a single labelled row.
--- The numeric field is disabled until "Fixed age" is selected in the age dropdown.
--- Caller is responsible for registering both returned elements.
--- @param parent LuaGuiElement
--- @param age_value_context any context for Gui.register_element for the age value field
--- @param age_value_key string key for Gui.register_element for the age value field
--- @return LuaGuiElement age_dd
--- @return LuaGuiElement age_value
function DebugWidgets.build_age_picker(parent, age_value_context, age_value_key, stacked)
    if stacked then
        parent.add {type = "label", caption = {"city-view.debug-spawn-age"}}
        local age_dd = parent.add {
            type = "drop-down",
            items = AGE_ITEMS,
            selected_index = 1,
            tags = {
                sosciencity_gui_event = "debug_age_picker_changed",
                age_value_context = age_value_context,
                age_value_key = age_value_key
            }
        }
        local age_value = Gui.Elements.NumericTextField.create(parent)
        age_value.text = "30"
        age_value.enabled = false
        return age_dd, age_value
    end
    local row = DebugWidgets.labelled(parent, "city-view.debug-spawn-age")
    local age_dd = row.add {
        type = "drop-down",
        items = AGE_ITEMS,
        selected_index = 1,
        tags = {
            sosciencity_gui_event = "debug_age_picker_changed",
            age_value_context = age_value_context,
            age_value_key = age_value_key
        }
    }
    local age_value = Gui.Elements.NumericTextField.create(row)
    age_value.text = "30"
    age_value.enabled = false
    return age_dd, age_value
end

Gui.set_selection_state_changed_handler(
    "debug_age_picker_changed",
    function(event)
        local tags = event.element.tags
        local age_value = Gui.get_element(tags.age_value_context, tags.age_value_key, event.player_index)
        if age_value then
            age_value.enabled = event.element.selected_index == 3
        end
    end
)

--- Builds the AgeGroup for the given picker selection.
--- @param age_idx integer selected index of the age dropdown
--- @param count integer number of inhabitants
--- @param age_value integer? fixed age (only used when age_idx == 3)
--- @return AgeGroup
function DebugWidgets.make_age_group(age_idx, count, age_value)
    if age_idx == 1 then
        return AgeGroup.new(count, 0)
    elseif age_idx == 2 then
        return AgeGroup.new_immigrants(count)
    else
        return AgeGroup.new(count, age_value or 0)
    end
end

---------------------------------------------------------------------------------------------------
-- << Per-entry infect/cure primitives >>
---------------------------------------------------------------------------------------------------

local HEALTHY = DiseaseGroup.HEALTHY

--- Applies infection to a single disease group, up to `cap` inhabitants.
--- @param diseases DiseaseGroup
--- @param cap integer upper bound on infections (caller has already minned against healthy count if needed)
--- @param scope_idx integer 1=specific, 2=random from category, 3=any random
--- @param target_idx integer index into disease_ids or category_ids depending on scope
--- @return integer actually_sickened
function DebugWidgets.apply_infection_to_entry(diseases, cap, scope_idx, target_idx)
    local take = min(cap, diseases[HEALTHY])
    if take <= 0 then return 0 end
    if scope_idx == 1 then
        return DiseaseGroup.make_sick(diseases, DebugWidgets.disease_ids[target_idx], take)
    elseif scope_idx == 2 then
        DiseaseGroup.make_sick_randomly(diseases, DebugWidgets.category_ids[target_idx], take, take, true)
        return take
    else
        local disease_id = DebugWidgets.disease_ids[random(#DebugWidgets.disease_ids)]
        return DiseaseGroup.make_sick(diseases, disease_id, take)
    end
end

--- Picks a disease that `diseases` currently has with count > 0, matching the chosen scope.
--- Returns nil if no matching disease is present.
local function pick_disease_to_cure(diseases, scope_idx, target_idx)
    if scope_idx == 1 then
        local id = DebugWidgets.disease_ids[target_idx]
        return (diseases[id] or 0) > 0 and id or nil
    end

    local available = {}
    if scope_idx == 2 then
        local category_id = DebugWidgets.category_ids[target_idx]
        for id in pairs(Diseases.categories[category_id] or {}) do
            if (diseases[id] or 0) > 0 then
                available[#available + 1] = id
            end
        end
    else
        for id, count in pairs(diseases) do
            if id ~= HEALTHY and count > 0 then
                available[#available + 1] = id
            end
        end
    end

    if #available == 0 then return nil end
    return available[random(#available)]
end

--- Cures inhabitants in a single entry, applying cure side effects (escalation/complication rolls).
--- @param entry Entry housing entry; must have [EK.diseases]
--- @param cap integer upper bound on cures
--- @param scope_idx integer 1=specific, 2=random from category, 3=any random
--- @param target_idx integer index into disease_ids or category_ids depending on scope
--- @return integer actually_cured
function DebugWidgets.apply_cure_to_entry(entry, cap, scope_idx, target_idx)
    local diseases = entry[EK.diseases]
    local disease_id = pick_disease_to_cure(diseases, scope_idx, target_idx)
    if not disease_id then return 0 end

    local cured = DiseaseGroup.cure(diseases, disease_id, cap)
    if cured > 0 then
        Inhabitants.apply_cure_side_effects(entry, disease_id, cured, true)
    end
    return cured
end
