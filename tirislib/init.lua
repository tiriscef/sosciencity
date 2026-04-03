Tirislib = Tirislib or {}

--- @class locale
--- @class point2d
--- @class array

require("testing")
require("utils")
require("string")
require("tables")
require("arrays")
require("locales")
require("lazy-luaq")
require("luaq")

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
