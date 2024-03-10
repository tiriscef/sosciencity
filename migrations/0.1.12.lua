-- remove old altmode_sprites
for _, entry in pairs(global.register) do
    local id = entry[8] -- the old EK.altmode_sprite
    if id then
        if rendering.is_valid(id) then
            rendering.destroy(id)
        end
    end
end
