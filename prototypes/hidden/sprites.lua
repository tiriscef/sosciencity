local sprites_to_create = {
    "empty",
    "clockwork",
    "ember",
    "gunfire",
    "gleam",
    "foundry",
    "orchid",
    "aurora",
    "plasma"
}

for _, name in pairs(sprites_to_create) do
    Tirislib.Prototype.create {
        type = "sprite",
        name = name .. "-caste",
        width = 256,
        height = 256,
        layers = {
            {
                filename = "__core__/graphics/entity-info-dark-background.png",
                size = 53,
                scale = 1.5 * 64. / 53.
            },
            {
                filename = "__sosciencity-graphics__/graphics/" .. name .. "-caste.png",
                size = 256,
                scale = 0.25
            }
        }
    }
end

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-left-top",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-left-top.png",
    size = 64,
    scale = 0.5,
    shift = {0.4, 0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-left-top-big",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-left-top-big.png",
    size = 64,
    scale = 0.5,
    shift = {0.4, 0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-right-top",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-right-top.png",
    size = 64,
    scale = 0.5,
    shift = {-0.4, 0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-right-top-big",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-right-top-big.png",
    size = 64,
    scale = 0.5,
    shift = {-0.4, 0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-left-bottom",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-left-bottom.png",
    size = 64,
    scale = 0.5,
    shift = {0.4, -0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-left-bottom-big",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-left-bottom-big.png",
    size = 64,
    scale = 0.5,
    shift = {0.4, -0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-right-bottom",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-right-bottom.png",
    size = 64,
    scale = 0.5,
    shift = {-0.4, -0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "highlight-right-bottom-big",
    filename = "__sosciencity-graphics__/graphics/utility/highlight-right-bottom-big.png",
    size = 64,
    scale = 0.5,
    shift = {-0.4, -0.4}
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "sosciencity-people",
    filename = "__sosciencity-graphics__/graphics/utility/people.png",
    size = 64
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "sosciencity-happiness",
    filename = "__sosciencity-graphics__/graphics/utility/happiness.png",
    size = 64
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "sosciencity-health",
    filename = "__sosciencity-graphics__/graphics/utility/health.png",
    size = 64
}

Tirislib.Prototype.create {
    type = "sprite",
    name = "sosciencity-sanity",
    filename = "__sosciencity-graphics__/graphics/utility/sanity.png",
    size = 64
}
