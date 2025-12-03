Tirislib = Tirislib or {}

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
