require("lib.prototypes")

require("prototypes.item-groups")

local enabled_concepts = {
    "misc.science-ingredients",
    --
    -- technologies
    --[["technology.clockwork-caste",
    "technology.ember-caste",
    "technology.gunfire-caste",
    "technology.gleam-caste",
    "technology.foundry-caste",
    "technology.orchid-caste",
    "technology.aurora-caste",]]
    --
    -- buildings
    "building.clockwork-housing",
    "building.ember-housing",
    "building.gunfire-housing",
    "building.gleam-housing",
    "building.foundry-housing",
    "building.orchid-housing",
    "building.aurora-housing",
    "building.club",
}

for _, concept in pairs(enabled_concepts) do
    try_load("prototypes." .. concept)
end

Prototype:finish_postponed()
