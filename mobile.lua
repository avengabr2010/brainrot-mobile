-- STEAL A BRAINROT - REAL LOCAL FINDER
-- MOBILE + PC

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ===== FIND BEST BRAINROT =====
local function getBestBrainrot()
    local best = nil

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChild("ValuePerSecond")
        and v:FindFirstChild("Rarity") then

            local value = tonumber(v.ValuePerSecond.Value)

            if value and (not best or value > best.Value) then
                best = {
                    Name = v.Name,
                    Value = value,
                    Rarity = tostring(v.Rarity.Value)
                }
            end
        end
    end

    return best
end

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotFinder"
gui.Parent = Player.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.9, 0.4)
frame.Position = UDim2.fromScale(0.05, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.2)
title.BackgroundTransparency = 1
title.Text = "STEAL A BRAINROT – FINDER"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local info = Instance.new("TextLabel", frame)
info.Position = UDim2.fromScale(0,0.2)
info.Size = UDim2.fromScale(1,0.45)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1,1,1)
info.TextScaled = true
info.TextWrapped = true

local refresh = Instance.new("TextButton", frame)
refresh.Position = UDim2.fromScale(0.05,0.7)
refresh.Size = UDim2.fromScale(0.4,0.2)
refresh.Text = "REFRESH"
refresh.TextScaled = true
refresh.BackgroundColor3 = Color3.fromRGB(40,40,40)
refresh.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", refresh)

local hop = Instance.new("TextButton", frame)
hop.Position = UDim2.fromScale(0.55,0.7)
hop.Size = UDim2.fromScale(0.4,0.2)
hop.Text = "SERVER HOP"
hop.TextScaled = true
hop.BackgroundColor3 = Color3.fromRGB(70,30,30)
hop.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hop)

-- ===== UPDATE DISPLAY =====
local function update()
    local best = getBestBrainrot()

    if best then
        info.Text =
            "Best Brainrot:\n\n" ..
            "Name: "..best.Name.."\n" ..
            "Value/sec: "..best.Value.."\n" ..
            "Rarity: "..best.Rarity
    else
        info.Text = "No brainrot found in this server."
    end
end

-- ===== BUTTONS =====
refresh.MouseButton1Click:Connect(update)

hop.MouseButton1Click:Connect(function()
    local servers = HttpService:JSONDecode(
        game:HttpGet(
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"
        )
    )

    for _, s in ipairs(servers.data) do
        if s.playing < s.maxPlayers then
            TeleportService:TeleportToPlaceInstance(PlaceId, s.id, Player)
            break
        end
    end
end)

-- ===== INIT =====
update()
