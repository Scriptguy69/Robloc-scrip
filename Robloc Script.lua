-- Grow a Garden 2 Dupe Script - Anti-Cheat Bypass Version
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/Robloc%20Script.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- ==================== ANTI-CHEAT BYPASS ====================

-- Hook metatable to bypass detection
pcall(function()
    local mt = getmetatable(game)
    if mt then
        rawset(mt, "__newindex", function(self, key, value) end)
    end
end)

-- ==================== DUPE FUNCTION ====================

local function dupe(itemName, amount)
    local item = Backpack:FindFirstChild(itemName)
    
    if not item then
        print("❌ Item not found: " .. itemName)
        return false
    end
    
    print("🔄 Duping " .. itemName .. " x" .. tostring(amount) .. "...")
    
    local cloned = 0
    for i = 1, amount do
        pcall(function()
            local clone = item:Clone()
            clone.Parent = Backpack
            cloned = cloned + 1
            
            -- Tiny delay to bypass rate-limit detection
            if i % 15 == 0 then
                wait(0.01)
            end
        end)
    end
    
    print("✅ Successfully duped " .. tostring(cloned) .. "x " .. itemName)
    return true
end

-- ==================== MINIMAL CLEAN UI (CENTERED) ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (centered, small, clean with rounded corners)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 130)
Frame.Position = UDim2.new(0.5, -120, 0.5, -65)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- Item Input
local ItemInput = Instance.new("TextBox")
ItemInput.Size = UDim2.new(0.85, 0, 0, 28)
ItemInput.Position = UDim2.new(0.075, 0, 0, 8)
ItemInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
ItemInput.TextColor3 = Color3.white
ItemInput.PlaceholderText = "Item name..."
ItemInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
ItemInput.Font = Enum.Font.Gotham
ItemInput.TextSize = 12
ItemInput.BorderSizePixel = 0
ItemInput.Parent = Frame

local ItemCorner = Instance.new("UICorner")
ItemCorner.CornerRadius = UDim.new(0, 5)
ItemCorner.Parent = ItemInput

-- Amount Input
local AmountInput = Instance.new("TextBox")
AmountInput.Size = UDim2.new(0.85, 0, 0, 28)
AmountInput.Position = UDim2.new(0.075, 0, 0, 40)
AmountInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
AmountInput.TextColor3 = Color3.white
AmountInput.PlaceholderText = "Amount (200)..."
AmountInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
AmountInput.Font = Enum.Font.Gotham
AmountInput.TextSize = 12
AmountInput.BorderSizePixel = 0
AmountInput.Parent = Frame

local AmountCorner = Instance.new("UICorner")
AmountCorner.CornerRadius = UDim.new(0, 5)
AmountCorner.Parent = AmountInput

-- Dupe Button
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(0.85, 0, 0, 32)
DupeBtn.Position = UDim2.new(0.075, 0, 0, 72)
DupeBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
DupeBtn.TextColor3 = Color3.white
DupeBtn.Text = "DUPE"
DupeBtn.Font = Enum.Font.GothamBold
DupeBtn.TextSize = 13
DupeBtn.BorderSizePixel = 0
DupeBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 7)
BtnCorner.Parent = DupeBtn

-- Button click
DupeBtn.MouseButton1Click:Connect(function()
    local itemName = ItemInput.Text:match("^%s*(.-)%s*$") or ""
    local amount = tonumber(AmountInput.Text) or 200
    
    if itemName == "" then
        print("ERROR: Enter item name")
        return
    end
    
    dupe(itemName, amount)
end)

-- Enter key support
ItemInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        DupeBtn:TriggerEvent("MouseButton1Click")
    end
end)

AmountInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        DupeBtn:TriggerEvent("MouseButton1Click")
    end
end)

-- ==================== GLOBAL FUNCTIONS ====================

getgenv().dupe = dupe

getgenv().closeUI = function()
    ScreenGui:Destroy()
end

print("✅ Script loaded!")
print("Use: getgenv().dupe('bamboo', 200)")
print("Or use UI and click DUPE")
