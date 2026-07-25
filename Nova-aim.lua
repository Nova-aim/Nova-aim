-- Nova v2.55
-- Загрузочный экран с анимацией и переходом, бля

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- цвета, бля
local Theme = {
    bg = Color3.fromRGB(8, 8, 10),
    surface = Color3.fromRGB(18, 18, 22),
    surfaceHi = Color3.fromRGB(28, 28, 32),
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

-- состояние, бля
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

-- скругление, нахуй
local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

-- сообщения для загрузки, пиздец
local BootMessages = {
    "инициализация ядра Python, бля",
    "загрузка модулей Nova, ебать",
    "подключение к системным библиотекам",
    "настройка окружения, нахуй",
    "проверка целостности файлов",
    "загрузка конфигурации, пиздец",
    "активация сетевых протоколов",
    "синхронизация времени, заебало",
    "подготовка интерфейса",
    "загрузка шрифтов, бля",
    "инициализация графики",
    "проверка обновлений, нахуй",
    "загрузка драйверов",
    "настройка безопасности, ебать",
    "оптимизация производительности",
    "загрузка системных служб",
    "активация ядра Nova, погнали",
    "подключение к серверам",
    "загрузка пользовательских данных",
    "финальная настройка, пиздец",
}

-- ============================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН
-- ============================================

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
    
    -- шапка, бля
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = bg
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -20, 1, 0)
    headerText.Position = UDim2.new(0, 14, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Python  —  Nova v2.55"
    headerText.TextColor3 = Theme.text
    headerText.TextSize = 15
    headerText.Font = FONT_BOLD
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = header
    
    -- консоль, нахуй
    local console = Instance.new("ScrollingFrame")
    console.Size = UDim2.new(1, -40, 1, -100)
    console.Position = UDim2.new(0, 20, 0, 52)
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
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0, 500, 0, 36)
    inputContainer.Position = UDim2.new(0, 20, 1, -48)
    inputContainer.BackgroundColor3 = Theme.surfaceHi
    inputContainer.BackgroundTransparency = 0.5
    inputContainer.BorderSizePixel = 0
    inputContainer.Visible = false
    inputContainer.Parent = bg
    Round(inputContainer, 6)
    
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Size = UDim2.new(0, 24, 1, 0)
    inputLabel.Position = UDim2.new(0, 8, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "$"
    inputLabel.TextColor3 = Theme.accent
    inputLabel.TextSize = 14
    inputLabel.Font = FONT_BOLD
    inputLabel.Parent = inputContainer
    
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
    inputField.Parent = inputContainer
    
    -- курсор, ебаный
    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 2, 0, 18)
    cursor.Position = UDim2.new(0, 0, 0.5, -9)
    cursor.BackgroundColor3 = Theme.cursor
    cursor.BorderSizePixel = 0
    cursor.Parent = inputContainer
    cursor.Visible = true
    
    -- прогресс, нахуй
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 300, 0, 3)
    progressBg.Position = UDim2.new(0.5, -150, 1, -16)
    progressBg.BackgroundColor3 = Theme.surfaceHi
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg
    Round(progressBg, 999)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Theme.accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    Round(progressFill, 999)
    
    -- анимация символов
    local animChars = {"|", "/", "-", "\\"}
    local animIndex = 1
    
    function Boot:Log(msg, color)
        local current = consoleText.Text
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        
        -- анимируем каждый раз, бля
        local animChar = animChars[animIndex]
        animIndex = animIndex + 1
        if animIndex > 4 then animIndex = 1 end
        
        local display = msg .. " " .. animChar
        consoleText.Text = current .. colorHex .. "[" .. time .. "] " .. display .. reset .. "\n"
        -- не листаем автоматически, нахуй
    end
    
    function Boot:UpdateProgress(pct)
        progressFill.Size = UDim2.new(pct, 0, 1, 0)
    end
    
    function Boot:ShowInput()
        inputContainer.Visible = true
        task.wait(0.2)
        inputField:CaptureFocus()
    end
    
    function Boot:ClearInput()
        inputField.Text = ""
    end
    
    -- ввод, ебать
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputField.Text ~= "" then
            local cmd = inputField.Text
            inputField.Text = ""
            
            local yes = {"y", "yes", "ye", "да", "д", "1"}
            local isYes = false
            for _, v in ipairs(yes) do
                if cmd:lower() == v then
                    isYes = true
                    break
                end
            end
            
            if isYes then
                Boot:Log("запуск Nova, погнали", Theme.green)
                task.wait(0.5)
                StartNova()
            else
                Boot:Log("отмена. перезапусти скрипт.", Theme.red)
                inputContainer.Visible = false
            end
        end
    end)
    
    -- для телефона, бля
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and inputContainer.Visible then
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
    Boot.inputContainer = inputContainer
    return gui
end

Boot:Create()

-- ============================================
-- МЕНЮ ПОСЛЕ ЗАГРУЗКИ (типа софт, но без софта)
-- ============================================

local function ShowFakeMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaMain"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    gui.DisplayOrder = 999
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Theme.bg
    main.BackgroundTransparency = 0.03
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    Round(main, 16)
    
    -- свечение, бля
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 4, 1, 4)
    glow.Position = UDim2.new(0, -2, 0, -2)
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 2
    glow.BorderColor3 = Theme.accent
    glow.BorderTransparency = 0.5
    glow.Parent = main
    Round(glow, 18)
    
    -- шапка
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = main
    Round(header, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Nova v2.55 — Python IDE"
    title.TextColor3 = Theme.text
    title.TextSize = 15
    title.Font = FONT_BOLD
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- кнопки (точки)
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
    
    -- текст с надписью
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -40, 1, -80)
    text.Position = UDim2.new(0, 20, 0, 60)
    text.BackgroundTransparency = 1
    text.Text = "ТУТ ДОЛЖЕН БЫТЬ ВАШ СОФТ\nНО ВЫ МНЕ НЕ ЗАПЛАТИЛИ"
    text.TextColor3 = Theme.textMuted
    text.TextSize = 24
    text.Font = FONT_BOLD
    text.TextScaled = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = main
    
    -- кнопка выхода
    local exitBtn = Instance.new("TextButton")
    exitBtn.Size = UDim2.new(0, 120, 0, 36)
    exitBtn.Position = UDim2.new(0.5, -60, 1, -50)
    exitBtn.BackgroundColor3 = Theme.red
    exitBtn.BackgroundTransparency = 0.3
    exitBtn.BorderSizePixel = 0
    exitBtn.Text = "> exit"
    exitBtn.TextColor3 = Theme.text
    exitBtn.TextSize = 14
    exitBtn.Font = FONT
    exitBtn.Parent = main
    Round(exitBtn, 8)
    
    exitBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- анимация появления
    main.Size = UDim2.new(0, 200, 0, 200)
    main.Position = UDim2.new(0.5, -100, 0.5, -100)
    main.BackgroundTransparency = 1
    
    local tween = TweenService:Create(main, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundTransparency = 0.03,
    })
    tween:Play()
    
    return gui
end

-- ============================================
-- ЗАПУСК СОФТА
-- ============================================

function StartNova()
    -- удаляем загрузочный экран с анимацией
    local bootGui = Boot.gui
    if bootGui then
        -- плавное исчезновение
        local fade = TweenService:Create(bootGui, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Enabled = false
        })
        fade:Play()
        fade.Completed:Connect(function()
            bootGui:Destroy()
        end)
    end
    
    task.wait(0.6)
    
    -- показываем меню
    ShowFakeMenu()
end

-- ============================================
-- ЗАГРУЗКА
-- ============================================

task.spawn(function()
    Boot:Log("Termux environment initialized", Theme.green)
    Boot:Log("Python 3.11.5 (Nova framework)", Theme.pythonYellow)
    Boot:Log("")
    
    local shuffled = {}
    for i, msg in ipairs(BootMessages) do
        table.insert(shuffled, msg)
    end
    
    local steps = math.random(10, 18)
    local totalTime = math.random(12, 30)
    local stepTime = totalTime / steps
    
    for i = 1, steps do
        local idx = math.random(1, #shuffled)
        local msg = shuffled[idx]
        table.remove(shuffled, idx)
        if #shuffled == 0 then break end
        
        local progress = i / steps
        Boot:UpdateProgress(progress)
        Boot:Log(msg, Theme.textMuted)
        
        local delay = stepTime * (0.6 + math.random() * 0.6)
        task.wait(delay)
    end
    
    Boot:UpdateProgress(1)
    Boot:Log("")
    Boot:Log("загрузка завершена, бля", Theme.green)
    Boot:Log("Nova готов, you are ready? y/n", Theme.amber)
    
    Boot:ShowInput()
end)

print("Nova v2.55 загружена, братан!")
