require("__stdlib__/stdlib/data/data").Util.create_data_globals()
table = require("__stdlib__/stdlib/utils/table")

function try_load(file)
    local ok, err = pcall(require, file)
    if not ok and not err:find('^module .* not found') then
        error(err)
    end
end

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

for _, concept in pairs(enabled_concepts) do
    try_load("prototypes." .. concept .. "-recipes")
end
