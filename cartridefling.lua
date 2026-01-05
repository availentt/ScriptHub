local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game.Players
FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1

function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

function getRoot(char)
	if char and char:FindFirstChildOfClass("Humanoid") then
		return char:FindFirstChildOfClass("Humanoid").RootPart
	else
		return nil
	end
end

local speaker = game.Players.LocalPlayer
local ch = speaker.Character
	ch:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local prt=Instance.new("Model")
	prt.Parent = speaker.Character
	local z1 = Instance.new("Part")
	z1.Name="Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part")
	z2.Name="Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 =Instance.new("Humanoid")
	z3.Name="Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character=prt
	wait(3)
	speaker.Character=ch
	wait(3)
	local Hum = Instance.new("Humanoid")
	z2:Clone()
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v ~= root and  v.Name ~= "Humanoid" then
			v:Destroy()
		end
	end
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = RunService.Stepped:Connect(function()
		if speaker.Character and getRoot(speaker.Character) then
			getRoot(speaker.Character).CanCollide = false
		else
			invisflingStepped:Disconnect()
		end
	end)
	sFLY()
	workspace.CurrentCamera.CameraSubject = root
	local bambam = Instance.new("BodyThrust")
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999,99999*10,99999)
	bambam.Location = getRoot(speaker.Character).Position
