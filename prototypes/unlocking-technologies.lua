local Unlocks = require("constants.unlocks")

Tirislib.Item.create {
    name = "sosciencity-research-blocker",
    type = "tool",
    icon = "__core__/graphics/cancel.png",
    icon_size = 64,
    stack_size = 50,
    durability = 1,
    flags = {"hidden"},
    is_hack = true
}

for tech_name, item_name in pairs(Unlocks.by_item_aquisition) do
    local item = Tirislib.Item.get_by_name(item_name)
    local localised_name = item:get_localised_name()

    Tirislib.Technology.create {
        name = tech_name,
        icon = Tirislib.String.insert(item.icon, "-hr", -5),
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
        localised_name = localised_name,
        localised_description = {"", {"sosciencity-util.unlock-condition"}, "\n [img=tooltip-category-debug] ", {"sosciencity-util.acquisition", localised_name}},
        is_hack = true
    }
end
