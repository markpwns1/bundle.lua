
local path = require("src.path")

local function parse_args(args)
    if #args < 1 then 
        print("Usage: lua bundle.lua <entry file> [ options... ]")
        print("Options:")
        print("    -i <include path>        Sets the include paths to search for modules")
        print("                             * Note that the argument must be in the form of ")
        print("                               \"path/to/include/?.lua;another/path/?.lua\"")
        print("    -o <output file>         Sets the output file name")
        print("    -m, --minify             Minifies the output file")
        print("    -a, --no-animals         Disables animal hashing")
        print("    -g, --ignore <modules>   Sets the modules to ignore when bundling, separated by semicolons")
        os.exit(1)
    end
    
    local entry_file = args[1]
    local include_paths = {}
    local output_file = path.get_filename(entry_file) .. "_bundle.lua"
    local minify = false
    local animal_hash = true
    local ignore_modules = {}
    
    for i = 2, #args do
        if args[i] == "-i" then
            i = i + 1
            for path in args[i]:gmatch("[^;]+") do
                table.insert(include_paths, path)
            end
        elseif args[i] == "-o" then
            i = i + 1
            output_file = args[i]
        elseif args[i] == "--minify" or args[i] == "-m" then
            minify = true
        elseif args[i] == "--no-animals" or args[i] == "-a" then
            animal_hash = false
        elseif args[i] == "--ignore" or args[i] == "-g" then
            i = i + 1
            for path in args[i]:gmatch("[^;]+") do
                table.insert(ignore_modules, path)
            end
        end
    end

    return {
        entry_file = entry_file,
        include_paths = include_paths,
        output_file = output_file,
        minify = minify,
        animal_hash = animal_hash,
        ignore_modules = ignore_modules
    }
end

return parse_args