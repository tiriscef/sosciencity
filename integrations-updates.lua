for mod_name in pairs(mods) do
    pcall(require, "integrations-updates." .. mod_name)
end
