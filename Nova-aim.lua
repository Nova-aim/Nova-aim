--==================================================
-- NOVA UI SYSTEM v3.0
-- Loader + Terminal + Menu + Effects + AIM
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

local Color = {
    bg = Color3.fromRGB(8,8,8),
    panel = Color3.fromRGB(18,18,18),
    white = Color3.fromRGB(235,235,235),
    gray = Color3.fromRGB(140,140,140),
    green = Color3.fromRGB(120,255,150),
    red = Color3.fromRGB(255,60,60),
    dark = Color3.fromRGB(12,12,12),
}

--==================================================
-- FUNCTIONS
--==================================================

local function Corner(obj,size)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,size)
    c.Parent = obj
end

local function Tween(obj,time,prop)
    TweenService:Create(
        obj,
        TweenInfo.new(time,Enum.EasingStyle.Quint),
        prop
    ):Play()
end

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
-- LOADER
--==================================================

local Loader = Instance.new("Frame")
Loader.Size = UDim2.fromScale(1,1)
Loader.BackgroundColor3 = Color.bg
Loader.Parent = Gui

local Terminal = Instance.new("TextLabel")
Terminal.Size = UDim2.new(1,-100,0,300)
Terminal.Position = UDim2.new(0,50,0.25,0)
Terminal.BackgroundTransparency = 1
Terminal.TextColor3 = Color.green
Terminal.Font = Enum.Font.Code
Terminal.TextSize = 18
Terminal.TextXAlignment = Enum.TextXAlignment.Left
Terminal.TextYAlignment = Enum.TextYAlignment.Top
Terminal.Parent = Loader

local lines = {
    "> NOVA SYSTEM BOOT",
    "> Loading modules...",
    "> Checking interface...",
    "> Loading particles...",
    "> Engine ready",
    "",
    "READY? y/n"
}

for i,v in ipairs(lines) do
    Terminal.Text = Terminal.Text .. v .. "\n"
    task.wait(0.18)
end

--==================================================
-- PARTICLES
--==================================================

for i = 1,35 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0,3,0,3)
    p.Position = UDim2.new(math.random(),0,math.random(),0)
    p.BackgroundColor3 = Color.white
    p.BackgroundTransparency = 0.5
    p.Parent = Loader
    Corner(p,10)
    
    task.spawn(function()
        while p.Parent do
            Tween(
                p,
                math.random(3,6),
                {
                    Position = UDim2.new(
                        math.random(),
                        0,
                        math.random(),
                        0
                    ),
                    BackgroundTransparency = 1
                }
            )
            task.wait(3)
            p.BackgroundTransparency = 0.5
        end
    end)
end

task.wait(1)

Tween(
    Loader,
    0.6,
    {
        BackgroundTransparency = 1
    }
)

task.wait(0.7)
Loader:Destroy()

--==================================================
-- FOV CIRCLE
--==================================================

local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
fovCircle.Position = UDim2.new(0.5, -Config.FOV, 0.5, -Config.FOV)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://4911621264"
fovCircle.ImageColor3 = Color.green
fovCircle.ImageTransparency = 0.4
fovCircle.Visible = false
fovCircle.Parent = Gui

--==================================================
-- CROSSHAIR
--==================================================

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 4, 0, 4)
crosshair.Position = UDim2.new(0.5, -2, 0.5, -2)
crosshair.BackgroundColor3 = Color.green
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.Parent = Gui
local crossCorner = Instance.new("UICorner")
crossCorner.CornerRadius = UDim.new(1,0)
crossCorner.Parent = crosshair

--==================================================
-- X-RAY CONTAINER
--==================================================

local xrayContainer = Instance.new("Frame")
xrayContainer.Size = UDim2.fromScale(1,1)
xrayContainer.BackgroundTransparency = 1
xrayContainer.BorderSizePixel = 0
xrayContainer.Parent = Gui

--==================================================
-- MAIN MENU
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,430,0,450)
Main.Position = UDim2.new(0.5,-215,0.5,-225)
Main.BackgroundColor3 = Color.panel
Main.Parent = Gui
Corner(Main,25)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "NOVA"
Title.TextColor3 = Color.white
Title.Font = Enum.Font.Code
Title.TextSize = 32
Title.Parent = Main

-- КЛИК ПО ЗАГОЛОВКУ ДЛЯ СМЕНЫ ЦЕЛИ
Title.Active = true
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SwitchAimPart()
    end
end)

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1,-40,0,45)
Tabs.Position = UDim2.new(0,20,0,60)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local function Button(text,pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.45,0,1,0)
    b.Position = pos
    b.BackgroundColor3 = Color.bg
    b.Text = text
    b.TextColor3 = Color.white
    b.Font = Enum.Font.Code
    b.TextSize = 16
    b.Parent = Tabs
    Corner(b,20)
    
    b.MouseEnter:Connect(function()
        Tween(b,0.2,{
            BackgroundColor3 = Color3.fromRGB(35,35,35)
        })
    end)
    
    b.MouseLeave:Connect(function()
        Tween(b,0.2,{
            BackgroundColor3 = Color.bg
        })
    end)
    
    return b
end

local SoftTab = Button("SOFTWARE", UDim2.new(0,0,0,0))
local SetTab = Button("SETTINGS", UDim2.new(0.55,0,0,0))

local Content = Instance.new("TextLabel")
Content.Size = UDim2.new(1,-40,0,200)
Content.Position = UDim2.new(0,20,0,130)
Content.BackgroundTransparency = 1
Content.TextColor3 = Color.white
Content.Font = Enum.Font.Code
Content.TextSize = 17
Content.TextXAlignment = Enum.TextXAlignment.Left
Content.TextYAlignment = Enum.TextYAlignment.Top
Content.Text = [[
SYSTEM STATUS

● Status: READY
● Connection: STABLE
● Engine: ACTIVE


TARGET

None


LOCK:
Searching

HIT:
---
]]
Content.Parent = Main

--==================================================
-- ENABLE BUTTON
--==================================================

local Enable = Instance.new("TextButton")
Enable.Size = UDim2.new(0.5,0,0,45)
Enable.Position = UDim2.new(0.25,0,0,345)
Enable.Text = "ENABLE"
Enable.BackgroundColor3 = Color.bg
Enable.TextColor3 = Color.white
Enable.Font = Enum.Font.Code
Enable.TextSize = 18
Enable.Parent = Main
Corner(Enable,25)

--==================================================
-- MINIMIZE
--==================================================

local Min = Instance.new("TextButton")
Min.Size = UDim2.new(0.5,0,0,35)
Min.Position = UDim2.new(0.25,0,0,400)
Min.Text = "MINIMIZE"
Min.BackgroundColor3 = Color.bg
Min.TextColor3 = Color.white
Min.Font = Enum.Font.Code
Min.Parent = Main
Corner(Min,20)

--==================================================
-- MINI LOGO
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0,70,0,70)
Mini.Position = UDim2.new(0.05,0,0.8,0)
Mini.Text = "N"
Mini.TextSize = 35
Mini.Font = Enum.Font.Code
Mini.TextColor3 = Color.white
Mini.BackgroundColor3 = Color.panel
Mini.Visible = false
Mini.Parent = Gui
Corner(Mini,50)

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
        UpdateContent()
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
        UpdateContent()
    end
end

--==================================================
-- ОБНОВЛЕНИЕ КОНТЕНТА
--==================================================

local function UpdateContent()
    local targetText = State.target and State.target.Name or "None"
    local lockText = State.aimEnabled and (State.target and "LOCKED" or "Searching") or "Disabled"
    local hitText = State.target and "---" or "---"
    
    Content.Text = [[
SYSTEM STATUS

● Status: ]] .. (State.aimEnabled and "ACTIVE" or "READY") .. [[
● Connection: STABLE
● Engine: ACTIVE


TARGET

]] .. targetText .. [[


LOCK:
]] .. lockText .. [[

HIT:
]] .. hitText .. [[
]]
end

--==================================================
-- ФУНКЦИИ ДЛЯ КНОПОК
--==================================================

local function ToggleAim()
    State.aimEnabled = not State.aimEnabled
    if State.aimEnabled then
        Enable.Text = "DISABLE"
        Enable.TextColor3 = Color.red
        fovCircle.Visible = true
        crosshair.Visible = true
    else
        Enable.Text = "ENABLE"
        Enable.TextColor3 = Color.white
        fovCircle.Visible = false
        crosshair.Visible = false
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
        ClearAllBoxes()
    end
    UpdateContent()
end

local function ToggleXRay()
    State.xrayEnabled = not State.xrayEnabled
    if not State.xrayEnabled then
        ClearAllBoxes()
    end
    UpdateContent()
end

local function SwitchAimPart()
    if Config.AimPart == "Head" then
        Config.AimPart = "HumanoidRootPart"
        Config.BackupPart = "Torso"
    else
        Config.AimPart = "Head"
        Config.BackupPart = "UpperTorso"
    end
    UpdateContent()
end

--==================================================
-- ПОДКЛЮЧЕНИЕ КНОПОК
--==================================================

Enable.MouseButton1Click:Connect(ToggleAim)

SoftTab.MouseButton1Click:Connect(function()
    ToggleXRay()
end)

SetTab.MouseButton1Click:Connect(function()
    SwitchAimPart()
end)

Min.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
    Main.Visible = true
    Mini.Visible = false
end)

--==================================================
-- DRAG MINI LOGO
--==================================================

local dragData = {
    dragging = false,
    startPos = nil,
    startOffset = nil,
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
-- ОБНОВЛЕНИЕ КРОССХАИРА
--==================================================

local function UpdateCrosshair()
    if not Camera then return end
    local center = GetCenter()
    crosshair.Position = UDim2.fromOffset(center.X, center.Y)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCrosshair)
UserInputService.WindowFocused:Connect(UpdateCrosshair)

--==================================================
-- ЗАПУСК
--==================================================

UpdateContent()

RunService.RenderStepped:Connect(function(dt)
    pcall(Update, dt)
end)

print("NOVA UI v3.0 READY")
