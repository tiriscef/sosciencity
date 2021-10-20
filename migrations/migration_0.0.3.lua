local WarningType = require("enums.warning-type")

for _, warning_type in pairs(WarningType) do
    if not global.warnings[warning_type] then
        global.warnings[warning_type] = {
            last_warning_tick = 0
        }
    end
end
