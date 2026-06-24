for _, recipe in Tirislib.Recipe.iterate() do
    -- Only when handcrafting is the sole category: the appended note tells the player this recipe
    -- can't be automated, which wouldn't hold if the recipe also belongs to an automatable category.
    local categories = recipe.categories
    if categories and #categories == 1 and categories[1] == "sosciencity-handcrafting" then
        local original_description = recipe.localised_description or {"recipe-description." .. recipe.name}

        recipe.localised_description = {"", original_description, "\n", {"sosciencity-util.handcrafting"}}

        recipe:add_category_layer("handcrafting")
    end
end
