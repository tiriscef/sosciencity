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
        name = "sosciencity-penalty-module",
        order = "aaa",
        setting_type = "runtime-global",
        default_value = true
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
        maximum_value = 2000,
        minimum_value = 20
    }
}
