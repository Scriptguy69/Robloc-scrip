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
        for _, child
