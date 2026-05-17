local Time = require("constants.time")

--- Physical unit multipliers. Multiply a human-readable quantity by the appropriate
--- constant to get Factorio's internal representation.
local Unit = {}

-- Power (J/tick, Factorio's internal energy unit)
Unit.W  = 1 / Time.second
Unit.kW = 1000 / Time.second
Unit.MW = 1000000 / Time.second

-- Rates (per-tick)
Unit.per_second = 1 / Time.second
Unit.per_minute = 1 / Time.minute
Unit.per_hour   = 1 / Time.hour

return Unit
