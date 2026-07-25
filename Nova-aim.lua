--==================================================
-- NOVA UI SYSTEM v4.1 FINAL FIX
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
-- COLORS
--==================================================

local C = {
    Black = Color3.fromRGB(5,5,5),
    Panel = Color3.fromRGB(15,15,15),
    Dark = Color3.fromRGB(22,22,22),
    White = Color3.fromRGB(240,240,240),
    Gray = Color3.fromRGB(130,130,130),
    Green = Color3.fromRGB(120,255,150),
    Red = Color3.fromRGB(255,70,70),
    GreenDim = Color3.fromRGB(30,80,40),
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
    isFullscreen = false,
    readyProcessed = false,
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

local function Tween(obj,time,data)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        data
    ):Play()
end

--==================================================
-- LOADER
--==================================================

local Loader = Instance.new("Frame")
Loader.Size = UDim2.fromScale(1,1)
Loader.BackgroundColor3 = C.Black
Loader.ZIndex = 100
Loader.Parent = Gui

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Size = UDim2.fromScale(1,1)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.BackgroundColor3 = C.Green
GlowOverlay.ZIndex = 101
GlowOverlay.Parent = Loader

local Terminal = Instance.new("TextLabel")
Terminal.Size = UDim2.new(0.8,0,0.4,0)
Terminal.Position = UDim2.new(0.1,0,0.15,0)
Terminal.BackgroundTransparency = 1
Terminal.TextColor3 = C.Green
Terminal.Font = Enum.Font.Code
Terminal.TextSize = 20
Terminal.TextXAlignment = Enum.TextXAlignment.Left
Terminal.TextYAlignment = Enum.TextYAlignment.Top
Terminal.ZIndex = 110
Terminal.Parent = Loader

--==================================================
-- PARTICLES
--==================================================

local Particles = {}
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Size = UDim2.fromScale(1,1)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ZIndex = 105
ParticleContainer.Parent = Loader

for i = 1,40 do
    local p = Instance.new("Frame")
    local size = math.random(2,4)
    p.Size = UDim2.fromOffset(size,size)
    p.Position = UDim2.fromScale(math.random(), math.random())
    p.BackgroundColor3 = C.Green
    p.BackgroundTransparency = 0.3 + math.random() * 0.3
    p.ZIndex = 106
    Corner(p,10)
    p.Parent = ParticleContainer
    
    table.insert(Particles, {
        frame = p,
        speedX = (math.random() - 0.5) * 0.008,
        speedY = (math.random() - 0.5) * 0.008,
        phase = math.random() * 2 * math.pi,
        startX = p.Position.X.Scale,
        startY = p.Position.Y.Scale,
        transSpeed = 0.1 + math.random() * 0.2,
    })
end

local function UpdateParticles()
    local time = os.clock()
    for _, data in ipairs(Particles) do
        if data.frame and data.frame.Parent then
            local offsetX = math.sin(time * 0.3 + data.phase) * data.speedX * 12
            local offsetY = math.cos(time * 0.5 + data.phase) * data.speedY * 12
            data.frame.Position = UDim2.new(
                data.startX + offsetX,
                0,
                data.startY + offsetY,
                0
            )
            data.frame.BackgroundTransparency = 0.3 + math.sin(time * data.transSpeed + data.phase) * 0.2 + 0.2
        end
    end
end

--==================================================
-- GLOW PULSE
--==================================================

task.spawn(function()
    while Loader and Loader.Parent do
        Tween(GlowOverlay, 2, {BackgroundTransparency = 0.92})
        task.wait(2)
        Tween(GlowOverlay, 2, {BackgroundTransparency = 1})
        task.wait(2)
    end
end)

--==================================================
-- TERMINAL OUTPUT
--==================================================

local function TypeLine(text)
    Terminal.Text = Terminal.Text .. "\n"
    for i = 1,#text do
        Terminal.Text = Terminal.Text .. string.sub(text,i,i)
        task.wait(0.025)
    end
end

local bootComplete = false

task.spawn(function()
    local lines = {
        "$ NOVA SYSTEM BOOT",
        "$ Loading modules...",
        "$ Checking interface...",
        "$ Particle engine online",
        "$ Security layer ready",
        "$ UI initialized",
        "",
        "READY? y/n"
    }
    
    for _,v in ipairs(lines) do
        TypeLine(v)
        task.wait(0.25)
    end
    bootComplete = true
end)

--==================================================
-- READY INPUT
--==================================================

local ReadyFrame = Instance.new("Frame")
ReadyFrame.Size = UDim2.new(0.45,0,0,45)
ReadyFrame.Position = UDim2.new(0.1,0,0.7,0)
ReadyFrame.BackgroundTransparency = 1
ReadyFrame.ZIndex = 150
ReadyFrame.Visible = false
ReadyFrame.Parent = Loader

local Prefix = Instance.new("TextLabel")
Prefix.Size = UDim2.new(0,35,1,0)
Prefix.BackgroundTransparency = 1
Prefix.Text = "~$"
Prefix.TextColor3 = C.Green
Prefix.Font = Enum.Font.Code
Prefix.TextSize = 22
Prefix.TextXAlignment = Enum.TextXAlignment.Left
Prefix.ZIndex = 151
Prefix.Parent = ReadyFrame

local InputLine = Instance.new("TextBox")
InputLine.Size = UDim2.new(1,-40,1,0)
InputLine.Position = UDim2.new(0,40,0,0)
InputLine.BackgroundTransparency = 1
InputLine.Text = ""
InputLine.PlaceholderText = " type y or n..."
InputLine.PlaceholderColor3 = C.Gray
InputLine.TextColor3 = C.Green
InputLine.Font = Enum.Font.Code
InputLine.TextSize = 22
InputLine.ClearTextOnFocus = false
InputLine.ZIndex = 151
InputLine.Parent = ReadyFrame

--==================================================
-- MAIN WINDOW (создаём до функций)
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,450,0,550)
Main.Position = UDim2.new(0.5,-225,0.5,-275)
Main.BackgroundColor3 = C.Panel
Main.Visible = false
Main.ZIndex = 10
Corner(Main,30)
Main.Parent = Gui

--==================================================
-- FORWARD DECLARATIONS
--==================================================

local StartMenu
local SwitchTab

--==================================================
-- START MENU FUNCTION
--==================================================

StartMenu = function()
    if State.readyProcessed then return end
    State.readyProcessed = true
    
    Tween(Loader, 0.7, {BackgroundTransparency = 1})
    task.wait(0.7)
    Loader.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0,300,0,350)
    Tween(Main, 0.5, {Size = UDim2.new(0,450,0,550)})
    SwitchTab("software")
end

--==================================================
-- CHECK ANSWER
--==================================================

local function CheckAnswer()
    local answer = string.lower(InputLine.Text)
    if answer == "y" then
        StartMenu()
    elseif answer == "n" then
        InputLine.Text = ""
        InputLine.PlaceholderText = "cancelled"
    end
end

--==================================================
-- WAIT FOR BOOT
--==================================================

task.spawn(function()
    while not bootComplete do
        task.wait(0.1)
    end
    
    ReadyFrame.Visible = true
    ReadyFrame.Position = UDim2.new(0.1,0,0.74,0)
    Tween(ReadyFrame, 0.6, {Position = UDim2.new(0.1,0,0.65,0)})
    task.wait(0.3)
    InputLine:CaptureFocus()
end)

--==================================================
-- INPUT HANDLERS
--==================================================

InputLine.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        CheckAnswer()
    end
end)

InputLine:GetPropertyChangedSignal("Text"):Connect(function()
    local text = InputLine.Text
    if string.find(text, "\n") then
        InputLine.Text = string.gsub(text, "\n", "")
        CheckAnswer()
    end
end)

Loader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and ReadyFrame.Visible then
        InputLine:CaptureFocus()
    end
end)

--==================================================
-- TOP
--==================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,55)
Top.BackgroundColor3 = C.Dark
Top.ZIndex = 11
Top.Parent = Main
Corner(Top,30)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "NOVA"
Title.TextColor3 = C.Green
Title.Font = Enum.Font.Code
Title.TextSize = 28
Title.ZIndex = 12
Title.Parent = Top

--==================================================
-- TOP BUTTONS
--==================================================

local function TopButton(text,x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40,35)
    b.Position = UDim2.new(1,x,0.5,-17)
    b.Text = text
    b.BackgroundColor3 = C.Black
    b.TextColor3 = C.White
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.ZIndex = 12
    Corner(b,12)
    b.Parent = Top
    
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.GreenDim})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.Black})
    end)
    return b
end

local MinBtn = TopButton("─", -150)
local FullBtn = TopButton("□", -100)
local CloseBtn = TopButton("✕", -50)

--==================================================
-- MINI LOGO
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(70,70)
Mini.Position = UDim2.new(0.05,0,0.85,0)
Mini.Text = "N"
Mini.TextSize = 35
Mini.TextColor3 = C.Green
Mini.BackgroundColor3 = C.Panel
Mini.Visible = false
Mini.ZIndex = 20
Corner(Mini,50)
Mini.Parent = Gui

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

--==================================================
-- BUTTONS
--==================================================

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0.85,0,0,370)
ButtonContainer.Position = UDim2.new(0.075,0,0,130)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.ZIndex = 12
ButtonContainer.Parent = Main

local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.Padding = UDim.new(0,10)
ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.Parent = ButtonContainer

local function CreateButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,48)
    b.BackgroundColor3 = C.Dark
    b.Text = text
    b.TextColor3 = C.White
    b.Font = Enum.Font.Code
    b.TextSize = 17
    b.ZIndex = 13
    Corner(b,25)
    b.Parent = ButtonContainer
    
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = Color3.fromRGB(35,35,35)})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.15, {BackgroundColor3 = C.Dark})
    end)
    return b
end

local SoftwareBtn = CreateButton("SOFTWARE")
local SettingsBtn = CreateButton("SETTINGS")
local FriendsBtn = CreateButton("FRIENDS")
local EnableBtn = CreateButton("ENABLE AIM")
local XrayBtn = CreateButton("XRAY OFF")
local PartBtn = CreateButton("HEAD")
local MinimizeBtn = CreateButton("MINIMIZE")

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.5,0,0,120)
Status.Position = UDim2.new(0.48,0,0.8,0)
Status.BackgroundTransparency = 1
Status.Text = [[
STATUS
● READY
● CONNECTION STABLE

TARGET: None
LOCK: Searching
HIT: Head]]
Status.TextColor3 = C.White
Status.Font = Enum.Font.Code
Status.TextSize = 14
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 12
Status.Parent = Main

local function UpdateStatus()
    local targetText = State.target and State.target.Name or "None"
    local statusText = State.aimEnabled and "ACTIVE" or "READY"
    local lockText = State.aimEnabled and (State.target and "LOCKED" or "Searching") or "Disabled"
    local hitText = Config.AimPart
    
    Status.Text = [[
STATUS
● ]] .. statusText .. [[
● CONNECTION STABLE

TARGET: ]] .. targetText .. [[
LOCK: ]] .. lockText .. [[
HIT: ]] .. hitText
end

--==================================================
-- SETTINGS TAB
--==================================================

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.4,0,0.5,0)
SettingsFrame.Position = UDim2.new(0.05,0,0.35,0)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 12
SettingsFrame.Parent = Main

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

FOV: 60
Smoothness: 0.15
Distance: 250
]]
SettingsText.Parent = SettingsFrame

--==================================================
-- FRIENDS TAB
--==================================================

local FriendsFrame = Instance.new("Frame")
FriendsFrame.Size = UDim2.new(0.5,0,0.5,0)
FriendsFrame.Position = UDim2.new(0.05,0,0.35,0)
FriendsFrame.BackgroundTransparency = 1
FriendsFrame.Visible = false
FriendsFrame.ZIndex = 12
FriendsFrame.Parent = Main

local FriendList = Instance.new("ScrollingFrame")
FriendList.Size = UDim2.new(1,0,1,0)
FriendList.BackgroundTransparency = 1
FriendList.BorderSizePixel = 0
FriendList.CanvasSize = UDim2.new(0,0,0,0)
FriendList.ScrollBarThickness = 3
FriendList.Parent = FriendsFrame

local FriendLayout = Instance.new("UIListLayout")
FriendLayout.Padding = UDim.new(0,6)
FriendLayout.SortOrder = Enum.SortOrder.LayoutOrder
FriendLayout.Parent = FriendList

local FriendInfo = Instance.new("Frame")
FriendInfo.Size = UDim2.new(0.45,0,1,0)
FriendInfo.Position = UDim2.new(0.55,0,0,0)
FriendInfo.BackgroundColor3 = C.Dark
FriendInfo.BackgroundTransparency = 1
FriendInfo.Visible = false
FriendInfo.Parent = FriendsFrame
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

--==================================================
-- FRIENDS CONNECTIONS
--==================================================

local FriendConnections = {}

local function UpdateFriendsList()
    for _, child in pairs(FriendList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, conn in ipairs(FriendConnections) do
        if conn then conn:Disconnect() end
    end
    FriendConnections = {}
    
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
        
        local conn = btn.MouseButton1Click:Connect(function()
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
                FriendName.Text = plr.Name
                FriendInfo.Visible = true
                FriendInfo.BackgroundTransparency = 1
                Tween(FriendInfo, 0.3, {BackgroundTransparency = 0})
                
                for _, c in ipairs(FriendConnections) do
                    if c then c:Disconnect() end
                end
                FriendConnections = {}
                
                local confirmConn = ConfirmBtn.MouseButton1Click:Connect(function()
                    table.insert(State.friends, plr)
                    FriendInfo.Visible = false
                    UpdateFriendsList()
                    UpdateStatus()
                end)
                table.insert(FriendConnections, confirmConn)
                
                local cancelConn = CancelBtn.MouseButton1Click:Connect(function()
                    FriendInfo.Visible = false
                end)
                table.insert(FriendConnections, cancelConn)
            end
        end)
        table.insert(FriendConnections, conn)
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

SwitchTab = function(tab)
    if tab == "software" then
        Status.Visible = true
        SettingsFrame.Visible = false
        FriendsFrame.Visible = false
        EnableBtn.Visible = true
        XrayBtn.Visible = true
        PartBtn.Visible = true
        UpdateStatus()
    elseif tab == "settings" then
        Status.Visible = false
        SettingsFrame.Visible = true
        FriendsFrame.Visible = false
        EnableBtn.Visible = false
        XrayBtn.Visible = false
        PartBtn.Visible = false
    elseif tab == "friends" then
        Status.Visible = false
        SettingsFrame.Visible = false
        FriendsFrame.Visible = true
        EnableBtn.Visible = false
        XrayBtn.Visible = false
        PartBtn.Visible = false
        UpdateFriendsList()
    end
    State.currentTab = tab
end

SoftwareBtn.MouseButton1Click:Connect(function() SwitchTab("software") end)
SettingsBtn.MouseButton1Click:Connect(function() SwitchTab("settings") end)
FriendsBtn.MouseButton1Click:Connect(function() SwitchTab("friends") end)

--==================================================
-- BUTTON FUNCTIONS
--==================================================

local function ToggleAim()
    State.aimEnabled = not State.aimEnabled
    EnableBtn.Text = State.aimEnabled and "DISABLE AIM" or "ENABLE AIM"
    EnableBtn.TextColor3 = State.aimEnabled and C.Red or C.White
    UpdateStatus()
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
    UpdateStatus()
end

EnableBtn.MouseButton1Click:Connect(ToggleAim)
XrayBtn.MouseButton1Click:Connect(ToggleXRay)
PartBtn.MouseButton1Click:Connect(SwitchAimPart)

--==================================================
-- WINDOW CONTROL
--==================================================

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
    Mini.Visible = false
    Main.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

FullBtn.MouseButton1Click:Connect(function()
    State.isFullscreen = not State.isFullscreen
    if State.isFullscreen then
        FullBtn.Text = "◻"
        Tween(Main, 0.4, {
            Size = UDim2.new(0, 700, 0, 500),
            Position = UDim2.new(0.5, -350, 0.5, -250)
        })
        Tween(ButtonContainer, 0.3, {Size = UDim2.new(0.5,0,0,370)})
    else
        FullBtn.Text = "□"
        Tween(Main, 0.4, {
            Size = UDim2.new(0,450,0,550),
            Position = UDim2.new(0.5,-225,0.5,-275)
        })
        Tween(ButtonContainer, 0.3, {Size = UDim2.new(0.85,0,0,370)})
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
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
