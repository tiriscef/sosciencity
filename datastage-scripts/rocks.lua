if not settings.startup["sosciencity-modify-environment"].value then
    return
end

for _, entity in Tirislib.Entity.iterate("simple-entity") do
    if string.match(entity.name, "rock") then
        entity:add_mining_result {
            type = "item",
            name = "wild-fungi",
            independent_probability = 0.5,
            amount_min = 1,
            amount_max = 3
        }
        entity:add_mining_result {
            type = "item",
            name = "insect-meat",
            independent_probability = 0.3,
            amount_min = 1,
            amount_max = 2
        }
    end
end
