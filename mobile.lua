-- 🧠 STEAL A BRAINROT - SERVER FINDER (REAL)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================= SETTINGS =================
getgenv().MinValuePerSec = 30000
getgenv().WantedRarity = "" -- vide = toutes
getgenv().AutoHop = false

local RareList = {
    ["Commun"]=true, ["Rare"]=true, ["Epique"]=true,
    ["Légendaire"]=true, ["Mythique"]=true,
    ["Brainrot God"]=true, ["Secret"]=true, ["OG"]=true
}

-- ================= UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotFinder"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.95,0,0.85,0)
main.Position = UDim2.new(0.025,0,0.075,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,45)
title.Text = "🧠 Brainrot Server Finder"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,55)
list.Size = UDim2.new(1,-20,1,-65)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)

-- ================= FUNCTIONS =================
local function addResult(name, rarity, value, jobId)
    local btn = Instance.new("TextButton", list)
    btn.Size = UDim2.new(1,-10,0,55)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextWrapped = true
    btn.Text = name.." | "..rarity.." | "..value.."/sec\n[ TAP TO JOIN ]"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)

    btn.MouseButton1Click:Connect(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
    end)

    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+20)
end

-- ================= SCAN CURRENT SERVER =================
task.wait(3)

local folder = workspace:FindFirstChild("Brainrots") or workspace
for _, b in pairs(folder:GetDescendants()) do
    if b:IsA("Model")
    and b:FindFirstChild("Rarity")
    and b:FindFirstChild("ValuePerSecond") then

        local rarity = b.Rarity.Value
        local value = b.ValuePerSecond.Value

        if value >= getgenv().MinValuePerSec
        and (getgenv().WantedRarity == "" or rarity == getgenv().WantedRarity) then
            addResult(b.Name, rarity, value, game.JobId)
        end
    end
end

-- ================= SERVER HOP =================
if getgenv().AutoHop then
    task.wait(2)
    local servers = HttpService:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    ))

    for _, s in pairs(servers.data) do
        if s.playing < s.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
            break
        end
    end
end
