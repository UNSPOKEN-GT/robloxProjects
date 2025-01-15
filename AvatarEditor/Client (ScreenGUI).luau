local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarEditoModule = ReplicatedStorage:FindFirstChild("AvatarEditor") or ReplicatedFirst:FindFirstChild("AvatarEditor")
local AvatarEditor = require(AvatarEditoModule)

local Player = Players.LocalPlayer
local Character = Player.Character

local currentCamera = workspace.CurrentCamera
local Rig = workspace.Other.Rig
local originalRigCFrame = Rig.PrimaryPart.CFrame
local rigTorso = Rig.Torso

local Mouse = Player:GetMouse()

local MainButton = script.ScreenGui.MainButton
local ExitUI = script.ScreenGui.Exit

local CAMERA_SPEED = 0.01
local AvatarEditting = false

local MouseButton1 = false
local MouseButton2 = false
local LastMouseX = 0
local LastMouseY = 0

local lastMagnitude = 0
local lastTouchPosition = Vector3.new()

MainButton.MouseButton1Up:Connect(function()
	if not AvatarEditting then
		AvatarEditor.init(currentCamera, Rig, Character)
		AvatarEditting = true

		MainButton.Visible = false
		ExitUI.Visible = true
	end
end)

ExitUI.MouseButton1Up:Connect(function()
	if AvatarEditting then
		AvatarEditor.stop(currentCamera, Rig, originalRigCFrame, Character)
		AvatarEditting = false

		MainButton.Visible = true
		ExitUI.Visible = false
	end
end)

--[[ stop avatar editting on death
Character.Humanoid.Died:Connect(function()
	AvatarEditor.stop(currentCamera, Rig, originalRigCFrame, Character)
	AvatarEditting = false
end)]]

UIS.InputChanged:Connect(function(input, processed)
	if processed or not AvatarEditting then return end

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local deltaX = Mouse.X - LastMouseX
		local deltaY = Mouse.Y - LastMouseY

		if MouseButton1 and not MouseButton2 then
			LastMouseX = AvatarEditor.smoothRotate(Rig, Mouse.X, LastMouseX)
		end

		if MouseButton2 and not MouseButton1 then
			AvatarEditor.moveCamera(currentCamera, Rig, (deltaX * CAMERA_SPEED), (deltaY * CAMERA_SPEED))
		end

		LastMouseX = Mouse.X
		LastMouseY = Mouse.Y
	end

	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local currentCameraPosition = currentCamera.CFrame.Position
		local ZOOM = math.clamp(currentCameraPosition.Z - input.Position.Z, rigTorso.Position.Z + 2, rigTorso.Position.Z + 10)

		currentCamera.CFrame = CFrame.new(currentCameraPosition.X, currentCameraPosition.Y, ZOOM)
	end
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed or not AvatarEditting then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Mouse.Target ~= nil and Rig:IsAncestorOf(Mouse.Target) then
			MouseButton1 = true
			LastMouseX = Mouse.X
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		MouseButton2 = true
		LastMouseX = Mouse.X
		LastMouseY = Mouse.Y
	end
end)

-- mobile support a bit 💩 cause im too lazy for now
UIS.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
	if processed or not AvatarEditting then return end

	local currentMagnitude = (touchPositions[1] - touchPositions[2]).magnitude
	local difference = currentMagnitude - lastMagnitude

	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local currentCameraPosition = currentCamera.CFrame.Position

		local zoomAmount = difference * 0.1
		local newZ = math.clamp(currentCameraPosition.Z + zoomAmount, rigTorso.Position.Z + 2, rigTorso.Position.Z + 10)

		currentCamera.CFrame = CFrame.new(currentCameraPosition.X, currentCameraPosition.Y, newZ)
	end

	lastMagnitude = currentMagnitude
end)

UIS.TouchMoved:Connect(function(input, processed)
	if processed or not AvatarEditting then return end
	local delta = input.Position - lastTouchPosition

	lastTouchPosition = AvatarEditor.smoothRotate(Rig, Mouse.X, LastMouseX)
	lastTouchPosition = input.Position
end)

UIS.InputEnded:Connect(function(input, processed)
	if processed or not AvatarEditting then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		MouseButton1 = false
		task.spawn(AvatarEditor.gradualStop, Rig)
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		MouseButton2 = false
	end
end)
