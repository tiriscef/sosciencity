table.insert(item_operations, {
    func = function(item, details)
        if not item:is_launchable() then
            return
        end

        local launch_products = item:get_launch_products()
        for _, product in pairs(launch_products) do
            local name = RecipeEntry:get_name(product)
            local amount = RecipeEntry:get_average_yield(product)

            for _, operation in pairs(recipe_operations) do
                if operation.details.spread_to_launch_products and name == operation.details.item then
                    table.insert(recipe_operations, {
                        func = conditional_add_ingredient, 
                        details = {
                            item = name,
                            item_to_add = operation.details.item_to_add,
                            type = operation.details.type,
                            amount_factor = operation.details.amount_factor * amount
                        }
                    })
                end
            end
        end
    end
})