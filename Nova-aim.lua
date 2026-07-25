-- Nova v2.55
-- Бля, зачем я это делаю вообще?

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- чистим хуйню старую
if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- цвета, бля
local Theme = {
    bg = Color3.fromRGB(10, 10, 12),
    surface = Color3.fromRGB(20, 20, 25),
    surfaceHi = Color3.fromRGB(30, 30, 35),
    accent = Color3.fromRGB(0, 200, 100),
    text = Color3.fromRGB(180, 220, 200),
    textMuted = Color3.fromRGB(100, 130, 110),
    red = Color3.fromRGB(255, 80, 80),
    green = Color3.fromRGB(80, 255, 130),
    amber = Color3.fromRGB(255, 200, 50),
    cursor = Color3.fromRGB(0, 255, 100),
    pythonBlue = Color3.fromRGB(50, 120, 255),
    pythonYellow = Color3.fromRGB(255, 210, 50),
}

local FONT = Enum.Font.SourceSans
local FONT_BOLD = Enum.Font.SourceSansBold

-- состояние, нахуй
local State = {
    enabled = false,
    target = nil,
    targetCF = nil,
    smoothCF = nil,
    friends = {},
    hue = 0,
    lostTimer = 0,
    searchTimer = 0,
    xrayTimer = 0,
}

-- X-Ray хуйня
local XRay = {
    enabled = true,
    boxes = {},
    container = nil,
}

-- настройки, пиздец
local Config = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 60,
    Smoothness = 0.85,
    Distance = 250,
}

-- скругление для кнопок, бля
local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

-- проверка жив ли, ебать
local function IsAlive(plr)
    if not plr or not plr.Parent then return false end
    if not plr.Character or not plr.Character.Parent then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

-- друг или нет, хуй знает
local function IsFriend(plr)
    if not plr then return false end
    for _, f in ipairs(State.friends) do
        if f == plr then return true end
    end
    return false
end

-- аватарки, заебало
local function MakeAvatar(plr, size)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, size, 0, size)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    container.ClipsDescendants = true
    container.BorderSizePixel = 0
    Round(container, 999)
    
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    img.ScaleType = Enum.ScaleType.Fit
    img.BorderSizePixel = 0
    pcall(function()
        img.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    img.Parent = container
    Round(img, 999)
    return container
end

-- загрузочный экран, пиздец
local Boot = {}

function Boot:Create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaBoot"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 9999
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Theme.bg
    bg.BorderSizePixel = 0
    bg.Parent = gui
    
    -- шапка Termux, нахуй
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = bg
    
    local termText = Instance.new("TextLabel")
    termText.Size = UDim2.new(1, -20, 1, 0)
    termText.Position = UDim2.new(0, 12, 0, 0)
    termText.BackgroundTransparency = 1
    termText.Text = "Termux | Python 3.11.5"
    termText.TextColor3 = Theme.textMuted
    termText.TextSize = 13
    termText.Font = FONT
    termText.TextXAlignment = Enum.TextXAlignment.Left
    termText.Parent = header
    
    -- консоль, бля
    local console = Instance.new("ScrollingFrame")
    console.Size = UDim2.new(1, -40, 1, -80)
    console.Position = UDim2.new(0, 20, 0, 48)
    console.BackgroundColor3 = Theme.bg
    console.BackgroundTransparency = 1
    console.BorderSizePixel = 0
    console.ScrollBarThickness = 3
    console.ScrollBarImageColor3 = Theme.textMuted
    console.ScrollBarImageTransparency = 0.3
    console.Parent = bg
    
    local consoleText = Instance.new("TextLabel")
    consoleText.Size = UDim2.new(1, -10, 1, -10)
    consoleText.Position = UDim2.new(0, 5, 0, 5)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = ""
    consoleText.TextColor3 = Theme.text
    consoleText.TextSize = 13
    consoleText.Font = FONT
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.RichText = true
    consoleText.LineHeight = 1.3
    consoleText.Parent = console
    
    -- строка ввода, заебали
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0, 500, 0, 34)
    inputFrame.Position = UDim2.new(0, 20, 1, -46)
    inputFrame.BackgroundColor3 = Theme.surfaceHi
    inputFrame.BackgroundTransparency = 0.5
    inputFrame.BorderSizePixel = 0
    inputFrame.Visible = false
    inputFrame.Parent = bg
    Round(inputFrame, 6)
    
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Size = UDim2.new(0, 24, 1, 0)
    inputLabel.Position = UDim2.new(0, 8, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "$"
    inputLabel.TextColor3 = Theme.accent
    inputLabel.TextSize = 14
    inputLabel.Font = FONT_BOLD
    inputLabel.Parent = inputFrame
    
    local inputField = Instance.new("TextBox")
    inputField.Size = UDim2.new(1, -36, 1, 0)
    inputField.Position = UDim2.new(0, 30, 0, 0)
    inputField.BackgroundTransparency = 1
    inputField.Text = ""
    inputField.TextColor3 = Theme.text
    inputField.TextSize = 14
    inputField.Font = FONT
    inputField.TextXAlignment = Enum.TextXAlignment.Left
    inputField.ClearTextOnFocus = false
    inputField.Parent = inputFrame
    
    -- курсор, ебаный
    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 2, 0, 18)
    cursor.Position = UDim2.new(0, 0, 0.5, -9)
    cursor.BackgroundColor3 = Theme.cursor
    cursor.BorderSizePixel = 0
    cursor.Parent = inputFrame
    cursor.Visible = true
    
    -- прогресс бар, нахуй
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 300, 0, 3)
    progressBg.Position = UDim2.new(0.5, -150, 1, -20)
    progressBg.BackgroundColor3 = Theme.surfaceHi
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg
    Round(progressBg, 2)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Theme.accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    Round(progressFill, 2)
    
    function Boot:Log(msg, color)
        local current = consoleText.Text
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        consoleText.Text = current .. colorHex .. "[" .. time .. "] " .. msg .. reset .. "\n"
        console.CanvasPosition = Vector2.new(0, consoleText.TextBounds.Y)
    end
    
    function Boot:UpdateProgress(pct)
        progressFill.Size = UDim2.new(pct, 0, 1, 0)
    end
    
    function Boot:ShowInput()
        inputFrame.Visible = true
        task.wait(0.2)
        inputField:CaptureFocus()
    end
    
    -- ввод, ебать
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputField.Text ~= "" then
            local cmd = inputField.Text
            inputField.Text = ""
            Boot:Log("> " .. cmd, Theme.amber)
            
            if cmd:lower() == "start" then
                Boot:Log("запуск Nova, погнали", Theme.green)
                task.wait(0.5)
                StartNova()
            elseif cmd:lower() == "help" then
                Boot:Log("команды, бля:", Theme.amber)
                Boot:Log("  start - запустить Nova", Theme.textMuted)
                Boot:Log("  help - помощь", Theme.textMuted)
                Boot:Log("  exit - выйти нахуй", Theme.textMuted)
            elseif cmd:lower() == "exit" then
                Boot:Log("выход, пока", Theme.red)
                task.wait(0.5)
                gui:Destroy()
            else
                Boot:Log("хуйня какая-то, введи help", Theme.red)
            end
        end
    end)
    
    -- для телефона, бля
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and inputFrame.Visible then
            inputField:CaptureFocus()
        end
    end)
    
    -- анимация курсора, заебало
    task.spawn(function()
        local blink = true
        while gui and gui.Parent do
            blink = not blink
            cursor.Visible = blink and inputField:IsFocused()
            task.wait(0.5)
        end
    end)
    
    Boot.gui = gui
    Boot.consoleText = consoleText
    Boot.inputField = inputField
    return gui
end

Boot:Create()

-- сообщения для загрузки, хуйня
local BootMessages = {
    "инициализация ядра, бля",
    "загрузка модулей, ебать",
    "подключение к библиотекам",
    "настройка окружения",
    "проверка файлов, пиздец",
    "загрузка конфига",
    "активация протоколов",
    "синхронизация, нахуй",
    "подготовка интерфейса",
    "загрузка шрифтов",
    "инициализация графики",
    "проверка обновлений",
    "загрузка драйверов",
    "настройка безопасности",
    "оптимизация, заебало",
    "загрузка служб",
    "активация ядра",
    "подключение к серверам",
    "загрузка данных",
    "финальная настройка, пиздец",
}

-- запускаем загрузку, бля
task.spawn(function()
    Boot:Log("Termux environment, погнали", Theme.green)
    Boot:Log("Python 3.11.5 (Nova framework)", Theme.pythonYellow)
    Boot:Log("")
    
    local shuffled = {}
    for i, msg in ipairs(BootMessages) do
        table.insert(shuffled, msg)
    end
    
    local steps = math.random(8, 15)
    local totalTime = math.random(10, 30)
    local stepTime = totalTime / steps
    
    for i = 1, steps do
        local idx = math.random(1, #shuffled)
        local msg = shuffled[idx]
        table.remove(shuffled, idx)
        if #shuffled == 0 then break end
        
        local progress = i / steps
        Boot:UpdateProgress(progress)
        Boot:Log(msg, Theme.textMuted)
        
        local delay = stepTime * (0.7 + math.random() * 0.6)
        task.wait(delay)
    end
    
    Boot:UpdateProgress(1)
    Boot:Log("")
    Boot:Log("загрузка завершена, бля", Theme.green)
    Boot:Log("система готова, нахуй", Theme.green)
    Boot:Log("")
    Boot:Log("введи start чтобы запустить", Theme.amber)
    Boot:Log("введи help чтобы посмотреть команды", Theme.amber)
    
    Boot:ShowInput()
end)

-- основной интерфейс, пиздец
local NovaUI = {}

function NovaUI:Create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaMain"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 999
    gui.Enabled = false
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 440, 0, 400)
    main.Position = UDim2.new(0.5, -220, 0.5, -200)
    main.BackgroundColor3 = Theme.bg
    main.BackgroundTransparency = 0.03
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    Round(main, 14)
    
    -- свечение
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 4, 1, 4)
    glow.Position = UDim2.new(0, -2, 0, -2)
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 2
    glow.BorderColor3 = Theme.accent
    glow.BorderTransparency = 0.5
    glow.Parent = main
    Round(glow, 16)
    
    -- шапка Python стиль
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = main
    Round(header, 14)
    
    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0.5, -10)
    icon.BackgroundColor3 = Theme.pythonBlue
    icon.BorderSizePixel = 2
    icon.BorderColor3 = Theme.pythonYellow
    icon.Parent = header
    Round(icon, 4)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 40, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Nova v2.55 — Python IDE"
    title.TextColor3 = Theme.text
    title.TextSize = 14
    title.Font = FONT_BOLD
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- кнопки окна (точки)
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
    
    -- статус
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 22)
    status.Position = UDim2.new(0, 10, 0, 48)
    status.BackgroundTransparency = 1
    status.Text = "> offline"
    status.TextColor3 = Theme.textMuted
    status.TextSize = 13
    status.Font = FONT
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main
    
    -- цель
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -20, 0, 20)
    targetLabel.Position = UDim2.new(0, 10, 0, 70)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "> target: none"
    targetLabel.TextColor3 = Theme.textMuted
    targetLabel.TextSize = 12
    targetLabel.Font = FONT
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = main
    
    -- кнопки
    local function MakeBtn(text, y, col)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 32)
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
    
    local btnToggle = MakeBtn("> start", 100, Theme.green)
    local btnAim = MakeBtn("> switch: head", 138, Theme.accent)
    local btnXRay = MakeBtn("> x-ray: on", 176, Theme.accent)
    local btnFriend = MakeBtn("> friends (0)", 214, Theme.amber)
    local btnExit = MakeBtn("> exit", 252, Theme.red)
    
    -- консоль
    local console = Instance.new("Frame")
    console.Size = UDim2.new(1, -20, 0, 30)
    console.Position = UDim2.new(0, 10, 0, 290)
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
    
    -- FOV
    local fov = Instance.new("ImageLabel")
    fov.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
    fov.Position = UDim2.new(0.5, -Config.FOV, 0.5, -Config.FOV)
    fov.BackgroundTransparency = 1
    fov.Image = "rbxassetid://4911621264"
    fov.ImageColor3 = Theme.text
    fov.ImageTransparency = 0.5
    fov.Visible = false
    fov.Parent = gui
    
    -- прицел
    local crosshair = Instance.new("Frame")
    crosshair.Size = UDim2.new(0, 4, 0, 4)
    crosshair.Position = UDim2.new(0.5, -2, 0.5, -2)
    crosshair.BackgroundColor3 = Theme.text
    crosshair.BorderSizePixel = 0
    crosshair.Visible = false
    crosshair.Parent = gui
    Round(crosshair, 999)
    
    -- друзья окно
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
    friendTitle.Font = FONT_BOLD
    friendTitle.TextXAlignment = Enum.TextXAlignment.Left
    friendTitle.Parent = friendHeader
    
    local friendClose = Instance.new("Frame")
    friendClose.Size = UDim2.new(0, 12, 0, 12)
    friendClose.Position = UDim2.new(1, -24, 0.5, -6)
    friendClose.BackgroundColor3 = Theme.red
    friendClose.BorderSizePixel = 0
    friendClose.Parent = friendHeader
    Round(friendClose, 999)
    
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
    
    function NovaUI:UpdateFriendList()
        for _, child in pairs(playerList:GetChildren()) do
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
            empty.Text = "> no players found"
            empty.TextColor3 = Theme.textMuted
            empty.TextSize = 12
            empty.Font = FONT
            empty.Parent = playerList
            playerList.CanvasSize = UDim2.new(0, 0, 0, 40)
            return
        end
        
        table.sort(players, function(a, b) return a.Name < b.Name end)
        
        for _, plr in ipairs(players) do
            local isFriend = IsFriend(plr)
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = isFriend and Color3.fromRGB(20, 60, 30) or Theme.surface
            btn.BackgroundTransparency = isFriend and 0.7 or 0.3
            btn.BorderSizePixel = 0
            btn.Parent = playerList
            Round(btn, 6)
            
            local avatar = MakeAvatar(plr, 32)
            avatar.Position = UDim2.new(0, 4, 0.5, -16)
            avatar.Parent = btn
            
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
            
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Size = UDim2.new(0, 30, 1, 0)
            statusIcon.Position = UDim2.new(1, -34, 0, 0)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Text = isFriend and "✓" or "+"
            statusIcon.TextColor3 = isFriend and Theme.green or Theme.textMuted
            statusIcon.TextSize = 16
            statusIcon.Font = FONT
            statusIcon.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                if isFriend then
                    for i, f in ipairs(State.friends) do
                        if f == plr then
                            table.remove(State.friends, i)
                            break
                        end
                    end
                    NovaUI:Log("removed: " .. plr.Name)
                    NovaUI.btnFriend.Text = "> friends (" .. #State.friends .. ")"
                    NovaUI:UpdateFriendList()
                else
                    table.insert(State.friends, plr)
                    NovaUI:Log("added: " .. plr.Name)
                    NovaUI.btnFriend.Text = "> friends (" .. #State.friends .. ")"
                    NovaUI:UpdateFriendList()
                end
            end)
            
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
        
        task.wait()
        playerList.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y + 10)
    end
    
    friendClose.MouseButton1Click:Connect(function()
        friendWindow.Visible = false
    end)
    
    function NovaUI:Log(msg)
        if self.consoleText then
            self.consoleText.Text = "> " .. msg
        end
    end
    
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
        UpdateFriendList = NovaUI.UpdateFriendList,
        Log = NovaUI.Log,
    }
end

NovaUI = NovaUI:Create()

function StartNova()
    Boot.gui.Enabled = false
    Boot.gui:Destroy()
    
    NovaUI.gui.Enabled = true
    
    -- анимация появления
    NovaUI.main.Size = UDim2.new(0, 200, 0, 200)
    NovaUI.main.Position = UDim2.new(0.5, -100, 0.5, -100)
    NovaUI.main.BackgroundTransparency = 1
    
    local tween1 = TweenService:Create(NovaUI.main, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 440, 0, 400),
        Position = UDim2.new(0.5, -220, 0.5, -200),
        BackgroundTransparency = 0.03,
    })
    tween1:Play()
    
    NovaUI:UpdateFriendList()
    NovaUI.btnFriend.Text = "> friends (" .. #State.friends .. ")"
    NovaUI:Log("ready! press 1 or click start")
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nova v2.55",
        Text = "1 - start/stop | 2 - switch aim | 3 - x-ray | 4 - friends",
        Duration = 4
    })
end

-- ============================================
-- АИМ ЛОГИКА, ПИЗДЕЦ
-- ============================================

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

-- основной цикл
local function Update(dt)
    if not Camera or not NovaUI.gui.Enabled then return end
    
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
    
    -- аим
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
            
            NovaUI.status.Text = "> locked: " .. State.target.Name
            NovaUI.status.TextColor3 = Theme.green
            NovaUI.targetLabel.Text = "> target: " .. State.target.Name
            NovaUI.targetLabel.TextColor3 = Theme.green
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
        
        NovaUI.status.Text = "> locked: " .. newTarget.Name
        NovaUI.status.TextColor3 = Theme.green
        NovaUI.targetLabel.Text = "> target: " .. newTarget.Name
        NovaUI.targetLabel.TextColor3 = Theme.green
        NovaUI:Log("target: " .. newTarget.Name)
    else
        if State.target then
            State.target = nil
            State.targetCF = nil
            State.smoothCF = nil
        end
        
        NovaUI.status.Text = "> searching..."
        NovaUI.status.TextColor3 = Theme.amber
        NovaUI.targetLabel.Text = "> target: none"
        NovaUI.targetLabel.TextColor3 = Theme.textMuted
    end
end

-- обработчики событий
local function ToggleAim()
    State.enabled = not State.enabled
    
    if State.enabled then
        NovaUI.btnToggle.Text = "> stop"
        NovaUI.btnToggle.TextColor3 = Theme.red
        NovaUI.status.Text = "> active"
        NovaUI.status.TextColor3 = Theme.green
        NovaUI.crosshair.Visible = true
        NovaUI.fov.Visible = true
        NovaUI:Log("aim started")
        
        if not XRay.container then
            XRay.container = Instance.new("Folder")
            XRay.container.Name = "XRay"
            XRay.container.Parent = NovaUI.gui
        end
    else
        NovaUI.btnToggle.Text = "> start"
        NovaUI.btnToggle.TextColor3 = Theme.green
        NovaUI.status.Text = "> offline"
        NovaUI.status.TextColor3 = Theme.textMuted
        NovaUI.targetLabel.Text = "> target: none"
        NovaUI.targetLabel.TextColor3 = Theme.textMuted
        NovaUI.crosshair.Visible = false
        NovaUI.fov.Visible = false
        NovaUI:Log("aim stopped")
        
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
        NovaUI.btnAim.Text = "> switch: body"
        NovaUI:Log("aim: body")
    else
        Config.AimPart = "Head"
        Config.BackupPart = "UpperTorso"
        NovaUI.btnAim.Text = "> switch: head"
        NovaUI:Log("aim: head")
    end
end

local function ToggleXRay()
    XRay.enabled = not XRay.enabled
    NovaUI.btnXRay.Text = XRay.enabled and "> x-ray: on" or "> x-ray: off"
    NovaUI:Log("x-ray: " .. (XRay.enabled and "on" or "off"))
    
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
        XRay.container.Parent = NovaUI.gui
    end
end

local function ShowFriendSelector()
    NovaUI.friendWindow.Visible = not NovaUI.friendWindow.Visible
    if NovaUI.friendWindow.Visible then
        NovaUI:UpdateFriendList()
        NovaUI:Log("friends manager opened")
    else
        NovaUI:Log("friends manager closed")
    end
end

-- привязка кнопок
NovaUI.btnToggle.MouseButton1Click:Connect(ToggleAim)
NovaUI.btnAim.MouseButton1Click:Connect(SwitchAim)
NovaUI.btnXRay.MouseButton1Click:Connect(ToggleXRay)
NovaUI.btnFriend.MouseButton1Click:Connect(ShowFriendSelector)

NovaUI.closeBtn.MouseButton1Click:Connect(function()
    NovaUI.gui:Destroy()
    if XRay.container then XRay.container:Destroy() end
end)

NovaUI.minBtn.MouseButton1Click:Connect(function()
    local state = NovaUI.main.Visible
    NovaUI.main.Visible = not state
    NovaUI:Log(state and "hidden" or "shown")
end)

NovaUI.maxBtn.MouseButton1Click:Connect(function()
    NovaUI:Log("maximize not implemented")
end)

NovaUI.btnExit.MouseButton1Click:Connect(function()
    NovaUI.gui:Destroy()
    if XRay.container then XRay.container:Destroy() end
end)

-- горячие клавиши
UserInputService.InputBegan:Connect(function(input)
    if not NovaUI.gui.Enabled then return end
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

-- запускаем цикл
RunService.RenderStepped:Connect(function(dt)
    pcall(Update, dt)
end)

print("Nova v2.55 загружена, бля!")
