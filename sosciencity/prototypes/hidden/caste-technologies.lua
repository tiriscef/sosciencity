for i = 0, 20 do
    local strength = 2 ^ i

    Technology:create {
        type = "technology",
        name = strength .. "-gleam-caste",
        icon = "__sosciencity__/graphics/icon/empty.png",
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
            }
        },
        enabled = false,
        visible_when_disabled = false,
        hidden = true,
        upgrade = false,
        prerequisites = {}
    }

    Technology:create {
        type = "technology",
        name = strength .. "-foundry-caste",
        icon = "__sosciencity__/graphics/icon/empty.png",
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
            }
        },
        enabled = false,
        visible_when_disabled = false,
        hidden = true,
        upgrade = false,
        prerequisites = {}
    }

    Technology:create {
        type = "technology",
        name = strength .. "-gunfire-caste",
        icon = "__sosciencity__/graphics/icon/empty.png",
        icon_size = 1,
        effects = {}, -- will be filled in data-final-fixes
        unit = {
            count = 1,
            time = 1,
            ingredients = {
                {"automation-science-pack", 1}
            }
        },
        enabled = false,
        visible_when_disabled = false,
        hidden = true,
        upgrade = false,
        prerequisites = {}
    }
end
