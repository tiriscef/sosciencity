local Type = require("enums.type")
local EK = require("enums.entry-key")

Register.load()

for _, hospital_type in pairs {Type.hospital, Type.improvised_hospital} do
    for _, hospital in Register.all_of_type(hospital_type) do
        hospital[EK.treatment_permissions] = {}
    end
end
