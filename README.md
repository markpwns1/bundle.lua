
# bundle.lua
A self-hosted, zero-dependency Lua utility to pack an entire project into one file. Suitable for environments that only let you run a single script, like in certain video games or programs.

## Installation
Just copy the file `bundle.lua` inside the repo into your project.

## Usage
You can use it as a command line utility like so:
```
lua bundle.lua <entry file> [ options... ]

Options:
    -i <include paths>       Sets the include paths to search for modules
                             * Note that the argument must be in the form of 
                               "path/to/include/?.lua;another/path/?.lua"
    -o <output file>         Sets the output file name
    -m, --minify             Minifies the output file
    -a, --no-animals         Disables animal hashing
    -g, --ignore <modules>   Sets the modules to ignore when bundling, separated by semicolons
    -v, --verbose            Enables verbose output
    -s, --suppress-warnings  Suppresses warnings
    -h, --help               Prints this help message
```

Note that include paths must be in the form of `path/to/include/?.lua;another/path/?.lua` which is [the same format that Lua package search uses](https://www.lua.org/pil/8.1.html).

Alternatively, you can `require("bundle")` which will return a function `bundle(entry_file: string, settings: table): string, {string}` which will return the bundled file contents and a list of warnings that were generated. Here's an example of its use as a module:
```lua
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

print(bundled) -- Prints the bundled string which can be written to a file later

print(tostring(#warnings) .. " warnings") -- Prints all warnings encountered
for _, warning in ipairs(warnings) do
    print(" - " .. warning)
end 
```

### Animal Hashing
Sometimes, when copy-pasting code into your environment, it might be hard to tell at a glance whether the version you just pasted is different to the one it replaced, or sometimes it might be hard to tell whether the code you're looking at is outdated or not. Regardless, each file is generated with a reasonably unique animal hash, such as `HIPPO <3 ELEPHANT` that changes depending on the time the file was built, as an easy way to differentiate two files at a glance.

The following is an example file header for a bundle generated with `bundle.lua`:
```lua
-- generated with bundle.lua
-- IGUANA <3 YAK
-- 2023-12-19 18:43:32
```

### Recursive Bundling
To prevent problems with bundling a file that has already been bundled, any file that starts with the comment `-- generated with bundle.lua` will have their dependencies ignored, since a bundled file has no dependencies anyway.

## How It Works
Essentially, it minifies your entry file and uses the minified file as a kind of normal form from which to extract dependencies. During minification, it keeps track of the places where it encountered the keyword `require`, and then on the minified version attempts to extract the module name from the `require` call. With the file minified and the dependencies extracted, it recursively performs the same process on each dependency, and in the end, outputs the entry file and all its dependencies into a `__modules` table in the generated file, and replaces the `require` function with a new one that gets the requested module from the `__modules` table.

## Building
The `bundle.lua` is self-hosted, and you can build the project by using any one of the files `build.bat`, `build.sh`, or `build.lua`, all of which just run the command
```
lua "src/main.lua" "src/main.lua" -i "?.lua" -o "bundle.lua" --minify --verbose
```
