local InformationType = require("enums.information-type")
local WarningType = require("enums.warning-type")
local Time = require("constants.time")

global.information_ticks = {}
for _, information_type in pairs(InformationType) do
    global.information_ticks[information_type] = -Time.nauvis_month
end
global.information_params = {}

global.warning_ticks = {}
for _, warning_type in pairs(WarningType) do
    global.warning_ticks[warning_type] = -Time.nauvis_month
end
global.warning_params = {}

global.warnings = nil
