for _, recipe in Tirislib_Recipe.iterate() do
    if recipe.category == "handcrafting" then
        local original_description = recipe.localised_description or {"recipe-description." .. recipe.name}

        recipe.localised_description = {"", original_description, {"description.handcrafting"}}
    end
end
