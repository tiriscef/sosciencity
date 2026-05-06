--- Enum table for move causes - why inhabitants are being added to a house.
--- Used to look up per-cause moving downtime in InhabitantsConstants.
--- @enum MoveCause
local MoveCause = {}

--- Distribution after an immigration wave
MoveCause.immigration = 1
--- Distribution after hatching in an upbringing station
MoveCause.upbringing = 2
--- Moving due to the 'pull' GUI button
MoveCause.pull = 3
--- Moving due to the 'push' GUI button
MoveCause.push = 4
--- Moving to a new house after joining another caste
MoveCause.caste_conversion = 5
--- Redistribution with the passive redistribution feature
MoveCause.passive_redistribution = 6
--- Redistribution after cure in a sanatorium
MoveCause.sanatorium_eviction = 7
--- Redistribution after the current house was destroyed
MoveCause.house_destroyed = 8
--- copy / debug operations, no move semantics
MoveCause.copy = 9

return MoveCause
