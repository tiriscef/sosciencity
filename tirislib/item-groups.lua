--- @class ItemGroups
Tirislib.ItemGroups = {}

--- Creates an item-group and its subgroups in one call.
--- Subgroups are ordered by their position in the array.
--- @param definition table {name, order, icon, icon_size, subgroups: string[]}
function Tirislib.ItemGroups.create(definition)
    local entries = {
        {
            type = "item-group",
            name = definition.name,
            order = definition.order,
            icon = definition.icon,
            icon_size = definition.icon_size
        }
    }

    for i, subgroup_name in pairs(definition.subgroups) do
        entries[#entries + 1] = {
            type = "item-subgroup",
            name = subgroup_name,
            group = definition.name,
            order = string.format("%04d", i)
        }
    end

    Tirislib.Prototype.batch_create(entries)
end
