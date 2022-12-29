Tirislib.Recipe.copy("landfill", "garbage-to-landfill"):add_result {
    type = "item",
    name = "landfill",
    amount = 1
}:add_ingredient {
    type = "item",
    name = "garbage",
    amount = 20
}:add_unlock("landfill")
