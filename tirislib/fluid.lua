---------------------------------------------------------------------------------------------------
-- << class for fluids >>
--- @class FluidPrototype
Tirislib.Fluid = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.Fluid.__index = Tirislib.Fluid

--- Class for arrays of fluids. Setter-functions can be called on them.
--- @class FluidPrototypeArray
Tirislib.FluidArray = {}
Tirislib.FluidArray.__index = Tirislib.PrototypeArray.__index

--- Gets the FluidPrototype of the given name. If no such Fluid exists, a dummy object will be returned instead.
--- @param name string
--- @return FluidPrototype prototype
--- @return boolean found
function Tirislib.Fluid.get_by_name(name)
    return Tirislib.Prototype.get("fluid", name, Tirislib.Fluid)
end

--- Creates the FluidPrototype metatable for the given prototype.
--- @param prototype table
--- @return FluidPrototype
function Tirislib.Fluid.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib.Fluid)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return FluidPrototype prototype
--- @return boolean|nil found
function Tirislib.Fluid.get(name)
    if type(name) == "string" then
        return Tirislib.Fluid.get_by_name(name)
    else
        return Tirislib.Fluid.get_from_prototype(name)
    end
end

--- Creates an iterator over all FluidPrototypes.
--- @return function
--- @return string
--- @return FluidPrototype
function Tirislib.Fluid.iterate()
    local index, value

    local function _next()
        index, value = next(data.raw["fluid"] or {}, index)

        if index then
            setmetatable(value, Tirislib.Fluid)
            return index, value
        end
    end

    return _next, index, value
end

--- Creates an FluidPrototype from the given prototype table.
--- Extra key consumed: `use_placeholder_icon`.
--- Icon priority: `use_placeholder_icon` > explicit `icon` > auto-derived from `default_icon_path .. name`.
--- @param prototype table
--- @return FluidPrototype prototype
function Tirislib.Fluid.create(prototype)
    local use_placeholder_icon = prototype.use_placeholder_icon
    prototype.use_placeholder_icon = nil

    if use_placeholder_icon then
        prototype.icon = Tirislib.Prototype.placeholder_icon
        prototype.icon_size = prototype.icon_size or 64
    elseif not prototype.icon then
        prototype.icon = Tirislib.Prototype.default_icon_path .. prototype.name .. ".png"
    end

    prototype.type = prototype.type or "fluid"

    Tirislib.Prototype.create(prototype)

    return Tirislib.Fluid.get(prototype.name)
end

--- Creates a bunch of fluid prototypes.
--- Fluid entries are merged with `batch_data` defaults (fluid fields take priority).
--- @param fluid_data_array table
--- @param batch_data table
--- @return FluidPrototypeArray
function Tirislib.Fluid.batch_create(fluid_data_array, batch_data)
    local created_fluids = {}
    for index, fluid_data in pairs(fluid_data_array) do
        local prototype = {}
        Tirislib.Tables.set_fields(prototype, batch_data)
        Tirislib.Tables.set_fields(prototype, fluid_data)
        prototype.order = prototype.order or string.format("%03d", index)
        prototype.icon_size = prototype.icon_size or 64

        created_fluids[#created_fluids + 1] = Tirislib.Fluid.create(prototype)
    end

    setmetatable(created_fluids, Tirislib.FluidArray)
    return created_fluids
end

--- Returns the localised name of the fluid.
--- @return locale
function Tirislib.Fluid:get_localised_name()
    return self.localised_name or {"fluid-name." .. self.name}
end

--- Returns the localised description of the fluid.
--- @return locale
function Tirislib.Fluid:get_localised_description()
    return self.localised_description or {"fluid-description." .. self.name}
end

local meta = {
    __index = Tirislib.BasePrototype
}

function meta:__call(name)
    return Tirislib.Fluid.get(name)
end

setmetatable(Tirislib.Fluid, meta)
