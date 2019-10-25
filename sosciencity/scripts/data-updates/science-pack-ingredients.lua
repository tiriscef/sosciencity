function conditional_add_ingredient(recipe, details)
    if recipe:results_contain_item(details.item) then
        if recipe:has_difficulties() then
            local normal_amount, expensive_amount = recipe:get_result_item_count(details.item)

            if not (normal_amount and expensive_amount) then
                recipe:add_ingredient {type = details.type, name = details.item_to_add, amount = (normal_amount or expensive_amount)}
            else
                recipe:add_ingredient(
                    {type = details.type, name = details.item_to_add, amount = normal_amount},
                    {type = details.type, name = details.item_to_add, amount = expensive_amount}
                )
            end
            return
        end

        local ingredient_amount = recipe:get_result_item_count(details.item) * details.amount_factor
        recipe:add_ingredient {type = details.type, name = details.item_to_add, amount = ingredient_amount}
    end
end

table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "automation-science-pack",
            item_to_add = "note",
            type = "item",
            amount_factor = 1,
            spread_to_launch_products = true
        }
    }
)
table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "logistic-science-pack",
            item_to_add = "essay",
            type = "item",
            amount_factor = 1,
            spread_to_launch_products = true
        }
    }
)
table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "military-science-pack",
            item_to_add = "strategic-considerations",
            type = "item",
            amount_factor = 1,
            spread_to_launch_products = true
        }
    }
)
table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "chemical-science-pack",
            item_to_add = "published-paper",
            type = "item",
            amount_factor = 1,
            spread_to_launch_products = true
        }
    }
)
table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "production-science-pack",
            item_to_add = "complex-scientific-data",
            type = "item",
            amount_factor = 1,
            spread_to_launch_products = true
        }
    }
)
table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "utility-science-pack",
            item_to_add = "data-collection",
            type = "item",
            amount_factor = 1,
            spread_to_launch_products = true
        }
    }
)
table.insert(
    recipe_operations,
    {
        func = conditional_add_ingredient,
        details = {
            item = "space-science-pack",
            item_to_add = "well-funded-scientific-thesis",
            type = "item",
            amount_factor = 0.1,
            spread_to_launch_products = true
        }
    }
)
