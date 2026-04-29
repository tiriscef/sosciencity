local Type = require("enums.type")

--- Defines groups for the entity update cycle.
--- Each group receives a slice of the total updates_per_cycle budget (rounded up).
--- Assign bulk/high-count types to the low group to prevent them from diluting
--- the update frequency of lower-count types.
local UpdateGroup = {}

UpdateGroup.high = 1
UpdateGroup.low  = 2

UpdateGroup.definitions = {
    [UpdateGroup.high] = {slice_percent = 0.60},
    [UpdateGroup.low]  = {slice_percent = 0.40},
}

--- Ordered list - entity_update_cycle iterates this array.
UpdateGroup.all = Tirislib.Tables.get_keyset(UpdateGroup.definitions)

UpdateGroup.default = UpdateGroup.high

--- Types explicitly assigned to a non-default group.
--- Omitted types use UpdateGroup.default.
UpdateGroup.type_assignment = {
    [Type.assembling_machine] = UpdateGroup.low,
    [Type.furnace]            = UpdateGroup.low,
    [Type.rocket_silo]        = UpdateGroup.low,
    [Type.mining_drill]       = UpdateGroup.low,
    [Type.turret]             = UpdateGroup.low,
    [Type.lab]                = UpdateGroup.low,
}

return UpdateGroup
