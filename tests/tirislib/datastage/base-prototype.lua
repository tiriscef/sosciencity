local Assert = Tirislib.Testing.Assert

---------------------------------------------------------------------------------------------------
-- << convert_to_icons_table >>

Tirislib.Testing.add_test_case(
    "BasePrototype:convert_to_icons_table converts icon to icons array",
    "lib.base-prototype",
    function()
        local proto = {icon = "path/icon.png", icon_size = 64}
        Tirislib.BasePrototype.convert_to_icons_table(proto)

        Assert.is_nil(proto.icon)
        Assert.is_nil(proto.icon_size)
        Assert.equals(#proto.icons, 1)
        Assert.equals(proto.icons[1].icon, "path/icon.png")
        Assert.equals(proto.icons[1].icon_size, 64)
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:convert_to_icons_table preserves existing icons table",
    "lib.base-prototype",
    function()
        local existing = {{icon = "a.png", icon_size = 32}}
        local proto = {icons = existing}
        Tirislib.BasePrototype.convert_to_icons_table(proto)

        Assert.equals(proto.icons, existing)
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:convert_to_icons_table preserves draw_background and floating",
    "lib.base-prototype",
    function()
        local proto = {icon = "path/icon.png", icon_size = 64, icon_draw_background = true, icon_floating = true}
        Tirislib.BasePrototype.convert_to_icons_table(proto)

        Assert.equals(proto.icons[1].draw_background, true)
        Assert.equals(proto.icons[1].floating, true)
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:convert_to_icons_table handles no icon",
    "lib.base-prototype",
    function()
        local proto = {}
        Tirislib.BasePrototype.convert_to_icons_table(proto)

        Assert.equals(#proto.icons, 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << add_icon_layer >>

Tirislib.Testing.add_test_case(
    "BasePrototype:add_icon_layer adds a layer with defaults",
    "lib.base-prototype",
    function()
        local proto = {icon = "base.png", icon_size = 64}
        Tirislib.BasePrototype.add_icon_layer(proto, "overlay.png")

        Assert.equals(#proto.icons, 2)
        local layer = proto.icons[2]
        Assert.equals(layer.icon, "overlay.png")
        Assert.equals(layer.icon_size, 64)
        Assert.equals(layer.scale, 0.3)
        Assert.is_nil(layer.shift)
        Assert.is_nil(layer.tint)
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:add_icon_layer resolves named shifts",
    "lib.base-prototype",
    function()
        local proto = {icons = {{icon = "base.png", icon_size = 64}}}
        Tirislib.BasePrototype.add_icon_layer(proto, "overlay.png", "topright")

        Assert.equals(proto.icons[2].shift, {8, -8})
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:add_icon_layer accepts custom icon_size",
    "lib.base-prototype",
    function()
        local proto = {icons = {{icon = "base.png", icon_size = 64}}}
        Tirislib.BasePrototype.add_icon_layer(proto, "overlay.png", nil, nil, nil, 128)

        Assert.equals(proto.icons[2].icon_size, 128)
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:add_icon_layer returns self for chaining",
    "lib.base-prototype",
    function()
        local proto = {icons = {{icon = "base.png", icon_size = 64}}}
        local ret = Tirislib.BasePrototype.add_icon_layer(proto, "a.png")

        Assert.equals(ret, proto)
    end
)

---------------------------------------------------------------------------------------------------
-- << add_custom_tooltip >>

Tirislib.Testing.add_test_case(
    "BasePrototype:add_custom_tooltip adds tooltip fields",
    "lib.base-prototype",
    function()
        local proto = {}
        Tirislib.BasePrototype.add_custom_tooltip(proto, {type = "test", value = "hello"})

        Assert.equals(#proto.custom_tooltip_fields, 1)
        Assert.equals(proto.custom_tooltip_fields[1].type, "test")
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:add_custom_tooltip appends to existing fields",
    "lib.base-prototype",
    function()
        local proto = {custom_tooltip_fields = {{type = "first"}}}
        Tirislib.BasePrototype.add_custom_tooltip(proto, {type = "second"})

        Assert.equals(#proto.custom_tooltip_fields, 2)
    end
)

Tirislib.Testing.add_test_case(
    "BasePrototype:add_custom_tooltip returns self for chaining",
    "lib.base-prototype",
    function()
        local proto = {}
        local ret = Tirislib.BasePrototype.add_custom_tooltip(proto, {type = "x"})

        Assert.equals(ret, proto)
    end
)
