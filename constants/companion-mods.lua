--- Which companion mods are active. Works in every stage: the data stage has the `mods` table,
--- the control stage `script.active_mods`.
--- Control-stage code reads these through DevMode, constants (loaded in both stages) read them here.
local active_mods = mods or script.active_mods

local CompanionMods = {}

--- Whether sosciencity-debug (test commands, test prototypes, debug features) is active.
CompanionMods.debug = active_mods["sosciencity-debug"] ~= nil

--- Whether sosciencity-balancing (balancing and analysis commands) is active.
CompanionMods.balancing = active_mods["sosciencity-balancing"] ~= nil

return CompanionMods
