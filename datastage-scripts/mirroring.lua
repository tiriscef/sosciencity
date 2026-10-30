-- Crafting machines can only be flipped if they opt in. Only fluid boxes change when an entity is mirrored,
-- so it's pointless for the others.

for _, entity in Tirislib.Entity.iterate({"assembling-machine", "furnace"}) do
    if entity.owner == "sosciencity" and entity.fluid_boxes then
        entity.use_mirroring = true
    end
end
