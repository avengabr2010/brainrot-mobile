-- STEAL A BRAINROT - LOCAL FINDER (MOBILE SAFE)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ===== SCAN FUNCTION =====
local function getBestBrainrot()
    local best = nil

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChild("ValuePerSecond")
        and v:FindFirstChild("Rarity") then

            local value = tonumber(v.ValuePerSecond.Value)
            if value then
                if not best or value > best.Value then
                    best = {
                        Name = v.Name,
                        Value = value,
                        Rarity = tostring(v.Rarity.Value)
                    }
                end
            end
        end
    end

    return best
end

-- ===== UI =====
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "BrainrotFinder"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.9, 0.4)
frame.Position = UDim2.fromScale(0.05, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.2)
title.BackgroundTransparency = 1
title.Text = "STEAL A BRAINROT FINDER"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local info = Instance.new("TextLabel", frame)
info.Position = UDim2.fromScale(0,0.2)
info.Size = UDim2.fromScale(1,0.45)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1,1,1)
info.TextScaled = true
info.TextWrapped = true
info.Text = "Scanning..."

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
hop.BackgroundColor3 = Color3.fromRGB(80,30,30)
hop.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hop)

-- ===== UPDATE =====
local function update()
    info.Text = "Scanning..."
    task.wait(2) -- important pour que les brainrots spawnent

    local best = getBestBrainrot()
    if best then
        info.Text =
            "Best Brainrot:\n\n" ..
            best.Name .. "\n" ..
            "Value/sec: " .. best.Value .. "\n" ..
            "Rarity: " .. best.Rarity
    else
        info.Text = "No brainrot found yet.\nTry refresh in a few seconds."
    end
end

refresh.MouseButton1Click:Connect(update)

hop.MouseButton1Click:Connect(function()
    TeleportService:Teleport(PlaceId, Player)
end)

-- INIT
task.wait(3)
update()
