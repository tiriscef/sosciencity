local Unlocks = require("constants.unlocks")

for tech_name, details in pairs(Unlocks.by_item_acquisition) do
    local item_name = details.item
    local item = Tirislib.Item.get_by_name(item_name)
    local localised_name = item:get_localised_name()

    Tirislib.Technology.create {
        name = tech_name,
        icon = Tirislib.String.insert(item.icon, "-hr", -5),
        icon_size = 128,
        prerequisites = details.prerequisites,
        effects = {},
        research_trigger = Unlocks.get_research_trigger(details),
        upgrade = false,
        localised_name = localised_name,
        localised_description = {"", {"sosciencity-util.unlock-condition"}, "\n [img=tooltip-category-debug] ", {"sosciencity-util.acquisition", localised_name}},
    }
end
