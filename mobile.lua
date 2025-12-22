-- 🧠 STEAL A BRAINROT FINDER - ICE FINDER STYLE

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ===== SETTINGS =====
getgenv().MinValue = 0
getgenv().WantedRarity = "" -- vide = toutes
getgenv().Running = false

-- ===== UI =====
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotFinderGUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.92,0,0.85,0)
main.Position = UDim2.new(0.04,0,0.08,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "🧠 Brainrot Finder"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1

-- Settings input
local minBox = Instance.new("TextBox", main)
minBox.Size = UDim2.new(0.4,0,0,35)
minBox.Position = UDim2.new(0.03,0,0,50)
minBox.PlaceholderText = "Valeur min/sec"
minBox.Text = ""
minBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
minBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0,10)

local rarityBox = Instance.new("TextBox", main)
rarityBox.Size = UDim2.new(0.4,0,0,35)
rarityBox.Position = UDim2.new(0.5,0,0,50)
rarityBox.PlaceholderText = "Rareté (optionnel)"
rarityBox.Text = ""
rarityBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
rarityBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", rarityBox).CornerRadius = UDim.new(0,10)

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(0.9,0,0,35)
startBtn.Position = UDim2.new(0.05,0,0,95)
startBtn.Text = "Start / Stop Finder"
startBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
startBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,10)

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,140)
list.Size = UDim2.new(1,-20,1,-150)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

-- ===== FUNCTIONS =====
local function addResult(serverId, brainrotName, value, rarity)
	local f = Instance.new("Frame", list)
	f.Size = UDim2.new(1,0,0,60)
	f.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
	
	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(0.7,0,1,0)
	t.Position = UDim2.new(0,10,0,0)
	t.TextWrapped = true
	t.Text = "Server : "..serverId.."\nBrainrot : "..brainrotName.." | "..value.."/sec | "..rarity
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.BackgroundTransparency = 1
	
	local joinBtn = Instance.new("TextButton", f)
	joinBtn.Size = UDim2.new(0.25,0,0.6,0)
	joinBtn.Position = UDim2.new(0.72,0,0.2,0)
	joinBtn.Text = "JOIN"
	joinBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
	joinBtn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0,8)
	joinBtn.MouseButton1Click:Connect(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, player)
	end)
end

local function scanCurrentServer()
	local minValue = tonumber(minBox.Text) or 0
	local wantedRarity = string.lower(rarityBox.Text or "")
	local bestValue = 0
	local bestName = nil
	local bestRarity = "?"
	
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			local value, rarity
			for _, v in pairs(obj:GetDescendants()) do
				if v:IsA("NumberValue") and (v.Name:lower():find("sec") or v.Name:lower():find("value") or v.Name:lower():find("cash")) then
					value = v.Value
				end
				if v:IsA("StringValue") and v.Name:lower():find("rar") then
					rarity = v.Value
				end
			end
			if value and value >= minValue then
				if wantedRarity == "" or string.find(string.lower(rarity or ""), wantedRarity) then
					if value > bestValue then
						bestValue = value
						bestName = obj.Name
						bestRarity = rarity or "?"
					end
				end
			end
		end
	end
	
	if bestName then
		addResult(game.JobId, bestName, bestValue, bestRarity)
	end
end

local function getServers()
	local servers = {}
	local page = 1
	while true do
		local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="
		if page > 1 then url = url.."&cursor="..tostring(page) end
		local suc, data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if not suc or not data or #data.data == 0 then break end
		for _, s in pairs(data.data) do
			if s.playing < s.maxPlayers then
				table.insert(servers, s.id)
			end
		end
		page = page + 1
	end
	return servers
end

local function autoFinder()
	getgenv().Running = true
	while getgenv().Running do
		scanCurrentServer()
		local servers = getServers()
		for _, sId in pairs(servers) do
			if not getgenv().Running then break end
			TeleportService:TeleportToPlaceInstance(game.PlaceId, sId, player)
			task.wait(5)
		end
	end
end

startBtn.MouseButton1Click:Connect(function()
	if getgenv().Running then
		getgenv().Running = false
		startBtn.Text = "Start Finder"
	else
		getgenv().Running = true
		startBtn.Text = "Stop Finder"
		task.spawn(autoFinder)
	end
end)
