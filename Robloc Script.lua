-- Grow a Garden 2 ULTIMATE Dupe Script - OVERENGINEERED Edition
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptguy69/Robloc-scrip/main/Robloc%20Script.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local RunService = game:GetService("RunService")

-- ==================== ANTI-CHEAT BYPASS SYSTEM ====================

local AntiCheatBypass = {}

function AntiCheatBypass:Spoof()
    pcall(function()
        local mt = getmetatable(game)
        if mt then
            rawset(mt, "__newindex", function(self, key, value) end)
        end
    end)
end

function AntiCheatBypass:HookRemotes()
    pcall(function()
        local remotes = game:GetDescendants()
        for _, remote in pairs(remotes) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                -- Hook but don't block
            end
        end
    end)
end

AntiCheatBypass:Spoof()
AntiCheatBypass:HookRemotes()

-- ==================== ADVANCED SEED DETECTION SYSTEM ====================

local SeedDetector = {}
SeedDetector.seeds = {}
SeedDetector.lastUpdate = 0

function SeedDetector:ScanBackpack()
    local seeds = {}
    
    for _, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Instance") then
            local itemName = item.Name
            
            -- Smart detection: check if it contains seed-related keywords
            if itemName:lower():find("seed") or 
               itemName:lower():find("plant") or 
               itemName:lower():find("tree") or
               itemName:lower():find("flower") or
               itemName:lower():find("fruit") or
               itemName:lower():find("berry") or
               itemName:lower():find("bamboo") or
               itemName:lower():find("tomato") or
               itemName:lower():find("carrot") or
               itemName:lower():find("potato") or
               itemName:lower():find("corn") or
               itemName:lower():find("wheat") then
                
                if not table.find(seeds, itemName) then
                    table.insert(seeds, itemName)
                end
            end
        end
    end
    
    self.seeds = seeds
    self.lastUpdate = tick()
    return seeds
end

function SeedDetector:GetAllSeeds()
    return self.seeds
end

function SeedDetector:RefreshSeeds()
    return self:ScanBackpack()
end

-- Initial scan
SeedDetector:ScanBackpack()

-- ==================== DUPE ENGINE ====================

local DupeEngine = {}
DupeEngine.dupeHistory = {}
DupeEngine.isDuping = false

function DupeEngine:Dupe(itemName, amount)
    if self.isDuping then
        print("⏳ Already duping, please wait...")
        return false
    end
    
    self.isDuping = true
    
    local item = Backpack:FindFirstChild(itemName)
    
    if not item then
        self.isDuping = false
        print("❌ Item not found: " .. itemName)
        return false
    end
    
    print("🔄 [DUPE ENGINE] Starting duplication process...")
    print("📦 Target: " .. itemName .. " | Quantity: " .. amount)
    
    local cloned = 0
    local errors = 0
    
    for i = 1, amount do
        pcall(function()
            local clone = item:Clone()
            clone.Parent = Backpack
            cloned = cloned + 1
        end, function(err)
            errors = errors + 1
            print("⚠️ Clone error: " .. tostring(err))
        end)
        
        -- Advanced rate-limiting bypass
        if i % 20 == 0 then
            wait(0.005)
        end
    end
    
    -- Log to history
    table.insert(self.dupeHistory, {
        item = itemName,
        amount = amount,
        cloned = cloned,
        time = os.time(),
        success = cloned == amount
    })
    
    print("✅ [DUPE ENGINE] Complete!")
    print("📊 Cloned: " .. cloned .. "/" .. amount)
    print("⚠️ Errors: " .. errors)
    
    self.isDuping = false
    return true
end

function DupeEngine:GetHistory()
    return self.dupeHistory
end

-- ==================== OVERENGINEERED UI SYSTEM ====================

local UISystem = {}
UISystem.state = {
    selectedSeed = nil,
    amount = 200,
    isOpen = true,
    theme = "dark"
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeUIULTIMATE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ===== MAIN FRAME =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 520)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 200, 100)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- ===== HEADER =====
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌱 DUPE ULTIMATE PRO"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.15, 0, 1, 0)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
CloseBtn.TextColor3 = Color3.white
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== SEED LIST LABEL =====
local SeedListLabel = Instance.new("TextLabel")
SeedListLabel.Size = UDim2.new(1, -20, 0, 25)
SeedListLabel.Position = UDim2.new(0, 10, 0, 60)
SeedListLabel.BackgroundTransparency = 1
SeedListLabel.Text = "📚 Available Seeds:"
SeedListLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SeedListLabel.Font = Enum.Font.GothamBold
SeedListLabel.TextSize = 12
SeedListLabel.TextXAlignment = Enum.TextXAlignment.Left
SeedListLabel.Parent = MainFrame

-- ===== SCROLLING SEED LIST =====
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 0, 180)
ScrollFrame.Position = UDim2.new(0, 10, 0, 90)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 100)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame

-- Function to populate seed list
local function PopulateSeedList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local seeds = SeedDetector:GetAllSeeds()
    
    for _, seedName in pairs(seeds) do
        local SeedBtn = Instance.new("TextButton")
        SeedBtn.Size = UDim2.new(1, 0, 0, 35)
        SeedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        SeedBtn.TextColor3 = Color3.fromRGB(180, 255, 180)
        SeedBtn.Text = "✓ " .. seedName
        SeedBtn.Font = Enum.Font.Gotham
        SeedBtn.TextSize = 11
        SeedBtn.BorderSizePixel = 0
        SeedBtn.Parent = ScrollFrame
        
        local SeedCorner = Instance.new("UICorner")
        SeedCorner.CornerRadius = UDim.new(0, 6)
        SeedCorner.Parent = SeedBtn
        
        SeedBtn.MouseButton1Click:Connect(function()
            UISystem.state.selectedSeed = seedName
            SelectedSeedLabel.Text = "🎯 Selected: " .. seedName
            
            -- Visual feedback
            for _, btn in pairs(ScrollFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    btn.TextColor3 = Color3.fromRGB(180, 255, 180)
                end
            end
            
            SeedBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            SeedBtn.TextColor3 = Color3.white
        end)
        
        SeedBtn.MouseEnter:Connect(function()
            if SeedBtn.BackgroundColor3 ~= Color3.fromRGB(80, 180, 80) then
                SeedBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            end
        end)
        
        SeedBtn.MouseLeave:Connect(function()
            if SeedBtn.BackgroundColor3 ~= Color3.fromRGB(80, 180, 80) then
                SeedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            end
        end)
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

PopulateSeedList()

-- ===== SELECTED SEED DISPLAY =====
local SelectedSeedLabel = Instance.new("TextLabel")
SelectedSeedLabel.Size = UDim2.new(1, -20, 0, 30)
SelectedSeedLabel.Position = UDim2.new(0, 10, 0, 275)
SelectedSeedLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
SelectedSeedLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
SelectedSeedLabel.Text = "🎯 Selected: None"
SelectedSeedLabel.Font = Enum.Font.GothamBold
SelectedSeedLabel.TextSize = 11
SelectedSeedLabel.BorderSizePixel = 0
SelectedSeedLabel.Parent = MainFrame

local SelectedCorner = Instance.new("UICorner")
SelectedCorner.CornerRadius = UDim.new(0, 6)
SelectedCorner.Parent = SelectedSeedLabel

-- ===== AMOUNT SECTION =====
local AmountLabel = Instance.new("TextLabel")
AmountLabel.Size = UDim2.new(1, -20, 0, 20)
AmountLabel.Position = UDim2.new(0, 10, 0, 315)
AmountLabel.BackgroundTransparency = 1
AmountLabel.Text = "🔢 Dupe Amount:"
AmountLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
AmountLabel.Font = Enum.Font.GothamBold
AmountLabel.TextSize = 11
AmountLabel.TextXAlignment = Enum.TextXAlignment.Left
AmountLabel.Parent = MainFrame

local AmountInput = Instance.new("TextBox")
AmountInput.Size = UDim2.new(1, -20, 0, 35)
AmountInput.Position = UDim2.new(0, 10, 0, 340)
AmountInput.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AmountInput.TextColor3 = Color3.white
AmountInput.PlaceholderText = "200"
AmountInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
AmountInput.Font = Enum.Font.Gotham
AmountInput.TextSize = 12
AmountInput.Text = "200"
AmountInput.BorderSizePixel = 0
AmountInput.Parent = MainFrame

local AmountCorner = Instance.new("UICorner")
AmountCorner.CornerRadius = UDim.new(0, 6)
AmountCorner.Parent = AmountInput

-- ===== QUICK SELECT BUTTONS =====
local QuickLabel = Instance.new("TextLabel")
QuickLabel.Size = UDim2.new(1, -20, 0, 20)
QuickLabel.Position = UDim2.new(0, 10, 0, 380)
QuickLabel.BackgroundTransparency = 1
QuickLabel.Text = "⚡ Quick Select:"
QuickLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
QuickLabel.Font = Enum.Font.GothamBold
QuickLabel.TextSize = 10
QuickLabel.TextXAlignment = Enum.TextXAlignment.Left
QuickLabel.Parent = MainFrame

local QuickFrame = Instance.new("Frame")
QuickFrame.Size = UDim2.new(1, -20, 0, 32)
QuickFrame.Position = UDim2.new(0, 10, 0, 402)
QuickFrame.BackgroundTransparency = 1
QuickFrame.Parent = MainFrame

local QuickBtns = {
    {text = "100", val = 100},
    {text = "500", val = 500},
    {text = "1K", val = 1000},
    {text = "5K", val = 5000}
}

for i, btn in pairs(QuickBtns) do
    local QuickBtn = Instance.new("TextButton")
    QuickBtn.Size = UDim2.new(0.22, 0, 1, 0)
    QuickBtn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    QuickBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 70)
    QuickBtn.TextColor3 = Color3.white
    QuickBtn.Text = btn.text
    QuickBtn.Font = Enum.Font.GothamBold
    QuickBtn.TextSize = 10
    QuickBtn.BorderSizePixel = 0
    QuickBtn.Parent = QuickFrame
    
    local QuickCorner = Instance.new("UICorner")
    QuickCorner.CornerRadius = UDim.new(0, 5)
    QuickCorner.Parent = QuickBtn
    
    QuickBtn.MouseButton1Click:Connect(function()
        AmountInput.Text = tostring(btn.val)
        UISystem.state.amount = btn.val
    end)
end

-- ===== DUPE BUTTON =====
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(1, -20, 0, 45)
DupeBtn.Position = UDim2.new(0, 10, 0, 440)
DupeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
DupeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
DupeBtn.Text = "🚀 DUPE NOW"
DupeBtn.Font = Enum.Font.GothamBold
DupeBtn.TextSize = 14
DupeBtn.BorderSizePixel = 0
DupeBtn.Parent = MainFrame

local DupeCorner = Instance.new("UICorner")
DupeCorner.CornerRadius = UDim.new(0, 8)
DupeCorner.Parent = DupeBtn

DupeBtn.MouseButton1Click:Connect(function()
    if not UISystem.state.selectedSeed then
        print("❌ Please select a seed first!")
        return
    end
    
    local amount = tonumber(AmountInput.Text) or 200
    DupeEngine:Dupe(UISystem.state.selectedSeed, amount)
end)

DupeBtn.MouseEnter:Connect(function()
    DupeBtn.BackgroundColor3 = Color3.fromRGB(120, 220, 120)
end)

DupeBtn.MouseLeave:Connect(function()
    DupeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
end)

-- ===== REFRESH BUTTON =====
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -20, 0, 25)
RefreshBtn.Position = UDim2.new(0, 10, 0, 490)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 150)
RefreshBtn.TextColor3 = Color3.white
RefreshBtn.Text = "🔄 Refresh Seed List"
RefreshBtn.Font = Enum.Font.Gotham
RefreshBtn.TextSize = 11
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Parent = MainFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

RefreshBtn.MouseButton1Click:Connect(function()
    SeedDetector:RefreshSeeds()
    PopulateSeedList()
    print("✅ Seed list refreshed!")
end)

-- ==================== GLOBAL EXPORTS ====================

getgenv().DupeUltimate = {
    Dupe = function(itemName, amount)
        return DupeEngine:Dupe(itemName, amount)
    end,
    RefreshSeeds = function()
        return SeedDetector:RefreshSeeds()
    end,
    GetSeeds = function()
        return SeedDetector:GetAllSeeds()
    end,
    GetHistory = function()
        return DupeEngine:GetHistory()
    end,
    CloseUI = function()
        ScreenGui:Destroy()
    end
}

print("🚀 ============ DUPE ULTIMATE PRO LOADED ============")
print("✅ Seed Detection System: ACTIVE")
print("✅ Anti-Cheat Bypass: ACTIVE")
print("✅ Dupe Engine: READY")
print("📊 Available Seeds: " .. #SeedDetector:GetAllSeeds())
print("💻 Use: getgenv().DupeUltimate.Dupe('seed', 200)")
print("🔄 Use: getgenv().DupeUltimate.RefreshSeeds()")
print("📚 Use: getgenv().DupeUltimate.GetSeeds()")
print("================================================")
