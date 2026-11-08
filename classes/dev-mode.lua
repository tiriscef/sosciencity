--- Dev mode: whether the cheat and debug tools (the debug category of the city view, the debug tabs
--- of the details views) are available, and whether a save has ever used them.
---
--- Dev mode is active when the 'sosciencity-dev-mode' map setting is on or one of the companion mods
--- (sosciencity-debug, sosciencity-balancing) is active.

--[[
    Data this class stores in storage
    --------------------------------
    storage.dev_mode_first_activation: tick or nil
        when the map setting was first turned on in this save, nil if never
        the companion mods don't count, so opening a player's save with them doesn't mark it
]]
local DevMode = {}

local SETTING = "sosciencity-dev-mode"

local companion_mod_active =
    script.active_mods["sosciencity-debug"] ~= nil or script.active_mods["sosciencity-balancing"] ~= nil

--- Returns whether the cheat and debug tools are available.
--- @return boolean
function DevMode.is_active()
    return companion_mod_active or settings.global[SETTING].value
end

--- Records the first activation of the map setting. Call it on init and whenever the map settings change.
function DevMode.update_record()
    if storage.dev_mode_first_activation == nil and settings.global[SETTING].value then
        storage.dev_mode_first_activation = game.tick
    end
end

--- Returns the tick when the map setting was first turned on in this save, or nil if it never was.
--- @return integer?
function DevMode.get_first_activation()
    return storage.dev_mode_first_activation
end

--- Returns whether the given map setting change concerns dev mode.
--- @param event EventData.on_runtime_mod_setting_changed
--- @return boolean
function DevMode.is_setting_change(event)
    return event.setting == SETTING
end

return DevMode
