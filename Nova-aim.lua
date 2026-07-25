--==================================================
-- NOVA UI v4.0
-- Loader + Premium GUI System
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local GuiParent = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local old = GuiParent:FindFirstChild("NovaUI")
if old then
    old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "NovaUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.Parent = GuiParent

--==================================================
-- COLORS
--==================================================

local C = {
    Black = Color3.fromRGB(5,5,5),
    Panel = Color3.fromRGB(15,15,15),
    Soft = Color3.fromRGB(25,25,25),
    White = Color3.fromRGB(240,240,240),
    Gray = Color3.fromRGB(130,130,130),
    Green = Color3.fromRGB(100,255,140),
    Red = Color3.fromRGB(255,80,80),
    Dark = Color3.fromRGB(8,8,8),
}

--==================================================
-- STATE
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
    selectedFriend = nil,
}

--==================================================
-- CONFIG
--==================================================

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

local function Tween(obj,time,props)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function TweenIn(obj,time,props)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        props
    ):Play()
end

--==================================================
-- PARTICLES SYSTEM (PLAVNYE)
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
        
        local speedX = (math.random() - 0.5) * 0.02
        local speedY = (math.random() - 0.5) * 0.02
        local phase = math.random() * 2 * math.pi
        
        table.insert(particles, {
            frame = p,
            speedX = speedX,
            speedY = speedY,
            phase = phase,
            startPos = p.Position,
            transSpeed = 0.01 + math.random() * 0.02,
        })
    end
    
    task.spawn(function()
        while parent and parent.Parent do
            for _, data in ipairs(particles) do
                if data.frame and data.frame.Parent then
                    local time = os.clock()
                    local offsetX = math.sin(time * 0.5 + data.phase) * data.speedX * 5
                    local offsetY = math.cos(time * 0.7 + data.phase) * data.speedY * 5
                    data.frame.Position = UDim2.new(
                        data.startPos.X.Scale + offsetX,
                        0,
                        data.startPos.Y.Scale + offsetY,
                        0
                    )
                    data.frame.BackgroundTransparency = 0.4 + math.sin(time * data.transSpeed + data.phase) * 0.2 + 0.2
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
Loader.Parent = Gui

-- Particles inside loader
local loaderParticles = CreateParticles(Loader, 40)

local Terminal = Instance.new("TextLabel")
Terminal.Size = UDim2.new(0.8,0,0.5,0)
Terminal.Position = UDim2.new(0.1,0,0.25,0)
Terminal.BackgroundTransparency = 1
Terminal.TextColor3 = C.Green
Terminal.Font = Enum.Font.Code
Terminal.TextSize = 18
Terminal.TextXAlignment = Enum.TextXAlignment.Left
Terminal.TextYAlignment = Enum.TextYAlignment.Top
Terminal.Parent = Loader

local lines = {
    "> NOVA SYSTEM BOOT",
    "> Loading modules...",
    "> Checking security...",
    "> Loading interface...",
    "> Initializing engine...",
    "> Particles loaded",
    "> Interface ready",
    "",
    "READY? y/n"
}

for _,v in ipairs(lines) do
    Terminal.Text = Terminal.Text .. v .. "\n"
    task.wait(0.3)
end

-- Auto transition after 2 seconds
task.wait(2)

-- Fade out loader
Tween(Loader, 0.7, {BackgroundTransparency = 1})
task.wait(0.8)
Loader:Destroy()

--==================================================
-- MAIN MENU
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,450,0,520)
Main.Position = UDim2.new(0.5,-225,0.5,-260)
Main.BackgroundColor3 = C.Panel
Main.BackgroundTransparency = 1
Main.Parent = Gui
Corner(Main,30)

-- Particles inside menu
local menuParticles = CreateParticles(Main, 25)

-- Scale animation on appear
Main.Size = UDim2.new(0,300,0,350)
Tween(Main, 0.6, {
    Size = UDim2.new(0,450,0,520),
    BackgroundTransparency = 0
})

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundTransparency = 1
Title.Text = "NOVA"
Title.TextColor3 = C.White
Title.Font = Enum.Font.Code
Title.TextSize = 36
Title.Parent = Main

--==================================================
-- TABS
--==================================================

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1,-40,0,40)
Tabs.Position = UDim2.new(0,20,0,70)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local function CreateTab(text, x, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28,0,1,0)
    btn.Position = UDim2.new(x,0,0,0)
    btn.BackgroundColor3 = C.Soft
    btn.Text = text
    btn.TextColor3 = C.White
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Parent = Tabs
    Corner(btn,20)
    
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(35,35,35)})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = C.Soft})
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Content area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-40,0,280)
Content.Position = UDim2.new(0,20,0,125)
Content.BackgroundTransparency = 1
Content.Parent = Main

--==================================================
-- SOFTWARE TAB
--==================================================

local SoftwareContent = Instance.new("Frame")
SoftwareContent.Size = UDim2.new(1,0,1,0)
SoftwareContent.BackgroundTransparency = 1
SoftwareContent.Parent = Content

local SoftwareText = Instance.new("TextLabel")
SoftwareText.Size = UDim2.new(1,0,1,0)
SoftwareText.BackgroundTransparency = 1
SoftwareText.TextColor3 = C.White
SoftwareText.Font = Enum.Font.Code
SoftwareText.TextSize = 15
SoftwareText.TextXAlignment = Enum.TextXAlignment.Left
SoftwareText.TextYAlignment = Enum.TextYAlignment.Top
SoftwareText.Text = [[
SYSTEM STATUS

● Status: READY
● Connection: STABLE
● Engine: ACTIVE


CURRENT TARGET

None


STATUS
Lock: Searching
Target: ---
Hit: Head]]
SoftwareText.Parent = SoftwareContent

-- Buttons
local function CreateActionButton(text, y, col)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45,0,0,38)
    btn.Position = UDim2.new(0.275,0,y,0)
    btn.BackgroundColor3 = C.Soft
    btn.Text = text
    btn.TextColor3 = C.White
    btn.Font = Enum.Font.Code
    btn.TextSize = 15
    btn.Parent = Main
    Corner(btn,25)
    
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.12, {BackgroundColor3 = Color3.fromRGB(35,35,35), Size = UDim2.new(0.47,0,0,40)})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.12, {BackgroundColor3 = C.Soft, Size = UDim2.new(0.45,0,0,38)})
    end)
    return btn
end

local EnableBtn = CreateActionButton("ENABLE", 420)
local TargetBtn = CreateActionButton("HEAD", 465)
local XrayBtn = CreateActionButton("XRAY OFF", 510)
local MinimizeBtn = CreateActionButton("MINIMIZE", 555)

--==================================================
-- FRIENDS TAB
--==================================================

local FriendsContent = Instance.new("Frame")
FriendsContent.Size = UDim2.new(1,0,1,0)
FriendsContent.BackgroundTransparency = 1
FriendsContent.Visible = false
FriendsContent.Parent = Content

local FriendList = Instance.new("ScrollingFrame")
FriendList.Size = UDim2.new(0.6,0,1,0)
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
FriendInfo.BackgroundColor3 = C.Soft
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
ConfirmBtn.Size = UDim2.new(0.8,0,0,40)
ConfirmBtn.Position = UDim2.new(0.1,0,0,85)
ConfirmBtn.BackgroundColor3 = C.Green
ConfirmBtn.BackgroundTransparency = 0.2
ConfirmBtn.Text = "✓ CONFIRM"
ConfirmBtn.TextColor3 = C.White
ConfirmBtn.Font = Enum.Font.Code
ConfirmBtn.TextSize = 14
ConfirmBtn.Parent = FriendInfo
Corner(ConfirmBtn, 20)

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.8,0,0,40)
CancelBtn.Position = UDim2.new(0.1,0,0,130)
CancelBtn.BackgroundColor3 = C.Red
CancelBtn.BackgroundTransparency = 0.2
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
        btn.BackgroundColor3 = C.Soft
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
                UpdateSoftwareInfo()
            else
                FriendName.Text = plr.Name
                FriendInfo.Visible = true
                FriendInfo.BackgroundTransparency = 1
                Tween(FriendInfo, 0.3, {BackgroundTransparency = 0})
                
                ConfirmBtn.MouseButton1Click:Connect(function()
                    table.insert(State.friends, plr)
                    FriendInfo.Visible = false
                    UpdateFriendsList()
                    UpdateSoftwareInfo()
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
-- SETTINGS TAB
--==================================================

local SettingsContent = Instance.new("Frame")
SettingsContent.Size = UDim2.new(1,0,1,0)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
SettingsContent.Parent = Content

local SettingsText = Instance.new("TextLabel")
SettingsText.Size = UDim2.new(1,0,1,0)
SettingsText.BackgroundTransparency = 1
SettingsText.TextColor3 = C.White
SettingsText.Font = Enum.Font.Code
SettingsText.TextSize = 15
SettingsText.TextXAlignment = Enum.TextXAlignment.Left
SettingsText.TextYAlignment = Enum.TextYAlignment.Top
SettingsText.Text = [[
CONFIGURATION

Field Of View
◀──────●──────▶ 60

Smoothness
◀──────●──────▶ 0.15

Distance
◀──────●──────▶ 250
]]
SettingsText.Parent = SettingsContent

--==================================================
-- TAB SWITCHING
--==================================================

local function SwitchTab(tab)
    if tab == "software" then
        SoftwareContent.Visible = true
        FriendsContent.Visible = false
        SettingsContent.Visible = false
        UpdateSoftwareInfo()
    elseif tab == "friends" then
        SoftwareContent.Visible = false
        FriendsContent.Visible = true
        SettingsContent.Visible = false
        UpdateFriendsList()
    elseif tab == "settings" then
        SoftwareContent.Visible = false
        FriendsContent.Visible = false
        SettingsContent.Visible = true
    end
    State.currentTab = tab
end

CreateTab("SOFTWARE", 0, function() SwitchTab("software") end)
CreateTab("FRIENDS", 0.36, function() SwitchTab("friends") end)
CreateTab("SETTINGS", 0.72, function() SwitchTab("settings") end)

--==================================================
-- UPDATE FUNCTIONS
--==================================================

local function UpdateSoftwareInfo()
    local targetText = State.target and State.target.Name or "None"
    local statusText = State.aimEnabled and "ACTIVE" or "READY"
    local lockText = State.aimEnabled and (State.target and "LOCKED" or "Searching") or "Disabled"
    local hitText = Config.AimPart == "Head" and "Head" or "Body"
    
    SoftwareText.Text = [[
SYSTEM STATUS

● Status: ]] .. statusText .. [[
● Connection: STABLE
● Engine: ACTIVE


CURRENT TARGET

]] .. targetText .. [[


STATUS
Lock: ]] .. lockText .. [[
Target: ---
Hit: ]] .. hitText
end

--==================================================
-- BUTTON HANDLERS
--==================================================

EnableBtn.MouseButton1Click:Connect(function()
    State.aimEnabled = not State.aimEnabled
    EnableBtn.Text = State.aimEnabled and "DISABLE" or "ENABLE"
    EnableBtn.TextColor3 = State.aimEnabled and C.Red or C.White
    UpdateSoftwareInfo()
    if not State.aimEnabled then
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
    end
end)

TargetBtn.MouseButton1Click:Connect(function()
    if Config.AimPart == "Head" then
        Config.AimPart = "HumanoidRootPart"
        Config.BackupPart = "Torso"
        TargetBtn.Text = "BODY"
    else
        Config.AimPart = "Head"
        Config.BackupPart = "UpperTorso"
        TargetBtn.Text = "HEAD"
    end
    UpdateSoftwareInfo()
end)

XrayBtn.MouseButton1Click:Connect(function()
    State.xrayEnabled = not State.xrayEnabled
    XrayBtn.Text = State.xrayEnabled and "XRAY ON" or "XRAY OFF"
    XrayBtn.TextColor3 = State.xrayEnabled and C.Green or C.White
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    CreateMiniLogo()
end)

--==================================================
-- MINI LOGO
--==================================================

local MiniLogo = nil

function CreateMiniLogo()
    if MiniLogo and MiniLogo.Parent then
        MiniLogo.Visible = true
        return
    end
    
    MiniLogo = Instance.new("TextButton")
    MiniLogo.Size = UDim2.new(0,70,0,70)
    MiniLogo.Position = UDim2.new(0.05,0,0.85,0)
    MiniLogo.Text = "N"
    MiniLogo.TextSize = 32
    MiniLogo.Font = Enum.Font.Code
    MiniLogo.TextColor3 = C.White
    MiniLogo.BackgroundColor3 = C.Panel
    MiniLogo.BackgroundTransparency = 0.5
    MiniLogo.Parent = Gui
    Corner(MiniLogo, 50)
    
    -- Glow
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1.1,0,1.1,0)
    glow.Position = UDim2.new(-0.05,-0.05,-0.05,-0.05)
    glow.BackgroundTransparency = 1
    glow.BackgroundColor3 = C.Green
    glow.BorderSizePixel = 2
    glow.BorderColor3 = C.Green
    glow.BorderTransparency = 0.7
    glow.Parent = MiniLogo
    Corner(glow, 55)
    
    -- Pulse
    task.spawn(function()
        while MiniLogo and MiniLogo.Parent do
            Tween(glow, 1.5, {BorderTransparency = 0.3})
            task.wait(1.5)
            Tween(glow, 1.5, {BorderTransparency = 0.7})
            task.wait(1.5)
        end
    end)
    
    -- Drag
    local dragData = {dragging = false, startPos = nil, startOffset = nil}
    
    MiniLogo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.dragging = true
            dragData.startPos = input.Position
            dragData.startOffset = MiniLogo.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragData.dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragData.startPos
                MiniLogo.Position = UDim2.new(
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
    
    MiniLogo.MouseButton1Click:Connect(function()
        MiniLogo.Visible = false
        if Main then
            Main.Visible = true
            Main.Size = UDim2.new(0,300,0,350)
            Tween(Main, 0.5, {Size = UDim2.new(0,450,0,520)})
        end
    end)
end

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
        UpdateSoftwareInfo()
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
            UpdateSoftwareInfo()
        end
    end
end

--==================================================
-- HOTKEYS
--==================================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.One then
        State.aimEnabled = not State.aimEnabled
        EnableBtn.Text = State.aimEnabled and "DISABLE" or "ENABLE"
        EnableBtn.TextColor3 = State.aimEnabled and C.Red or C.White
        UpdateSoftwareInfo()
        if not State.aimEnabled then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
    elseif input.KeyCode == Enum.KeyCode.Two then
        if Config.AimPart == "Head" then
            Config.AimPart = "HumanoidRootPart"
            Config.BackupPart = "Torso"
            TargetBtn.Text = "BODY"
        else
            Config.AimPart = "Head"
            Config.BackupPart = "UpperTorso"
            TargetBtn.Text = "HEAD"
        end
        UpdateSoftwareInfo()
    elseif input.KeyCode == Enum.KeyCode.Three then
        State.xrayEnabled = not State.xrayEnabled
        XrayBtn.Text = State.xrayEnabled and "XRAY ON" or "XRAY OFF"
        XrayBtn.TextColor3 = State.xrayEnabled and C.Green or C.White
    end
end)

--==================================================
-- RUN LOOP
--==================================================

RunService.RenderStepped:Connect(function(dt)
    pcall(UpdateAim, dt)
end)

print("NOVA UI v4.0 LOADED")
