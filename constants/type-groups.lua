local Type = require("enums.type")

TypeGroup = {}

TypeGroup.all_castes = {
    Type.clockwork,
    Type.orchid,
    Type.gunfire,
    Type.ember,
    Type.foundry,
    Type.gleam,
    Type.aurora,
    Type.plasma
}

TypeGroup.breedable_castes = {
    Type.clockwork,
    Type.orchid,
    Type.gunfire,
    Type.ember,
    Type.foundry,
    Type.gleam,
    Type.plasma
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
