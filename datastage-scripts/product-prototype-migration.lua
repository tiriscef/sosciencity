-- Factorio 2.1 reworked ProductPrototypes. Like the category migration, this is a late blanket-fix.

local function migrate_probability(products)
    for _, product in pairs(products) do
        if product.probability then
            product.independent_probability = product.probability
            product.probability = nil
        end
    end
end

local function migrate_loot_fields(loot)
    for _, entry in pairs(loot) do
        if entry.item then
            entry.name = entry.item
            entry.item = nil
        end
        if entry.count_min then
            entry.amount_min = entry.count_min
            entry.count_min = nil
        end
        if entry.count_max then
            entry.amount_max = entry.count_max
            entry.count_max = nil
        end
    end
end

for _, recipe in Tirislib.Recipe.iterate() do
    if recipe.results then
        migrate_probability(recipe.results)
    end
end

for _, entity in Tirislib.Entity.iterate() do
    if entity.minable and entity.minable.results then
        migrate_probability(entity.minable.results)
    end
    if entity.loot then
        migrate_loot_fields(entity.loot)
        migrate_probability(entity.loot)
    end
end
