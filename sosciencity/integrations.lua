function try_load(file)
    local ok, err = pcall(require, file)
    if not ok and not err:find('^module .* not found') then
        error(err)
    end
end

for _, mod_name in pairs(mods) do
    try_load("integration-scripts." .. mod_name)
end
