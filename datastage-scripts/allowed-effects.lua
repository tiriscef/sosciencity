for _, entity in Tirislib.Entity.iterate {"assembling-machine", "mining-drill", "rocket-silo", "furnace"} do
    if entity.allowed_effects then
        if not Tirislib.Tables.contains(entity.allowed_effects, "speed") then
            table.insert(entity.allowed_effects, "speed")
        end
    end
end
