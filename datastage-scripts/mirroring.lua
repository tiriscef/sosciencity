-- Factorio's use_mirroring defaults to false, so crafting machines can't be flipped unless they opt in.
-- Sosciencity flips the default: every crafting machine with fluid boxes can be mirrored (the others gain nothing from it).
-- A building opts out by setting use_mirroring = false in its own prototype, e.g. if its sprite looks wrong when flipped.

for _, entity in Tirislib.Entity.iterate({"assembling-machine", "furnace"}) do
    if entity.owner == "sosciencity" and entity.fluid_boxes and entity.use_mirroring == nil then
        entity.use_mirroring = true
    end
end
