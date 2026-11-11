--- Enum table for destruction causes
--- @enum DeconstructionCause
local DeconstructionCause = {}

DeconstructionCause.unknown = 0
DeconstructionCause.mined = 1
DeconstructionCause.destroyed = 2
DeconstructionCause.type_change = 3
DeconstructionCause.mod_update = 4
--- the surface or chunk got deleted or cleared - by a mod or the map editor, so the intent is unknown
DeconstructionCause.surface_removed = 5

return DeconstructionCause
