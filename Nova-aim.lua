-- Nova v2.55
-- Загрузочный экран с нуля, бля

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- чистим хуйню
if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- цвета
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

-- состояние загрузки
local BootState = {
    phase = 0,
    ready = false,
    inputBuffer = "",
    cursorBlink = false,
    cursorTimer = 0,
    bootComplete = false,
    animFrame = 0,
    animChars = {"|", "/", "-", "\\"},
    currentMsg = "",
    msgList = {},
    msgIndex = 1,
    totalSteps = 0,
    progress = 0,
}

-- сообщения загрузки
local BootMessages = {
    "инициализация ядра Python...",
    "загрузка модулей Nova...",
    "подключение к системным библиотекам...",
    "настройка окружения...",
    "проверка целостности файлов...",
    "загрузка конфигурации...",
    "активация сетевых протоколов...",
    "синхронизация времени...",
    "подготовка интерфейса...",
    "загрузка шрифтов...",
    "инициализация графики...",
    "проверка обновлений...",
    "загрузка драйверов...",
    "настройка безопасности...",
    "оптимизация производительности...",
    "загрузка системных служб...",
    "активация ядра Nova...",
    "подключение к серверам...",
    "загрузка пользовательских данных...",
    "финальная настройка...",
}

-- создание загрузочного экрана
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
    
    -- шапка: Python + Nova
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = bg
    
    -- иконка Python
    local pythonIcon = Instance.new("Frame")
    pythonIcon.Size = UDim2.new(0, 22, 0, 22)
    pythonIcon.Position = UDim2.new(0, 14, 0.5, -11)
    pythonIcon.BackgroundColor3 = Theme.pythonBlue
    pythonIcon.BorderSizePixel = 2
    pythonIcon.BorderColor3 = Theme.pythonYellow
    pythonIcon.Parent = header
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 4)
    iconCorner.Parent = pythonIcon
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -20, 1, 0)
    headerText.Position = UDim2.new(0, 44, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Python  —  Nova v2.55"
    headerText.TextColor3 = Theme.text
    headerText.TextSize = 15
    headerText.Font = FONT_BOLD
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = header
    
    -- контейнер для консоли (с прокруткой)
    local consoleContainer = Instance.new("Frame")
    consoleContainer.Size = UDim2.new(1, -40, 1, -100)
    consoleContainer.Position = UDim2.new(0, 20, 0, 52)
    consoleContainer.BackgroundColor3 = Theme.bg
    consoleContainer.BackgroundTransparency = 1
    consoleContainer.BorderSizePixel = 0
    consoleContainer.Parent = bg
    consoleContainer.ClipsDescendants = true
    
    -- скролл для консоли
    local console = Instance.new("ScrollingFrame")
    console.Size = UDim2.new(1, 0, 1, 0)
    console.Position = UDim2.new(0, 0, 0, 0)
    console.BackgroundColor3 = Theme.bg
    console.BackgroundTransparency = 1
    console.BorderSizePixel = 0
    console.ScrollBarThickness = 3
    console.ScrollBarImageColor3 = Theme.textMuted
    console.ScrollBarImageTransparency = 0.3
    console.Parent = consoleContainer
    
    -- текст консоли
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
    
    -- рамка для ввода (появляется после ready?)
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0, 500, 0, 36)
    inputContainer.Position = UDim2.new(0, 20, 1, -48)
    inputContainer.BackgroundColor3 = Theme.surfaceHi
    inputContainer.BackgroundTransparency = 0.5
    inputContainer.BorderSizePixel = 0
    inputContainer.Visible = false
    inputContainer.Parent = bg
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputContainer
    
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
    
    -- курсор
    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 2, 0, 18)
    cursor.Position = UDim2.new(0, 0, 0.5, -9)
    cursor.BackgroundColor3 = Theme.cursor
    cursor.BorderSizePixel = 0
    cursor.Parent = inputContainer
    cursor.Visible = true
    
    -- прогресс бар
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 300, 0, 3)
    progressBg.Position = UDim2.new(0.5, -150, 1, -16)
    progressBg.BackgroundColor3 = Theme.surfaceHi
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBg
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Theme.accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill
    
    -- функция логирования
    function Boot:Log(msg, color, noAnim)
        local current = consoleText.Text
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        
        if not noAnim and msg ~= "" and msg ~= "готов? (y/n)" and msg ~= "загрузка завершена" then
            -- анимируем сообщение
            task.spawn(function()
                for i = 1, 8 do
                    local animChar = BootState.animChars[(i % 4) + 1]
                    local display = msg .. " " .. animChar
                    local full = current .. colorHex .. "[" .. time .. "] " .. display .. reset .. "\n"
                    consoleText.Text = full
                    console.CanvasPosition = Vector2.new(0, consoleText.TextBounds.Y)
                    task.wait(0.1)
                end
                -- финальная версия без анимации
                local full = current .. colorHex .. "[" .. time .. "] " .. msg .. reset .. "\n"
                consoleText.Text = full
                console.CanvasPosition = Vector2.new(0, consoleText.TextBounds.Y)
            end)
        else
            consoleText.Text = current .. colorHex .. "[" .. time .. "] " .. msg .. reset .. "\n"
            console.CanvasPosition = Vector2.new(0, consoleText.TextBounds.Y)
        end
    end
    
    function Boot:UpdateProgress(pct)
        progressFill.Size = UDim2.new(pct, 0, 1, 0)
    end
    
    function Boot:ShowInput()
        inputContainer.Visible = true
        -- позиционируем контейнер ввода чуть ниже последнего сообщения
        task.wait(0.1)
        inputField:CaptureFocus()
    end
    
    function Boot:ClearInput()
        inputField.Text = ""
    end
    
    -- обработка ввода
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputField.Text ~= "" and BootState.phase == 1 then
            local cmd = inputField.Text
            inputField.Text = ""
            Boot:Log("> " .. cmd, Theme.amber, true)
            
            local yes = {"y", "yes", "ye", "да", "д", "1", "true"}
            local isYes = false
            for _, v in ipairs(yes) do
                if cmd:lower() == v then
                    isYes = true
                    break
                end
            end
            
            if isYes then
                Boot:Log("запуск Nova...", Theme.green, true)
                BootState.ready = true
                task.wait(0.5)
                StartNova()
            else
                Boot:Log("отмена. перезапусти скрипт.", Theme.red, true)
                inputContainer.Visible = false
            end
        end
    end)
    
    -- для телефона
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and inputContainer.Visible then
            inputField:CaptureFocus()
        end
    end)
    
    -- анимация курсора
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
    Boot.progressFill = progressFill
    return gui
end

Boot:Create()

-- запускаем загрузку
task.spawn(function()
    Boot:Log("Termux environment initialized", Theme.green, true)
    Boot:Log("Python 3.11.5 (Nova framework)", Theme.pythonYellow, true)
    Boot:Log("", nil, true)
    
    -- перемешиваем сообщения
    local shuffled = {}
    for i, msg in ipairs(BootMessages) do
        table.insert(shuffled, msg)
    end
    
    -- рандомное количество шагов
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
    
    -- финальные сообщения
    Boot:UpdateProgress(1)
    Boot:Log("", nil, true)
    Boot:Log("загрузка завершена", Theme.green, true)
    Boot:Log("система готова", Theme.green, true)
    Boot:Log("", nil, true)
    Boot:Log("готов? (y/n)", Theme.amber, true)
    
    BootState.phase = 1
    Boot:ShowInput()
end)

-- функция запуска софта
function StartNova()
    Boot.gui.Enabled = false
    Boot.gui:Destroy()
    
    -- тут будет основной интерфейс
    print("Nova запущена, бля!")
end
