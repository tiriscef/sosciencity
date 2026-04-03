local Assert = Tirislib.Testing.Assert
local Locales = Tirislib.Locales

---------------------------------------------------------------------------------------------------
-- << shorten_enumeration >>

Tirislib.Testing.add_test_case(
    "shorten_enumeration does nothing for tables within the limit",
    "lib.locales",
    function()
        local tbl = {""}
        for i = 1, 19 do
            tbl[#tbl + 1] = "e" .. i
        end
        local original_size = #tbl
        Locales.shorten_enumeration(tbl)
        Assert.equals(#tbl, original_size)
    end
)

Tirislib.Testing.add_test_case(
    "shorten_enumeration splits a large table into subtables of at most 20 elements",
    "lib.locales",
    function()
        local tbl = {""}
        for i = 1, 25 do
            tbl[#tbl + 1] = "e" .. i
        end

        Locales.shorten_enumeration(tbl)

        -- outer table should now be within the limit
        Assert.is_true(#tbl <= 20)
        -- first subtable should have all 20 of the first elements
        Assert.equals(#tbl[2], 21) -- {"" + 20 elements}
        -- second subtable should have the remaining 5
        Assert.equals(#tbl[3], 6) -- {"" + 5 elements}
    end
)

Tirislib.Testing.add_test_case(
    "shorten_enumeration handles a table that requires more than one level of splitting",
    "lib.locales",
    function()
        local tbl = {""}
        for i = 1, 400 do
            tbl[#tbl + 1] = "e" .. i
        end

        Locales.shorten_enumeration(tbl)

        Assert.is_true(#tbl <= 20)
    end
)

---------------------------------------------------------------------------------------------------
-- << create_enumeration >>

Tirislib.Testing.add_test_case(
    "create_enumeration returns an empty string for an empty input",
    "lib.locales",
    function()
        Assert.equals(Locales.create_enumeration({}), "")
    end
)

Tirislib.Testing.add_test_case(
    "create_enumeration wraps a single element without a separator",
    "lib.locales",
    function()
        local result = Locales.create_enumeration({"apple"})
        Assert.equals(result, {"", "apple"})
    end
)

Tirislib.Testing.add_test_case(
    "create_enumeration joins two elements with the last_separator",
    "lib.locales",
    function()
        local result = Locales.create_enumeration({"apple", "banana"}, ", ", " and ")
        Assert.equals(result, {"", "apple", " and ", "banana"})
    end
)

Tirislib.Testing.add_test_case(
    "create_enumeration joins three elements with separator and last_separator",
    "lib.locales",
    function()
        local result = Locales.create_enumeration({"apple", "banana", "cherry"}, ", ", " and ")
        Assert.equals(result, {"", "apple", ", ", "banana", " and ", "cherry"})
    end
)

Tirislib.Testing.add_test_case(
    "create_enumeration uses the default separator when none is given",
    "lib.locales",
    function()
        local result = Locales.create_enumeration({"a", "b"})
        Assert.equals(result, {"", "a", ", ", "b"})
    end
)

---------------------------------------------------------------------------------------------------
-- << display_time >>

Tirislib.Testing.add_test_case(
    "display_time shows only seconds for sub-minute tick counts",
    "lib.locales",
    function()
        Assert.equals(Locales.display_time(0), {"", {"sosciencity.xseconds", 0}})
        Assert.equals(Locales.display_time(60), {"", {"sosciencity.xseconds", 1}})
        Assert.equals(Locales.display_time(3540), {"", {"sosciencity.xseconds", 59}})
    end
)

Tirislib.Testing.add_test_case(
    "display_time shows only minutes when seconds are zero",
    "lib.locales",
    function()
        -- 60 seconds * 60 ticks = 3600 ticks = 1 minute exactly
        Assert.equals(Locales.display_time(3600), {"", {"sosciencity.xminutes", 1}})
    end
)

Tirislib.Testing.add_test_case(
    "display_time shows only hours when minutes and seconds are zero",
    "lib.locales",
    function()
        -- 3600 seconds * 60 ticks = 216000 ticks = 1 hour exactly
        Assert.equals(Locales.display_time(216000), {"", {"sosciencity.xhours", 1}})
    end
)

Tirislib.Testing.add_test_case(
    "display_time combines hours, minutes and seconds with separators",
    "lib.locales",
    function()
        -- 1h 1m 1s = (3600 + 60 + 1) * 60 = 219660 ticks
        local result = Locales.display_time(219660)
        Assert.equals(result, {
            "",
            {"sosciencity.xhours", 1},
            ", ",
            {"sosciencity.xminutes", 1},
            {"sosciencity.and"},
            {"sosciencity.xseconds", 1}
        })
    end
)

---------------------------------------------------------------------------------------------------
-- << display_ingame_time >>

Tirislib.Testing.add_test_case(
    "display_ingame_time returns less-than-a-day for small tick counts",
    "lib.locales",
    function()
        Assert.equals(Locales.display_ingame_time(0), {"", {"sosciencity.less-than-a-day"}})
        Assert.equals(Locales.display_ingame_time(24999), {"", {"sosciencity.less-than-a-day"}})
    end
)

Tirislib.Testing.add_test_case(
    "display_ingame_time shows days, weeks and months correctly",
    "lib.locales",
    function()
        -- 1 day = 25000 ticks
        Assert.equals(Locales.display_ingame_time(25000), {"", {"sosciencity.xdays", 1}})
        -- 1 week = 7 days = 175000 ticks
        Assert.equals(Locales.display_ingame_time(175000), {"", {"sosciencity.xweeks", 1}})
        -- 1 month = 4 weeks = 700000 ticks
        Assert.equals(Locales.display_ingame_time(700000), {"", {"sosciencity.xmonths", 1}})
    end
)

Tirislib.Testing.add_test_case(
    "display_ingame_time combines months, weeks and days with separators",
    "lib.locales",
    function()
        -- 1 month + 1 week + 1 day = (28 + 7 + 1) days = 36 days = 900000 ticks
        local result = Locales.display_ingame_time(900000)
        Assert.equals(result, {
            "",
            {"sosciencity.xmonths", 1},
            ", ",
            {"sosciencity.xweeks", 1},
            {"sosciencity.and"},
            {"sosciencity.xdays", 1}
        })
    end
)

---------------------------------------------------------------------------------------------------
-- << display_item_stack_datastage >>

Tirislib.Testing.add_test_case(
    "display_item_stack_datastage returns the correct locale structure",
    "lib.locales",
    function()
        local result = Locales.display_item_stack_datastage("iron-plate", 10)
        Assert.equals(result, {"sosciencity.xitems", "10", "iron-plate", {"item-name.iron-plate"}})
    end
)

Tirislib.Testing.add_test_case(
    "display_item_stack_datastage converts count to string",
    "lib.locales",
    function()
        local result = Locales.display_item_stack_datastage("iron-plate", 42)
        Assert.equals(type(result[2]), "string")
    end
)

---------------------------------------------------------------------------------------------------
-- << display_fluid_stack_datastage >>

Tirislib.Testing.add_test_case(
    "display_fluid_stack_datastage returns the correct locale structure",
    "lib.locales",
    function()
        local result = Locales.display_fluid_stack_datastage("water", 100)
        Assert.equals(result, {"sosciencity.xfluids", "100", "water", {"fluid-name.water"}})
    end
)

Tirislib.Testing.add_test_case(
    "display_fluid_stack_datastage converts count to string",
    "lib.locales",
    function()
        local result = Locales.display_fluid_stack_datastage("water", 50)
        Assert.equals(type(result[2]), "string")
    end
)

---------------------------------------------------------------------------------------------------
-- << display_percentage >>

Tirislib.Testing.add_test_case(
    "display_percentage rounds and formats as a percentage locale",
    "lib.locales",
    function()
        Assert.equals(Locales.display_percentage(0.5), {"sosciencity.percentage", "50"})
        Assert.equals(Locales.display_percentage(0), {"sosciencity.percentage", "0"})
        Assert.equals(Locales.display_percentage(1), {"sosciencity.percentage", "100"})
        -- 75.5% rounds away from zero to 76
        Assert.equals(Locales.display_percentage(0.755), {"sosciencity.percentage", "76"})
    end
)

---------------------------------------------------------------------------------------------------
-- << display_signed_number >>

Tirislib.Testing.add_test_case(
    "display_signed_number prefixes positive numbers with +",
    "lib.locales",
    function()
        Assert.equals(Locales.display_signed_number(5), "+5")
        Assert.equals(Locales.display_signed_number(100), "+100")
        Assert.equals(Locales.display_signed_number(1.5), "+1.5")
    end
)

Tirislib.Testing.add_test_case(
    "display_signed_number keeps the minus sign for negative numbers",
    "lib.locales",
    function()
        Assert.equals(Locales.display_signed_number(-3), "-3")
        Assert.equals(Locales.display_signed_number(-0.5), "-0.5")
    end
)

Tirislib.Testing.add_test_case(
    "display_signed_number treats zero as positive",
    "lib.locales",
    function()
        Assert.equals(Locales.display_signed_number(0), "+0")
    end
)

---------------------------------------------------------------------------------------------------
-- << append / prepend >>

Tirislib.Testing.add_test_case(
    "append adds elements to an existing concatenation locale",
    "lib.locales",
    function()
        local locale = {"", "a", "b"}
        Locales.append(locale, "c", "d")
        Assert.equals(locale, {"", "a", "b", "c", "d"})
    end
)

Tirislib.Testing.add_test_case(
    "append wraps a keyed locale before appending",
    "lib.locales",
    function()
        local locale = {"some.key", "arg"}
        Locales.append(locale, "extra")
        Assert.equals(locale[1], "")
        Assert.equals(locale[2], {"some.key", "arg"})
        Assert.equals(locale[3], "extra")
    end
)

Tirislib.Testing.add_test_case(
    "prepend adds elements before existing content",
    "lib.locales",
    function()
        local locale = {"", "c", "d"}
        Locales.prepend(locale, "a", "b")
        Assert.equals(locale, {"", "a", "b", "c", "d"})
    end
)

Tirislib.Testing.add_test_case(
    "prepend wraps a keyed locale before prepending",
    "lib.locales",
    function()
        local locale = {"some.key", "arg"}
        Locales.prepend(locale, "prefix")
        Assert.equals(locale[1], "")
        Assert.equals(locale[2], "prefix")
        Assert.equals(locale[3], {"some.key", "arg"})
    end
)
