-- Huwans live on Nauvis only (0concept/huwans.md, "Where huwans live").
-- City buildings and farms require this surface property (datastage-scripts/huwan-habitat.lua). Every surface that
-- doesn't set it - space platforms, other planets, script-made surfaces - gets the default 0.
-- A future habitat (like Aurora on space platforms) opts in by setting it to 1.

Tirislib.Prototype.create {
    type = "surface-property",
    name = "huwan-habitat",
    default_value = 0
}

local nauvis = data.raw["planet"]["nauvis"]
if nauvis then
    nauvis.surface_properties = nauvis.surface_properties or {}
    nauvis.surface_properties["huwan-habitat"] = 1
end
