
local path = require("src.path")

local function print_help_msg()
    print("Usage: lua bundle.lua <entry file> [ options... ]")
    print("Options:")
    print("    -i <include paths>       Sets the include paths to search for modules")
    print("                             * Note that the argument must be in the form of ")
    print("                               \"path/to/include/?.lua;another/path/?.lua\"")
    print("    -o <output file>         Sets the output file name")
    print("    -m, --minify             Minifies the output file")
    print("    -a, --no-animals         Disables animal hashing")
    print("    -g, --ignore <modules>   Sets the modules to ignore when bundling, separated by semicolons")
    print("    -v, --verbose            Enables verbose output")
    print("    -s, --suppress-warnings  Suppresses warnings")
    print("    -h, --help               Prints this help message")
end

local function parse_args(args)
    if #args < 1 then 
        print_help_msg()
        os.exit(1)
    end
    
    local entry_file = args[1]
    local include_paths = {}
    local output_file = path.get_filename(entry_file) .. "_bundle.lua"
    local minify = false
    local animal_hash = true
    local ignore_modules = {}
    local verbose = false
    local suppress_warnings = false
    
    local i = 2
    while i <= #args do
        if args[i] == "-i" then
            i = i + 1
            for path in args[i]:gmatch("[^;]+") do
                table.insert(include_paths, path)
            end
            i = i + 1
        elseif args[i] == "-o" then
            i = i + 1
            output_file = args[i]
            i = i + 1
        elseif args[i] == "--minify" or args[i] == "-m" then
            minify = true
            i = i + 1
        elseif args[i] == "--no-animals" or args[i] == "-a" then
            animal_hash = false
            i = i + 1
        elseif args[i] == "--ignore" or args[i] == "-g" then
            i = i + 1
            for path in args[i]:gmatch("[^;]+") do
                table.insert(ignore_modules, path)
            end
            i = i + 1
        elseif args[i] == "--verbose" or args[i] == "-v" then
            verbose = true
            i = i + 1
        elseif args[i] == "--suppress-warnings" or args[i] == "-s" then
            suppress_warnings = true
            i = i + 1
        elseif args[i] == "--help" or args[i] == "-h" then
            print_help_msg()
            os.exit(0)
        else
            print("Unknown argument: " .. args[i])
            print_help_msg()
            os.exit(1)
        end
    end

    return {
        entry_file = entry_file,
        include_paths = include_paths,
        output_file = output_file,
        minify = minify,
        animal_hash = animal_hash,
        ignore_modules = ignore_modules,
        verbose = verbose,
        suppress_warnings = suppress_warnings
    }
end

return parse_args