local multiplier_table = {}
local slots_multiplier_table = {}
for _, quality in pairs(data.raw["quality"] or {}) do
    multiplier_table[quality.name] = 1
    slots_multiplier_table[quality.name] = 0
end

for entity_name in pairs(Sosciencity_Config.buildings_needing_quality_multipliers) do
    local entity = Tirislib.Entity.get_by_name(entity_name)
    entity.crafting_speed_quality_multiplier = Tirislib.Tables.copy(multiplier_table)
    entity.energy_usage_quality_multiplier = Tirislib.Tables.copy(multiplier_table)
    entity.module_slots_quality_bonus  = Tirislib.Tables.copy(slots_multiplier_table)
end
