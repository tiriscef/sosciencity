--- Data-stage model of what a player can obtain, for the progression checks in tests/content.
---
--- Everything is expressed as rules "these facts give those facts". Facts are strings:
--- "item:<name>", "fluid:<name>", "entity:<name>" (placeable), "crafting:<category>" (a machine for it,
--- with "[<n> in, <m> out]" appended when the recipe needs fluid boxes),
--- "mining:<resource category>", "fluid-mining:<resource category>", "mining-with-fluid" and "rocket-launch".
--- A state starts from the rules that don't depend on research and gets recipe rules added for the
--- recipes that a set of technologies unlocks. Adding rules keeps everything derived so far,
--- so a check can derive the state of a technology's prerequisites first and add the technology's
--- own recipes afterwards.

local ScriptedProducts = require("constants.scripted-products")
local Unlocks = require("constants.unlocks")

local ProgressionGraph = {}

---------------------------------------------------------------------------------------------------
-- << prototype access >>

local function iterate_prototypes(base_type, fn)
    for type_name in pairs(defines.prototypes[base_type]) do
        for _, prototype in pairs(data.raw[type_name] or {}) do
            fn(prototype)
        end
    end
end

local function fact_of(product)
    return (product.type == "fluid" and "fluid:" or "item:") .. product.name
end

--- Facts of the products of a MinableProperties table.
local function minable_products(minable)
    local facts = {}
    if not minable then
        return facts
    end
    if minable.results then
        for _, result in pairs(minable.results) do
            facts[#facts + 1] = fact_of(result)
        end
    elseif minable.result then
        facts[1] = "item:" .. minable.result
    end
    return facts
end

local function get_recipe_categories(recipe)
    if recipe.categories then
        return recipe.categories
    end
    return {recipe.category or "crafting"}
end

--- The fact for a machine that crafts the category and has at least the given numbers of fluid boxes.
local function crafting_fact(category, fluid_inputs, fluid_outputs)
    if fluid_inputs == 0 and fluid_outputs == 0 then
        return "crafting:" .. category
    end
    return string.format("crafting:%s[%d in, %d out]", category, fluid_inputs, fluid_outputs)
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

--- The crafting facts a machine provides: every category with every fluid box count up to its own.
local function get_crafting_capabilities(entity)
    local fluid_inputs = 0
    local fluid_outputs = 0
    for _, fluid_box in pairs(entity.fluid_boxes or {}) do
        if fluid_box.production_type == "input" or fluid_box.production_type == "input-output" then
            fluid_inputs = fluid_inputs + 1
        elseif fluid_box.production_type == "output" then
            fluid_outputs = fluid_outputs + 1
        end
    end

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
    local facts = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        facts[#facts + 1] = fact_of(ingredient)
    end
    local required_module = ScriptedProducts.required_modules[recipe.name]
    if required_module then
        facts[#facts + 1] = "item:" .. required_module
    end
    return facts
end

function ProgressionGraph.recipe_products(recipe)
    local facts = {}
    for _, result in pairs(recipe.results or {}) do
        facts[#facts + 1] = fact_of(result)
    end
    return facts
end

---------------------------------------------------------------------------------------------------
-- << technologies >>

--- Whether the prototype belongs to the sosciencity-debug test setup (see datastage-scripts/test-prototype-group.lua).
--- Test recipes are enabled from the start and some make real items, so they would hide real problems.
function ProgressionGraph.is_test_prototype(name)
    return name:sub(1, 5) == "test-"
end

--- Whether the recipe is available without any research.
function ProgressionGraph.is_start_recipe(recipe)
    return recipe.enabled ~= false and not recipe.parameter
end

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
    local packs = {}
    for _, requirement in pairs(ProgressionGraph.get_research_requirements(technology)) do
        packs[requirement] = true
    end
    return packs
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

local tier_cache = {}

--- All researchable technologies that need no other science packs than the given ones.
--- @param packs table<string, boolean> set of pack facts
--- @return table<string, boolean>
local function get_technologies_for_packs(packs)
    local keys = {}
    for pack in pairs(packs) do
        keys[#keys + 1] = pack
    end
    table.sort(keys)
    local key = table.concat(keys, ",")
    if tier_cache[key] then
        return tier_cache[key]
    end

    local technologies = {}
    local changed = true
    while changed do
        changed = false
        for name, technology in pairs(data.raw.technology) do
            if not technologies[name] and ProgressionGraph.is_researchable(technology) then
                local ok = true
                for pack in pairs(get_pack_set(technology)) do
                    if not packs[pack] then
                        ok = false
                        break
                    end
                end
                for _, prerequisite in pairs(ok and technology.prerequisites or {}) do
                    if not technologies[prerequisite] then
                        ok = false
                        break
                    end
                end
                if ok then
                    technologies[name] = true
                    changed = true
                end
            end
        end
    end

    tier_cache[key] = technologies
    return technologies
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
    for name in pairs(get_technologies_for_packs(ProgressionGraph.get_tier_packs(technology_name))) do
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

local static_rules
local static_facts

--- Rules that hold regardless of research.
local function build_static_rules()
    static_rules = {}
    static_facts = {}

    local function add_rule(requirements, products, source)
        static_rules[#static_rules + 1] = {requirements = requirements, products = products, source = source}
    end

    -- the character: handcrafting (without fluids) and handmining
    local character = data.raw.character and data.raw.character.character
    for _, category in pairs(character and character.crafting_categories or {}) do
        static_facts[#static_facts + 1] = crafting_fact(category, 0, 0)
    end
    for _, category in pairs(character and character.mining_categories or {}) do
        static_facts[#static_facts + 1] = "mining:" .. category
    end

    -- items: placing, spoiling, burning
    iterate_prototypes("item", function(item)
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
            local products = {}
            for _, product in pairs(item.rocket_launch_products) do
                products[#products + 1] = fact_of(product)
            end
            add_rule({fact, "rocket-launch"}, products, item.name)
        end
    end)

    -- world fluids, pumped from autoplaced tiles
    local tile_fluids = {}
    for _, tile in pairs(data.raw.tile) do
        if tile.fluid and tile.autoplace then
            tile_fluids[#tile_fluids + 1] = "fluid:" .. tile.fluid
        end
    end

    -- entities: machines, drills, pumps, boilers, world entities
    iterate_prototypes("entity", function(entity)
        local fact = "entity:" .. entity.name

        if entity.crafting_categories and entity.type ~= "character" then
            add_rule({fact}, get_crafting_capabilities(entity), entity.name)
        end

        if entity.type == "rocket-silo" then
            add_rule({fact}, {"rocket-launch"}, entity.name)
        end

        if entity.type == "mining-drill" then
            local categories = {}
            local fluid_categories = {}
            for _, category in pairs(entity.resource_categories or {}) do
                categories[#categories + 1] = "mining:" .. category
                fluid_categories[#fluid_categories + 1] = "fluid-mining:" .. category
            end
            add_rule({fact}, categories, entity.name)
            if entity.input_fluid_box then
                add_rule({fact}, fluid_categories, entity.name)
            end
        elseif entity.type == "resource" then
            local category = entity.category or "basic-solid"
            local products = minable_products(entity.minable)
            local required_fluid = entity.minable and entity.minable.required_fluid
            if required_fluid then
                add_rule(
                    {"fluid-mining:" .. category, "fluid:" .. required_fluid, "mining-with-fluid"},
                    products,
                    entity.name
                )
            else
                add_rule({"mining:" .. category}, products, entity.name)
            end
        elseif entity.type == "offshore-pump" then
            add_rule({fact}, tile_fluids, entity.name)
        elseif entity.type == "boiler" then
            local input = entity.fluid_box and entity.fluid_box.filter
            local output = entity.output_fluid_box and entity.output_fluid_box.filter
            if input and output then
                add_rule({fact, "fluid:" .. input}, {"fluid:" .. output}, entity.name)
            end
        elseif entity.autoplace and entity.minable then
            -- trees, rocks, fish, plants: mined by hand where the world generator put them
            add_rule({}, minable_products(entity.minable), entity.name)
        end
    end)

    -- scripted building logic
    for _, definition in pairs(ScriptedProducts.values) do
        for _, entity_name in pairs(ScriptedProducts.get_producer_entities(definition)) do
            add_rule({"entity:" .. entity_name}, {"item:" .. definition.item}, entity_name .. " (scripted)")
        end
    end
    for _, definition in pairs(ScriptedProducts.crafting_categories) do
        for _, entity_name in pairs(ScriptedProducts.get_producer_entities(definition)) do
            add_rule({"entity:" .. entity_name}, {crafting_fact(definition.category, 0, 0)}, entity_name .. " (scripted)")
        end
    end
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

function State:add_rule(rule)
    for _, product in pairs(rule.products) do
        local producers = self.rules_by_product[product]
        if not producers then
            producers = {}
            self.rules_by_product[product] = producers
        end
        producers[#producers + 1] = rule
    end

    local missing = 0
    for _, requirement in pairs(rule.requirements) do
        if not self.facts[requirement] then
            missing = missing + 1
            local waiting = self.rules_by_requirement[requirement]
            if not waiting then
                waiting = {}
                self.rules_by_requirement[requirement] = waiting
            end
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
        if waiting then
            self.rules_by_requirement[fact] = nil
            for _, rule in pairs(waiting) do
                local missing = self.missing_counts[rule] - 1
                self.missing_counts[rule] = missing
                if missing == 0 then
                    self:fire(rule)
                end
            end
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
    for _, crafting in pairs(get_crafting_requirements(recipe)) do
        local rule_requirements = {crafting}
        for _, requirement in pairs(requirements) do
            rule_requirements[#rule_requirements + 1] = requirement
        end
        self:add_rule({requirements = rule_requirements, products = products, source = recipe_name})
    end
end

--- Adds the recipes and effects of the given technology.
function State:add_technology(technology_name)
    local technology = data.raw.technology[technology_name]
    if not technology then
        return
    end
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

        local producers = self.rules_by_product[fact]
        if not producers then
            roots[fact] = true
            return
        end
        for _, rule in pairs(producers) do
            for _, requirement in pairs(rule.requirements) do
                visit(requirement)
            end
        end
    end

    for _, fact in pairs(facts) do
        visit(fact)
    end

    local ret = {}
    for fact in pairs(roots) do
        ret[#ret + 1] = fact
    end
    table.sort(ret)
    return ret
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
        for _, crafting in pairs(get_crafting_requirements(recipe)) do
            missing[#missing + 1] = crafting
        end
    end
    return missing
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

return ProgressionGraph
