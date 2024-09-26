-- goofy way of creating a glass breaking effect

local Window = script.Parent
local requiredForce = 25

Window.Touched:Connect(function(hit)
	local Character = hit.Parent
	local HumanoidRoot = Character:FindFirstChild("HumanoidRootPart")

	if HumanoidRoot then
		local currentForce = (HumanoidRoot.Velocity - Window.Velocity).magnitude
		
		if currentForce > requiredForce and Window.CanCollide then
			
			Window.CanCollide = false
			Window.Transparency = 1

			local brokenWindow = workspace.Broken.Glass:Clone()
			brokenWindow.Parent = workspace:FindFirstChild("Garbage")
			brokenWindow:PivotTo(Window.CFrame)
			
			local hitDirection = -(HumanoidRoot.Position - Window.Position).Unit
			
			for _, v in brokenWindow:GetDescendants() do
				v.Anchored = false
				
				local Force = Instance.new("BodyVelocity")
				Force.Velocity = hitDirection * (currentForce/2)
				Force.MaxForce = Vector3.new(4000, 4000, 4000)
				Force.Parent =  v
				
				game:GetService("Debris"):AddItem(Force, 0.2)
			end
			
			Window.Sound:Play()
		end
	end
end)
