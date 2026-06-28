---------------------------------------------------------------------------------------------------
-- << static class for Recipe Entries >>

--- Functions for ItemProductPrototype, FluidProductPrototype, ItemIngredientPrototype and FluidIngredientPrototype.
--- These entry shapes are shared by recipes (ingredients/results), entity loot and entity mining results.
--- @class RecipeEntryPrototype
Tirislib.RecipeEntry = {}

--- The engine default for each RecipeEntryPrototype fields.
--- Fields without a meaningful default are simply absent here, so get_field returns nil for them.
--- Note: fluidbox_index and shared_probability are intentionally omitted - see can_be_merged.
local default_values = {
    type = "item",
    independent_probability = 1,
    percent_spoiled = 0,
    quality_change = 0,
    affected_by_quality = true,
    always_fresh = false,
    reset_freshness_on_craft = false,
    spoil_weight = 1,
    extra_count_fraction = 0
}

--- Returns the value of the given field, falling back to the field's default if it isn't set.
--- @param entry RecipeEntryPrototype
--- @param field string
--- @return any
function Tirislib.RecipeEntry.get_field(entry, field)
    local value = entry[field]
    if value ~= nil then
        return value
    end
    return default_values[field]
end

--- Sets the RecipeEntryPrototype's return amount to the given value.
--- @param entry table
--- @param min integer
--- @param max integer?
function Tirislib.RecipeEntry.set_product_amount(entry, min, max)
    -- Clear any leftover fractional amount so the new amount isn't silently inflated by it.
    entry.extra_count_fraction = nil
    if not max then
        entry.amount = min
        entry.amount_min = nil
        entry.amount_max = nil
    else
        entry.amount = nil
        entry.amount_min = min
        entry.amount_max = max
    end
end

--- Adds to the amount of this RecipeEntryPrototype.
--- @param entry RecipeEntryPrototype
--- @param min integer
--- @param max integer?
function Tirislib.RecipeEntry.add_amount(entry, min, max)
    if not max or min == max then
        if entry.amount_min then
            entry.amount_min = entry.amount_min + min
            entry.amount_max = entry.amount_max + min
        else
            entry.amount = entry.amount + min
        end
    else
        entry.amount_min = (entry.amount_min or entry.amount) + min
        entry.amount_max = (entry.amount_max or entry.amount) + max
        entry.amount = nil
    end
end

--- Multiplies this RecipeEntryPrototype's amount with the given multiplier.
--- @param entry RecipeEntryPrototype
--- @param multiplier number
function Tirislib.RecipeEntry.multiply_amount(entry, multiplier)
    if entry.amount then
        entry.amount = entry.amount * multiplier
    end
    if entry.amount_min then
        entry.amount_min = entry.amount_min * multiplier
        entry.amount_max = entry.amount_max * multiplier
    end
end

--- Transforms the given RecipeEntryPrototype's amount by the given function.
--- @param entry RecipeEntryPrototype
--- @param fn function
function Tirislib.RecipeEntry.transform_amount(entry, fn)
    if entry.amount then
        entry.amount = fn(entry.amount)
        entry.amount = math.max(entry.amount, 1)
    elseif entry.amount_min then
        entry.amount_min = fn(entry.amount_min)
        entry.amount_max = fn(entry.amount_max)
    end
end

--- Returns the average yield of the given RecipeEntryPrototype, assuming it's a ProductPrototype.
--- @param entry RecipeEntryPrototype
--- @return number yield
function Tirislib.RecipeEntry.get_average_yield(entry)
    local probability = Tirislib.RecipeEntry.get_field(entry, "independent_probability")
    local extra = Tirislib.RecipeEntry.get_field(entry, "extra_count_fraction")

    local base
    if entry.amount_min then
        base = (entry.amount_min + entry.amount_max) * 0.5
    else
        base = entry.amount
    end

    return base * probability + extra
end

--- Returns the maximum yield of the given RecipeEntryPrototype, assuming it's a ProductPrototype.
--- @param entry RecipeEntryPrototype
--- @return number yield
function Tirislib.RecipeEntry.get_max_yield(entry)
    local base = entry.amount_max or entry.amount

    if Tirislib.RecipeEntry.get_field(entry, "extra_count_fraction") > 0 then
        base = base + 1
    end

    return base
end

--- Fields compared (via get_field, so an explicit value equal to its default still matches an
--- absent one) when deciding whether two entries describe the same stuff. shared_probability and
--- fluidbox_index are handled separately below because they need special comparison semantics.
local merge_compared_fields = {
    "name",
    "type",
    -- ProductPrototypeBase
    "independent_probability",
    -- ItemProductPrototype
    "percent_spoiled",
    "affected_by_quality",
    "always_fresh",
    "reset_freshness_on_craft",
    -- quality (ItemIngredientPrototype / ItemProductPrototype)
    "quality_min",
    "quality_max",
    "quality_change",
    -- ItemIngredientPrototype
    "spoil_weight",
    -- FluidProductPrototype
    "temperature",
    -- FluidIngredientPrototype
    "minimum_temperature",
    "maximum_temperature"
}

--- Checks if the given RecipeEntryPrototypes can be merged, meaning they specify the same stuff.
--- @param lh RecipeEntryPrototype
--- @param rh RecipeEntryPrototype
--- @return boolean
function Tirislib.RecipeEntry.can_be_merged(lh, rh)
    for _, field in pairs(merge_compared_fields) do
        if Tirislib.RecipeEntry.get_field(lh, field) ~= Tirislib.RecipeEntry.get_field(rh, field) then
            return false
        end
    end

    -- shared_probability is a {min, max} range table, so it needs a deep comparison; entries
    -- merge when their ranges are value-equal (or both absent).
    if not Tirislib.Tables.equal(lh.shared_probability, rh.shared_probability) then
        return false
    end

    -- A nil fluidbox_index means the entry doesn't care which fluidbox it uses, so two entries
    -- only conflict when both pin an index and those indices differ.
    if lh.fluidbox_index and rh.fluidbox_index and lh.fluidbox_index ~= rh.fluidbox_index then
        return false
    end

    return true
end

--- Merges the given right hand RecipeEntryPrototype into the given left hand RecipeEntryPrototype.
--- @param lh RecipeEntryPrototype
--- @param rh RecipeEntryPrototype
function Tirislib.RecipeEntry.merge(lh, rh)
    local min = rh.amount_min or rh.amount
    local max = rh.amount_max or rh.amount

    Tirislib.RecipeEntry.add_amount(lh, min, max)

    if rh.ignored_by_stats then
        lh.ignored_by_stats = (lh.ignored_by_stats or 0) + rh.ignored_by_stats
    end
    if rh.ignored_by_productivity then
        lh.ignored_by_productivity = (lh.ignored_by_productivity or 0) + rh.ignored_by_productivity
    end
    if rh.extra_count_fraction then
        lh.extra_count_fraction = (lh.extra_count_fraction or 0) + rh.extra_count_fraction

        if lh.extra_count_fraction >= 1 then
            local overhang = math.floor(lh.extra_count_fraction)
            lh.extra_count_fraction = lh.extra_count_fraction - overhang
            Tirislib.RecipeEntry.add_amount(lh, overhang)
        end
    end
end

--- Creates a ProductPrototype for the given product and with the given average yield.
--- @param product ItemID|FluidID
--- @param amount number
--- @param _type string? defaults to 'item'
--- @return RecipeEntryPrototype?
function Tirislib.RecipeEntry.create_product_prototype(product, amount, _type)
    if amount > 0 then
        local ret = {type = _type or "item", name = product}

        if amount < 1 then
            ret.amount = 1
            ret.independent_probability = amount
        elseif math.floor(amount) == amount then -- amount doesn't have decimals
            ret.amount = amount
        else
            ret.amount = math.floor(amount)
            ret.extra_count_fraction = amount - math.floor(amount)
        end

        return ret
    end
end
