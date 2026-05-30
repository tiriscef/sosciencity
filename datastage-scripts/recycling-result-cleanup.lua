-- Items that are nonsensical as recycling outputs (e.g. abstract concepts, reusable tools).
-- When these appear as results in an auto-generated recycling recipe, strip them out.
local items_to_remove_from_recycling = {
    "architectural-concept",
    "sketch",
    "tools",
    "power-tools",
    "dye"
}

for _, recipe in Tirislib.Recipe.iterate() do
    if recipe.category == "recycling" then
        for _, item_name in pairs(items_to_remove_from_recycling) do
            recipe:remove_result(item_name, "item")
        end
    end
end
