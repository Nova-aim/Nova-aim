-- NOVA BOOT SCREEN v2.55

local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("NovaBoot") then
    CoreGui.NovaBoot:Destroy()
end

local Colors = {
    Background = Color3.fromRGB(4,4,4),
    Panel = Color3.fromRGB(12,12,12),
    Green = Color3.fromRGB(0,255,90),
    Gray = Color3.fromRGB(120,180,120),
    White = Color3.fromRGB(220,220,220),
    Yellow = Color3.fromRGB(255,220,70),
    Red = Color3.fromRGB(255,70,70)
}

local gui = Instance.new("ScreenGui")
gui.Name = "NovaBoot"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
gui.Parent = CoreGui


local main = Instance.new("Frame")
main.Size = UDim2.fromScale(1,1)
main.BackgroundColor3 = Colors.Background
main.BorderSizePixel = 0
main.Parent = gui


-- верхняя панель

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,35)
header.BackgroundColor3 = Colors.Panel
header.BorderSizePixel = 0
header.Parent = main


local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,250,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "Nova v2.55"
title.Font = Enum.Font.Code
title.TextSize = 16
title.TextColor3 = Colors.White
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header


-- кнопки

local function CreateButton(text,x)
    local b = Instance.new("TextLabel")
    b.Size = UDim2.new(0,30,0,30)
    b.Position = UDim2.new(1,x,0,2)
    b.BackgroundTransparency = 1
    b.Text = text
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.TextColor3 = Colors.Gray
    b.Parent = header
end

CreateButton("_",-100)
CreateButton("□",-65)
CreateButton("×",-30)


-- консоль

local console = Instance.new("ScrollingFrame")
console.Size = UDim2.new(1,-30,1,-55)
console.Position = UDim2.new(0,15,0,45)
console.BackgroundTransparency = 1
console.BorderSizePixel = 0
console.ScrollBarThickness = 3
console.Parent = main


local output = Instance.new("TextLabel")
output.Size = UDim2.new(1,-10,0,0)
output.BackgroundTransparency = 1
output.AutomaticSize = Enum.AutomaticSize.Y
output.Font = Enum.Font.Code
output.TextSize = 15
output.TextColor3 = Colors.Green
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.RichText = true
output.Parent = console


local lines = {}


local function RGB(color)
    return string.format(
        "rgb(%d,%d,%d)",
        math.floor(color.R*255),
        math.floor(color.G*255),
        math.floor(color.B*255)
    )
end


local function Render()
    output.Text = table.concat(lines,"\n")

    task.wait()

    console.CanvasSize = UDim2.new(
        0,
        0,
        0,
        output.TextBounds.Y + 40
    )

    console.CanvasPosition = Vector2.new(
        0,
        console.CanvasSize.Y.Offset
    )
end


local function Type(text,color)

    local line = ""

    local index = #lines + 1
    lines[index] = ""

    for i = 1,#text do
        
        line = line .. text:sub(i,i)

        lines[index] =
            "<font color='"..
            RGB(color)..
            "'>"..
            "["..os.date("%H:%M:%S").."] "..line.."▌"..
            "</font>"

        Render()

        task.wait(0.04)
    end


    lines[index] =
        "<font color='"..
        RGB(color)..
        "'>"..
        "["..os.date("%H:%M:%S").."] "..line..
        "</font>"

    Render()
end



task.spawn(function()

    local messages = {
        "Запуск Nova...",
        "Загрузка модулей...",
        "Проверка конфигурации...",
        "Инициализация интерфейса...",
        "Оптимизация системы...",
        "Nova готова."
    }


    for _,msg in ipairs(messages) do
        Type(msg,Colors.Green)
        task.wait(0.25)
    end


    Type("Продолжить? (y/n)",Colors.Yellow)

end)
