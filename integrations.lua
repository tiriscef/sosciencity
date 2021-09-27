for mod_name in pairs(mods) do
    pcall(require, "integrations." .. mod_name)
end
