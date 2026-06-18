--// Garden Duplicator v5.1 (Refined)
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

--// Item Detection System (Refined)
local function GetEquippedItem()
    local item = nil
    local itemType = nil
    
    -- Prioritize checking character for equipped tool
    if Character then
        for _, child in pairs(Character:GetChildren()) do
            if child:IsA("Tool") then
                item = child
                itemType = "Tool"
                
                -- Check for specific attributes or children to determine type
                if child:FindFirstChild("SeedProperties") or child:GetAttribute("IsSeed") or child.Name:lower():match("seed") then
                    itemType = "Seed"
                elseif child:FindFirstChild("PetModel") or child:FindFirstChild("PetData") or child:GetAttribute("IsPet") or child.Name:lower():match("pet") then
                    itemType = "Pet"
                end
                
                -- If we found an item in character, this is the most likely one. Return immediately.
                return item, itemType
            end
        end
    end
    
    -- Fallback to checking Backpack if nothing is in hand
    local backpack = LocalPlayer:WaitForChild("Backpack", 2)
    if backpack then
        -- Find the first tool that might be the intended one
        for _, child in pairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                -- A simple heuristic: the first tool is often the one the player is about to use or just used.
                item = child
                itemType = "Tool"
                if child.Name:lower():match("pet") or child:GetAttribute("IsPet") then
                    itemType = "Pet"
                elseif child.Name:lower():match("seed") or child:GetAttribute("IsSeed") then
                    itemType = "Seed"
                end
                -- We'll return the first one we find to avoid ambiguity.
                return item, itemType
            end
        end
    end
    
    return nil, nil
end

--// Remote Finder (Refined)
local function CacheRemotes()
    -- Clear cache to avoid stale remotes if the game updates
    DupeEngine.RemoteCache = {}
    
    -- Look for specific, common remote event names
    local commonRemotes = {"GiveItem", "AddItem", "GivePet", "AddPet", "InventoryEvent", "ItemEvent"}
    for _, name in pairs(commonRemotes) do
        if ReplicatedStorage:FindFirstChild(name) then
            DupeEngine.RemoteCache[name] = ReplicatedStorage:FindFirstChild(name)
        end
    end
    
    -- If common ones aren't found, do a more general search
    if next(DupeEngine.RemoteCache) == nil then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                -- More targeted patterns
                if name:match("give") or name:match("add") or name:match("replicate") then
                    DupeEngine.RemoteCache[obj.Name] = obj
                end
            end
        end
    end
end

--// Execute Duplication (Simplified and Focused)
local function DupeEquipped()
    if DupeEngine.Active then return end
    DupeEngine.Active = true
    
    local item, itemType = GetEquippedItem()
    
    if not item then
        warn("No item detected. Please equip a seed or pet.")
        DupeEngine.Active = false
        return
    end
    
    if itemType == "Pet" and not Config.ItemTypes.Pets then
        warn("Pet duplication is disabled in config.")
        DupeEngine.Active = false
        return
    end
    if itemType == "Seed" and not Config.ItemTypes.Seeds then
        warn("Seed duplication is disabled in config.")
        DupeEngine.Active = false
        return
    end
    
    DupeEngine.EquippedItem = item
    DupeEngine.EquippedType = itemType
    
    print("Attempting to duplicate: " .. item.Name .. " (" .. itemType .. ") x" .. Config.DupeAmount)
    
    -- Build a simple, clean packet
    local packet = {
        ItemName = item.Name,
        Amount = 1,
        Player = LocalPlayer
    }
    
    -- Try the most likely remotes first
    local success = false
    for i = 1, Config.DupeAmount do
        if Config.StealthMode then
            task.wait(math.random(0.1, 0.3)) -- Shorter, less suspicious delay
        end
        
        -- Try GiveItem remote first
        if DupeEngine.RemoteCache["GiveItem"] then
            pcall(function()
                DupeEngine.RemoteCache["GiveItem"]:FireServer(packet)
                success = true
            end)
        end
        
        -- Try AddItem remote
        if DupeEngine.RemoteCache["AddItem"] and not success then
            pcall(function()
                DupeEngine.RemoteCache["AddItem"]:FireServer(packet)
                success = true
            end)
        end
        
        -- Try generic remotes as a last resort
        if not success then
            for name, remote in pairs(DupeEngine.RemoteCache) do
                pcall(function()
                    remote:FireServer("Add", packet)
                    success = true
                end)
                if success then break end
            end
        end
        
        success = false -- Reset for the next iteration
    end
    
    task.wait(1) -- Shorter wait time
    DupeEngine.Active = false
    print("Duplication attempt complete. Check your inventory.")
end

--// Create UI (Unchanged)
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
