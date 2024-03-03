if not settings.startup["sosciencity-modify-environment"].value then
    return
end

for _, tree in Tirislib.Entity.iterate("tree") do
    tree:add_mining_result {
        name = "wild-fungi",
        probability = 0.2,
        amount_min = 1,
        amount_max = 2
    }

    if not string.find(tree.name, "dead") then
        tree:add_mining_result {
            name = "wild-edible-plants",
            probability = 0.5,
            amount_min = 1,
            amount_max = 3
        }

        tree:add_mining_result {
            name = "leafage",
            amount_min = 1,
            amount_max = 3
        }
    end
end
