--<< find all turrets and add them to the hidden gunfire techs >>
local gunfire_techs = {}
for i = 0, 20 do
    local strength = 2 ^ i

    table.insert(gunfire_techs, {strength = strength, prototype = Technology.get_by_name(i .. "-gunfire-caste")})
end

local turret_types = require("lib.prototype-types.turret-types")

local function add_turret_to_gunfire(turret)
    for _, gunfire_tech in pairs(gunfire_techs) do
        gunfire_tech.prototype:add_effect {
            type = "turret-attack",
            modifier = gunfire_tech.strength,
            turret_id = turret.name
        }
    end
end

for _, turret_type in pairs(turret_types) do
    for _, turret in pairs(data.raw[turret_type]) do
        -- try to filter worms, because they are also turrets
        if turret.subgroup ~= "enemies" and not string.find(turret.name, "worm") then
            add_turret_to_gunfire(turret)
        end
    end
end
