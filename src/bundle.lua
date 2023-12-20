
local path = require("src.path")
local generate_animal_hash = require("src.animal-hash")

local settings = {}

-- returns str[i] or ""
local function char_at(str, i)
    if i > #str then return "" end
    return str:sub(i, i)
end

local function log(str)
    if settings.verbose then
        print(str)
    end
end

-- returns minified contents of a file (or original contents if settings.minify is false)
-- and a list of all require calls in the file
local function process_file(f)

    local contents = ""
    local original_contents = ""

    local search_depth = 0
    local search_start = ""
    local searching_for = ""
    local preserve_original_content = false
    local first_line = true
    local explore = true
    local last_char_was_space = false
    local require_indices = {}

    local function write(str)
        if not preserve_original_content and str == " " then
            if not last_char_was_space then
                contents = contents .. " "
                last_char_was_space = true
            end
        else
            contents = contents .. str
            last_char_was_space = false
        end
    end

    for line in f:lines() do
        -- if line isnt all whitespace or a comment, add it to the original contents
        if not line:match("^%s*%-%-") and not line:match("^%s*$") then
            original_contents = original_contents .. "    " .. line .. "\n"
        end

        if first_line then
            if line == "-- generated with bundle.lua" then 
                log("Encountered bundle.lua header, will not resolve dependencies.")
                explore = false 
            end
            first_line = false
        elseif search_depth > 0 and preserve_original_content then
            write("\n")
        end

        local i = 1
        write(" ")
        while i <= #line do

            local function skip_to_end_of_line()
                i = #line + 1
            end

            local function is_multiline_string_start()
                local j = i
                if char_at(line, i) == "[" then 
                    local start = "["
                    local search = "]"
                    i = i + 1
                    while char_at(line, i) == "=" do
                        start = start .. "="
                        search = search .. "="
                        i = i + 1
                    end
                    if char_at(line, i) == "[" then
                        return true, start .. "[", search .. "]"
                    else
                        i = j
                        return false
                    end
                else 
                    return false
                end
            end

            -- scans string WITHOUT the quotation marks
            local function scan_string()
                local j = i
                local search = char_at(line, i)
                i = i + 1
                while char_at(line, i) ~= search do
                    if char_at(line, i) == "\\" then
                        i = i + 1
                    end
                    i = i + 1
                end
                i = i + 1
                return line:sub(j + 1, i - 2)
            end

            local started_at = i

            if search_depth > 0 then
                if line:sub(i, i + #searching_for - 1) == searching_for then
                    search_depth = search_depth - 1
                    i = i + #searching_for
                    if preserve_original_content then
                        write(searching_for)
                    end
                elseif line:sub(i, i + #search_start - 1) == search_start then
                    search_depth = search_depth + 1
                    i = i + #search_start
                    if preserve_original_content then
                        write(search_start)
                    end
                elseif preserve_original_content then
                    write(char_at(line, i))
                    i = i + 1
                else
                    i = i + 1
                end
            else
                local c = char_at(line, i)
                if c == "-" and char_at(line, i + 1) == "-" then
                    if char_at(line, i + 2) == "[" then
                        local start = "["
                        local search = "]"
                        i = i + 3
                        while char_at(line, i) == "=" do
                            start = start .. "="
                            search = search .. "="
                            i = i + 1
                        end
                        if char_at(line, i) == "[" then
                            search_depth = 1
                            preserve_original_content = false
                            search_start = start .. "["
                            searching_for = search .. "]"
                        else
                            skip_to_end_of_line()
                        end
                    else
                        skip_to_end_of_line()
                    end
                elseif c == "\"" or c == "'" then
                    local inner = scan_string()
                    write(c .. inner .. c)
                elseif c == " " or c == "\t" then
                    while char_at(line, i) == " " or char_at(line, i) == "\t" do
                        i = i + 1
                    end
                    if not last_char_was_space then
                        write(" ")
                        last_char_was_space = true
                    end
                else
                    local is_multiline_string, start, search = is_multiline_string_start()
                    if is_multiline_string then
                        write(start)
                        i = i + #search
                        search_depth = 1
                        preserve_original_content = true
                        search_start = start
                        searching_for = search
                    else
                        if line:sub(i, i + 6) == "require" then
                            table.insert(require_indices, #contents + 1)
                        end
                        write(c)
                        i = i + 1
                    end
                end
            end
        end
    end

    local requires = {}
    if explore then 
        for _, i in ipairs(require_indices) do 
            i = i + 8
            local function skip_whitespace()
                while char_at(contents, i) == " " or char_at(contents, i) == "\t" do i = i + 1 end
            end
            if i <= #contents then 
                skip_whitespace()
                local bracket_depth = 0
                while char_at(contents, i) == "(" do 
                    bracket_depth = bracket_depth + 1
                    i = i + 1 
                end
                skip_whitespace()
                if char_at(contents, i) == "\"" or char_at(contents, i) == "'" then 
                    local j = i
                    local search = char_at(contents, i)
                    i = i + 1
                    while char_at(contents, i) ~= search do
                        if char_at(contents, i) == "\\" then
                            i = i + 1
                        end
                        i = i + 1
                    end
                    local path
                    if char_at(contents, i) == search then
                        i = i + 1
                        path = contents:sub(j + 1, i - 2)
                    end

                    skip_whitespace()

                    local valid = true
                    for k = 1, bracket_depth do
                        if char_at(contents, i) ~= ")" then
                            valid = false
                            break
                        end
                        i = i + 1
                    end

                    if valid then
                        table.insert(requires, path)
                    end
                end
            end
        end
    end

    if not settings.minify then 
        contents = original_contents
    end

    return {
        minified = contents,
        requires = requires
    }
end

local function array_contains(arr, val)
    for _, v in ipairs(arr) do
        if v == val then return true end
    end
    return false
end

local warnings = {}
local modules = {}
-- opens loads all the modules in the `requires` list and adds them to the `modules` table
-- and recursively does the same to all the modules that those modules require
local function explore_requires(requires)
    for _, module in ipairs(requires) do
        -- if the module is not in the ignore list and it has not already been loaded
        if not modules[module] and not array_contains(settings.ignore_modules, module) then
            local file, full_path = path.open_module_file(settings.include_paths, module)
            if file then
                log("Processing module '" .. module .. "' from " .. full_path .. "...")
                local processed = process_file(file)
                file:close()
                modules[module] = {
                    content = processed.minified,
                    path = full_path
                }
                explore_requires(processed.requires)
            else
                local warning = "module '" .. module .. "' not found"
                if not settings.suppress_warnings then
                    log("WARNING: " .. warning)
                end
                table.insert(warnings, warning)
            end
        end
    end
end

local function bundle(entry_file, s)
    modules = {}
    warnings = {}
    s.ignore_modules = s.ignore_modules or {}
    settings = s

    log("Processing entry file '" .. entry_file .. "'...")
    local entry_file_handle = io.open(entry_file, "r")
    local entry_file_info = process_file(entry_file_handle)
    entry_file_handle:close()

    -- start with the entry file
    explore_requires(entry_file_info.requires)

    local output = ""
    local function write(str)
        output = output .. str
    end

    write("-- generated with bundle.lua\n")
    write("-- " .. generate_animal_hash() .. "\n")
    write("-- " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n")
    write("local __modules = {}\n")
    write("local function require(module_name) local module = __modules[module_name] if module then return module() else error(\"module not found: \" .. module_name, 2) end end\n")
    write("\n")

    for module_name, mod in pairs(modules) do
        write("-- Module \"" .. module_name .. "\" from " .. mod.path .. "\n")
        write("__modules[\"" .. module_name .. "\"] = function(...)")
        if not settings.minify then 
            write("\n")
        end
        write(mod.content)
        if settings.minify then 
            write(" ")
        end
        write("end\n")
        write("\n")
    end

    write("-- Entry file \"" .. entry_file .. "\"\n")
    write("do")
    if not settings.minify then 
        write("\n")
    end
    write(entry_file_info.minified)
    if settings.minify then 
        write(" ")
    end
    write("end\n")
    log("Bundle complete.")

    return output, warnings
end

return bundle
