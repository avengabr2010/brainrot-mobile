-- 🧠 STEAL A BRAINROT - REAL FINDER (AUTO DETECT)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- ===== SETTINGS PAR DEFAUT =====
local MIN_VALUE = 0
local TARGET_RARITY = "" -- vide = toutes

-- ===== UI =====
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotFinder"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.94,0,0.85,0)
main.Position = UDim2.new(0.03,0,0.08,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "🧠 Brainrot Finder (Auto)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- SETTINGS
local minBox = Instance.new("TextBox", main)
minBox.Size = UDim2.new(0.4,0,0,40)
minBox.Position = UDim2.new(0.05,0,0,50)
minBox.PlaceholderText = "Min valeur / sec"
minBox.Text = ""
minBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
minBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0,10)

local rarityBox = Instance.new("TextBox", main)
rarityBox.Size = UDim2.new(0.4,0,0,40)
rarityBox.Position = UDim2.new(0.55,0,0,50)
rarityBox.PlaceholderText = "Rareté (optionnel)"
rarityBox.Text = ""
rarityBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
rarityBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", rarityBox).CornerRadius = UDim.new(0,10)

-- LISTE
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,100)
list.Size = UDim2.new(1,-20,1,-110)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

-- ===== FINDER LOGIC =====

local function addResult(name, rarity, value)
	local btn = Instance.new("TextLabel", list)
	btn.Size = UDim2.new(1,-10,0,60)
	btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
	btn.TextWrapped = true
	btn.Text = name.." | "..rarity.." | "..value.." / sec"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
end

-- AUTO DETECTION
local bestValue = 0
local bestName = nil
local bestRarity = "?"

task.wait(3)

MIN_VALUE = tonumber(minBox.Text) or 0
TARGET_RARITY = string.lower(rarityBox.Text or "")

for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("Model") then
		local rarity, value

		for _, v in pairs(obj:GetDescendants()) do
			if v:IsA("StringValue") and string.find(string.lower(v.Name),"rar") then
				rarity = v.Value
			end
			if v:IsA("NumberValue") and (
				string.find(string.lower(v.Name),"sec")
				or string.find(string.lower(v.Name),"value")
				or string.find(string.lower(v.Name),"cash")
			) then
				value = v.Value
			end
		end

		if value and value >= MIN_VALUE then
			if TARGET_RARITY == "" or string.find(string.lower(rarity or ""), TARGET_RARITY) then
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
	addResult(bestName, bestRarity, bestValue)
else
	addResult("Aucun brainrot trouvé", "-", "-")
end
