require("constants.unlocks")

Tirislib_Item.create {
    name = "sosciencity-research-blocker",
    type = "tool",
    icon = "__core__/graphics/cancel.png",
    icon_size = 64,
    stack_size = 50,
    durability = 1,
    is_hack = true
}

Tirislib_Technology.create {
    name = "sosciencity-research-blocker",
    icon = "__core__/graphics/cancel.png",
    icon_size = 64,
    prerequisites = {"aurora-caste"},
    unit = {
        count = 1,
        time = 1,
        ingredients = {
            {"sosciencity-research-blocker", 1}
        }
    },
    upgrade = false,
    enabled = false,
    is_hack = true
}

for tech_name, item_name in pairs(Unlocks.by_item_aquisition) do
    local item = Tirislib_Item.get_by_name(item_name)
    local localised_name = item:get_localised_name()

    Tirislib_Technology.create {
        name = tech_name,
        icon = Tirislib_String.insert(item.icon, "-hr", -5),
        icon_size = 128,
        effects = {},
        unit = {
            count = 1,
            time = 1,
            ingredients = {
                {"sosciencity-research-blocker", 1}
            }
        },
        upgrade = false,
        enabled = false,
        visible_when_disabled = true,
        prerequisites = {"sosciencity-research-blocker"},
        localised_name = localised_name,
        localised_description = {"technology-description.acquisition", localised_name},
        is_hack = true
    }
end
