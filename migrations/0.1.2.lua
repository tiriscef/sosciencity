local Type = require("enums.type")
local TypeGroup = require("constants.type-groups")
local EK = require("enums.entry-key")

require("classes.register")
Register.load()

global.technologies["transfusion-medicine"] = game.forces.player.technologies["transfusion-medicine"].researched

for _, _type in pairs {Type.hospital, Type.improvised_hospital} do
    for _, hospital in Register.all_of_type(_type) do
        hospital[EK.blood_donations] = 0
        hospital[EK.blood_donation_threshold] = 100
    end
end

for _, _type in pairs(TypeGroup.all_castes) do
    for _, hospital in Register.all_of_type(_type) do
        hospital[EK.blood_donation_progress] = 0.4 * math.random()
    end
end
