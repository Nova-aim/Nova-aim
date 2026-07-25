--==================================================
-- NOVA UI CORE v4.0
-- Loader + Menu Base + Particles + Friends
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local GuiParent = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local old = GuiParent:FindFirstChild("NOVA_UI")
if old then
    old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "NOVA_UI"
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
    Green = Color3.fromRGB(120,255,150),
    Red = Color3.fromRGB(255,70,70),
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
    friendSelect = nil,
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
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        data
    ):Play()
end

local function TweenIn(obj,time,data)
    TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        ),
        data
    ):Play()
end

--==================================================
-- PARTICLES SYSTEM
--==================================================

local function CreateParticles(parent,count)
    local particles = {}
    for i = 1,count do
        local p = Instance.new("Frame")
        local size = math.random(2,4)
        p.Size = UDim2.new(0,size,0,size)
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BackgroundColor3 = C.White
        p.BackgroundTransparency = 0.5
        p.Parent = parent
        Corner(p,10)
        
        local speed = math.random(30,60)
        local direction = math.random(1,4)
        local startPos = p.Position
        
        table.insert(particles, {
            frame = p,
            speed = speed,
            direction = direction,
            startPos = startPos,
            phase = math.random() * 2 * math.pi,
        })
    end
    
    task.spawn(function()
        while parent and parent.Parent do
            for _, data in ipairs(particles) do
                if data.frame and data.frame.Parent then
                    local offsetX = math.sin(os.clock() * data.speed + data.phase) * 0.02
                    local offsetY = math.cos(os.clock() * data.speed * 0.7 + data.phase) * 0.02
                    data.frame.Position = UDim2.new(
                        data.startPos.X.Scale + offsetX,
                        0,
                        data.startPos.Y.Scale + offsetY,
                        0
                    )
                    data.frame.BackgroundTransparency = 0.3 + math.sin(os.clock() * data.speed * 0.3 + data.phase) * 0.2 + 0.2
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

local glowOverlay = Instance.new("Frame")
glowOverlay.Size = UDim2.fromScale(1,1)
glowOverlay.BackgroundTransparency = 1
glowOverlay.BackgroundColor3 = C.Green
glowOverlay.Parent = Loader

local function GlowPulse()
    while Loader and Loader.Parent do
        Tween(glowOverlay, 2, {BackgroundTransparency = 0.95})
        task.wait(2)
        Tween(glowOverlay, 2, {BackgroundTransparency = 1})
        task.wait(2)
    end
end
task.spawn(GlowPulse)

CreateParticles(Loader, 50)

local Terminal = Instance.new("TextLabel")
Terminal.Size = UDim2.new(0.8,0,0,300)
Terminal.Position = UDim2.new(0.1,0,0.2,0)
Terminal.BackgroundTransparency = 1
Terminal.TextColor3 = C.Green
Terminal.Font = Enum.Font.Code
Terminal.TextSize = 20
Terminal.TextXAlignment = Enum.TextXAlignment.Left
Terminal.TextYAlignment = Enum.TextYAlignment.Top
Terminal.Parent = Loader

local lines = {
    "> NOVA SYSTEM BOOT",
    "> Loading modules...",
    "> Checking interface...",
    "> Loading effects...",
    "> Initializing engine...",
    "> Connection stable",
    "> Engine ready",
    "",
    "READY? y/n"
}

for _,text in ipairs(lines) do
    Terminal.Text = Terminal.Text .. text .. "\n"
    task.wait(0.35)
end

local Yes = Instance.new("TextButton")
Yes.Size = UDim2.new(0,120,0,45)
Yes.Position = UDim2.new(0.5,-140,0.7,0)
Yes.Text = "YES"
Yes.TextColor3 = C.White
Yes.BackgroundColor3 = C.Panel
Yes.Font = Enum.Font.Code
Yes.TextSize = 18
Yes.Parent = Loader
Corner(Yes,25)

local No = Instance.new("TextButton")
No.Size = UDim2.new(0,120,0,45)
No.Position = UDim2.new(0.5,20,0.7,0)
No.Text = "NO"
No.TextColor3 = C.White
No.BackgroundColor3 = C.Panel
No.Font = Enum.Font.Code
No.TextSize = 18
No.Parent = Loader
Corner(No,25)

No.MouseButton1Click:Connect(function()
    Terminal.Text = Terminal.Text .. "\nSYSTEM PAUSED"
    No.Visible = false
    Yes.Visible = false
end)

--==================================================
-- MAIN MENU
--==================================================

local Main = nil
local FriendsPanel = nil
local SettingsPanel = nil
local MiniLogo = nil

local function CreateMainMenu()
    Main = Instance.new("Frame")
    Main.Size = UDim2.new(0,430,0,520)
    Main.Position = UDim2.new(0.5,-215,0.5,-260)
    Main.BackgroundColor3 = C.Panel
    Main.BackgroundTransparency = 1
    Main.Parent = Gui
    Corner(Main,30)
    
    Tween(Main, 0.6, {BackgroundTransparency = 0})
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,60)
    Title.BackgroundTransparency = 1
    Title.Text = "NOVA"
    Title.TextColor3 = C.White
    Title.Font = Enum.Font.Code
    Title.TextSize = 36
    Title.Parent = Main
    
    -- Tabs
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
            Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(35,35,35)})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.2, {BackgroundColor3 = C.Soft})
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
    
    local ContentText = Instance.new("TextLabel")
    ContentText.Size = UDim2.new(1,0,1,0)
    ContentText.BackgroundTransparency = 1
    ContentText.TextColor3 = C.White
    ContentText.Font = Enum.Font.Code
    ContentText.TextSize = 16
    ContentText.TextXAlignment = Enum.TextXAlignment.Left
    ContentText.TextYAlignment = Enum.TextYAlignment.Top
    ContentText.Parent = Content
    
    -- Buttons
    local function CreateActionButton(text, y, col)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.45,0,0,40)
        btn.Position = UDim2.new(0.275,0,y,0)
        btn.BackgroundColor3 = C.Soft
        btn.Text = text
        btn.TextColor3 = C.White
        btn.Font = Enum.Font.Code
        btn.TextSize = 16
        btn.Parent = Main
        Corner(btn,25)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(35,35,35)})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = C.Soft})
        end)
        return btn
    end
    
    local EnableBtn = CreateActionButton("ENABLE", 420)
    local SwitchBtn = CreateActionButton("SWITCH", 470)
    local MinimizeBtn = CreateActionButton("MINIMIZE", 520)
    
    local function UpdateContent()
        local targetText = State.target and State.target.Name or "None"
        local statusText = State.aimEnabled and "ACTIVE" or "READY"
        local lockText = State.aimEnabled and (State.target and "LOCKED" or "Searching") or "Disabled"
        
        ContentText.Text = [[
SYSTEM STATUS

● Status: ]] .. statusText .. [[
● Connection: STABLE
● Engine: ACTIVE


TARGET

]] .. targetText .. [[


LOCK:
]] .. lockText .. [[

HIT:
---]]
    end
    UpdateContent()
    
    -- Tab functions
    local function ShowSoftware()
        Content.Visible = true
        if FriendsPanel then FriendsPanel.Visible = false end
        if SettingsPanel then SettingsPanel.Visible = false end
        UpdateContent()
    end
    
    local function ShowFriends()
        Content.Visible = false
        if FriendsPanel then
            FriendsPanel.Visible = true
            UpdateFriendsList()
        end
        if SettingsPanel then SettingsPanel.Visible = false end
    end
    
    local function ShowSettings()
        Content.Visible = false
        if FriendsPanel then FriendsPanel.Visible = false end
        if SettingsPanel then SettingsPanel.Visible = true end
    end
    
    CreateTab("SOFTWARE", 0, ShowSoftware)
    CreateTab("FRIENDS", 0.36, ShowFriends)
    CreateTab("SETTINGS", 0.72, ShowSettings)
    
    -- Friends Panel
    FriendsPanel = Instance.new("Frame")
    FriendsPanel.Size = UDim2.new(1,0,1,0)
    FriendsPanel.BackgroundTransparency = 1
    FriendsPanel.Visible = false
    FriendsPanel.Parent = Content
    
    local FriendScroll = Instance.new("ScrollingFrame")
    FriendScroll.Size = UDim2.new(1,0,1,0)
    FriendScroll.BackgroundTransparency = 1
    FriendScroll.BorderSizePixel = 0
    FriendScroll.CanvasSize = UDim2.new(0,0,0,0)
    FriendScroll.ScrollBarThickness = 3
    FriendScroll.Parent = FriendsPanel
    
    local FriendLayout = Instance.new("UIListLayout")
    FriendLayout.Padding = UDim.new(0, 6)
    FriendLayout.SortOrder = Enum.SortOrder.LayoutOrder
    FriendLayout.Parent = FriendScroll
    
    local function UpdateFriendsList()
        for _, child in pairs(FriendScroll:GetChildren()) do
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
            empty.Parent = FriendScroll
            FriendScroll.CanvasSize = UDim2.new(0,0,0,40)
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
            btn.BackgroundColor3 = C.Soft
            btn.BackgroundTransparency = 0.5
            btn.BorderSizePixel = 0
            btn.Parent = FriendScroll
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
                else
                    table.insert(State.friends, plr)
                    UpdateFriendsList()
                end
            end)
        end
        
        FriendLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            FriendScroll.CanvasSize = UDim2.new(0,0,0, FriendLayout.AbsoluteContentSize.Y + 10)
        end)
        task.wait()
        FriendScroll.CanvasSize = UDim2.new(0,0,0, FriendLayout.AbsoluteContentSize.Y + 10)
    end
    
    -- Settings Panel
    SettingsPanel = Instance.new("Frame")
    SettingsPanel.Size = UDim2.new(1,0,1,0)
    SettingsPanel.BackgroundTransparency = 1
    SettingsPanel.Visible = false
    SettingsPanel.Parent = Content
    
    local SettingsText = Instance.new("TextLabel")
    SettingsText.Size = UDim2.new(1,0,1,0)
    SettingsText.BackgroundTransparency = 1
    SettingsText.TextColor3 = C.White
    SettingsText.Font = Enum.Font.Code
    SettingsText.TextSize = 16
    SettingsText.TextXAlignment = Enum.TextXAlignment.Left
    SettingsText.TextYAlignment = Enum.TextYAlignment.Top
    SettingsText.Text = [[
SETTINGS

Aim Part: ]] .. Config.AimPart .. [[

FOV: ]] .. Config.FOV .. [[

Smoothness: ]] .. string.format("%.2f", Config.Smoothness) .. [[

Distance: ]] .. Config.Distance .. [[

X-Ray: ]] .. (State.xrayEnabled and "ON" or "OFF") .. [[

Friends: ]] .. #State.friends
    SettingsText.Parent = SettingsPanel
    
    -- Button handlers
    EnableBtn.MouseButton1Click:Connect(function()
        State.aimEnabled = not State.aimEnabled
        EnableBtn.Text = State.aimEnabled and "DISABLE" or "ENABLE"
        EnableBtn.TextColor3 = State.aimEnabled and C.Red or C.White
        UpdateContent()
        if not State.aimEnabled then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
    end)
    
    SwitchBtn.MouseButton1Click:Connect(function()
        if Config.AimPart == "Head" then
            Config.AimPart = "HumanoidRootPart"
            Config.BackupPart = "Torso"
        else
            Config.AimPart = "Head"
            Config.BackupPart = "UpperTorso"
        end
        UpdateContent()
        SettingsText.Text = [[
SETTINGS

Aim Part: ]] .. Config.AimPart .. [[

FOV: ]] .. Config.FOV .. [[

Smoothness: ]] .. string.format("%.2f", Config.Smoothness) .. [[

Distance: ]] .. Config.Distance .. [[

X-Ray: ]] .. (State.xrayEnabled and "ON" or "OFF") .. [[

Friends: ]] .. #State.friends
    end)
    
    -- Minimize
    MinimizeBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        CreateMiniLogo()
    end)
    
    return Main
end

--==================================================
-- MINI LOGO
--==================================================

local function CreateMiniLogo()
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
    
    -- Pulse glow
    task.spawn(function()
        while MiniLogo and MiniLogo.Parent do
            for i = 1, 3 do
                Tween(glow, 1.5, {BorderTransparency = 0.3})
                task.wait(1.5)
                Tween(glow, 1.5, {BorderTransparency = 0.7})
                task.wait(1.5)
            end
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
    
    UIS.InputChanged:Connect(function(input)
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
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.dragging = false
        end
    end)
    
    MiniLogo.MouseButton1Click:Connect(function()
        MiniLogo.Visible = false
        if Main then Main.Visible = true end
    end)
end

--==================================================
-- LOADER BUTTONS
--==================================================

Yes.MouseButton1Click:Connect(function()
    Tween(Loader, 0.6, {BackgroundTransparency = 1})
    task.wait(0.7)
    Loader:Destroy()
    CreateMainMenu()
end)

--==================================================
-- HOTKEYS
--==================================================

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.One then
        if State.aimEnabled then
            State.aimEnabled = false
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        else
            State.aimEnabled = true
        end
        if Main then
            for _, btn in pairs(Main:GetDescendants()) do
                if btn:IsA("TextButton") and btn.Text == "ENABLE" or btn.Text == "DISABLE" then
                    btn.Text = State.aimEnabled and "DISABLE" or "ENABLE"
                    btn.TextColor3 = State.aimEnabled and C.Red or C.White
                end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.Two then
        if Config.AimPart == "Head" then
            Config.AimPart = "HumanoidRootPart"
            Config.BackupPart = "Torso"
        else
            Config.AimPart = "Head"
            Config.BackupPart = "UpperTorso"
        end
    elseif input.KeyCode == Enum.KeyCode.Three then
        State.xrayEnabled = not State.xrayEnabled
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
        State.target = newTarget
        State.lostTimer = 0
        State.targetCF = nil
        State.smoothCF = nil
    end
end

RunService.RenderStepped:Connect(function(dt)
    pcall(UpdateAim, dt)
end)

print("NOVA UI v4.0 LOADED")
