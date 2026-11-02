local Unlocks = require("constants.unlocks")

for tech_name, details in pairs(Unlocks.by_item_acquisition) do
    local item_name = details.item
    local item = Tirislib.Item.get_by_name(item_name)
    local localised_name = item:get_localised_name()

    local research_trigger
    if details.mined_from then
        research_trigger = {type = "mine-entity", entities = {details.mined_from}}
    else
        research_trigger = {type = "craft-item", item = item_name, count = 1}
    end

    local icon, icon_size
    if details.no_hr_icon then
        icon, icon_size = item.icon, item.icon_size or 64
    else
        icon, icon_size = Tirislib.String.insert(item.icon, "-hr", -5), 128
    end

    Tirislib.Technology.create {
        name = tech_name,
        icon = icon,
        icon_size = icon_size,
        prerequisites = {details.prerequisite},
        effects = {},
        research_trigger = research_trigger,
        upgrade = false,
        localised_name = localised_name,
        localised_description = {"", {"sosciencity-util.unlock-condition"}, "\n [img=tooltip-category-debug] ", {"sosciencity-util.acquisition", localised_name}},
    }
end
