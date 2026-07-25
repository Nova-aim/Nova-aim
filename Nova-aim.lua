-- Nova v2.55
-- Настоящий Termux стиль с посимвольной печатью, бля

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("Nova") then
    CoreGui.Nova:Destroy()
end

-- цвета как в терминале
local Theme = {
    bg = Color3.fromRGB(8, 8, 12),
    surface = Color3.fromRGB(18, 18, 24),
    surfaceHi = Color3.fromRGB(28, 28, 36),
    text = Color3.fromRGB(180, 220, 200),
    textMuted = Color3.fromRGB(100, 130, 110),
    green = Color3.fromRGB(80, 255, 130),
    amber = Color3.fromRGB(255, 210, 60),
    red = Color3.fromRGB(255, 90, 90),
    cursor = Color3.fromRGB(0, 255, 100),
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

-- сообщения для загрузки
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
    
    -- шапка Termux
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Theme.surface
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = bg
    
    -- иконка Termux
    local termuxIcon = Instance.new("Frame")
    termuxIcon.Size = UDim2.new(0, 20, 0, 20)
    termuxIcon.Position = UDim2.new(0, 12, 0.5, -10)
    termuxIcon.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
    termuxIcon.BorderSizePixel = 2
    termuxIcon.BorderColor3 = Theme.pythonYellow
    termuxIcon.Parent = header
    Round(termuxIcon, 4)
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = ">"
    iconText.TextColor3 = Theme.pythonYellow
    iconText.TextSize = 12
    iconText.Font = FONT_BOLD
    iconText.Parent = termuxIcon
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -100, 1, 0)
    headerText.Position = UDim2.new(0, 40, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Termux  —  Nova v2.55"
    headerText.TextColor3 = Theme.text
    headerText.TextSize = 14
    headerText.Font = FONT_BOLD
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = header
    
    -- кнопки
    local function MakeIconBtn(x, icon)
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.Position = UDim2.new(0, x, 0.5, -13)
        btn.BackgroundTransparency = 1
        btn.Image = icon
        btn.ImageColor3 = Theme.textMuted
        btn.ScaleType = Enum.ScaleType.Fit
        btn.Parent = header
        return btn
    end
    
    local closeBtn = MakeIconBtn(header.Size.X.Offset - 34, Icons.Close)
    local maxBtn = MakeIconBtn(header.Size.X.Offset - 18, Icons.Maximize)
    local minBtn = MakeIconBtn(header.Size.X.Offset - 2, Icons.Minimize)
    
    -- консоль
    local console = Instance.new("ScrollingFrame")
    console.Size = UDim2.new(1, -30, 1, -80)
    console.Position = UDim2.new(0, 15, 0, 48)
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
    inputContainer.Size = UDim2.new(0, 500, 0, 34)
    inputContainer.Position = UDim2.new(0, 15, 1, -44)
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
    inputLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
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
    
    -- состояние печати
    local lines = {}
    local isPrinting = false
    local printQueue = {}
    local currentLine = ""
    local currentColor = nil
    local lineIndex = 0
    
    -- функция печати по символам
    function Boot:TypeLine(text, color, callback)
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        
        -- добавляем время в начало
        local fullText = "[" .. time .. "] " .. text
        
        -- создаём строку для печати
        local line = ""
        local charIndex = 1
        
        -- добавляем в очередь
        table.insert(printQueue, {
            text = fullText,
            colorHex = colorHex,
            reset = reset,
            callback = callback
        })
        
        -- если не печатаем, запускаем
        if not isPrinting then
            Boot:ProcessQueue()
        end
    end
    
    function Boot:ProcessQueue()
        if #printQueue == 0 then
            isPrinting = false
            return
        end
        
        isPrinting = true
        local item = printQueue[1]
        table.remove(printQueue, 1)
        
        local text = item.text
        local colorHex = item.colorHex
        local reset = item.reset
        local callback = item.callback
        
        -- создаём новую строку в консоли
        local line = colorHex .. reset
        table.insert(lines, line)
        lineIndex = #lines
        
        -- печатаем по символам
        local charIndex = 1
        local function typeNextChar()
            if charIndex > #text then
                -- завершили печать строки
                if callback then callback() end
                Boot:ProcessQueue()
                return
            end
            
            -- берём следующий символ
            local char = text:sub(charIndex, charIndex)
            charIndex = charIndex + 1
            
            -- обновляем строку
            local currentText = ""
            for i = 1, charIndex - 1 do
                currentText = currentText .. text:sub(i, i)
            end
            
            lines[lineIndex] = colorHex .. currentText .. reset
            Boot:Render()
            
            -- следующий символ через 30-50ms (как в терминале)
            local delay = math.random(30, 50) / 1000
            task.wait(delay)
            
            typeNextChar()
        end
        
        typeNextChar()
    end
    
    function Boot:Render()
        consoleText.Text = table.concat(lines, "\n") .. "\n"
        -- автоматический скролл вниз
        console.CanvasPosition = Vector2.new(0, consoleText.TextBounds.Y)
    end
    
    function Boot:AddStaticLine(msg, color)
        local time = os.date("%H:%M:%S")
        local colorHex = color and string.format("<font color='rgb(%d,%d,%d)'>", color.R*255, color.G*255, color.B*255) or ""
        local reset = color and "</font>" or ""
        
        local line = colorHex .. "[" .. time .. "] " .. msg .. reset
        table.insert(lines, line)
        Boot:Render()
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
                Boot:TypeLine("запуск Nova, погнали", Theme.green, function()
                    task.wait(0.5)
                    if StartNova then StartNova() end
                end)
            else
                Boot:TypeLine("отмена. перезапусти скрипт.", Theme.red)
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
    -- статичные сообщения (без анимации)
    Boot:AddStaticLine("Termux environment initialized", Theme.green)
    Boot:AddStaticLine("Python 3.11.5 (Nova framework)", Theme.pythonYellow)
    Boot:AddStaticLine("")
    
    -- перемешиваем сообщения
    local shuffled = {}
    for i, msg in ipairs(BootMessages) do
        table.insert(shuffled, msg)
    end
    
    -- выбираем случайные сообщения (10-15 штук)
    local steps = math.random(10, 15)
    local selected = {}
    for i = 1, steps do
        if #shuffled == 0 then break end
        local idx = math.random(1, #shuffled)
        table.insert(selected, shuffled[idx])
        table.remove(shuffled, idx)
    end
    
    -- печатаем каждое сообщение с задержкой
    local delayBetween = math.random(1, 3) / 10 -- 0.1-0.3 сек между строками
    
    for i, msg in ipairs(selected) do
        Boot:TypeLine(msg, Theme.textMuted)
        task.wait(delayBetween + math.random() * 0.2)
    end
    
    -- финальные сообщения
    task.wait(0.5)
    Boot:AddStaticLine("")
    Boot:TypeLine("загрузка завершена, бля", Theme.green)
    task.wait(0.3)
    Boot:TypeLine("Nova готов, you are ready? y/n", Theme.amber)
    
    task.wait(0.5)
    Boot:ShowInput()
end)

print("Nova v2.55 загружена, братан!")
