local EK = require("enums.entry-key")
local Type = require("enums.type")

local set_beacon_effects = Subentities.set_beacon_effects

local create_active_machine_status = Entity.create_active_machine_status
local update_active_machine_status = Entity.update_active_machine_status
local remove_active_machine_status = Entity.remove_active_machine_status

Register.set_entity_creation_handler(Type.assembling_machine, create_active_machine_status)
Register.set_entity_creation_handler(Type.furnace, create_active_machine_status)
Register.set_entity_creation_handler(Type.mining_drill, create_active_machine_status)
Register.set_entity_creation_handler(Type.rocket_silo, create_active_machine_status)

local function update_machine(entry)
    local clockwork_bonus = Entity.caste_bonuses[Type.clockwork]
    local penalty_module_needed = (clockwork_bonus < 0)

    entry[EK.entity].consumption_modifier = penalty_module_needed and (1 + clockwork_bonus / 100) or 1

    if penalty_module_needed then
        clockwork_bonus = clockwork_bonus + 80
    end

    set_beacon_effects(entry, clockwork_bonus, 0, penalty_module_needed)
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.assembling_machine, update_machine)
Register.set_entity_updater(Type.furnace, update_machine)
Register.set_entity_updater(Type.mining_drill, update_machine)

local function update_rocket_silo(entry)
    local clockwork_bonus = Entity.caste_bonuses[Type.clockwork]
    local use_penalty_module = (clockwork_bonus < 0)

    entry[EK.entity].consumption_modifier = use_penalty_module and (1 + clockwork_bonus / 100) or 1

    if use_penalty_module then
        clockwork_bonus = clockwork_bonus + 80
    end

    set_beacon_effects(entry, clockwork_bonus, Entity.caste_bonuses[Type.aurora], use_penalty_module)
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.rocket_silo, update_rocket_silo)

Register.set_entity_destruction_handler(Type.assembling_machine, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.furnace, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.mining_drill, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.rocket_silo, remove_active_machine_status)
