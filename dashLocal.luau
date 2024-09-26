-- first dash script i ever made 🔥

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRT = Character:WaitForChild("HumanoidRootPart")

local Ragdolling = Character:FindFirstChild("Ragdolling")

local After_Effect = replicatedStorage.AfterImage
local remoteEvent = replicatedStorage.Events.Dash

local Camera = workspace.CurrentCamera
local Animator = Humanoid:FindFirstChildOfClass("Animator")

local frontDash = Animator:LoadAnimation(script.frontDash)
local backwardsDash = Animator:LoadAnimation(script.backwardsDash)
local rightDash = Animator:LoadAnimation(script.rightDash)
local leftDash = Animator:LoadAnimation(script.leftDash)

local LDiagonal = Animator:LoadAnimation(script.Diagonal.LDiagonal)
local RDiagonal = Animator:LoadAnimation(script.Diagonal.RDiagonal)
local LbackwardDiagonal = Animator:LoadAnimation(script.Diagonal.LbackwardDiagonal)
local RbackwardDiagonal = Animator:LoadAnimation(script.Diagonal.RbackwardDiagonal)

local otherDash = false
local OtherCharacter = nil

local Debounce = false
local Dashing = false

local function determineMovementDirection()
	local lookVector = HRT.CFrame.LookVector
	local moveDirection = Character.Humanoid.MoveDirection

	local dotProduct = lookVector:Dot(moveDirection)
	local crossProduct = lookVector:Cross(moveDirection)

	if dotProduct > 0.5 and math.abs(crossProduct.Y) < 0.5 then
		return "Forward"
	elseif dotProduct > 0.5 and crossProduct.Y > 0.5 then
		return "LDiagonal"
	elseif dotProduct > 0.5 and crossProduct.Y < -0.5 then
		return "RDiagonal"
	elseif dotProduct < -0.5 and math.abs(crossProduct.Y) < 0.5 then
		return "Backward"
	elseif dotProduct < -0.5 and crossProduct.Y > 0.5 then
		return "BackwardLDiagonal"
	elseif dotProduct < -0.5 and crossProduct.Y < -0.5 then
		return "BackwardRDiagonal"
	elseif crossProduct.Y > 0.5 then
		return "Left"
	elseif crossProduct.Y < -0.5 then
		return "Right"
	else
		return "Stationary"
	end
end

local function linearVelocity()
	local lookDirection
	local Force = 60
	local animTime = 4.75

	local direction = determineMovementDirection()

	if direction == "Forward" then
		frontDash:Play()
		frontDash:AdjustSpeed(animTime)
	elseif direction == "LDiagonal" or direction == "RDiagonal" then
		if direction == "LDiagonal" then
			LDiagonal:Play()
			LDiagonal:AdjustSpeed(animTime)
		else
			RDiagonal:Play()
			RDiagonal:AdjustSpeed(animTime)
		end
	elseif direction == "Backward" then
		backwardsDash:Play()
		backwardsDash:AdjustSpeed(animTime)
	elseif direction == "BackwardLDiagonal" or direction == "BackwardRDiagonal" then
		if direction == "BackwardLDiagonal" then
			LbackwardDiagonal:Play()
			LbackwardDiagonal:AdjustSpeed(animTime)
		else
			RbackwardDiagonal:Play()
			RbackwardDiagonal:AdjustSpeed(animTime)
		end
	elseif direction == "Left" then
		leftDash:Play()
		leftDash:AdjustSpeed(animTime)
	elseif direction == "Right" then
		rightDash:Play()
		rightDash:AdjustSpeed(animTime)
	else
		frontDash:Play()
		frontDash:AdjustSpeed(animTime)
	end

	if Character.Humanoid.MoveDirection == Vector3.new(0, 0, 0) then
		lookDirection = HRT.CFrame.LookVector * Force
	else
		lookDirection = Character.Humanoid.MoveDirection * Force
	end

	local linearVelocityOBJ = Instance.new("LinearVelocity")
	linearVelocityOBJ.Parent = HRT
	linearVelocityOBJ.Attachment0 = HRT.RootAttachment
	linearVelocityOBJ.VectorVelocity = lookDirection
	linearVelocityOBJ.MaxForce = 2.5*10^4
	
	return linearVelocityOBJ
end

local function isFirstPerson()
	return (Character.Torso.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude <= 3.6
end

local function dashAfterEffect(playerName, bool)
	if bool then
		local After_Clone = After_Effect:Clone()
		After_Clone.Parent = workspace.Dash_AfterImage.Character
		After_Clone.Name = playerName.."_AfterImage"

		local playerCharacter = workspace.Characters:FindFirstChild(playerName)
		if playerCharacter then
			local head = After_Clone:FindFirstChild("h")
			local torso = After_Clone:FindFirstChild("t")
			local rarm = After_Clone:FindFirstChild("ra")
			local larm = After_Clone:FindFirstChild("la")
			local rleg = After_Clone:FindFirstChild("rl")
			local lleg = After_Clone:FindFirstChild("ll")

			local Head = playerCharacter:FindFirstChild("Head")
			local Torso = playerCharacter:FindFirstChild("Torso")
			local RArm = playerCharacter:FindFirstChild("Right Arm")
			local LArm = playerCharacter:FindFirstChild("Left Arm")
			local RLeg = playerCharacter:FindFirstChild("Right Leg")
			local LLeg = playerCharacter:FindFirstChild("Left Leg")

			if Head and Torso and RArm and LArm and RLeg and LLeg then
				head.Color = Head.Color
				torso.Color = Torso.Color
				rarm.Color = RArm.Color
				larm.Color = LArm.Color
				rleg.Color = RLeg.Color
				lleg.Color = LLeg.Color

				head.CFrame = Head.CFrame
				torso.CFrame = Torso.CFrame
				rarm.CFrame = RArm.CFrame
				larm.CFrame = LArm.CFrame
				rleg.CFrame = RLeg.CFrame
				lleg.CFrame = LLeg.CFrame

				if playerName == Player.Name and isFirstPerson() then
					for _, afterEffectCloneParts in After_Clone:GetChildren() do
						afterEffectCloneParts.Transparency = 1
					end
				else
					task.spawn(function()
						for i = 1, 20 do
							head.Transparency = head.Transparency + 0.05
							torso.Transparency = torso.Transparency + 0.05
							rarm.Transparency = rarm.Transparency + 0.05
							larm.Transparency = larm.Transparency + 0.05
							rleg.Transparency = rleg.Transparency + 0.05
							lleg.Transparency = lleg.Transparency + 0.05
							
							task.wait()
						end

						Debris:AddItem(After_Clone)
					end)
				end
			end
		end
	end
end

UIS.InputBegan:Connect(function(pressedKey, processed)
	if processed then return end

	if pressedKey.KeyCode == Enum.KeyCode.LeftShift and not Debounce and not Ragdolling.Value then
		Debounce = true
 		
		Humanoid.JumpPower = 0
		task.wait()
		
		local finalLinearVelocity = linearVelocity()
		Debris:AddItem(finalLinearVelocity, 0.15)
		
		Dashing = true
		remoteEvent:FireServer(true)
		Humanoid.JumpPower = 50

		task.wait(1)
		Debounce = false
	end
end)

remoteEvent.OnClientEvent:Connect(function(playerName, bool)
	if bool then
		otherDash = true
		OtherCharacter = playerName
	else
		task.delay(0.2, function()
			otherDash = false
			OtherCharacter = nil
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait()
		if Dashing then
			if HRT.AssemblyLinearVelocity.Magnitude <= 20 then --17
				Dashing = false
				remoteEvent:FireServer(false)
			end
		end
	end
end)

task.spawn(function()
	while true do
		if Dashing then
			dashAfterEffect(Character.Name, Dashing)
		end

		if otherDash and OtherCharacter then
			dashAfterEffect(OtherCharacter, otherDash)
		end
		task.wait(0.0454)
	end
end)
