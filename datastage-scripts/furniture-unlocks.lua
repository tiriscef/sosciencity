local function find_appropriate_architecture_tech(item)
    for i = 1, 7 do
        local tech = Tirislib_Technology.get_by_name("architecture-" .. i)

        for _, recipe in pairs(tech:get_unlocked_recipes()) do
            if recipe:has_ingredient(item) then
                return tech.name
            end
        end
    end

    -- no technology uses this, yet. Just dump it into the last architecture tech
    return "architecture-7"
end

for _, recipe in Tirislib_Recipe.iterate() do
    if recipe.subgroup == "sosciencity-furniture" then
        local item = recipe:get_first_result()
        local tech = find_appropriate_architecture_tech(item)
        recipe:add_unlock(tech)
    end
end
