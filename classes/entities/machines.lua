local EK = require("enums.entry-key")
local Type = require("enums.type")

local set_effects = Effects.set

local create_active_machine_status = Entity.create_active_machine_status
local update_active_machine_status = Entity.update_active_machine_status
local remove_active_machine_status = Entity.remove_active_machine_status
local get_breakdown_state = Entity.get_breakdown_state
local set_breakdown_state = Entity.set_breakdown_state
local set_active = Entity.set_active
local is_externally_owned = Register.is_externally_owned
local max = math.max

Register.set_entity_creation_handler(Type.assembling_machine, create_active_machine_status)
Register.set_entity_creation_handler(Type.furnace, create_active_machine_status)
Register.set_entity_creation_handler(Type.mining_drill, create_active_machine_status)
Register.set_entity_creation_handler(Type.rocket_silo, create_active_machine_status)

local function update_machine(entry)
    local clockwork_bonus = Entity.caste_bonuses[Type.clockwork]
    set_effects(entry, {speed = max(0, clockwork_bonus)})

    if not is_externally_owned(entry) then
        set_breakdown_state(entry, get_breakdown_state(entry))
    end

    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.assembling_machine, update_machine)
Register.set_entity_updater(Type.furnace, update_machine)
Register.set_entity_updater(Type.mining_drill, update_machine)

local function update_rocket_silo(entry)
    -- unlike the other machines the silo also takes the clockwork malus, and the aurora bonus
    -- (the aurora caste is disabled, so it has no bonus entry at all)
    set_effects(
        entry,
        {speed = Entity.caste_bonuses[Type.clockwork], productivity = Entity.caste_bonuses[Type.aurora]}
    )
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.rocket_silo, update_rocket_silo)

Register.set_entity_destruction_handler(Type.assembling_machine, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.furnace, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.mining_drill, remove_active_machine_status)
Register.set_entity_destruction_handler(Type.rocket_silo, remove_active_machine_status)
