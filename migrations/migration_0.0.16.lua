local InformationType = require("enums.information-type")
local WarningType = require("enums.warning-type")
local Time = require("constants.time")
local EK = require("enums.entry-key")
local Unlocks = require("constants.unlocks")

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

local tech_renames = {
    ["clockwork-caste-effectivity"] = "clockwork-caste-efficiency",
    ["orchid-caste-effectivity"] = "orchid-caste-efficiency",
    ["gunfire-caste-effectivity"] = "gunfire-caste-efficiency",
    ["plasma-caste-effectivity"] = "plasma-caste-efficiency",
    ["ember-caste-effectivity"] = "ember-caste-efficiency",
    ["foundry-caste-effectivity"] = "foundry-caste-efficiency",
    ["gleam-caste-effectivity"] = "gleam-caste-efficiency",
    ["aurora-caste-effectivity"] = "aurora-caste-efficiency"
}

for old_name, new_name in pairs(tech_renames) do
    global.technologies[new_name] = global.technologies[old_name]
    global.technologies[old_name] = nil
end

for _, entry in pairs(global.register) do
    if entry[EK.name] == "microalgae-farm" then
        entry[EK.name] = "algae-farm"
    end
end

if not global.gated_technologies then
    global.gated_technologies = {}
    for tech_name in pairs(Unlocks.gated_technologies) do
        global.gated_technologies[tech_name] = false
    end
end
