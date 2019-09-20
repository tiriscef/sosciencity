data:extend {
    {
        type = "bool-setting",
        name = "sosciencity-penalty-module",
        order = "aaa",
        setting_type = "startup", 
        default_value = true
    },
    {
        type = "int-setting",
        name = "sosciencity-entity-updates-per-cycle",
        order = "zaa",
        setting_type = "startup", 
        default_value = 50,
        maximum_value = 2000,
        minimum_value = 20
    },
    {
        type = "int-setting",
        name = "sosciencity-entity-update-cycle-frequency",
        order = "zab",
        setting_type = "startup", 
        default_value = 10,
        maximum_value = 120,
        minimum_value = 1
    }
}
