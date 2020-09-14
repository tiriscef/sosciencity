for _, tree in Tirislib_Entity.pairs("tree") do
    tree:add_mining_result {
        name = "fawoxylas",
        probability = 0.5,
        amount_min = 1,
        amount_max = 5
    }

    if not string.find(tree.name, "dead") then
        tree:add_mining_result {
            name = "leafage",
            amount_min = 1,
            amount_max = 3
        }
    end
end
