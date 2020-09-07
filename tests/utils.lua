require("lib.testing")
require("lib.utils")

local Assert = Tiristest.Assert

Tiristest.add_test_case(
    "dice_rolls returns the correct number of rolls",
    "lib.utils",
    function()
        local dice = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

        -- count > actual count, modulo == 0
        local rolls = Tirislib_Utils.dice_rolls(dice, 500, 20)
        Assert.equals(Tirislib_Tables.sum(rolls), 500)

        -- count > actual count, modulo ~= 0
        rolls = Tirislib_Utils.dice_rolls(dice, 37, 20)
        Assert.equals(Tirislib_Tables.sum(rolls), 37)

        -- count == actual count
        rolls = Tirislib_Utils.dice_rolls(dice, 20, 20)
        Assert.equals(Tirislib_Tables.sum(rolls), 20)

        -- count < actual count
        rolls = Tirislib_Utils.dice_rolls(dice, 20, 100)
        Assert.equals(Tirislib_Tables.sum(rolls), 20)

        -- count == 0
        rolls = Tirislib_Utils.dice_rolls(dice, 0)
        Assert.equals(Tirislib_Tables.sum(rolls), 0)
    end
)

Tiristest.add_test_case(
    "dice_rolls returns a table with the dice's keys",
    "lib.utils",
    function()
        local dice = {[1] = 1, ["a string"] = 1, [true] = 1, [false] = 1, [{}] = 1}
        local rolls = Tirislib_Utils.dice_rolls(dice, 10, 10)

        for key in pairs(rolls) do
            Assert.not_nil(dice[key])
        end
        for key in pairs(dice) do
            Assert.not_nil(rolls[key])
        end
    end
)

Tiristest.add_test_case(
    "string join concats the contents of tables",
    "lib.utils",
    function()
        local test = Tirislib_String.join(" ", "h", {"e", "l", "l", "o"}, " ", {{"wor", "ld"}, "!"})
        Assert.equals(test, "h e l l o   wor ld !")
    end
)

Tiristest.add_test_case(
    "string join can handle empty inputs/tables",
    "lib.utils",
    function()
        local test = Tirislib_String.join(",", {}, "a", "b", {{}})
        Assert.equals(test, "a,b")

        test = Tirislib_String.join(",")
        Assert.equals(test, "")

        test = Tirislib_String.join(",", {})
        Assert.equals(test, "")

        test = Tirislib_String.join(",", {"a"})
        Assert.equals(test, "a")
    end
)
