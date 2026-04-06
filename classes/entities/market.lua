local EK = require("enums.entry-key")
local Type = require("enums.type")

local Food = require("constants.food")

function Entity.market_has_food(entry)
    for _, item_stack in pairs(entry[EK.inventory_contents]) do
        if Food.values[item_stack.name] then
            return true
        end
    end
end

Register.set_entity_creation_handler(Type.market, Inventories.cache_contents)
Register.set_entity_updater(Type.market, Inventories.cache_contents)
