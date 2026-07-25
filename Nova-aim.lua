--==================================================
-- NOVA v2.55 TERMINAL SYSTEM
-- BOOT + TERMINAL + COMMANDS + AIM + XRAY + FRIENDS
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

if not Player then return end

local PlayerGui = Player:WaitForChild("PlayerGui")

local OLD = PlayerGui:FindFirstChild("NovaSystem")
if OLD then
    OLD:Destroy()
end

--==================================================
-- КАМЕРА
--==================================================

local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

--==================================================
-- НАСТРОЙКИ
--==================================================

local Config = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 60,
    Smoothness = 0.15,
    Distance = 250,
    Enabled = false,
}

--==================================================
-- СОСТОЯНИЕ
--==================================================

local State = {
    target = nil,
    targetCF = nil,
    smoothCF = nil,
    friends = {},
    hue = 0,
    lostTimer = 0,
    searchTimer = 0,
    xrayTimer = 0,
    enabled = false,
    bootComplete = false,
}

--==================================================
-- X-RAY
--==================================================

local XRay = {
    enabled = false,
    boxes = {},
    container = nil,
}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "NovaSystem"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(1,1)
Main.BackgroundColor3 = Color3.fromRGB(5,5,5)
Main.BorderSizePixel = 0
Main.Parent = Gui

-- Масштабирование для телефона
local Scale = Instance.new("UIScale")
Scale.Parent = Main
Scale.Scale = math.clamp(workspace.CurrentCamera.ViewportSize.X / 800, 0.7, 1.2)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Scale.Scale = math.clamp(workspace.CurrentCamera.ViewportSize.X / 800, 0.7, 1.2)
end)

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = Color3.fromRGB(15,15,15)
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5,0,1,0)
Title.Position = UDim2.new(0,15,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Nova v2.55"
Title.TextColor3 = Color3.fromRGB(230,230,230)
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- OUTPUT
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-30,1,-120)
Scroll.Position = UDim2.new(0,15,0,55)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.Parent = Main

local Output = Instance.new("TextLabel")
Output.Size = UDim2.new(1,-10,0,0)
Output.AutomaticSize = Enum.AutomaticSize.Y
Output.BackgroundTransparency = 1
Output.Text = ""
Output.TextColor3 = Color3.fromRGB(0,255,100)
Output.Font = Enum.Font.Code
Output.TextSize = 16
Output.TextXAlignment = Enum.TextXAlignment.Left
Output.TextYAlignment = Enum.TextYAlignment.Top
Output.RichText = true
Output.Parent = Scroll

-- INPUT
local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1,-30,0,35)
Input.Position = UDim2.new(0,15,1,-55)
Input.BackgroundColor3 = Color3.fromRGB(15,15,15)
Input.BorderSizePixel = 0
Input.TextColor3 = Color3.fromRGB(0,255,100)
Input.PlaceholderText = "Nova@terminal:"
Input.Font = Enum.Font.Code
Input.TextSize = 16
Input.ClearTextOnFocus = false
Input.Visible = false
Input.Parent = Main

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
XRay.container = xrayContainer

--==================================================
-- ТЕРМИНАЛ
--==================================================

local Lines = {}

local function Update()
    Output.Text = table.concat(Lines, "\n")
    task.wait()
    Scroll.CanvasSize = UDim2.new(0,0,0, Output.AbsoluteSize.Y + 30)
    Scroll.CanvasPosition = Vector2.new(0, Scroll.CanvasSize.Y.Offset)
end

local function Print(text, color)
    local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
    local reset = color and "</font>" or ""
    table.insert(Lines, colorHex .. text .. reset)
    Update()
end

local function Type(text, color)
    local current = ""
    local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
    local reset = color and "</font>" or ""
    table.insert(Lines, "")
    local index = #Lines
    for i = 1, #text do
        current = current .. text:sub(i,i)
        Lines[index] = colorHex .. current .. reset
        Update()
        task.wait(0.03)
    end
end

local function Clear()
    Lines = {}
    Update()
end

local function Log(msg)
    Print("> " .. msg, Color3.fromRGB(150,150,150))
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

local function CreateBox(plr)
    if XRay.boxes[plr] then return end
    if IsFriend(plr) then return end
    if not XRay.container then return end
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 30, 0, 40)
    box.BackgroundTransparency = 1
    box.Parent = XRay.container
    
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
    
    XRay.boxes[plr] = {
        box = box,
        border = border,
        outline = outline,
        name = name,
    }
end

local function UpdateBox(plr, hue)
    local data = XRay.boxes[plr]
    if not data then return end
    if not data.box or not data.box.Parent then
        XRay.boxes[plr] = nil
        return
    end
    if not plr or not plr.Character then
        if data.box then data.box:Destroy() end
        XRay.boxes[plr] = nil
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
    for plr in pairs(XRay.boxes) do
        if XRay.boxes[plr] and XRay.boxes[plr].box then
            XRay.boxes[plr].box:Destroy()
        end
        XRay.boxes[plr] = nil
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
    if XRay.enabled then
        State.hue = (State.hue + dt * 0.15) % 1
        State.xrayTimer = State.xrayTimer + dt
        
        if State.xrayTimer >= 0.03 then
            State.xrayTimer = 0
            
            for plr in pairs(XRay.boxes) do
                if not plr or not plr.Parent or not IsAlive(plr) or IsFriend(plr) then
                    if XRay.boxes[plr] and XRay.boxes[plr].box then
                        XRay.boxes[plr].box:Destroy()
                    end
                    XRay.boxes[plr] = nil
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
    
    if not State.enabled then return end
    
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
        Log("target: " .. newTarget.Name)
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
    end
end

--==================================================
-- КОМАНДЫ
--==================================================

local function ToggleAim()
    State.enabled = not State.enabled
    if State.enabled then
        Log("Aim ON")
        fovCircle.Visible = true
        crosshair.Visible = true
    else
        Log("Aim OFF")
        fovCircle.Visible = false
        crosshair.Visible = false
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
        ClearAllBoxes()
    end
end

local function SwitchAimPart()
    if Config.AimPart == "Head" then
        Config.AimPart = "HumanoidRootPart"
        Config.BackupPart = "Torso"
        Log("Aim: BODY")
    else
        Config.AimPart = "Head"
        Config.BackupPart = "UpperTorso"
        Log("Aim: HEAD")
    end
end

local function ToggleXRay()
    XRay.enabled = not XRay.enabled
    Log("X-Ray: " .. (XRay.enabled and "ON" or "OFF"))
    if not XRay.enabled then
        ClearAllBoxes()
    end
end

local function ShowFriends()
    if #State.friends == 0 then
        Log("No friends added")
        return
    end
    local names = {}
    for _, f in ipairs(State.friends) do
        table.insert(names, f.Name)
    end
    Log("Friends: " .. table.concat(names, ", "))
end

local function AddFriend(name)
    for _, plr in pairs(Players:GetPlayers()) do
        if string.lower(plr.Name) == string.lower(name) and plr ~= Player then
            if not IsFriend(plr) then
                table.insert(State.friends, plr)
                Log("Added friend: " .. plr.Name)
                return
            else
                Log("Already friend: " .. plr.Name)
                return
            end
        end
    end
    Log("Player not found: " .. name)
end

local function RemoveFriend(name)
    for i, plr in ipairs(State.friends) do
        if string.lower(plr.Name) == string.lower(name) then
            table.remove(State.friends, i)
            Log("Removed friend: " .. name)
            return
        end
    end
    Log("Friend not found: " .. name)
end

--==================================================
-- ОБРАБОТЧИК КОМАНД
--==================================================

local function Execute(command)
    local parts = {}
    for word in command:gmatch("%S+") do
        table.insert(parts, word)
    end
    
    if #parts == 0 then return end
    
    local cmd = string.lower(parts[1])
    
    if cmd == "help" then
        Print("")
        Print("=== NOVA COMMANDS ===", Color3.fromRGB(0,255,100))
        Print("help     - show commands")
        Print("clear    - clear terminal")
        Print("version  - show version")
        Print("status   - system status")
        Print("info     - Nova information")
        Print("on       - enable aim")
        Print("off      - disable aim")
        Print("aim      - switch aim part (HEAD/BODY)")
        Print("xray     - toggle X-Ray ON/OFF")
        Print("friends  - show friends list")
        Print("add <name>   - add friend")
        Print("remove <name> - remove friend")
        Print("exit     - close terminal")
        Print("")
    elseif cmd == "clear" then
        Clear()
    elseif cmd == "version" then
        Print("Nova v2.55 Terminal")
    elseif cmd == "status" then
        Print("Terminal: ONLINE")
        Print("Aim: " .. (State.enabled and "ON" or "OFF"))
        Print("X-Ray: " .. (XRay.enabled and "ON" or "OFF"))
        Print("Friends: " .. #State.friends)
    elseif cmd == "info" then
        Print("Nova Terminal System v2.55")
        Print("Built: 2026")
        Print("Aim Part: " .. Config.AimPart)
        Print("FOV: " .. Config.FOV)
        Print("Smoothness: " .. Config.Smoothness)
    elseif cmd == "on" then
        if not State.enabled then ToggleAim() end
    elseif cmd == "off" then
        if State.enabled then ToggleAim() end
    elseif cmd == "aim" then
        SwitchAimPart()
    elseif cmd == "xray" then
        ToggleXRay()
    elseif cmd == "friends" then
        ShowFriends()
    elseif cmd == "add" and parts[2] then
        AddFriend(parts[2])
    elseif cmd == "remove" and parts[2] then
        RemoveFriend(parts[2])
    elseif cmd == "exit" then
        Clear()
        Type("Shutting down...")
        task.wait(0.5)
        Gui:Destroy()
    else
        Print("Unknown command: " .. cmd)
        Print("Type help for commands")
    end
end

--==================================================
-- ЗАГРУЗКА (BOOT)
--==================================================

local function BootSequence()
    Type("Nova v2.55 Terminal")
    Type("")
    Type("Initializing Nova Core...")
    task.wait(0.3)
    Type("Loading modules...")
    task.wait(0.3)
    Type("Checking configuration...")
    task.wait(0.3)
    Type("Preparing interface...")
    task.wait(0.3)
    Type("")
    Type("Initialization complete.")
    Type("")
    Type("Continue? (y/n)")
    
    Input.Visible = true
    Input:CaptureFocus()
end

--==================================================
-- БЫСТРЫЕ КЛАВИШИ
--==================================================

UserInputService.InputBegan:Connect(function(input)
    if Gui and not Gui.Enabled then return end
    if input.KeyCode == Enum.KeyCode.One then
        ToggleAim()
    elseif input.KeyCode == Enum.KeyCode.Two then
        SwitchAimPart()
    elseif input.KeyCode == Enum.KeyCode.Three then
        ToggleXRay()
    end
end)

--==================================================
-- ЗАПУСК ЦИКЛА
--==================================================

RunService.RenderStepped:Connect(function(dt)
    pcall(Update, dt)
end)

--==================================================
-- ОБНОВЛЕНИЕ ПОЗИЦИИ ПРИЦЕЛА
--==================================================

local function UpdateCrosshair()
    if not Camera then return end
    local center = GetCenter()
    crosshair.Position = UDim2.fromOffset(center.X, center.Y)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCrosshair)
UserInputService.WindowFocused:Connect(UpdateCrosshair)

--==================================================
-- INPUT HANDLER
--==================================================

Input.FocusLost:Connect(function(enter)
    if not enter then return end
    
    local text = Input.Text
    Input.Text = ""
    
    if State.bootComplete == false then
        if text == "y" or text == "yes" then
            State.bootComplete = true
            Clear()
            Type("Nova Terminal v2.55")
            Type("")
            Print("Type help for commands")
            Print("")
            Input.PlaceholderText = "Nova@terminal:"
        elseif text == "n" or text == "no" then
            Type("Cancelled.")
            task.wait(1)
            Gui:Destroy()
        end
    else
        Execute(text)
    end
    
    if Gui and Gui.Enabled then
        Input:CaptureFocus()
    end
end)

--==================================================
-- ЗАПУСК
--==================================================

task.spawn(BootSequence)

print("Nova v2.55 Terminal loaded, blya!")
