local all_recipes = Tirislib.Recipe.all()

for index, recipe in pairs(all_recipes) do
    -- filter out recipes created by transport drones and the void crushing recipes of krastorio2
    if recipe.is_hack or Tirislib.String.begins_with(recipe.name, "request-") or recipe:has_category("void-crushing") then
        all_recipes[index] = nil
    end
end

local function identity(n)
    return n
end

--- Flat list of (result - ingredient) pairings for science packs.
local sp_pairings = {
    -- automation science
    {
        result = Sosciencity.Config.ember_pack,
        result_type = "item",
        ingredient = "artistic-insight",
        ingredient_type = "item",
        amount_fn = identity
    },
    -- logistic science
    {
        result = Sosciencity.Config.orchid_pack,
        result_type = "item",
        ingredient = "environmental-study",
        ingredient_type = "item",
        amount_fn = identity
    },
    {
        result = Sosciencity.Config.orchid_pack,
        result_type = "item",
        ingredient = "mosaic",
        ingredient_type = "item",
        amount_fn = identity
    },
    -- military science
    {
        result = Sosciencity.Config.gunfire_pack,
        result_type = "item",
        ingredient = "strategic-considerations",
        ingredient_type = "item",
        amount_fn = identity
    },
    {
        result = Sosciencity.Config.gunfire_pack,
        result_type = "item",
        ingredient = "found-art",
        ingredient_type = "item",
        amount_fn = identity
    },
    -- chemical science
    {
        result = Sosciencity.Config.clockwork_pack,
        result_type = "item",
        ingredient = "invention",
        ingredient_type = "item",
        amount_fn = identity
    },
    {
        result = Sosciencity.Config.clockwork_pack,
        result_type = "item",
        ingredient = "mixtape",
        ingredient_type = "item",
        amount_fn = identity
    },
    -- production science
    {
        result = Sosciencity.Config.foundry_pack,
        result_type = "item",
        ingredient = "scientific-theory",
        ingredient_type = "item",
        amount_fn = identity
    },
    {
        result = Sosciencity.Config.foundry_pack,
        result_type = "item",
        ingredient = "kinetic-sculpture",
        ingredient_type = "item",
        amount_fn = identity
    },
    -- utility science
    {
        result = Sosciencity.Config.gleam_pack,
        result_type = "item",
        ingredient = "metastudy",
        ingredient_type = "item",
        amount_fn = identity
    },
    {
        result = Sosciencity.Config.gleam_pack,
        result_type = "item",
        ingredient = "jewellery",
        ingredient_type = "item",
        amount_fn = identity
    },
    --[[{
        result = Sosciencity.Config.aurora_pack,
        result_type = "item",
        ingredient = "well-funded-scientific-thesis",
        ingredient_type = "item",
        amount_fn = function(n)
            return n * 0.1
        end
    }]]
}

-- group pairings by result name so the rocket derivation can fan out correctly
local result_to_pairings = {}
for _, pairing in pairs(sp_pairings) do
    local list = result_to_pairings[pairing.result]
    if not list then
        list = {}
        result_to_pairings[pairing.result] = list
    end
    list[#list + 1] = pairing
end

-- derive pairings for items that, when launched as a rocket, yield a science pack
local rocket_pairings = {}
for _, item in Tirislib.Item.iterate() do
    for _, launch_product in pairs(item:get_launch_products()) do
        local pairings = result_to_pairings[launch_product.name]
        if pairings then
            local launch_product_amount = Tirislib.RecipeEntry.get_average_yield(launch_product)
            for _, pairing in pairs(pairings) do
                rocket_pairings[#rocket_pairings + 1] = {
                    result = item.name,
                    result_type = "item",
                    ingredient = pairing.ingredient,
                    ingredient_type = pairing.ingredient_type,
                    amount_fn = function(n)
                        return launch_product_amount * pairing.amount_fn(n)
                    end
                }
            end
        end
    end
end

local function apply_pairings(pairings)
    for _, pairing in pairs(pairings) do
        all_recipes:pair_result_with_ingredient(
            pairing.result,
            pairing.result_type,
            pairing.ingredient,
            pairing.ingredient_type,
            pairing.amount_fn
        )
    end
end

apply_pairings(sp_pairings)
apply_pairings(rocket_pairings)
