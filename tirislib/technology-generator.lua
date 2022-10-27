--- Generator for generic technologies with configurable ingredients to facilitate integration/compatibility with other mods.
Tirislib.TechnologyGenerator = {}

-- (tier, 'science pack' item name)-pairs
local tier_science_packs = {
    [0] = "automation-science-pack",
    [2] = "logistic-science-pack",
    [3] = "chemical-science-pack",
    [4] = "production-science-pack",
    [5] = "utility-science-pack",
    [6] = "space-science-pack"
}

function Tirislib.TechnologyGenerator.set_tier_science_packs(tiers)
    Tirislib.Tables.set_fields(tier_science_packs, tiers)
end

local labeled_science_packs = {
    ["military"] = "military-science-pack"
}

function Tirislib.TechnologyGenerator.set_labeled_science_packs(labels)
    Tirislib.Tables.set_fields(labeled_science_packs, labels)
end

--- Creates an ingredients table for a technology.\
--- **tier:** int\
--- **[any string]:** labeled science packs to add\
--- **tiers_to_ommit:** table of ints
--- @param details table
--- @return array
function Tirislib.TechnologyGenerator.create_ingredients(details)
    local packs = {}

    if details.tier then
        for tier, science_pack in pairs(tier_science_packs) do
            if tier <= details.tier then
                packs[science_pack] = true
            end
        end
    end

    if details.tiers_to_ommit then
        for _, tier in pairs(details.tiers_to_ommit) do
            if tier_science_packs[tier] then
                packs[tier_science_packs[tier]] = nil
            end
        end
    end

    for _, label in pairs(details) do
        if labeled_science_packs[label] then
            packs[labeled_science_packs[label]] = true
        end
    end

    local ret = {}

    for science_pack in pairs(packs) do
        ret[#ret + 1] = {science_pack, 1}
    end

    return ret
end