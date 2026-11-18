--- Gets a module that control.lua loads later than the caller, for dependencies that would close a cycle
--- if the caller required them at file scope.<br>
--- Factorio only allows `require` while control.lua is being parsed, so a module that needs another one in its
--- function bodies binds it in its load function with this instead. By then control.lua has loaded every module.<br>
--- Factorio keys package.loaded by resolved path, not by the string passed to require.
--- @param name string module name in require form, e.g. "classes.entities.hospital"
--- @return any module
local function late_require(name)
    local path = "__sosciencity__/" .. name:gsub("%.", "/") .. ".lua"
    local module = package.loaded[path]
    if module == nil then
        error("late_require: module " .. name .. " isn't loaded")
    end
    return module
end

return late_require
