--- Balancing category for the CityView.
--- Only loaded when BALANCING is true (sosciencity-balancing companion mod present).

Gui.CityView.add_category("balancing", {"city-view.balancing"})

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

local function rebuild_content(main_flow)
    local content = main_flow.content
    content.clear()

    local baseline_packs, target_packs,
          baseline_start_recipes, baseline_trigger_techs,
          target_start_recipes, target_trigger_techs = get_selections(main_flow)
    local player_index = main_flow.player_index
    local display_mode = Gui.get_element(CONTEXT, "display_grid", player_index).toggled and "grid" or "list"
    local sort_mode = Gui.get_element(CONTEXT, "sort_inventory", player_index).toggled and "inventory" or "name"
    local sosciencity_only = Gui.get_element(CONTEXT, "mod_sosciencity", player_index).toggled

    local available_baseline = compute_available_techs(baseline_packs, baseline_trigger_techs)
    local available_target   = compute_available_techs(target_packs,   target_trigger_techs)

    -- Expand available_target with target tech ancestors (and optionally siblings).
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

    local rd = {
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

    add_summary_section(content, rd)
    add_new_technologies_section(content, rd)

    if #content.children == 0 then
        Gui.Elements.Label.paragraph(content, {"city-view.balancing-nothing-available"})
    end
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
    category = "balancing",
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
