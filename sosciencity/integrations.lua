

for _, mod_name in pairs(mods) do
    try_load("integration-scripts." .. mod_name)
end
