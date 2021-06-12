if not settings.startup["sosciencity-modify-environment"].value then
    return
end

for _, tree in Tirislib_Entity.iterate("tree") do
    tree:add_mining_result {
        name = "fawoxylas",
        probability = 0.5,
        amount_min = 1,
        amount_max = 5
    }

    if not string.find(tree.name, "dead") then
        tree:add_mining_result {
            name = "unnamed-fruit",
            probability = 0.2,
            amount_min = 1,
            amount_max = 5
        }

        tree:add_mining_result {
            name = "leafage",
            amount_min = 1,
            amount_max = 3
        }
    end
end
