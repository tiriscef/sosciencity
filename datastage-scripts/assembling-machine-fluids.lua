-- The assembling machine 1 gets one fluid input and one fluid output, so that early recipes with fluids
-- don't need the assembling machine 2, which needs logistic science. Same layout as the assembling machine 2.

local assembler, found = Tirislib.Entity.get_by_name("assembling-machine-1")
if not found then
    return
end

assembler:add_crafting_category("crafting-with-fluid")

local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures()

assembler.fluid_boxes = {
    {
        production_type = "input",
        pipe_picture = pipe_pictures,
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{flow_direction = "input", direction = defines.direction.north, position = {0, -1}}},
        secondary_draw_orders = {north = -1}
    },
    {
        production_type = "output",
        pipe_picture = pipe_pictures,
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{flow_direction = "output", direction = defines.direction.south, position = {0, 1}}},
        secondary_draw_orders = {north = -1}
    }
}
assembler.fluid_boxes_off_when_no_fluid_recipe = true
