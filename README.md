
# bundle.lua
A zero-dependency Lua utility to pack an entire project into one file. Suitable for environments that only let you run a single script, like in certain video games or programs.

## Installation
Just copy the file `bundle.lua` inside the repo into your project.

## Usage
You can use it as a command line utility like so:
```
lua bundle.lua <entry file> [ options... ]

Options:
    -i <include path>        Sets the include paths to search for modules
                             * Note that the argument must be in the form of 
                               "path/to/include/?.lua;another/path/?.lua"
    -o <output file>         Sets the output file name
    -m, --minify             Minifies the output file
    -a, --no-animals         Disables animal hashing
    -g, --ignore <modules>   Sets the modules to ignore when bundling, separated by semicolons
```

Alternatively, you can `require("bundle")` which will return a function `bundle(entry_file: string, settings: table): string` which can be used like so:
```lua
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

print(bundled) -- Prints the bundled string which can be written to a file later
```

### Animal Hashing
Sometimes, when copy-pasting code into your environment, it might be hard to tell at a glance whether the version you just pasted is different to the one it replaced, or sometimes it might be hard to tell whether the code you're looking at is outdated or not. Regardless, each file is generated with a reasonably unique animal hash, such as `HIPPO <3 ELEPHANT` that changes depending on the time the file was built, as an easy way to differentiate two files at a glance.

### Recursive Bundling
To prevent problems with bundling a file that has already been bundled, any file that starts with the comment `-- generated with bundle.lua` will have their dependencies ignored, since a bundled file has no dependencies anyway.

## Building
The `bundle.lua` is self-hosted, and you can build the project by using any one of the files `build.bat`, `build.sh`, or `build.lua`, all of which just run the command
```
lua "src/main.lua" "src/main.lua" -i "?.lua" -o "bundle.lua" --minify
```