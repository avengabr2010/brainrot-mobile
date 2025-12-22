-- BRAINROT FINDER PRO - INTERSERVERS

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ========== SETTINGS ==========

getgenv().MinValuePerSec = 30000
getgenv().WantedRarity = "" -- vide = toutes
getgenv().AutoHop = true

local RarityList = {"", "Commun", "Rare", "Epique", "Légendaire", "Mythique", "Brainrot God", "Secret", "OG"}

local PlaceId = game.PlaceId
local visitedServers = {}
local foundList = {}

-- ================== UI ==================

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotFinderUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.92,0,0.85,0)
main.Position = UDim2.new(0.04,0,0.08,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "🧠 Brainrot Finder Pro"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- SETTINGS PANEL
local settingsFrame = Instance.new("Frame", main)
settingsFrame.Size = UDim2.new(1, -20, 0, 90)
settingsFrame.Position = UDim2.new(0,10,0,50)
settingsFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0,12)

-- MIN VALUE
local minLabel = Instance.new("TextLabel", settingsFrame)
minLabel.Size = UDim2.new(0.3,0,1,0)
minLabel.Position = UDim2.new(0,10,0,0)
minLabel.BackgroundTransparency = 1
minLabel.Text = "Min/sec:"
minLabel.TextColor3 = Color3.new(1,1,1)
minLabel.Font = Enum.Font.Gotham
minLabel.TextSize = 14
minLabel.TextXAlignment = Enum.TextXAlignment.Left

local minBox = Instance.new("TextBox", settingsFrame)
minBox.Size = UDim2.new(0.25,0,0.7,0)
minBox.Position = UDim2.new(0.3,10,0.15,0)
minBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
minBox.TextColor3 = Color3.new(1,1,1)
minBox.Text = tostring(getgenv().MinValuePerSec)
minBox.ClearTextOnFocus = false
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0,10)

-- RARITY DROPDOWN
local rarityLabel = Instance.new("TextLabel", settingsFrame)
rarityLabel.Size = UDim2.new(0.25,0,1,0)
rarityLabel.Position = UDim2.new(0.6,10,0,0)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = "Rarity:"
rarityLabel.TextColor3 = Color3.new(1,1,1)
rarityLabel.Font = Enum.Font.Gotham
rarityLabel.TextSize = 14
rarityLabel.TextXAlignment = Enum.TextXAlignment.Left

local rarityBox = Instance.new("TextBox", settingsFrame)
rarityBox.Size = UDim2.new(0.25,0,0.7,0)
rarityBox.Position = UDim2.new(0.85,0,0.15,0)
rarityBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
rarityBox.TextColor3 = Color3.new(1,1,1)
rarityBox.Text = getgenv().WantedRarity
rarityBox.ClearTextOnFocus = false
Instance.new("UICorner", rarityBox).CornerRadius = UDim.new(0,10)

-- LIST OF SERVERS
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,150)
list.Size = UDim2.new(1,-20,1,-160)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+20)
end)

-- ========== FUNCTIONS ==========

local function notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title="Brainrot Finder",
        Text=msg,
        Duration=4
    })
end

local function addResult(name, rarity, value, jobId)
    local btn = Instance.new("TextButton", list)
    btn.Size = UDim2.new(1,-10,0,60)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextWrapped = true
    btn.Text = name.." | "..rarity.." | "..value.."/sec\n[TAP TO JOIN]"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)

    btn.MouseButton1Click:Connect(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, jobId, player)
    end)

    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+20)
    if rarity == "Brainrot God" or rarity == "Secret" or rarity == "OG" then
        notify("Found "..rarity.." : "..name)
    end
end

-- SCAN SERVER
local function scanServer()
    getgenv().MinValuePerSec = tonumber(minBox.Text) or 0
    getgenv().WantedRarity = rarityBox.Text or ""

    local folder = workspace:FindFirstChild("Brainrots") or workspace
    for _, b in pairs(folder:GetDescendants()) do
        if b:IsA("Model") and b:FindFirstChild("Rarity") and b:FindFirstChild("ValuePerSecond") then
            local rarity = b.Rarity.Value
            local value = b.ValuePerSecond.Value
            if value >= getgenv().MinValuePerSec and 
               (getgenv().WantedRarity=="" or string.lower(rarity)==string.lower(getgenv().WantedRarity)) then
                addResult(b.Name, rarity, value, game.JobId)
            end
        end
    end
end

-- ================= SERVER HOP =================
task.spawn(function()
    scanServer()
    if getgenv().AutoHop then
        task.wait(2)
        local body = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local servers = HttpService:JSONDecode(body).data
        for _, s in pairs(servers) do
            if not visitedServers[s.id] then
                visitedServers[s.id] = true
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)
                break
            end
        end
    end
end)
