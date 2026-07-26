-- Nova LOADER v10.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local Gui = Instance.new("ScreenGui")
Gui.Name = "NovaLoader"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.Parent = PlayerGui


local Colors = {
    Black = Color3.fromRGB(3,3,6),
    Dark = Color3.fromRGB(10,10,15),
    Neon = Color3.fromRGB(80,255,130),
    DimNeon = Color3.fromRGB(20,80,40),
}



-- задний фон

local Background = Instance.new("Frame")
Background.Size = UDim2.fromScale(1,1)
Background.BackgroundColor3 = Colors.Black
Background.Parent = Gui



-- частицы

local ParticleFolder = Instance.new("Folder")
ParticleFolder.Parent = Background


local particles = {}


local function CreateParticle()

    local p = Instance.new("Frame")

    local neon = math.random(1,3)==1

    p.Size = UDim2.fromOffset(
        math.random(2,5),
        math.random(2,5)
    )

    p.Position = UDim2.fromScale(
        math.random(),
        math.random()
    )


    p.BackgroundColor3 =
        neon and Colors.Neon
        or Color3.fromRGB(
            math.random(5,20),
            math.random(5,20),
            math.random(8,25)
        )


    p.BackgroundTransparency =
        neon and 0.2 or 0.35


    p.Parent = ParticleFolder


    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent=p


    table.insert(particles,{
        obj=p,
        x=math.random(-20,20)/10000,
        y=math.random(-20,20)/10000,
        phase=math.random()
    })

end


for i=1,100 do
    CreateParticle()
end



RunService.RenderStepped:Connect(function()

    local t=os.clock()

    for _,p in pairs(particles) do

        local obj=p.obj

        if obj then

            local pos=obj.Position

            obj.Position=UDim2.new(
                pos.X.Scale+p.x,
                0,
                pos.Y.Scale+p.y,
                0
            )


            obj.BackgroundTransparency =
                0.2 +
                math.sin(
                    t+p.phase
                )*0.3


            if pos.X.Scale > 1 then
                obj.Position=UDim2.fromScale(0,math.random())
            end

            if pos.Y.Scale > 1 then
                obj.Position=UDim2.fromScale(math.random(),0)
            end

        end

    end

end)



-- частицы

local Title=Instance.new("TextLabel")
Title.Size=UDim2.fromOffset(500,80)
Title.Position=UDim2.new(.5,-250,.32,0)

Title.BackgroundTransparency=1

Title.Text="NOVA"

Title.TextColor3=Colors.Neon
Title.TextSize=60
Title.Font=Enum.Font.Code

Title.Parent=Background



Title.TextTransparency=1


TweenService:Create(
    Title,
    TweenInfo.new(1),
    {
        TextTransparency=0
    }
):Play()



-- типо терминал

local Terminal=Instance.new("TextLabel")

Terminal.Size=UDim2.new(.7,0,.35,0)
Terminal.Position=UDim2.new(.15,.0,.48,0)

Terminal.BackgroundTransparency=1

Terminal.TextColor3=Colors.Neon
Terminal.Font=Enum.Font.Code
Terminal.TextSize=18

Terminal.TextXAlignment=Enum.TextXAlignment.Left
Terminal.TextYAlignment=Enum.TextYAlignment.Top

Terminal.Parent=Background



local function Type(text)

    Terminal.Text..="\n"

    for i=1,#text do

        Terminal.Text=
            Terminal.Text..
            string.sub(text,i,i)

        task.wait(.025)

    end

end



task.spawn(function()

    local boot={
        "$ NOVA SYSTEM START",
        "$ Loading modules...",
        "$ Initializing particles...",
        "$ Loading interface...",
        "$ Engine ready",
        "",
        "READY? y/n"
    }


    for _,v in ipairs(boot) do
        Type(v)
        task.wait(.2)
    end

end)



-- хз что 

task.spawn(function()

    task.wait(3)

    local pulse=true

    while pulse do

        TweenService:Create(
            Title,
            TweenInfo.new(1),
            {
                TextColor3=
                Color3.fromRGB(140,255,170)
            }
        ):Play()

        task.wait(1)

        TweenService:Create(
            Title,
            TweenInfo.new(1),
            {
                TextColor3=Colors.Neon
            }
        ):Play()

        task.wait(1)

    end

end)
