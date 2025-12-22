-- 🧠 STEAL A BRAINROT - REAL AUTO SERVER FINDER

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ========= SETTINGS =========
getgenv().MinValue = 0
getgenv().WantedRarity = "" -- vide = toutes
getgenv().Running = true

-- ========= UI =========
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotFinder"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.92,0,0.85,0)
main.Position = UDim2.new(0.04,0,0.08,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,45)
title.Text = "🧠 Brainrot Finder – Auto Hop"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,30)
status.Position = UDim2.new(0,0,0,45)
status.Text = "Status : scan en cours..."
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.BackgroundTransparency = 1

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,80)
list.Size = UDim2.new(1,-20,1,-90)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

local function addResult(serverId, name, value)
	local f = Instance.new("Frame", list)
	f.Size = UDim2.new(1,-10,0,55)
	f.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)

	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(1,-10,1,0)
	t.Position = UDim2.new(0,10,0,0)
	t.TextWrapped = true
	t.TextXAlignment = Left
	t.Text = "Server : "..serverId.."\nBest Brainrot : "..name.." | "..value.."/sec"
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.BackgroundTransparency = 1
end

-- ========= SCAN CURRENT SERVER =========
local function scanServer()
	local bestValue = 0
	local bestName = nil

	for _, m in pairs(workspace:GetDescendants()) do
		if m:IsA("Model") then
			for _, v in pairs(m:GetDescendants()) do
				if v:IsA("NumberValue") and (
					v.Name:lower():find("sec")
					or v.Name:lower():find("value")
					or v.Name:lower():find("cash")
				) then
					if v.Value > bestValue then
						bestValue = v.Value
						bestName = m.Name
					end
				end
			end
		end
	end

	if bestName then
		addResult(game.JobId, bestName, bestValue)
	end
end

-- ========= SERVER HOP LOOP =========
task.spawn(function()
	while getgenv().Running do
		status.Text = "Scan du serveur..."
		scanServer()
		status.Text = "Changement de serveur..."
		task.wait(2)

		local data = HttpService:JSONDecode(
			game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
		)

		for _, s in pairs(data.data) do
			if s.playing < s.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
				task.wait(5)
				break
			end
		end
	end
end)
