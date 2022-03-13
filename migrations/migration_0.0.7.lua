local EK = require("enums.entry-key")
local Type = require("enums.type")

Register.load()

for _, water_distributer in Register.all_of_type(Type.water_distributer) do
    if water_distributer[EK.name] == "water-tower" then
        water_distributer[EK.power_usage] = nil
    end
end

for _, entry in pairs(global.register) do
    if entry[EK.name] == "house8" then
        entry[EK.name] = "big-living-container"
    end
end
