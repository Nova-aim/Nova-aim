--==================================================
-- NOVA UI v4.0
-- FULL LOADER + MENU SYSTEM
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local old = PlayerGui:FindFirstChild("NovaUI")
if old then
	old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "NovaUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = PlayerGui

-- COLORS
local C = {
	Black = Color3.fromRGB(5,5,5),
	Dark = Color3.fromRGB(15,15,15),
	Panel = Color3.fromRGB(22,22,22),
	White = Color3.fromRGB(240,240,240),
	Gray = Color3.fromRGB(150,150,150),
	Green = Color3.fromRGB(120,255,150),
	Red = Color3.fromRGB(255,70,70),
}

--==================================================
-- STATE & CONFIG
--==================================================

local State = {
	aimEnabled = false,
	xrayEnabled = false,
	friends = {},
	target = nil,
	targetCF = nil,
	smoothCF = nil,
	hue = 0,
	lostTimer = 0,
	searchTimer = 0,
	xrayTimer = 0,
	currentTab = "software",
}

local Config = {
	AimPart = "Head",
	BackupPart = "UpperTorso",
	FOV = 60,
	Smoothness = 0.15,
	Distance = 250,
}

--==================================================
-- UTILS
--==================================================

local function Corner(obj,r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,r)
	c.Parent = obj
end

local function Tween(obj,time,data)
	TweenService:Create(
		obj,
		TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		data
	):Play()
end

--==================================================
-- PARTICLES (PLAVNYE)
--==================================================

local function CreateParticles(parent,count)
	local particles = {}
	for i = 1,count do
		local p = Instance.new("Frame")
		local size = math.random(2,4)
		p.Size = UDim2.new(0,size,0,size)
		p.Position = UDim2.fromScale(math.random(), math.random())
		p.BackgroundColor3 = C.White
		p.BackgroundTransparency = 0.6
		p.Parent = parent
		Corner(p,10)
		
		local speedX = (math.random() - 0.5) * 0.015
		local speedY = (math.random() - 0.5) * 0.015
		local phase = math.random() * 2 * math.pi
		
		table.insert(particles, {
			frame = p,
			speedX = speedX,
			speedY = speedY,
			phase = phase,
			startPos = p.Position,
		})
	end
	
	task.spawn(function()
		while parent and parent.Parent do
			for _, data in ipairs(particles) do
				if data.frame and data.frame.Parent then
					local time = os.clock()
					local offsetX = math.sin(time * 0.4 + data.phase) * data.speedX * 8
					local offsetY = math.cos(time * 0.6 + data.phase) * data.speedY * 8
					data.frame.Position = UDim2.new(
						data.startPos.X.Scale + offsetX,
						0,
						data.startPos.Y.Scale + offsetY,
						0
					)
					data.frame.BackgroundTransparency = 0.4 + math.sin(time * 0.3 + data.phase) * 0.2 + 0.2
				end
			end
			task.wait(0.05)
		end
	end)
	
	return particles
end

--==================================================
-- LOADER
--==================================================

local Loader = Instance.new("Frame")
Loader.Size = UDim2.fromScale(1,1)
Loader.BackgroundColor3 = C.Black
Loader.ZIndex = 100
Loader.Parent = Gui

local loaderParticles = CreateParticles(Loader, 35)

local Terminal = Instance.new("TextLabel")
Terminal.Size = UDim2.new(0.8,0,0.5,0)
Terminal.Position = UDim2.new(0.1,0,0.25,0)
Terminal.BackgroundTransparency = 1
Terminal.TextColor3 = C.White
Terminal.Font = Enum.Font.Code
Terminal.TextSize = 20
Terminal.TextXAlignment = Enum.TextXAlignment.Left
Terminal.TextYAlignment = Enum.TextYAlignment.Top
Terminal.ZIndex = 110
Terminal.Parent = Loader

local logs = {
	"> NOVA SYSTEM BOOT",
	"> Loading modules...",
	"> Loading interface...",
	"> Loading visual engine...",
	"> Connection stable",
	"> Engine ready",
	"",
	"READY? y/n"
}

task.spawn(function()
	for _,v in ipairs(logs) do
		Terminal.Text = Terminal.Text .. v .. "\n"
		task.wait(0.3)
	end
end)

task.wait(4)

Tween(Loader, 1, {BackgroundTransparency = 1})
task.wait(1)
Loader:Destroy()

--==================================================
-- MAIN MENU
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,460,0,550)
Main.Position = UDim2.new(0.5,-230,0.5,-275)
Main.BackgroundColor3 = C.Panel
Main.ZIndex = 10
Main.Parent = Gui
Corner(Main,25)

local menuParticles = CreateParticles(Main, 20)

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundTransparency = 1
Title.Text = "NOVA"
Title.TextColor3 = C.White
Title.Font = Enum.Font.Code
Title.TextSize = 38
Title.ZIndex = 20
Title.Parent = Main

--==================================================
-- TABS
--==================================================

local Tabs = {}
local ContentAreas = {}

local function CreateTab(name,x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.28,0,0,40)
	b.Position = UDim2.new(x,0,0,70)
	b.BackgroundColor3 = C.Dark
	b.Text = name
	b.TextColor3 = C.White
	b.Font = Enum.Font.Code
	b.TextSize = 16
	b.ZIndex = 20
	b.Parent = Main
	Corner(b,20)
	Tabs[name] = b
	return b
end

CreateTab("SOFTWARE", 0.04)
CreateTab("SETTINGS", 0.36)
CreateTab("FRIENDS", 0.68)

--==================================================
-- SOFTWARE TAB
--==================================================

local SoftwareContent = Instance.new("TextLabel")
SoftwareContent.Size = UDim2.new(1,-50,0,220)
SoftwareContent.Position = UDim2.new(0,25,0,130)
SoftwareContent.BackgroundTransparency = 1
SoftwareContent.TextColor3 = C.White
SoftwareContent.Font = Enum.Font.Code
SoftwareContent.TextSize = 17
SoftwareContent.TextXAlignment = Enum.TextXAlignment.Left
SoftwareContent.TextYAlignment = Enum.TextYAlignment.Top
SoftwareContent.ZIndex = 20
SoftwareContent.Parent = Main

local function UpdateSoftware()
	local targetText = State.target and State.target.Name or "None"
	local statusText = State.aimEnabled and "ACTIVE" or "READY"
	local lockText = State.aimEnabled and (State.target and "LOCKED" or "Searching") or "Disabled"
	local hitText = Config.AimPart
	
	SoftwareContent.Text = [[

SYSTEM STATUS

● Status: ]] .. statusText .. [[
● Connection: STABLE
● Engine: ACTIVE


CURRENT TARGET

]] .. targetText .. [[


LOCK:
]] .. lockText .. [[

HIT:
]] .. hitText
end
UpdateSoftware()

--==================================================
-- BUTTONS
--==================================================

local function CreateButton(text,y,col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.45,0,0,42)
	b.Position = UDim2.new(0.275,0,0,y)
	b.BackgroundColor3 = C.Dark
	b.Text = text
	b.TextColor3 = col or C.White
	b.Font = Enum.Font.Code
	b.TextSize = 17
	b.ZIndex = 20
	b.Parent = Main
	Corner(b,25)
	
	b.MouseEnter:Connect(function()
		Tween(b, 0.15, {BackgroundColor3 = Color3.fromRGB(40,40,40), Size = UDim2.new(0.47,0,0,44)})
	end)
	b.MouseLeave:Connect(function()
		Tween(b, 0.15, {BackgroundColor3 = C.Dark, Size = UDim2.new(0.45,0,0,42)})
	end)
	
	b.MouseButton1Down:Connect(function()
		Tween(b, 0.08, {Size = UDim2.new(0.43,0,0,40)})
	end)
	b.MouseButton1Up:Connect(function()
		Tween(b, 0.08, {Size = UDim2.new(0.45,0,0,42)})
	end)
	
	return b
end

local EnableBtn = CreateButton("ENABLE AIM", 370)
local XrayBtn = CreateButton("XRAY OFF", 418)
local PartBtn = CreateButton("HEAD", 466)
local MinimizeBtn = CreateButton("MINIMIZE", 514)

--==================================================
-- SETTINGS TAB
--==================================================

local SettingsContent = Instance.new("Frame")
SettingsContent.Size = UDim2.new(1,0,1,0)
SettingsContent.Position = UDim2.new(0,0,0,0)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
SettingsContent.Parent = Main

local SettingsText = Instance.new("TextLabel")
SettingsText.Size = UDim2.new(1,-50,0,250)
SettingsText.Position = UDim2.new(0,25,0,130)
SettingsText.BackgroundTransparency = 1
SettingsText.TextColor3 = C.White
SettingsText.Font = Enum.Font.Code
SettingsText.TextSize = 16
SettingsText.TextXAlignment = Enum.TextXAlignment.Left
SettingsText.TextYAlignment = Enum.TextYAlignment.Top
SettingsText.Text = [[
CONFIGURATION

FOV: 60
Smoothness: 0.15
Distance: 250
]]
SettingsText.Parent = SettingsContent

--==================================================
-- FRIENDS TAB
--==================================================

local FriendsContent = Instance.new("Frame")
FriendsContent.Size = UDim2.new(1,0,1,0)
FriendsContent.Position = UDim2.new(0,0,0,0)
FriendsContent.BackgroundTransparency = 1
FriendsContent.Visible = false
FriendsContent.Parent = Main

local FriendList = Instance.new("ScrollingFrame")
FriendList.Size = UDim2.new(0.6,0,1,0)
FriendList.Position = UDim2.new(0,0,0,0)
FriendList.BackgroundTransparency = 1
FriendList.BorderSizePixel = 0
FriendList.CanvasSize = UDim2.new(0,0,0,0)
FriendList.ScrollBarThickness = 3
FriendList.Parent = FriendsContent

local FriendLayout = Instance.new("UIListLayout")
FriendLayout.Padding = UDim.new(0,6)
FriendLayout.SortOrder = Enum.SortOrder.LayoutOrder
FriendLayout.Parent = FriendList

local FriendInfo = Instance.new("Frame")
FriendInfo.Size = UDim2.new(0.38,0,1,0)
FriendInfo.Position = UDim2.new(0.62,0,0,0)
FriendInfo.BackgroundColor3 = C.Dark
FriendInfo.BackgroundTransparency = 1
FriendInfo.Visible = false
FriendInfo.Parent = FriendsContent
Corner(FriendInfo, 20)

local FriendName = Instance.new("TextLabel")
FriendName.Size = UDim2.new(1,-20,0,30)
FriendName.Position = UDim2.new(0,10,0,10)
FriendName.BackgroundTransparency = 1
FriendName.Text = "Player"
FriendName.TextColor3 = C.White
FriendName.Font = Enum.Font.Code
FriendName.TextSize = 18
FriendName.TextXAlignment = Enum.TextXAlignment.Left
FriendName.Parent = FriendInfo

local FriendQuestion = Instance.new("TextLabel")
FriendQuestion.Size = UDim2.new(1,-20,0,30)
FriendQuestion.Position = UDim2.new(0,10,0,45)
FriendQuestion.BackgroundTransparency = 1
FriendQuestion.Text = "Add to friends?"
FriendQuestion.TextColor3 = C.Gray
FriendQuestion.Font = Enum.Font.Code
FriendQuestion.TextSize = 14
FriendQuestion.TextXAlignment = Enum.TextXAlignment.Left
FriendQuestion.Parent = FriendInfo

local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Size = UDim2.new(0.8,0,0,38)
ConfirmBtn.Position = UDim2.new(0.1,0,0,85)
ConfirmBtn.BackgroundColor3 = C.Green
ConfirmBtn.BackgroundTransparency = 0.3
ConfirmBtn.Text = "✓ CONFIRM"
ConfirmBtn.TextColor3 = C.White
ConfirmBtn.Font = Enum.Font.Code
ConfirmBtn.TextSize = 14
ConfirmBtn.Parent = FriendInfo
Corner(ConfirmBtn, 20)

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.8,0,0,38)
CancelBtn.Position = UDim2.new(0.1,0,0,130)
CancelBtn.BackgroundColor3 = C.Red
CancelBtn.BackgroundTransparency = 0.3
CancelBtn.Text = "✕ CANCEL"
CancelBtn.TextColor3 = C.White
CancelBtn.Font = Enum.Font.Code
CancelBtn.TextSize = 14
CancelBtn.Parent = FriendInfo
Corner(CancelBtn, 20)

local function UpdateFriendsList()
	for _, child in pairs(FriendList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local players = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= Player then
			table.insert(players, plr)
		end
	end
	
	if #players == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,0,0,30)
		empty.BackgroundTransparency = 1
		empty.Text = "No players in server"
		empty.TextColor3 = C.Gray
		empty.Font = Enum.Font.Code
		empty.TextSize = 14
		empty.Parent = FriendList
		FriendList.CanvasSize = UDim2.new(0,0,0,40)
		return
	end
	
	table.sort(players, function(a,b) return a.Name < b.Name end)
	
	for _, plr in ipairs(players) do
		local isFriend = false
		for _, f in ipairs(State.friends) do
			if f == plr then isFriend = true break end
		end
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,36)
		btn.BackgroundColor3 = C.Dark
		btn.BackgroundTransparency = 0.3
		btn.BorderSizePixel = 0
		btn.Parent = FriendList
		Corner(btn, 12)
		
		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(0.7,0,1,0)
		name.Position = UDim2.new(0,12,0,0)
		name.BackgroundTransparency = 1
		name.Text = plr.Name
		name.TextColor3 = isFriend and C.Green or C.White
		name.Font = Enum.Font.Code
		name.TextSize = 14
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Parent = btn
		
		local action = Instance.new("TextLabel")
		action.Size = UDim2.new(0.2,0,1,0)
		action.Position = UDim2.new(0.8,0,0,0)
		action.BackgroundTransparency = 1
		action.Text = isFriend and "✓" or "+"
		action.TextColor3 = isFriend and C.Green or C.Gray
		action.Font = Enum.Font.Code
		action.TextSize = 18
		action.Parent = btn
		
		btn.MouseButton1Click:Connect(function()
			if isFriend then
				for i, f in ipairs(State.friends) do
					if f == plr then
						table.remove(State.friends, i)
						break
					end
				end
				UpdateFriendsList()
				UpdateSoftware()
			else
				FriendName.Text = plr.Name
				FriendInfo.Visible = true
				FriendInfo.BackgroundTransparency = 1
				Tween(FriendInfo, 0.3, {BackgroundTransparency = 0})
				
				ConfirmBtn.MouseButton1Click:Connect(function()
					table.insert(State.friends, plr)
					FriendInfo.Visible = false
					UpdateFriendsList()
					UpdateSoftware()
				end)
				
				CancelBtn.MouseButton1Click:Connect(function()
					FriendInfo.Visible = false
				end)
			end
		end)
	end
	
	FriendLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		FriendList.CanvasSize = UDim2.new(0,0,0, FriendLayout.AbsoluteContentSize.Y + 10)
	end)
	task.wait()
	FriendList.CanvasSize = UDim2.new(0,0,0, FriendLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- TAB SWITCHING
--==================================================

local function SwitchTab(tab)
	if tab == "software" then
		SoftwareContent.Visible = true
		SettingsContent.Visible = false
		FriendsContent.Visible = false
	elseif tab == "settings" then
		SoftwareContent.Visible = false
		SettingsContent.Visible = true
		FriendsContent.Visible = false
	elseif tab == "friends" then
		SoftwareContent.Visible = false
		SettingsContent.Visible = false
		FriendsContent.Visible = true
		UpdateFriendsList()
	end
	State.currentTab = tab
end

Tabs["SOFTWARE"].MouseButton1Click:Connect(function() SwitchTab("software") end)
Tabs["SETTINGS"].MouseButton1Click:Connect(function() SwitchTab("settings") end)
Tabs["FRIENDS"].MouseButton1Click:Connect(function() SwitchTab("friends") end)

--==================================================
-- BUTTON FUNCTIONS
--==================================================

local function ToggleAim()
	State.aimEnabled = not State.aimEnabled
	EnableBtn.Text = State.aimEnabled and "DISABLE AIM" or "ENABLE AIM"
	EnableBtn.TextColor3 = State.aimEnabled and C.Red or C.White
	UpdateSoftware()
	if not State.aimEnabled then
		State.target = nil
		State.targetCF = nil
		State.smoothCF = nil
	end
end

local function ToggleXRay()
	State.xrayEnabled = not State.xrayEnabled
	XrayBtn.Text = State.xrayEnabled and "XRAY ON" or "XRAY OFF"
	XrayBtn.TextColor3 = State.xrayEnabled and C.Green or C.White
end

local function SwitchAimPart()
	if Config.AimPart == "Head" then
		Config.AimPart = "HumanoidRootPart"
		Config.BackupPart = "Torso"
		PartBtn.Text = "BODY"
	else
		Config.AimPart = "Head"
		Config.BackupPart = "UpperTorso"
		PartBtn.Text = "HEAD"
	end
	UpdateSoftware()
end

EnableBtn.MouseButton1Click:Connect(ToggleAim)
XrayBtn.MouseButton1Click:Connect(ToggleXRay)
PartBtn.MouseButton1Click:Connect(SwitchAimPart)

--==================================================
-- MINI LOGO
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0,70,0,70)
Mini.Position = UDim2.new(0.05,0,0.85,0)
Mini.Text = "N"
Mini.TextSize = 35
Mini.TextColor3 = C.White
Mini.BackgroundColor3 = C.Panel
Mini.Visible = false
Mini.ZIndex = 50
Mini.Parent = Gui
Corner(Mini, 50)

local miniGlow = Instance.new("Frame")
miniGlow.Size = UDim2.new(1.1,0,1.1,0)
miniGlow.Position = UDim2.new(-0.05,-0.05,-0.05,-0.05)
miniGlow.BackgroundTransparency = 1
miniGlow.BackgroundColor3 = C.Green
miniGlow.BorderSizePixel = 2
miniGlow.BorderColor3 = C.Green
miniGlow.BorderTransparency = 0.7
miniGlow.Parent = Mini
Corner(miniGlow, 55)

task.spawn(function()
	while Mini and Mini.Parent do
		Tween(miniGlow, 1.5, {BorderTransparency = 0.3})
		task.wait(1.5)
		Tween(miniGlow, 1.5, {BorderTransparency = 0.7})
		task.wait(1.5)
	end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
	Mini.Visible = false
	Main.Visible = true
end)

-- Drag Mini
local dragData = {dragging = false, startPos = nil, startOffset = nil}

Mini.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData.dragging = true
		dragData.startPos = input.Position
		dragData.startOffset = Mini.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragData.dragging then
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragData.startPos
			Mini.Position = UDim2.new(
				dragData.startOffset.X.Scale,
				dragData.startOffset.X.Offset + delta.X,
				dragData.startOffset.Y.Scale,
				dragData.startOffset.Y.Offset + delta.Y
			)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData.dragging = false
	end
end)

--==================================================
-- CLOSE
--==================================================

local CloseBtn = CreateButton("CLOSE", 562)
CloseBtn.MouseButton1Click:Connect(function()
	Gui:Destroy()
end)

--==================================================
-- AIM LOGIC
--==================================================

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function UpdateFilter(char)
	if char then
		raycastParams.FilterDescendantsInstances = {char}
	end
end

UpdateFilter(Player.Character)
Player.CharacterAdded:Connect(UpdateFilter)

local function IsAlive(plr)
	if not plr or not plr.Parent then return false end
	if not plr.Character or not plr.Character.Parent then return false end
	local hum = plr.Character:FindFirstChild("Humanoid")
	return hum and hum.Health > 0
end

local function IsFriend(plr)
	if not plr then return false end
	for _, f in ipairs(State.friends) do
		if f == plr then return true end
	end
	return false
end

local function GetAimPart(plr)
	if not plr or not plr.Character then return nil end
	local c = plr.Character
	local part = c:FindFirstChild(Config.AimPart)
	if part and part.Parent then return part end
	part = c:FindFirstChild(Config.BackupPart)
	if part and part.Parent then return part end
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
end

local function GetScreenPos(part)
	if not part or not part.Parent then return nil end
	local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
	if not onScreen then return nil end
	return Vector2.new(pos.X, pos.Y)
end

local function IsVisible(plr)
	if not plr or not plr.Character then return false end
	if IsFriend(plr) then return false end
	local part = GetAimPart(plr)
	if not part or not part.Parent then return false end
	local origin = Camera.CFrame.Position
	local target = part.Position
	local direction = (target - origin).Unit
	local distance = (target - origin).Magnitude
	if distance > Config.Distance then return false end
	local result = workspace:Raycast(origin, direction * distance, raycastParams)
	if not result then return true end
	local hit = result.Instance
	local parent = hit.Parent
	while parent do
		if parent == plr.Character then return true end
		parent = parent.Parent
	end
	return false
end

local function FindBestTarget()
	if not Camera then return nil end
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local best = nil
	local bestDist = math.huge
	local fovSq = Config.FOV ^ 2
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= Player and IsAlive(plr) and not IsFriend(plr) then
			local part = GetAimPart(plr)
			if part then
				local pos = GetScreenPos(part)
				if pos then
					local dx = pos.X - center.X
					local dy = pos.Y - center.Y
					local d = dx*dx + dy*dy
					if d < fovSq and d < bestDist then
						if IsVisible(plr) then
							best = plr
							bestDist = d
						end
					end
				end
			end
		end
	end
	
	return best
end

local function UpdateAim(dt)
	if not Camera then return end
	if not State.aimEnabled then return end
	
	State.searchTimer = State.searchTimer + dt
	
	if State.target and IsAlive(State.target) and not IsFriend(State.target) then
		local part = GetAimPart(State.target)
		if part and IsVisible(State.target) then
			State.lostTimer = 0
			local pos = part.Position
			State.targetCF = CFrame.lookAt(Camera.CFrame.Position, pos)
			
			if State.targetCF then
				State.smoothCF = State.smoothCF and State.smoothCF:Lerp(State.targetCF, Config.Smoothness) or State.targetCF
				Camera.CFrame = State.smoothCF
			end
			return
		end
		
		State.lostTimer = State.lostTimer + dt
		if State.lostTimer > 0.15 then
			State.target = nil
			State.targetCF = nil
			State.smoothCF = nil
		end
	end
	
	if State.searchTimer < 0.05 then return end
	State.searchTimer = 0
	
	local newTarget = FindBestTarget()
	if newTarget then
		State.target = newTarget
		State.lostTimer = 0
		State.targetCF = nil
		State.smoothCF = nil
		UpdateSoftware()
	end
end

--==================================================
-- HOTKEYS
--==================================================

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.One then
		ToggleAim()
	elseif input.KeyCode == Enum.KeyCode.Two then
		SwitchAimPart()
	elseif input.KeyCode == Enum.KeyCode.Three then
		ToggleXRay()
	end
end)

--==================================================
-- RUN LOOP
--==================================================

RunService.RenderStepped:Connect(function(dt)
	pcall(UpdateAim, dt)
end)

UpdateSoftware()
print("NOVA GUI v4.0 loaded")
