-- Nova v2.55
-- Загрузочный экран в стиле Termux, бля

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

-- Чистим мусор
if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- Тема как в терминале
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
}

local FONT = Enum.Font.SourceSans

-- Состояние загрузки
local BootState = {
    phase = 0, -- 0=загрузка, 1=готов, 2=запущен
    ready = false,
    animating = false,
    termuxActive = false,
    inputBuffer = "",
    cursorBlink = false,
    cursorTimer = 0,
    startupProgress = 0,
    showCursor = true,
}

-- ============================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН (Termux стиль)
-- ============================================

local function CreateBootScreen()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaBoot"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 9999
    
    -- Чёрный фон как в терминале
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Theme.bg
    bg.BorderSizePixel = 0
    bg.Parent = gui
    
    -- Иконка Termux (просто зелёный квадрат с буквой >)
    local termIcon = Instance.new("Frame")
    termIcon.Size = UDim2.new(0, 60, 0, 60)
    termIcon.Position = UDim2.new(0.5, -30, 0.3, -30)
    termIcon.BackgroundColor3 = Theme.accent
    termIcon.BackgroundTransparency = 0.9
    termIcon.BorderSizePixel = 2
    termIcon.BorderColor3 = Theme.accent
    termIcon.Parent = bg
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = termIcon
    
    local termLabel = Instance.new("TextLabel")
    termLabel.Size = UDim2.new(1, 0, 1, 0)
    termLabel.BackgroundTransparency = 1
    termLabel.Text = ">"
    termLabel.TextColor3 = Theme.accent
    termLabel.TextSize = 32
    termLabel.Font = FONT
    termLabel.Parent = termIcon
    
    -- Консольный вывод
    local console = Instance.new("ScrollingFrame")
    console.Size = UDim2.new(0, 400, 0, 200)
    console.Position = UDim2.new(0.5, -200, 0.5, -50)
    console.BackgroundColor3 = Theme.surface
    console.BackgroundTransparency = 0.3
    console.BorderSizePixel = 1
    console.BorderColor3 = Theme.textMuted
    console.BorderSizePixel = 1
    console.Parent = bg
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 4)
    consoleCorner.Parent = console
    
    -- Заголовок консоли
    local consoleHeader = Instance.new("Frame")
    consoleHeader.Size = UDim2.new(1, 0, 0, 24)
    consoleHeader.BackgroundColor3 = Theme.surfaceHi
    consoleHeader.BackgroundTransparency = 0.5
    consoleHeader.BorderSizePixel = 0
    consoleHeader.Parent = console
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 4)
    headerCorner.Parent = consoleHeader
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -20, 1, 0)
    headerText.Position = UDim2.new(0, 8, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "termux >"
    headerText.TextColor3 = Theme.text
    headerText.TextSize = 11
    headerText.Font = FONT
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = consoleHeader
    
    local headerClose = Instance.new("TextLabel")
    headerClose.Size = UDim2.new(0, 20, 1, 0)
    headerClose.Position = UDim2.new(1, -24, 0, 0)
    headerClose.BackgroundTransparency = 1
    headerClose.Text = "✕"
    headerClose.TextColor3 = Theme.red
    headerClose.TextSize = 12
    headerClose.Font = FONT
    headerClose.Parent = consoleHeader
    
    -- Текст консоли
    local consoleText = Instance.new("TextLabel")
    consoleText.Size = UDim2.new(1, -16, 1, -30)
    consoleText.Position = UDim2.new(0, 8, 0, 28)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = ""
    consoleText.TextColor3 = Theme.text
    consoleText.TextSize = 13
    consoleText.Font = FONT
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.RichText = true
    consoleText.LineHeight = 1.2
    consoleText.Parent = console
    
    -- Строка ввода (Termux стиль)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -16, 0, 28)
    inputFrame.Position = UDim2.new(0, 8, 1, -32)
    inputFrame.BackgroundColor3 = Theme.surfaceHi
    inputFrame.BackgroundTransparency = 0.5
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = console
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputFrame
    
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Size = UDim2.new(1, -20, 1, 0)
    inputLabel.Position = UDim2.new(0, 6, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "$ "
    inputLabel.TextColor3 = Theme.accent
    inputLabel.TextSize = 13
    inputLabel.Font = FONT
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Parent = inputFrame
    
    local inputField = Instance.new("TextBox")
    inputField.Size = UDim2.new(1, -30, 1, 0)
    inputField.Position = UDim2.new(0, 18, 0, 0)
    inputField.BackgroundTransparency = 1
    inputField.Text = ""
    inputField.TextColor3 = Theme.text
    inputField.TextSize = 13
    inputField.Font = FONT
    inputField.TextXAlignment = Enum.TextXAlignment.Left
    inputField.ClearTextOnFocus = false
    inputField.Parent = inputFrame
    
    -- Курсор мигающий
    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 2, 0, 16)
    cursor.Position = UDim2.new(0, 0, 0.5, -8)
    cursor.BackgroundColor3 = Theme.cursor
    cursor.BorderSizePixel = 0
    cursor.Parent = inputFrame
    cursor.Visible = true
    
    -- Полоса загрузки
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 300, 0, 4)
    progressBar.Position = UDim2.new(0.5, -150, 0.85, 0)
    progressBar.BackgroundColor3 = Theme.surfaceHi
    progressBar.BorderSizePixel = 0
    progressBar.Parent = bg
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = progressBar
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.accent
    barFill.BorderSizePixel = 0
    barFill.Parent = progressBar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = barFill
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0, 300, 0, 20)
    statusText.Position = UDim2.new(0.5, -150, 0.88, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "загрузка..."
    statusText.TextColor3 = Theme.textMuted
    statusText.TextSize = 11
    statusText.Font = FONT
    statusText.Parent = bg
    
    -- Анимация иконки Termux (пульсация)
    local pulse = TweenService:Create(termIcon, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.7
    })
    pulse:Play()
    
    -- Функция вывода в консоль
    function ConsoleLog(msg, color)
        local current = consoleText.Text
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        consoleText.Text = current .. colorHex .. time .. " " .. msg .. reset .. "\n"
        console.CanvasPosition = Vector2.new(0, consoleText.TextBounds.Y)
    end
    
    -- Функция обновления прогресса
    function UpdateProgress(pct, msg)
        barFill.Size = UDim2.new(pct, 0, 1, 0)
        statusText.Text = msg
    end
    
    -- Ввод с клавиатуры
    inputField.Focused:Connect(function()
        BootState.termuxActive = true
        if UserInputService.TouchEnabled then
            inputField:CaptureFocus()
        end
    end)
    
    inputField.FocusLost:Connect(function()
        BootState.termuxActive = false
    end)
    
    inputField:GetPropertyChangedSignal("Text"):Connect(function()
        local text = inputField.Text
        if text:sub(1, 2) == "$ " then
            text = text:sub(3)
        end
        BootState.inputBuffer = text
    end)
    
    -- Обработка ввода
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed and BootState.inputBuffer ~= "" then
            local cmd = BootState.inputBuffer
            inputField.Text = ""
            BootState.inputBuffer = ""
            
            if BootState.phase == 1 then
                if cmd:lower() == "y" then
                    BootState.ready = true
                    ConsoleLog("> запуск...", Theme.green)
                    StartNova()
                elseif cmd:lower() == "n" then
                    ConsoleLog("> отмена. Перезапустите скрипт.", Theme.amber)
                else
                    ConsoleLog("> введите y или n", Theme.red)
                end
            end
        end
    end)
    
    -- Для мобильных: клик по экрану вызывает клавиатуру
    local function ShowKeyboard()
        if BootState.phase == 1 then
            inputField:CaptureFocus()
            inputField:ReleaseFocus()
            inputField:CaptureFocus()
        end
    end
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            ShowKeyboard()
        end
    end)
    
    -- Обновление курсора
    task.spawn(function()
        while gui and gui.Parent do
            BootState.cursorTimer = BootState.cursorTimer + 0.5
            BootState.cursorBlink = not BootState.cursorBlink
            cursor.Visible = BootState.cursorBlink and inputField:IsFocused()
            task.wait(0.5)
        end
    end)
    
    return {
        gui = gui,
        consoleText = consoleText,
        progressBar = barFill,
        statusText = statusText,
        inputField = inputField,
        cursor = cursor,
        ConsoleLog = ConsoleLog,
        UpdateProgress = UpdateProgress,
        bg = bg,
        termIcon = termIcon,
    }
end

local Boot = CreateBootScreen()

-- ============================================
-- ОСНОВНОЙ СОФТ (Nova)
-- ============================================

local NovaState = {
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
}

local XRay = {
    enabled = true,
    boxes = {},
    container = nil,
}

local Config = {
    AimPart = "Head",
    BackupPart = "UpperTorso",
    FOV = 60,
    Smoothness = 0.85,
    Distance = 250,
}

-- Вспомогательные функции
local function IsAlive(plr)
    if not plr or not plr.Parent then return false end
    if not plr.Character or not plr.Character.Parent then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function IsFriend(plr)
    if not plr then return false end
    for _, f in ipairs(NovaState.friends) do
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

-- Создание основного интерфейса
local UI = {}

function UI:Build()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaMain"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 999
    gui.Enabled = false
    
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
    
    -- Кнопки (точки)
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
    
    -- Консоль
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
    
    -- Окно друзей
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
    
    function UI:UpdateFriendList()
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
                    for i, f in ipairs(NovaState.friends) do
                        if f == plr then
                            table.remove(NovaState.friends, i)
                            break
                        end
                    end
                    UI:Log("removed: " .. plr.Name)
                    UI.btnFriend.Text = "> friends (" .. #NovaState.friends .. ")"
                    UI:UpdateFriendList()
                else
                    table.insert(NovaState.friends, plr)
                    UI:Log("added: " .. plr.Name)
                    UI.btnFriend.Text = "> friends (" .. #NovaState.friends .. ")"
                    UI:UpdateFriendList()
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
        UpdateFriendList = UI.UpdateFriendList,
        Log = function(self, msg)
            if self.consoleText then
                self.consoleText.Text = "> " .. msg
            end
        end,
    }
end

local NovaUI = UI:Build()

-- ============================================
-- ЗАПУСК СОФТА (после загрузки)
-- ============================================

function StartNova()
    Boot.gui.Enabled = false
    Boot.gui:Destroy()
    
    NovaUI.gui.Enabled = true
    
    -- Анимация появления
    NovaUI.main.Size = UDim2.new(0, 200, 0, 200)
    NovaUI.main.Position = UDim2.new(0.5, -100, 0.5, -100)
    NovaUI.main.BackgroundTransparency = 1
    
    local tween1 = TweenService:Create(NovaUI.main, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 420, 0, 380),
        Position = UDim2.new(0.5, -210, 0.5, -190),
        BackgroundTransparency = 0.03,
    })
    tween1:Play()
    
    NovaUI:UpdateFriendList()
    NovaUI.btnFriend.Text = "> friends (" .. #NovaState.friends .. ")"
    NovaUI:Log("ready! press 1 or click start")
end

-- ============================================
-- ЗАГРУЗКА (Boot Sequence)
-- ============================================

local bootMessages = {
    {msg = "инициализация системы...", progress = 0.05},
    {msg = "подключение к ядру...", progress = 0.15},
    {msg = "загрузка модулей...", progress = 0.30},
    {msg = "настройка окружения...", progress = 0.45},
    {msg = "проверка конфигурации...", progress = 0.60},
    {msg = "активация интерфейса...", progress = 0.75},
    {msg = "готов к запуску!", progress = 0.90},
}

task.spawn(function()
    Boot.ConsoleLog("> termux v2.55")
    Boot.ConsoleLog("> nova system initializing...", Theme.textMuted)
    
    for i, step in ipairs(bootMessages) do
        Boot.UpdateProgress(step.progress, step.msg)
        Boot.ConsoleLog("> " .. step.msg, Theme.textMuted)
        task.wait(0.3 + math.random() * 0.2)
    end
    
    Boot.UpdateProgress(0.95, "ожидание ввода...")
    Boot.ConsoleLog("")
    Boot.ConsoleLog("> система готова", Theme.green)
    Boot.ConsoleLog("> запустить софт? (y/n)", Theme.amber)
    Boot.phase = 1
    
    -- Фокус на поле ввода для телефона
    task.wait(0.5)
    Boot.inputField:CaptureFocus()
    
    -- Ожидание ввода y/n
    while Boot.phase == 1 and not BootState.ready do
        task.wait(0.1)
    end
    
    if BootState.ready then
        Boot.UpdateProgress(1.0, "запуск...")
        task.wait(0.5)
        StartNova()
    end
end)

-- ============================================
-- АИМ ЛОГИКА (работает после запуска)
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

-- Основной цикл обновления
local function Update(dt)
    if not Camera or not NovaUI.gui.Enabled then return end
    
    -- X-Ray обновление
    if XRay.enabled then
        NovaState.hue = (NovaState.hue + dt * 0.15) % 1
        NovaState.xrayTimer = NovaState.xrayTimer + dt
        
        if NovaState.xrayTimer >= 0.03 then
            NovaState.xrayTimer = 0
            
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
                    UpdateBox(plr, NovaState.hue)
                end
            end
        end
    end
    
    if not NovaState.enabled then return end
    
    -- Аим логика
    NovaState.searchTimer = NovaState.searchTimer + dt
    
    if NovaState.target and IsAlive(NovaState.target) and not IsFriend(NovaState.target) then
        local part = GetPart(NovaState.target)
        if part and IsVisible(NovaState.target) then
            NovaState.lostTimer = 0
            local pos = part.Position
            NovaState.targetCF = CFrame.lookAt(Camera.CFrame.Position, pos)
            
            if NovaState.targetCF then
                NovaState.smoothCF = NovaState.smoothCF and NovaState.smoothCF:Lerp(NovaState.targetCF, Config.Smoothness) or NovaState.targetCF
                Camera.CFrame = NovaState.smoothCF
            end
            
            NovaUI.status.Text = "> locked: " .. NovaState.target.Name
            NovaUI.status.TextColor3 = Theme.green
            NovaUI.targetLabel.Text = "> target: " .. NovaState.target.Name
            NovaUI.targetLabel.TextColor3 = Theme.green
            return
        end
        
        NovaState.lostTimer = NovaState.lostTimer + dt
        if NovaState.lostTimer > 0.15 then
            NovaState.target = nil
            NovaState.targetCF = nil
            NovaState.smoothCF = nil
        end
    end
    
    if NovaState.searchTimer < 0.05 then return end
    NovaState.searchTimer = 0
    
    local newTarget = FindTarget()
    if newTarget then
        NovaState.target = newTarget
        NovaState.lostTimer = 0
        NovaState.targetCF = nil
        NovaState.smoothCF = nil
        
        NovaUI.status.Text = "> locked: " .. newTarget.Name
        NovaUI.status.TextColor3 = Theme.green
        NovaUI.targetLabel.Text = "> target: " .. newTarget.Name
        NovaUI.targetLabel.TextColor3 = Theme.green
        NovaUI:Log("target: " .. newTarget.Name)
    else
        if NovaState.target then
            NovaState.target = nil
            NovaState.targetCF = nil
            NovaState.smoothCF = nil
        end
        
        NovaUI.status.Text = "> searching..."
        NovaUI.status.TextColor3 = Theme.amber
        NovaUI.targetLabel.Text = "> target: none"
        NovaUI.targetLabel.TextColor3 = Theme.textMuted
    end
end

-- ============================================
-- ОБРАБОТЧИКИ СОБЫТИЙ
-- ============================================

local function ToggleAim()
    NovaState.enabled = not NovaState.enabled
    
    if NovaState.enabled then
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
        
        NovaState.target = nil
        NovaState.targetCF = nil
        NovaState.smoothCF = nil
        
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

-- Подключение кнопок
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

-- Горячие клавиши
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

-- Основной цикл
RunService.RenderStepped:Connect(function(dt)
    pcall(Update, dt)
end)

print("Nova v2.55 загружена, братан!")
