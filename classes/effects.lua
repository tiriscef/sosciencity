local EK = require("enums.entry-key")

--- Static class that applies sosciencity's effect bonuses to entities.
Effects = {}

--[[
    Data this class stores in storage
    --------------------------------
    nothing
]]
--
-- LuaEntity::local_effect is a single field that every mod shares. There is no way to tell whose
-- contribution is whose, so we never overwrite it: we remember what we wrote last, treat everything
-- else as somebody else's and add our new contribution on top of that.
--
-- The engine keeps four decimals and rounds to them, so every value we write is rounded the same way.
-- That keeps our bookkeeping identical to what a read gives back and stops the repeated
-- read-modify-write from drifting.

local floor = math.floor

--- All the fields of the Effect type, so every one of them can be influenced.
local EFFECT_NAMES = {"speed", "productivity", "consumption", "pollution", "quality"}

--- Rounds to the four decimals the engine stores.
--- @param value number
--- @return number
local function round(value)
    return floor(value * 10000 + 0.5) / 10000
end

--- Sets sosciencity's contribution to this entity's effects, leaving the contributions of other
--- mods untouched. Values are percentages, so 50 means +50%. Effects that aren't given count as
--- zero, so this always replaces our whole previous contribution.
--- @param entry Entry
--- @param effects table<string, number> bonus percentages, keyed like the engine's Effect type
function Effects.set(entry, effects)
    local written = entry[EK.written_effect]

    -- our new contribution, in the values the engine actually stores
    local ours = {}
    local has_contribution = false
    local changed = false

    for _, name in pairs(EFFECT_NAMES) do
        local value = round((effects[name] or 0) / 100)

        if value ~= 0 then
            ours[name] = value
            has_contribution = true
        end
        changed = changed or value ~= (written and written[name] or 0)
    end

    -- our contribution is additive, so an unchanged one means the entity already carries exactly
    -- what we want it to - no matter what other mods did to it in the meantime
    if not changed then
        return
    end

    local entity = entry[EK.entity]
    local current = entity.local_effect

    -- entities without an effect receiver can't be influenced at all
    if not current then
        return
    end

    for _, name in pairs(EFFECT_NAMES) do
        -- both our old contribution and the new one are rounded, so subtracting ours from the
        -- entity's value gives back exactly what the other mods contributed
        current[name] = round((current[name] or 0) - (written and written[name] or 0) + (ours[name] or 0))
    end

    -- assigning replaces the whole effect, so this has to be the table we read above
    entity.local_effect = current

    entry[EK.written_effect] = has_contribution and ours or nil
end

--- Takes sosciencity's contribution back out of this entity's effects.
--- @param entry Entry
function Effects.clear(entry)
    local written = entry[EK.written_effect]
    if not written then
        return
    end

    entry[EK.written_effect] = nil

    local entity = entry[EK.entity]
    -- when the entity is gone its effects are gone with it
    if not entity.valid then
        return
    end

    local current = entity.local_effect
    if not current then
        return
    end

    for name, value in pairs(written) do
        current[name] = round((current[name] or 0) - value)
    end
    entity.local_effect = current
end

return Effects
