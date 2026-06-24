-- Prototype-shape regression guard.
-- Serializes the final shape of every prototype so a behaviour-preserving change can be verified with a plain diff.

if not mods["sosciencity-balancing"] then
    return
end

local dump = serpent.block(data.raw, {sortkeys = true, comment = false, nocode = true})

-- Log the dump between markers.
log("---SOSCIENCITY-SHAPE-START---\n" .. dump .. "\n---SOSCIENCITY-SHAPE-END---")
