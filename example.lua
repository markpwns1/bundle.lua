
-- This file should print a bundled version of itself to stdout

local bundle = require("bundle")

local bundled = bundle("example.lua", {
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