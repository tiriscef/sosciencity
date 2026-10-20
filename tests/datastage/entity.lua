local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_entity(name, fields)
    local proto = {
        type = "assembling-machine",
        name = name,
        icon = "__base__/graphics/icons/assembling-machine-1.png",
        icon_size = 64,
        max_health = 100,
        collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
        selection_box = {{-1, -1}, {1, 1}},
        crafting_categories = {"crafting"},
        crafting_speed = 1,
        energy_source = {type = "void"},
        energy_usage = "1W"
    }
    if fields then
        for k, v in pairs(fields) do
            proto[k] = v
        end
    end
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Entity.create(proto)
end

local function create_test_item(name)
    local proto = {type = "item", name = name, stack_size = 50, subgroup = "raw-material", order = "a"}
    created_prototypes[#created_prototypes + 1] = proto
    Tirislib.Prototype.create(proto)
end

local function teardown()
    for _, proto in pairs(created_prototypes) do
        if data.raw[proto.type] then
            data.raw[proto.type][proto.name] = nil
        end
    end
    created_prototypes = {}
end

---------------------------------------------------------------------------------------------------
-- << Entity.create and Entity.get >>

Tirislib.Testing.add_test_case(
    "Entity.create adds an entity to data.raw",
    "lib.entity",
    function()
        create_test_entity("test-ent-create")

        local entity, found = Tirislib.Entity.get_by_name("test-ent-create")
        Assert.is_true(found)
        Assert.equals(entity.name, "test-ent-create")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity.get returns dummy for nonexistent entity",
    "lib.entity",
    function()
        local entity, found = Tirislib.Entity.get_by_name("nonexistent-entity-xyz")
        Assert.is_false(found)
        Assert.is_true(Tirislib.Prototype.is_dummy(entity))
    end
)

---------------------------------------------------------------------------------------------------
-- << size helpers >>

Tirislib.Testing.add_test_case(
    "Entity.get_selection_box creates correct box",
    "lib.entity",
    function()
        local box = Tirislib.Entity.get_selection_box(2, 3)
        Assert.equals(box, {{-1, -1.5}, {1, 1.5}})
    end
)

Tirislib.Testing.add_test_case(
    "Entity.get_collision_box creates box with margin",
    "lib.entity",
    function()
        local box = Tirislib.Entity.get_collision_box(2, 2)
        Assert.equals(box, {{-0.75, -0.75}, {0.75, 0.75}})
    end
)

Tirislib.Testing.add_test_case(
    "Entity:set_size sets both selection and collision box",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-size")
        entity:set_size(3, 3)

        Assert.equals(entity.selection_box, {{-1.5, -1.5}, {1.5, 1.5}})
        Assert.equals(entity.collision_box, {{-1.25, -1.25}, {1.25, 1.25}})
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << crafting categories >>

Tirislib.Testing.add_test_case(
    "Entity:add_crafting_category adds a new category",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-cat", {crafting_categories = {"crafting"}})
        entity:add_crafting_category("smelting")

        Assert.is_true(entity:has_crafting_category("crafting"))
        Assert.is_true(entity:has_crafting_category("smelting"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:add_crafting_category does not duplicate",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-cat-dup", {crafting_categories = {"crafting"}})
        entity:add_crafting_category("crafting")

        local count = 0
        for _ in pairs(entity.crafting_categories) do
            count = count + 1
        end
        Assert.equals(count, 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:has_crafting_category returns false for missing category",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-cat-miss", {crafting_categories = {"crafting"}})
        Assert.is_false(entity:has_crafting_category("smelting"))
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << loot >>

Tirislib.Testing.add_test_case(
    "Entity:add_loot adds a loot entry",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-loot")
        entity:add_loot({name = "iron-plate", independent_probability = 1, amount_min = 1, amount_max = 2})

        Assert.equals(#entity.loot, 1)
        Assert.equals(entity.loot[1].name, "iron-plate")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:add_loot merges matching loot entries",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-loot-merge")
        entity:add_loot({name = "iron-plate", independent_probability = 1, amount_min = 1, amount_max = 2})
        entity:add_loot({name = "iron-plate", independent_probability = 1, amount_min = 3, amount_max = 4})

        Assert.equals(#entity.loot, 1)
        Assert.equals(entity.loot[1].amount_min, 4)
        Assert.equals(entity.loot[1].amount_max, 6)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:add_loot does not merge entries with different probability",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-loot-diff")
        entity:add_loot({name = "iron-plate", independent_probability = 1, amount_min = 1, amount_max = 1})
        entity:add_loot({name = "iron-plate", independent_probability = 0.5, amount_min = 1, amount_max = 1})

        Assert.equals(#entity.loot, 2)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:add_loot does not merge entries differing in quality",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-loot-quality")
        entity:add_loot({name = "iron-plate", independent_probability = 1, amount_min = 1, amount_max = 1})
        entity:add_loot({name = "iron-plate", independent_probability = 1, amount_min = 1, amount_max = 1, quality_min = "uncommon"})

        Assert.equals(#entity.loot, 2)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << mining results >>

Tirislib.Testing.add_test_case(
    "Entity:add_mining_result converts single result to results table",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-mine", {minable = {result = "iron-ore", mining_time = 1}})
        entity:add_mining_result({type = "item", name = "stone", amount = 1})

        Assert.is_nil(entity.minable.result)
        Assert.equals(#entity.minable.results, 2)
        Assert.equals(entity.minable.results[1].name, "iron-ore")
        Assert.equals(entity.minable.results[2].name, "stone")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:add_mining_result silently does nothing without minable",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-mine-none")
        -- should not error
        entity:add_mining_result({type = "item", name = "stone", amount = 1})
        Assert.pass()
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << localisation >>

Tirislib.Testing.add_test_case(
    "Entity:get_localised_name returns explicit name when set",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-loc", {localised_name = {"custom-entity"}})

        Assert.equals(entity:get_localised_name(), {"custom-entity"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Entity:get_localised_name falls back to entity-name key",
    "lib.entity",
    function()
        local entity = create_test_entity("test-ent-loc-default")

        Assert.equals(entity:get_localised_name(), {"entity-name.test-ent-loc-default"})
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << copy_icon_from_item >>

Tirislib.Testing.add_test_case(
    "Entity:copy_icon_from_item copies icon from specified item",
    "lib.entity",
    function()
        create_test_item("test-ent-icon-item")
        local item = Tirislib.Item.get_by_name("test-ent-icon-item")
        item.icon = "custom-icon.png"
        item.icon_size = 128

        local entity = create_test_entity("test-ent-icon-copy")
        entity:copy_icon_from_item("test-ent-icon-item")

        Assert.equals(entity.icon, "custom-icon.png")
        Assert.equals(entity.icon_size, 128)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << create_animation_from_sprite_data >>

local function sprite_data_sheet(name)
    return {
        width = 30,
        height = 20,
        shift = {0.5, -0.25},
        line_length = 4,
        lines_per_file = 2,
        filenames = {"__test__/" .. name .. ".png"}
    }
end

Tirislib.Testing.add_test_case(
    "Entity.create_animation_from_sprite_data creates one layer per map in drawing order",
    "lib.entity",
    function()
        local animation = Tirislib.Entity.create_animation_from_sprite_data {
            frame_count = 8,
            maps = {
                glow = sprite_data_sheet("glow"),
                diffuse = sprite_data_sheet("diffuse"),
                shadowmap = sprite_data_sheet("shadowmap")
            }
        }

        local layers = animation.layers
        Assert.equals(#layers, 3)
        Assert.equals(layers[1].filenames, {"__test__/diffuse.png"})
        Assert.equals(layers[2].filenames, {"__test__/shadowmap.png"})
        Assert.is_true(layers[2].draw_as_shadow)
        Assert.equals(layers[3].filenames, {"__test__/glow.png"})
        Assert.is_true(layers[3].draw_as_glow)
        Assert.is_nil(layers[1].draw_as_shadow)
        Assert.is_nil(layers[1].draw_as_glow)
    end
)

Tirislib.Testing.add_test_case(
    "Entity.create_animation_from_sprite_data copies frame data to every layer and sheet data per map",
    "lib.entity",
    function()
        local shadow = sprite_data_sheet("shadowmap")
        shadow.width = 50
        shadow.shift = {1, 2}
        local animation = Tirislib.Entity.create_animation_from_sprite_data {
            frame_count = 3,
            animation_speed = 20 / 60,
            frame_sequence = {1, 2, 2, 3},
            maps = {diffuse = sprite_data_sheet("diffuse"), shadowmap = shadow}
        }

        for _, layer in pairs(animation.layers) do
            Assert.equals(layer.frame_count, 3)
            Assert.equals(layer.animation_speed, 20 / 60)
            Assert.equals(layer.frame_sequence, {1, 2, 2, 3})
            Assert.equals(layer.line_length, 4)
            Assert.equals(layer.lines_per_file, 2)
            Assert.equals(layer.scale, 0.5)
        end
        Assert.equals(animation.layers[1].width, 30)
        Assert.equals(animation.layers[1].shift, {0.5, -0.25})
        Assert.equals(animation.layers[2].width, 50)
        Assert.equals(animation.layers[2].shift, {1, 2})
    end
)

Tirislib.Testing.add_test_case(
    "Entity.create_animation_from_sprite_data makes a single frame without frame data",
    "lib.entity",
    function()
        local static = sprite_data_sheet("static")
        static.line_length = nil
        static.lines_per_file = nil
        local animation = Tirislib.Entity.create_animation_from_sprite_data {maps = {diffuse = static}}

        local layer = animation.layers[1]
        Assert.equals(layer.frame_count, 1)
        Assert.equals(layer.lines_per_file, 1)
        Assert.is_nil(layer.frame_sequence)
        Assert.is_nil(layer.animation_speed)
    end
)
