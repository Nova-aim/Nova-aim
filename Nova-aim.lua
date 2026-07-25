-- AIM LOCK v36 | ULTIMATE EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ============================================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН
-- ============================================================
local function createSplashScreen()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SplashScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.DisplayOrder = 9999

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.Parent = gui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
    })
    gradient.Parent = frame

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 400, 0, 80)
    logo.Position = UDim2.new(0.5, -200, 0.4, -40)
    logo.BackgroundTransparency = 1
    logo.Text = "AIM LOCK"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 48
    logo.Font = Enum.Font.GothamBold
    logo.TextScaled = true
    logo.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(0, 300, 0, 30)
    sub.Position = UDim2.new(0.5, -150, 0.5, 10)
    sub.BackgroundTransparency = 1
    sub.Text = "v36 — ULTIMATE"
    sub.TextColor3 = Color3.fromRGB(150, 150, 150)
    sub.TextSize = 18
    sub.Font = Enum.Font.GothamMedium
    sub.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 300, 0, 4)
    barBg.Position = UDim2.new(0.5, -150, 0.6, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0, 200, 0, 20)
    statusText.Position = UDim2.new(0.5, -100, 0.65, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "INITIALIZING..."
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.Parent = frame

    return {
        gui = gui,
        frame = frame,
        barFill = barFill,
        statusText = statusText,
        logo = logo,
        sub = sub
    }
end

local splash = createSplashScreen()
local loadProgress = 0
local loadSteps = {
    {text = "LOADING CORE MODULES...", progress = 0.1},
    {text = "CONFIGURING AIM SYSTEM...", progress = 0.25},
    {text = "INITIALIZING X-RAY...", progress = 0.40},
    {text = "SETTING UP FRIEND SYSTEM...", progress = 0.55},
    {text = "BUILDING INTERFACE...", progress = 0.70},
    {text = "SYNCHRONIZING...", progress = 0.85},
    {text = "READY!", progress = 1.0}
}

-- ============================================================
-- КОНФИГУРАЦИЯ
-- ============================================================
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

-- ============================================================
-- СОСТОЯНИЕ
-- ============================================================
local State = {
    enabled = false,
    destroyed = false,
    cleaned = false,
    target = nil,
    targetCF = nil,
    smoothCF = nil,
    killCount = 0,
    lostTimer = 0,
    minimized = false,
    maximized = false,
    searchTimer = 0,
    xrayTimer = 0,
    hue = 0,
    friends = {},
    friendSelection = nil,
    showFriendSelector = false,
}

-- ============================================================
-- X-RAY СОСТОЯНИЕ
-- ============================================================
local XRayState = {
    enabled = true,
    boxes = {},
    container = nil,
    partsCache = {},
    cacheTimers = {},
    CACHE_DURATION = 0.5,
}

-- ============================================================
-- УТИЛИТЫ
-- ============================================================
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
    for _, friend in ipairs(State.friends) do
        if friend == plr then return true end
    end
    return false
end

-- ============================================================
-- АВАТАРКИ
-- ============================================================
local function createAvatar(plr, size)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, size, 0, size)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    img.Image = plr and Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) or ""
    img.ImageRectSize = Vector2.new(420, 420)
    img.ImageRectOffset = Vector2.new(0, 0)
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = img
    
    return container
end

-- ============================================================
-- GUI
-- ============================================================
local PlayerGui = Player:WaitForChild("PlayerGui")
local GUI = nil

local function createGradient(color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2),
    })
    return gradient
end

local function buildGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimLock_v36"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    gui.DisplayOrder = 999
    
    -- Главное окно
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 240, 0, 320)
    main.Position = UDim2.new(0, 16, 0, 16)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = main
    
    local bgGrad = createGradient(
        Color3.fromRGB(25, 25, 25),
        Color3.fromRGB(5, 5, 5)
    )
    bgGrad.Parent = main
    
    -- Обводка
    local glowBorder = Instance.new("Frame")
    glowBorder.Size = UDim2.new(1, 0, 1, 0)
    glowBorder.BackgroundTransparency = 1
    glowBorder.BorderSizePixel = 2
    glowBorder.BorderColor3 = Color3.fromRGB(255, 255, 255)
    glowBorder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    glowBorder.BackgroundTransparency = 1
    glowBorder.Parent = main
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 16)
    glowCorner.Parent = glowBorder
    
    local innerStroke = Instance.new("UIStroke")
    innerStroke.Color = Color3.fromRGB(255, 255, 255)
    innerStroke.Thickness = 1
    innerStroke.Transparency = 0.1
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Parent = main
    
    -- Хедер
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BackgroundTransparency = 0.05
    header.BorderSizePixel = 0
    header.Parent = main
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "AIM LOCK"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.Parent = header
    
    -- Кнопки окна
    local winButtons = {}
    for i, data in ipairs({
        {text = "─", pos = 1, color = Color3.fromRGB(255, 255, 255), action = "minimize"},
        {text = "□", pos = 2, color = Color3.fromRGB(255, 255, 255), action = "maximize"},
        {text = "✕", pos = 3, color = Color3.fromRGB(255, 80, 80), action = "close"},
    }) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 24, 1, 0)
        btn.Position = UDim2.new(1, -24 * (4 - data.pos), 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = data.text
        btn.TextColor3 = data.color
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = header
        winButtons[data.action] = btn
    end
    
    -- Разделитель
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 32)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.1
    divider.BorderSizePixel = 0
    divider.Parent = main
    
    -- Статус
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 18)
    status.Position = UDim2.new(0, 10, 0, 38)
    status.BackgroundTransparency = 1
    status.Text = "DISABLED"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Font = Enum.Font.Gotham
    status.Parent = main
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -20, 0, 18)
    targetLabel.Position = UDim2.new(0, 10, 0, 56)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "TARGET: NONE"
    targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetLabel.TextSize = 10
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Parent = main
    
    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(1, -20, 0, 18)
    aimLabel.Position = UDim2.new(0, 10, 0, 74)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "AIM: HEAD"
    aimLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    aimLabel.TextSize = 10
    aimLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimLabel.Font = Enum.Font.Gotham
    aimLabel.Parent = main
    
    local killsLabel = Instance.new("TextLabel")
    killsLabel.Size = UDim2.new(1, -20, 0, 18)
    killsLabel.Position = UDim2.new(0, 10, 0, 92)
    killsLabel.BackgroundTransparency = 1
    killsLabel.Text = "KILLS: 0"
    killsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    killsLabel.TextSize = 10
    killsLabel.TextXAlignment = Enum.TextXAlignment.Left
    killsLabel.Font = Enum.Font.Gotham
    killsLabel.Parent = main
    
    -- Создание кнопок
    local function createModernButton(text, y, color1, color2)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = main
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        local grad = createGradient(color1, color2)
        grad.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = btn
        
        -- Анимации
        local tweenHover = TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, -18, 0, 32)
        })
        local tweenLeave = TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0,
            Size = UDim2.new(1, -20, 0, 30)
        })
        
        btn.MouseEnter:Connect(function()
            tweenLeave:Cancel()
            tweenHover:Play()
        end)
        btn.MouseLeave:Connect(function()
            tweenHover:Cancel()
            tweenLeave:Play()
        end)
        
        return btn, stroke, grad
    end
    
    local btnToggle, strokeToggle, gradToggle = createModernButton(
        "ACTIVATE", 108,
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(150, 150, 150)
    )
    
    local btnAimPart, strokeAim, gradAim = createModernButton(
        "SWITCH TO BODY", 144,
        Color3.fromRGB(200, 200, 200),
        Color3.fromRGB(100, 100, 100)
    )
    
    local btnXRay, strokeXRay, gradXRay = createModernButton(
        "X-RAY: ON", 180,
        Color3.fromRGB(200, 200, 200),
        Color3.fromRGB(100, 100, 100)
    )
    
    local btnFriend, strokeFriend, gradFriend = createModernButton(
        "ADD FRIEND", 216,
        Color3.fromRGB(180, 200, 255),
        Color3.fromRGB(100, 120, 200)
    )
    
    local btnExit, strokeExit, gradExit = createModernButton(
        "EXIT", 252,
        Color3.fromRGB(255, 100, 100),
        Color3.fromRGB(150, 50, 50)
    )
    
    -- FOV круг
    local fovCircle = Instance.new("ImageLabel")
    fovCircle.Size = UDim2.new(0, CONFIG.FOV * 2, 0, CONFIG.FOV * 2)
    fovCircle.Position = UDim2.new(0.5, -CONFIG.FOV, 0.5, -CONFIG.FOV)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Image = "rbxassetid://4911621264"
    fovCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    fovCircle.ImageTransparency = 0.3
    fovCircle.Visible = false
    fovCircle.Parent = gui
    
    -- Прицел
    local crosshair = Instance.new("Frame")
    crosshair.Size = UDim2.new(0, 0, 0, 0)
    crosshair.BackgroundTransparency = 1
    crosshair.Visible = false
    crosshair.Parent = gui
    
    local function updateCrosshairPosition()
        local center = getCenter()
        crosshair.Position = UDim2.fromOffset(center.X, center.Y)
    end
    
    local function createDot()
        for _, c in pairs(crosshair:GetChildren()) do c:Destroy() end
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.Parent = crosshair
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
    end
    
    if CONFIG.CrosshairStyle == "DOT" then
        createDot()
    end
    
    updateCrosshairPosition()
    
    return {
        gui = gui,
        main = main,
        header = header,
        winButtons = winButtons,
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
        strokeToggle = strokeToggle,
        strokeAim = strokeAim,
        strokeXRay = strokeXRay,
        strokeFriend = strokeFriend,
        gradToggle = gradToggle,
        gradAim = gradAim,
        gradXRay = gradXRay,
        gradFriend = gradFriend,
        updateCrosshair = updateCrosshairPosition,
    }
end

-- ============================================================
-- ОКНО ВЫБОРА ДРУЗЕЙ
-- ============================================================
local function showFriendSelector()
    if State.destroyed then return end
    
    if State.friendSelector and State.friendSelector.Parent then
        State.friendSelector:Destroy()
        State.friendSelector = nil
        return
    end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 350, 0, 400)
    container.Position = UDim2.new(0.5, -175, 0.5, -200)
    container.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.Parent = GUI.gui
    container.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = container
    
    local grad = createGradient(
        Color3.fromRGB(25, 25, 25),
        Color3.fromRGB(5, 5, 5)
    )
    grad.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BackgroundTransparency = 0.5
    title.Text = "✚ SELECT FRIEND"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = title
    
    -- Список
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scroll.ScrollBarImageTransparency = 0.3
    scroll.Parent = container
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = container
    closeBtn.MouseButton1Click:Connect(function()
        if container and container.Parent then
            container:Destroy()
            State.friendSelector = nil
        end
    end)
    
    -- Добавление игроков
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(players, plr)
        end
    end
    
    table.sort(players, function(a, b)
        return a.Name < b.Name
    end)
    
    for _, plr in ipairs(players) do
        local isFriend = isFriend(plr)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 44)
        btn.BackgroundColor3 = isFriend and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(20, 20, 20)
        btn.BackgroundTransparency = isFriend and 0.7 or 0
        btn.BorderSizePixel = 0
        btn.Parent = scroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        -- Аватар
        local avatar = createAvatar(plr, 34)
        avatar.Position = UDim2.new(0, 4, 0.5, -17)
        avatar.Parent = btn
        
        -- Имя
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -80, 1, 0)
        nameLabel.Position = UDim2.new(0, 44, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = isFriend and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.Parent = btn
        
        -- Статус друга
        local friendLabel = Instance.new("TextLabel")
        friendLabel.Size = UDim2.new(0, 60, 1, 0)
        friendLabel.Position = UDim2.new(1, -65, 0, 0)
        friendLabel.BackgroundTransparency = 1
        friendLabel.Text = isFriend and "✅" or "➕"
        friendLabel.TextColor3 = isFriend and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 255)
        friendLabel.TextSize = 16
        friendLabel.Font = Enum.Font.Gotham
        friendLabel.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if isFriend then
                -- Удалить из друзей
                for i, f in ipairs(State.friends) do
                    if f == plr then
                        table.remove(State.friends, i)
                        break
                    end
                end
                if container and container.Parent then
                    container:Destroy()
                    State.friendSelector = nil
                end
                showFriendSelector()
            else
                -- Добавить в друзья
                table.insert(State.friends, plr)
                if container and container.Parent then
                    container:Destroy()
                    State.friendSelector = nil
                end
                showFriendSelector()
            end
        end)
        
        -- Ховер
        local hover = TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.1
        })
        local leave = TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundTransparency = isFriend and 0.7 or 0
        })
        btn.MouseEnter:Connect(function()
            leave:Cancel()
            hover:Play()
        end)
        btn.MouseLeave:Connect(function()
            hover:Cancel()
            leave:Play()
        end)
    end
    
    -- Обновление CanvasSize
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    State.friendSelector = container
end

-- ============================================================
-- RAYCAST
-- ============================================================
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function updateRaycastFilter(char)
    if char then
        raycastParams.FilterDescendantsInstances = {char}
    end
end

updateRaycastFilter(Player.Character)
Player.CharacterAdded:Connect(updateRaycastFilter)

-- ============================================================
-- ФУНКЦИИ АИМА
-- ============================================================
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

-- ============================================================
-- X-RAY
-- ============================================================
local XRAY_PARTS = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftFoot", "RightFoot", "LeftHand", "RightHand"}

local function getCharacterParts(plr)
    if not plr or not plr.Character or not plr.Character.Parent then return {} end
    if isFriend(plr) then return {} end
    local cached = XRayState.partsCache[plr]
    if cached and XRayState.cacheTimers[plr] and os.clock() - XRayState.cacheTimers[plr] < XRayState.CACHE_DURATION then
        return cached
    end
    local char = plr.Character
    local parts = {}
    for _, name in ipairs(XRAY_PARTS) do
        local part = char:FindFirstChild(name)
        if part and part.Parent then
            table.insert(parts, part)
        end
    end
    if #parts < 3 then
        for _, child in ipairs(char:GetDescendants()) do
            if child:IsA("BasePart") and child.Parent then
                table.insert(parts, child)
            end
        end
    end
    XRayState.partsCache[plr] = parts
    XRayState.cacheTimers[plr] = os.clock()
    return parts
end

local function clearPartsCache(plr)
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
    
    local border = Instance
