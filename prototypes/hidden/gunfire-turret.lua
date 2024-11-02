local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")

-- basically the vanilla gunturret
-- priorities are adjusted to extra-high to ensure that it's rendered above the gunfire HQ
-- the base foundation thingy is left out so it looks like it belongs ontop of the gunfire HQ

local function gun_turret_extension(inputs)
    return {
        filename = "__base__/graphics/entity/gun-turret/gun-turret-raising.png",
        priority = "extra-high",
        width = 130,
        height = 126,
        direction_count = 4,
        frame_count = inputs.frame_count or 5,
        line_length = inputs.line_length or 0,
        run_mode = inputs.run_mode or "forward",
        shift = util.by_pixel(0, -26.5),
        scale = 0.5
    }
end

local function gun_turret_extension_mask(inputs)
    return {
        filename = "__base__/graphics/entity/gun-turret/gun-turret-raising-mask.png",
        priority = "extra-high",
        flags = {"mask"},
        width = 48,
        height = 62,
        direction_count = 4,
        frame_count = inputs.frame_count or 5,
        line_length = inputs.line_length or 0,
        run_mode = inputs.run_mode or "forward",
        shift = util.by_pixel(0, -28),
        apply_runtime_tint = true,
        scale = 0.5
    }
end

local function gun_turret_attack(inputs)
    return {
        layers = {
            {
                width = 132,
                height = 130,
                frame_count = inputs.frame_count or 2,
                direction_count = 64,
                shift = util.by_pixel(0, -27.5),
                stripes = {
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-1.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-2.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-3.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-4.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                scale = 0.5
            },
            {
                flags = {"mask"},
                line_length = inputs.frame_count or 2,
                width = 58,
                height = 54,
                frame_count = inputs.frame_count or 2,
                direction_count = 64,
                shift = util.by_pixel(0, -32.5),
                apply_runtime_tint = true,
                stripes = {
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-1.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-2.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-3.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-4.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                scale = 0.5
            },
            {
                width = 250,
                height = 124,
                frame_count = inputs.frame_count or 2,
                direction_count = 64,
                shift = util.by_pixel(22, 2.5),
                draw_as_shadow = true,
                stripes = {
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-1.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-2.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-3.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-4.png",
                        width_in_frames = inputs.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                scale = 0.5
            }
        }
    }
end

Tirislib.Entity.create {
    type = "turret",
    name = "gunfire-hq-turret",
    icon = "__base__/graphics/icons/gun-turret.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    selection_box = {{-1, -0.5}, {1, 0.5}},
    damaged_trigger_effect = hit_effects.entity(),
    rotation_speed = 0.015,
    preparing_speed = 0.08,
    preparing_sound = sounds.gun_turret_activate,
    folding_sound = sounds.gun_turret_deactivate,
    folding_speed = 0.08,
    automated_ammo_count = 10,
    attacking_speed = 0.5,
    alert_when_attacking = true,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    graphics_set = {
        base_visualisation = {
            animation = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-base.png",
                        priority = "high",
                        width = 150,
                        height = 118,
                        shift = util.by_pixel(0.5, -1),
                        scale = 0.5
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-base-mask.png",
                        flags = {"mask", "low-object"},
                        line_length = 1,
                        width = 122,
                        height = 102,
                        shift = util.by_pixel(0, -4.5),
                        apply_runtime_tint = true,
                        scale = 0.5
                    }
                }
            }
        }
    },
    folded_animation = {
        layers = {
            gun_turret_extension {frame_count = 1, line_length = 1},
            gun_turret_extension_mask {frame_count = 1, line_length = 1}
        }
    },
    preparing_animation = {
        layers = {
            gun_turret_extension {},
            gun_turret_extension_mask {}
        }
    },
    prepared_animation = gun_turret_attack {frame_count = 1},
    attacking_animation = gun_turret_attack {},
    folding_animation = {
        layers = {
            gun_turret_extension {run_mode = "backward"},
            gun_turret_extension_mask {run_mode = "backward"}
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    attack_parameters = {
        type = "projectile",
        ammo_category = "bullet",
        cooldown = 20,
        projectile_creation_distance = 1.39375,
        projectile_center = {0, -0.0875},
        shell_particle = {
            name = "shell-particle",
            direction_deviation = 0.1,
            speed = 0.1,
            speed_deviation = 0.03,
            center = {-0.0625, 0},
            creation_distance = -1.925,
            starting_frame_speed = 0.2,
            starting_frame_speed_deviation = 0.1
        },
        range = 18,
        sound = sounds.gun_turret_gunshot,
        ammo_type = {
            category = "bullet",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    source_effects = {
                        type = "create-explosion",
                        entity_name = "explosion-gunshot"
                    },
                    target_effects = {
                        {
                            type = "create-entity",
                            entity_name = "explosion-hit",
                            offsets = {{0, 1}},
                            offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}
                        },
                        {
                            type = "damage",
                            damage = {amount = 40, type = "physical"}
                        }
                    }
                }
            }
        }
    },
    call_for_help_radius = 40,
    water_reflection = {
        pictures = {
            filename = "__base__/graphics/entity/gun-turret/gun-turret-reflection.png",
            priority = "extra-high",
            width = 20,
            height = 32,
            shift = util.by_pixel(0, 40),
            variation_count = 1,
            scale = 5
        },
        rotate = false,
        orientation_to_variation = false
    },
    base_picture_render_layer = "higher-object-under",
    gun_animation_render_layer = "higher-object-under"
}
