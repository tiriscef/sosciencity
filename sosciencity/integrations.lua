function try_load(file)
    local ok, err = pcall(require, file)
    if not ok and not string.find(err, '^module .* not found') then
        error(err)
    end
end

for mod_name, _ in pairs(mods) do
    try_load("integrations." .. mod_name)
end
