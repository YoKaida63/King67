local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local function IsWhitelisted()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://mystb.in/raw/WHITELIST_ID") -- Whitelist paste
    end)
    
    if not success then return false end
    
    for name in response:gmatch("[^\r\n]+") do
        if name:lower() == player.Name:lower() then
            return true
        end
    end
    
    return false
end

if not IsWhitelisted() then
    game.Players.LocalPlayer:Kick("❌ You are not whitelisted! Purchase KingV4 Premium.")
    return
end

-- Load the obfuscated script from Mystb.in or Pastey.gg
local success, response = pcall(function()
    return HttpService:GetAsync("https://mystb.in/raw/OBFUSCATED_SCRIPT_ID")
end)

if success and response then
    loadstring(response)()
end
