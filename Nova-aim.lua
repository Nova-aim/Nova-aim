--========================
-- NOVA v2 UI
--========================

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
    keepTarget = false,
    ignoreWalls = false,
    autoSwitch = false,
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

local function Tween(obj,time,data)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        data
    ):Play()
end

--==================================================
-- MAIN GUI
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(470,540)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
Main.BorderSizePixel = 0
Main.Parent = Gui
Corner(Main,18)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,52)
Header.BackgroundColor3 = Color3.fromRGB(8,8,8)
Header.BorderSizePixel = 0
Header.Parent = Main
Corner(Header,18)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,0,1,0)
Title.Text = "Nova v2.55.1"
Title.Font = Enum.Font.Code
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(235,235,235)
Title.Parent = Header

-- Кнопки хедера
local function HeaderButton(text,x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40,35)
    b.Position = UDim2.new(1,x,0.5,-17)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(8,8,8)
    b.TextColor3 = Color3.fromRGB(200,200,200)
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.ZIndex = 12
    Corner(b,12)
    b.Parent = Header
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
Tabs.Size = UDim2.new(1,-20,0,40)
Tabs.Position = UDim2.new(0,10,0,62)
Tabs.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.Padding = UDim.new(0,8)
Layout.Parent = Tabs

local function Tab(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(140,34)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Code
    b.TextSize = 18
    Corner(b,10)
    b.Parent = Tabs
    return b
end

local Software = Tab("SOFTWARE")
local Settings = Tab("SETTINGS")
local Friends = Tab("FRIENDS")

--==================================================
-- SOFTWARE PAGE
--==================================================

local SoftwareFrame = Instance.new("Frame")
SoftwareFrame.BackgroundTransparency = 1
SoftwareFrame.Size = UDim2.new(1,-30,1,-120)
SoftwareFrame.Position = UDim2.new(0,15,0,110)
SoftwareFrame.Parent = Main

local function Label(txt,y)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0,0,0,y)
    l.Size = UDim2.new(1,0,0,26)
    l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextSize = 19
    l.TextColor3 = Color3.new(1,1,1)
    l.Text = txt
    l.Parent = SoftwareFrame
    return l
end

local StatusLabel = Label("SYSTEM",0)
local StatusLine = Label("● STATUS : READY",40)
local EngineLine = Label("● ENGINE : ACTIVE",68)
local ConnLine = Label("● CONNECTION : STABLE",96)

local TargetTitle = Label("TARGET",145)

local Target = Instance.new("Frame")
Target.Size = UDim2.new(1,-40,0,42)
Target.Position = UDim2.new(0,20,0,180)
Target.BackgroundColor3 = Color3.fromRGB(25,25,25)
Corner(Target,8)
Target.Parent = SoftwareFrame

local TargetName = Instance.new("TextLabel")
TargetName.BackgroundTransparency = 1
TargetName.Size = UDim2.new(1,0,1,0)
TargetName.Text = "None"
TargetName.Font = Enum.Font.Code
TargetName.TextSize = 18
TargetName.TextColor3 = Color3.new(1,1,1)
TargetName.Parent = Target

local LockLine = Label("LOCK : SEARCHING",240)
local HitLine = Label("HIT : HEAD",270)

--==================================================
-- BUTTONS
--==================================================

local function BigButton(text,y,color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-60,0,48)
    b.Position = UDim2.new(0,30,0,y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Code
    b.TextSize = 19
    Corner(b,12)
    b.Parent = SoftwareFrame
    return b
end

local EnableBtn = BigButton("◉ ENABLE",330,Color3.fromRGB(20,90,40))
local MinimizeBtn = BigButton("◯ MINIMIZE",388,Color3.fromRGB(40,40,40))

--==================================================
-- SETTINGS
--==================================================

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Visible = false
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Size = SoftwareFrame.Size
SettingsFrame.Position = SoftwareFrame.Position
SettingsFrame.Parent = Main

local function Slider(name,y,value,minVal,maxVal)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0,0,0,y)
    t.Size = UDim2.new(1,0,0,25)
    t.Text = name
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.Code
    t.TextSize = 18
    t.TextColor3 = Color3.new(1,1,1)
    t.Parent = SettingsFrame

    local bar = Instance.new("Frame")
    bar.Position = UDim2.new(0,0,0,y+32)
    bar.Size = UDim2.new(1,-80,0,6)
    bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Corner(bar,4)
    bar.Parent = SettingsFrame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - minVal) / (maxVal - minVal),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(120,255,120)
    Corner(fill,4)
    fill.Parent = bar

    local val = Instance.new("TextLabel")
    val.Position = UDim2.new(1,-50,0,y+18)
    val.Size = UDim2.fromOffset(50,30)
    val.BackgroundTransparency = 1
    val.Text = tostring(value)
    val.Font = Enum.Font.Code
    val.TextColor3 = Color3.new(1,1,1)
    val.Parent = SettingsFrame
    
    return {bar = bar, fill = fill, label = val, minVal = minVal, maxVal = maxVal, value = value}
end

local FOVSlider = Slider("Field Of View",20,60,1,120)
local SmoothSlider = Slider("Smoothness",110,0.15,0.01,1)
local DistSlider = Slider("Distance",200,250,50,500)

--==================================================
-- OPTIONS
--==================================================

local OptionsTitle = Label("OPTIONS",310)

local function Checkbox(text,y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,30)
    b.Position = UDim2.new(0,0,0,y)
    b.BackgroundTransparency = 1
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = SettingsFrame
    return b
end

local KeepTargetChk = Checkbox("☐ Keep Target",345)
local IgnoreWallsChk = Checkbox("☐ Ignore Walls",375)
local AutoSwitchChk = Checkbox("☐ Auto Switch",405)

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
Scroll.Size = UDim2.new(0.52,0,1,0)
Scroll.CanvasSize = UDim2.new()
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1
Scroll.Parent = FriendsFrame

local Layout2 = Instance.new("UIListLayout")
Layout2.Padding = UDim.new(0,8)
Layout2.Parent = Scroll

local FriendInfoPanel = Instance.new("Frame")
FriendInfoPanel.Size = UDim2.new(0.42,0,1,0)
FriendInfoPanel.Position = UDim2.new(0.58,0,0,0)
FriendInfoPanel.BackgroundColor3 = Color3.fromRGB(25,25,25)
FriendInfoPanel.Visible = false
FriendInfoPanel.Parent = FriendsFrame
Corner(FriendInfoPanel, 12)

local FriendInfoName = Instance.new("TextLabel")
FriendInfoName.Size = UDim2.new(1,-20,0,30)
FriendInfoName.Position = UDim2.new(0,10,0,10)
FriendInfoName.BackgroundTransparency = 1
FriendInfoName.Text = "Player"
FriendInfoName.Font = Enum.Font.Code
FriendInfoName.TextSize = 20
FriendInfoName.TextColor3 = Color3.new(1,1,1)
FriendInfoName.TextXAlignment = Enum.TextXAlignment.Left
FriendInfoName.Parent = FriendInfoPanel

local FriendInfoQuestion = Instance.new("TextLabel")
FriendInfoQuestion.Size = UDim2.new(1,-20,0,25)
FriendInfoQuestion.Position = UDim2.new(0,10,0,50)
FriendInfoQuestion.BackgroundTransparency = 1
FriendInfoQuestion.Text = "Add to friends?"
FriendInfoQuestion.Font = Enum.Font.Code
FriendInfoQuestion.TextSize = 14
FriendInfoQuestion.TextColor3 = Color3.fromRGB(150,150,150)
FriendInfoQuestion.TextXAlignment = Enum.TextXAlignment.Left
FriendInfoQuestion.Parent = FriendInfoPanel

local FriendConfirm = Instance.new("TextButton")
FriendConfirm.Size = UDim2.new(0.8,0,0,40)
FriendConfirm.Position = UDim2.new(0.1,0,0,90)
FriendConfirm.BackgroundColor3 = Color3.fromRGB(20,90,40)
FriendConfirm.Text = "✓ CONFIRM"
FriendConfirm.TextColor3 = Color3.new(1,1,1)
FriendConfirm.Font = Enum.Font.Code
FriendConfirm.TextSize = 16
Corner(FriendConfirm, 12)
FriendConfirm.Parent = FriendInfoPanel

local FriendCancel = Instance.new("TextButton")
FriendCancel.Size = UDim2.new(0.8,0,0,40)
FriendCancel.Position = UDim2.new(0.1,0,0,140)
FriendCancel.BackgroundColor3 = Color3.fromRGB(60,20,20)
FriendCancel.Text = "✕ CANCEL"
FriendCancel.TextColor3 = Color3.new(1,1,1)
FriendCancel.Font = Enum.Font.Code
FriendCancel.TextSize = 16
Corner(FriendCancel, 12)
FriendCancel.Parent = FriendInfoPanel

--==================================================
-- ФУНКЦИИ ОБНОВЛЕНИЯ
--==================================================

local function UpdateStatus()
    local targetText = State.target and State.target.Name or "None"
    local statusText = State.aimEnabled and "ACTIVE" or "READY"
    local lockText = "SEARCHING"
    if State.aimEnabled then
        if State.target then
            lockText = "LOCKED"
        else
            lockText = "SEARCHING"
        end
    else
        lockText = "DISABLED"
    end
    local hitText = Config.AimPart
    
    StatusLine.Text = "● STATUS : " .. statusText
    TargetName.Text = targetText
    LockLine.Text = "LOCK : " .. lockText
    HitLine.Text = "HIT : " .. hitText
end

local function UpdateFriendsList()
    -- Очищаем список
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
        empty.Size = UDim2.new(1,0,0,30)
        empty.BackgroundTransparency = 1
        empty.Text = "No players in server"
        empty.TextColor3 = Color3.fromRGB(130,130,130)
        empty.Font = Enum.Font.Code
        empty.TextSize = 14
        empty.Parent = Scroll
        Scroll.CanvasSize = UDim2.new(0,0,0,40)
        return
    end
    
    table.sort(players, function(a,b) return a.Name < b.Name end)
    
    for _, plr in ipairs(players) do
        local isFriend = false
        for _, f in ipairs(State.friends) do
            if f == plr then isFriend = true break end
        end
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,40)
        btn.BackgroundColor3 = isFriend and Color3.fromRGB(20,60,30) or Color3.fromRGB(25,25,25)
        btn.BorderSizePixel = 0
        btn.Parent = Scroll
        Corner(btn, 8)
        
        -- Аватарка
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.fromOffset(32,32)
        avatar.Position = UDim2.new(0,4,0.5,-16)
        avatar.BackgroundColor3 = Color3.fromRGB(30,30,30)
        avatar.BorderSizePixel = isFriend and 2 or 0
        avatar.BorderColor3 = Color3.fromRGB(120,255,150)
        Corner(avatar, 16)
        pcall(function()
            avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        avatar.Parent = btn
        
        -- Имя
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0.6,0,1,0)
        name.Position = UDim2.new(0,44,0,0)
        name.BackgroundTransparency = 1
        name.Text = plr.Name
        name.TextColor3 = isFriend and Color3.fromRGB(120,255,150) or Color3.new(1,1,1)
        name.Font = Enum.Font.Code
        name.TextSize = 16
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = btn
        
        -- Статус
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.2,0,1,0)
        status.Position = UDim2.new(0.8,0,0,0)
        status.BackgroundTransparency = 1
        status.Text = isFriend and "✓" or "+"
        status.TextColor3 = isFriend and Color3.fromRGB(120,255,150) or Color3.fromRGB(130,130,130)
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
            else
                FriendInfoName.Text = plr.Name
                FriendInfoPanel.Visible = true
                FriendInfoPanel.BackgroundTransparency = 1
                Tween(FriendInfoPanel, 0.3, {BackgroundTransparency = 0})
                
                local confirmConn = FriendConfirm.MouseButton1Click:Connect(function()
                    table.insert(State.friends, plr)
                    FriendInfoPanel.Visible = false
                    UpdateFriendsList()
                end)
                
                local cancelConn = FriendCancel.MouseButton1Click:Connect(function()
                    FriendInfoPanel.Visible = false
                end)
            end
        end)
    end
    
    Layout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0,0,0, Layout2.AbsoluteContentSize.Y + 10)
    end)
    task.wait()
    Scroll.CanvasSize = UDim2.new(0,0,0, Layout2.AbsoluteContentSize.Y + 10)
end

--==================================================
-- ПРИВЯЗКА ТАБОВ
--==================================================

Software.MouseButton1Click:Connect(function()
    SoftwareFrame.Visible = true
    SettingsFrame.Visible = false
    FriendsFrame.Visible = false
    State.currentTab = "software"
end)

Settings.MouseButton1Click:Connect(function()
    SoftwareFrame.Visible = false
    SettingsFrame.Visible = true
    FriendsFrame.Visible = false
    State.currentTab = "settings"
end)

Friends.MouseButton1Click:Connect(function()
    SoftwareFrame.Visible = false
    SettingsFrame.Visible = false
    FriendsFrame.Visible = true
    State.currentTab = "friends"
    UpdateFriendsList()
end)

--==================================================
-- ПРИВЯЗКА КНОПОК
--==================================================

-- ENABLE / DISABLE
local function ToggleAim()
    State.aimEnabled = not State.aimEnabled
    EnableBtn.Text = State.aimEnabled and "◉ DISABLE" or "◉ ENABLE"
    EnableBtn.BackgroundColor3 = State.aimEnabled and Color3.fromRGB(60,20,20) or Color3.fromRGB(20,90,40)
    UpdateStatus()
    if not State.aimEnabled then
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
    end
end
EnableBtn.MouseButton1Click:Connect(ToggleAim)

-- MINIMIZE
MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)

--==================================================
-- MINI LOGO
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(70,70)
Mini.Position = UDim2.new(0.05,0,0.85,0)
Mini.Text = "N"
Mini.TextSize = 35
Mini.TextColor3 = Color3.fromRGB(120,255,150)
Mini.BackgroundColor3 = Color3.fromRGB(15,15,15)
Mini.Visible = false
Mini.ZIndex = 20
Corner(Mini,50)
Mini.Parent = Gui

Mini.MouseButton1Click:Connect(function()
    Mini.Visible = false
    Main.Visible = true
end)

--==================================================
-- HEADER BUTTONS
--==================================================

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
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
            Size = UDim2.fromOffset(470,540),
            Position = UDim2.fromScale(0.5,0.5)
        })
    end
end)

--==================================================
-- SETTINGS СЛАЙДЕРЫ
--==================================================

-- FOV
FOVSlider.bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local function update()
            local pos = math.clamp((input.Position.X - FOVSlider.bar.AbsolutePosition.X) / FOVSlider.bar.AbsoluteSize.X, 0, 1)
            local val = math.round(FOVSlider.minVal + (FOVSlider.maxVal - FOVSlider.minVal) * pos)
            Config.FOV = val
            FOVSlider.fill.Size = UDim2.new(pos,0,1,0)
            FOVSlider.label.Text = tostring(val)
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

-- Smoothness
SmoothSlider.bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local function update()
            local pos = math.clamp((input.Position.X - SmoothSlider.bar.AbsolutePosition.X) / SmoothSlider.bar.AbsoluteSize.X, 0, 1)
            local val = math.round((SmoothSlider.minVal + (SmoothSlider.maxVal - SmoothSlider.minVal) * pos) * 100) / 100
            Config.Smoothness = val
            SmoothSlider.fill.Size = UDim2.new(pos,0,1,0)
            SmoothSlider.label.Text = string.format("%.2f", val)
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

-- Distance
DistSlider.bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local function update()
            local pos = math.clamp((input.Position.X - DistSlider.bar.AbsolutePosition.X) / DistSlider.bar.AbsoluteSize.X, 0, 1)
            local val = math.round(DistSlider.minVal + (DistSlider.maxVal - DistSlider.minVal) * pos)
            Config.Distance = val
            DistSlider.fill.Size = UDim2.new(pos,0,1,0)
            DistSlider.label.Text = tostring(val)
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

--==================================================
-- ОПЦИИ (ЧЕКБОКСЫ)
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
            HitLine.Text = "HIT : BODY"
        else
            Config.AimPart = "Head"
            Config.BackupPart = "UpperTorso"
            HitLine.Text = "HIT : HEAD"
        end
        UpdateStatus()
    elseif input.KeyCode == Enum.KeyCode.Three then
        -- XRAY toggle (если добавить кнопку)
    end
end)

--==================================================
-- RUN LOOP
--==================================================

RunService.RenderStepped:Connect(function(dt)
    pcall(UpdateAim, dt)
end)

--==================================================
-- СТАРТ
--==================================================

UpdateStatus()
print("NOVA v2 UI LOADED")
