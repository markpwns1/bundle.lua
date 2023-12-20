
local path = {}

function path.fill_path_template(path, file)
    return path:gsub("%?", file)
end

function path.dot_to_slash(module_name)
    return module_name:gsub("%.", "/")
end

function path.normalise_slashes(path)
    return path:gsub("\\", "/")
end

function path.open_module_file(include_paths, module_name)
    local module_path = path.dot_to_slash(module_name)
    for _, include_path in ipairs(include_paths) do
        local full_path = path.normalise_slashes(path.fill_path_template(include_path, module_path))
        local file = io.open(full_path, "r")
        if file then
            return file, full_path
        end
    end
    return nil
end

-- returns filename without extension IF POSSIBLE
-- ex: "path/to/file.lua" -> "file"
-- ex: "path/to/file" -> "file"
function path.get_filename(path)
    local filename = path:match("[^/]*$")
    return filename:match("(.+)%..+") or filename
end

return path