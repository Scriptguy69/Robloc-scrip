-- Grow a Garden 2 Dupe Script - Anti-Cheat Bypass Version
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/Robloc%20Script.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- ==================== ANTI-CHEAT BYPASS ====================

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
            
            if i % 15 == 0 then
                wait(0.01)
            end
        end)
    end
    
    print("✅ Successfully duped " .. tostring(cloned) .. "x " .. itemName)
    return true
end

-- ==================== UI ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 160)
Frame.Position = UDim2.new(0.5, -130, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
Title.TextColor3 = Color3.white
Title.Text = "Dupe Tool"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Item Input Label
local ItemLabel = Instance.new("TextLabel")
ItemLabel.Size = UDim2.new(0.4, 0, 0, 20)
ItemLabel.Position = UDim2.new(0.05, 0, 0, 35)
ItemLabel.BackgroundTransparency = 1
ItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ItemLabel.Text = "Item:"
ItemLabel.Font = Enum.Font.Gotham
ItemLabel.TextSize = 11
ItemLabel.Parent = Frame

-- Item Input
local ItemInput = Instance.new("TextBox")
ItemInput.Size = UDim2.new(0.9, 0, 0, 22)
ItemInput.Position = UDim2.new(0.05, 0, 0, 55)
ItemInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ItemInput.TextColor3 = Color3.white
ItemInput.PlaceholderText = "bamboo"
ItemInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ItemInput.Font = Enum.Font.Gotham
ItemInput.TextSize = 11
ItemInput.BorderSizePixel = 0
ItemInput.Parent = Frame

local ItemCorner = Instance.new("UICorner")
ItemCorner.CornerRadius = UDim.new(0, 4)
ItemCorner.Parent = ItemInput

-- Amount Input Label
local AmountLabel = Instance.new("TextLabel")
AmountLabel.Size = UDim2.new(0.4, 0, 0, 20)
AmountLabel.Position = UDim2.new(0.05, 0, 0, 80)
AmountLabel.BackgroundTransparency = 1
AmountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AmountLabel.Text = "Amount:"
AmountLabel.Font = Enum.Font.Gotham
AmountLabel.TextSize = 11
AmountLabel.Parent = Frame

-- Amount Input
local AmountInput = Instance.new("TextBox")
AmountInput.Size = UDim2.new(0.9, 0, 0, 22)
AmountInput.Position = UDim2.new(0.05, 0, 0, 100)
AmountInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AmountInput.TextColor3 = Color3.white
AmountInput.PlaceholderText = "200"
AmountInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
AmountInput.Font = Enum.Font.Gotham
AmountInput.TextSize = 11
AmountInput.BorderSizePixel = 0
AmountInput.Parent = Frame

local AmountCorner = Instance.new("UICorner")
AmountCorner.CornerRadius = UDim.new(0, 4)
AmountCorner.Parent = AmountInput

-- Dupe Button
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(0.9, 0, 0, 28)
DupeBtn.Position = UDim2.new(0.05, 0, 0, 128)
DupeBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
DupeBtn.TextColor3 = Color3.white
DupeBtn.Text = "DUPE"
DupeBtn.Font = Enum.Font.GothamBold
DupeBtn.TextSize = 12
DupeBtn.BorderSizePixel = 0
DupeBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
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
