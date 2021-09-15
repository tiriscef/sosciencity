local techs = {
    "infrastructure-1",
    "architecture-1",
    "architecture-2",
    "architecture-3",
    "architecture-4",
    "architecture-5",
    "architecture-6",
    "architecture-7"
}

local function find_appropriate_architecture_tech(item)
    for _, tech_name in pairs(techs) do
        local tech = Tirislib_Technology.get_by_name(tech_name)

        for _, recipe in pairs(tech:get_unlocked_recipes()) do
            if recipe:has_ingredient(item) then
                return tech.name
            end
        end
    end

    -- no technology uses this, yet. Just dump it into the last architecture tech
    return techs[#techs]
end

for _, recipe in Tirislib_Recipe.iterate() do
    if recipe.subgroup == "sosciencity-furniture" then
        local item = recipe:get_first_result()
        local tech = find_appropriate_architecture_tech(item)
        recipe:add_unlock(tech)
    end
end
