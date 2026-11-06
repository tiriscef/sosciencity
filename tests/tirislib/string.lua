local Assert = Tirislib.Testing.Assert
local String = Tirislib.String

---------------------------------------------------------------------------------------------------
-- << begins_with >>

Tirislib.Testing.add_test_case(
    "begins_with returns true for a matching prefix",
    "lib.string",
    function()
        Assert.is_true(String.begins_with("hello world", "hello"))
        Assert.is_true(String.begins_with("hello", "hello"))
        Assert.is_true(String.begins_with("abc", ""))
    end
)

Tirislib.Testing.add_test_case(
    "begins_with returns false for a non-matching prefix",
    "lib.string",
    function()
        Assert.is_false(String.begins_with("hello world", "world"))
        Assert.is_false(String.begins_with("hello", "hello world"))
        Assert.is_false(String.begins_with("abc", "ABC"))
    end
)

---------------------------------------------------------------------------------------------------
-- << ends_with >>

Tirislib.Testing.add_test_case(
    "ends_with returns true for a matching suffix",
    "lib.string",
    function()
        Assert.is_true(String.ends_with("hello world", "world"))
        Assert.is_true(String.ends_with("hello", "hello"))
        Assert.is_true(String.ends_with("abc", ""))
    end
)

Tirislib.Testing.add_test_case(
    "ends_with returns false for a non-matching suffix",
    "lib.string",
    function()
        Assert.is_false(String.ends_with("hello world", "hello"))
        Assert.is_false(String.ends_with("hello", "hello world"))
        Assert.is_false(String.ends_with("abc", "ABC"))
    end
)

---------------------------------------------------------------------------------------------------
-- << contains >>

Tirislib.Testing.add_test_case(
    "contains returns true when the substring is present",
    "lib.string",
    function()
        Assert.is_true(String.contains("hello world", "world"))
        Assert.is_true(String.contains("hello world", "lo wo"))
        Assert.is_true(String.contains("hello", "hello"))
        Assert.is_true(String.contains("hello", ""))
    end
)

Tirislib.Testing.add_test_case(
    "contains returns false when the substring is absent",
    "lib.string",
    function()
        Assert.is_false(String.contains("hello world", "xyz"))
        Assert.is_false(String.contains("hello", "HELLO"))
    end
)

Tirislib.Testing.add_test_case(
    "contains treats the substring as a plain string, not a pattern",
    "lib.string",
    function()
        Assert.is_true(String.contains("price: $5.00", "$5.00"))
        Assert.is_false(String.contains("price 500", "$5.00"))
    end
)

---------------------------------------------------------------------------------------------------
-- << trim >>

Tirislib.Testing.add_test_case(
    "trim removes leading and trailing whitespace",
    "lib.string",
    function()
        Assert.equals(String.trim("  hello  "), "hello")
        Assert.equals(String.trim("\t hello \n"), "hello")
        Assert.equals(String.trim("hello"), "hello")
        Assert.equals(String.trim("   "), "")
        Assert.equals(String.trim(""), "")
    end
)

Tirislib.Testing.add_test_case(
    "trim does not remove internal whitespace",
    "lib.string",
    function()
        Assert.equals(String.trim("  hello world  "), "hello world")
    end
)

---------------------------------------------------------------------------------------------------
-- << replace >>

Tirislib.Testing.add_test_case(
    "replace substitutes all occurrences of a substring",
    "lib.string",
    function()
        Assert.equals(String.replace("aabbaa", "aa", "x"), "xbbx")
        Assert.equals(String.replace("hello world", "world", "Lua"), "hello Lua")
        Assert.equals(String.replace("aaa", "a", "bb"), "bbbbbb")
    end
)

Tirislib.Testing.add_test_case(
    "replace returns the original string when 'from' is not found",
    "lib.string",
    function()
        Assert.equals(String.replace("hello", "xyz", "!"), "hello")
    end
)

Tirislib.Testing.add_test_case(
    "replace returns the original string when 'from' is empty",
    "lib.string",
    function()
        Assert.equals(String.replace("hello", "", "x"), "hello")
    end
)

Tirislib.Testing.add_test_case(
    "replace treats both arguments as plain strings, not patterns",
    "lib.string",
    function()
        Assert.equals(String.replace("1+1=2", "+", "plus"), "1plus1=2")
        Assert.equals(String.replace("a.b.c", ".", "-"), "a-b-c")
        Assert.equals(String.replace("50%", "%", " percent"), "50 percent")
    end
)

---------------------------------------------------------------------------------------------------
-- << join >>

Tirislib.Testing.add_test_case(
    "join concats the contents of tables",
    "lib.string",
    function()
        Assert.equals(String.join(" ", "h", {"e", "l", "l", "o"}, " ", {{"wor", "ld"}, "!"}), "h e l l o   wor ld !")
    end
)

Tirislib.Testing.add_test_case(
    "join handles empty inputs and tables",
    "lib.string",
    function()
        Assert.equals(String.join(",", {}, "a", "b", {{}}), "a,b")
        Assert.equals(String.join(","), "")
        Assert.equals(String.join(",", {}), "")
        Assert.equals(String.join(",", {"a"}), "a")
    end
)

---------------------------------------------------------------------------------------------------
-- << split >>

Tirislib.Testing.add_test_case(
    "split splits a string on a single-character separator",
    "lib.string",
    function()
        Assert.equals(String.split("a|b|c", "|"), {"a", "b", "c"})
        Assert.equals(String.split("1.2.3", "."), {"1", "2", "3"})
    end
)

Tirislib.Testing.add_test_case(
    "split splits a string on a multi-character separator",
    "lib.string",
    function()
        Assert.equals(String.split("a||b||c", "||"), {"a", "b", "c"})
        Assert.equals(String.split("oneXXtwoXXthree", "XX"), {"one", "two", "three"})
    end
)

Tirislib.Testing.add_test_case(
    "split skips empty parts from consecutive separators",
    "lib.string",
    function()
        Assert.equals(String.split("a||b", "|"), {"a", "b"})
        Assert.equals(String.split("|a|", "|"), {"a"})
    end
)

Tirislib.Testing.add_test_case(
    "split treats the separator as a plain string, not a pattern",
    "lib.string",
    function()
        Assert.equals(String.split("a.b.c", "."), {"a", "b", "c"})
        Assert.equals(String.split("a+b+c", "+"), {"a", "b", "c"})
    end
)

Tirislib.Testing.add_test_case(
    "split returns a single-element table when separator is absent",
    "lib.string",
    function()
        Assert.equals(String.split("hello", "|"), {"hello"})
    end
)

---------------------------------------------------------------------------------------------------
-- << insert >>

Tirislib.Testing.add_test_case(
    "insert inserts a string after the given position",
    "lib.string",
    function()
        Assert.equals(String.insert("hello", "X", 2), "heXllo")
        Assert.equals(String.insert("hello", "X", 0), "Xhello")
        Assert.equals(String.insert("hello", "X", 5), "helloX")
    end
)
