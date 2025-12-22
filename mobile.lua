-- 🧠 STEAL A BRAINROT - UI SERVER FINDER (MOBILE + PC)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ========= FILTRES =========
getgenv().MinPerSecond = 30000
getgenv().TargetName = ""
getgenv().TargetRarity = ""
-- ===========================

local PlaceId = game.PlaceId
local visited = {}
local foundServers = {}

-- request compatible Codex
local function httpGet(url)
    if request then
        return request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
    end
end

-- ================= UI =================

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.9,0,0.75,0)
main.Position = UDim2.new(0.05,0,0.12,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,18)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,50)
title.Text = "🧠 Brainrot Server Finder"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,0,0,60)
list.Size = UDim2.new(1,0,1,-60)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.4

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
end)

-- ========== UI ENTRY ==========
local function addServerUI(info)
    local item = Instance.new("Frame", list)
    item.Size = UDim2.new(1,-20,0,90)
    item.BackgroundColor3 = Color3.fromRGB(30,30,30)
    item.BorderSizePixel = 0

    Instance.new("UICorner", item).CornerRadius = UDim.new(0,14)

    local txt = Instance.new("TextLabel", item)
    txt.Size = UDim2.new(0.7,0,1,0)
    txt.Position = UDim2.new(0,15,0,0)
    txt.BackgroundTransparency = 1
    txt.TextWrapped = true
    txt.TextXAlignment = Left
    txt.TextYAlignment = Center
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Text =
        "🧠 "..info.name..
        "\n⭐ "..info.rarity..
        "\n💰 "..info.value.." / sec"

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

-- ========== SCAN ==========
local function scanServer()
    local folder = workspace:FindFirstChild("Brainrots")
    if not folder then return end

    for _, b in pairs(folder:GetChildren()) do
        if b:IsA("Model") and b:FindFirstChild("Value") and b:FindFirstChild("Rarity") then
            local value = b.Value.Value
            local rarity = b.Rarity.Value
            local name = b.Name

            if value >= getgenv().MinPerSecond
            and (getgenv().TargetName == "" or string.find(string.lower(name), string.lower(getgenv().TargetName)))
            and (getgenv().TargetRarity == "" or string.lower(rarity) == string.lower(getgenv().TargetRarity)) then

                if not foundServers[game.JobId] then
                    foundServers[game.JobId] = true
                    addServerUI({
                        name = name,
                        rarity = rarity,
                        value = value,
                        serverId = game.JobId
                    })
                end
            end
        end
    end
end

-- ========== AUTO SERVER HOP ==========
task.spawn(function()
    while task.wait(4) do
        scanServer()

        local body = httpGet(
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"
        )
        local servers = HttpService:JSONDecode(body).data

        for _, s in pairs(servers) do
            if not visited[s.id] then
                visited[s.id] = true
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)
                task.wait(6)
                break
            end
        end
    end
end)
