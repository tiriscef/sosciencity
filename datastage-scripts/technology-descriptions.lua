local UnlockCondition = require("enums.unlock-condition")

local Castes = require("constants.castes")
local Unlocks = require("constants.unlocks")

local condition_fns = {
    [UnlockCondition.caste_points] = function(condition)
        return {"sosciencity-util.having-points", tostring(condition.count), Castes.values[condition.caste].localised_name_short}
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

    Tirislib.Locales.append(technology:get_localised_description(), unpack(localised_conditions))
end
