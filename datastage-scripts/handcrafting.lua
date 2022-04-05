for _, recipe in Tirislib.Recipe.iterate() do
    if recipe.category == "sosciencity-handcrafting" then
        local original_description = recipe.localised_description or {"recipe-description." .. recipe.name}

        recipe.localised_description = {"", original_description, "\n", {"sosciencity-util.handcrafting"}}

        recipe:add_icon_layer("__sosciencity-graphics__/graphics/utility/hand.png", "topright")
    end
end
