if not settings.startup["sosciencity-modify-environment"].value then
    return
end

for _, entity in Tirislib.Entity.iterate("simple-entity") do
    if string.match(entity.name, "rock") then
        entity:add_mining_result {
            name = "birdsnake",
            probability = 0.5,
            amount_min = 1,
            amount_max = 5
        }
    end
end
