if not Sosciencity_Config.lumber_in_vanilla_recipes then
    return
end

local function double(n)
    return 2 * n
end

for _, recipe in Tirislib.Recipe.iterate() do
    if recipe.owner ~= "sosciencity" then
        recipe:replace_ingredient("wood", "lumber", nil, nil, double)
    end
end
