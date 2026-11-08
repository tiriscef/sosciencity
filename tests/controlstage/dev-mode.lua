local Assert = Tirislib.Testing.Assert
local DevMode = require("classes.dev-mode")

local SETTING = "sosciencity-dev-mode"

--- Runs fn with the given dev mode map setting and record, and restores both afterwards, also when fn fails.
local function with_dev_mode_state(setting_value, record, fn)
    local saved_setting = settings.global[SETTING].value
    local saved_record = storage.dev_mode_first_activation

    settings.global[SETTING] = {value = setting_value}
    storage.dev_mode_first_activation = record

    local ok, err = pcall(fn)

    settings.global[SETTING] = {value = saved_setting}
    storage.dev_mode_first_activation = saved_record

    if not ok then
        error(err, 0)
    end
end

Tirislib.Testing.add_test_case(
    "DevMode.update_record doesn't record anything while the map setting is off",
    "dev-mode",
    function()
        with_dev_mode_state(false, nil, function()
            DevMode.update_record()
            Assert.is_nil(DevMode.get_first_activation())
        end)
    end
)

Tirislib.Testing.add_test_case(
    "DevMode.update_record records the current tick when the map setting is on",
    "dev-mode",
    function()
        with_dev_mode_state(true, nil, function()
            DevMode.update_record()
            Assert.equals(DevMode.get_first_activation(), game.tick)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "DevMode.update_record keeps the first activation",
    "dev-mode",
    function()
        with_dev_mode_state(true, -42, function()
            DevMode.update_record()
            Assert.equals(DevMode.get_first_activation(), -42)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "DevMode.update_record keeps the record after the map setting was turned off again",
    "dev-mode",
    function()
        with_dev_mode_state(false, -42, function()
            DevMode.update_record()
            Assert.equals(DevMode.get_first_activation(), -42)
        end)
    end
)
