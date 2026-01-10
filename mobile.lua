local whitelist = {
    "Leoking_000",
    "Monkey_0436",
    "lanotherdeadl",
    "vitika6606",
    "Maxiging_6",
    "SABTRADE328",
    ""
}

local function isWhitelisted(name)
	for _, v in ipairs(whitelist) do
		if string.lower(v) == string.lower(name) then
			return true
		end
	end
	return false
end

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not isWhitelisted(player.Name) then
	player:Kick("Not Whitelisted")
	return
end

if _G.NexHubInstantStealLoaded then return end
_G.NexHubInstantStealLoaded = true

local pos1, pos2 = nil, nil
local beam1, beam2
local part1, part2

local targetPositions = {
	Vector3.new(-481.88, -3.79, 138.02),
	Vector3.new(-481.75, -3.79, 89.18),
	Vector3.new(-481.82, -3.79, 30.95),
	Vector3.new(-481.75, -3.79, -17.79),
	Vector3.new(-481.80, -3.79, -76.06),
	Vector3.new(-481.72, -3.79, -124.70),
	Vector3.new(-337.45, -3.85, -124.72),
	Vector3.new(-337.37, -3.85, -76.07),
	Vector3.new(-337.46, -3.79, -17.72),
	Vector3.new(-337.41, -3.79, 30.92),
	Vector3.new(-337.32, -3.79, 89.02),
	Vector3.new(-337.27, -3.79, 137.90),
	Vector3.new(-337.45, -3.79, 196.29),
	Vector3.new(-337.37, -3.79, 244.91),
	Vector3.new(-481.72, -3.79, 196.21),
	Vector3.new(-481.76, -3.79, 244.92)
}

local gui = Instance.new("ScreenGui")
gui.Name = "NexHubUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 160)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", frame).ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frame.UIStroke.Color = Color3.fromRGB(50,50,50)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -12, 0, 28)
title.Position = UDim2.fromOffset(6, 6)
title.BackgroundTransparency = 1
title.Text = "NexHub | INSTANT STEAL"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(220,220,220)
title.TextXAlignment = Enum.TextXAlignment.Center

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -12, 0, 22)
status.Position = UDim2.fromOffset(6, 42)
status.BackgroundTransparency = 1
status.Text = "Waiting for Stealâ€¦"
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.fromRGB(180,180,180)
status.TextXAlignment = Enum.TextXAlignment.Center

task.spawn(function()
	while true do
		TweenService:Create(status, TweenInfo.new(1.2), {TextTransparency = 0.4}):Play()
		task.wait(1.2)
		TweenService:Create(status, TweenInfo.new(1.2), {TextTransparency = 0}):Play()
		task.wait(1.2)
	end
end)

local function makeButton(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1, -24, 0, 36)
	b.Position = UDim2.fromOffset(12, y)
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.BackgroundTransparency = 0.05
	b.Text = text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.AutoButtonColor = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
	end)

	return b
end

local btn1 = makeButton("Set Position", 80)

local function pressAnim(button)
	local origSize = button.Size
	local origPos = button.Position

	TweenService:Create(button, TweenInfo.new(0.08), {
		Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 4,
		                 origSize.Y.Scale, origSize.Y.Offset - 3),
		Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + 2,
		                     origPos.Y.Scale, origPos.Y.Offset + 1)
	}):Play()

	task.wait(0.08)

	TweenService:Create(button, TweenInfo.new(0.12), {
		Size = origSize,
		Position = origPos
	}):Play()
end

local function createBeam(position, color, index)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local part = Instance.new("Part", workspace)
	part.Size = Vector3.new(1,1,1)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = CFrame.new(position)

	local a0 = Instance.new("Attachment", part)
	local a1 = Instance.new("Attachment", char.HumanoidRootPart)

	local beam = Instance.new("Beam", workspace)
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.12
	beam.Width1 = 0.12
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(color)

	if index == 1 then
		if beam1 then beam1:Destroy() end
		if part1 then part1:Destroy() end
		beam1, part1 = beam, part
	else
		if beam2 then beam2:Destroy() end
		if part2 then part2:Destroy() end
		beam2, part2 = beam, part
	end
end

btn1.MouseButton1Click:Connect(function()
	pressAnim(btn1)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		pos1 = hrp.CFrame
		createBeam(pos1.Position, Color3.fromRGB(0,170,255), 1)
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local closestDist = math.huge
			local closestPos = nil
			for _, v in ipairs(targetPositions) do
				local dist = (hrp.Position - v).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPos = v
				end
			end
			if closestPos then
				pos2 = CFrame.new(closestPos)
				createBeam(pos2.Position, Color3.fromRGB(255,140,0), 2)
			end
		end
	end
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, who)
	if who ~= player then return end
	if prompt.Name ~= "Steal" and prompt.ActionText ~= "Steal" then return end

	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local carpet = backpack:FindFirstChild("Flying Carpet")
		if carpet and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid:EquipTool(carpet)
		end
	end

	if pos1 then hrp.CFrame = pos1 end
	if pos2 then task.wait(0.05); hrp.CFrame = pos2 end
end)

local discord = Instance.new("TextLabel", frame)
discord.Size = UDim2.new(1,0,0,16)
discord.Position = UDim2.fromOffset(0,140)
discord.BackgroundTransparency = 1
discord.Text = "discord.gg/UMmhuXFcmq"
discord.Font = Enum.Font.GothamMedium
discord.TextSize = 10
discord.TextXAlignment = Enum.TextXAlignment.Center
discord.TextColor3 = Color3.fromRGB(180,180,180)

local h = 0
RunService.RenderStepped:Connect(function(dt)
	h = (h + dt * 0.3) % 1
	discord.TextColor3 = Color3.fromHSV(h,1,1)
end)
