local Assert = Tirislib.Testing.Assert

local Register = require("classes.register")
local late_require = require("classes.late-require")

Tirislib.Testing.add_test_case(
    "late_require returns the table require returned",
    "late-require",
    function()
        Assert.equals(late_require("classes.register"), Register)
    end
)

Tirislib.Testing.add_test_case(
    "late_require fails for a module that isn't loaded",
    "late-require",
    function()
        Assert.throws(
            function()
                late_require("classes.does-not-exist")
            end
        )
    end
)
