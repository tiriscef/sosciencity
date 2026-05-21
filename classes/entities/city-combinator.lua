local EK = require("enums.entry-key")
local Type = require("enums.type")

local population_signals = {
    ["signal-ember"] = Type.ember,
    ["signal-orchid"] = Type.orchid,
    ["signal-clockwork"] = Type.clockwork,
    ["signal-gunfire"] = Type.gunfire,
    ["signal-foundry"] = Type.foundry,
    ["signal-gleam"] = Type.gleam,
    ["signal-plasma"] = Type.plasma
}

local function update_city_combinator(entry)
    local control_behavior = entry[EK.entity].get_control_behavior()

    for _, section in pairs(control_behavior.sections) do
        -- section.filters is a sparse Lua table keyed by slot index, not a dense array.
        -- LogisticFilter has no index field; the pairs() key is the slot index for set_slot.
        for slot_index, signal in pairs(section.filters) do
            local caste = signal.value and population_signals[signal.value.name]
            if caste then
                signal.min = storage.population[caste]
                signal.max = storage.population[caste]
                section.set_slot(slot_index, signal)
            end
        end
    end
end
Register.set_entity_updater(Type.city_combinator, update_city_combinator)
