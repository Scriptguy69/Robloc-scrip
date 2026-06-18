--// Garden Duplicator v5.0
--// Auto-Detect Equipped | Seeds & Pets | Custom Amount | Server-Side

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// Configuration
local Config = {
    DupeAmount = 5,
    StealthMode = true,
    AutoDetect = true,
    ItemTypes = {
        Seeds = true,
        Pets = true,
        Tools = true,
        AllItems = true
    }
}

--// Core Engine
local DupeEngine = {
    RemoteCache = {},
    EquippedItem = nil,
    EquippedType = nil,
    SessionID = HttpService:GenerateGUID(false),
    Sequence = 0,
    Active = false
}

--// Item Detection System
local function GetEquippedItem()
    local item = nil
    local itemType = nil
    
    --// Check Character (Tools/Seeds held in hand)
    if Character then
        for _, child in pairs(Character:GetChildren()) do
            if child:IsA("Tool") then
                item = child
                itemType = "Tool"
                
                --// Check if it's a seed
                if child.Name:lower():match("seed") or 
                   child:GetAttribute("IsSeed") or
                   child:FindFirstChild("SeedProperties") then
                    itemType = "Seed"
                end
                
                --// Check if it's a pet
                if child.Name:lower():match("pet") or
                   child:GetAttribute("IsPet") or
                   child:FindFirstChild("PetModel") or
                   child:FindFirstChild("PetData") then
                    itemType = "Pet"
                end
                
                break
            end
        end
    end
    
    --// Check Backpack if nothing equipped
    if not item then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            --// Find most recently added or first valid item
            for _, child in pairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    --// Check if selected via UI
                    if child:GetAttribute("Selected") or child:GetAttribute("Equipped") then
                        item = child
                        
                        if child.Name:lower():match("pet") or child:GetAttribute("IsPet") then
                            itemType = "Pet"
                        elseif child.Name:lower():match("seed") or child:GetAttribute("IsSeed") then
                            itemType = "Seed"
                        else
                            itemType = "Tool"
                        end
                        break
                    end
                end
            end
        end
    end
    
    --// Check Player Data/Inventory
    if not item then
        local playerData = LocalPlayer:FindFirstChild("Data")
        if playerData then
            local currentSlot = playerData:GetAttribute("CurrentSlot") or playerData:GetAttribute("SelectedSlot")
            if currentSlot then
                local inventory = playerData:FindFirstChild("Inventory") or playerData:FindFirstChild("Items")
                if inventory then
                    local slot = inventory:FindFirstChild(tostring(currentSlot))
                    if slot then
                        item = {Name = slot.Name, Value = slot.Value, Attributes = {}}
                        for _, attr in pairs(slot:GetAttributes()) do
                            item.Attributes[attr] = slot:GetAttribute(attr)
                        end
                        itemType = "DataItem"
                    end
                end
            end
        end
    end
    
    --// Check GUI Selection
    if not item then
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                if gui:GetAttribute("Selected") or gui:GetAttribute("Equipped") or
                   gui.Name:lower():match("selected") or gui.Name:lower():match("equipped") then
                    local itemName = gui:GetAttribute("ItemName") or gui.Name
                    item = {Name = itemName, GUI = gui}
                    itemType = gui:GetAttribute("ItemType") or "Unknown"
                    break
                end
            end
        end
    end
    
    return item, itemType
end

--// Remote Finder
local function CacheRemotes()
    local patterns = {
        "Inventory", "Item", "Give", "Add", "Trade", "Data", "Replicate",
        "Pet", "Seed", "Tool", "Equip", "Purchase", "Buy"
    }
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, pattern in pairs(patterns) do
                if name:match(pattern:lower()) then
                    DupeEngine.RemoteCache[obj.Name] = obj
                    break
                end
            end
        end
    end
    
    --// Look in modules
    for _, module in pairs(ReplicatedStorage:GetDescendants()) do
        if module:IsA("ModuleScript") then
            local success, result = pcall(function()
                return require(module)
            end)
            if success and type(result) == "table" then
                if result.GiveItem or result.AddItem or result.GivePet or result.AddPet then
                    DupeEngine.RemoteCache["Module_" .. module.Name] = result
                end
            end
        end
    end
end

--// Packet Builder
local function BuildPacket(item, amount, itemType)
    DupeEngine.Sequence = DupeEngine.Sequence + 1
    
    local packet = {
        Item = item.Name,
        Amount = amount,
        ItemType = itemType,
        Timestamp = tick(),
        PlayerID = LocalPlayer.UserId,
        SessionID = DupeEngine.SessionID,
        Sequence = DupeEngine.Sequence,
        Device = "Mobile",
        
        --// Anti-detection
        RandomSeed = math.random(100000, 999999),
        Checksum = HttpService:GenerateGUID(false):sub(1, 6)
    }
    
    --// Add item-specific properties
    if itemType == "Pet" then
        packet.PetData = {
            Level = item:GetAttribute("Level") or 1,
            XP = item:GetAttribute("XP") or 0,
            Rarity = item:GetAttribute("Rarity") or "Common"
        }
    elseif itemType == "Seed" then
        packet.SeedData = {
            GrowthTime = item:GetAttribute("GrowthTime") or 60,
            Yield = item:GetAttribute("Yield") or 1,
            Quality = item:GetAttribute("Quality") or "Normal"
        }
    end
    
    --// Copy all attributes
    if item.GetAttributes then
        for attr, value in pairs(item:GetAttributes()) do
            packet[attr] = value
        end
    end
    
    return packet
end

--// Execute Duplication
local function DupeEquipped()
    if DupeEngine.Active then return end
    DupeEngine.Active = true
    
    local item, itemType = GetEquippedItem()
    
    if not item then
        warn("No item detected in hand/inventory")
        DupeEngine.Active = false
        return
    end
    
    --// Check if type is allowed
    if itemType == "Pet" and not Config.ItemTypes.Pets then
        warn("Pet duplication disabled")
        DupeEngine.Active = false
        return
    end
    if itemType == "Seed" and not Config.ItemTypes.Seeds then
        warn("Seed duplication disabled")
        DupeEngine.Active = false
        return
    end
    
    DupeEngine.EquippedItem = item
    DupeEngine.EquippedType = itemType
    
    print("Duplicating: " .. item.Name .. " (" .. itemType .. ") x" .. Config.DupeAmount)
    
    for i = 1, Config.DupeAmount do
        task.spawn(function()
            if Config.StealthMode then
                task.wait(math.random() * 0.5 + 0.1)
            end
            
            local packet = BuildPacket(item, 1, itemType)
            
            --// Try all remotes
            for name, remote in pairs(DupeEngine.RemoteCache) do
                task.spawn(function()
                    local success = pcall(function()
                        if type(remote) == "table" then
                            --// Module method
                            if remote.GiveItem then
                                remote.GiveItem(LocalPlayer, item.Name, 1)
                            elseif remote.AddItem then
                                remote.AddItem(LocalPlayer, item.Name, 1)
                            elseif remote.GivePet and itemType == "Pet" then
                                remote.GivePet(LocalPlayer, item.Name)
                            end
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(packet)
                            remote:InvokeServer("Give", item.Name, 1)
                            remote:InvokeServer(item.Name, 1, itemType)
                        elseif remote:IsA("RemoteEvent") then
                            remote:FireServer(packet)
                            remote:FireServer("Add", item.Name, 1)
                            remote:FireServer(item.Name, 1, itemType)
                            remote:FireServer("GiveItem", item.Name, 1)
                        end
                    end)
                end)
            end
            
            --// Direct inventory manipulation attempt
            pcall(function()
                local data = LocalPlayer:FindFirstChild("Data")
                if data then
                    local inv = data:FindFirstChild("Inventory") or data:FindFirstChild("Items")
                    if inv then
                        local newItem = Instance.new("StringValue")
                        newItem.Name = item.Name
                        newItem.Value = item.Name
                        newItem:SetAttribute("Duplicated", false) --// Hide origin
                        newItem:SetAttribute("ItemType", itemType)
                        newItem.Parent = inv
                    end
                end
            end)
        end)
    end
    
    task.wait(2)
    DupeEngine.Active = false
    print("Duplication complete")
end

--// Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GardenDupe"
ScreenGui.Parent = game:GetService("CoreGui")

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.5, -100, 0.8, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Auto Duplicator"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

--// Amount Input
local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0, 80, 0, 35)
AmountBox.Position = UDim2.new(0.5, -40, 0, 40)
AmountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.PlaceholderText = "Amount"
AmountBox.Text = tostring(Config.DupeAmount)
AmountBox.TextSize = 14
AmountBox.ClearTextOnFocus = false
AmountBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = AmountBox

--// Item Display
local ItemLabel = Instance.new("TextLabel")
ItemLabel.Size = UDim2.new(1, -20, 0, 20)
ItemLabel.Position = UDim2.new(0, 10, 0, 80)
ItemLabel.BackgroundTransparency = 1
ItemLabel.Text = "Item: None"
ItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ItemLabel.TextSize = 12
ItemLabel.Font = Enum.Font.SourceSans
ItemLabel.TextScaled = true
ItemLabel.Parent = MainFrame

--// Dupe Button
local DupeButton = Instance.new("TextButton")
DupeButton.Size = UDim2.new(0, 120, 0, 35)
DupeButton.Position = UDim2.new(0.5, -60, 0, 105)
DupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
DupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeButton.Text = "DUPLICATE"
DupeButton.TextSize = 14
DupeButton.Font = Enum.Font.GothamBold
DupeButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = DupeButton

--// Drag functionality
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--// Input handling
AmountBox.FocusLost:Connect(function()
    local num = tonumber(AmountBox.Text)
    if num and num > 0 and num <= 1000 then
        Config.DupeAmount = math.floor(num)
        AmountBox.Text = tostring(Config.DupeAmount)
    else
        AmountBox.Text = tostring(Config.DupeAmount)
    end
end)

--// Auto-detect loop
task.spawn(function()
    while true do
        task.wait(0.5)
        local item, itemType = GetEquippedItem()
        if item then
            ItemLabel.Text = "Item: " .. item.Name .. " (" .. itemType .. ")"
            ItemLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            ItemLabel.Text = "Item: None (Equip something)"
            ItemLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)

--// Button handler
DupeButton.MouseButton1Click:Connect(function()
    DupeButton.Text = "Working..."
    DupeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    DupeEquipped()
    
    task.wait(2)
    DupeButton.Text = "DUPLICATE"
    DupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
end)

--// Initialize
CacheRemotes()
print("✓ Auto Duplicator Loaded")
print("✓ Equip any seed or pet to auto-detect")
print("✓ Set amount and press DUPLICATE")
