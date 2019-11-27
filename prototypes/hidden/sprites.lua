local sprites_to_create = {"empty", "clockwork", "ember", "gunfire", "gleam", "foundry", "orchid", "aurora", "plasma"}

for _, name in pairs(sprites_to_create) do
    Prototype.create {
        type = "sprite",
        name = name .. "-caste",
        width = 256,
        height = 256,
        layers = {
            {
                filename = "__core__/graphics/entity-info-dark-background.png",
                size = 53,
                scale = 64. / 53.
            },
            {
                filename = "__sosciencity__/graphics/" .. name .. "-caste.png",
                size = 256,
                scale = 0.25
            }
        }
    }
end
