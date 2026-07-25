-- NOVA TERMINAL BOOT v3.0

local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("NovaTerminal") then
    CoreGui.NovaTerminal:Destroy()
end

local Colors = {
    bg = Color3.fromRGB(5,5,5),
    panel = Color3.fromRGB(15,15,15),
    green = Color3.fromRGB(0,255,90),
    dim = Color3.fromRGB(90,170,100),
    white = Color3.fromRGB(220,220,220),
    yellow = Color3.fromRGB(255,210,60)
}

local gui = Instance.new("ScreenGui")
gui.Name = "NovaTerminal"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = CoreGui


local main = Instance.new("Frame")
main.Size = UDim2.fromScale(1,1)
main.BackgroundColor3 = Colors.bg
main.BorderSizePixel = 0
main.Parent = gui


-- верхняя панель
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,34)
header.BackgroundColor3 = Colors.panel
header.BorderSizePixel = 0
header.Parent = main


local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0,40,1,0)
logo.Position = UDim2.new(0,10,0,0)
logo.BackgroundTransparency = 1
logo.Text = ">"
logo.Font = Enum.Font.Code
logo.TextSize = 22
logo.TextColor3 = Colors.green
logo.Parent = header


local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,250,1,0)
title.Position = UDim2.new(0,45,0,0)
title.BackgroundTransparency = 1
title.Text = "Nova Terminal v2.55"
title.Font = Enum.Font.Code
title.TextSize = 15
title.TextColor3 = Colors.white
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header


-- кнопки
local function Button(text,pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,30,0,24)
    b.Position = pos
    b.BackgroundTransparency = 1
    b.Text = text
    b.Font = Enum.Font.Code
    b.TextSize = 18
    b.TextColor3 = Colors.dim
    b.Parent = header
end

Button("_",UDim2.new(1,-100,0,5))
Button("□",UDim2.new(1,-65,0,5))
Button("X",UDim2.new(1,-30,0,5))


-- консоль
local console = Instance.new("ScrollingFrame")
console.Size = UDim2.new(1,-30,1,-60)
console.Position = UDim2.new(0,15,0,45)
console.BackgroundTransparency = 1
console.BorderSizePixel = 0
console.ScrollBarThickness = 3
console.Parent = main


local text = Instance.new("TextLabel")
text.Size = UDim2.new(1,-10,0,0)
text.BackgroundTransparency = 1
text.Font = Enum.Font.Code
text.TextSize = 15
text.TextColor3 = Colors.green
text.TextXAlignment = Enum.TextXAlignment.Left
text.TextYAlignment = Enum.TextYAlignment.Top
text.RichText = true
text.AutomaticSize = Enum.AutomaticSize.Y
text.Parent = console


local lines = {}


local function Render()
    text.Text = table.concat(lines,"\n")
    console.CanvasSize = UDim2.new(
        0,0,
        0,text.AbsoluteSize.Y+30
    )
    console.CanvasPosition = Vector2.new(
        0,
        math.max(0,text.AbsoluteSize.Y)
    )
end


local function TypeLine(msg,color)
    local prefix = "["..os.date("%H:%M:%S").."] "
    local result = prefix

    table.insert(lines,result.."█")
    Render()

    for i=1,#msg do
        result = result..msg:sub(i,i)

        lines[#lines] = 
            "<font color='rgb("..
            color.R*255..","..
            color.G*255..","..
            color.B*255..
            ")'>"..
            result..
            "█</font>"

        Render()

        task.wait(0.04)
    end

    lines[#lines] = 
        "<font color='rgb("..
        color.R*255..","..
        color.G*255..","..
        color.B*255..
        ")'>"..
        result..
        "</font>"

    Render()
end


local boot = {
    "Nova kernel loading...",
    "Checking modules...",
    "Loading configuration...",
    "Starting Python environment...",
    "Preparing interface...",
    "Optimizing performance...",
    "Security check complete...",
    "Nova initialization complete"
}


task.spawn(function()

    TypeLine(
        "Nova Terminal v2.55",
        Colors.white
    )

    TypeLine(
        "Linux environment ready",
        Colors.dim
    )

    for _,v in ipairs(boot) do
        task.wait(.2)
        TypeLine(v,Colors.green)
    end

    task.wait(.5)

    TypeLine(
        "Continue? (y/n)",
        Colors.yellow
    )

end)
