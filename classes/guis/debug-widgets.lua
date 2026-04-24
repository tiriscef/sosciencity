--- Shared debug GUI widgets: dropdown data, scope picker, per-entry infect/cure primitives.
--- Consumed by both the city-view broadcast page (Surface 2) and the detail-view debug tabs (Surface 3).
--- Only usable when DEV_MODE is true (both consumers are DEV_MODE-gated).

local EK = require("enums.entry-key")
local DiseaseCategory = require("enums.disease-category")
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")

local random = math.random
local min = math.min

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
--- @return LuaGuiElement row
function DebugWidgets.labelled(parent, caption_key)
    local row = parent.add {type = "flow", direction = "horizontal"}
    row.style.vertical_align = "center"
    row.style.horizontal_spacing = 6
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
