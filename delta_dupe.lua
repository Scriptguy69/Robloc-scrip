-- Grow a Garden 2 Dupe Script - Delta Executor (Simple Version)
-- Copy entire line into Delta: loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/delta_dupe.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to duplicate seeds
local function dupeItem(itemName, amount)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then
        return "Error: Backpack not found"
    end
    
    local originalItem = backpack:FindFirstChild(itemName)
    if not originalItem then
        return "❌ Item not found: " .. itemName
    end
    
    local success = 0
    for i = 1, amount do
        local clone = originalItem:Clone()
        clone.Parent = backpack
        success = success + 1
    end
    
    return "✅ Successfully cloned " .. success .. "x " .. itemName
end

-- Global function - use this!
getgenv().dupe = function(itemName, amount)
    return dupeItem(itemName, amount)
end

print("✅ Script loaded! Use: getgenv().dupe('bamboo', 200)")
