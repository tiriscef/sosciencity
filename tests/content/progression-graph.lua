--- Data-stage model of what a player can obtain, for the progression checks in tests/content.
---
--- Everything is expressed as rules "these facts give those facts". Facts are strings:
--- "item:<name>", "fluid:<name>", "entity:<name>" (placeable), "crafting:<category>" (a machine for it,
--- with "[<n> in, <m> out]" appended when the recipe needs fluid boxes),
--- "mining:<resource category>", "fluid-mining:<resource category>", "mining-with-fluid", "rocket-launch",
--- "technology:<name>" (researched), "working:<entity>" (placed and staffed with its workforce),
--- "food-supply", "water-supply", "housing:<caste>" (a liveable house for the caste) and "inhabitants:<caste>".
--- People are facts too, so that loops through them (eggs -> inhabitants -> eggs) need a way in like any other,
--- and so do buildings that need workers of a caste.
--- A state starts from the rules that don't depend on research and gets recipe rules added for the
--- recipes that a set of technologies unlocks. Adding rules keeps everything derived so far,
--- so a check can derive the state of a technology's prerequisites first and add the technology's
--- own recipes afterwards.

local Building = require("constants.buildings")
local Castes = require("constants.castes")
local DrinkingWater = require("constants.drinking-water")
local Food = require("constants.food")
local Housing = require("constants.housing")
local InhabitantsConstants = require("constants.inhabitants")
local ScriptedProducts = require("constants.scripted-products")
local Unlocks = require("constants.unlocks")

local get_keyset = Tirislib.Tables.get_keyset
local get_subtbl = Tirislib.Tables.get_subtbl
local merge = Tirislib.Tables.merge

local ProgressionGraph = {}

---------------------------------------------------------------------------------------------------
-- << helpers >>

--- The keys of the set as a sorted array.
local function sorted_keys(set)
    local keys = get_keyset(set)
    table.sort(keys)
    return keys
end

local function iterate_prototypes(base_type, fn)
    for type_name in pairs(defines.prototypes[base_type]) do
        for _, prototype in pairs(data.raw[type_name] or {}) do
            fn(prototype)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << facts >>

local function fact_of(product)
    return (product.type == "fluid" and "fluid:" or "item:") .. product.name
end

--- Facts of an array of ingredients or products.
local function facts_of(products)
    local facts = {}
    for _, product in pairs(products or {}) do
        facts[#facts + 1] = fact_of(product)
    end
    return facts
end

--- Facts of the products of a MinableProperties table.
local function minable_products(minable)
    if not minable then
        return {}
    end
    if minable.results then
        return facts_of(minable.results)
    end
    if minable.result then
        return {"item:" .. minable.result}
    end
    return {}
end

--- The fact for a machine that crafts the category and has at least the given numbers of fluid boxes.
local function crafting_fact(category, fluid_inputs, fluid_outputs)
    if fluid_inputs == 0 and fluid_outputs == 0 then
        return "crafting:" .. category
    end
    return string.format("crafting:%s[%d in, %d out]", category, fluid_inputs, fluid_outputs)
end

--- The fact for having inhabitants of the caste.
--- @param caste_type Type
function ProgressionGraph.inhabitants_fact(caste_type)
    return "inhabitants:" .. Castes.values[caste_type].name
end
local inhabitants_fact = ProgressionGraph.inhabitants_fact

--- The fact for a liveable house that inhabitants of the caste can move into.
--- @param caste_type Type
function ProgressionGraph.housing_fact(caste_type)
    return "housing:" .. Castes.values[caste_type].name
end
local housing_fact = ProgressionGraph.housing_fact

--- The fact for a placed building that does its work: with its full workforce, if it needs one.
function ProgressionGraph.working_fact(entity_name)
    return "working:" .. entity_name
end
local working_fact = ProgressionGraph.working_fact

---------------------------------------------------------------------------------------------------
-- << recipes and machines >>

local function get_recipe_categories(recipe)
    if recipe.categories then
        return recipe.categories
    end
    return {recipe.category or "crafting"}
end

local function count_fluids(products)
    local count = 0
    for _, product in pairs(products or {}) do
        if product.type == "fluid" then
            count = count + 1
        end
    end
    return count
end

--- The crafting facts of which the recipe needs one: one per category, with its fluid box needs.
local function get_crafting_requirements(recipe)
    local fluid_inputs = count_fluids(recipe.ingredients)
    local fluid_outputs = count_fluids(recipe.results)
    local facts = {}
    for _, category in pairs(get_recipe_categories(recipe)) do
        facts[#facts + 1] = crafting_fact(category, fluid_inputs, fluid_outputs)
    end
    return facts
end

--- The number of input and of output fluid boxes of the machine.
local function count_fluid_boxes(entity)
    local inputs = 0
    local outputs = 0
    for _, fluid_box in pairs(entity.fluid_boxes or {}) do
        if fluid_box.production_type == "input" or fluid_box.production_type == "input-output" then
            inputs = inputs + 1
        elseif fluid_box.production_type == "output" then
            outputs = outputs + 1
        end
    end
    return inputs, outputs
end

--- The crafting facts a machine provides: every category with every fluid box count up to its own.
local function get_crafting_capabilities(entity)
    local fluid_inputs, fluid_outputs = count_fluid_boxes(entity)
    local facts = {}
    for _, category in pairs(entity.crafting_categories) do
        for inputs = 0, fluid_inputs do
            for outputs = 0, fluid_outputs do
                facts[#facts + 1] = crafting_fact(category, inputs, outputs)
            end
        end
    end
    return facts
end

--- The ingredients of the recipe as facts, and the module a building's script needs for it.
function ProgressionGraph.recipe_requirements(recipe)
    local facts = facts_of(recipe.ingredients)
    local required_module = ScriptedProducts.required_modules[recipe.name]
    if required_module then
        facts[#facts + 1] = "item:" .. required_module
    end
    return facts
end

function ProgressionGraph.recipe_products(recipe)
    return facts_of(recipe.results)
end

--- Whether the prototype belongs to the sosciencity-debug test setup (see datastage-scripts/test-prototype-group.lua).
--- Test recipes are enabled from the start and some make real items, so they would hide real problems.
function ProgressionGraph.is_test_prototype(name)
    return name:sub(1, 5) == "test-"
end

--- Recipes that the game or other mods generate for every item or fluid, not meant as a step of progression.
local generated_subgroups = {
    ["fill-barrel"] = true,
    ["empty-barrel"] = true
}

function ProgressionGraph.is_generated_recipe(recipe)
    if generated_subgroups[recipe.subgroup] then
        return true
    end
    for _, category in pairs(get_recipe_categories(recipe)) do
        if category == "recycling" then
            return true
        end
    end
    return false
end

--- Whether the recipe is available without any research.
function ProgressionGraph.is_start_recipe(recipe)
    return recipe.enabled ~= false and not recipe.parameter
end

---------------------------------------------------------------------------------------------------
-- << technologies >>

--- Whether a player can research the technology at some point. Gated technologies start disabled
--- and get enabled by script once their conditions are met.
function ProgressionGraph.is_researchable(technology)
    if technology.hidden then
        return false
    end
    return technology.enabled ~= false or Unlocks.gated_technologies[technology.name] ~= nil
end

--- The names of all recipes the technology unlocks.
function ProgressionGraph.get_unlocked_recipes(technology)
    local recipes = {}
    for _, effect in pairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" then
            recipes[#recipes + 1] = effect.recipe
        end
    end
    return recipes
end

--- The science packs a technology needs, as facts.
function ProgressionGraph.get_research_requirements(technology)
    local facts = {}
    for _, ingredient in pairs(technology.unit and technology.unit.ingredients or {}) do
        facts[#facts + 1] = "item:" .. (ingredient.name or ingredient[1])
    end
    return facts
end

local function name_of(prototype_or_name)
    return type(prototype_or_name) == "table" and prototype_or_name.name or prototype_or_name
end

--- What the research trigger of the technology needs, as a fact.
--- Nil if it has no trigger or the trigger type isn't modelled.
function ProgressionGraph.get_trigger_requirement(technology)
    local trigger = technology.research_trigger
    if not trigger then
        return nil
    end
    if trigger.type == "craft-item" then
        return "item:" .. name_of(trigger.item)
    elseif trigger.type == "craft-fluid" then
        return "fluid:" .. trigger.fluid
    elseif trigger.type == "build-entity" then
        return "entity:" .. name_of(trigger.entity)
    end
end

local ancestor_cache = {}

--- All transitive prerequisites of the technology as a set, without the technology itself.
function ProgressionGraph.get_ancestors(technology_name)
    local cached = ancestor_cache[technology_name]
    if cached then
        return cached
    end

    local ancestors = {}
    ancestor_cache[technology_name] = ancestors -- guards against cycles in the tech tree

    local technology = data.raw.technology[technology_name]
    for _, prerequisite in pairs(technology and technology.prerequisites or {}) do
        ancestors[prerequisite] = true
        for name in pairs(ProgressionGraph.get_ancestors(prerequisite)) do
            ancestors[name] = true
        end
    end

    return ancestors
end

local function get_pack_set(technology)
    return Tirislib.Tables.to_lookup(ProgressionGraph.get_research_requirements(technology))
end

--- The science packs of the technology and all its prerequisites, as a set of facts.
--- Trigger technologies have no packs of their own and land in the tier of their prerequisites.
function ProgressionGraph.get_tier_packs(technology_name)
    local packs = get_pack_set(data.raw.technology[technology_name])
    for ancestor in pairs(ProgressionGraph.get_ancestors(technology_name)) do
        for pack in pairs(get_pack_set(data.raw.technology[ancestor])) do
            packs[pack] = true
        end
    end
    return packs
end

local function needs_only_packs(technology, packs)
    for pack in pairs(get_pack_set(technology)) do
        if not packs[pack] then
            return false
        end
    end
    return true
end

local function has_prerequisites(technology, researched)
    for _, prerequisite in pairs(technology.prerequisites or {}) do
        if not researched[prerequisite] then
            return false
        end
    end
    return true
end

--- Researches whatever becomes researchable with the packs, until nothing new does.
--- @param packs table<string, boolean> set of pack facts
--- @return table<string, boolean>
local function research_everything_with(packs)
    local researched = {}
    local changed = true
    while changed do
        changed = false
        for name, technology in pairs(data.raw.technology) do
            if not researched[name]
                and ProgressionGraph.is_researchable(technology)
                and needs_only_packs(technology, packs)
                and has_prerequisites(technology, researched)
            then
                researched[name] = true
                changed = true
            end
        end
    end
    return researched
end

local tier_cache = {}

--- All researchable technologies that need no other science packs than the given ones.
--- The same pack set gets the same (cached) table.
--- @param packs table<string, boolean> set of pack facts
--- @return table<string, boolean>
local function get_technologies_for_packs(packs)
    local key = table.concat(sorted_keys(packs), ",")
    if not tier_cache[key] then
        tier_cache[key] = research_everything_with(packs)
    end
    return tier_cache[key]
end

--- All technologies a player can research in the tier of the given technology.
--- Technologies of the same tier get the same (cached) table.
--- @return table<string, boolean>
function ProgressionGraph.get_tier(technology_name)
    return get_technologies_for_packs(ProgressionGraph.get_tier_packs(technology_name))
end

--- The technologies a player can research in the tier of the given technology without researching it:
--- everything that needs no other science packs, except the technology and those that build on it.
--- @return table<string, boolean>
function ProgressionGraph.get_tier_without(technology_name)
    local ret = {}
    for name in pairs(ProgressionGraph.get_tier(technology_name)) do
        if name ~= technology_name and not ProgressionGraph.get_ancestors(name)[technology_name] then
            ret[name] = true
        end
    end
    -- the prerequisites are guaranteed in any case, also when one of them isn't researchable by itself
    for name in pairs(ProgressionGraph.get_ancestors(technology_name)) do
        ret[name] = true
    end
    return ret
end

---------------------------------------------------------------------------------------------------
-- << static rules >>

--- Rules and facts that hold regardless of research. Built once, on the first new state.
local static_rules
local static_facts

local function add_rule(requirements, products, source)
    if not ProgressionGraph.is_test_prototype(source) then
        static_rules[#static_rules + 1] = {requirements = requirements, products = products, source = source}
    end
end

--- The character: handcrafting (without fluids) and handmining.
local function add_character_facts()
    local character = data.raw.character and data.raw.character.character
    if not character then
        return
    end
    for _, category in pairs(character.crafting_categories or {}) do
        static_facts[#static_facts + 1] = crafting_fact(category, 0, 0)
    end
    for _, category in pairs(character.mining_categories or {}) do
        static_facts[#static_facts + 1] = "mining:" .. category
    end
end

--- Items: placing, spoiling, burning, launching.
local function add_item_rules(item)
    if item.parameter then
        return
    end
    local fact = "item:" .. item.name
    if item.place_result then
        add_rule({fact}, {"entity:" .. item.place_result}, item.name)
    end
    if item.spoil_result then
        add_rule({fact}, {"item:" .. item.spoil_result}, item.name)
    end
    if item.burnt_result then
        add_rule({fact}, {"item:" .. item.burnt_result}, item.name)
    end
    if item.rocket_launch_products then
        add_rule({fact, "rocket-launch"}, facts_of(item.rocket_launch_products), item.name)
    end
end

--- World fluids, pumped from autoplaced tiles.
local function get_tile_fluids()
    local fluids = {}
    for _, tile in pairs(data.raw.tile) do
        if tile.fluid and tile.autoplace then
            fluids[#fluids + 1] = "fluid:" .. tile.fluid
        end
    end
    return fluids
end

--- A placed building works, with its full workforce if it needs one (Inhabitants.evaluate_workforce).
local function add_working_rules(entity)
    local building = Building.values[entity.name]
    local workforce = building and building.workforce
    local placed = "entity:" .. entity.name
    if not workforce then
        add_rule({placed}, {working_fact(entity.name)}, entity.name)
        return
    end
    for _, caste in pairs(workforce.castes) do
        add_rule({placed, inhabitants_fact(caste)}, {working_fact(entity.name)}, entity.name)
    end
end

local function add_mining_drill_rules(entity)
    local categories = {}
    local fluid_categories = {}
    for _, category in pairs(entity.resource_categories or {}) do
        categories[#categories + 1] = "mining:" .. category
        fluid_categories[#fluid_categories + 1] = "fluid-mining:" .. category
    end
    add_rule({working_fact(entity.name)}, categories, entity.name)
    if entity.input_fluid_box then
        add_rule({working_fact(entity.name)}, fluid_categories, entity.name)
    end
end

local function add_resource_rules(entity)
    local category = entity.category or "basic-solid"
    local products = minable_products(entity.minable)
    local required_fluid = entity.minable and entity.minable.required_fluid
    if required_fluid then
        add_rule({"fluid-mining:" .. category, "fluid:" .. required_fluid, "mining-with-fluid"}, products, entity.name)
    else
        add_rule({"mining:" .. category}, products, entity.name)
    end
end

local function add_offshore_pump_rules(entity, tile_fluids)
    add_rule({working_fact(entity.name)}, tile_fluids, entity.name)
end

local function add_boiler_rules(entity)
    local input = entity.fluid_box and entity.fluid_box.filter
    local output = entity.output_fluid_box and entity.output_fluid_box.filter
    if input and output then
        add_rule({working_fact(entity.name), "fluid:" .. input}, {"fluid:" .. output}, entity.name)
    end
end

local function add_rocket_silo_rules(entity)
    add_rule({working_fact(entity.name)}, {"rocket-launch"}, entity.name)
end

--- Rules for what an entity of the type gives, called with (entity, tile_fluids).
local rules_by_entity_type = {
    ["mining-drill"] = add_mining_drill_rules,
    ["resource"] = add_resource_rules,
    ["offshore-pump"] = add_offshore_pump_rules,
    ["boiler"] = add_boiler_rules,
    ["rocket-silo"] = add_rocket_silo_rules
}

--- Entities: machines, drills, pumps, boilers, world entities.
local function add_entity_rules(entity, tile_fluids)
    add_working_rules(entity)

    if entity.crafting_categories and entity.type ~= "character" then
        add_rule({working_fact(entity.name)}, get_crafting_capabilities(entity), entity.name)
    end

    local type_rules = rules_by_entity_type[entity.type]
    if type_rules then
        type_rules(entity, tile_fluids)
    elseif entity.autoplace and entity.minable then
        -- trees, rocks, fish, plants: mined by hand where the world generator put them
        add_rule({}, minable_products(entity.minable), entity.name)
    end
end

--- Adds a rule "working <producer> + requirements give products" for every producer entity of the definition.
local function add_scripted_rules(definition, requirements, products)
    for _, entity_name in pairs(ScriptedProducts.get_producer_entities(definition)) do
        add_rule(merge({working_fact(entity_name)}, requirements), products, entity_name .. " (scripted)")
    end
end

--- Items that buildings insert by script, some of them only with inhabitants of any caste around.
local function add_scripted_product_rules()
    for _, definition in pairs(ScriptedProducts.values) do
        local products = {"item:" .. definition.item}
        if definition.needs_inhabitants then
            for _, caste in pairs(Castes.all) do
                add_scripted_rules(definition, {inhabitants_fact(caste.type)}, products)
            end
        else
            add_scripted_rules(definition, {}, products)
        end
    end
end

--- Housing: a house big enough for the caste, with a market with any food and drinking water in range.
local function add_housing_rules()
    for food_name in pairs(Food.values) do
        add_scripted_rules(ScriptedProducts.food_suppliers, {"item:" .. food_name}, {"food-supply"})
    end
    for water_name in pairs(DrinkingWater.values) do
        add_scripted_rules(ScriptedProducts.water_suppliers, {"fluid:" .. water_name}, {"water-supply"})
    end
    for house_name, house in pairs(Housing.values) do
        for _, caste in pairs(Castes.all) do
            if Housing.allows_caste(house, caste) then
                add_rule({"entity:" .. house_name, "food-supply", "water-supply"}, {housing_fact(caste.type)}, house_name)
            end
        end
    end
end

--- Inhabitants: hatched from any egg into one of the researched breedable castes, moving into a house.
local function add_hatching_rules()
    for _, caste in pairs(Castes.all) do
        if caste.breedable then
            for egg_name in pairs(InhabitantsConstants.egg_data) do
                add_scripted_rules(
                    ScriptedProducts.hatcheries,
                    {"item:" .. egg_name, housing_fact(caste.type), "technology:" .. caste.tech_name},
                    {inhabitants_fact(caste.type)}
                )
            end
        end
    end
end

--- Buildings that craft a category by script.
local function add_scripted_crafting_rules()
    for _, definition in pairs(ScriptedProducts.crafting_categories) do
        add_scripted_rules(definition, {}, {crafting_fact(definition.category, 0, 0)})
    end
end

local function build_static_rules()
    static_rules = {}
    static_facts = {}

    add_character_facts()
    iterate_prototypes("item", add_item_rules)
    local tile_fluids = get_tile_fluids()
    iterate_prototypes("entity", function(entity)
        add_entity_rules(entity, tile_fluids)
    end)

    add_scripted_product_rules()
    add_housing_rules()
    add_hatching_rules()
    add_scripted_crafting_rules()
end

---------------------------------------------------------------------------------------------------
-- << states >>

local State = {}
State.__index = State

--- Creates a state that holds everything obtainable without research.
function ProgressionGraph.new_state()
    if not static_rules then
        build_static_rules()
    end

    local state = setmetatable({
        facts = {},
        rules_by_requirement = {},
        missing_counts = {},
        queue = {},
        added_recipes = {},
        rules_by_product = {}
    }, State)

    for _, fact in pairs(static_facts) do
        state:add_fact(fact)
    end
    for _, rule in pairs(static_rules) do
        state:add_rule(rule)
    end
    state:propagate()

    return state
end

function State:add_fact(fact)
    if not self.facts[fact] then
        self.facts[fact] = true
        self.queue[#self.queue + 1] = fact
    end
end

function State:fire(rule)
    for _, product in pairs(rule.products) do
        self:add_fact(product)
    end
end

--- Counts one more requirement of the rule as met and fires it once it has all of them.
function State:satisfy_requirement(rule)
    local missing = self.missing_counts[rule] - 1
    self.missing_counts[rule] = missing
    if missing == 0 then
        self:fire(rule)
    end
end

function State:add_rule(rule)
    for _, product in pairs(rule.products) do
        local producers = get_subtbl(self.rules_by_product, product)
        producers[#producers + 1] = rule
    end

    local missing = 0
    for _, requirement in pairs(rule.requirements) do
        if not self.facts[requirement] then
            missing = missing + 1
            local waiting = get_subtbl(self.rules_by_requirement, requirement)
            waiting[#waiting + 1] = rule
        end
    end

    self.missing_counts[rule] = missing
    if missing == 0 then
        self:fire(rule)
    end
end

--- Derives every fact that follows from the rules added so far.
function State:propagate()
    local queue = self.queue
    local index = 1
    while index <= #queue do
        local fact = queue[index]
        index = index + 1

        local waiting = self.rules_by_requirement[fact]
        self.rules_by_requirement[fact] = nil
        for _, rule in pairs(waiting or {}) do
            self:satisfy_requirement(rule)
        end
    end
    self.queue = {}
end

--- Adds the rules of a recipe: one per crafting category, since a machine for any of them is enough.
function State:add_recipe(recipe_name)
    if self.added_recipes[recipe_name] then
        return
    end
    self.added_recipes[recipe_name] = true

    local recipe = data.raw.recipe[recipe_name]
    if not recipe or recipe.parameter or ProgressionGraph.is_test_prototype(recipe_name) then
        return
    end

    local requirements = ProgressionGraph.recipe_requirements(recipe)
    local products = ProgressionGraph.recipe_products(recipe)

    -- an education recipe graduates the students into its caste, who need a house of their own
    -- (the students are the workforce of the school, so its crafting fact needs them already)
    local education = ScriptedProducts.get_education(recipe)
    if education then
        products[#products + 1] = inhabitants_fact(education.result)
        requirements[#requirements + 1] = housing_fact(education.result)
    end

    for _, crafting in pairs(get_crafting_requirements(recipe)) do
        self:add_rule({requirements = merge({crafting}, requirements), products = products, source = recipe_name})
    end
end

--- Adds the recipes and effects of the given technology.
function State:add_technology(technology_name)
    local technology = data.raw.technology[technology_name]
    if not technology then
        return
    end
    self:add_fact("technology:" .. technology_name)
    for _, effect in pairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" then
            self:add_recipe(effect.recipe)
        elseif effect.type == "mining-with-fluid" then
            self:add_fact("mining-with-fluid")
        end
    end
end

function State:add_start_recipes()
    for name, recipe in pairs(data.raw.recipe) do
        if ProgressionGraph.is_start_recipe(recipe) then
            self:add_recipe(name)
        end
    end
end

function State:has(fact)
    return self.facts[fact] == true
end

--- Whether this state has a machine for the recipe.
function State:can_craft_category(recipe)
    for _, crafting in pairs(get_crafting_requirements(recipe)) do
        if self.facts[crafting] then
            return true
        end
    end
    return false
end

--- The missing requirements of the recipe as facts, with every crafting fact that would do when no machine fits.
function State:missing_for_recipe(recipe_name)
    local recipe = data.raw.recipe[recipe_name]
    local missing = {}
    for _, requirement in pairs(ProgressionGraph.recipe_requirements(recipe)) do
        if not self.facts[requirement] then
            missing[#missing + 1] = requirement
        end
    end
    if not self:can_craft_category(recipe) then
        merge(missing, get_crafting_requirements(recipe))
    end
    return missing
end

--- Calls fn with every requirement of every rule that could produce the fact.
function State:for_each_requirement_of(fact, fn)
    for _, rule in pairs(self.rules_by_product[fact] or {}) do
        for _, requirement in pairs(rule.requirements) do
            fn(requirement)
        end
    end
end

--- Follows the given missing facts back to the ones nothing in this state can produce.
--- Returns them as a sorted array of readable strings.
--- @param facts string[]
--- @return string[]
function State:find_roots(facts)
    local roots = {}
    local visited = {}

    local function visit(fact)
        if visited[fact] or self.facts[fact] then
            return
        end
        visited[fact] = true

        if not self.rules_by_product[fact] then
            roots[fact] = true
        end
        self:for_each_requirement_of(fact, visit)
    end

    for _, fact in pairs(facts) do
        visit(fact)
    end
    return sorted_keys(roots)
end

--- Follows the given missing facts back like find_roots and returns the loops on the way: facts that need,
--- through other missing facts, themselves. Each loop as "a needs b needs a", sorted.
--- @param facts string[]
--- @return string[]
function State:find_cycles(facts)
    local cycles = {}
    local done = {}
    local path = {} -- the facts currently being visited, each needed by the one before
    local path_index = {}

    --- The loop from the fact's place in the path back to the fact.
    local function describe_loop(fact)
        local loop = {}
        for i = path_index[fact], #path do
            loop[#loop + 1] = path[i]
        end
        loop[#loop + 1] = fact
        return table.concat(loop, " needs ")
    end

    local function visit(fact)
        if done[fact] or self.facts[fact] then
            return
        end
        if path_index[fact] then
            cycles[describe_loop(fact)] = true
            return
        end

        path[#path + 1] = fact
        path_index[fact] = #path
        self:for_each_requirement_of(fact, visit)
        path[#path] = nil
        path_index[fact] = nil
        done[fact] = true
    end

    for _, fact in pairs(facts) do
        visit(fact)
    end
    return sorted_keys(cycles)
end

--- The state of everything a player has once the given technologies are researched.
--- @param technologies table<string, boolean> set of technology names
function ProgressionGraph.state_for(technologies)
    local state = ProgressionGraph.new_state()
    state:add_start_recipes()
    for name in pairs(technologies) do
        state:add_technology(name)
    end
    state:propagate()
    return state
end

local tier_states = {}

--- The state of the whole tier of the technology, shared by all technologies of that tier.
--- Cached, so don't add anything to it.
function ProgressionGraph.get_tier_state(technology_name)
    local tier = ProgressionGraph.get_tier(technology_name)
    if not tier_states[tier] then
        tier_states[tier] = ProgressionGraph.state_for(tier)
    end
    return tier_states[tier]
end

return ProgressionGraph
