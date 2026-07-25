--==================================================
-- NOVA UI CONCEPT v1
-- Terminal Boot + Python Style Menu
-- UI ONLY
--==================================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local GuiParent = Player:WaitForChild("PlayerGui")

local old = GuiParent:FindFirstChild("NOVA_UI")
if old then old:Destroy() end


local Gui = Instance.new("ScreenGui")
Gui.Name = "NOVA_UI"
Gui.IgnoreGuiInset = true
Gui.Parent = GuiParent


local Colors = {
    Black = Color3.fromRGB(5,5,5),
    Panel = Color3.fromRGB(15,15,15),
    White = Color3.fromRGB(240,240,240),
    Gray = Color3.fromRGB(120,120,120),
    Green = Color3.fromRGB(0,255,120)
}


--------------------------------------------------
-- BOOT
--------------------------------------------------

local Boot = Instance.new("Frame")
Boot.Size = UDim2.fromScale(1,1)
Boot.BackgroundColor3 = Colors.Black
Boot.Parent = Gui


local Text = Instance.new("TextLabel")
Text.Size = UDim2.new(0.8,0,0.8,0)
Text.Position = UDim2.new(0.1,0,0.1,0)
Text.BackgroundTransparency = 1
Text.TextColor3 = Colors.Green
Text.Font = Enum.Font.Code
Text.TextSize = 18
Text.TextXAlignment = Enum.TextXAlignment.Left
Text.TextYAlignment = Enum.TextYAlignment.Top
Text.Parent = Boot


local lines = {
"> NOVA SYSTEM BOOT",
"> Loading modules...",
"> Checking interface...",
"> Loading terminal...",
"> Initializing core...",
"> Interface ready",
"",
"READY? Y/N"
}


for _,v in ipairs(lines) do
    Text.Text ..= v.."\n"
    task.wait(0.35)
end


task.wait(1)

TweenService:Create(
    Boot,
    TweenInfo.new(0.5),
    {BackgroundTransparency = 1}
):Play()

task.wait(0.5)
Boot:Destroy()



--------------------------------------------------
-- MAIN MENU
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,500,0,350)
Main.Position = UDim2.new(0.5,-250,0.5,-175)
Main.BackgroundColor3 = Colors.Panel
Main.Parent = Gui


local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = Main



local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1,0,0,50)
Header.BackgroundTransparency = 1
Header.Text = "NOVA // TERMINAL"
Header.TextColor3 = Colors.Green
Header.Font = Enum.Font.Code
Header.TextSize = 28
Header.Parent = Main



--------------------------------------------------
-- TABS
--------------------------------------------------

local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(0,150,0,35)
Tab1.Position = UDim2.new(0,20,0,60)
Tab1.Text = "SYSTEM"
Tab1.Font = Enum.Font.Code
Tab1.TextColor3 = Colors.White
Tab1.BackgroundColor3 = Color3.fromRGB(30,30,30)
Tab1.Parent = Main


local Tab2 = Tab1:Clone()
Tab2.Position = UDim2.new(0,180,0,60)
Tab2.Text="FRIENDS"
Tab2.Parent=Main



--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-40,0,210)
Content.Position = UDim2.new(0,20,0,110)
Content.BackgroundTransparency = 1
Content.Parent = Main



local function Button(name,y)

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,35)
    b.Position = UDim2.new(0,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(25,25,25)
    b.Text = "[ "..name.." ]"
    b.TextColor3 = Colors.White
    b.Font = Enum.Font.Code
    b.TextSize = 17
    b.Parent = Content

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent=b

    return b
end


Button("AIM SYSTEM",0)
Button("XRAY MODULE",45)
Button("SETTINGS",90)
Button("TERMINAL",135)



--------------------------------------------------
-- FRIENDS TAB MOCK
--------------------------------------------------

Tab2.MouseButton1Click:Connect(function()

    for _,v in pairs(Content:GetChildren()) do
        v:Destroy()
    end

    Button("FRIEND LIST",0)
    Button("ADD FRIEND",45)
    Button("REMOVE FRIEND",90)
    Button("SAFE USERS",135)

end)


Tab1.MouseButton1Click:Connect(function()

    for _,v in pairs(Content:GetChildren()) do
        v:Destroy()
    end

    Button("AIM SYSTEM",0)
    Button("XRAY MODULE",45)
    Button("SETTINGS",90)
    Button("TERMINAL",135)

end)
