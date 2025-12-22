-- 🧠 BRAINROT FINDER UI + SETTINGS - MOBILE & PC & CODEX

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ========== GLOBAL SETTINGS ==========
getgenv().MinPerSecond = 30000
getgenv().TargetRarity = "" -- "" = toutes, sinon Commun, Rare, Epique, Légendaire, Mythique, Brainrot God, Secret, OG

local PlaceId = game.PlaceId
local visited = {}
local foundList = {}

-- request compatible Codex
local function httpGet(url)
    if request then
        return request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
    end
end

-- ================= UI =================

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotFinderUI"
gui.Parent = game.CoreGui

-- MAIN PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.92,0,0.8,0)
main.Position = UDim2.new(0.04,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "🧠 Brainrot Finder"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- SETTINGS PANEL
local settingsFrame = Instance.new("Frame", main)
settingsFrame.Size = UDim2.new(1, -20, 0, 80)
settingsFrame.Position = UDim2.new(0,10,0,50)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
minBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
minBox.TextColor3 = Color3.new(1,1,1)
minBox.Text = tostring(getgenv().MinPerSecond)
minBox.ClearTextOnFocus = false
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0,10)

-- RARITY SELECT
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
rarityBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
rarityBox.TextColor3 = Color3.new(1,1,1)
rarityBox.Text = getgenv().TargetRarity
rarityBox.ClearTextOnFocus = false
Instance.new("UICorner", rarityBox).CornerRadius = UDim.new(0,10)

-- LIST OF SERVERS
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,140)
list.Size = UDim2.new(1,-20,1,-150)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.4

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
end)

-- ========= REFRESH UI =========
local function refreshUI()
    for _, c in pairs(list:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    -- TRI PAR VALEUR
    table.sort(foundList, function(a,b) return a.value > b.value end)

    for _, info in pairs(foundList) do
        local item = Instance.new("Frame", list)
        item.Size = UDim2.new(1,0,0,80)
        item.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Instance.new("UICorner", item).CornerRadius = UDim.new(0,12)

        local txt = Instance.new("TextLabel", item)
        txt.Size = UDim2.new(0.7,0,1,0)
        txt.Position = UDim2.new(0,10,0,0)
        txt.BackgroundTransparency = 1
        txt.TextWrapped = true
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 14
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Text = "🧠 "..info.name.."\n⭐ "..info.rarity.."\n💰 "..info.value.." / sec"

        local btn = Instance.new("TextButton", item)
        btn.Size = UDim2.new(0.25,0,0.5,0)
        btn.Position = UDim2.new(0.72,0,0.25,0)
        btn.Text = "JOIN"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(70,130,255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, info.serverId, player)
        end)
    end
end

-- ========= SCAN SERVER =========
local function waitForBrainrots()
    for _=1,30 do
        local f = workspace:FindFirstChild("Brainrots")
        if f then return f end
        task.wait(1)
    end
end

local function scanServer()
    local folder = waitForBrainrots()
    if not folder then return end

    for _, b in pairs(folder:GetChildren()) do
        if b:IsA("Model") and b:FindFirstChild("Value") and b:FindFirstChild("Rarity") then
            local value = b.Value.Value
            local rarity = b.Rarity.Value
            local name = b.Name

            -- CHECK SETTINGS
            getgenv().MinPerSecond = tonumber(minBox.Text) or 0
            getgenv().TargetRarity = rarityBox.Text or ""

            if value >= getgenv().MinPerSecond
            and (getgenv().TargetRarity == "" or string.lower(rarity) == string.lower(getgenv().TargetRarity)) then
                local exists = false
                for _,v in pairs(foundList) do
                    if v.serverId == game.JobId then exists = true break end
                end
                if not exists then
                    table.insert(foundList,{
                        name=name,
                        rarity=rarity,
                        value=value,
                        serverId=game.JobId
                    })
                    refreshUI()
                end
            end
        end
    end
end

-- ========= AUTO SERVER HOP =========
task.spawn(function()
    while task.wait(4) do
        scanServer()
        local body = httpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100")
        local servers = HttpService:JSONDecode(body).data
        for _, s in pairs(servers) do
            if not visited[s.id] then
                visited[s.id] = true
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)
                task.wait(8)
                break
            end
        end
    end
end)
