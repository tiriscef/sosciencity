for _, entity in Tirislib.Entity.iterate {"assembling-machine", "mining-drill", "rocket-silo", "furnace"} do
    entity.allowed_effects = entity.allowed_effects or {"speed", "productivity"}
end
