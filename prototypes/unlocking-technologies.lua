local Unlocks = require("constants.unlocks")

local mine_entity_triggers = {
    ["boofish"] = "fishwhirl",
    ["fupper"] = "fishwhirl",
}

for tech_name, item_name in pairs(Unlocks.by_item_acquisition) do
    local item = Tirislib.Item.get_by_name(item_name)
    local localised_name = item:get_localised_name()

    local research_trigger
    if mine_entity_triggers[item_name] then
        research_trigger = {type = "mine-entity", entity = mine_entity_triggers[item_name]}
    else
        research_trigger = {type = "craft-item", item = item_name, count = 1}
    end

    Tirislib.Technology.create {
        name = tech_name,
        icon = Tirislib.String.insert(item.icon, "-hr", -5),
        icon_size = 128,
        effects = {},
        research_trigger = research_trigger,
        upgrade = false,
        localised_name = localised_name,
        localised_description = {"", {"sosciencity-util.unlock-condition"}, "\n [img=tooltip-category-debug] ", {"sosciencity-util.acquisition", localised_name}},
    }
end
