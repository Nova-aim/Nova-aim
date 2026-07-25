-- Nova v2.54.1
-- Бля, теперь с нормальными аватарками и выбором друзей

-- Подключаем нужную хуйню
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Чистим старый мусор
if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- Цвета для темы
local Theme = {
    bg = Color3.fromRGB(28, 28, 35),
    surface = Color3.fromRGB(38, 38, 45),
    surfaceHi = Color3.fromRGB(48, 48, 55),
    border = Color3.fromRGB(58, 58, 65),
    accent = Color3.fromRGB(80, 200, 255),
    green = Color3.fromRGB(80, 230, 140),
    red = Color3.fromRGB(255, 100, 110),
    amber = Color3.fromRGB(255, 200, 80),
    text = Color3.fromRGB(220, 225, 235),
    textMuted = Color3.fromRGB(150, 155, 165),
}

local FONT = Enum.Font.SourceSans

-- Всякое состояние
local State = {
    enabled = false,
    target = nil,
    targetCF = nil,
    smoothCF = nil,
    friends = {},
    hue = 0,
    killed = 0,
    lostTimer = 0,
    searchTimer = 0,
    xrayTimer = 0,
    showFriendSelector = false,
}

-- Для X-Ray
local XRay = {
    enabled = true,
    boxes = {},
    container = nil,
}

-- Настройки
local Config = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 60,
    Smoothness = 0.85,
    Distance = 250,
}

-- Вспомогательная хуйня

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

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

-- Создание аватарки (из профиля)
local function MakeAvatar(plr, size)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, size, 0, size)
    container.BackgroundColor3 = Theme.surface
    container.ClipsDescendants = true
    container.BorderSizePixel = 0
    Round(container, 999)
    
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundColor3 = Theme.surface
    img.ScaleType = Enum.ScaleType.Fit
    img.BorderSizePixel = 0
    
    -- Загружаем аву из профиля
    pcall(function()
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        img.Image = Players:GetUserThumbnailAsync(plr.UserId, thumbType, thumbSize)
    end)
    
    img.Parent = container
    Round(img, 999)
    
    return container
end

-- Создаём интерфейс

local UI = {}
local PlayerGui = Player:WaitForChild("PlayerGui")

function UI:Build()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Nova"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 999
    
    -- Главное окно
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 420, 0, 380)
    main.Position = UDim2.new(0.5, -210, 0.5, -190)
    main.BackgroundColor3 = Theme.bg
    main.BackgroundTransparency = 0.03
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    Round(main, 12)
    
    -- Хедер
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.Parent = main
    Round(header, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "nova >"
    title.TextColor3 = Theme.text
    title.TextSize = 14
    title.Font = FONT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Кнопки управления (точки)
    local function Dot(x, col)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, 12, 0, 12)
        d.Position = UDim2.new(0, x, 0.5, -6)
        d.BackgroundColor3 = col
        d.BorderSizePixel = 0
        d.Parent = header
        Round(d, 999)
        return d
    end
    
    local closeBtn = Dot(header.Size.X.Offset - 36, Theme.red)
    local maxBtn = Dot(header.Size.X.Offset - 20, Theme.amber)
    local minBtn = Dot(header.Size.X.Offset - 4, Theme.green)
    
    -- Статус
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 22)
    status.Position = UDim2.new(0, 10, 0, 44)
    status.BackgroundTransparency = 1
    status.Text = "> offline"
    status.TextColor3 = Theme.textMuted
    status.TextSize = 13
    status.Font = FONT
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main
    
    -- Цель
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -20, 0, 20)
    targetLabel.Position = UDim2.new(0, 10, 0, 66)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "> target: none"
    targetLabel.TextColor3 = Theme.textMuted
    targetLabel.TextSize = 12
    targetLabel.Font = FONT
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = main
    
    -- Кнопки
    local function MakeBtn(text, y, col)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Theme.surface
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Theme.text
        btn.TextSize = 12
        btn.Font = FONT
        btn.Parent = main
        Round(btn, 6)
        return btn
    end
    
    local btnToggle = MakeBtn("> start", 94, Theme.green)
    local btnAim = MakeBtn("> switch: head", 130, Theme.accent)
    local btnXRay = MakeBtn("> x-ray: on", 166, Theme.accent)
    local btnFriend = MakeBtn("> friends (0)", 202, Theme.amber)
    local btnExit = MakeBtn("> exit", 238, Theme.red)
    
    -- Консольный вывод
    local console = Instance.new("Frame")
    console.Size = UDim2.new(1, -20, 0, 28)
    console.Position = UDim2.new(0, 10, 0, 276)
    console.BackgroundColor3 = Theme.surface
    console.BackgroundTransparency = 0.5
    console.BorderSizePixel = 0
    console.Parent = main
    Round(console, 6)
    
    local consoleText = Instance.new("TextLabel")
    consoleText.Size = UDim2.new(1, -16, 1, 0)
    consoleText.Position = UDim2.new(0, 8, 0, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = "> ready"
    consoleText.TextColor3 = Theme.textMuted
    consoleText.TextSize = 11
    consoleText.Font = FONT
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.Parent = console
    
    -- FOV круг
    local fov = Instance.new("ImageLabel")
    fov.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
    fov.Position = UDim2.new(0.5, -Config.FOV, 0.5, -Config.FOV)
    fov.BackgroundTransparency = 1
    fov.Image = "rbxassetid://4911621264"
    fov.ImageColor3 = Theme.text
    fov.ImageTransparency = 0.5
    fov.Visible = false
    fov.Parent = gui
    
    -- Прицел
    local crosshair = Instance.new("Frame")
    crosshair.Size = UDim2.new(0, 4, 0, 4)
    crosshair.Position = UDim2.new(0.5, -2, 0.5, -2)
    crosshair.BackgroundColor3 = Theme.text
    crosshair.BorderSizePixel = 0
    crosshair.Visible = false
    crosshair.Parent = gui
    Round(crosshair, 999)
    
    -- Окно выбора друзей (скрытое)
    local friendWindow = Instance.new("Frame")
    friendWindow.Size = UDim2.new(0, 380, 0, 300)
    friendWindow.Position = UDim2.new(0.5, -190, 0.5, -150)
    friendWindow.BackgroundColor3 = Theme.bg
    friendWindow.BackgroundTransparency = 0.05
    friendWindow.BorderSizePixel = 0
    friendWindow.ClipsDescendants = true
    friendWindow.Visible = false
    friendWindow.Parent = gui
    Round(friendWindow, 12)
    
    -- Заголовок окна друзей
    local friendHeader = Instance.new("Frame")
    friendHeader.Size = UDim2.new(1, 0, 0, 36)
    friendHeader.BackgroundColor3 = Theme.surface
    friendHeader.BackgroundTransparency = 0.5
    friendHeader.BorderSizePixel = 0
    friendHeader.Parent = friendWindow
    Round(friendHeader, 12)
    
    local friendTitle = Instance.new("TextLabel")
    friendTitle.Size = UDim2.new(1, -60, 1, 0)
    friendTitle.Position = UDim2.new(0, 12, 0, 0)
    friendTitle.BackgroundTransparency = 1
    friendTitle.Text = "> friends"
    friendTitle.TextColor3 = Theme.text
    friendTitle.TextSize = 14
    friendTitle.Font = FONT
    friendTitle.TextXAlignment = Enum.TextXAlignment.Left
    friendTitle.Parent = friendHeader
    
    local friendClose = Instance.new("Frame")
    friendClose.Size = UDim2.new(0, 12, 0, 12)
    friendClose.Position = UDim2.new(1, -24, 0.5, -6)
    friendClose.BackgroundColor3 = Theme.red
    friendClose.BorderSizePixel = 0
    friendClose.Parent = friendHeader
    Round(friendClose, 999)
    
    -- Список игроков
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, -16, 1, -50)
    playerList.Position = UDim2.new(0, 8, 0, 44)
    playerList.BackgroundTransparency = 1
    playerList.BorderSizePixel = 0
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.ScrollBarThickness = 3
    playerList.ScrollBarImageColor3 = Theme.border
    playerList.ScrollBarImageTransparency = 0.3
    playerList.Parent = friendWindow
    
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.Padding = UDim.new(0, 4)
    playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayout.Parent = playerList
    
    -- Функция обновления списка друзей
    function UI:UpdateFriendList()
        -- Чистим список
        for _, child in pairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Собираем всех игроков
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
            empty.Text = "> no players found"
            empty.TextColor3 = Theme.textMuted
            empty.TextSize = 12
            empty.Font = FONT
            empty.Parent = playerList
            playerList.CanvasSize = UDim2.new(0, 0, 0, 40)
            return
        end
        
        -- Сортируем по имени
        table.sort(players, function(a, b) return a.Name < b.Name end)
        
        for _, plr in ipairs(players) do
            local isFriend = IsFriend(plr)
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = isFriend and Theme.greenDim or Theme.surface
            btn.BackgroundTransparency = isFriend and 0.7 or 0.3
            btn.BorderSizePixel = 0
            btn.Parent = playerList
            Round(btn, 6)
            
            -- Аватарка
            local avatar = MakeAvatar(plr, 32)
            avatar.Position = UDim2.new(0, 4, 0.5, -16)
            avatar.Parent = btn
            
            -- Имя
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(1, -80, 1, 0)
            name.Position = UDim2.new(0, 42, 0, 0)
            name.BackgroundTransparency = 1
            name.Text = plr.Name
            name.TextColor3 = isFriend and Theme.green or Theme.text
            name.TextSize = 13
            name.Font = FONT
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = btn
            
            -- Статус (друг или нет)
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Size = UDim2.new(0, 30, 1, 0)
            statusIcon.Position = UDim2.new(1, -34, 0, 0)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Text = isFriend and "✓" or "+"
            statusIcon.TextColor3 = isFriend and Theme.green or Theme.textMuted
            statusIcon.TextSize = 16
            statusIcon.Font = FONT
            statusIcon.Parent = btn
            
            -- Клик по кнопке
            btn.MouseButton1Click:Connect(function()
                if isFriend then
                    -- Удаляем из друзей
                    for i, f in ipairs(State.friends) do
                        if f == plr then
                            table.remove(State.friends, i)
                            break
                        end
                    end
                    UI:Log("removed: " .. plr.Name)
                    UI.btnFriend.Text = "> friends (" .. #State.friends .. ")"
                    UI:UpdateFriendList()
                else
                    -- Добавляем в друзья
                    table.insert(State.friends, plr)
                    UI:Log("added: " .. plr.Name)
                    UI.btnFriend.Text = "> friends (" .. #State.friends .. ")"
                    UI:UpdateFriendList()
                end
            end)
            
            -- Ховер эффект
            local hover = TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundTransparency = isFriend and 0.5 or 0.1
            })
            local leave = TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundTransparency = isFriend and 0.7 or 0.3
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
        
        -- Обновляем размер скролла
        task.wait()
        playerList.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y + 10)
    end
    
    -- Закрытие окна друзей
    friendClose.MouseButton1Click:Connect(function()
        friendWindow.Visible = false
        State.showFriendSelector = false
    end)
    
    return {
        gui = gui,
        main = main,
        status = status,
        targetLabel = targetLabel,
        consoleText = consoleText,
        btnToggle = btnToggle,
        btnAim = btnAim,
        btnXRay = btnXRay,
        btnFriend = btnFriend,
        btnExit = btnExit,
        closeBtn = closeBtn,
        maxBtn = maxBtn,
        minBtn = minBtn,
        crosshair = crosshair,
        fov = fov,
        friendWindow = friendWindow,
        playerList = playerList,
        friendClose = friendClose,
    }
end

UI = UI:Build()

-- Функция для вывода в консоль
function UI:Log(msg)
    if self.consoleText then
        self.consoleText.Text = "> " .. msg
    end
end

-- Показ окна выбора друзей
local function ShowFriendSelector()
    State.showFriendSelector = not State.showFriendSelector
    UI.friendWindow.Visible = State.showFriendSelector
    
    if State.showFriendSelector then
        UI:UpdateFriendList()
        UI:Log("friends manager opened")
    else
        UI:Log("friends manager closed")
    end
end

-- Аим логика

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function UpdateFilter(char)
    if char then
        raycastParams.FilterDescendantsInstances = {char}
    end
end

UpdateFilter(Player.Character)
Player.CharacterAdded:Connect(UpdateFilter)

local function GetPart(plr)
    if not plr or not plr.Character then return nil end
    local c = plr.Character
    local p = c:FindFirstChild(Config.AimPart)
    if p then return p end
    p = c:FindFirstChild(Config.BackupPart)
    if p then return p end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
end

local function GetScreenPos(part)
    if not part then return nil end
    local pos, on = Camera:WorldToViewportPoint(part.Position)
    if not on then return nil end
    return Vector2.new(pos.X, pos.Y)
end

local function IsVisible(plr)
    if not plr or not plr.Character then return false end
    if IsFriend(plr) then return false end
    local part = GetPart(plr)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local target = part.Position
    local dir = (target - origin).Unit
    local dist = (target - origin).Magnitude
    if dist > Config.Distance then return false end
    local result = workspace:Raycast(origin, dir * dist, raycastParams)
    if not result then return true end
    local hit = result.Instance
    local parent = hit.Parent
    while parent do
        if parent == plr.Character then return true end
        parent = parent.Parent
    end
    return false
end

-- X-Ray логика

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
    name.Font = FONT
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

-- Поиск цели

local function FindTarget()
    if not Camera then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = math.huge
    local fovSq = Config.FOV ^ 2
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and IsAlive(plr) and not IsFriend(plr) then
            local part = GetPart(plr)
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

-- Основной цикл

local function Update(dt)
    if not Camera then return end
    
    -- X-Ray обновление
    if XRay.enabled then
        State.hue = (State.hue + dt * 0.15) % 1
        State.xrayTimer = State.xrayTimer + dt
        
        if State.xrayTimer >= 0.03 then
            State.xrayTimer = 0
            
            -- Чистим мёртвых
            for plr in pairs(XRay.boxes) do
                if not plr or not plr.Parent or not IsAlive(plr) or IsFriend(plr) then
                    if XRay.boxes[plr] and XRay.boxes[plr].box then
                        XRay.boxes[plr].box:Destroy()
                    end
                    XRay.boxes[plr] = nil
                end
            end
            
            -- Создаём новые
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= Player and IsAlive(plr) and not IsFriend(plr) then
                    CreateBox(plr)
                    UpdateBox(plr, State.hue)
                end
            end
        end
    end
    
    if not State.enabled then return end
    
    -- Аим логика
    State.searchTimer = State.searchTimer + dt
    
    if State.target and IsAlive(State.target) and not IsFriend(State.target) then
        local part = GetPart(State.target)
        if part and IsVisible(State.target) then
            State.lostTimer = 0
            local pos = part.Position
            State.targetCF = CFrame.lookAt(Camera.CFrame.Position, pos)
            
            if State.targetCF then
                State.smoothCF = State.smoothCF and State.smoothCF:Lerp(State.targetCF, Config.Smoothness) or State.targetCF
                Camera.CFrame = State.smoothCF
            end
            
            UI.status.Text = "> locked: " .. State.target.Name
            UI.status.TextColor3 = Theme.green
            UI.targetLabel.Text = "> target: " .. State.target.Name
            UI.targetLabel.TextColor3 = Theme.green
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
    
    local newTarget = FindTarget()
    if newTarget then
        State.target = newTarget
        State.lostTimer = 0
        State.targetCF = nil
        State.smoothCF = nil
        
        UI.status.Text = "> locked: " .. newTarget.Name
        UI.status.TextColor3 = Theme.green
        UI.targetLabel.Text = "> target: " .. newTarget.Name
        UI.targetLabel.TextColor3 = Theme.green
        UI:Log("target: " .. newTarget.Name)
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
        
        UI.status.Text = "> searching..."
        UI.status.TextColor3 = Theme.amber
        UI.targetLabel.Text = "> target: none"
        UI.targetLabel.TextColor3 = Theme.textMuted
    end
end

-- Обработчики событий

local function ToggleAim()
    State.enabled = not State.enabled
    
    if State.enabled then
        UI.btnToggle.Text = "> stop"
        UI.btnToggle.TextColor3 = Theme.red
        UI.status.Text = "> active"
        UI.status.TextColor3 = Theme.green
        UI.crosshair.Visible = true
        UI.fov.Visible = true
        UI:Log("aim started")
        
        if not XRay.container then
            XRay.container = Instance.new("Folder")
            XRay.container.Name = "XRay"
            XRay.container.Parent = UI.gui
        end
    else
        UI.btnToggle.Text = "> start"
        UI.btnToggle.TextColor3 = Theme.green
        UI.status.Text = "> offline"
        UI.status.TextColor3 = Theme.textMuted
        UI.targetLabel.Text = "> target: none"
        UI.targetLabel.TextColor3 = Theme.textMuted
        UI.crosshair.Visible = false
        UI.fov.Visible = false
        UI:Log("aim stopped")
        
        State.target = nil
        State.targetCF = nil
        State.smoothCF = nil
        
        for plr in pairs(XRay.boxes) do
            if XRay.boxes[plr] and XRay.boxes[plr].box then
                XRay.boxes[plr].box:Destroy()
            end
            XRay.boxes[plr] = nil
        end
        if XRay.container then
            XRay.container:Destroy()
            XRay.container = nil
        end
    end
end

local function SwitchAim()
    if Config.AimPart == "Head" then
        Config.AimPart = "HumanoidRootPart"
        Config.BackupPart = "Torso"
        UI.btnAim.Text = "> switch: body"
        UI:Log("aim: body")
    else
        Config.AimPart = "Head"
        Config.BackupPart = "UpperTorso"
        UI.btnAim.Text = "> switch: head"
        UI:Log("aim: head")
    end
end

local function ToggleXRay()
    XRay.enabled = not XRay.enabled
    UI.btnXRay.Text = XRay.enabled and "> x-ray: on" or "> x-ray: off"
    UI:Log("x-ray: " .. (XRay.enabled and "on" or "off"))
    
    if not XRay.enabled then
        for plr in pairs(XRay.boxes) do
            if XRay.boxes[plr] and XRay.boxes[plr].box then
                XRay.boxes[plr].box:Destroy()
            end
            XRay.boxes[plr] = nil
        end
        if XRay.container then
            XRay.container:Destroy()
            XRay.container = nil
        end
    elseif not XRay.container then
        XRay.container = Instance.new("Folder")
        XRay.container.Name = "XRay"
        XRay.container.Parent = UI.gui
    end
end

-- Подключение событий

UI.btnToggle.MouseButton1Click:Connect(ToggleAim)
UI.btnAim.MouseButton1Click:Connect(SwitchAim)
UI.btnXRay.MouseButton1Click:Connect(ToggleXRay)
UI.btnFriend.MouseButton1Click:Connect(ShowFriendSelector)

UI.closeBtn.MouseButton1Click:Connect(function()
    UI.gui:Destroy()
end)

UI.minBtn.MouseButton1Click:Connect(function()
    local state = UI.main.Visible
    UI.main.Visible = not state
    UI:Log(state and "hidden" or "shown")
end)

UI.maxBtn.MouseButton1Click:Connect(function()
    UI:Log("maximize not implemented")
end)

-- Клавиши
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.One then
        ToggleAim()
    elseif input.KeyCode == Enum.KeyCode.Two then
        SwitchAim()
    elseif input.KeyCode == Enum.KeyCode.Three then
        ToggleXRay()
    elseif input.KeyCode == Enum.KeyCode.Four then
        ShowFriendSelector()
    end
end)

-- Хуйня для очистки
local function Cleanup()
    UI.gui:Destroy()
    if XRay.container then XRay.container:Destroy() end
end

UI.btnExit.MouseButton1Click:Connect(Cleanup)

-- Обновляем список друзей при загрузке
UI:UpdateFriendList()
UI.btnFriend.Text = "> friends (" .. #State.friends .. ")"

-- Уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nova v2.54",
    Text = "1 - start/stop | 2 - switch aim | 3 - x-ray | 4 - friends",
    Duration = 4
})

-- Основной циклRunService.RenderStepped:Connect(function(dt)
    pcall(Update, dt)
end)

UI:Log("ready! press 4 or click friends button")
