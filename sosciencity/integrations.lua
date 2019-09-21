local integrations = {
    ["bspmod"] = true,
}

for mod_name, _ in pairs(integrations) do
    if mods[mod_name] then
        require("integrations." .. mod_name)
    end
end
