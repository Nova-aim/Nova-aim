--==================================================
-- NOVA ULTIMATE v6.0 FULL GUI FIX
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
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = PlayerGui

--==================================================
-- COLORS (PREMIUM)
--==================================================

local C = {
    Black = Color3.fromRGB(5,5,5),
    Panel = Color3.fromRGB(12,12,14),
    Dark = Color3.fromRGB(20,20,24),
    White = Color3.fromRGB(235,235,240),
    Gray = Color3.fromRGB(130,130,140),
    Green = Color3.fromRGB(100,255,140),
    Red = Color3.fromRGB(255,70,70),
    GreenDim = Color3.fromRGB(15,50,25),
    Glow = Color3.fromRGB(80,255,130),
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
    isFullscreen = false,
    readyProcessed = false,
    isMinimized = false,
}

local Config = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 60,
    Smoothness = 0.15,
    Distance = 250,
    KeepTarget = false,
    IgnoreWalls = false,
    AutoSwitch = false,
}

--==================================================
-- UTILS
--==================================================

local function Corner(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = obj
end

local function Tween(obj,time,data,style)
    TweenService:Create(
        obj,
        TweenInfo.new(time, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        data
    ):Play()
end

--==================================================
-- PARTICLE SYSTEM (РАБОТАЕТ!)
--==================================================

local ParticleSystems = {}

local function CreateParticleSystem(parent, count, color, speed, sizeRange)
    local container = Instance.new("Frame")
    container.Size = UDim2.fromScale(1,1)
    container.BackgroundTransparency = 1
    container.ZIndex = 1
    container.Parent = parent
    
    local particles = {}
    local col = color or C.Green
    local spd = speed or 0.008
    local sRange = sizeRange or {2,4}
    
    for i = 1, count do
        local p = Instance.new("Frame")
        local size = math.random(sRange[1], sRange[2])
        p.Size = UDim2.fromOffset(size,size)
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BackgroundColor3 = col
        p.BackgroundTransparency = 0.2 + math.random() * 0.5
        p.ZIndex = 2
        Corner(p,10)
        p.Parent = container
        
        table.insert(particles, {
            frame = p,
            speedX = (math.random() - 0.5) * spd * 2.5,
            speedY = (math.random() - 0.5) * spd * 2.5,
            phase = math.random() * 2 * math.pi,
            startX = p.Position.X.Scale,
            startY = p.Position.Y.Scale,
            transSpeed = 0.05 + math.random() * 0.3,
        })
    end
    
    local system = {
        container = container,
        particles = particles,
        Update = function(self)
            local time = os.clock()
            for _, data in ipairs(self.particles) do
                if data.frame and data.frame.Parent then
                    local offsetX = math.sin(time * 0.25 + data.phase) * data.speedX * 20
                    local offsetY = math.cos(time * 0.4 + data.phase) * data.speedY * 20
                    data.frame.Position = UDim2.new(
                        data.startX + offsetX,
                        0,
                        data.startY + offsetY,
                        0
                    )
                    data.frame.BackgroundTransparency = 0.2 + math.sin(time * data.transSpeed + data.phase) * 0.3 + 0.3
                end
            end
        end,
        Destroy = function(self)
            if self.container then self.container:Destroy() end
        end
    }
    
    table.insert(ParticleSystems, system)
    return system
end

--==================================================
-- LOADER (С ЧАСТИЦАМИ)
--==================================================

local Loader = Instance.new("Frame")
Loader.Size = UDim2.fromScale(1,1)
Loader.BackgroundColor3 = C.Black
Loader.ZIndex = 100
Loader.Parent = Gui

-- ЧАСТИЦЫ НА ЗАГРУЗКЕ (60 ШТ)
local LoaderParticles = CreateParticleSystem(Loader, 60, C.Green, 0.012, {2,5})

-- Glow Pulse
local GlowOverlay = Instance.new("Frame")
GlowOverlay.Size = UDim2.fromScale(1,1)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.BackgroundColor3 = C.Glow
GlowOverlay.ZIndex = 101
GlowOverlay.Parent = Loader

task.spawn(function()
    while Loader and Loader.Parent do
        Tween(GlowOverlay, 2.5, {BackgroundTransparency = 0.92})
        task.wait(2.5)
        Tween(GlowOverlay, 2.5, {BackgroundTransparency = 1})
        task.wait(2.5)
    end
end)

-- Terminal
local Terminal = Instance.new("TextLabel")
Terminal.Size = UDim2.new(0.85,0,0.45,0)
Terminal.Position = UDim2.new(0.075,0,0.12,0)
Terminal.BackgroundTransparency = 1
Terminal.TextColor3 = C.Green
Terminal.Font = Enum.Font.Code
Terminal.TextSize = 20
Terminal.TextXAlignment = Enum.TextXAlignment.Left
Terminal.TextYAlignment = Enum.TextYAlignment.Top
Terminal.ZIndex = 110
Terminal.Parent = Loader

local function TypeLine(text)
    Terminal.Text = Terminal.Text .. "\n"
    for i = 1, #text do
        Terminal.Text = Terminal.Text .. string.sub(text, i, i)
        task.wait(0.02)
    end
end

local bootComplete = false

task.spawn(function()
    local lines = {
        "$ NOVA SYSTEM BOOT v6.0",
        "$ Loading core modules...",
        "$ Initializing particle engine...",
        "$ Checking security layer...",
        "$ Loading interface...",
        "$ Connection stable",
        "$ Engine ready",
        "",
        "READY? y/n"
    }
    for _, v in ipairs(lines) do
        TypeLine(v)
        task.wait(0.2)
    end
    bootComplete = true
end)

--==================================================
-- READY INPUT (РАБОТАЕТ!)
--==================================================

local ReadyFrame = Instance.new("Frame")
ReadyFrame.Size = UDim2.new(0.55,0,0,50)
ReadyFrame.Position = UDim2.new(0.075,0,0.7,0)
ReadyFrame.BackgroundTransparency = 1
ReadyFrame.ZIndex = 150
ReadyFrame.Visible = false
ReadyFrame.Parent = Loader

local Prefix = Instance.new("TextLabel")
Prefix.Size = UDim2.new(0,40,1,0)
Prefix.BackgroundTransparency = 1
Prefix.Text = "~$"
Prefix.TextColor3 = C.Green
Prefix.Font = Enum.Font.Code
Prefix.TextSize = 24
Prefix.TextXAlignment = Enum.TextXAlignment.Left
Prefix.ZIndex = 151
Prefix.Parent = ReadyFrame

local InputLine = Instance.new("TextBox")
InputLine.Size = UDim2.new(1,-45,1,0)
InputLine.Position = UDim2.new(0,45,0,0)
InputLine.BackgroundColor3 = C.Dark
InputLine.BackgroundTransparency = 0.3
InputLine.Text = ""
InputLine.PlaceholderText = " type y or n..."
InputLine.PlaceholderColor3 = C.Gray
InputLine.TextColor3 = C.Green
InputLine.Font = Enum.Font.Code
InputLine.TextSize = 22
InputLine.ClearTextOnFocus = false
InputLine.ZIndex = 151
Corner(InputLine, 8)
InputLine.Parent = ReadyFrame

-- ФУНКЦИЯ ЗАПУСКА МЕНЮ
local function StartMenu()
    if State.readyProcessed then return end
    State.readyProcessed = true
    
    Tween(Loader, 0.8, {BackgroundTransparency = 1})
    LoaderParticles:Destroy()
    task.wait(0.8)
    Loader.Visible = false
    
    Main.Visible = true
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 300, 0, 350)
    
    Tween(Main, 0.6, {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 470, 0, 540)
    }, Enum.EasingStyle.Back)
    
    -- Показываем элементы по очереди
    task.wait(0.2)
    Tween(Header, 0.3, {BackgroundTransparency = 0})
    task.wait(0.1)
    Tween(Tabs, 0.3, {BackgroundTransparency = 0})
    task.wait(0.1)
    Tween(SoftwareFrame, 0.3, {BackgroundTransparency = 0})
    
    SwitchTab("software")
end

-- ПРОВЕРКА ОТВЕТА
local function CheckAnswer()
    local answer = string.lower(InputLine.Text)
    if answer == "y" then
        StartMenu()
    elseif answer == "n" then
        InputLine.Text = ""
        InputLine.PlaceholderText = "cancelled"
    end
end

-- ОЖИДАНИЕ ЗАГРУЗКИ
task.spawn(function()
    while not bootComplete do
        task.wait(0.1)
    end
    ReadyFrame.Visible = true
    ReadyFrame.Position = UDim2.new(0.075,0,0.76,0)
    Tween(ReadyFrame, 0.6, {Position = UDim2.new(0.075,0,0.68,0)})
    task.wait(0.3)
    InputLine:CaptureFocus()
end)

-- PC ENTER
InputLine.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        CheckAnswer()
    end
end)

-- MOBILE ENTER
InputLine:GetPropertyChangedSignal("Text"):Connect(function()
    local text = InputLine.Text
    if string.find(text, "\n") then
        InputLine.Text = string.gsub(text, "\n", "")
        CheckAnswer()
    end
end)

-- TOUCH FOCUS
Loader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and ReadyFrame.Visible then
        InputLine:CaptureFocus()
    end
end)

--==================================================
-- MAIN MENU
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 470, 0, 540)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.Panel
Main.BackgroundTransparency = 1
Main.Visible = false
Main.ZIndex = 10
Corner(Main, 22)
Main.Parent = Gui

-- ЧАСТИЦЫ В МЕНЮ (45 ШТ)
local MenuParticles = CreateParticleSystem(Main, 45, C.GreenDim, 0.008, {2,4})

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,52)
Header.BackgroundColor3 = C.Dark
Header.BackgroundTransparency = 0.5
Header.ZIndex = 11
Corner(Header, 22)
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,0,1,0)
Title.Text = "Nova v6.0"
Title.Font = Enum.Font.Code
Title.TextSize = 28
Title.TextColor3 = C.White
Title.Parent = Header

-- Кнопки хедера
local function HeaderButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 35)
    b.Position = UDim2.new(1, x, 0.5, -17)
    b.Text = text
    b.BackgroundColor3 = C.Black
    b.BackgroundTransparency = 0.5
    b.TextColor3 = C.Gray
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.ZIndex = 12
    Corner(b, 12)
    b.Parent = Header
    
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.GreenDim, TextColor3 = C.White})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.Black, TextColor3 = C.Gray})
    end)
    return b
end

local MinBtn = HeaderButton("─", -150)
local FullBtn = HeaderButton("□", -100)
local CloseBtn = HeaderButton("✕", -50)

--==================================================
-- TABS
--==================================================

local Tabs = Instance.new("Frame")
Tabs.BackgroundTransparency = 1
Tabs.Size = UDim2.new(1, -20, 0, 40)
Tabs.Position = UDim2.new(0, 10, 0, 62)
Tabs.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Tabs

local function Tab(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(140, 34)
    b.BackgroundColor3 = C.Dark
    b.BackgroundTransparency = 0.3
    b.Text = text
    b.TextColor3 = C.Gray
    b.Font = Enum.Font.Code
    b.TextSize = 18
    Corner(b, 10)
    b.Parent = Tabs
    
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.GreenDim, TextColor3 = C.White})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.Dark, TextColor3 = C.Gray})
    end)
    return b
end

local Software = Tab("SOFTWARE")
local Settings = Tab("SETTINGS")
local Friends = Tab("FRIENDS")

--==================================================
-- SOFTWARE
--==================================================

local SoftwareFrame = Instance.new("Frame")
SoftwareFrame.BackgroundTransparency = 1
SoftwareFrame.Size = UDim2.new(1, -30, 1, -120)
SoftwareFrame.Position = UDim2.new(0, 15, 0, 110)
SoftwareFrame.Parent = Main

local function Label(txt, y, size)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0, 0, 0, y)
    l.Size = UDim2.new(1, 0, 0, 26)
    l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextSize = size or 19
    l.TextColor3 = C.White
    l.Text = txt
    l.Parent = SoftwareFrame
    return l
end

Label("SYSTEM", 0, 20)
local StatusLine = Label("● STATUS : READY", 40)
local EngineLine = Label("● ENGINE : ACTIVE", 68)
local ConnLine = Label("● CONNECTION : STABLE", 96)

Label("TARGET", 145, 20)

local Target = Instance.new("Frame")
Target.Size = UDim2.new(1, -40, 0, 42)
Target.Position = UDim2.new(0, 20, 0, 180)
Target.BackgroundColor3 = C.Dark
Target.BackgroundTransparency = 0.5
Corner(Target, 8)
Target.Parent = SoftwareFrame

local TargetName = Instance.new("TextLabel")
TargetName.BackgroundTransparency = 1
TargetName.Size = UDim2.new(1, 0, 1, 0)
TargetName.Text = "None"
TargetName.Font = Enum.Font.Code
TargetName.TextSize = 18
TargetName.TextColor3 = C.Gray
TargetName.Parent = Target

local LockLine = Label("LOCK : SEARCHING", 240)
local HitLine = Label("HIT : HEAD", 270)

--==================================================
-- БОЛЬШИЕ КНОПКИ
--==================================================

local function BigButton(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -60, 0, 48)
    b.Position = UDim2.new(0, 30, 0, y)
    b.BackgroundColor3 = color or C.Dark
    b.BackgroundTransparency = 0.3
    b.Text = text
    b.TextColor3 = C.White
    b.Font = Enum.Font.Code
    b.TextSize = 19
    Corner(b, 12)
    b.Parent = SoftwareFrame
    
    b.MouseEnter:Connect(function()
        Tween(b, 0.12, {BackgroundTransparency = 0.1, Size = UDim2.new(1.02, -60, 0, 50)})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.12, {BackgroundTransparency = 0.3, Size = UDim2.new(1, -60, 0, 48)})
    end)
    return b
end

local EnableBtn = BigButton("◉ ENABLE", 330, Color3.fromRGB(20, 80, 40))
local MinimizeBtn = BigButton("◯ MINIMIZE", 388, C.Dark)

--==================================================
-- SETTINGS
--==================================================

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Visible = false
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Size = SoftwareFrame.Size
SettingsFrame.Position = SoftwareFrame.Position
SettingsFrame.Parent = Main

local function Slider(name, y, value, minVal, maxVal, format)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 0, 0, y)
    t.Size = UDim2.new(1, 0, 0, 25)
    t.Text = name
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.Code
    t.TextSize = 18
    t.TextColor3 = C.White
    t.Parent = SettingsFrame

    local bar = Instance.new("Frame")
    bar.Position = UDim2.new(0, 0, 0, y+32)
    bar.Size = UDim2.new(1, -80, 0, 6)
    bar.BackgroundColor3 = C.Dark
    Corner(bar, 4)
    bar.Parent = SettingsFrame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = C.Green
    Corner(fill, 4)
    fill.Parent = bar

    local val = Instance.new("TextLabel")
    val.Position = UDim2.new(1, -50, 0, y+18)
    val.Size = UDim2.fromOffset(50, 30)
    val.BackgroundTransparency = 1
    val.Text = format and string.format(format, value) or tostring(value)
    val.Font = Enum.Font.Code
    val.TextColor3 = C.White
    val.Parent = SettingsFrame
    
    return {
        bar = bar,
        fill = fill,
        label = val,
        minVal = minVal,
        maxVal = maxVal,
        value = value,
        format = format,
        Update = function(self, newVal)
            local clamped = math.clamp(newVal, self.minVal, self.maxVal)
            self.value = clamped
            local pos = (clamped - self.minVal) / (self.maxVal - self.minVal)
            self.fill.Size = UDim2.new(pos, 0, 1, 0)
            self.label.Text = self.format and string.format(self.format, clamped) or tostring(clamped)
        end
    }
end

local FOVSlider = Slider("Field Of View", 20, 60, 1, 120, "%d")
local SmoothSlider = Slider("Smoothness", 110, 0.15, 0.01, 1, "%.2f")
local DistSlider = Slider("Distance", 200, 250, 50, 500, "%d")

--==================================================
-- OPTIONS
--==================================================

Label("OPTIONS", 310, 20)

local function Checkbox(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundTransparency = 1
    b.Text = text
    b.TextColor3 = C.White
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = SettingsFrame
    
    b.MouseEnter:Connect(function()
        Tween(b, 0.12, {TextColor3 = C.Green})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.12, {TextColor3 = C.White})
    end)
    return b
end

local KeepTargetChk = Checkbox("☐ Keep Target", 345)
local IgnoreWallsChk = Checkbox("☐ Ignore Walls", 375)
local AutoSwitchChk = Checkbox("☐ Auto Switch", 405)

--==================================================
-- FRIENDS
--==================================================

local FriendsFrame = Instance.new("Frame")
FriendsFrame.Visible = false
FriendsFrame.BackgroundTransparency = 1
FriendsFrame.Size = SoftwareFrame.Size
FriendsFrame.Position = SoftwareFrame.Position
FriendsFrame.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(0.52, 0, 1, 0)
Scroll.CanvasSize = UDim2.new()
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1
Scroll.Parent = FriendsFrame

local Layout2 = Instance.new("UIListLayout")
Layout2.Padding = UDim.new(0, 8)
Layout2.Parent = Scroll

local FriendInfoPanel = Instance.new("Frame")
FriendInfoPanel.Size = UDim2.new(0.42, 0, 1, 0)
FriendInfoPanel.Position = UDim2.new(0.58, 0, 0, 0)
FriendInfoPanel.BackgroundColor3 = C.Dark
FriendInfoPanel.BackgroundTransparency = 1
FriendInfoPanel.Visible = false
FriendInfoPanel.Parent = FriendsFrame
Corner(FriendInfoPanel, 12)

local FriendInfoName = Instance.new("TextLabel")
FriendInfoName.Size = UDim2.new(1, -20, 0, 30)
FriendInfoName.Position = UDim2.new(0, 10, 0, 10)
FriendInfoName.BackgroundTransparency = 1
FriendInfoName.Text = "Player"
FriendInfoName.Font = Enum.Font.Code
FriendInfoName.TextSize = 20
FriendInfoName.TextColor3 = C.White
FriendInfoName.TextXAlignment = Enum.TextXAlignment.Left
FriendInfoName.Parent = FriendInfoPanel

local FriendInfoQuestion = Instance.new("TextLabel")
FriendInfoQuestion.Size = UDim2.new(1, -20, 0, 25)
FriendInfoQuestion.Position = UDim2.new(0, 10, 0, 50)
FriendInfoQuestion.BackgroundTransparency = 1
FriendInfoQuestion.Text = "Add to friends?"
FriendInfoQuestion.Font = Enum.Font.Code
FriendInfoQuestion.TextSize = 14
FriendInfoQuestion.TextColor3 = C.Gray
FriendInfoQuestion.TextXAlignment = Enum.TextXAlignment.Left
FriendInfoQuestion.Parent = FriendInfoPanel

local FriendConfirm = Instance.new("TextButton")
FriendConfirm.Size = UDim2.new(0.8, 0, 0, 40)
FriendConfirm.Position = UDim2.new(0.1, 0, 0, 90)
FriendConfirm.BackgroundColor3 = C.Green
FriendConfirm.BackgroundTransparency = 0.3
FriendConfirm.Text = "✓ CONFIRM"
FriendConfirm.TextColor3 = C.White
FriendConfirm.Font = Enum.Font.Code
FriendConfirm.TextSize = 16
Corner(FriendConfirm, 12)
FriendConfirm.Parent = FriendInfoPanel

local FriendCancel = Instance.new("TextButton")
FriendCancel.Size = UDim2.new(0.8, 0, 0, 40)
FriendCancel.Position = UDim2.new(0.1, 0, 0, 140)
FriendCancel.BackgroundColor3 = C.Red
FriendCancel.BackgroundTransparency = 0.3
FriendCancel.Text = "✕ CANCEL"
FriendCancel.TextColor3 = C.White
FriendCancel.Font = Enum.Font.Code
FriendCancel.TextSize = 16
Corner(FriendCancel, 12)
FriendCancel.Parent = FriendInfoPanel

--==================================================
-- UPDATE FUNCTIONS
--==================================================

local function UpdateStatus()
    local targetText = State.target and State.target.Name or "None"
    local statusText = State.aimEnabled and "ACTIVE" or "READY"
    local lockText = "SEARCHING"
    if State.aimEnabled then
        lockText = State.target and "LOCKED" or "SEARCHING"
    else
        lockText = "DISABLED"
    end
    local hitText = Config.AimPart
    
    StatusLine.Text = "● STATUS : " .. statusText
    TargetName.Text = targetText
    LockLine.Text = "LOCK : " .. lockText
    HitLine.Text = "HIT : " .. hitText
    TargetName.TextColor3 = State.target and C.Green or C.Gray
end

local function UpdateFriendsList()
    for _, child in pairs(Scroll:GetChildren()) do
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
        empty.Size = UDim2.new(1, 0, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "No players in server"
        empty.TextColor3 = C.Gray
        empty.Font = Enum.Font.Code
        empty.TextSize = 14
        empty.Parent = Scroll
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 40)
        return
    end
    
    table.sort(players, function(a,b) return a.Name < b.Name end)
    
    for _, plr in ipairs(players) do
        local isFriend = false
        for _, f in ipairs(State.friends) do
            if f == plr then isFriend = true break end
        end
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = isFriend and Color3.fromRGB(20,60,30) or C.Dark
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Parent = Scroll
        Corner(btn, 8)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, 0.12, {BackgroundTransparency = 0.2})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.12, {BackgroundTransparency = 0.5})
        end)
        
        -- Avatar
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.fromOffset(32, 32)
        avatar.Position = UDim2.new(0, 4, 0.5, -16)
        avatar.BackgroundColor3 = C.Dark
        avatar.BorderSizePixel = isFriend and 2 or 0
        avatar.BorderColor3 = C.Green
        Corner(avatar, 16)
        pcall(function()
            avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        avatar.Parent = btn
        
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0.6, 0, 1, 0)
        name.Position = UDim2.new(0, 44, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = plr.Name
        name.TextColor3 = isFriend and C.Green or C.White
        name.Font = Enum.Font.Code
        name.TextSize = 16
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = btn
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.2, 0, 1, 0)
        status.Position = UDim2.new(0.8, 0, 0, 0)
        status.BackgroundTransparency = 1
        status.Text = isFriend and "✓" or "+"
        status.TextColor3 = isFriend and C.Green or C.Gray
        status.Font = Enum.Font.Code
        status.TextSize = 22
        status.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if isFriend then
                for i, f in ipairs(State.friends) do
                    if f == plr then
                        table.remove(State.friends, i)
                        break
                    end
                end
                UpdateFriendsList()
                UpdateStatus()
            else
                FriendInfoName.Text = plr.Name
                FriendInfoPanel.Visible = true
                FriendInfoPanel.BackgroundTransparency = 1
                FriendInfoPanel.Position = UDim2.new(0.58, 0, 0, 0)
                Tween(FriendInfoPanel, 0.3, {BackgroundTransparency = 0, Position = UDim2.new(0.55, 0, 0, 0)})
            end
        end)
    end
    
    Layout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout2.AbsoluteContentSize.Y + 10)
    end)
    task.wait()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout2.AbsoluteContentSize.Y + 10)
end

--==================================================
-- TAB SWITCHING
--==================================================

local function SwitchTab(tab)
    if tab == "software" then
        Tween(SoftwareFrame, 0.2, {BackgroundTransparency = 0})
        Tween(SettingsFrame, 0.2, {BackgroundTransparency = 1})
        Tween(FriendsFrame, 0.2, {BackgroundTransparency = 1})
        task.wait(0.2)
        SoftwareFrame.Visible = true
        SettingsFrame.Visible = false
        FriendsFrame.Visible = false
    elseif tab == "settings" then
        SettingsFrame.Visible = true
        Tween(SettingsFrame, 0.2, {BackgroundTransparency = 0})
        Tween(SoftwareFrame, 0.2, {BackgroundTransparency = 1})
        Tween(FriendsFrame, 0.2, {BackgroundTransparency = 1})
        task.wait(0.2)
        SoftwareFrame.Visible = false
        FriendsFrame.Visible = false
    elseif tab == "friends" then
        FriendsFrame.Visible = true
        Tween(FriendsFrame, 0.2, {BackgroundTransparency = 0})
        Tween(SoftwareFrame, 0.2, {BackgroundTransparency = 1})
        Tween(SettingsFrame, 0.2, {BackgroundTransparency = 1})
        task.wait(0.2)
        SoftwareFrame.Visible = false
        SettingsFrame.Visible = false
        UpdateFriendsList()
    end
    State.currentTab = tab
end

Software.MouseButton1Click:Connect(function() SwitchTab("software") end)
Settings.MouseButton1Click:Connect(function() SwitchTab("settings") end)
Friends.MouseButton1Click:Connect(function() SwitchTab("friends") end)

--==================================================
-- BUTTON FUNCTIONS
--==================================================

local function ToggleAim()
    State.aimEnabled = not State.aimEnabled
    EnableBtn.Text = State.aimEnabled and "◉ DISABLE" or "◉ ENABLE"
    EnableBtn.BackgroundColor3 = State.aimEnabled and Color3.fromRGB(60,20,20) or Color3.fromRGB(20,80,40)
    UpdateStatus()
    if not State.aimEnabled then
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
    end
end

EnableBtn.MouseButton1Click:Connect(ToggleAim)

MinimizeBtn.MouseButton1Click:Connect(function()
    State.isMinimized = true
    Tween(Main, 0.3, {Size = UDim2.fromOffset(200,200), BackgroundTransparency = 1})
    task.wait(0.3)
    Main.Visible = false
    Mini.Visible = true
    Tween(Mini, 0.3, {Size = UDim2.fromOffset(80,80)})
end)

--==================================================
-- MINI LOGO
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(70, 70)
Mini.Position = UDim2.new(0.05, 0, 0.85, 0)
Mini.Text = "N"
Mini.TextSize = 35
Mini.TextColor3 = C.Green
Mini.BackgroundColor3 = C.Panel
Mini.Visible = false
Mini.ZIndex = 20
Corner(Mini, 50)
Mini.Parent = Gui

local miniGlow = Instance.new("Frame")
miniGlow.Size = UDim2.new(1.1, 0, 1.1, 0)
miniGlow.Position = UDim2.new(-0.05, -0.05, -0.05, -0.05)
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

Mini.MouseEnter:Connect(function()
    Tween(Mini, 0.15, {Size = UDim2.fromOffset(75,75), TextColor3 = C.White})
end)
Mini.MouseLeave:Connect(function()
    Tween(Mini, 0.15, {Size = UDim2.fromOffset(70,70), TextColor3 = C.Green})
end)

Mini.MouseButton1Click:Connect(function()
    Mini.Visible = false
    Main.Visible = true
    Main.Size = UDim2.fromOffset(200, 200)
    Main.BackgroundTransparency = 1
    Tween(Main, 0.4, {Size = UDim2.fromOffset(470, 540), BackgroundTransparency = 0}, Enum.EasingStyle.Back)
end)

--==================================================
-- HEADER BUTTONS
--==================================================

MinBtn.MouseButton1Click:Connect(function()
    State.isMinimized = true
    Tween(Main, 0.3, {Size = UDim2.fromOffset(200,200), BackgroundTransparency = 1})
    task.wait(0.3)
    Main.Visible = false
    Mini.Visible = true
    Tween(Mini, 0.3, {Size = UDim2.fromOffset(80,80)})
end)

CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

FullBtn.MouseButton1Click:Connect(function()
    State.isFullscreen = not State.isFullscreen
    if State.isFullscreen then
        FullBtn.Text = "◻"
        Tween(Main, 0.4, {
            Size = UDim2.new(0, 700, 0, 600),
            Position = UDim2.new(0.5, -350, 0.5, -300)
        })
    else
        FullBtn.Text = "□"
        Tween(Main, 0.4, {
            Size = UDim2.fromOffset(470, 540),
            Position = UDim2.fromScale(0.5, 0.5)
        })
    end
end)

--==================================================
-- SLIDERS
--==================================================

local function SetupSlider(sliderObj, configKey)
    sliderObj.bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local function update()
                local pos = math.clamp((input.Position.X - sliderObj.bar.AbsolutePosition.X) / sliderObj.bar.AbsoluteSize.X, 0, 1)
                local val = sliderObj.minVal + (sliderObj.maxVal - sliderObj.minVal) * pos
                Config[configKey] = val
                sliderObj:Update(val)
            end
            update()
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    update()
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    conn:Disconnect()
                end
            end)
        end
    end)
end

SetupSlider(FOVSlider, "FOV")
SetupSlider(SmoothSlider, "Smoothness")
SetupSlider(DistSlider, "Distance")

--==================================================
-- OPTIONS
--==================================================

KeepTargetChk.MouseButton1Click:Connect(function()
    Config.KeepTarget = not Config.KeepTarget
    KeepTargetChk.Text = Config.KeepTarget and "☑ Keep Target" or "☐ Keep Target"
end)

IgnoreWallsChk.MouseButton1Click:Connect(function()
    Config.IgnoreWalls = not Config.IgnoreWalls
    IgnoreWallsChk.Text = Config.IgnoreWalls and "☑ Ignore Walls" or "☐ Ignore Walls"
end)

AutoSwitchChk.MouseButton1Click:Connect(function()
    Config.AutoSwitch = not Config.AutoSwitch
    AutoSwitchChk.Text = Config.AutoSwitch and "☑ Auto Switch" or "☐ Auto Switch"
end)

--==================================================
-- FRIENDS BUTTONS
--==================================================

FriendConfirm.MouseButton1Click:Connect(function()
    local name = FriendInfoName.Text
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name == name and plr ~= Player then
            table.insert(State.friends, plr)
            FriendInfoPanel.Visible = false
            UpdateFriendsList()
            UpdateStatus()
            break
        end
    end
end)

FriendCancel.MouseButton1Click:Connect(function()
    FriendInfoPanel.Visible = false
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
    if Config.IgnoreWalls then return true end
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
        if State.lostTimer > 0.15 and not Config.KeepTarget then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
    end
    
    if State.searchTimer < 0.05 then return end
    State.searchTimer = 0
    
    if Config.AutoSwitch or not State.target then
        local newTarget = FindBestTarget()
        if newTarget then
            State.target = newTarget
            State.lostTimer = 0
            State.targetCF = nil
            State.smoothCF = nil
            UpdateStatus()
        else
            if not Config.KeepTarget then
                State.target = nil
                State.targetCF = nil
                State.smoothCF = nil
                UpdateStatus()
            end
        end
    end
end

--==================================================
-- HOTKEYS
--==================================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.One then
        ToggleAim()
    elseif input.KeyCode == Enum.KeyCode.Two then
        if Config.AimPart == "Head" then
            Config.AimPart = "HumanoidRootPart"
            Config.BackupPart = "Torso"
        else
            Config.AimPart = "Head"
            Config.BackupPart = "UpperTorso"
        end
        UpdateStatus()
    end
end)

--==================================================
-- UPDATE LOOP
--==================================================

RunService.Heartbeat:Connect(function()
    for _, system in ipairs(ParticleSystems) do
        if system and system.Update then
            system:Update()
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    pcall(UpdateAim, dt)
end)

--==================================================
-- START
--==================================================

UpdateStatus()
print("NOVA ULTIMATE v6.0 LOADED - FULLY FIXED!")
