local integrations = {
    "bspmod"
}

for _, mod_name in pairs(integrations) do
    if mods[mod_name] then
        require("integrations." .. mod_name)
    end
end
