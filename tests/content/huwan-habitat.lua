local Types = require("constants.types")

local Assert = Tirislib.Testing.Assert

--- Huwan habitat: city buildings and farms can only be placed on Nauvis (prototypes/huwan-habitat.lua).
--- The surface conditions only exist with the space_travel feature flag. The test environment runs without it
--- (the game wouldn't load conditions without it), so the condition checks only run when the suite gets started
--- with Space Age.

local function requires_habitat(entity)
    for _, condition in pairs(entity.surface_conditions or {}) do
        if condition.property == "huwan-habitat" and condition.min == 1 then
            return true
        end
    end
    return false
end

Tirislib.Testing.add_test_case(
    "Nauvis is a huwan habitat, other surfaces aren't",
    "content.huwan-habitat",
    function()
        local property = data.raw["surface-property"]["huwan-habitat"]
        Assert.not_nil(property, "surface property missing")
        Assert.equals(property.default_value, 0)
        Assert.equals(data.raw["planet"]["nauvis"].surface_properties["huwan-habitat"], 1)
    end
)

Tirislib.Testing.add_parameterized_test_case(
    "%s requires a huwan habitat: %s",
    "content.huwan-habitat",
    {
        {"house1", true, name = "a house"},
        {"market-hall", true, name = "a civil building"},
        {"bloomhouse", true, name = "a building with a workforce that isn't civil"},
        {"farm", true, name = "a farm"},
        {"industrial-animal-farm", true, name = "an animal farm"},
        {"cold-storage-warehouse", false, name = "a building without workforce that isn't civil"},
        {"sorting-machine", false, name = "a machine without a building definition"}
    },
    function(name, expected)
        if not feature_flags["space_travel"] then
            Assert.pass()
            return
        end

        local entity, found = Tirislib.Entity.get_by_name(name)
        Assert.is_true(found, name .. " doesn't exist")
        Assert.equals(requires_habitat(entity), expected)
    end
)

Tirislib.Testing.add_test_case(
    "Exactly the buildings that need a huwan habitat require it",
    "content.huwan-habitat",
    function()
        if not feature_flags["space_travel"] then
            Assert.pass()
            return
        end

        local wrong = {}
        for _, entity in Tirislib.Entity.iterate() do
            if Tirislib.Prototype.get_owner(entity) == "sosciencity"
                and requires_habitat(entity) ~= Types.needs_huwan_habitat(entity.name) then
                wrong[#wrong + 1] = entity.name
            end
        end
        table.sort(wrong)
        Assert.is_table_empty(wrong, "habitat condition doesn't match Types.needs_huwan_habitat: " .. table.concat(wrong, ", "))
    end
)
