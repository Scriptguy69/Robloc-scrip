-- Grow a Garden 2 ULTIMATE Dupe Script - FIXED Edition
-- GitHub-ready version

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local RunService = game:GetService("RunService")

-- Anti-Cheat Bypass
local function spoof()
    local mt = getmetatable(game)
    if mt then
        rawset(mt, "__newindex", function() end)
    end
end

spoof()

-- Seed Detection
local seeds = {}
local lastUpdate = 0

local function scanBackpack()
    local foundSeeds = {}
    for _, item in pairs(Backpack:GetChildren()) do
        local name = item.Name:lower()
        if name:find("seed") or name:find("plant") or name:find("tree") or 
           name:find("flower") or name:find("fruit") or name:find("berry") then
            table.insert(foundSeeds, item.Name)
        end
    end
    seeds = foundSeeds
    lastUpdate = tick()
    return foundSeeds
end

scanBackpack()

-- Dupe Engine
local isDuping = false

local function dupe(itemName, amount)
    if isDuping then
        print("⏳ Already duping...")
        return false
    end
    
    isDuping = true
    local item = Backpack:FindFirstChild(itemName)
    
    if not item then
        isDuping = false
        print("❌ Item not found: " .. itemName)
        return false
    end
    
    print("🔄 Duping " .. itemName .. " x" .. amount)
    local cloned = 0
    local errors = 0
    
    for i = 1, amount do
        pcall(function()
            local clone = item:Clone()
            clone.Parent = Backpack
            cloned = cloned + 1
        end, function(err)
            errors = errors + 1
        end)
        
        if i
