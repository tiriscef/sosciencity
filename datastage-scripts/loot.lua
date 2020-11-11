if not settings.startup["sosciencity-alien-loot"].value then
    return
end

--<< find all biter units and add alien meat as loot >>
-- there is no perfect way to detect all the poorly defined 'alien'-units
-- for now I will test the name, this should work for all the enemy adding mods I know of
-- checked: Rampant, Natural Evolution Enemies, Bobs Enemies, DyWorld, Big Monsters, Cold Biters, Explosive Biters
local function is_likely_an_alien(unit)
    return string.find(unit.name, "biter") or string.find(unit.name, "spitter") or string.find(unit.name, "worm")
end

-- Balancing heavy area
local function get_meat_amounts(unit)
    return 1, math.ceil(0.25 * unit.max_health ^ 0.4)
end

local PROBABILITY = 0.5

-- biters and spitters are units, worms are turrets
local types = {"unit", "turret"}

for _, prototype_type in pairs(types) do
    for _, unit in Tirislib_Entity.iterate(prototype_type) do
        if is_likely_an_alien(unit) then
            local count_min, count_max = get_meat_amounts(unit)

            unit:add_loot {
                item = "alien-meat",
                probability = PROBABILITY,
                count_min = count_min,
                count_max = count_max
            }
        end
    end
end
