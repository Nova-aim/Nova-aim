Nova v2.54

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("NovaUI") then
    CoreGui.NovaUI:Destroy()
end

local Themes = {
    Dark = {
        bg        = Color3.fromRGB(12,  12,  15),
        surface   = Color3.fromRGB(18,  18,  22),
        surfaceHi = Color3.fromRGB(25,  25,  30),
        border    = Color3.fromRGB(45,  45,  55),
        borderHi  = Color3.fromRGB(80,  80,  95),
        accent    = Color3.fromRGB(220, 220, 220),
        accentDim = Color3.fromRGB(120, 120, 120),
        green     = Color3.fromRGB(0,   255, 127),
        greenDim  = Color3.fromRGB(20,  70,  45),
        red       = Color3.fromRGB(255, 90,  90),
        redDim    = Color3.fromRGB(60,  18,  18),
        amber     = Color3.fromRGB(255, 200, 60),
        text      = Color3.fromRGB(240, 240, 240),
        textMuted = Color3.fromRGB(150, 150, 150),
        textDim   = Color3.fromRGB(90,  90,  90),
    },
    Light = {
        bg        = Color3.fromRGB(244, 246, 250),
        surface   = Color3.fromRGB(250, 252, 255),
        surfaceHi = Color3.fromRGB(255, 255, 255),
        border    = Color3.fromRGB(211, 216, 228),
        borderHi  = Color3.fromRGB(176, 186, 207),
        accent    = Color3.fromRGB(41,  49,  65),
        accentDim = Color3.fromRGB(102, 112, 134),
        green     = Color3.fromRGB(0,   170, 90),
        greenDim  = Color3.fromRGB(211, 241, 224),
        red       = Color3.fromRGB(210, 65, 65),
        redDim    = Color3.fromRGB(247, 225, 225),
        amber     = Color3.fromRGB(222, 152, 35),
        text      = Color3.fromRGB(46,  53,  69),
        textMuted = Color3.fromRGB(100, 110, 130),
        textDim   = Color3.fromRGB(148, 156, 173),
    },
}

local currentTheme = "Dark"
local C = {}
for k, v in pairs(Themes[currentTheme]) do
    C[k] = v
end

local State = {
    enabled = false,
    destroyed = false,
    target = nil,
    targetCF = nil,
    smoothCF = nil,
    killCount = 0,
    lostTimer = 0,
    searchTimer = 0,
    xrayTimer = 0,
    hue = 0,
    friends = {},
    friendSelector = nil,
    isMobile = UserInputService.TouchEnabled,
    vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080),
    minimized = false,
    maximized = false,
    uiVisible = true,
}

local XRayState = {
    enabled = true,
    boxes = {},
    container = nil,
    partsCache = {},
    cacheTimers = {},
    CACHE_DURATION = 0.5,
}

local CONFIG = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 50,
    Smoothness = 0.85,
    DistanceLimit = 250,
    PredictionStrength = 0.6,
    BulletSpeed = 1800,
    LostTimeout = 0.1,
    SearchInterval = 0.05,
    XRayUpdateInterval = 0.025,
    ShowFOV = true,
    CrosshairStyle = "DOT",
    CenterOffset = Vector2.new(0, 0),
}

local DIST_LIMIT_SQ = CONFIG.DistanceLimit * CONFIG.DistanceLimit

local function getCenter()
    local vp = Camera.ViewportSize
    return Vector2.new(
        vp.X / 2 + CONFIG.CenterOffset.X,
        vp.Y / 2 + CONFIG.CenterOffset.Y
    )
end

local function isAlive(plr)
    if not plr or not plr.Parent then return false end
    if not plr.Character or not plr.Character.Parent then return false end
    local humanoid = plr.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isFriend(plr)
    if not plr then return false end
    for i, friend in ipairs(State.friends) do
        if friend == plr then return true end
    end
    return false
end

local function makeCorner(inst, r)
    local c = Instance.new("UICorner", inst)
    c.CornerRadius = UDim.new(0, r or 10)
    return c
end

local function makeStroke(inst, col, t)
    local s = Instance.new("UIStroke", inst)
    s.Color = col or C.border
    s.Thickness = t or 1
    return s
end

local function makeAvatar(plr, size)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, size, 0, size)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundColor3 = C.surfaceHi
    img.Image = plr and Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) or ""
    img.ImageRectSize = Vector2.new(420, 420)
    img.ImageRectOffset = Vector2.new(0, 0)
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = container
    
    local corner = makeCorner(img, 999)
    return container
end

local PlayerGui = Player:WaitForChild("PlayerGui")
local UI = {}

local function BuildUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 999
    
    local main = Instance.new("Frame")
    main.Size = State.isMobile and UDim2.new(0.92, 0, 0, State.vp.Y * 0.75) or UDim2.new(0, 480, 0, 420)
    main.Position = UDim2.new(0.5, -main.Size.X.Offset/2, 0.5, -main.Size.Y.Offset/2)
    main.BackgroundColor3 = C.bg
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    makeCorner(main, 16)
    makeStroke(main, C.borderHi, 1)
    
    local bgGrad = Instance.new("UIGradient", main)
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.surface),
        ColorSequenceKeypoint.new(1, C.bg),
    })
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = C.surface
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.Parent = main
    
    local headerCorner = makeCorner(header, 16)
    headerCorner.CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "NOVA v2.54"
    title.TextColor3 = C.text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    local winButtons = {}
    local btnData = {
        {text = "─", pos = 1, color = C.textMuted, action = "minimize"},
        {text = "□", pos = 2, color = C.textMuted, action = "maximize"},
        {text = "✕", pos = 3, color = C.red, action = "close"},
    }
    for i, data in ipairs(btnData) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 1, 0)
        btn.Position = UDim2.new(1, -30 * (4 - data.pos), 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = data.text
        btn.TextColor3 = data.color
        btn.TextSize = 16
        btn.Font = Enum.Font.Gotham
        btn.Parent = header
        winButtons[data.action] = btn
    end
    
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(1, 0, 0, 36)
    tabs.Position = UDim2.new(0, 0, 0, 42)
    tabs.BackgroundColor3 = C.surface
    tabs.BackgroundTransparency = 0.3
    tabs.BorderSizePixel = 0
    tabs.Parent = main
    
    local tabButtons = {}
    local tabContents = {}
    local activeTab = "main"
    
    local function switchTab(tab)
        activeTab = tab
        for t, btn in pairs(tabButtons) do
            btn.BackgroundTransparency = (t == tab) and 0.2 or 1
            btn.TextColor3 = (t == tab) and C.text or C.textMuted
        end
        for t, cont in pairs(tabContents) do
            cont.Visible = (t == tab)
        end
    end
    
    local tabNames = {"Главная", "Друзья", "Настройки"}
    for i, name in ipairs(tabNames) do
        local t = (i == 1) and "main" or (i == 2) and "friends" or "settings"
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.Position = UDim2.new(0, 120 * (i - 1), 0, 0)
        btn.BackgroundTransparency = (i == 1) and 0.2 or 1
        btn.Text = name
        btn.TextColor3 = (i == 1) and C.text or C.textMuted
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.BorderSizePixel = 0
        btn.Parent = tabs
        tabButtons[t] = btn
        
        btn.MouseButton1Click:Connect(function()
            switchTab(t)
        end)
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -20, 1, -60)
        content.Position = UDim2.new(0, 10, 0, 82)
        content.BackgroundTransparency = 1
        content.Visible = (i == 1)
        content.Parent = main
        tabContents[t] = content
    end
    
    -- Main Tab
    local mainContent = tabContents["main"]
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 24)
    status.BackgroundTransparency = 1
    status.Text = "ОТКЛЮЧЕН"
    status.TextColor3 = C.textMuted
    status.TextSize = 14
    status.Font = Enum.Font.GothamMedium
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = mainContent
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0, 20)
    targetLabel.Position = UDim2.new(0, 0, 0, 26)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "ЦЕЛЬ: НЕТ"
    targetLabel.TextColor3 = C.textMuted
    targetLabel.TextSize = 12
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = mainContent
    
    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(1, 0, 0, 20)
    aimLabel.Position = UDim2.new(0, 0, 0, 46)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "ЦЕЛЬ: ГОЛОВА"
    aimLabel.TextColor3 = C.textMuted
    aimLabel.TextSize = 12
    aimLabel.Font = Enum.Font.Gotham
    aimLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimLabel.Parent = mainContent
    
    local killsLabel = Instance.new("TextLabel")
    killsLabel.Size = UDim2.new(1, 0, 0, 20)
    killsLabel.Position = UDim2.new(0, 0, 0, 66)
    killsLabel.BackgroundTransparency = 1
    killsLabel.Text = "УБИЙСТВ: 0"
    killsLabel.TextColor3 = C.textMuted
    killsLabel.TextSize = 12
    killsLabel.Font = Enum.Font.Gotham
    killsLabel.TextXAlignment = Enum.TextXAlignment.Left
    killsLabel.Parent = mainContent
    
    local function MakeButton(text, y, col)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = C.surface
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = C.text
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = mainContent
        
        makeCorner(btn, 8)
        makeStroke(btn, col or C.border, 1)
        
        local hover = TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.2
        })
        local leave = TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.5
        })
        
        btn.MouseEnter:Connect(function()
            leave:Cancel()
            hover:Play()
        end)
        btn.MouseLeave:Connect(function()
            hover:Cancel()
            leave:Play()
        end)
        
        return btn
    end
    
    local btnToggle = MakeButton("ВКЛЮЧИТЬ", 92, C.accent)
    local btnAimPart = MakeButton("СМЕНИТЬ ЦЕЛЬ", 132, C.accentDim)
    local btnXRay = MakeButton("X-RAY: ВКЛ", 172, C.accentDim)
    local btnFriend = MakeButton("ДРУЗЬЯ", 212, C.greenDim)
    local btnExit = MakeButton("ВЫХОД", 252, C.redDim)
    
    -- Friends Tab
    local friendsContent = tabContents["friends"]
    
    local friendList = Instance.new("ScrollingFrame")
    friendList.Size = UDim2.new(1, 0, 1, 0)
    friendList.BackgroundTransparency = 1
    friendList.BorderSizePixel = 0
    friendList.CanvasSize = UDim2.new(0, 0, 0, 0)
    friendList.ScrollBarThickness = 3
    friendList.ScrollBarImageColor3 = C.borderHi
    friendList.ScrollBarImageTransparency = 0.3
    friendList.Parent = friendsContent
    
    local friendLayout = Instance.new("UIListLayout", friendList)
    friendLayout.Padding = UDim.new(0, 6)
    friendLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function UpdateFriendsList()
        for i, child in ipairs(friendList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if #State.friends == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 40)
            empty.BackgroundTransparency = 1
            empty.Text = "Нет добавленных друзей"
            empty.TextColor3 = C.textMuted
            empty.TextSize = 14
            empty.Font = Enum.Font.Gotham
            empty.Parent = friendList
            friendList.CanvasSize = UDim2.new(0, 0, 0, 50)
            return
        end
        
        for i, plr in ipairs(State.friends) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 44)
            btn.BackgroundColor3 = C.surface
            btn.BackgroundTransparency = 0.3
            btn.BorderSizePixel = 0
            btn.Parent = friendList
            
            makeCorner(btn, 8)
            
            local avatar = makeAvatar(plr, 34)
            avatar.Position = UDim2.new(0, 4, 0.5, -17)
            avatar.Parent = btn
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -80, 1, 0)
            nameLabel.Position = UDim2.new(0, 44, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = C.text
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.Parent = btn
            
            local removeBtn = Instance.new("TextButton")
            removeBtn.Size = UDim2.new(0, 40, 1, 0)
            removeBtn.Position = UDim2.new(1, -44, 0, 0)
            removeBtn.BackgroundTransparency = 1
            removeBtn.Text = "✕"
            removeBtn.TextColor3 = C.red
            removeBtn.TextSize = 16
            removeBtn.Font = Enum.Font.Gotham
            removeBtn.Parent = btn
            
            removeBtn.MouseButton1Click:Connect(function()
                for j, f in ipairs(State.friends) do
                    if f == plr then
                        table.remove(State.friends, j)
                        UpdateFriendsList()
                        break
                    end
                end
            end)
        end
        
        friendLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            friendList.CanvasSize = UDim2.new(0, 0, 0, friendLayout.AbsoluteContentSize.Y + 10)
        end)
        task.wait()
        friendList.CanvasSize = UDim2.new(0, 0, 0, friendLayout.AbsoluteContentSize.Y + 10)
    end
    
    UpdateFriendsList()
    
    -- Settings Tab
    local settingsContent = tabContents["settings"]
    
    local settings = {
        {text = "Показывать FOV", key = "showFOV", default = true},
        {text = "Сглаживание", key = "smoothness", default = 0.85, min = 0.1, max = 1},
        {text = "Дистанция", key = "distance", default = 250, min = 50, max = 500},
    }
    
    local settingsY = 0
    for i, setting in ipairs(settings) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, settingsY)
        frame.BackgroundTransparency = 1
        frame.Parent = settingsContent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = setting.text
        label.TextColor3 = C.text
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        if setting.key == "showFOV" then
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 60, 0, 28)
            toggle.Position = UDim2.new(1, -64, 0.5, -14)
            toggle.BackgroundColor3 = CONFIG.ShowFOV and C.green or C.red
            toggle.BackgroundTransparency = 0.3
            toggle.BorderSizePixel = 0
            toggle.Text = CONFIG.ShowFOV and "ВКЛ" or "ВЫКЛ"
            toggle.TextColor3 = C.text
            toggle.TextSize = 11
            toggle.Font = Enum.Font.GothamBold
            toggle.Parent = frame
            makeCorner(toggle, 6)
            
            toggle.MouseButton1Click:Connect(function()
                CONFIG.ShowFOV = not CONFIG.ShowFOV
                toggle.BackgroundColor3 = CONFIG.ShowFOV and C.green or C.red
                toggle.Text = CONFIG.ShowFOV and "ВКЛ" or "ВЫКЛ"
                if UI.fovCircle then
                    UI.fovCircle.Visible = State.enabled and CONFIG.ShowFOV
                end
            end)
        elseif setting.key == "smoothness" then
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0, 120, 0, 6)
            slider.Position = UDim2.new(1, -124, 0.5, -3)
            slider.BackgroundColor3 = C.surfaceHi
            slider.BorderSizePixel = 0
            slider.Parent = frame
            makeCorner(slider, 3)
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(CONFIG.Smoothness, 0, 1, 0)
            fill.BackgroundColor3 = C.accent
            fill.BorderSizePixel = 0
            fill.Parent = slider
            makeCorner(fill, 3)
            
            local value = Instance.new("TextLabel")
            value.Size = UDim2.new(0, 40, 1, 0)
            value.Position = UDim2.new(1, 0, 0, 0)
            value.BackgroundTransparency = 1
            value.Text = string.format("%.2f", CONFIG.Smoothness)
            value.TextColor3 = C.textMuted
            value.TextSize = 11
            value.Font = Enum.Font.Gotham
            value.Parent = slider
        elseif setting.key == "distance" then
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0, 120, 0, 6)
            slider.Position = UDim2.new(1, -124, 0.5, -3)
            slider.BackgroundColor3 = C.surfaceHi
            slider.BorderSizePixel = 0
            slider.Parent = frame
            makeCorner(slider, 3)
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((CONFIG.DistanceLimit - 50) / 450, 0, 1, 0)
            fill.BackgroundColor3 = C.accent
            fill.BorderSizePixel = 0
            fill.Parent = slider
            makeCorner(fill, 3)
            
            local value = Instance.new("TextLabel")
            value.Size = UDim2.new(0, 50, 1, 0)
            value.Position = UDim2.new(1, 0, 0, 0)
            value.BackgroundTransparency = 1
            value.Text = tostring(CONFIG.DistanceLimit)
            value.TextColor3 = C.textMuted
            value.TextSize = 11
            value.Font = Enum.Font.Gotham
            value.Parent = slider
        end
        
        settingsY = settingsY + 46
    end
    
    -- FOV Circle
    local fovCircle = Instance.new("ImageLabel")
    fovCircle.Size = UDim2.new(0, CONFIG.FOV * 2, 0, CONFIG.FOV * 2)
    fovCircle.Position = UDim2.new(0.5, -CONFIG.FOV, 0.5, -CONFIG.FOV)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Image = "rbxassetid://4911621264"
    fovCircle.ImageColor3 = C.text
    fovCircle.ImageTransparency = 0.4
    fovCircle.Visible = false
    fovCircle.Parent = gui
    
    -- Crosshair
    local crosshair = Instance.new("Frame")
    crosshair.Size = UDim2.new(0, 0, 0, 0)
    crosshair.BackgroundTransparency = 1
    crosshair.Visible = false
    crosshair.Parent = gui
    
    local function updateCrosshair()
        local center = getCenter()
        crosshair.Position = UDim2.fromOffset(center.X, center.Y)
    end
    
    local function makeDot()
        for i, c in pairs(crosshair:GetChildren()) do c:Destroy() end
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
        dot.BackgroundColor3 = C.text
        dot.BorderSizePixel = 0
        dot.Parent = crosshair
        makeCorner(dot, 999)
    end
    
    makeDot()
    updateCrosshair()
    
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCrosshair)
    UserInputService.WindowFocused:Connect(updateCrosshair)
    
    return {
        gui = gui,
        main = main,
        header = header,
        winButtons = winButtons,
        tabButtons = tabButtons,
        tabContents = tabContents,
        status = status,
        targetLabel = targetLabel,
        aimLabel = aimLabel,
        killsLabel = killsLabel,
        btnToggle = btnToggle,
        btnAimPart = btnAimPart,
        btnXRay = btnXRay,
        btnFriend = btnFriend,
        btnExit = btnExit,
        fovCircle = fovCircle,
        crosshair = crosshair,
        friendList = friendList,
        updateFriends = UpdateFriendsList,
        switchTab = switchTab,
        updateCrosshair = updateCrosshair,
    }
end

UI = BuildUI()

local function ShowFriendSelector()
    if State.destroyed then return end
    UI.switchTab("friends")
end

-- Rest of aim logic remains the same...
-- [AIM LOGIC HERE - keeping it compact]

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function updateFilter(char)
    if char then
        raycastParams.FilterDescendantsInstances = {char}
    end
end

updateFilter(Player.Character)
Player.CharacterAdded:Connect(updateFilter)

local function getAimPart(plr)
    if not plr or not plr.Character or not plr.Character.Parent then return nil end
    local char = plr.Character
    local part = char:FindFirstChild(CONFIG.AimPart)
    if part then return part end
    part = char:FindFirstChild(CONFIG.BackupPart)
    if part then return part end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function getScreenPos(part)
    if not part or not part.Parent then return nil end
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return nil end
    return Vector2.new(pos.X, pos.Y)
end

local function getVelocity(plr)
    if not plr or not plr.Character or not plr.Character.Parent then return Vector3.new(0, 0, 0) end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if root then return root.AssemblyLinearVelocity end
    return Vector3.new(0, 0, 0)
end

local function isVisible(plr)
    if not plr or not plr.Character or not plr.Character.Parent then return false end
    if not Camera then return false end
    if isFriend(plr) then return false end
    local part = getAimPart(plr)
    if not part or not part.Parent then return false end
    local origin = Camera.CFrame.Position
    local targetPos = part.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    if distance > CONFIG.DistanceLimit then return false end
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

local XRAY_PARTS = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftFoot", "RightFoot", "LeftHand", "RightHand"}

local function getCharParts(plr)
    if not plr or not plr.Character or not plr.Character.Parent then return {} end
    if isFriend(plr) then return {} end
    local cached = XRayState.partsCache[plr]
    if cached and XRayState.cacheTimers[plr] and os.clock() - XRayState.cacheTimers[plr] < XRayState.CACHE_DURATION then
        return cached
    end
    local char = plr.Character
    local parts = {}
    for i, name in ipairs(XRAY_PARTS) do
        local part = char:FindFirstChild(name)
        if part and part.Parent then
            table.insert(parts, part)
        end
    end
    if #parts < 3 then
        for i, child in ipairs(char:GetDescendants()) do
            if child:IsA("BasePart") and child.Parent then
                table.insert(parts, child)
            end
        end
    end
    XRayState.partsCache[plr] = parts
    XRayState.cacheTimers[plr] = os.clock()
    return parts
end

local function clearCache(plr)
    if plr then
        XRayState.partsCache[plr] = nil
        XRayState.cacheTimers[plr] = nil
    else
        XRayState.partsCache = {}
        XRayState.cacheTimers = {}
    end
end

local function removeBox(plr)
    local data = XRayState.boxes[plr]
    if data then
        if data.container and data.container.Parent then
            data.container:Destroy()
        end
        XRayState.boxes[plr] = nil
    end
end

local function clearAllBoxes()
    for plr in pairs(XRayState.boxes) do
        removeBox(plr)
    end
    XRayState.boxes = {}
end

local function createBox(plr)
    if XRayState.boxes[plr] then return end
    if isFriend(plr) then return end
    if not XRayState.container or not XRayState.container.Parent then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 40, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = XRayState.container
    
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 0.7
    border.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    border.BorderSizePixel = 0
    border.Parent = container
    
    makeCorner(border, 4)
    
    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, 0, 1, 0)
    outline.Position = UDim2.new(0, 1, 0, 1)
    outline.Size = UDim2.new(1, -2, 1, -2)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 2
    outline.BorderColor3 = Color3.fromHSV(0, 1, 1)
    outline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outline.BackgroundTransparency = 0.7
    outline.Parent = container
    makeCorner(outline, 3)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromHSV(0, 1, 1)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = container
    
    XRayState.boxes[plr] = {
        container = container,
        border = border,
        outline = outline,
        name = nameLabel,
    }
end

local function updateBox(plr, hue)
    local data = XRayState.boxes[plr]
    if not data then return end
    if not data.container or not data.container.Parent then
        XRayState.boxes[plr] = nil
        return
    end
    if not plr or not plr.Character or not plr.Character.Parent then
        removeBox(plr)
        return
    end
    if not Camera then return end
    
    local color = Color3.fromHSV(hue, 1, 1)
    if data.border then data.border.BackgroundColor3 = color end
    if data.outline then data.outline.BorderColor3 = color end
    if data.name then data.name.TextColor3 = color end
    
    local parts = getCharParts(plr)
    if #parts == 0 then
        data.container.Visible = false
        return
    end
    
    local minX, maxX, minY, maxY = nil, nil, nil, nil
    for i, part in ipairs(parts) do
        if part and part.Parent then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                if minX == nil then
                    minX, maxX = pos.X, pos.X
                    minY, maxY = pos.Y, pos.Y
                else
                    if pos.X < minX then minX = pos.X end
                    if pos.X > maxX then maxX = pos.X end
                    if pos.Y < minY then minY = pos.Y end
                    if pos.Y > maxY then maxY = pos.Y end
                end
            end
        end
    end
    
    if minX == nil then
        data.container.Visible = false
        return
    end
    
    local padding = 4
    local width = maxX - minX + padding * 2
    local height = maxY - minY + padding * 2
    width = math.max(width, 20)
    height = math.max(height, 30)
    
    data.container.Position = UDim2.new(0, minX - padding, 0, minY - padding)
    data.container.Size = UDim2.new(0, width, 0, height)
    data.container.Visible = true
end

local function updateXRay(dt)
    if State.destroyed then return end
    if not XRayState.enabled then
        clearAllBoxes()
        return
    end
    
    State.hue = (State.hue + dt * 0.2) % 1
    State.xrayTimer = State.xrayTimer + dt
    local shouldUpdate = State.xrayTimer >= CONFIG.XRayUpdateInterval
    if shouldUpdate then State.xrayTimer = 0 end
    
    for plr, data in pairs(XRayState.boxes) do
        if data and data.container and data.container.Parent then
            local color = Color3.fromHSV(State.hue, 1, 1)
            if data.border then data.border.BackgroundColor3 = color end
            if data.outline then data.outline.BorderColor3 = color end
            if data.name then data.name.TextColor3 = color end
        end
    end
    
    if not shouldUpdate then return end
    
    for plr in pairs(XRayState.boxes) do
        if not plr or not plr.Parent or not isAlive(plr) then
            removeBox(plr)
        end
    end
    
    for i, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Parent and isAlive(plr) then
            createBox(plr)
            updateBox(plr, State.hue)
        end
    end
end

local function updateTargetCF(plr)
    if not plr or not isAlive(plr) then return end
    if not Camera then return end
    
    local part = getAimPart(plr)
    if not part or not part.Parent then return end
    
    local pos = part.Position
    local vel = getVelocity(plr)
    local distance = (pos - Camera.CFrame.Position).Magnitude
    local targetPos = pos
    
    if vel.Magnitude >= 0.1 then
        local flyTime = distance / CONFIG.BulletSpeed
        local predTime = flyTime * CONFIG.PredictionStrength
        targetPos = pos + vel * predTime
    end
    
    State.targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

local function findBestTarget()
    if not Camera or not Player.Character or not Player.Character.Parent then return nil end
    
    local center = getCenter()
    local best = nil
    local bestDist = math.huge
    local fovSq = CONFIG.FOV ^ 2
    local camPos = Camera.CFrame.Position
    local candidates = {}
    
    for i, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Parent and isAlive(plr) and not isFriend(plr) then
            local part = getAimPart(plr)
            if part and part.Parent then
                local screenPos = getScreenPos(part)
                if screenPos then
                    local dx = screenPos.X - center.X
                    local dy = screenPos.Y - center.Y
                    local dist = dx*dx + dy*dy
                    if dist < fovSq then
                        local offset = part.Position - camPos
                        local worldDistSq = offset:Dot(offset)
                        if worldDistSq <= DIST_LIMIT_SQ then
                            table.insert(candidates, {
                                player = plr,
                                part = part,
                                screenPos = screenPos,
                                dist = dist,
                            })
                        end
                    end
                end
            end
        end
    end
    
    for j, cand in ipairs(candidates) do
        if isVisible(cand.player) then
            if cand.dist < bestDist then
                best = cand.player
                bestDist = cand.dist
            end
        end
    end
    
    return best
end

local function isTargetInFOV(plr)
    if not plr or not plr.Character or not plr.Character.Parent then return false end
    if not Camera then return false end
    if isFriend(plr) then return false end
    
    local part = getAimPart(plr)
    if not part or not part.Parent then return false end
    
    local screenPos = getScreenPos(part)
    if not screenPos then return false end
    
    local center = getCenter()
    local dx = screenPos.X - center.X
    local dy = screenPos.Y - center.Y
    local dist = dx*dx + dy*dy
    
    return dist < CONFIG.FOV ^ 2
end

local function processAim(dt)
    if State.destroyed then return end
    if not Camera then return end
    
    updateXRay(dt)
    
    if not State.enabled then return end
    
    State.searchTimer = State.searchTimer + dt
    
    if State.target and State.target.Parent and isAlive(State.target) and not isFriend(State.target) then
        local part = getAimPart(State.target)
        local visible = part and part.Parent and isVisible(State.target)
        local inFOV = isTargetInFOV(State.target)
        
        if part and visible and inFOV then
            State.lostTimer = 0
            updateTargetCF(State.target)
            
            if State.targetCF then
                if State.smoothCF then
                    State.smoothCF = State.smoothCF:Lerp(State.targetCF, CONFIG.Smoothness)
                else
                    State.smoothCF = State.targetCF
                end
                
                if Camera and State.smoothCF then
                    Camera.CFrame = State.smoothCF
                end
            end
            
            if UI.status then
                UI.status.Text = "ЗАХВАТ: " .. State.target.Name
                UI.status.TextColor3 = C.green
            end
            if UI.targetLabel then
                UI.targetLabel.Text = "ЦЕЛЬ: " .. State.target.Name
                UI.targetLabel.TextColor3 = C.green
            end
            return
        end
        
        State.lostTimer = State.lostTimer + dt
        if State.lostTimer > CONFIG.LostTimeout then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
    end
    
    if State.searchTimer < CONFIG.SearchInterval then return end
    State.searchTimer = 0
    
    local newTarget = findBestTarget()
    if newTarget then
        State.target = newTarget
        State.lostTimer = 0
        State.smoothCF = nil
        State.targetCF = nil
        updateTargetCF(newTarget)
        
        if State.targetCF then
            State.smoothCF = State.targetCF
            if Camera then
                Camera.CFrame = State.smoothCF
            end
        end
        
        if UI.status then
            UI.status.Text = "ЗАХВАТ: " .. newTarget.Name
            UI.status.TextColor3 = C.green
        end
        if UI.targetLabel then
            UI.targetLabel.Text = "ЦЕЛЬ: " .. newTarget.Name
            UI.targetLabel.TextColor3 = C.green
        end
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
        
        if UI.status then
            UI.status.Text = "НЕТ ЦЕЛИ"
            UI.status.TextColor3 = C.amber
        end
        if UI.targetLabel then
            UI.targetLabel.Text = "ПОИСК..."
            UI.targetLabel.TextColor3 = C.amber
        end
    end
end

local function toggleAim()
    if State.destroyed then return end
    
    State.enabled = not State.enabled
    
    if State.enabled then
        local target = findBestTarget()
        if target then
            State.target = target
            State.lostTimer = 0
            State.targetCF = nil
            State.smoothCF = nil
            State.searchTimer = 0
            State.xrayTimer = 0
            updateTargetCF(target)
            
            if State.targetCF and Camera then
                State.smoothCF = State.targetCF
                Camera.CFrame = State.smoothCF
            end
            
            if UI.status then
                UI.status.Text = "ЗАХВАТ: " .. target.Name
                UI.status.TextColor3 = C.green
            end
            if UI.targetLabel then
                UI.targetLabel.Text = "ЦЕЛЬ: " .. target.Name
                UI.targetLabel.TextColor3 = C.green
            end
        else
            State.target = nil
            if UI.status then
                UI.status.Text = "НЕТ ЦЕЛИ"
                UI.status.TextColor3 = C.amber
            end
            if UI.targetLabel then
                UI.targetLabel.Text = "ПОИСК..."
                UI.targetLabel.TextColor3 = C.amber
            end
        end
        
        UI.btnToggle.Text = "ВЫКЛЮЧИТЬ"
        UI.fovCircle.Visible = CONFIG.ShowFOV
        UI.crosshair.Visible = true
        
        if not XRayState.container or not XRayState.container.Parent then
            XRayState.container = Instance.new("Folder")
            XRayState.container.Name = "XRay"
            XRayState.container.Parent = UI.gui
        end
    else
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
        State.lostTimer = 0
        State.searchTimer = 0
        State.xrayTimer = 0
        State.killCount = 0
        
        UI.status.Text = "ОТКЛЮЧЕН"
        UI.status.TextColor3 = C.textMuted
        UI.targetLabel.Text = "ЦЕЛЬ: НЕТ"
        UI.targetLabel.TextColor3 = C.textMuted
        UI.killsLabel.Text = "УБИЙСТВ: 0"
        UI.btnToggle.Text = "ВКЛЮЧИТЬ"
        UI.fovCircle.Visible = false
        UI.crosshair.Visible = false
        
        clearAllBoxes()
        clearCache()
        if XRayState.container and XRayState.container.Parent then
            XRayState.container:Destroy()
            XRayState.container = nil
        end
    end
end

local function switchAimPart()
    if State.destroyed then return end
    
    if CONFIG.AimPart == "Head" then
        CONFIG.AimPart = "HumanoidRootPart"
        CONFIG.BackupPart = "Torso"
        UI.aimLabel.Text = "ЦЕЛЬ: ТЕЛО"
        UI.btnAimPart.Text = "ЦЕЛЬ: ГОЛОВА"
    else
        CONFIG.AimPart = "Head"
        CONFIG.BackupPart = "UpperTorso"
        UI.aimLabel.Text = "ЦЕЛЬ: ГОЛОВА"
        UI.btnAimPart.Text = "ЦЕЛЬ: ТЕЛО"
    end
end

local function toggleXRay()
    if State.destroyed then return end
    
    XRayState.enabled = not XRayState.enabled
    UI.btnXRay.Text = XRayState.enabled and "X-RAY: ВКЛ" or "X-RAY: ВЫКЛ"
    
    if not XRayState.enabled then
        clearAllBoxes()
        clearCache()
        if XRayState.container and XRayState.container.Parent then
            XRayState.container:Destroy()
            XRayState.container = nil
        end
    elseif not XRayState.container or not XRayState.container.Parent then
        XRayState.container = Instance.new("Folder")
        XRayState.container.Name = "XRay"
        XRayState.container.Parent = UI.gui
    end
end

local connections = {}

local function connect(obj, event, callback)
    local conn
    if type(obj) == "string" then
        conn = event:Connect(callback)
    else
        conn = obj[event]:Connect(callback)
    end
    table.insert(connections, conn)
    return conn
end

connect(UI.btnToggle, "MouseButton1Click", toggleAim)
connect(UI.btnAimPart, "MouseButton1Click", switchAimPart)
connect(UI.btnXRay, "MouseButton1Click", toggleXRay)
connect(UI.btnFriend, "MouseButton1Click", ShowFriendSelector)

connect(UI.winButtons.minimize, "MouseButton1Click", function()
    State.minimized = not State.minimized
    if State.minimized then
        UI.main:TweenSize(UDim2.new(0, 200, 0, 32), "Out", "Quad", 0.3, true)
        for i, child in ipairs(UI.main:GetChildren()) do
            if child:IsA("TextLabel") or (child:IsA("TextButton") and child ~= UI.header) or child:IsA("Frame") then
                child.Visible = false
            end
        end
        UI.winButtons.minimize.Text = "□"
    else
        UI.main:TweenSize(UDim2.new(0, 480, 0, 420), "Out", "Quad", 0.3, true)
        for i, child in ipairs(UI.main:GetChildren()) do
            child.Visible = true
        end
        UI.winButtons.minimize.Text = "─"
    end
end)

connect(UI.winButtons.maximize, "MouseButton1Click", function()
    State.maximized = not State.maximized
    if State.maximized then
        UI.main:TweenSize(UDim2.new(0, 600, 0, 500), "Out", "Quad", 0.3, true)
        UI.main:TweenPosition(UDim2.new(0.5, -300, 0.5, -250), "Out", "Quad", 0.3, true)
    else
        UI.main:TweenSize(UDim2.new(0, 480, 0, 420), "Out", "Quad", 0.3, true)
        UI.main:TweenPosition(UDim2.new(0.5, -240, 0.5, -210), "Out", "Quad", 0.3, true)
    end
end)

local keyConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if State.destroyed then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        toggleAim()
    elseif input.KeyCode == Enum.KeyCode.Two then
        switchAimPart()
    elseif input.KeyCode == Enum.KeyCode.Three then
        toggleXRay()
    elseif input.KeyCode == Enum.KeyCode.Four then
        ShowFriendSelector()
    end
end)
table.insert(connections, keyConn)

Players.PlayerRemoving:Connect(function(plr)
    removeBox(plr)
    clearCache(plr)
    if State.target == plr then
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
    end
end)

for i, plr in pairs(Players:GetPlayers()) do
    if plr ~= Player then
        plr.CharacterAdded:Connect(function()
            clearCache(plr)
        end)
        plr.CharacterRemoving:Connect(function()
            clearCache(plr)
        end)
    end
end

local function cleanup()
    if State.cleaned then return end
    State.cleaned = true
    State.destroyed = true
    
    for i, conn in ipairs(connections) do
        if conn and conn.Disconnect then
            pcall(conn.Disconnect, conn)
        end
    end
    connections = {}
    
    if UI.gui and UI.gui.Parent then
        pcall(function() UI.gui:Destroy() end)
    end
    if XRayState.container and XRayState.container.Parent then
        pcall(function() XRayState.container:Destroy() end)
        XRayState.container = nil
    end
    
    clearAllBoxes()
    clearCache()
    State.enabled = false
    State.target = nil
    State.targetCF = nil
    State.smoothCF = nil
end

connect(UI.winButtons.close, "MouseButton1Click", cleanup)
connect(UI.btnExit, "MouseButton1Click", cleanup)

local renderConn = RunService.RenderStepped:Connect(function(dt)
    if State.destroyed then return end
    pcall(processAim, dt)
end)
table.insert(connections, renderConn)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NOVA v2.54",
    Text = "1 - Вкл/Выкл | 2 - Сменить цель | 3 - X-Ray | 4 - Друзья",
    Duration = 5
})

print("NOVA v2.54 ЗАГРУЖЕНА")
print("1 - Вкл/Выкл")
print("2 - Сменить цель (ГОЛОВА ↔ ТЕЛО)")
print("3 - Вкл/Выкл X-RAY")
print("4 - Добавить/Удалить друга")
