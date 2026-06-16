-- Grow a Garden 2 Dupe Script - Delta Executor Edition
-- Optimized for Mobile Execution

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ==================== DUPE FUNCTIONS ====================

local function duplicateSeeds(seedName, amount)
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local itemToFind = backpack:FindFirstChild(seedName)
    
    if not itemToFind then
        return "❌ Samen nicht gefunden: " .. seedName
    end
    
    local cloned = 0
    for i = 1, amount do
        pcall(function()
            local clone = itemToFind:Clone()
            clone.Parent = backpack
            cloned = cloned + 1
        end)
    end
    
    return "✅ " .. cloned .. "x " .. seedName .. " dupliziert"
end

local function duplicatePets(petName, amount)
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local itemToFind = backpack:FindFirstChild(petName)
    
    if not itemToFind then
        return "❌ Haustier nicht gefunden: " .. petName
    end
    
    local cloned = 0
    for i = 1, amount do
        pcall(function()
            local clone = itemToFind:Clone()
            clone.Parent = backpack
            cloned = cloned + 1
        end)
    end
    
    return "✅ " .. cloned .. "x " .. petName .. " dupliziert"
end

-- ==================== COMMAND PROCESSOR ====================

local commands = {
    ["dupeseed"] = function(args)
        local seedName = args[1] or "DefaultSeed"
        local amount = tonumber(args[2]) or 10
        return duplicateSeeds(seedName, amount)
    end,
    
    ["dupepet"] = function(args)
        local petName = args[1] or "DefaultPet"
        local amount = tonumber(args[2]) or 5
        return duplicatePets(petName, amount)
    end,
    
    ["help"] = function()
        return "📋 VERFÜGBARE BEFEHLE:\n" ..
               "dupeseed [Name] [Anzahl] - Samen duplizieren\n" ..
               "dupepet [Name] [Anzahl] - Haustiere duplizieren\n" ..
               "help - Diese Hilfe anzeigen"
    end
}

local function processCommand(command)
    local parts = {}
    for part in command:gmatch("%S+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then
        return "❌ Bitte geben Sie einen Befehl ein."
    end
    
    local cmd = parts[1]:lower()
    local args = {}
    
    for i = 2, #parts do
        table.insert(args, parts[i])
    end
    
    if commands[cmd] then
        return commands[cmd](args)
    else
        return "❌ Unbekannter Befehl: " .. cmd .. "\nGib 'help' ein für verfügbare Befehle."
    end
end

-- ==================== UI SETUP ====================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 320, 0, 380)
Frame.Position = UDim2.new(0.5, -160, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(100, 200, 100)
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
Title.BackgroundTransparency = 0
Title.Text = "🌱 Grow a Garden 2 Dupe"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

-- Command Input
local TextBox = Instance.new("TextBox")
TextBox.Name = "CommandInput"
TextBox.Size = UDim2.new(1, -20, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 55)
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
TextBox.PlaceholderText = "Befehl eingeben (z.B. dupeseed Seed 10)"
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Parent = Frame

-- Execute Button
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteBtn"
ExecuteButton.Size = UDim2.new(0.5, -7, 0, 40)
ExecuteButton.Position = UDim2.new(0, 10, 0, 105)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.Text = "▶ Ausführen"
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.TextSize = 14
ExecuteButton.Parent = Frame

-- Help Button
local HelpButton = Instance.new("TextButton")
HelpButton.Name = "HelpBtn"
HelpButton.Size = UDim2.new(0.5, -7, 0, 40)
HelpButton.Position = UDim2.new(0.5, 4, 0, 105)
HelpButton.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
HelpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HelpButton.Text = "❓ Hilfe"
HelpButton.Font = Enum.Font.GothamBold
HelpButton.TextSize = 14
HelpButton.Parent = Frame

-- Output Label
local OutputLabel = Instance.new("TextLabel")
OutputLabel.Name = "Output"
OutputLabel.Size = UDim2.new(1, -20, 0, 140)
OutputLabel.Position = UDim2.new(0, 10, 0, 155)
OutputLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
OutputLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
OutputLabel.Text = "🔄 Bereit..."
OutputLabel.TextWrapped = true
OutputLabel.Font = Enum.Font.GothamMonospace
OutputLabel.TextSize = 12
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.TextYAlignment = Enum.TextYAlignment.Top
OutputLabel.Parent = Frame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseBtn"
CloseButton.Size = UDim2.new(1, -20, 0, 35)
CloseButton.Position = UDim2.new(0, 10, 0, 305)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "✕ Schließen"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = Frame

-- ==================== BUTTON EVENTS ====================

ExecuteButton.MouseButton1Click:Connect(function()
    local command = TextBox.Text:match("^%s*(.-)%s*$") or ""
    if command ~= "" then
        local result = processCommand(command)
        OutputLabel.Text = result
        TextBox.Text = ""
    else
        OutputLabel.Text = "❌ Bitte geben Sie einen Befehl ein."
    end
end)

HelpButton.MouseButton1Click:Connect(function()
    OutputLabel.Text = processCommand("help")
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Allow Enter key to execute
TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ExecuteButton:TriggerEvent("MouseButton1Click")
    end
end)

-- ==================== GLOBAL FUNCTIONS ====================

getgenv().DupeGUI = {
    execute = function(command)
        return processCommand(command)
    end,
    dupeSeed = duplicateSeeds,
    dupePet = duplicatePets,
    close = function()
        ScreenGui:Destroy()
    end
}

print("✅ Delta Executor Dupe Script geladen!")
print("Nutze: getgenv().DupeGUI.execute('help') für Befehle")
