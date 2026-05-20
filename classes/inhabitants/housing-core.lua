local Castes = require("constants.castes")
local EK = require("enums.entry-key")
local Housing = require("constants.housing")

Inhabitants.HousingCore = {}
local HousingCore = Inhabitants.HousingCore

local castes = Castes.values
local houses = Housing.values

--- @param entry Entry
--- @return HouseDefinition
function HousingCore.get(entry)
    return houses[entry[EK.name]]
end

--- @param entry Entry
--- @return integer
function HousingCore.get_capacity(entry)
    local housing_details = HousingCore.get(entry)
    local room_count = housing_details.room_count
    if housing_details.one_room_per_inhabitant then
        return room_count
    else
        return math.floor(room_count / castes[entry[EK.type]].required_room_count)
    end
end

--- @param entry Entry
--- @return integer
function HousingCore.get_free_capacity(entry)
    return HousingCore.get_capacity(entry) - entry[EK.inhabitants]
end

--- @param house HouseDefinition
--- @param caste_id integer
--- @return boolean
function HousingCore.allowes_caste(house, caste_id)
    return house.room_count >= castes[caste_id].required_room_count
end
