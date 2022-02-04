-- destroy the city info guy, which makes the GUI class recreate it in its new form
for _, player in pairs(game.players) do
    player.gui.top["sosciencity-city-info"].destroy()
end

local TypeGroup = require("constants.type-groups")
local Housing = require("constants.housing")

if not global.housing_capacity then
    Register.load()

    global.housing_capacity = {}
    for _, caste_id in pairs(TypeGroup.all_castes) do
        global.housing_capacity[caste_id] = {[true] = 0, [false] = 0}

        for _, house in Register.all_of_type(caste_id) do
            local improvised = Housing.get(house).is_improvised
            global.housing_capacity[caste_id][improvised] =
                global.housing_capacity[caste_id][improvised] + Housing.get_capacity(house)
        end
    end
end
