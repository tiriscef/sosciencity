local Type = require("enums.type")

local TypeGroup = {}

--- All the enabled castes.
TypeGroup.all_castes = {
    Type.ember,
    Type.orchid,
    Type.clockwork,
    Type.plasma,
    Type.gunfire,
    Type.foundry,
    Type.gleam
}

--- The castes that can be obtained by Upbringing Station.
TypeGroup.breedable_castes = {
    Type.ember,
    Type.orchid,
    Type.clockwork
}

TypeGroup.affected_by_clockwork = {
    Type.assembling_machine,
    Type.furnace,
    Type.rocket_silo,
    Type.mining_drill,
    Type.waterwell
}

TypeGroup.social_places = {
    Type.nightclub
}

TypeGroup.hospital_complements = {
    Type.pharmacy,
    Type.psych_ward,
    Type.intensive_care_unit
}

return TypeGroup
