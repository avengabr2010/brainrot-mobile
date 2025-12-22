-- 🧠 STEAL A BRAINROT FINDER V3 – UI MODERNE + SETTINGS FONCTIONNELS

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ===== SETTINGS =====
getgenv().MinValue = 0
getgenv().WantedRarity = ""
getgenv().Running = false

-- ===== COLORS / STYLE =====
local COLORS = {
	Commun = Color3.fromRGB(150,150,150),
	Rare = Color3.fromRGB(64,128,255),
	Epique = Color3.fromRGB(180,0,255),
	Legendaire = Color3.fromRGB(255,200,0),
	Mythique = Color3.fromRGB(255,0,0),
	["Brainrot God"] = Color3.fromRGB(0,255,255),
	Secret = Color3.fromRGB(255,128,0),
	OG = Color3.fromRGB(0,255,0)
}

-- ===== UI =====
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotFinderV3"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.94,0,0.9,0)
main.Position = UDim2.new(0.03,0,0.05,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,20)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.Text = "🧠 Brainrot Finder V3"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BackgroundTransparency = 1

-- ===== SETTINGS INPUTS =====
local minBox = Instance.new("TextBox", main)
minBox.Size = UDim2.new(0.42,0,0,35)
minBox.Position = UDim2.new(0.03,0,0,60)
minBox.PlaceholderText = "Valeur min/sec"
minBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
minBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0,10)

local rarityBox = Instance.new("TextBox", main)
rarityBox.Size = UDim2.new(0.42,0,0,35)
rarityBox.Position = UDim2.new(0.5,0,0,60)
rarityBox.PlaceholderText = "Rareté (optionnel)"
rarityBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
rarityBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", rarityBox).CornerRadius = UDim.new(0,10)

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(0.94,0,0,40)
startBtn.Position = UDim2.new(0.03,0,0,105)
startBtn.Text = "Start Finder"
startBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,12)

-- ===== LIST SCROLLABLE =====
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,150)
list.Size = UDim2.new(1,-20,1,-160)
list.BackgroundTransparency = 0.1
list.BackgroundColor3 = Color3.fromRGB(40,40,40)
list.ScrollBarImageColor3 = Color3.fromRGB(200,200,200)
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,8)
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
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = "Server : "..serverId.."\nBrainrot : "..brainrotName.." | "..value.."/sec | "..rarity
	t.TextColor3 = COLORS[rarity] or Color3.fromRGB(255,255,255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.BackgroundTransparency = 1
	
	local joinBtn = Instance.new("TextButton", f)
	joinBtn.Size = UDim2.new(0.25,0,0.6,0)
	joinBtn.Position = UDim2.new(0.72,0,0.2,0)
	joinBtn.Text = "JOIN"
	joinBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
	joinBtn.TextColor3 = Color3.fromRGB(255,255,255)
	Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0,10)
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
	local pageCursor = ""
	repeat
		local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"
		if pageCursor ~= "" then url = url.."&cursor="..pageCursor end
		local suc, data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if not suc or not data or #data.data == 0 then break end
		for _, s in pairs(data.data) do
			if s.playing < s.maxPlayers then
				table.insert(servers, s.id)
			end
		end
		pageCursor = data.nextPageCursor or ""
	until pageCursor == nil or pageCursor == ""
	return servers
end

local function autoFinder()
	getgenv().Running = true
	while getgenv().Running do
		scanCurrentServer()
		local servers = getServers()
		table.sort(servers, function(a,b) return a>b end)
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
