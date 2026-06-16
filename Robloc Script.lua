-- Grow a Garden 2 Dupe Tool - Mobile UI Version
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/Robloc%20Script.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ==================== DUPE FUNCTIONS ====================

local function dupeItem(itemName, amount)
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local item = backpack:FindFirstChild(itemName)
    
    if not item then
        return {success = false, message = "❌ Item not found: " .. itemName}
    end
    
    local cloned = 0
    for i = 1, amount do
        pcall(function()
            local clone = item:Clone()
            clone.Parent = backpack
            cloned = cloned + 1
        end)
    end
    
    return {success = true, message = "✅ Duped " .. cloned .. "x " .. itemName}
end

-- ==================== UI SETUP ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.85, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
MainFrame.BorderColor3 = Color3.fromRGB(80, 200, 80)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

-- Draggable functionality
local dragging = false
local dragStart
local framePos

MainFrame.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        framePos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = framePos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.8, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🌱 Dupe Tool"
TitleText.TextColor3 = Color3.fromRGB(200, 255, 200)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.2, -2, 1, 0)
CloseBtn.Position = UDim2.new(0.8, 2, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.TextColor3 = Color3.white
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

-- Item Name Label
local ItemLabel = Instance.new("TextLabel")
ItemLabel.Size = UDim2.new(1, -20, 0, 25)
ItemLabel.Position = UDim2.new(0, 10, 0, 50)
ItemLabel.BackgroundTransparency = 1
ItemLabel.Text = "Item Name:"
ItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ItemLabel.Font = Enum.Font.Gotham
ItemLabel.TextSize = 12
ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
ItemLabel.Parent = MainFrame

-- Item Name Input
local ItemInput = Instance.new("TextBox")
ItemInput.Size = UDim2.new(1, -20, 0, 35)
ItemInput.Position = UDim2.new(0, 10, 0, 75)
ItemInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ItemInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ItemInput.PlaceholderText = "e.g. bamboo"
ItemInput.Font = Enum.Font.Gotham
ItemInput.TextSize = 13
ItemInput.BorderSizePixel = 1
ItemInput.BorderColor3 = Color3.fromRGB(80, 80, 100)
ItemInput.Parent = MainFrame

-- Amount Label
local AmountLabel = Instance.new("TextLabel")
AmountLabel.Size = UDim2.new(1, -20, 0, 25)
AmountLabel.Position = UDim2.new(0, 10, 0, 120)
AmountLabel.BackgroundTransparency = 1
AmountLabel.Text = "Amount:"
AmountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AmountLabel.Font = Enum.Font.Gotham
AmountLabel.TextSize = 12
AmountLabel.TextXAlignment = Enum.TextXAlignment.Left
AmountLabel.Parent = MainFrame

-- Amount Input
local AmountInput = Instance.new("TextBox")
AmountInput.Size = UDim2.new(1, -20, 0, 35)
AmountInput.Position = UDim2.new(0, 10, 0, 145)
AmountInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AmountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
AmountInput.PlaceholderText = "e.g. 200"
AmountInput.Font = Enum.Font.Gotham
AmountInput.TextSize = 13
AmountInput.BorderSizePixel = 1
AmountInput.BorderColor3 = Color3.fromRGB(80, 80, 100)
AmountInput.Parent = MainFrame

-- Dupe Button
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(1, -20, 0, 40)
DupeBtn.Position = UDim2.new(0, 10, 0, 190)
DupeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
DupeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
DupeBtn.Text = "▶ DUPE"
DupeBtn.Font = Enum.Font.GothamBold
DupeBtn.TextSize = 14
DupeBtn.BorderSizePixel = 0
DupeBtn.Parent = MainFrame

-- Output Label
local OutputLabel = Instance.new("TextLabel")
OutputLabel.Size = UDim2.new(1, -20, 0, 60)
OutputLabel.Position = UDim2.new(0, 10, 0, 240)
OutputLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
OutputLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
OutputLabel.Text = "Ready..."
OutputLabel.TextWrapped = true
OutputLabel.Font = Enum.Font.GothamMonospace
OutputLabel.TextSize = 11
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.TextYAlignment = Enum.TextYAlignment.Top
OutputLabel.BorderSizePixel = 1
OutputLabel.BorderColor3 = Color3.fromRGB(80, 80, 100)
OutputLabel.Parent = MainFrame

-- ==================== BUTTON EVENTS ====================

DupeBtn.MouseButton1Click:Connect(function()
    local itemName = ItemInput.Text:match("^%s*(.-)%s*$")
    local amountStr = AmountInput.Text:match("^%s*(.-)%s*$")
    
    if not itemName or itemName == "" then
        OutputLabel.Text = "❌ Enter item name"
        return
    end
    
    local amount = tonumber(amountStr) or 10
    if amount < 1 then
        OutputLabel.Text = "❌ Amount must be 1+"
        return
    end
    
    OutputLabel.Text = "🔄 Duping..."
    local result = dupeItem(itemName, amount)
    OutputLabel.Text = result.message
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Allow Enter to dupe
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

-- ==================== GLOBAL FUNCTION ====================

getgenv().DupeUI = function()
    ScreenGui:Destroy()
end

print("✅ Dupe UI Loaded!")
print("Click the X button to close")
print("Or type: getgenv().DupeUI() to close")
