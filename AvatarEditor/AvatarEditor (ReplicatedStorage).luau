local AvatarEditor = {}
-- TODO: make a similar dragging/slider system to that of the roblox avatar editor to edit hats or accessories

local rotationVelocity = 0
local deceleration = 0.9
local stopThreshold = 0.07
local isRotating = false

-- Settings:
local CAMERA_DISTANCE = 5
local GRID_LIMITS = {X = 2, Y = 4}
local Y_BOTTOM_OFFSET, Y_TOP_OFFSET = 4, 3

function AvatarEditor.init(camera: Camera, Rig: Model, Character: Model)	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(Vector3.new(
		Rig.PrimaryPart.Position.X, 
		Rig.Torso.Position.Y, 
		Rig.PrimaryPart.Position.Z + CAMERA_DISTANCE
		))
	
	local rigPosition = Rig.PrimaryPart.Position
	local cameraPosition = camera.CFrame.Position

	local directionToCamera = Vector3.new(cameraPosition.X - rigPosition.X, 0, cameraPosition.Z - rigPosition.Z).Unit

	local newCFrame = CFrame.new(rigPosition, rigPosition + directionToCamera)
	Rig:SetPrimaryPartCFrame(newCFrame)
end

function AvatarEditor.stop(camera: Camera, Rig: Model, originalRigCFrame: CFrame, Character: Model)
	Rig:SetPrimaryPartCFrame(originalRigCFrame)
	camera.CameraType = Enum.CameraType.Custom
end

function AvatarEditor.moveCamera(camera: Camera, Rig: Model, deltaX: number, deltaY: number)
	if not Rig.PrimaryPart then return end

	local currentCameraPosition = camera.CFrame.Position
	local rigPosition = Rig.PrimaryPart.Position

	local newPosition = Vector3.new(-- max cam movement for the x & y axis
		math.clamp(currentCameraPosition.X + -deltaX, 
			rigPosition.X - GRID_LIMITS.X, -- left
			rigPosition.X + GRID_LIMITS.X), -- right
		
		math.clamp(currentCameraPosition.Y + deltaY, 
			rigPosition.Y - Y_BOTTOM_OFFSET, -- bottom
			(rigPosition.Y + GRID_LIMITS.Y) - Y_TOP_OFFSET), -- top
		currentCameraPosition.Z) -- setting this so it doesnt js start going to random places :sob:

	camera.CFrame = CFrame.new(newPosition)
end

function AvatarEditor.smoothRotate(model: Model, mouseX: number, lastMouseX: number): number
	if not model.PrimaryPart then return end

	local deltaRotation = math.rad(mouseX - lastMouseX)
	rotationVelocity = math.clamp(deltaRotation, 0, 0.6)

	local returnCFrame = model.PrimaryPart.CFrame
	local targetCFrame = returnCFrame * CFrame.Angles(0, deltaRotation, 0)

	local smoothCFrame = returnCFrame:Lerp(targetCFrame, 0.35)
	model:SetPrimaryPartCFrame(smoothCFrame)

	isRotating = true
	return mouseX
end

function AvatarEditor.gradualStop(model: Model)
	if not model.PrimaryPart then return end

	for i = 1, 50 do
		if math.abs(rotationVelocity) > stopThreshold then
			local returnCFrame = model.PrimaryPart.CFrame
			local targetCFrame = returnCFrame * CFrame.Angles(0, rotationVelocity, 0)
			model:SetPrimaryPartCFrame(targetCFrame)

			rotationVelocity *= deceleration
			task.wait()
		else
			rotationVelocity = 0
			break
		end
	end
	isRotating = false
end

return AvatarEditor

--[[
Copyright © 2025 xmuslem. All Rights Reserved.

This Roblox Luau script, designed as a replica of Roblox's avatar system, is protected by copyright law.
You are permitted to modify and use this script for personal or non-commercial purposes within Roblox games.

Restrictions:

You may not resell, redistribute, or otherwise use this script for commercial purposes.
You may not claim this script or any derivative works as your own.
Credit (Optional):
If you modify or use this script, giving credit to me is appreciated but not required.

Disclaimer: This script is not affiliated with, endorsed by, or sponsored by Roblox Corporation.
]]
