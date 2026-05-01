Tirislib.ItemGroups.create {
    name = "sosciencity-infrastructure",
    order = "za",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    subgroups = {
        "sosciencity-infrastructure",
        "sosciencity-housing",
        "sosciencity-comfort-upgrade-info",
        "sosciencity-trait-upgrade-info",
        "sosciencity-inhabitants",
        "sosciencity-education-buildings",
        "sosciencity-education-recipes",
        "sosciencity-hqs",
        "sosciencity-buildings",
        "sosciencity-flora-buildings",
        "sosciencity-fauna-buildings",
        "sosciencity-microorganism-buildings",
        "sosciencity-food-buildings",
        "sosciencity-production-buildings",
        "sosciencity-water-buildings"
    }
}

Tirislib.ItemGroups.create {
    name = "sosciencity-production",
    order = "za",
    icon = "__sosciencity-graphics__/graphics/icon/production-group.png",
    icon_size = 128,
    subgroups = {
        "sosciencity-materials",
        "sosciencity-building-materials",
        "sosciencity-furniture",
        "sosciencity-art-materials",
        "sosciencity-biology-materials",
        "sosciencity-laboratory-materials",
        "sosciencity-data",
        "sosciencity-fluid-materials",
        "sosciencity-ideas-by-hand",
        "sosciencity-ember-studies",
        "sosciencity-orchid-studies",
        "sosciencity-clockwork-studies",
        "sosciencity-foundry-studies",
        "sosciencity-gleam-studies",
        "sosciencity-gunfire-studies",
        "sosciencity-medicine",
        "sosciencity-consumable-medicine",
        "sosciencity-drinking-water",
        "sosciencity-garbage"
    }
}

Tirislib.ItemGroups.create {
    name = "sosciencity-agriculture",
    order = "zb",
    icon = "__sosciencity-graphics__/graphics/technology/open-environment-farming.png",
    icon_size = 128,
    subgroups = {
        "sosciencity-gathering",
        "sosciencity-microorganisms",
        "sosciencity-growth-media",
        "sosciencity-microorganism-products",
        "sosciencity-flora",
        "sosciencity-flora-perennial",
        "sosciencity-saplings",
        "sosciencity-flora-bloomhouse",
        "sosciencity-algae",
        "sosciencity-mushrooms",
        "sosciencity-fauna",
        "sosciencity-slaughter",
        "sosciencity-animal-food",
        "sosciencity-neogenesis-recipes",
        "sosciencity-food",
        "sosciencity-beverages"
    }
}

-- subgroups in vanilla groups
Tirislib.Prototype.batch_create {
    {
        type = "item-subgroup",
        name = "sosciencity-population",
        group = "signals",
        order = "aaa"
    },
    {
        type = "item-subgroup",
        name = "sosciencity-alerts",
        group = "signals",
        order = "aba"
    }
}
