if not Sosciencity.Config.lumber_in_vanilla_recipes then
    return
end

local function double(n)
    return 2 * n
end

--- Recipes that turn wood into something plantable (e.g. Space Age's tree seeds) need the living wood, not lumber.
local function produces_plantable(recipe)
    for _, result in pairs(recipe.results or {}) do
        if result.type == "item" then
            local item, found = Tirislib.Item.get_by_name(result.name)
            if found and item.plant_result then
                return true
            end
        end
    end

    return false
end

for _, recipe in Tirislib.Recipe.iterate() do
    if Tirislib.Prototype.get_owner(recipe) ~= "sosciencity" and not produces_plantable(recipe) then
        recipe:replace_ingredient("wood", "lumber", nil, nil, double)
    end
end
