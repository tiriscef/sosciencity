local Type = require("enums.type")

local TypeGroup = {}

TypeGroup.affected_by_clockwork = {
    Type.assembling_machine,
    Type.furnace,
    Type.rocket_silo,
    Type.mining_drill,
    Type.waterwell
}

TypeGroup.social_places = {
    Type.nightclub,
    Type.kitchen_for_all
}

TypeGroup.hospital_complements = {
    Type.pharmacy,
    Type.psych_ward,
    Type.intensive_care_unit
}

return TypeGroup
