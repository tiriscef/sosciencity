-- Factorio 2.1 merged the recipe prototype's `category` and `additional_categories` fields into a single `categories` array. 
-- Before I update every piece of code that reads .category properly, I will use this blanket-fix.

for _, recipe in Tirislib.Recipe.iterate() do
    if recipe.category or recipe.additional_categories then
        local categories = {}

        if recipe.category then
            categories[#categories + 1] = recipe.category
        end
        if recipe.additional_categories then
            for _, category in pairs(recipe.additional_categories) do
                categories[#categories + 1] = category
            end
        end

        recipe.categories = categories
        recipe.category = nil
        recipe.additional_categories = nil
    end
end
