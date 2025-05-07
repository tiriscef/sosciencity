data:extend {
    {
        type = "bool-setting",
        name = "sosciencity-alien-loot",
        order = "aaa",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "sosciencity-modify-environment",
        order = "aab",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "sosciencity-agriculture-pollution",
        order = "aac",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "sosciencity-lumber-in-vanilla-recipes",
        order = "aad",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting", --- set to disable notes etc when setting toggled (deafult requires = yes), purely for larger modpacks like mine that makes factories absolutely massive -cyberKoi** (also added to mod name and mod description in prototype En)
        name = "sosciencity-remove-extra-science-ingredient",
        order = "aae",
        setting_type = "startup",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "sosciencity-penalty-module",
        order = "aaa",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "double-setting",
        name = "sosciencity-start-clockwork-points",
        order = "aab",
        setting_type = "runtime-global",
        default_value = 50
    },
    {
        type = "bool-setting",
        name = "sosciencity-allow-tiriscef",
        order = "baa",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "sosciencity-allow-profanity",
        order = "bab",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "int-setting",
        name = "sosciencity-entity-updates-per-cycle",
        order = "zaa",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 1
    }
}
