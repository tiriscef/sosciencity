--- Debug category for the CityView - shared home for all dev-tool pages.
--- Only loaded when DEV_MODE is true (either sosciencity-debug or sosciencity-balancing active).

local Castes = require("constants.castes")

Gui.CityView.add_category("debug", {"city-view.debug"})

---------------------------------------------------------------------------------------------------
-- << Constants >>
---------------------------------------------------------------------------------------------------

local CONTEXT = "balancing-progression"
local MAIN_FLOW_KEY = "main_flow"

local Q = Tirislib.LazyLuaq

---------------------------------------------------------------------------------------------------
-- << Data helpers >>
---------------------------------------------------------------------------------------------------

-- Subgroups of all sosciencity prototypes start with "sosciencity-".
-- This is the only reliable way to identify mod ownership at runtime
-- since LuaPrototypeBase does not expose a mod field.
local function is_sosciencity(proto)
    return proto.subgroup and Tirislib.String.begins_with(proto.subgroup.name, "sosciencity-")
end

local function get_all_science_packs()
    local seen = {}
    local packs = {}

    for _, tech in pairs(prototypes.technology) do
        for _, ingredient in pairs(tech.research_unit_ingredients) do
            if not seen[ingredient.name] then
                seen[ingredient.name] = true
                packs[#packs + 1] = ingredient.name
            end
        end
    end

    table.sort(packs, function(a, b)
        local pa = prototypes.item[a]
        local pb = prototypes.item[b]
        local oa = pa and ((pa.subgroup and pa.subgroup.order or "") .. "\x00" .. (pa.order or "")) or a
        local ob = pb and ((pb.subgroup and pb.subgroup.order or "") .. "\x00" .. (pb.order or "")) or b
        return oa < ob
    end)

    return packs
end

-- Returns:
--   tech_to_recipes  {[tech_name] = [recipe_name, ...]}
--   all_tech_recipes {[recipe_name] = true}  -- recipes unlockable by any tech (i.e. not start recipes)
local function build_tech_to_recipes()
    local tech_to_recipes = {}
    local all_tech_recipes = {}

    for tech_name, tech in pairs(prototypes.technology) do
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" then
                if not tech_to_recipes[tech_name] then tech_to_recipes[tech_name] = {} end
                local t = tech_to_recipes[tech_name]
                t[#t + 1] = effect.recipe
                all_tech_recipes[effect.recipe] = true
            end
        end
    end

    return tech_to_recipes, all_tech_recipes
end

-- Returns the set of recipe names available at a given tech tier.
-- A recipe is available if it is a start recipe (not locked by any tech, and
-- include_start_recipes is true) or if at least one tech that unlocks it is in available_techs.
local function compute_available_recipe_set(available_techs, tech_to_recipes, all_tech_recipes, include_start_recipes)
    local available = {}

    if include_start_recipes then
        for recipe_name, recipe in pairs(prototypes.recipe) do
            if not recipe.parameter and not all_tech_recipes[recipe_name] then
                available[recipe_name] = true
            end
        end
    end

    for tech_name in pairs(available_techs) do
        for _, recipe_name in pairs(tech_to_recipes[tech_name] or {}) do
            available[recipe_name] = true
        end
    end

    return available
end

-- Returns a set of tech_names researchable with the given checked_packs.
-- When include_trigger_techs is false, techs with a research_trigger are excluded.
local function compute_available_techs(checked_packs, include_trigger_techs)
    local available = {}
    local changed = true

    while changed do
        changed = false
        for tech_name, tech in pairs(prototypes.technology) do
            if not available[tech_name] then
                if not include_trigger_techs and tech.research_trigger then
                    -- skip
                else
                    local ok = true

                    for _, ingredient in pairs(tech.research_unit_ingredients) do
                        if not checked_packs[ingredient.name] then
                            ok = false
                            break
                        end
                    end

                    if ok then
                        for prereq_name in pairs(tech.prerequisites) do
                            if not available[prereq_name] then
                                ok = false
                                break
                            end
                        end
                    end

                    if ok then
                        available[tech_name] = true
                        changed = true
                    end
                end
            end
        end
    end

    return available
end

-- Collects all items and fluids reachable at a given tech tier, from all sources:
--   - recipe products (start recipes + recipes unlocked by available_techs)
--   - world items (mined resources, offshore pump fluids, hand-minable autoplaced entities)
--   - scripted items (registered via BalancingData)
--   - spoilage chains (iterative: items whose spoil_result is not yet reachable)
--
-- All sources feed a single fixpoint loop so that cross-source dependencies
-- (e.g. a spoilage result that is placeable and enables new mining) are handled.
--
-- Returns:
--   items      {[name] = true}
--   fluids     {[name] = true}
--   item_meta  {[name] = {entities=[...], scripted=bool}}
--   fluid_meta {[name] = {entities=[...], scripted=bool}}
local function collect_available_resources(available_techs, available_recipes, sosciencity_only)
    local items = {}
    local fluids = {}
    local item_meta = {}
    local fluid_meta = {}

    local changed -- upvalue; set to true by add_item/add_fluid when a new entry is added

    local function add_item(name, entity_name, scripted)
        local proto = prototypes.item[name]
        if not proto or proto.parameter then return end
        if sosciencity_only and not is_sosciencity(proto) then return end
        if not items[name] then
            items[name] = true
            item_meta[name] = {entities = {}, scripted = scripted or false}
            changed = true
        end
        if entity_name and not Tirislib.Arrays.contains(item_meta[name].entities, entity_name) then
            item_meta[name].entities[#item_meta[name].entities + 1] = entity_name
        end
        if scripted then item_meta[name].scripted = true end
    end

    local function add_fluid(name, entity_name, scripted)
        local proto = prototypes.fluid[name]
        if not proto or proto.parameter then return end
        if sosciencity_only and not is_sosciencity(proto) then return end
        if not fluids[name] then
            fluids[name] = true
            fluid_meta[name] = {entities = {}, scripted = scripted or false}
            changed = true
        end
        if entity_name and not Tirislib.Arrays.contains(fluid_meta[name].entities, entity_name) then
            fluid_meta[name].entities[#fluid_meta[name].entities + 1] = entity_name
        end
        if scripted then fluid_meta[name].scripted = true end
    end

    local function add_product(product, entity_name, scripted)
        if product.type == "fluid" then
            add_fluid(product.name, entity_name, scripted)
        else
            add_item(product.name, entity_name, scripted)
        end
    end

    changed = true
    while changed do
        changed = false

        -- Source 1: recipe products
        for recipe_name in pairs(available_recipes) do
            local recipe = prototypes.recipe[recipe_name]
            if recipe then
                for _, product in pairs(recipe.products) do
                    add_product(product)
                end
            end
        end

        -- Source 2: world items
        -- Find entities placeable from currently available items.
        local available_entities = {}
        for item_name in pairs(items) do
            local item = prototypes.item[item_name]
            if item and item.place_result then
                available_entities[item.place_result.name] = true
            end
        end

        -- Determine which resource categories can be mined (and which support fluid mining).
        local drill_categories = {}
        local fluid_drill_categories = {}
        for entity_name in pairs(available_entities) do
            local entity = prototypes.entity[entity_name]
            if entity and entity.type == "mining-drill" then
                local has_fluid_input = false
                for _, fb in pairs(entity.fluidbox_prototypes) do
                    if fb.production_type == "input" then
                        has_fluid_input = true
                        break
                    end
                end
                for cat_name in pairs(entity.resource_categories) do
                    drill_categories[cat_name] = true
                    if has_fluid_input then fluid_drill_categories[cat_name] = true end
                end
            end
        end

        local mining_with_fluid_unlocked = false
        for tech_name in pairs(available_techs) do
            local tech = prototypes.technology[tech_name]
            if tech then
                for _, effect in pairs(tech.effects) do
                    if effect.type == "mining-with-fluid" then
                        mining_with_fluid_unlocked = true
                        break
                    end
                end
                if mining_with_fluid_unlocked then break end
            end
        end

        for _, entity in pairs(prototypes.entity) do
            if entity.type == "resource" then
                local props = entity.mineable_properties
                if props and props.minable and props.products then
                    local cat = entity.resource_category
                    if drill_categories[cat] then
                        local req_fluid = props.required_fluid
                        local fluid_ok = not req_fluid or
                            (mining_with_fluid_unlocked and
                             fluid_drill_categories[cat] and
                             fluids[req_fluid])
                        if fluid_ok then
                            for _, product in pairs(props.products) do
                                add_product(product, entity.name)
                            end
                        end
                    end
                end
            elseif entity.autoplace_specification then
                -- Non-resource autoplaced entities (trees, rocks) can be hand-mined.
                local props = entity.mineable_properties
                if props and props.minable and props.products then
                    for _, product in pairs(props.products) do
                        add_product(product, entity.name)
                    end
                end
            elseif entity.type == "offshore-pump" and available_entities[entity.name] then
                for _, fb in pairs(entity.fluidbox_prototypes) do
                    if fb.filter and fb.production_type == "output" then
                        add_fluid(fb.filter.name, entity.name)
                    end
                end
            end
        end

        -- Source 3: scripted items
        for item_name, condition in pairs(BalancingData.scripted_items) do
            local tech_name = condition == "always" and nil or condition
            if tech_name == nil or available_techs[tech_name] then
                if prototypes.fluid[item_name] then
                    add_fluid(item_name, nil, true)
                else
                    add_item(item_name, nil, true)
                end
            end
        end

        -- Source 4: spoilage chains
        for name in pairs(items) do
            local proto = prototypes.item[name]
            if proto and proto.spoil_result then
                add_item(proto.spoil_result.name)
            end
        end

    end

    return items, fluids, item_meta, fluid_meta
end

---------------------------------------------------------------------------------------------------
-- << Controls state readers >>
---------------------------------------------------------------------------------------------------

-- Returns:
--   baseline_packs, target_packs  {[pack_name] = true}
--   baseline_start_recipes, baseline_trigger_techs, target_start_recipes, target_trigger_techs  bool
local function get_selections(main_flow)
    local baseline_packs = {}
    local target_packs = {}
    local baseline_start_recipes = false
    local baseline_trigger_techs = false
    local target_start_recipes = false
    local target_trigger_techs = false

    for _, child in pairs(main_flow.pack_grid.children) do
        if child.type == "checkbox" and child.state then
            local tags = child.tags
            local is_baseline = tags.row == "baseline"
            if tags.pack_name == "start_recipes" then
                if is_baseline then baseline_start_recipes = true else target_start_recipes = true end
            elseif tags.pack_name == "trigger_techs" then
                if is_baseline then baseline_trigger_techs = true else target_trigger_techs = true end
            elseif is_baseline then
                baseline_packs[tags.pack_name] = true
            else
                target_packs[tags.pack_name] = true
            end
        end
    end

    return baseline_packs, target_packs,
           baseline_start_recipes, baseline_trigger_techs,
           target_start_recipes, target_trigger_techs
end

local function get_target_tech_names(target_slots)
    local names = {}

    for _, row in pairs(target_slots.children) do
        for _, child in pairs(row.children) do
            if child.type == "choose-elem-button" and child.elem_value then
                names[#names + 1] = child.elem_value
            end
        end
    end

    return names
end

-- Returns a set of all transitive prerequisite tech names for the given tech.
local function compute_ancestors(tech_name)
    local ancestors = {}
    local stack = {}

    local tech = prototypes.technology[tech_name]
    if not tech then return ancestors end

    for prereq_name in pairs(tech.prerequisites) do
        stack[#stack + 1] = prereq_name
    end

    while #stack > 0 do
        local name = table.remove(stack)
        if not ancestors[name] then
            ancestors[name] = true
            local t = prototypes.technology[name]
            if t then
                for prereq_name in pairs(t.prerequisites) do
                    if not ancestors[prereq_name] then
                        stack[#stack + 1] = prereq_name
                    end
                end
            end
        end
    end

    return ancestors
end

-- Adds to `available` all techs that share a direct prerequisite with
-- the target tech or any of its ancestors (option B siblings).
local function add_siblings(available, tech_name, ancestors)
    local shared_prereqs = {}

    local target_tech = prototypes.technology[tech_name]
    if target_tech then
        for prereq_name in pairs(target_tech.prerequisites) do
            shared_prereqs[prereq_name] = true
        end
    end

    for ancestor_name in pairs(ancestors) do
        local t = prototypes.technology[ancestor_name]
        if t then
            for prereq_name in pairs(t.prerequisites) do
                shared_prereqs[prereq_name] = true
            end
        end
    end

    for tname, tech in pairs(prototypes.technology) do
        if not available[tname] then
            for prereq_name in pairs(tech.prerequisites) do
                if shared_prereqs[prereq_name] then
                    available[tname] = true
                    break
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << Content rendering >>
---------------------------------------------------------------------------------------------------

-- Content width is 900px. Fixed label width of 280px gives 3 even columns (3×280 = 840px)
-- without any label being able to stretch and distort the layout.
local LABEL_WIDTH = 280

local SLOT_GRID_COLUMNS = 20
local MAX_ENTITY_ICONS = 4

local function make_3col_table(content)
    return content.add {type = "table", column_count = 3}
end

local function get_item_sort_key(name)
    local proto = prototypes.item[name] or prototypes.fluid[name]
    if not proto then return "\xff" end
    return (proto.subgroup and proto.subgroup.order or "") .. "\x00" .. (proto.order or "")
end

local function get_recipe_sort_key(name)
    local recipe = prototypes.recipe[name]
    if not recipe then return "\xff" end
    return (recipe.subgroup and recipe.subgroup.order or "") .. "\x00" .. (recipe.order or "")
end

local function get_tech_sort_key(name)
    local tech = prototypes.technology[name]
    if not tech then return "\xff" end
    return tech.order or name
end

-- Renders a sorted list of item names as either a slot-button grid or a 3-column label list.
-- meta_table is item_meta or fluid_meta; tooltip_type is "item" or "fluid";
-- sprite_prefix is "item/" or "fluid/".
-- In list mode, entity icons (up to MAX_ENTITY_ICONS) and a "[scripted]" suffix are appended
-- where the metadata indicates them.
local function add_resource_display(container, names, sprite_prefix, tooltip_type, meta_table, rd)
    local sorted = Q.from(names)
        :order_by(rd.sort_mode == "inventory" and get_item_sort_key or function(name) return name end)
        :to_array()

    if rd.display_mode == "grid" then
        local tbl = container.add {type = "table", column_count = SLOT_GRID_COLUMNS, style = "sosciencity_slot_grid"}
        for _, name in pairs(sorted) do
            tbl.add {
                type = "sprite-button",
                sprite = sprite_prefix .. name,
                elem_tooltip = {type = tooltip_type, name = name},
                style = "slot_button"
            }
        end
    else
        local tbl = make_3col_table(container)
        for _, name in pairs(sorted) do
            local proto = (tooltip_type == "fluid" and prototypes.fluid[name])
                       or (tooltip_type == "technology" and prototypes.technology[name])
                       or prototypes.item[name]
            local caption = {
                "",
                string.format("[%s=%s] ", tooltip_type, name),
                proto and proto.localised_name or name,
            }
            local meta = meta_table and meta_table[name]
            if meta then
                if #meta.entities > 0 then
                    caption[#caption + 1] = "  "
                    local shown = math.min(#meta.entities, MAX_ENTITY_ICONS)
                    for i = 1, shown do
                        caption[#caption + 1] = string.format("[entity=%s]", meta.entities[i])
                    end
                    if #meta.entities > MAX_ENTITY_ICONS then
                        caption[#caption + 1] = string.format(" (+%d)", #meta.entities - MAX_ENTITY_ICONS)
                    end
                end
                if meta.scripted then
                    caption[#caption + 1] = " [scripted]"
                end
            end
            local label = tbl.add {
                type = "label",
                caption = caption,
                elem_tooltip = {type = tooltip_type, name = name},
                style = "sosciencity_paragraph"
            }
            label.style.width = LABEL_WIDTH
        end
    end
end

local function add_recipes_display(content, recipe_names, rd)
    local sorted = Q.from(recipe_names)
        :where(function(name) return prototypes.recipe[name] ~= nil end)
        :order_by(rd.sort_mode == "inventory" and get_recipe_sort_key or function(name) return name end)
        :to_array()

    if rd.display_mode == "grid" then
        local tbl = content.add {type = "table", column_count = SLOT_GRID_COLUMNS, style = "sosciencity_slot_grid"}
        for _, recipe_name in pairs(sorted) do
            tbl.add {
                type = "sprite-button",
                sprite = "recipe/" .. recipe_name,
                elem_tooltip = {type = "recipe", name = recipe_name},
                style = "slot_button"
            }
        end
    else
        local tbl = make_3col_table(content)
        for _, recipe_name in pairs(sorted) do
            local recipe = prototypes.recipe[recipe_name]
            local label = tbl.add {
                type = "label",
                caption = {"", string.format("[recipe=%s] ", recipe_name), recipe.localised_name},
                elem_tooltip = {type = "recipe", name = recipe_name},
                style = "sosciencity_paragraph"
            }
            label.style.width = LABEL_WIDTH
        end
    end
end

-- Renders the delta summary section (everything new in After vs Before).
local function add_summary_section(content, rd)
    local buildings = Q.from(rd.items_delta)
        :where(function(name)
            local proto = prototypes.item[name]
            return proto ~= nil and proto.place_result ~= nil
        end)
        :to_array()

    local plain_items = Q.from(rd.items_delta)
        :where(function(name)
            local proto = prototypes.item[name]
            return not (proto ~= nil and proto.place_result ~= nil)
        end)
        :to_array()

    if #rd.techs_delta == 0 and #rd.recipes_delta == 0 and
       #buildings == 0 and #plain_items == 0 and #rd.fluids_delta == 0 then
        return
    end

    local summary = Gui.Elements.CollapsibleSection.heading_1_compact(content, {"city-view.balancing-summary"})

    if #buildings > 0 then
        local section = Gui.Elements.CollapsibleSection.heading_2_compact(summary, {"city-view.balancing-summary-buildings"})
        add_resource_display(section, buildings, "item/", "item", rd.item_meta, rd)
    end

    if #plain_items > 0 then
        local section = Gui.Elements.CollapsibleSection.heading_2_compact(summary, {"city-view.balancing-summary-items"})
        add_resource_display(section, plain_items, "item/", "item", rd.item_meta, rd)
    end

    if #rd.fluids_delta > 0 then
        local section = Gui.Elements.CollapsibleSection.heading_2_compact(summary, {"city-view.balancing-summary-fluids"})
        add_resource_display(section, rd.fluids_delta, "fluid/", "fluid", rd.fluid_meta, rd)
    end

    if #rd.techs_delta > 0 then
        local section = Gui.Elements.CollapsibleSection.heading_2_compact(summary, {"city-view.balancing-summary-techs"})
        add_resource_display(section, rd.techs_delta, "technology/", "technology", nil, rd)
    end

    if #rd.recipes_delta > 0 then
        local section = Gui.Elements.CollapsibleSection.heading_2_compact(summary, {"city-view.balancing-recipes"})
        add_recipes_display(section, rd.recipes_delta, rd)
    end

    Gui.Elements.Utils.separator_line(content)
end

-- description is optional; shown as tooltip on the heading when provided (used for scripted techs).
local function add_tech_section(content, tech_name, rd, description)
    local tech = prototypes.technology[tech_name]
    if not tech then return end

    local recipes = Q.from(rd.tech_to_recipes[tech_name] or {})
        :where(function(recipe_name)
            local recipe = prototypes.recipe[recipe_name]
            return recipe ~= nil and not recipe.parameter
               and (not rd.sosciencity_only or is_sosciencity(recipe))
        end)
        :to_array()

    -- scripted_items is {[item_name]=condition}, so from() yields (condition, item_name).
    local scripted_items = Q.from(BalancingData.scripted_items)
        :where(function(condition, name)
            if condition ~= tech_name then return false end
            local proto = prototypes.item[name]
            return proto ~= nil and (not rd.sosciencity_only or is_sosciencity(proto))
        end)
        :select(function(_, name) return name end)
        :to_array()

    local scripted_fluids = Q.from(BalancingData.scripted_items)
        :where(function(condition, name)
            if condition ~= tech_name then return false end
            local proto = prototypes.fluid[name]
            return proto ~= nil and (not rd.sosciencity_only or is_sosciencity(proto))
        end)
        :select(function(_, name) return name end)
        :to_array()

    if #recipes == 0 and #scripted_items == 0 and #scripted_fluids == 0 then return end

    local caption = {"", string.format("[technology=%s] ", tech_name), tech.localised_name}
    for _, ingredient in pairs(tech.research_unit_ingredients) do
        caption[#caption + 1] = "  "
        caption[#caption + 1] = string.format("[item=%s]", ingredient.name)
    end

    local section_content = Gui.Elements.CollapsibleSection.heading_2_compact(content, caption, {
        collapsed = true,
        elem_tooltip = {type = "technology", name = tech_name},
        tooltip = description
    })

    if #recipes > 0 then
        add_recipes_display(section_content, recipes, rd)
    end

    if #scripted_items > 0 then
        add_resource_display(section_content, scripted_items, "item/", "item", rd.item_meta, rd)
    end

    if #scripted_fluids > 0 then
        add_resource_display(section_content, scripted_fluids, "fluid/", "fluid", rd.fluid_meta, rd)
    end
end

local function add_new_technologies_section(content, rd)
    if #rd.techs_delta == 0 then return end

    local outer_section = Gui.Elements.CollapsibleSection.heading_1_compact(content, {"city-view.balancing-delta-techs"})
    for _, tech_name in pairs(rd.techs_delta) do
        add_tech_section(outer_section, tech_name, rd)
    end
end

local function compute_tech_sets(main_flow)
    local baseline_packs, target_packs,
          baseline_start_recipes, baseline_trigger_techs,
          target_start_recipes, target_trigger_techs = get_selections(main_flow)
    local player_index = main_flow.player_index

    local available_baseline = compute_available_techs(baseline_packs, baseline_trigger_techs)
    local available_target   = compute_available_techs(target_packs,   target_trigger_techs)

    local include_siblings = main_flow.target_row.siblings_toggle.toggled
    local target_names = get_target_tech_names(Gui.get_element(CONTEXT, "target_slots", player_index))
    for _, target_name in pairs(target_names) do
        if prototypes.technology[target_name] then
            available_target[target_name] = true
            local ancestors = compute_ancestors(target_name)
            for name in pairs(ancestors) do available_target[name] = true end
            if include_siblings then add_siblings(available_target, target_name, ancestors) end
        end
    end

    return available_baseline, available_target, baseline_start_recipes, target_start_recipes
end

-- Builds the render-data table consumed by both the GUI render path and the markdown export.
local function compute_render_data(main_flow)
    local player_index = main_flow.player_index
    local display_mode = Gui.get_element(CONTEXT, "display_grid", player_index).toggled and "grid" or "list"
    local sort_mode = Gui.get_element(CONTEXT, "sort_inventory", player_index).toggled and "inventory" or "name"
    local sosciencity_only = Gui.get_element(CONTEXT, "mod_sosciencity", player_index).toggled

    local available_baseline, available_target,
          baseline_start_recipes, target_start_recipes = compute_tech_sets(main_flow)

    local tech_to_recipes, all_tech_recipes = build_tech_to_recipes()

    local recipes_baseline = compute_available_recipe_set(available_baseline, tech_to_recipes, all_tech_recipes, baseline_start_recipes)
    local recipes_target   = compute_available_recipe_set(available_target,   tech_to_recipes, all_tech_recipes, target_start_recipes)

    local items_baseline, fluids_baseline = collect_available_resources(available_baseline, recipes_baseline, sosciencity_only)
    local items_target, fluids_target, item_meta, fluid_meta = collect_available_resources(available_target, recipes_target, sosciencity_only)

    local techs_delta = Q.from_keyset(available_target)
        :where(function(name)
            local tech = prototypes.technology[name]
            return not available_baseline[name] and tech ~= nil and not tech.hidden
        end)
        :order()
        :to_array()

    local recipes_delta = Q.from_keyset(recipes_target)
        :where(function(name)
            local recipe = prototypes.recipe[name]
            return recipe ~= nil
               and (not sosciencity_only or is_sosciencity(recipe))
               and not recipes_baseline[name]
        end)
        :to_array()

    local items_delta  = Q.from_keyset(items_target)
        :where(function(n) return not items_baseline[n] end)
        :to_array()
    local fluids_delta = Q.from_keyset(fluids_target)
        :where(function(n) return not fluids_baseline[n] end)
        :to_array()

    return {
        display_mode     = display_mode,
        sort_mode        = sort_mode,
        sosciencity_only = sosciencity_only,
        tech_to_recipes  = tech_to_recipes,
        techs_delta      = techs_delta,
        recipes_delta    = recipes_delta,
        items_delta      = items_delta,
        fluids_delta     = fluids_delta,
        item_meta        = item_meta,
        fluid_meta       = fluid_meta,
    }
end

local function rebuild_content(main_flow)
    local content = main_flow.content
    content.clear()

    local rd = compute_render_data(main_flow)

    add_summary_section(content, rd)
    add_new_technologies_section(content, rd)

    if #content.children == 0 then
        Gui.Elements.Label.paragraph(content, {"city-view.balancing-nothing-available"})
    end
end

---------------------------------------------------------------------------------------------------
-- << Markdown export >>
---------------------------------------------------------------------------------------------------

-- Single fixed path so re-exports overwrite. Users who want to keep a snapshot can rename it.
local EXPORT_FILENAME = "sosciencity-progression.md"

local function describe_pack_selection(packs, start_recipes, trigger_techs)
    local pack_names = {}
    for name in pairs(packs) do pack_names[#pack_names + 1] = name end
    table.sort(pack_names)

    local parts = {}
    parts[#parts + 1] = #pack_names == 0 and "(no science packs)" or table.concat(pack_names, ", ")
    if start_recipes then parts[#parts + 1] = "+ start recipes" end
    if trigger_techs then parts[#parts + 1] = "+ trigger techs" end
    return table.concat(parts, ", ")
end

local function build_export_header_lines(main_flow)
    local baseline_packs, target_packs,
          baseline_start_recipes, baseline_trigger_techs,
          target_start_recipes, target_trigger_techs = get_selections(main_flow)

    local target_techs = get_target_tech_names(
        Gui.get_element(CONTEXT, "target_slots", main_flow.player_index)
    )
    local include_siblings = main_flow.target_row.siblings_toggle.toggled

    local mod_names = {}
    for name in pairs(script.active_mods) do mod_names[#mod_names + 1] = name end
    table.sort(mod_names)

    local lines = {
        "# Sosciencity Progression Export",
        "",
        "**Generated:** game tick " .. game.tick,
        "**Baseline:** " .. describe_pack_selection(baseline_packs, baseline_start_recipes, baseline_trigger_techs),
        "**Target:** " .. describe_pack_selection(target_packs, target_start_recipes, target_trigger_techs),
    }

    if #target_techs > 0 then
        lines[#lines + 1] = "**Target technologies:** " .. table.concat(target_techs, ", ") ..
            (include_siblings and " (+ siblings)" or "")
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "**Active mods:**"
    for _, name in pairs(mod_names) do
        lines[#lines + 1] = "- " .. name .. " " .. script.active_mods[name]
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Shows items, fluids, recipes and technologies reachable at Target but not Baseline."
    lines[#lines + 1] = "Regenerated from the live prototype graph - includes contributions from every active mod."
    lines[#lines + 1] = ""
    lines[#lines + 1] = "---"
    lines[#lines + 1] = ""

    return lines
end

local function build_resource_lines(names, meta_table)
    local sorted = Q.from(names):order_by(get_item_sort_key):to_array()
    local lines = {}
    for _, name in pairs(sorted) do
        local suffix = ""
        local meta = meta_table and meta_table[name]
        if meta then
            if #meta.entities > 0 then
                suffix = suffix .. " (from " .. table.concat(meta.entities, ", ") .. ")"
            end
            if meta.scripted then suffix = suffix .. " [scripted]" end
        end
        lines[#lines + 1] = "- `" .. name .. "`" .. suffix
    end
    return lines
end

local function build_recipe_lines(names)
    local sorted = Q.from(names)
        :where(function(name) return prototypes.recipe[name] ~= nil end)
        :order_by(get_recipe_sort_key)
        :to_array()
    local lines = {}
    for _, name in pairs(sorted) do
        lines[#lines + 1] = "- `" .. name .. "`"
    end
    return lines
end

local function build_tech_lines(names)
    local sorted = Q.from(names):order_by(get_tech_sort_key):to_array()
    local lines = {}
    for _, name in pairs(sorted) do
        local tech = prototypes.technology[name]
        local cost = ""
        if tech then
            local ingredients = {}
            for _, ing in pairs(tech.research_unit_ingredients) do
                ingredients[#ingredients + 1] = ing.name
            end
            if #ingredients > 0 then
                cost = " (cost: " .. table.concat(ingredients, ", ") .. ")"
            end
        end
        lines[#lines + 1] = "- `" .. name .. "`" .. cost
    end
    return lines
end

local function append_section(out, title, body_lines)
    if #body_lines == 0 then return end
    out[#out + 1] = string.format("### %s (%d)", title, #body_lines)
    out[#out + 1] = ""
    for _, line in pairs(body_lines) do out[#out + 1] = line end
    out[#out + 1] = ""
end

local function build_export_summary_lines(rd)
    local out = {}

    local buildings = Q.from(rd.items_delta)
        :where(function(name)
            local proto = prototypes.item[name]
            return proto ~= nil and proto.place_result ~= nil
        end)
        :to_array()
    local plain_items = Q.from(rd.items_delta)
        :where(function(name)
            local proto = prototypes.item[name]
            return not (proto ~= nil and proto.place_result ~= nil)
        end)
        :to_array()

    local total = #buildings + #plain_items + #rd.fluids_delta + #rd.techs_delta + #rd.recipes_delta
    if total == 0 then
        out[#out + 1] = "(Nothing new in Target compared to Baseline.)"
        return out
    end

    out[#out + 1] = "## Summary"
    out[#out + 1] = ""
    append_section(out, "New Buildings", build_resource_lines(buildings, rd.item_meta))
    append_section(out, "New Items", build_resource_lines(plain_items, rd.item_meta))
    append_section(out, "New Fluids", build_resource_lines(rd.fluids_delta, rd.fluid_meta))
    append_section(out, "New Technologies", build_tech_lines(rd.techs_delta))
    append_section(out, "New Recipes", build_recipe_lines(rd.recipes_delta))
    return out
end

local function build_export_tech_detail_lines(rd)
    local out = {}
    if #rd.techs_delta == 0 then return out end

    out[#out + 1] = "## New Technologies in Detail"
    out[#out + 1] = ""

    for _, tech_name in pairs(rd.techs_delta) do
        local tech = prototypes.technology[tech_name]
        if tech then
            local recipes = Q.from(rd.tech_to_recipes[tech_name] or {})
                :where(function(name)
                    local recipe = prototypes.recipe[name]
                    return recipe ~= nil and not recipe.parameter
                       and (not rd.sosciencity_only or is_sosciencity(recipe))
                end)
                :to_array()

            local scripted_items = Q.from(BalancingData.scripted_items)
                :where(function(condition, name)
                    if condition ~= tech_name then return false end
                    local proto = prototypes.item[name] or prototypes.fluid[name]
                    return proto ~= nil and (not rd.sosciencity_only or is_sosciencity(proto))
                end)
                :select(function(_, name) return name end)
                :to_array()

            if #recipes > 0 or #scripted_items > 0 then
                out[#out + 1] = "### `" .. tech_name .. "`"
                local ingredients = {}
                for _, ing in pairs(tech.research_unit_ingredients) do
                    ingredients[#ingredients + 1] = ing.name
                end
                if #ingredients > 0 then
                    out[#out + 1] = "**Cost:** " .. table.concat(ingredients, ", ")
                end
                if #recipes > 0 then
                    out[#out + 1] = "**Recipes:**"
                    for _, line in pairs(build_recipe_lines(recipes)) do out[#out + 1] = line end
                end
                if #scripted_items > 0 then
                    out[#out + 1] = "**Scripted items/fluids:**"
                    for _, line in pairs(build_resource_lines(scripted_items, nil)) do out[#out + 1] = line end
                end
                out[#out + 1] = ""
            end
        end
    end

    return out
end

local function export_current_view(main_flow)
    local rd = compute_render_data(main_flow)

    local lines = build_export_header_lines(main_flow)
    for _, l in pairs(build_export_summary_lines(rd)) do lines[#lines + 1] = l end
    for _, l in pairs(build_export_tech_detail_lines(rd)) do lines[#lines + 1] = l end

    helpers.write_file(EXPORT_FILENAME, table.concat(lines, "\n") .. "\n", false, main_flow.player_index)
    return EXPORT_FILENAME
end

---------------------------------------------------------------------------------------------------
-- << Full progression export (v2) >>
---------------------------------------------------------------------------------------------------

local PROGRESSION_DIR = "sosciencity-progression"

-- Strips "-science-pack" / "-pack" suffix for compact display + filenames.
local function strip_pack_suffix(name)
    if Tirislib.String.ends_with(name, "-science-pack") then
        return name:sub(1, #name - #"-science-pack")
    elseif Tirislib.String.ends_with(name, "-pack") then
        return name:sub(1, #name - #"-pack")
    end
    return name
end

local function sorted_pack_names(pack_set)
    local names = {}
    for n in pairs(pack_set) do names[#names + 1] = n end
    table.sort(names)
    return names
end

local function pack_set_key(pack_set)
    return table.concat(sorted_pack_names(pack_set), ",")
end

local function pack_set_subset(a, b)
    for k in pairs(a) do
        if not b[k] then return false end
    end
    return true
end

local function pack_set_equal(a, b)
    return pack_set_subset(a, b) and pack_set_subset(b, a)
end

local function pack_set_size(s)
    local n = 0
    for _ in pairs(s) do n = n + 1 end
    return n
end

local function format_pack_set(pack_set_sorted, separator)
    if #pack_set_sorted == 0 then return "(empty)" end
    local short = {}
    for _, n in pairs(pack_set_sorted) do short[#short + 1] = strip_pack_suffix(n) end
    return "{" .. table.concat(short, separator or ", ") .. "}"
end

-- Recursive memoized computation of min_packs for every tech (including hidden).
-- min_packs(T) = T.research_unit_ingredients ∪ ⋃ min_packs(prereq).
-- Trigger techs have empty research_unit_ingredients, so own_packs = ∅.
-- Hidden techs are still computed so visible descendants inherit their packs;
-- the lattice builder filters them out when collecting unique tier pack-sets.
local function compute_min_packs_per_tech()
    local memo = {}

    local function compute(tech_name, visiting)
        if memo[tech_name] ~= nil then return memo[tech_name] end
        local tech = prototypes.technology[tech_name]
        if not tech then
            memo[tech_name] = {}
            return memo[tech_name]
        end
        if visiting[tech_name] then return {} end
        visiting[tech_name] = true

        local result = {}
        for _, ing in pairs(tech.research_unit_ingredients) do
            result[ing.name] = true
        end
        for prereq in pairs(tech.prerequisites) do
            local p = compute(prereq, visiting)
            for k in pairs(p) do result[k] = true end
        end

        visiting[tech_name] = nil
        memo[tech_name] = result
        return result
    end

    for tech_name in pairs(prototypes.technology) do
        compute(tech_name, {})
    end

    return memo
end

-- Builds the lattice of unique pack-sets and ordered tier records.
-- Each tier record has: id, depth, pack_set, pack_set_sorted, key, marginal,
-- parents (array of tier records), filename.
local function build_lattice(min_packs_per_tech)
    local by_key = {}
    for tech_name, packs in pairs(min_packs_per_tech) do
        local tech = prototypes.technology[tech_name]
        if tech and not tech.hidden then
            local key = pack_set_key(packs)
            if not by_key[key] then
                by_key[key] = {pack_set = packs, key = key}
            end
        end
    end

    local tiers = {}
    for _, t in pairs(by_key) do tiers[#tiers + 1] = t end

    -- Sort by pack-set size first so subsets come before supersets.
    table.sort(tiers, function(a, b)
        local sa, sb = pack_set_size(a.pack_set), pack_set_size(b.pack_set)
        if sa ~= sb then return sa < sb end
        return a.key < b.key
    end)

    -- Compute depth + direct parents.
    for _, tier in pairs(tiers) do
        local proper_subsets = {}
        for _, other in pairs(tiers) do
            if other ~= tier
              and pack_set_subset(other.pack_set, tier.pack_set)
              and not pack_set_equal(other.pack_set, tier.pack_set) then
                proper_subsets[#proper_subsets + 1] = other
            end
        end

        local max_depth = -1
        for _, ps in pairs(proper_subsets) do
            if ps.depth > max_depth then max_depth = ps.depth end
        end
        tier.depth = max_depth + 1

        -- Direct parent = proper subset that is not a proper subset of any other proper subset.
        local direct = {}
        for i, ps in pairs(proper_subsets) do
            local is_direct = true
            for j, ps2 in pairs(proper_subsets) do
                if i ~= j
                  and pack_set_subset(ps.pack_set, ps2.pack_set)
                  and not pack_set_equal(ps.pack_set, ps2.pack_set) then
                    is_direct = false
                    break
                end
            end
            if is_direct then direct[#direct + 1] = ps end
        end
        tier.parents = direct
    end

    -- Resort by (depth, lex of key) and assign IDs.
    table.sort(tiers, function(a, b)
        if a.depth ~= b.depth then return a.depth < b.depth end
        return a.key < b.key
    end)

    for i, tier in pairs(tiers) do
        tier.id = i
        tier.pack_set_sorted = sorted_pack_names(tier.pack_set)
    end

    -- Compute marginal = pack-set - ⋃ parents.pack-sets.
    for _, tier in pairs(tiers) do
        local parents_union = {}
        for _, p in pairs(tier.parents) do
            for k in pairs(p.pack_set) do parents_union[k] = true end
        end
        tier.marginal = {}
        for k in pairs(tier.pack_set) do
            if not parents_union[k] then
                tier.marginal[#tier.marginal + 1] = k
            end
        end
        table.sort(tier.marginal)
    end

    -- Filename: tier-NNN-{marginal}.md, suffix omitted on reconvergence.
    for _, tier in pairs(tiers) do
        local id_str = string.format("%03d", tier.id)
        if #tier.marginal == 0 then
            tier.filename = string.format("tier-%s.md", id_str)
        else
            local short = {}
            for _, m in pairs(tier.marginal) do
                short[#short + 1] = strip_pack_suffix(m)
            end
            tier.filename = string.format("tier-%s-%s.md", id_str, table.concat(short, "-"))
        end
    end

    return tiers
end

-- For each tier: populate available_techs/recipes/items/fluids and ★ markers.
-- Reuses v1's collect_available_resources et al.
local function compute_per_tier_data(tiers, sosciencity_only)
    local tech_to_recipes, all_tech_recipes = build_tech_to_recipes()

    for _, tier in pairs(tiers) do
        tier.available_techs = compute_available_techs(tier.pack_set, true)
        tier.available_recipes = compute_available_recipe_set(
            tier.available_techs, tech_to_recipes, all_tech_recipes, true)
        tier.items, tier.fluids, tier.item_meta, tier.fluid_meta =
            collect_available_resources(tier.available_techs, tier.available_recipes, sosciencity_only)
    end

    for _, tier in pairs(tiers) do
        local pt, pr, pi, pf = {}, {}, {}, {}
        for _, p in pairs(tier.parents) do
            for k in pairs(p.available_techs) do pt[k] = true end
            for k in pairs(p.available_recipes) do pr[k] = true end
            for k in pairs(p.items) do pi[k] = true end
            for k in pairs(p.fluids) do pf[k] = true end
        end
        tier.new_techs, tier.new_recipes, tier.new_items, tier.new_fluids = {}, {}, {}, {}
        for k in pairs(tier.available_techs) do if not pt[k] then tier.new_techs[k] = true end end
        for k in pairs(tier.available_recipes) do if not pr[k] then tier.new_recipes[k] = true end end
        for k in pairs(tier.items) do if not pi[k] then tier.new_items[k] = true end end
        for k in pairs(tier.fluids) do if not pf[k] then tier.new_fluids[k] = true end end
    end

    for _, tier in pairs(tiers) do
        tier.visible_techs = {}
        tier.visible_new_techs = {}
        for n in pairs(tier.available_techs) do
            local tech = prototypes.technology[n]
            if tech and not tech.hidden then
                tier.visible_techs[n] = true
                if tier.new_techs[n] then tier.visible_new_techs[n] = true end
            end
        end
    end

    for _, tier in pairs(tiers) do
        tier.available_castes = {}
        tier.new_castes = {}
        for _, caste in pairs(Castes.values) do
            if caste.enabled and tier.available_techs[caste.tech_name] then
                tier.available_castes[caste.name] = true
                if tier.new_techs[caste.tech_name] then
                    tier.new_castes[caste.name] = true
                end
            end
        end
    end

    return tech_to_recipes
end

-- Build {item_name → [recipe_name, ...]} for fast recipe lookup in mode C.
local function build_item_to_recipes()
    local map = {}
    for recipe_name, recipe in pairs(prototypes.recipe) do
        if not recipe.parameter then
            for _, product in pairs(recipe.products) do
                if not map[product.name] then map[product.name] = {} end
                local list = map[product.name]
                local seen = false
                for _, n in pairs(list) do if n == recipe_name then seen = true break end end
                if not seen then list[#list + 1] = recipe_name end
            end
        end
    end
    return map
end

local function format_recipe_inline(recipe_name)
    local recipe = prototypes.recipe[recipe_name]
    if not recipe then return string.format("`%s`", recipe_name) end
    local ings = {}
    for _, ing in pairs(recipe.ingredients) do
        local sprite_type = ing.type == "fluid" and "fluid" or "item"
        ings[#ings + 1] = string.format("%d×[%s=%s]", ing.amount, sprite_type, ing.name)
    end
    local prods = {}
    for _, prod in pairs(recipe.products) do
        local sprite_type = prod.type == "fluid" and "fluid" or "item"
        local amt = prod.amount or ((prod.amount_min or 0) + (prod.amount_max or 0)) / 2
        if amt == 0 then amt = 1 end
        prods[#prods + 1] = string.format("%g×[%s=%s]", amt, sprite_type, prod.name)
    end
    local cat = recipe.category or "crafting"
    local time = recipe.energy or 0.5
    return string.format("[recipe=%s] %s → %s (%s, %ss)",
        recipe_name,
        #ings > 0 and table.concat(ings, " + ") or "(no ingredients)",
        #prods > 0 and table.concat(prods, " + ") or "(no products)",
        cat, time)
end

-- Sort an array of names by Factorio subgroup+order (matches v1's "inventory" sort).
local function sort_items_by_factorio_order(names)
    table.sort(names, function(a, b)
        local pa = prototypes.item[a] or prototypes.fluid[a]
        local pb = prototypes.item[b] or prototypes.fluid[b]
        local oa = pa and ((pa.subgroup and pa.subgroup.order or "") .. "\x00" .. (pa.order or "")) or a
        local ob = pb and ((pb.subgroup and pb.subgroup.order or "") .. "\x00" .. (pb.order or "")) or b
        return oa < ob
    end)
    return names
end

local function sort_recipes_by_factorio_order(names)
    table.sort(names, function(a, b)
        local ra, rb = prototypes.recipe[a], prototypes.recipe[b]
        local oa = ra and ((ra.subgroup and ra.subgroup.order or "") .. "\x00" .. (ra.order or "")) or a
        local ob = rb and ((rb.subgroup and rb.subgroup.order or "") .. "\x00" .. (rb.order or "")) or b
        return oa < ob
    end)
    return names
end

local function sort_techs_by_factorio_order(names)
    table.sort(names, function(a, b)
        local ta, tb = prototypes.technology[a], prototypes.technology[b]
        local oa = ta and (ta.order or a) or a
        local ob = tb and (tb.order or b) or b
        return oa < ob
    end)
    return names
end

-- Render an item line. mode = "compact" (A) or "detailed" (C).
local function render_item_line(name, is_new, item_meta, item_to_recipes, available_recipes, mode)
    local star = is_new and "★ " or ""
    local meta = item_meta and item_meta[name]

    local line = string.format("- %s[item=%s] `%s`", star, name, name)

    local trailing = {}
    if meta then
        if #meta.entities > 0 then
            local ents = {}
            for _, e in pairs(meta.entities) do ents[#ents + 1] = string.format("[entity=%s]", e) end
            trailing[#trailing + 1] = "from " .. table.concat(ents, " ")
        end
        if meta.scripted then trailing[#trailing + 1] = "[scripted]" end
    end
    if #trailing > 0 then
        line = line .. "  " .. table.concat(trailing, " ")
    end

    local lines = {line}

    if mode == "detailed" then
        local recipes = item_to_recipes[name] or {}
        local visible = {}
        for _, rn in pairs(recipes) do
            if available_recipes[rn] then visible[#visible + 1] = rn end
        end
        sort_recipes_by_factorio_order(visible)
        for _, rn in pairs(visible) do
            lines[#lines + 1] = "  - " .. format_recipe_inline(rn)
        end
    end

    return lines
end

local function render_fluid_line(name, is_new, fluid_meta, item_to_recipes, available_recipes, mode)
    local star = is_new and "★ " or ""
    local meta = fluid_meta and fluid_meta[name]

    local line = string.format("- %s[fluid=%s] `%s`", star, name, name)

    local trailing = {}
    if meta then
        if #meta.entities > 0 then
            local ents = {}
            for _, e in pairs(meta.entities) do ents[#ents + 1] = string.format("[entity=%s]", e) end
            trailing[#trailing + 1] = "from " .. table.concat(ents, " ")
        end
        if meta.scripted then trailing[#trailing + 1] = "[scripted]" end
    end
    if #trailing > 0 then
        line = line .. "  " .. table.concat(trailing, " ")
    end

    local lines = {line}

    if mode == "detailed" then
        local recipes = item_to_recipes[name] or {}
        local visible = {}
        for _, rn in pairs(recipes) do
            if available_recipes[rn] then visible[#visible + 1] = rn end
        end
        sort_recipes_by_factorio_order(visible)
        for _, rn in pairs(visible) do
            lines[#lines + 1] = "  - " .. format_recipe_inline(rn)
        end
    end

    return lines
end

local function render_tech_line(name, is_new)
    local tech = prototypes.technology[name]
    local star = is_new and "★ " or ""
    local cost_parts = {}
    if tech then
        for _, ing in pairs(tech.research_unit_ingredients) do
            cost_parts[#cost_parts + 1] = string.format("[item=%s]", ing.name)
        end
    end
    local cost_str = #cost_parts > 0 and ("  " .. table.concat(cost_parts, " ")) or ""
    return string.format("- %s[technology=%s] `%s`%s", star, name, name, cost_str)
end

local function pluralize_count(n, singular)
    return string.format("%d %s%s", n, singular, n == 1 and "" or "s")
end

local function tier_link(tier)
    return string.format("[tier-%03d](%s)", tier.id, tier.filename)
end

-- Build the markdown lines for a single tier file (cumulative).
local function build_tier_file_lines(tier, item_to_recipes, mode)
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    add(string.format("# Tier %03d - %s", tier.id, format_pack_set(tier.pack_set_sorted)))
    add("")
    add(string.format("**Depth:** %d", tier.depth))

    if #tier.parents > 0 then
        local parent_links = {}
        table.sort(tier.parents, function(a, b) return a.id < b.id end)
        for _, p in pairs(tier.parents) do parent_links[#parent_links + 1] = tier_link(p) end
        add(string.format("**Parents:** %s", table.concat(parent_links, ", ")))
    else
        add("**Parents:** (none - root tier)")
    end

    local nt = pack_set_size(tier.visible_new_techs)
    local nb, ni = 0, 0
    for n in pairs(tier.items) do
        local proto = prototypes.item[n]
        if proto and proto.place_result then
            if tier.new_items[n] then nb = nb + 1 end
        else
            if tier.new_items[n] then ni = ni + 1 end
        end
    end
    local nf = pack_set_size(tier.new_fluids)

    local total_techs = pack_set_size(tier.visible_techs)
    local total_buildings, total_items = 0, 0
    for n in pairs(tier.items) do
        local proto = prototypes.item[n]
        if proto and proto.place_result then total_buildings = total_buildings + 1
        else total_items = total_items + 1 end
    end
    local total_fluids = pack_set_size(tier.fluids)

    add(string.format("**Counts:** %s, %s, %s, %s (★ %d / %d / %d / %d new this tier)",
        pluralize_count(total_techs, "tech"),
        pluralize_count(total_buildings, "building"),
        pluralize_count(total_items, "item"),
        pluralize_count(total_fluids, "fluid"),
        nt, nb, ni, nf))

    local available = sorted_pack_names(tier.available_castes)
    local new = sorted_pack_names(tier.new_castes)
    add(string.format("**Castes available:** %s",
        #available > 0 and table.concat(available, ", ") or "(none)"))
    if #new > 0 then
        add(string.format("**New caste this tier:** %s", table.concat(new, ", ")))
    end

    add("")

    -- Technologies section
    add("## Technologies")
    add("")
    local tech_names = {}
    for n in pairs(tier.visible_techs) do tech_names[#tech_names + 1] = n end
    sort_techs_by_factorio_order(tech_names)
    if #tech_names == 0 then
        add("(none)")
    else
        for _, n in pairs(tech_names) do
            add(render_tech_line(n, tier.visible_new_techs[n] == true))
        end
    end
    add("")

    -- Buildings section
    add("## Buildings")
    add("")
    local building_names = {}
    for n in pairs(tier.items) do
        local proto = prototypes.item[n]
        if proto and proto.place_result then building_names[#building_names + 1] = n end
    end
    sort_items_by_factorio_order(building_names)
    if #building_names == 0 then
        add("(none)")
    else
        for _, n in pairs(building_names) do
            for _, l in pairs(render_item_line(n, tier.new_items[n] == true,
                tier.item_meta, item_to_recipes, tier.available_recipes, mode)) do add(l) end
        end
    end
    add("")

    -- Items section
    add("## Items")
    add("")
    local item_names = {}
    for n in pairs(tier.items) do
        local proto = prototypes.item[n]
        if not (proto and proto.place_result) then item_names[#item_names + 1] = n end
    end
    sort_items_by_factorio_order(item_names)
    if #item_names == 0 then
        add("(none)")
    else
        for _, n in pairs(item_names) do
            for _, l in pairs(render_item_line(n, tier.new_items[n] == true,
                tier.item_meta, item_to_recipes, tier.available_recipes, mode)) do add(l) end
        end
    end
    add("")

    -- Fluids section
    add("## Fluids")
    add("")
    local fluid_names = {}
    for n in pairs(tier.fluids) do fluid_names[#fluid_names + 1] = n end
    sort_items_by_factorio_order(fluid_names)
    if #fluid_names == 0 then
        add("(none)")
    else
        for _, n in pairs(fluid_names) do
            for _, l in pairs(render_fluid_line(n, tier.new_fluids[n] == true,
                tier.fluid_meta, item_to_recipes, tier.available_recipes, mode)) do add(l) end
        end
    end
    add("")

    return lines
end

local function build_index_lines(tiers, mode, sosciencity_only)
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    add("# Sosciencity Progression Snapshot")
    add("")
    add(string.format("**Generated:** game tick %d", game.tick))
    add(string.format("**Mode:** %s", mode == "detailed" and "Detailed (C)" or "Compact (A)"))
    if sosciencity_only then
        add("**Filter:** sosciencity prototypes only")
    end

    local mod_names = {}
    for n in pairs(script.active_mods) do mod_names[#mod_names + 1] = n end
    table.sort(mod_names)
    add("")
    add("**Active mods:**")
    for _, n in pairs(mod_names) do
        add(string.format("- %s %s", n, script.active_mods[n]))
    end

    add("")
    add("See [overview.md](overview.md) for the delta-per-tier walk in one file.")
    add("")
    add("## Tiers")
    add("")
    add("| # | Pack-set | Depth | Techs | Buildings | Items | Fluids | New here (T/B/I/F) |")
    add("|---|---|---|---|---|---|---|---|")

    for _, tier in pairs(tiers) do
        local total_techs = pack_set_size(tier.visible_techs)
        local total_buildings, total_items = 0, 0
        for n in pairs(tier.items) do
            local proto = prototypes.item[n]
            if proto and proto.place_result then total_buildings = total_buildings + 1
            else total_items = total_items + 1 end
        end
        local total_fluids = pack_set_size(tier.fluids)

        local nt = pack_set_size(tier.visible_new_techs)
        local nr_b, nr_i = 0, 0
        for n in pairs(tier.new_items) do
            local proto = prototypes.item[n]
            if proto and proto.place_result then nr_b = nr_b + 1
            else nr_i = nr_i + 1 end
        end
        local nr_f = pack_set_size(tier.new_fluids)

        add(string.format("| [%03d](%s) | %s | %d | %d | %d | %d | %d | %d/%d/%d/%d |",
            tier.id, tier.filename,
            format_pack_set(tier.pack_set_sorted),
            tier.depth, total_techs, total_buildings, total_items, total_fluids,
            nt, nr_b, nr_i, nr_f))
    end

    add("")
    return lines
end

local function build_overview_lines(tiers)
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    add("# Progression Overview")
    add("")
    add("Delta per tier - shows only what is new at each tier. See [index.md](index.md) for cumulative views per tier.")
    add("")

    for _, tier in pairs(tiers) do
        add(string.format("## Tier %03d - %s", tier.id, format_pack_set(tier.pack_set_sorted)))
        add("")
        add(string.format("**Depth:** %d  **File:** [%s](%s)", tier.depth, tier.filename, tier.filename))

        local new_castes = sorted_pack_names(tier.new_castes)
        if #new_castes > 0 then
            add(string.format("**New caste this tier:** %s", table.concat(new_castes, ", ")))
        end
        add("")

        local new_techs = {}
        for n in pairs(tier.visible_new_techs) do new_techs[#new_techs + 1] = n end
        sort_techs_by_factorio_order(new_techs)
        if #new_techs > 0 then
            local items = {}
            for _, n in pairs(new_techs) do
                items[#items + 1] = string.format("[technology=%s] `%s`", n, n)
            end
            add(string.format("**New techs (%d):** %s", #new_techs, table.concat(items, ", ")))
        end

        local new_buildings, new_items = {}, {}
        for n in pairs(tier.new_items) do
            local proto = prototypes.item[n]
            if proto and proto.place_result then new_buildings[#new_buildings + 1] = n
            else new_items[#new_items + 1] = n end
        end
        sort_items_by_factorio_order(new_buildings)
        sort_items_by_factorio_order(new_items)

        if #new_buildings > 0 then
            local b = {}
            for _, n in pairs(new_buildings) do b[#b + 1] = string.format("[item=%s] `%s`", n, n) end
            add(string.format("**New buildings (%d):** %s", #new_buildings, table.concat(b, ", ")))
        end
        if #new_items > 0 then
            local b = {}
            for _, n in pairs(new_items) do b[#b + 1] = string.format("[item=%s] `%s`", n, n) end
            add(string.format("**New items (%d):** %s", #new_items, table.concat(b, ", ")))
        end

        local new_fluids = {}
        for n in pairs(tier.new_fluids) do new_fluids[#new_fluids + 1] = n end
        sort_items_by_factorio_order(new_fluids)
        if #new_fluids > 0 then
            local b = {}
            for _, n in pairs(new_fluids) do b[#b + 1] = string.format("[fluid=%s] `%s`", n, n) end
            add(string.format("**New fluids (%d):** %s", #new_fluids, table.concat(b, ", ")))
        end

        add("")
    end

    return lines
end

local function export_full_progression(main_flow, mode)
    local player_index = main_flow.player_index
    local sosciencity_only = Gui.get_element(CONTEXT, "mod_sosciencity", player_index).toggled

    local min_packs = compute_min_packs_per_tech()
    local tiers = build_lattice(min_packs)
    compute_per_tier_data(tiers, sosciencity_only)
    local item_to_recipes = build_item_to_recipes()

    local function write(rel, lines)
        helpers.write_file(PROGRESSION_DIR .. "/" .. rel,
            table.concat(lines, "\n") .. "\n", false, player_index)
    end

    write("index.md", build_index_lines(tiers, mode, sosciencity_only))
    write("overview.md", build_overview_lines(tiers))

    for _, tier in pairs(tiers) do
        write(tier.filename, build_tier_file_lines(tier, item_to_recipes, mode))
    end

    return PROGRESSION_DIR, #tiers + 2
end

---------------------------------------------------------------------------------------------------
-- << Target tech helpers >>
---------------------------------------------------------------------------------------------------

local function add_target_slot(target_slots)
    local tags = target_slots.tags
    local slot_id = tags.next_id
    tags.next_id = slot_id + 1
    target_slots.tags = tags

    local row = target_slots.add {
        type = "flow",
        direction = "horizontal",
        tags = {slot_id = slot_id}
    }
    row.style.vertical_align = "center"

    row.add {
        type = "choose-elem-button",
        elem_type = "technology",
        tags = {
            sosciencity_gui_event = "balancing_target_tech_changed",
            slot_id = slot_id
        }
    }

    row.add {
        type = "button",
        caption = "×",
        style = "close_button",
        tooltip = {"city-view.balancing-remove-target"},
        tags = {
            sosciencity_gui_event = "balancing_target_tech_remove",
            slot_id = slot_id
        }
    }
end

---------------------------------------------------------------------------------------------------
-- << Sync helpers >>
---------------------------------------------------------------------------------------------------

local function sync_packs(main_flow, from_row, to_row)
    local from_states = {}
    local to_checkboxes = {}

    for _, child in pairs(main_flow.pack_grid.children) do
        if child.type == "checkbox" then
            local tags = child.tags
            if tags.row == from_row then
                from_states[tags.pack_name] = child.state
            elseif tags.row == to_row then
                to_checkboxes[tags.pack_name] = child
            end
        end
    end

    for pack_name, checkbox in pairs(to_checkboxes) do
        checkbox.state = from_states[pack_name] or false
    end
end

---------------------------------------------------------------------------------------------------
-- << Event handlers >>
---------------------------------------------------------------------------------------------------

local function get_main_flow(event)
    return Gui.get_element(CONTEXT, MAIN_FLOW_KEY, event.player_index)
end

Gui.set_checked_state_handler(
    "balancing_pack_filter",
    function(event)
        rebuild_content(get_main_flow(event))
    end
)

Gui.set_click_handler(
    "balancing_display_radio",
    function(event)
        local button = event.element
        button.toggled = true
        button.parent[button.tags.sibling].toggled = false
        rebuild_content(get_main_flow(event))
    end
)

Gui.set_click_handler(
    "balancing_check_all_baseline",
    function(event)
        local main_flow = get_main_flow(event)
        for _, child in pairs(main_flow.pack_grid.children) do
            if child.type == "checkbox" and child.tags.row == "baseline" then
                child.state = true
            end
        end
        rebuild_content(main_flow)
    end
)

Gui.set_click_handler(
    "balancing_check_all_target",
    function(event)
        local main_flow = get_main_flow(event)
        for _, child in pairs(main_flow.pack_grid.children) do
            if child.type == "checkbox" and child.tags.row == "target" then
                child.state = true
            end
        end
        rebuild_content(main_flow)
    end
)

Gui.set_click_handler(
    "balancing_sync_to_baseline",
    function(event)
        local main_flow = get_main_flow(event)
        sync_packs(main_flow, "target", "baseline")
        rebuild_content(main_flow)
    end
)

Gui.set_click_handler(
    "balancing_sync_to_target",
    function(event)
        local main_flow = get_main_flow(event)
        sync_packs(main_flow, "baseline", "target")
        rebuild_content(main_flow)
    end
)

Gui.set_click_handler(
    "balancing_target_tech_add",
    function(event)
        local target_slots = Gui.get_element(CONTEXT, "target_slots", event.player_index)
        add_target_slot(target_slots)
        rebuild_content(get_main_flow(event))
    end
)

Gui.set_click_handler(
    "balancing_target_tech_remove",
    function(event)
        local slot_id = event.element.tags.slot_id
        local target_slots = Gui.get_element(CONTEXT, "target_slots", event.player_index)
        for _, child in pairs(target_slots.children) do
            if child.tags.slot_id == slot_id then
                child.destroy()
                break
            end
        end
        rebuild_content(get_main_flow(event))
    end
)

Gui.set_elem_changed_handler(
    "balancing_target_tech_changed",
    function(event)
        rebuild_content(get_main_flow(event))
    end
)

Gui.set_click_handler(
    "balancing_target_siblings_toggle",
    function(event)
        local button = event.element
        button.toggled = not button.toggled
        rebuild_content(get_main_flow(event))
    end
)

Gui.set_click_handler(
    "balancing_export_view",
    function(event)
        local main_flow = get_main_flow(event)
        local filename = export_current_view(main_flow)
        game.players[event.player_index].print({"city-view.balancing-export-done", filename})
    end
)

Gui.set_click_handler(
    "balancing_export_progression",
    function(event)
        local main_flow = get_main_flow(event)
        local mode = event.element.tags.mode
        local dir, file_count = export_full_progression(main_flow, mode)
        game.players[event.player_index].print({"city-view.balancing-export-progression-done", file_count, dir})
    end
)

Gui.set_click_handler(
    "balancing_apply_target",
    function(event)
        local main_flow = get_main_flow(event)
        local available_baseline, available_target = compute_tech_sets(main_flow)
        local player = game.players[event.player_index]
        local techs = player.force.technologies
        local count = 0
        for name in pairs(available_target) do
            if not available_baseline[name] then
                local tech = techs[name]
                if tech and not tech.researched then
                    tech.researched = true
                    count = count + 1
                end
            end
        end
        if count > 0 then
            player.print({"city-view.balancing-apply-target-done", count})
        else
            player.print({"city-view.balancing-apply-target-noop"})
        end
    end
)

---------------------------------------------------------------------------------------------------
-- << Page registration >>
---------------------------------------------------------------------------------------------------

local function add_radio_row(parent, row_name, label_key, opt1_name, opt1_key, opt2_name, opt2_key, default_first)
    local row = parent.add {type = "flow", name = row_name, direction = "horizontal"}
    row.style.vertical_align = "center"
    row.add {type = "label", caption = {label_key}}
    row.add {
        type = "button",
        name = opt1_name,
        caption = {opt1_key},
        toggled = default_first,
        tags = {sosciencity_gui_event = "balancing_display_radio", sibling = opt2_name}
    }
    row.add {
        type = "button",
        name = opt2_name,
        caption = {opt2_key},
        toggled = not default_first,
        tags = {sosciencity_gui_event = "balancing_display_radio", sibling = opt1_name}
    }
    return row
end

Gui.CityView.add_page {
    name = "balancing-progression",
    category = "debug",
    localised_name = {"city-view.balancing-progression"},
    creator = function(container)
        local main_flow = container.add {
            type = "flow",
            name = "main_flow",
            direction = "vertical"
        }
        Gui.register_element(main_flow, CONTEXT, MAIN_FLOW_KEY, container.player_index)

        -- Controls bar
        local controls = main_flow.add {
            type = "flow",
            name = "controls",
            direction = "horizontal"
        }
        controls.style.vertical_align = "center"

        controls.add {
            type = "button",
            caption = {"city-view.balancing-check-all-baseline"},
            tags = {sosciencity_gui_event = "balancing_check_all_baseline"}
        }

        controls.add {
            type = "button",
            caption = {"city-view.balancing-check-all-target"},
            tags = {sosciencity_gui_event = "balancing_check_all_target"}
        }

        controls.add {
            type = "button",
            caption = {"city-view.balancing-sync-to-baseline"},
            tooltip = {"", {"city-view.balancing-target"}, " → ", {"city-view.balancing-baseline"}},
            tags = {sosciencity_gui_event = "balancing_sync_to_baseline"}
        }

        controls.add {
            type = "button",
            caption = {"city-view.balancing-sync-to-target"},
            tooltip = {"", {"city-view.balancing-baseline"}, " → ", {"city-view.balancing-target"}},
            tags = {sosciencity_gui_event = "balancing_sync_to_target"}
        }

        controls.add {type = "line", direction = "vertical"}
        controls.add {
            type = "button",
            caption = {"city-view.balancing-export"},
            tooltip = {"city-view.balancing-export-tooltip"},
            tags = {sosciencity_gui_event = "balancing_export_view"}
        }
        controls.add {
            type = "button",
            caption = {"city-view.balancing-export-progression-compact"},
            tooltip = {"city-view.balancing-export-progression-compact-tooltip"},
            tags = {sosciencity_gui_event = "balancing_export_progression", mode = "compact"}
        }
        controls.add {
            type = "button",
            caption = {"city-view.balancing-export-progression-detailed"},
            tooltip = {"city-view.balancing-export-progression-detailed-tooltip"},
            tags = {sosciencity_gui_event = "balancing_export_progression", mode = "detailed"}
        }
        controls.add {
            type = "button",
            style = "red_button",
            caption = {"city-view.balancing-apply-target"},
            tooltip = {"city-view.balancing-apply-target-tooltip"},
            tags = {sosciencity_gui_event = "balancing_apply_target"}
        }

        -- Pack selection grid:
        --   column 0: row label ("Baseline" / "Target")
        --   column 1: start-recipes checkbox [item=iron-plate]
        --   column 2: trigger-techs checkbox [item=lab]
        --   columns 3+: one checkbox per science pack, aligned between rows
        local packs = get_all_science_packs()
        local pack_grid = main_flow.add {
            type = "table",
            name = "pack_grid",
            column_count = 3 + #packs
        }
        pack_grid.style.top_padding = 4
        pack_grid.style.vertical_align = "center"

        -- Baseline row (all unchecked — empty baseline = show everything in target)
        pack_grid.add {type = "label", caption = {"city-view.balancing-baseline"}}
        pack_grid.add {
            type = "checkbox",
            state = false,
            caption = "[item=iron-plate]",
            tooltip = {"city-view.balancing-start-recipes-tip"},
            tags = {sosciencity_gui_event = "balancing_pack_filter", pack_name = "start_recipes", row = "baseline"}
        }
        pack_grid.add {
            type = "checkbox",
            state = false,
            caption = "[item=lab]",
            tooltip = {"city-view.balancing-trigger-techs-tip"},
            tags = {sosciencity_gui_event = "balancing_pack_filter", pack_name = "trigger_techs", row = "baseline"}
        }
        for _, pack_name in pairs(packs) do
            pack_grid.add {
                type = "checkbox",
                state = false,
                caption = string.format("[item=%s]", pack_name),
                tooltip = prototypes.item[pack_name] and prototypes.item[pack_name].localised_name or pack_name,
                tags = {sosciencity_gui_event = "balancing_pack_filter", pack_name = pack_name, row = "baseline"}
            }
        end

        -- Target row (start recipes + trigger techs checked by default = game start)
        pack_grid.add {type = "label", caption = {"city-view.balancing-target"}}
        pack_grid.add {
            type = "checkbox",
            state = true,
            caption = "[item=iron-plate]",
            tooltip = {"city-view.balancing-start-recipes-tip"},
            tags = {sosciencity_gui_event = "balancing_pack_filter", pack_name = "start_recipes", row = "target"}
        }
        pack_grid.add {
            type = "checkbox",
            state = true,
            caption = "[item=lab]",
            tooltip = {"city-view.balancing-trigger-techs-tip"},
            tags = {sosciencity_gui_event = "balancing_pack_filter", pack_name = "trigger_techs", row = "target"}
        }
        for _, pack_name in pairs(packs) do
            pack_grid.add {
                type = "checkbox",
                state = false,
                caption = string.format("[item=%s]", pack_name),
                tooltip = prototypes.item[pack_name] and prototypes.item[pack_name].localised_name or pack_name,
                tags = {sosciencity_gui_event = "balancing_pack_filter", pack_name = pack_name, row = "target"}
            }
        end

        -- Target technology row
        local target_row = main_flow.add {
            type = "flow",
            name = "target_row",
            direction = "horizontal"
        }
        target_row.style.vertical_align = "center"
        target_row.style.top_padding = 4

        target_row.add {
            type = "label",
            caption = {"city-view.balancing-target-techs"}
        }

        local target_slots = target_row.add {
            type = "flow",
            name = "target_slots",
            direction = "horizontal"
        }
        target_slots.style.vertical_align = "center"
        target_slots.tags = {next_id = 1}
        Gui.register_element(target_slots, CONTEXT, "target_slots", container.player_index)

        target_row.add {
            type = "button",
            caption = "+",
            tooltip = {"city-view.balancing-add-target"},
            tags = {sosciencity_gui_event = "balancing_target_tech_add"}
        }

        target_row.add {
            type = "button",
            name = "siblings_toggle",
            caption = {"city-view.balancing-include-siblings"},
            tooltip = {"city-view.balancing-include-siblings-tooltip"},
            toggled = false,
            tags = {sosciencity_gui_event = "balancing_target_siblings_toggle"}
        }

        -- Display settings panel
        local ds = Gui.Elements.CollapsibleSection.heading_3_compact(
            main_flow,
            {"city-view.balancing-display-settings"},
            {collapsed = true}
        )
        ds.parent.style.top_padding = 4

        local display_row = add_radio_row(ds, "display_row", "city-view.balancing-display-label",
            "display_grid", "city-view.balancing-display-grid",
            "display_list", "city-view.balancing-display-list",
            true)
        Gui.register_element(display_row.display_grid, CONTEXT, "display_grid", container.player_index)

        local sort_row = add_radio_row(ds, "sort_row", "city-view.balancing-sort-label",
            "sort_name", "city-view.balancing-sort-name",
            "sort_inventory", "city-view.balancing-sort-inventory",
            true)
        Gui.register_element(sort_row.sort_inventory, CONTEXT, "sort_inventory", container.player_index)

        local mod_row = add_radio_row(ds, "mod_row", "city-view.balancing-mod-label",
            "mod_all", "city-view.balancing-all-mods",
            "mod_sosciencity", "city-view.balancing-sosciencity-only",
            true)
        Gui.register_element(mod_row.mod_sosciencity, CONTEXT, "mod_sosciencity", container.player_index)

        Gui.Elements.Utils.separator_line(main_flow)

        main_flow.add {
            type = "flow",
            name = "content",
            direction = "vertical"
        }

        rebuild_content(main_flow)
    end
}
