local EK = require("enums.entry-key")
local SubentityType = require("enums.subentity-type")
local RenderingType = require("enums.rendering-type")
local DeconstructionCause = require("enums.deconstruction-cause")

local Buildings = require("constants.buildings")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

-- << sprites >>

Tirislib.Testing.add_test_case(
    "Alt-mode sprite is created on registration",
    "integration|integration.subentities",
    function()
        -- test-house has Type.empty_house, which has alt_mode_sprite = "empty-caste"
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        local renderings = entry[EK.attached_renderings]
        Assert.not_nil(renderings, "should have attached renderings")

        local altmode = renderings[RenderingType.altmode_sprite]
        Assert.not_nil(altmode, "should have an alt-mode sprite")
        Assert.is_true(altmode.valid, "alt-mode sprite should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Common sprite add and remove",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        Subentities.add_common_sprite(entry, RenderingType.food_warning)

        local renderings = entry[EK.attached_renderings]
        local food_sprite = renderings[RenderingType.food_warning]
        Assert.not_nil(food_sprite, "food warning sprite should exist")
        Assert.is_true(food_sprite.valid, "food warning sprite should be valid")

        Subentities.remove_common_sprite(entry, RenderingType.food_warning)
        Assert.is_nil(renderings[RenderingType.food_warning], "food warning sprite should be removed")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Adding the same common sprite twice does not create a duplicate",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        Subentities.add_common_sprite(entry, RenderingType.food_warning)
        local first = entry[EK.attached_renderings][RenderingType.food_warning]

        Subentities.add_common_sprite(entry, RenderingType.food_warning)
        local second = entry[EK.attached_renderings][RenderingType.food_warning]

        Assert.equals(first, second, "should be the same rendering object")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

-- << subentity lifecycle >>

Tirislib.Testing.add_test_case(
    "remove_all_for destroys subentities and sprites",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        local altmode_sprite = entry[EK.attached_renderings][RenderingType.altmode_sprite]
        Assert.is_true(altmode_sprite.valid, "sprite should be valid before removal")

        Register.remove_entry(entry, DeconstructionCause.unknown)

        Assert.is_false(altmode_sprite.valid, "sprite should be invalid after removal")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_or_create creates on first call, returns existing on second",
    "integration|integration.subentities",
    function()
        -- test-psych-ward has power_usage = 50 in its building definition, so it has an eei prototype
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})
        entry[EK.subentities][SubentityType.eei].destroy()

        local eei1, was_new1 = Subentities.get_or_create(entry, SubentityType.eei)
        Assert.not_nil(eei1, "should return a subentity")
        Assert.is_true(was_new1, "should be new on first call")
        Assert.is_true(eei1.valid, "eei should be valid")

        local eei2, was_new2 = Subentities.get_or_create(entry, SubentityType.eei)
        Assert.is_false(was_new2, "should not be new on second call")
        Assert.equals(eei1, eei2, "should return the same subentity")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

-- << EEI and power >>

Tirislib.Testing.add_test_case(
    "EEI is created for buildings with power_usage",
    "integration|integration.subentities",
    function()
        -- test-psych-ward has power_usage = 50 in its building definition
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        local subentities = entry[EK.subentities]
        Assert.not_nil(subentities, "should have subentities")

        local eei = subentities[SubentityType.eei]
        Assert.not_nil(eei, "should have an EEI subentity")
        Assert.is_true(eei.valid, "EEI should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "No EEI for buildings without power_usage",
    "integration|integration.subentities",
    function()
        -- test-market has no power_usage in its building definition
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        local subentities = entry[EK.subentities]
        Assert.is_nil(subentities and subentities[SubentityType.eei], "should not have an EEI subentity")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power returns true when no power_usage defined",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        Assert.is_true(Subentities.has_power(entry), "should return true when building needs no power")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "set_power_usage creates EEI on demand for buildings that didn't have one",
    "integration|integration.subentities",
    function()
        -- test-market has no power_usage, so no EEI is created on registration
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        -- dynamically give it a power requirement
        Subentities.set_power_usage(entry, 100)

        local eei = entry[EK.subentities][SubentityType.eei]
        Assert.not_nil(eei, "EEI should have been created")
        Assert.is_true(eei.valid, "EEI should be valid")
        Assert.equals(entry[EK.power_usage], 100, "entry should store the power usage")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "set_power_usage adjusts power on an existing EEI",
    "integration|integration.subentities",
    function()
        -- test-psych-ward starts with power_usage defined (50 kW, post-processed to J/tick)
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        local eei_before = entry[EK.subentities][SubentityType.eei]
        local initial_usage = entry[EK.power_usage]
        Assert.not_nil(initial_usage, "should have an initial power usage")

        -- adjust to a different value
        local new_usage = initial_usage * 2
        Subentities.set_power_usage(entry, new_usage)

        Assert.equals(entry[EK.power_usage], new_usage, "power usage should be updated")
        -- should reuse the same EEI, not create a new one
        local eei_after = entry[EK.subentities][SubentityType.eei]
        Assert.equals(eei_before, eei_after, "should reuse the same EEI entity")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power returns false when EEI has no energy",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- EEI starts with 0 energy (not connected to any power network)
        Assert.is_false(Subentities.has_power(entry), "should return false when EEI has no energy")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power returns true when EEI has energy",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- simulate power being available by filling the buffer
        local eei = entry[EK.subentities][SubentityType.eei]
        eei.energy = eei.electric_buffer_size

        Assert.is_true(Subentities.has_power(entry), "should return true when EEI has energy")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Disabling power usage makes has_power return true again",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- starts with power_usage = 50, no energy -> has_power is false
        Assert.is_false(Subentities.has_power(entry), "precondition: no power")

        -- disable power requirement by setting it to 0
        entry[EK.power_usage] = 0

        Assert.is_true(Subentities.has_power(entry),
            "should return true after power usage is disabled")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power recreates EEI if it was destroyed externally",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- destroy the EEI as if another mod deleted it
        local old_eei = entry[EK.subentities][SubentityType.eei]
        old_eei.destroy()

        -- has_power should recreate it and return true (safety fallback)
        Assert.is_true(Subentities.has_power(entry),
            "should return true when EEI had to be recreated")

        local new_eei = entry[EK.subentities][SubentityType.eei]
        Assert.not_nil(new_eei, "new EEI should exist")
        Assert.is_true(new_eei.valid, "new EEI should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

---------------------------------------------------------------------------------------------------
-- << recipe visualisation >>

local function get_recipe_visualisation(entry)
    return entry[EK.attached_renderings][RenderingType.recipe_visualisation]
end

local function expected_sprite(variant)
    return Buildings.get_recipe_visualisation_sprite("atelier", variant, "diffuse")
end

Tirislib.Testing.add_test_case(
    "Atelier shows the default recipe visualisation right after placement",
    "integration|integration.subentities|integration.recipe-visualisation",
    function()
        local atelier = Helpers.create_and_register(test_surface, "atelier", {0, 0})
        local default = Buildings.values["atelier"].recipe_visualisation.default

        local render = get_recipe_visualisation(atelier)
        Assert.is_true(render and render.valid, "the visualisation should exist right after placement")
        Assert.equals(render.sprite, expected_sprite(default))
        Assert.equals(render.target.entity, atelier[EK.entity], "it should be drawn on the atelier")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Atelier recipe visualisation follows the active recipe",
    "integration|integration.subentities|integration.recipe-visualisation",
    function()
        local atelier = Helpers.create_and_register(test_surface, "atelier", {0, 0})
        local entity = atelier[EK.entity]
        local visualisation = Buildings.values["atelier"].recipe_visualisation
        local render = get_recipe_visualisation(atelier)

        local function shown_sprite()
            Helpers.update_entry(atelier)
            return get_recipe_visualisation(atelier).sprite
        end

        for recipe, variant in pairs(visualisation.by_recipe) do
            entity.set_recipe(recipe)
            Assert.equals(shown_sprite(), expected_sprite(variant), "recipe " .. recipe)
        end
        Assert.equals(get_recipe_visualisation(atelier), render, "switching should reuse the render object")

        for name, recipe in pairs(prototypes.get_recipe_filtered {{filter = "category", category = "sosciencity-atelier"}}) do
            if not visualisation.by_recipe[name] then
                entity.set_recipe(recipe)
                Assert.equals(
                    shown_sprite(),
                    expected_sprite(visualisation.default),
                    "a recipe without its own variant (" .. name .. ") should show the default"
                )
                break
            end
        end

        entity.set_recipe(nil)
        Assert.equals(shown_sprite(), expected_sprite(visualisation.default), "no recipe should show the default")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Atelier recipe visualisation is redrawn when it got lost",
    "integration|integration.subentities|integration.recipe-visualisation",
    function()
        local atelier = Helpers.create_and_register(test_surface, "atelier", {0, 0})
        local recipe, variant = next(Buildings.values["atelier"].recipe_visualisation.by_recipe)
        atelier[EK.entity].set_recipe(recipe)

        get_recipe_visualisation(atelier).destroy()
        Helpers.update_entry(atelier)

        local render = get_recipe_visualisation(atelier)
        Assert.is_true(render and render.valid, "the visualisation should be redrawn")
        Assert.equals(render.sprite, expected_sprite(variant), "and show the active recipe")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Atelier recipe visualisation is removed with the atelier",
    "integration|integration.subentities|integration.recipe-visualisation",
    function()
        local atelier = Helpers.create_and_register(test_surface, "atelier", {0, 0})
        local renders = {}
        for _, render in pairs(atelier[EK.attached_renderings]) do
            renders[#renders + 1] = render
        end

        Helpers.destroy_entry(atelier)

        for _, render in pairs(renders) do
            Assert.is_false(render.valid, "every render object should be destroyed with the atelier")
        end
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
