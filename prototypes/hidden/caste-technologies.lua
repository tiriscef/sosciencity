for i = 0, 20 do
    local strength = 2 ^ i

    Tirislib.Technology.create {
        type = "technology",
        name = i .. "-gleam-caste",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        effects = {
            {
                type = "laboratory-productivity",
                modifier = 0.01 * strength
            }
        },
        unit = {
            count = 1,
            time = 1,
            ingredients = {
                {"automation-science-pack", 1}
                --{"sosciencity-research-blocker", 1} TODO: Look into possibilities to circumvent the "there is no lab that will accept all of the science packs this technology requires" error
            }
        },
        enabled = false,
        visible_when_disabled = false,
        hidden = true,
        upgrade = false,
        prerequisites = {},
        is_hack = true,
        localised_name = {"technology-name.hidden-technology"},
        localised_description = {"technology-description.hidden-technology"}
    }

    Tirislib.Technology.create {
        type = "technology",
        name = i .. "-foundry-caste",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        effects = {
            {
                type = "mining-drill-productivity-bonus",
                modifier = 0.01 * strength
            }
        },
        unit = {
            count = 1,
            time = 1,
            ingredients = {
                {"automation-science-pack", 1}
                --{"sosciencity-research-blocker", 1}
            }
        },
        enabled = false,
        visible_when_disabled = false,
        hidden = true,
        upgrade = false,
        prerequisites = {},
        is_hack = true,
        localised_name = {"technology-name.hidden-technology"},
        localised_description = {"technology-description.hidden-technology"}
    }

    Tirislib.Technology.create {
        type = "technology",
        name = i .. "-gunfire-caste",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        effects = {}, -- will be filled in data-updates
        unit = {
            count = 1,
            time = 1,
            ingredients = {
                {"automation-science-pack", 1}
                --{"sosciencity-research-blocker", 1}
            }
        },
        enabled = false,
        visible_when_disabled = false,
        hidden = true,
        upgrade = false,
        prerequisites = {},
        is_hack = true,
        localised_name = {"technology-name.hidden-technology"},
        localised_description = {"technology-description.hidden-technology"}
    }
end
