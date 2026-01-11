local UnlockCondition = require("enums.unlock-condition")

local Castes = require("constants.castes")
local Unlocks = require("constants.unlocks")

local condition_fns = {
    [UnlockCondition.item_acquisition] = function(condition)
        local item = Tirislib.Item.get_by_name(condition.item)

        return {"sosciencity-util.acquisition", item:get_localised_name()}
    end,
    [UnlockCondition.caste_points] = function(condition)
        return {"sosciencity-util.having-points", tostring(condition.count), Castes.values[condition.caste].localised_name_short}
    end,
    [UnlockCondition.caste_population] = function (condition)
        return {"sosciencity-util.caste-population", tostring(condition.count), Castes.values[condition.caste].localised_name_short}
    end,
    [UnlockCondition.population] = function(condition)
        return {"sosciencity-util.population", tostring(condition.count)}
    end
}

for tech_name, conditions in pairs(Unlocks.gated_technologies) do
    local technology = Tirislib.Technology.get_by_name(tech_name)

    local localised_conditions = {
        "\n\n",
        {"sosciencity-util.enable-condition"}
    }

    for _, condition in pairs(conditions) do
        localised_conditions[#localised_conditions+1] = "\n [img=tooltip-category-debug] "
        localised_conditions[#localised_conditions+1] = condition_fns[condition.type](condition)
    end

    Tirislib.Locales.append(technology:get_localised_description(), table.unpack(localised_conditions))
end
