local all_recipes = Tirislib.Recipe.all()

for index, recipe in pairs(all_recipes) do
    -- filter out recipes created by transport drones and the void crushing recipes of krastorio2
    if recipe.is_hack or Tirislib.String.begins_with(recipe.name, "request-") or recipe.category == "void-crushing" then
        all_recipes[index] = nil
    end
end

local function identity(n)
    return n
end

--- Science pack ingredients
---local settings
if not settings.startup["sosciencity-remove-extra-science-ingredient"].value then --- set to disable notes etc when setting toggled (deafult requires = yes), purely for larger modpacks like mine that makes factories absolutely massive -cyberKoi
    local sp_ingredients = {
        [Sosciencity_Config.clockwork_pack] = {
            result_type = "item",
            ingredient = "sketchbook",
            ingredient_type = "item",
            amount_fn = identity
        },
        [Sosciencity_Config.orchid_pack] = {
            result_type = "item",
            ingredient = "botanical-study",
            ingredient_type = "item",
            amount_fn = identity
        },
        [Sosciencity_Config.gunfire_pack] = {
            result_type = "item",
            ingredient = "strategic-considerations",
            ingredient_type = "item",
            amount_fn = identity
        },
        [Sosciencity_Config.ember_pack] = {
            result_type = "item",
            ingredient = "invention",
            ingredient_type = "item",
            amount_fn = identity
        },
        [Sosciencity_Config.foundry_pack] = {
            result_type = "item",
            ingredient = "complex-scientific-data",
            ingredient_type = "item",
            amount_fn = identity
        },
        [Sosciencity_Config.gleam_pack] = {
            result_type = "item",
            ingredient = "published-paper",
            ingredient_type = "item",
            amount_fn = identity
        },
        [Sosciencity_Config.aurora_pack] = {
            result_type = "item",
            ingredient = "well-funded-scientific-thesis",
            ingredient_type = "item",
            amount_fn = function(n)
                return n * 0.1
            end
        }
    }

    -- find launchable items that produce the science packs
    local launchable_item_ingredients = {}
    for _, item in Tirislib.Item.iterate() do
        for _, launch_product in pairs(item:get_launch_products()) do
            local launch_product_name = Tirislib.RecipeEntry.get_name(launch_product)

            if sp_ingredients[launch_product_name] then
                local details = sp_ingredients[launch_product_name]
                local launch_product_amount = Tirislib.RecipeEntry.get_average_yield(launch_product)

                launchable_item_ingredients[item.name] = {
                    result_type = "item",
                    ingredient = details.ingredient,
                    ingredient_type = details.ingredient_type,
                    amount_fn = function(n)
                        return launch_product_amount * details.amount_fn(n)
                    end
                }
            end
        end
    end


    -- finally pair the science packs and launchable items with the ingredients
    for result_name, details in pairs(sp_ingredients) do
        all_recipes:pair_result_with_ingredient(
            result_name,
            details.result_type,
            details.ingredient,
            details.ingredient_type,
            details.amount_fn
        )
    end

    for result_name, details in pairs(launchable_item_ingredients) do
        all_recipes:pair_result_with_ingredient(
            result_name,
            details.result_type,
            details.ingredient,
            details.ingredient_type,
            details.amount_fn
        )
    end

    all_recipes:pair_ingredient_with_result("complex-scientific-data", "item", "empty-hard-drive", "item", identity)
end
