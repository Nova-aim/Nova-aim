-- NOVA EFFECT ENGINE

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


local Effects = {}


function Effects.FadeIn(frame)

	frame.BackgroundTransparency = 1
	
	local tween = TweenService:Create(
		frame,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quint
		),
		{
			BackgroundTransparency = 0
		}
	)

	tween:Play()

end



function Effects.Button(button)

	local normal = button.Size


	button.MouseEnter:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Back
			),
			{
				Size = normal + UDim2.new(0,8,0,4)
			}

		):Play()

	end)



	button.MouseLeave:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(0.2),
			{
				Size = normal
			}

		):Play()

	end)

end



-- PARTICLES ONLY IN GUI

function Effects.Particles(parent)

	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1,1)
	holder.BackgroundTransparency = 1
	holder.Parent = parent



	for i = 1,35 do

		local dot = Instance.new("Frame")

		dot.Size = UDim2.new(0,2,0,2)
		dot.Position = UDim2.random()
		dot.BackgroundColor3 = Color3.fromRGB(
			255,
			255,
			255
		)

		dot.BackgroundTransparency = math.random(
			30,
			80
		)/100

		dot.BorderSizePixel = 0

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1,0)
		corner.Parent = dot


		dot.Parent = holder



		task.spawn(function()

			while dot.Parent do

				local x = math.random(-20,20)
				local y = math.random(-20,20)


				TweenService:Create(
					dot,
					TweenInfo.new(
						math.random(2,5),
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						Position =
						UDim2.new(
							dot.Position.X.Scale,
							x,
							dot.Position.Y.Scale,
							y
						)
					}

				):Play()


				task.wait(3)

			end

		end)

	end

end


return Effects
