-- Nova v2.55
-- Загрузочный экран, исправленный, бля

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- цвета
local Theme = {
    bg = Color3.fromRGB(10, 10, 16),
    surface = Color3.fromRGB(20, 20, 28),
    surfaceHi = Color3.fromRGB(30, 30, 40),
    accent = Color3.fromRGB(0, 220, 120),
    text = Color3.fromRGB(190, 230, 210),
    textMuted = Color3.fromRGB(110, 140, 120),
    red = Color3.fromRGB(255, 90, 90),
    green = Color3.fromRGB(80, 255, 130),
    amber = Color3.fromRGB(255, 210, 60),
    cursor = Color3.fromRGB(0, 255, 100),
    pythonBlue = Color3.fromRGB(60, 130, 255),
    pythonYellow = Color3.fromRGB(255, 215, 60),
}

local FONT = Enum.Font.SourceSans
local FONT_BOLD = Enum.Font.SourceSansBold

local Icons = {
    Close = "rbxassetid://6031095305",
    Maximize = "rbxassetid://6031095457",
    Minimize = "rbxassetid://6031095388",
}

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

-- анимация символов волной
local animChars = {"|", "/", "-", "\\", "-", "/"}
local animIndex = 1

function GetNextChar()
    local char = animChars[animIndex]
    animIndex = animIndex + 1
    if animIndex > #animChars then animIndex = 1 end
    return char
end

-- сообщения
local BootMessages = {
    "инициализация ядра Python",
    "загрузка модулей Nova",
    "подключение к системным библиотекам",
    "настройка окружения",
    "проверка целостности файлов",
    "загрузка конфигурации",
    "активация сетевых протоколов",
    "синхронизация времени",
    "подготовка интерфейса",
    "загрузка шрифтов",
    "инициализация графики",
    "проверка обновлений",
    "загрузка драйверов",
    "настройка безопасности",
    "оптимизация производительности",
    "загрузка системных служб",
    "активация ядра Nova",
    "подключение к серверам",
    "загрузка пользовательских данных",
    "финальная настройка",
}

-- создаём экран
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
    
    -- шапка с логотипом Termux
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = bg
    
    -- логотип Termux (квадратик)
    local termuxIcon = Instance.new("Frame")
    termuxIcon.Size = UDim2.new(0, 22, 0, 22)
    termuxIcon.Position = UDim2.new(0, 14, 0.5, -11)
    termuxIcon.BackgroundColor3 = Theme.pythonBlue
    termuxIcon.BorderSizePixel = 2
    termuxIcon.BorderColor3 = Theme.pythonYellow
    termuxIcon.Parent = header
    Round(termuxIcon, 4)
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = ">"
    iconText.TextColor3 = Theme.pythonYellow
    iconText.TextSize = 14
    iconText.Font = FONT_BOLD
    iconText.Parent = termuxIcon
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -100, 1, 0)
    headerText.Position = UDim2.new(0, 44, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Termux  —  Nova v2.55"
    headerText.TextColor3 = Theme.text
    headerText.TextSize = 15
    headerText.Font = FONT_BOLD
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = header
    
    -- кнопки с иконками
    local function MakeIconBtn(x, icon)
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.Position = UDim2.new(0, x, 0.5, -14)
        btn.BackgroundTransparency = 1
        btn.Image = icon
        btn.ImageColor3 = Theme.textMuted
        btn.ScaleType = Enum.ScaleType.Fit
        btn.Parent = header
        return btn
    end
    
    local closeBtn = MakeIconBtn(header.Size.X.Offset - 36, Icons.Close)
    local maxBtn = MakeIconBtn(header.Size.X.Offset - 20, Icons.Maximize)
    local minBtn = MakeIconBtn(header.Size.X.Offset - 4, Icons.Minimize)
    
    -- консоль
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
    
    -- строка ввода
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
    
    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 2, 0, 18)
    cursor.Position = UDim2.new(0, 0, 0.5, -9)
    cursor.BackgroundColor3 = Theme.cursor
    cursor.BorderSizePixel = 0
    cursor.Parent = inputContainer
    cursor.Visible = true
    
    -- прогресс (убран, но оставлю на всякий)
    -- полоски нет, бля
    
    -- хранилище строк
    local lines = {}
    local currentMsg = ""
    local currentColor = nil
    local isAnimating = false
    
    function Boot:AddLine(msg, color, isStatic)
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        
        -- чистим сообщение от лишних символов
        local cleanMsg = msg:gsub("[|/\\%-]", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if cleanMsg == "" then cleanMsg = msg end
        
        if isStatic then
            local line = colorHex .. "[" .. time .. "] " .. cleanMsg .. reset
            table.insert(lines, line)
            currentMsg = ""
            currentColor = nil
            isAnimating = false
        else
            currentMsg = cleanMsg
            currentColor = color
            isAnimating = true
            -- добавляем строку без символа (будет обновляться)
            local line = colorHex .. "[" .. time .. "] " .. cleanMsg .. " " .. reset
            table.insert(lines, line)
        end
        
        Boot:Render()
    end
    
    function Boot:UpdateAnim()
        if not isAnimating or currentMsg == "" then return end
        
        local colorHex = currentColor and string.format("<font color='rgb(%d,%d,%d)'>", currentColor.R*255, currentColor.G*255, currentColor.B*255) or ""
        local reset = currentColor and "</font>" or ""
        local char = GetNextChar()
        local time = os.date("%H:%M:%S")
        
        -- заменяем последнюю строку
        if #lines > 0 then
            lines[#lines] = colorHex .. "[" .. time .. "] " .. currentMsg .. " " .. char .. reset
        end
        
        Boot:Render()
    end
    
    function Boot:Render()
        consoleText.Text = table.concat(lines, "\n") .. "\n"
    end
    
    function Boot:ShowInput()
        inputContainer.Visible = true
        task.wait(0.2)
        inputField:CaptureFocus()
    end
    
    -- ввод
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
                isAnimating = false
                Boot:AddLine("запуск Nova, погнали", Theme.green, true)
                task.wait(0.5)
                if StartNova then StartNova() end
            else
                isAnimating = false
                Boot:AddLine("отмена. перезапусти скрипт.", Theme.red, true)
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
    Boot.inputField = inputField
    Boot.inputContainer = inputContainer
    return gui
end

Boot:Create()

-- функция запуска
function StartNova()
    Boot.gui.Enabled = false
    Boot.gui:Destroy()
    print("Nova запущена, бля!")
end

-- запускаем загрузку
task.spawn(function()
    Boot:AddLine("Termux environment initialized", Theme.green, true)
    Boot:AddLine("Python 3.11.5 (Nova framework)", Theme.pythonYellow, true)
    Boot:AddLine("", nil, true)
    
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
        
        -- добавляем новое сообщение
        Boot:AddLine(msg, Theme.textMuted, false)
        
        -- анимируем последнее сообщение
        local delay = stepTime * (0.6 + math.random() * 0.6)
        local startTime = tick()
        while tick() - startTime < delay do
            Boot:UpdateAnim()
            task.wait(0.3)
        end
    end
    
    Boot:AddLine("", nil, true)
    Boot:AddLine("загрузка завершена, бля", Theme.green, true)
    Boot:AddLine("Nova готов, you are ready? y/n", Theme.amber, true)
    
    Boot:ShowInput()
end)

print("Nova v2.55 загружена, братан!")
