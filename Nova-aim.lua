--==================================================
-- NOVA UI SYSTEM
-- Loading + Menu + Mini Logo + Functions
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local GuiParent = Player:WaitForChild("PlayerGui")

local old = GuiParent:FindFirstChild("NovaUI")
if old then
    old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "NovaUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = GuiParent

-- COLORS
local Colors = {
    Background = Color3.fromRGB(8,8,12),
    Panel = Color3.fromRGB(15,15,22),
    Accent = Color3.fromRGB(0,255,120),
    Text = Color3.fromRGB(240,240,240),
    Muted = Color3.fromRGB(130,130,140),
    Red = Color3.fromRGB(255,50,50),
    Dark = Color3.fromRGB(5,5,8),
}

--==================================================
-- КАМЕРА
--==================================================

local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

--==================================================
-- СОСТОЯНИЕ
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
}

--==================================================
-- НАСТРОЙКИ
--==================================================

local Config = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 60,
    Smoothness = 0.15,
    Distance = 250,
}

--==================================================
-- LOADING SCREEN С ПРОЦЕНТАМИ
--==================================================

local Loading = Instance.new("Frame")
Loading.Size = UDim2.fromScale(1,1)
Loading.BackgroundColor3 = Colors.Background
Loading.Parent = Gui

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1,0,0,80)
Logo.Position = UDim2.new(0,0,0.25,0)
Logo.BackgroundTransparency = 1
Logo.Text = "NOVA"
Logo.TextColor3 = Colors.Accent
Logo.Font = Enum.Font.Code
Logo.TextSize = 60
Logo.Parent = Loading

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,40)
Status.Position = UDim2.new(0,0,0.38,0)
Status.BackgroundTransparency = 1
Status.Text = "Initializing system..."
Status.TextColor3 = Colors.Text
Status.Font = Enum.Font.Code
Status.TextSize = 18
Status.Parent = Loading

local Percent = Instance.new("TextLabel")
Percent.Size = UDim2.new(1,0,0,40)
Percent.Position = UDim2.new(0,0,0.44,0)
Percent.BackgroundTransparency = 1
Percent.Text = "0%"
Percent.TextColor3 = Colors.Accent
Percent.Font = Enum.Font.Code
Percent.TextSize = 24
Percent.Parent = Loading

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0,0,0,4)
Bar.Position = UDim2.new(0.25,0,0.50,0)
Bar.BackgroundColor3 = Colors.Accent
Bar.Parent = Loading

local bootSteps = {
    {text = "Checking system modules...", pct = 10},
    {text = "Loading interface...", pct = 30},
    {text = "Preparing environment...", pct = 50},
    {text = "Initializing Nova Core...", pct = 70},
    {text = "Configuring settings...", pct = 85},
    {text = "System ready!", pct = 100},
}

task.spawn(function()
    for _, step in ipairs(bootSteps) do
        Status.Text = step.text
        local targetPct = step.pct / 100
        TweenService:Create(
            Bar,
            TweenInfo.new(1.5),
            {Size = UDim2.new(targetPct,0,0,4)}
        ):Play()
        for i = 1, step.pct do
            Percent.Text = i .. "%"
            task.wait(0.015)
        end
        task.wait(0.2)
    end
    task.wait(0.5)
    TweenService:Create(
        Loading,
        TweenInfo.new(0.6),
        {BackgroundTransparency = 1}
    ):Play()
    task.wait(0.6)
    Loading:Destroy()
    ShowMainMenu()
end)

--==================================================
-- MAIN MENU
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,420,0,320)
Main.Position = UDim2.new(0.5,-210,0.5,-160)
Main.BackgroundColor3 = Colors.Panel
Main.BackgroundTransparency = 1
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,14)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "NOVA"
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.Code
Title.TextSize = 32
Title.Active = true
Title.Parent = Main

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SwitchAimPart()
    end
end)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1,0,0,20)
StatusText.Position = UDim2.new(0,0,0,50)
StatusText.BackgroundTransparency = 1
StatusText.Text = "> offline"
StatusText.TextColor3 = Colors.Muted
StatusText.Font = Enum.Font.Code
StatusText.TextSize = 14
StatusText.Parent = Main

-- FOV круг
local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
fovCircle.Position = UDim2.new(0.5, -Config.FOV, 0.5, -Config.FOV)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://4911621264"
fovCircle.ImageColor3 = Color3.fromRGB(0,255,100)
fovCircle.ImageTransparency = 0.4
fovCircle.Visible = false
fovCircle.Parent = Gui

-- Прицел
local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 4, 0, 4)
crosshair.Position = UDim2.new(0.5, -2, 0.5, -2)
crosshair.BackgroundColor3 = Color3.fromRGB(0,255,100)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.Parent = Gui
local crossCorner = Instance.new("UICorner")
crossCorner.CornerRadius = UDim.new(1,0)
crossCorner.Parent = crosshair

-- X-Ray контейнер
local xrayContainer = Instance.new("Frame")
xrayContainer.Size = UDim2.fromScale(1,1)
xrayContainer.BackgroundTransparency = 1
xrayContainer.BorderSizePixel = 0
xrayContainer.Parent = Gui

--==================================================
-- КНОПКИ
--==================================================

local function CreateButton(text, y)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.8,0,0,40)
    Button.Position = UDim2.new(0.1,0,0,y)
    Button.BackgroundColor3 = Color3.fromRGB(25,25,35)
    Button.Text = text
    Button.TextColor3 = Colors.Text
    Button.Font = Enum.Font.Code
    Button.TextSize = 18
    Button.BackgroundTransparency = 1
    Button.Parent = Main
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = Button
    return Button
end

local Start = CreateButton("START",90)
local XRayBtn = CreateButton("XRAY OFF",140)
local Close = CreateButton("MINIMIZE",190)

--==================================================
-- MINI LOGO
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0,70,0,70)
Mini.Position = UDim2.new(0.1,0,0.8,0)
Mini.BackgroundColor3 = Colors.Panel
Mini.Text = "N"
Mini.TextColor3 = Colors.Accent
Mini.Font = Enum.Font.Code
Mini.TextSize = 40
Mini.Visible = false
Mini.Parent = Gui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(1,0)
mc.Parent = Mini

--==================================================
-- ПЛАВНОЕ ПОЯВЛЕНИЕ МЕНЮ
--==================================================

local function ShowMainMenu()
    Main.BackgroundTransparency = 1
    TweenService:Create(
        Main,
        TweenInfo.new(0.5),
        {BackgroundTransparency = 0}
    ):Play()
    task.wait(0.1)
    for _, btn in ipairs({Start, XRayBtn, Close}) do
        btn.BackgroundTransparency = 1
        btn.Position = UDim2.new(0.1,0,btn.Position.Y.Scale + 0.05,0)
        TweenService:Create(
            btn,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0,
                Position = UDim2.new(0.1,0,btn.Position.Y.Scale - 0.05,0)
            }
        ):Play()
        task.wait(0.08)
    end
end

--==================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
--==================================================

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

local function GetCenter()
    local vp = Camera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

--==================================================
-- АИМ ЛОГИКА
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

--==================================================
-- X-RAY ЛОГИКА
--==================================================

local XRayParts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
local XRayBoxes = {}

local function CreateBox(plr)
    if XRayBoxes[plr] then return end
    if IsFriend(plr) then return end
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 30, 0, 40)
    box.BackgroundTransparency = 1
    box.Parent = xrayContainer
    
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 0.6
    border.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    border.BorderSizePixel = 0
    border.Parent = box
    Round(border, 3)
    
    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, -2, 1, -2)
    outline.Position = UDim2.new(0, 1, 0, 1)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 1
    outline.BorderColor3 = Color3.fromHSV(0, 1, 1)
    outline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outline.BackgroundTransparency = 0.5
    outline.Parent = box
    Round(outline, 2)
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 14)
    name.Position = UDim2.new(0, 0, 1, 0)
    name.BackgroundTransparency = 1
    name.Text = plr.Name
    name.TextColor3 = Color3.fromHSV(0, 1, 1)
    name.TextSize = 9
    name.Font = Enum.Font.Code
    name.TextStrokeTransparency = 0.2
    name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    name.Parent = box
    
    XRayBoxes[plr] = {
        box = box,
        border = border,
        outline = outline,
        name = name,
    }
end

local function UpdateBox(plr, hue)
    local data = XRayBoxes[plr]
    if not data then return end
    if not data.box or not data.box.Parent then
        XRayBoxes[plr] = nil
        return
    end
    if not plr or not plr.Character then
        if data.box then data.box:Destroy() end
        XRayBoxes[plr] = nil
        return
    end
    
    local color = Color3.fromHSV(hue, 1, 1)
    data.border.BackgroundColor3 = color
    data.outline.BorderColor3 = color
    data.name.TextColor3 = color
    
    local parts = {}
    for _, name in ipairs(XRayParts) do
        local p = plr.Character:FindFirstChild(name)
        if p then table.insert(parts, p) end
    end
    
    if #parts == 0 then
        data.box.Visible = false
        return
    end
    
    local minX, maxX, minY, maxY
    for _, p in ipairs(parts) do
        local pos, on = Camera:WorldToViewportPoint(p.Position)
        if on then
            if not minX then
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
    
    if not minX then
        data.box.Visible = false
        return
    end
    
    local pad = 4
    local w = maxX - minX + pad * 2
    local h = maxY - minY + pad * 2
    w = math.max(w, 16)
    h = math.max(h, 24)
    
    data.box.Position = UDim2.new(0, minX - pad, 0, minY - pad)
    data.box.Size = UDim2.new(0, w, 0, h)
    data.box.Visible = true
end

local function ClearAllBoxes()
    for plr in pairs(XRayBoxes) do
        if XRayBoxes[plr] and XRayBoxes[plr].box then
            XRayBoxes[plr].box:Destroy()
        end
        XRayBoxes[plr] = nil
    end
end

--==================================================
-- ПОИСК ЦЕЛИ
--==================================================

local function FindBestTarget()
    if not Camera then return nil end
    local center = GetCenter()
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

--==================================================
-- ОСНОВНОЙ ЦИКЛ
--==================================================

local function Update(dt)
    if not Camera then return end
    
    -- X-Ray
    if State.xrayEnabled then
        State.hue = (State.hue + dt * 0.15) % 1
        State.xrayTimer = State.xrayTimer + dt
        
        if State.xrayTimer >= 0.03 then
            State.xrayTimer = 0
            
            for plr in pairs(XRayBoxes) do
                if not plr or not plr.Parent or not IsAlive(plr) or IsFriend(plr) then
                    if XRayBoxes[plr] and XRayBoxes[plr].box then
                        XRayBoxes[plr].box:Destroy()
                    end
                    XRayBoxes[plr] = nil
                end
            end
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= Player and IsAlive(plr) and not IsFriend(plr) then
                    CreateBox(plr)
                    UpdateBox(plr, State.hue)
                end
            end
        end
    end
    
    if not State.aimEnabled then return end
    
    -- Аим
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
        StatusText.Text = "> locked: " .. newTarget.Name
        StatusText.TextColor3 = Colors.Accent
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
        StatusText.Text = "> searching..."
        StatusText.TextColor3 = Colors.Muted
    end
end

--==================================================
-- ФУНКЦИИ ДЛЯ КНОПОК
--==================================================

local function ToggleAim()
    State.aimEnabled = not State.aimEnabled
    if State.aimEnabled then
        Start.Text = "STOP"
        Start.TextColor3 = Colors.Red
        StatusText.Text = "> active"
        StatusText.TextColor3 = Colors.Accent
        fovCircle.Visible = true
        crosshair.Visible = true
    else
        Start.Text = "START"
        Start.TextColor3 = Colors.Text
        StatusText.Text = "> offline"
        StatusText.TextColor3 = Colors.Muted
        fovCircle.Visible = false
        crosshair.Visible = false
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
        ClearAllBoxes()
    end
end

local function ToggleXRay()
    State.xrayEnabled = not State.xrayEnabled
    if State.xrayEnabled then
        XRayBtn.Text = "XRAY ON"
        XRayBtn.TextColor3 = Colors.Accent
    else
        XRayBtn.Text = "XRAY OFF"
        XRayBtn.TextColor3 = Colors.Text
        ClearAllBoxes()
    end
end

local function SwitchAimPart()
    if Config.AimPart == "Head" then
        Config.AimPart = "HumanoidRootPart"
        Config.BackupPart = "Torso"
        StatusText.Text = "> aim: body"
    else
        Config.AimPart = "Head"
        Config.BackupPart = "UpperTorso"
        StatusText.Text = "> aim: head"
    end
    StatusText.TextColor3 = Colors.Text
end

--==================================================
-- АНИМАЦИЯ МИНИ-ЛОГО
--==================================================

local function AnimateMiniLogo()
    while Mini and Mini.Parent do
        TweenService:Create(
            Mini,
            TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
            {Size = UDim2.new(0, 72, 0, 72)}
        ):Play()
        task.wait(2)
        TweenService:Create(
            Mini,
            TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
            {Size = UDim2.new(0, 68, 0, 68)}
        ):Play()
        task.wait(2)
    end
end

task.spawn(AnimateMiniLogo)

Mini.MouseEnter:Connect(function()
    TweenService:Create(
        Mini,
        TweenInfo.new(0.3),
        {BackgroundColor3 = Color3.fromRGB(25,25,35)}
    ):Play()
end)

Mini.MouseLeave:Connect(function()
    TweenService:Create(
        Mini,
        TweenInfo.new(0.3),
        {BackgroundColor3 = Colors.Panel}
    ):Play()
end)

--==================================================
-- MINI LOGO DRAG (улучшенный)
--==================================================

local dragData = {
    dragging = false,
    startPos = nil,
    startOffset = nil,
    connection = nil,
}

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
-- ПОДКЛЮЧЕНИЕ КНОПОК
--==================================================

Start.MouseButton1Click:Connect(ToggleAim)

XRayBtn.MouseButton1Click:Connect(ToggleXRay)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
    TweenService:Create(
        Mini,
        TweenInfo.new(0.5),
        {Size = UDim2.new(0, 80, 0, 80)}
    ):Play()
end)

Mini.MouseButton1Click:Connect(function()
    Main.Visible = true
    Mini.Visible = false
end)

--==================================================
-- ГОРЯЧИЕ КЛАВИШИ
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
-- ЗАПУСК
--==================================================

local renderConnection = RunService.RenderStepped:Connect(function(dt)
    pcall(Update, dt)
end)

local function UpdateCrosshair()
    if not Camera then return end
    local center = GetCenter()
    crosshair.Position = UDim2.fromOffset(center.X, center.Y)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCrosshair)
UserInputService.WindowFocused:Connect(UpdateCrosshair)

--==================================================
-- ОЧИСТКА
--==================================================

Gui.AncestryChanged:Connect(function()
    if not Gui.Parent then
        renderConnection:Disconnect()
    end
end)

print("Nova UI loaded with functions!")
