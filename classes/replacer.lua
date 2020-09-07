Replacer = {}

-- reasonable unique prefix so I don't try to replace entities from other mods
local PLACER_PREFIX = "sosciencity-placer-"
local prefix_length = PLACER_PREFIX:len()

function Replacer.replace(entity)
    local entity_name = entity.name

    if entity_name:sub(1, prefix_length) == PLACER_PREFIX then
        local replacement_name = entity_name:sub(prefix_length + 1)

        entity.surface.create_entity {
            name = replacement_name,
            position = entity.position,
            direction = entity.direction,
            force = entity.force,
            fast_replace = true,
            raise_built = true,
            create_build_effect_smoke = false
        }

        entity.destroy()

        return true
    else
        return false
    end
end

return Replacer
