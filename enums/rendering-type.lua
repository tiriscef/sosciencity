--- Enum table for common entity rendering additions
--- @enum RenderingType
local RenderingType = {}

RenderingType.altmode_sprite = 1
RenderingType.food_warning= 2
RenderingType.water_warning = 3
RenderingType.no_workers = 4
RenderingType.breakdown_warning = 5
RenderingType.recipe_visualisation = 6
RenderingType.recipe_visualisation_glow = 7
RenderingType.recipe_visualisation_light = 8
RenderingType.strike_warning = 9
RenderingType.full_strike_warning = 10
-- map markers of the warnings above
RenderingType.food_warning_map = 11
RenderingType.water_warning_map = 12
RenderingType.no_workers_map = 13
RenderingType.breakdown_warning_map = 14
RenderingType.strike_warning_map = 15
RenderingType.full_strike_warning_map = 16

return RenderingType
