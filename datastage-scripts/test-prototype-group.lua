-- Moves the test prototypes of the sosciencity-debug mod into their own item group, so they don't
-- clutter the crafting menu and Factoriopedia categories of the real items.
-- Every item and recipe whose name starts with "test-" counts as a test prototype.

if not Sosciencity.Config.DEBUG then
    return
end

Tirislib.ItemGroups.create {
    name = "sosciencity-test-prototypes",
    order = "zz",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroups = {
        "sosciencity-test-buildings",
        "sosciencity-test-items",
        "sosciencity-test-recipes"
    }
}

local function is_test_prototype(name)
    return name:sub(1, 5) == "test-"
end

local test_item_subgroups = {}

for name, item in Tirislib.Item.iterate() do
    if is_test_prototype(name) then
        item.subgroup = item.place_result and "sosciencity-test-buildings" or "sosciencity-test-items"
        test_item_subgroups[name] = item.subgroup
    end
end

for name, recipe in Tirislib.Recipe.iterate() do
    if is_test_prototype(name) then
        -- recipes for a test item sit next to their item, the rest (test recipes for real products) get their own row
        local main_product = recipe.main_product or (recipe.results and recipe.results[1] and recipe.results[1].name)
        recipe.subgroup = test_item_subgroups[main_product] or "sosciencity-test-recipes"
    end
end
