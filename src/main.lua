

local bundle = require("src.bundle")

-- if loaded in module
if pcall(debug.getlocal, 4, 1) then
    return bundle
else
    local parse_args = require("src.cmd-parse")
    local settings = parse_args({...})
    local bundled = bundle(settings.entry_file, settings)

    local output_file = io.open(settings.output_file, "w")
    output_file:write(bundled)
    output_file:close()
end

