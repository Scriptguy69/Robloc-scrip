-- Grow a Garden 2 Ultra Simple Dupe - Delta Executor
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/delta_dupe.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Main dupe function
function dupe(itemName, count)
    -- Search in multiple locations
    local item = Backpack:FindFirstChild(itemName)
    
    if not item then
        -- Try searching in character
        local char = LocalPlayer.Character
        if char then
            item = char:FindFirstChild(itemName)
        end
    end
    
    if not item then
        -- Try recursive search
        item = LocalPlayer:FindFirstChildOfClass("Model")
        if item then
            item = item:FindFirstChild(itemName)
        end
    end
    
    if not item then
        warn("❌ Item '" .. itemName .. "' not found in Backpack or Character")
        return false
    end
    
    -- Clone the item
    local cloned = 0
    for i = 1, count do
        pcall(function()
            local clone = item:Clone()
            clone.Parent = Backpack
            cloned = cloned + 1
        end)
    end
    
    print("✅ Duped " .. cloned .. "x " .. itemName)
    return true
end

-- Set global function
getgenv().dupe = dupe

print("✅ Script loaded!")
print("Use: getgenv().dupe('bamboo', 200)")
