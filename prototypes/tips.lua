Tirislib.Prototype.batch_create {
    {
        type = "tips-and-tricks-item-category",
        name = "sosciencity-tips",
        order = "az"
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-intro",
        category = "sosciencity-tips",
        order = "a",
        starting_status = "suggested",
        is_title = true
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-caste-boni",
        category = "sosciencity-tips",
        indent = 1,
        order = "b",
        dependencies = {"sosciencity-intro"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-maintenance",
        category = "sosciencity-tips",
        indent = 1,
        order = "c",
        dependencies = {"sosciencity-intro"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-first-settlement",
        category = "sosciencity-tips",
        indent = 1,
        is_title = true,
        order = "d",
        trigger = {
            type = "research",
            technology = "clockwork-caste"
        }
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-reproduction",
        category = "sosciencity-tips",
        indent = 2,
        order = "e",
        dependencies = {"sosciencity-first-settlement"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-housing",
        category = "sosciencity-tips",
        indent = 1,
        order = "f",
        dependencies = {"sosciencity-reproduction"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-food-supply",
        category = "sosciencity-tips",
        indent = 1,
        order = "g",
        dependencies = {"sosciencity-reproduction"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-water-supply",
        category = "sosciencity-tips",
        indent = 1,
        order = "h",
        dependencies = {"sosciencity-reproduction"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-garbage-collection",
        category = "sosciencity-tips",
        indent = 1,
        order = "i",
        dependencies = {"sosciencity-reproduction"}
    },
    {
        type = "tips-and-tricks-item",
        name = "sosciencity-healthcare",
        category = "sosciencity-tips",
        indent = 1,
        order = "j",
        dependencies = {"sosciencity-reproduction"}
    }
}
