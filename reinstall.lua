local function deleteRecursive(path, keepPath)
    if path == keepPath then return end
    if isfolder and isfolder(path) then
        for _, item in ipairs(listfiles(path)) do
            deleteRecursive(item, keepPath)
        end
        if path ~= keepPath then
            if delfolder then delfolder(path) else pcall(delfolder, path) end
        end
    else
        delfile(path)
    end
end

if not isfolder("newvape") then
    print("folder 'newvape' not found.")
    return
end

local keepFullPath = "newvape/profiles"
if not isfolder(keepFullPath) then
    print("warning nigga : 'newvape/profiles' missing - everything boutta get deleted gang")
end

for _, item in ipairs(listfiles("newvape")) do
    if item ~= keepFullPath then
        deleteRecursive(item, keepFullPath)
    end
end

print("loading Kingv4...")
task.wait(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/YoKaida63/King67/main/downloader.lua", true))()
