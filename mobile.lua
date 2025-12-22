-- =======================
-- STEAL A BRAINROT FINDER
-- TOP 10 SERVERS
-- MOBILE + PC
-- =======================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

getgenv().BrainrotFinder = getgenv().BrainrotFinder or {
    Results = {},
    Scanned = {},
    MaxResults = 10,
    MaxServers = 40
}

-- ===== SCAN CURRENT SERVER =====
local function scanServer()
    local best = nil

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChild("ValuePerSecond")
        and v:FindFirstChild("Rarity") then

            local value = v.ValuePerSecond.Value

            if not best or value > best.Value then
                best = {
                    Name = v.Name,
                    Value = value,
                    Rarity = v.Rarity.Value,
                    ServerId = game.JobId
                }
            end
        end
    end

    return best
end

-- ===== SAVE RESULT =====
local function saveResult(result)
    if not result then return end

    table.insert(getgenv().BrainrotFinder.Results, result)

    table.sort(getgenv().BrainrotFinder.Results, function(a,b)
        return a.Value > b.Value
    end)

    if #getgenv().BrainrotFinder.Results > getgenv().BrainrotFinder.MaxResults then
        table.remove(getgenv().BrainrotFinder.Results)
    end
end

-- ===== GET SERVERS =====
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"
    if cursor then url = url.."&cursor="..cursor end
    return HttpService:JSONDecode(game:HttpGet(url))
end

-- ===== SERVER HOP =====
local function hop()
    local data = getServers()

    for _, server in pairs(data.data) do
        if not getgenv().BrainrotFinder.Scanned[server.id]
        and server.playing < server.maxPlayers then

            getgenv().BrainrotFinder.Scanned[server.id] = true
            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player)
            return
        end
    end
end

-- ===== ON JOIN =====
task.delay(5, function()
    local result = scanServer()
    saveResult(result)

    if #getgenv().BrainrotFinder.Scanned < getgenv().BrainrotFinder.MaxServers then
        hop()
    end
end)

-- ===== UI (simple mais propre) =====
task.delay(8, function()
    local gui = Instance.new("ScreenGui", Player.PlayerGui)
    gui.Name = "BrainrotFinderUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.9,0.6)
    frame.Position = UDim2.fromScale(0.05,0.2)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    local list = Instance.new("UIListLayout", frame)
    list.Padding = UDim.new(0,6)

    for _, r in pairs(getgenv().BrainrotFinder.Results) do
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.fromScale(1,0.1)
        btn.Text = r.Name.." | "..r.Value.."/sec | JOIN"
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.new(1,1,1)

        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, r.ServerId, Player)
        end)
    end
end)
