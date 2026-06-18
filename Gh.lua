--// Garden Duplicator v6.0 (Intelligent System)
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
    DebugMode = true, -- Set to false to stop printing debug info
    ItemTypes = {
        Seeds = true,
        Pets = true,
        Tools = true,
        AllItems = true
    }
}

--// Core Engine
local DupeEngine = {
    RemoteEvents = {},
    RemoteFunctions = {},
    EquippedItem = nil,
    EquippedType = nil,
    SessionID = HttpService:GenerateGUID(false),
    Sequence = 0,
    Active = false,
    FoundRemotes = false -- Flag to check if we found potential remotes
}

--// Print function for debugging
local function debugPrint(...)
    if Config.DebugMode then
        print("[GardenDupe]", ...)
    end
end

--// Item Detection System (Refined)
local function GetEquippedItem()
    local item = nil
    local itemType = nil
    
    if Character then
        for _, child in pairs(Character:GetChildren()) do
            if child:IsA("Tool") then
                item = child
                itemType = "Tool"
                
                if child:FindFirstChild("SeedProperties") or child:GetAttribute("IsSeed") or child.Name:lower():match("seed") then
                    itemType = "Seed"
                elseif child:FindFirstChild("PetModel") or child:FindFirstChild("PetData") or child:GetAttribute("IsPet") or child.Name:lower():match("pet") then
                    itemType = "Pet"
                end
                
                debugPrint("Detected equipped item:", item.Name, "Type:", itemType)
                return item, itemType
            end
        end
    end
    
    local backpack = LocalPlayer:WaitForChild("Backpack", 2)
    if backpack then
        for _, child in pairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                item = child
                itemType = "Tool"
                if child.Name:lower():match("pet") or child:GetAttribute("IsPet") then
                    itemType = "Pet"
                elseif child.Name:lower():match("seed") or child:GetAttribute("IsSeed") then
                    itemType = "Seed"
                end
                debugPrint("Detected backpack item:", item.Name, "Type:", itemType)
                return item, itemType
            end
        end
    end
    
    debugPrint("No item detected.")
    return nil, nil
end

--// Intelligent Remote Finder
local function FindAndAnalyzeRemotes()
    debugPrint("Starting remote analysis...")
    DupeEngine.RemoteEvents = {}
    DupeEngine.RemoteFunctions = {}
    
    -- Look for specific, common remote event names
    local commonRemotes = {"GiveItem", "AddItem", "GivePet", "AddPet", "InventoryEvent", "ItemEvent", "PurchaseItem", "BuyItem", "EquipItem"}
    for _, name in pairs(commonRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name, true)
        if remote then
            if remote:IsA("RemoteEvent") then
                DupeEngine.RemoteEvents[remote.Name] = remote
                debugPrint("Found common RemoteEvent:", remote.Name)
            elseif remote:IsA("RemoteFunction") then
                DupeEngine.RemoteFunctions[remote.Name] = remote
                debugPrint("Found common RemoteFunction:", remote.Name)
            end
        end
    end

    -- If common ones aren't found, do a more general search
    if next(DupeEngine.RemoteEvents) == nil and next(DupeEngine.RemoteFunctions) == nil then
        debugPrint("No common remotes found, performing general search...")
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:match("give") or name:match("add") or name:match("item") or name:match("inv") or name:match("purchase") or name:match("buy") then
                    if obj:IsA("RemoteEvent") then
                        DupeEngine.RemoteEvents[obj.Name] = obj
                        debugPrint("Found general RemoteEvent:", obj.Name)
                    else
                        DupeEngine.RemoteFunctions[obj.Name] = obj
                        debugPrint("Found general RemoteFunction:", obj.Name)
                    end
                end
            end
        end
    end

    if next(DupeEngine.RemoteEvents) ~= nil or next(DupeEngine.RemoteFunctions) ~= nil then
        DupeEngine.FoundRemotes = true
        debugPrint("Remote analysis complete. Found potential targets.")
    else
        DupeEngine.FoundRemotes = false
        debugPrint("Remote analysis complete. No potential targets found.")
    end
end

--// Execute Duplication (Intelligent and Focused)
local function DupeEquipped()
    if DupeEngine.Active then 
        debugPrint("Dupe already in progress.")
        return 
    end
    DupeEngine.Active = true
    
    if not DupeEngine.FoundRemotes then
        warn("Cannot dupe: No valid remotes found. Check console (F9) for details.")
        DupeEngine.Active = false
        return
    end

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
    
    debugPrint("Attempting to duplicate:", item.Name, "(", itemType, ") x", Config.DupeAmount)
    
    -- Try different packet structures and remote calls
    for i = 1, Config.DupeAmount do
        if Config.StealthMode then
            task.wait(math.random(0.1, 0.3))
        end
        
        -- Attempt 1: Simple item name
        for name, remote in pairs(DupeEngine.RemoteEvents) do
            pcall(function()
                debugPrint("Attempt 1 - Firing", name, "with item name:", item.Name)
                remote:FireServer(item.Name)
            end)
        end
        for name, remote in pairs(DupeEngine.RemoteFunctions) do
            pcall(function()
                debugPrint("Attempt 1 - Invoking", name, "with item name:", item.Name)
                remote:InvokeServer(item.Name)
            end)
        end
        
        task.wait(0.1)

        -- Attempt 2: Item name and player
        for name, remote in pairs(DupeEngine.RemoteEvents) do
            pcall(function()
                debugPrint("Attempt 2 - Firing", name, "with item name and player.")
                remote:FireServer(item.Name, LocalPlayer)
            end)
        end
        for name, remote in pairs(DupeEngine.RemoteFunctions) do
            pcall(function()
                debugPrint("Attempt 2 - Invoking", name, "with item name and player.")
                remote:InvokeServer(item.Name, LocalPlayer)
            end)
        end
        
        task.wait(0.1)

        -- Attempt 3: Item object itself
        for name, remote in pairs(DupeEngine.RemoteEvents) do
            pcall(function()
                debugPrint("Attempt 3 - Firing", name, "with item object.")
                remote:FireServer(item)
            end)
        end
        for name, remote in pairs(DupeEngine.RemoteFunctions) do
            pcall(function()
                debugPrint("Attempt 3 - Invoking", name, "with item object.")
                remote:InvokeServer(item)
            end)
        end
    end
    
    task.wait(1)
    DupeEngine.Active = false
    print("Duplication attempt complete. Check your inventory.")
end

--// Create UI (Unchanged)
local ScreenGui = Instance.new("ScreenGui")
