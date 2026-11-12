-- City buildings and farms can only be placed where huwans live (see prototypes/huwan-habitat.lua).
-- Surface conditions require the space_travel feature flag - without it, the game refuses to load prototypes that
-- have them. Without Space Age there is only Nauvis anyway.
-- Buildings that already stand on other surfaces stay and keep working, only new placement is blocked.
-- Scripts' create_entity ignores surface conditions.

local Types = require("constants.types")

if not feature_flags["space_travel"] then
    return
end

local habitat_condition = {property = "huwan-habitat", min = 1}

for _, entity in Tirislib.Entity.iterate() do
    if Tirislib.Prototype.get_owner(entity) == "sosciencity" and Types.needs_huwan_habitat(entity.name) then
        entity.surface_conditions = entity.surface_conditions or {}
        table.insert(entity.surface_conditions, habitat_condition)
    end
end
