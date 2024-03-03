if not settings.startup["sosciencity-modify-environment"].value then
    return
end

for _, entity in Tirislib.Entity.iterate("fish") do
    if string.match(entity.name, "fish") then
        entity:add_mining_result {
            name = "wild-algae",
            probability = 0.5,
            amount_min = 1,
            amount_max = 3
        }
    end
end
