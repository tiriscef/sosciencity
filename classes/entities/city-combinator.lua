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
        for i = 1, 10 do
            local signal = section.get_slot(i)
            local value = signal.value
            if not value then
                goto continue
            end

            local name = value.name
            if not name then
                goto continue
            end

            local caste = population_signals[name]
            if caste then
                signal.min = storage.population[caste]
                signal.max = storage.population[caste]
                section.set_slot(i, signal)
            end

            ::continue::
        end
    end
end
Register.set_entity_updater(Type.city_combinator, update_city_combinator)
