for _, tree in Tirislib_Entity.pairs("tree") do
    tree:add_mining_result {
        name = "fawoxylas",
        probability = 0.1,
        amount_min = 1,
        amount_max = 5
    }
end
