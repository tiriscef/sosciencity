---------------------------------------------------------------------------------------------------
-- << class for recipe categories >>
Tirislib_RecipeCategory = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_RecipeCategory.__index = Tirislib_RecipeCategory

function Tirislib_RecipeCategory.get_by_name(name)
    return Tirislib_Prototype.get("recipe-category", name, Tirislib_RecipeCategory)
end

function Tirislib_RecipeCategory.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_RecipeCategory)
    return prototype
end

function Tirislib_RecipeCategory.get(name)
    if type(name) == "string" then
        return Tirislib_RecipeCategory.get_by_name(name)
    else
        return Tirislib_RecipeCategory.get_from_prototype(name)
    end
end

function Tirislib_RecipeCategory.pairs()
    local index, value

    local function _next()
        index, value = next(data.raw["recipe-category"], index)

        if index then
            setmetatable(value, Tirislib_RecipeCategory)
            return index, value
        end
    end

    return _next, index, value
end

function Tirislib_RecipeCategory.create(prototype)
    if not prototype.type then
        prototype.type = "recipe-category"
    end

    data:extend {prototype}
    return Tirislib_RecipeCategory.get(prototype.name)
end

-- << manipulation >>
--- Entity types that can have crafting categories
local crafters = {"character", "god-controller", "assembling-machine", "furnace", "rocket-silo"}

function Tirislib_RecipeCategory:make_hand_craftable()
    -- add it to all the prototypes the player can be in
    for _, character in Tirislib_Entity.iterate("character") do
        character:add_crafting_category(self.name)
    end
    for _, controller in Tirislib_Entity.iterate("god-controller") do
        -- technically a god controller isn't an entity, but adding a category works the same for them
        controller:add_crafting_category(self.name)
    end
end

--- Adds the recipe category to every entity that has also the given category.
function Tirislib_RecipeCategory:pair_with(category)
    for _, _type in pairs(crafters) do
        for _, entity in Tirislib_Entity.iterate(_type) do
            if entity:has_crafting_category(category) then
                entity:add_crafting_category(self.name)
            end
        end
    end
end

local meta = {}

function meta:__call(name)
    return Tirislib_RecipeCategory.get(name)
end

setmetatable(Tirislib_RecipeCategory, meta)
