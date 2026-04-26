local Time = require("constants.time")

local InhabitantsConstants = {}

--- Ticks a treatable disease must go unclaimed before the house becomes transport-eligible.
InhabitantsConstants.transport_eligibility_threshold = 5 * Time.minute

return InhabitantsConstants
