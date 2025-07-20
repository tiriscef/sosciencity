---@class Prototype
---@class PrototypeArray
---@class RecipePrototype
---@class RecipePrototypeArray
---@class ItemPrototype
---@class ItemPrototypeArray
---@class EntityPrototype
---@class EntityPrototypeArray
---@class TechnologyPrototype
---@class TechnologyPrototypeArray
---@class FluidPrototype
---@class FluidPrototypeArray
---@class RecipeCategoryPrototype
---@class RecipeCategoryPrototypeArray

---@class RecipeEntryPrototype

---@class TechnologyEffectPrototype

---@class SpritePrototype
---@class AnimationPrototype
---@class PicturePrototype
---@class SoundPrototype

---@class LuaqQuery

---@class LuaEntity

---@class locale
---@class point2d
---@class BoundingBox
---@class array

local tirislib_internal_version = 6

if Tirislib then
    if tirislib_internal_version <= (Tirislib.internal_version or 0) then
        -- avoid loading an older version if another mod already loaded Tirislib
        return
    end
end

Tirislib = Tirislib or {}
Tirislib.internal_version = tirislib_internal_version

require("testing")
require("lazy-luaq")
require("utils")

if Tirislib.Utils.is_data_stage() then
    require("prototype")
    require("base-prototype")
    require("recipe")
    require("item")
    require("entity")
    require("technology")
    require("fluid")
    require("recipe-category")
    require("recipe-generator")
end
