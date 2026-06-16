-- Grow a Garden 2 Dupe Script - Functional Version
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/Robloc%20Script.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Simple dupe function
local function dupe(itemName, amount)
    -- Find the item in backpack
    local item = Backpack:FindFirstChild(itemName)
    
    if not item then
        print("❌ Item not found: " .. itemName)
        return false
    end
    
    print("🔄 Duping " .. itemName .. " x" .. amount .. "...")
    
    local cloned = 0
    for i = 1, amount do
        pcall(function()
            local clone = item:Clone()
            clone.Parent = Backpack
            cloned = cloned + 1
        end)
    end
    
    print("✅ Successfully duped " .. cloned .. "x " .. itemName)
    return true
end

-- Set global function
getgenv().dupe = dupe

-- Also create a simple UI for input (basic, functional only)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.Parent = ScreenGui

local ItemLabel = Instance.new("TextLabel")
ItemLabel.Size = UDim2.new(1, 0, 0, 20)
ItemLabel.Position = UDim2.new(0, 0, 0, 0)
ItemLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ItemLabel.TextColor3 = Color3.white
ItemLabel.Text = "Item Name"
ItemLabel.Font = Enum.Font.GothamBold
ItemLabel.TextSize = 12
ItemLabel.Parent = Frame

local ItemInput = Instance.new("TextBox")
ItemInput.Size = UDim2.new(1, -10, 0, 25)
ItemInput.Position = UDim2.new(0, 5, 0, 25)
ItemInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ItemInput.TextColor3 = Color3.white
ItemInput.PlaceholderText = "bamboo"
ItemInput.Font = Enum.Font.Gotham
ItemInput.TextSize = 12
ItemInput.Parent = Frame

local AmountLabel = Instance.new("TextLabel")
AmountLabel.Size = UDim2.new(1, 0, 0, 20)
AmountLabel.Position = UDim2.new(0, 0, 0, 55)
AmountLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AmountLabel.TextColor3 = Color3.white
AmountLabel.Text = "Amount"
AmountLabel.Font = Enum.Font.GothamBold
AmountLabel.TextSize = 12
AmountLabel.Parent = Frame

local AmountInput = Instance.new("TextBox")
AmountInput.Size = UDim2.new(1, -10, 0, 25)
AmountInput.Position = UDim2.new(0, 5, 0, 80)
AmountInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AmountInput.TextColor3 = Color3.white
AmountInput.PlaceholderText = "200"
AmountInput.Font = Enum.Font.Gotham
AmountInput.TextSize = 12
AmountInput.Parent = Frame

local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(1, -10, 0, 25)
DupeBtn.Position = UDim2.new(0, 5, 0, 115)
DupeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
DupeBtn.TextColor3 = Color3.white
DupeBtn.Text = "DUPE"
DupeBtn.Font = Enum.Font.GothamBold
DupeBtn.TextSize = 12
DupeBtn.Parent = Frame

-- Button click event
DupeBtn.MouseButton1Click:Connect(function()
    local itemName = ItemInput.Text
    local amount = tonumber(AmountInput.Text) or 200
    
    if itemName == "" then
        print("ERROR: Enter item name")
        return
    end
    
    dupe(itemName, amount)
end)

-- Allow Enter key to dupe
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

print("✅ Script loaded! Type in UI and click DUPE")
print("Or use in console: getgenv().dupe('bamboo', 200)")
