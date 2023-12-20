
-- This file should print a bundled version of itself to stdout

local bundle = require("bundle")

local bundled, warnings = bundle("example.lua", {
    include_paths = {
        "?.lua"
    },
    ignore_modules = {
        "bundle"
    },
    minify = true,
    animal_hash = true
})

print(bundled)
print(tostring(#warnings) .. " warnings")
for _, warning in ipairs(warnings) do
    print(" - " .. warning)
end