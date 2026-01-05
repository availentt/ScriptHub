local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings
local highlightEnabled = true
local highlightColor = Color3.fromRGB(0, 255, 255)
local highlightOutlineColor = Color3.fromRGB(255, 255, 255)

-- Store highlights for cleanup
local highlights = {}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightToggleGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame (draggable container)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 25)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Player Highlights"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Toggle Button Container
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ToggleContainer"
toggleContainer.Size = UDim2.new(0, 50, 0, 24)
toggleContainer.Position = UDim2.new(0, 10, 0, 45)
toggleContainer.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleContainer.BorderSizePixel = 0
toggleContainer.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleContainer

-- Toggle Circle
local toggleCircle = Instance.new("Frame")
toggleCircle.Name = "ToggleCircle"
toggleCircle.Size = UDim2.new(0, 20, 0, 20)
toggleCircle.Position = UDim2.new(0, 28, 0.5, -10)
toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleCircle.BorderSizePixel = 0
toggleCircle.Parent = toggleContainer

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = toggleCircle

-- Toggle Button (invisible but clickable)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundTransparency = 1
toggleButton.Text = ""
toggleButton.Parent = toggleContainer

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 100, 0, 24)
statusLabel.Position = UDim2.new(0, 70, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ENABLED"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Dragging functionality
local dragging = false
local dragInput, mousePos, framePos

local function updateInput(input)
	local delta = input.Position - mousePos
	local newPos = UDim2.new(
		framePos.X.Scale,
		framePos.X.Offset + delta.X,
		framePos.Y.Scale,
		framePos.Y.Offset + delta.Y
	)
	mainFrame.Position = newPos
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or 
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		mousePos = input.Position
		framePos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or
	   input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		updateInput(input)
	end
end)

-- Toggle animation
local function animateToggle(enabled)
	local targetPos = enabled and UDim2.new(0, 28, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
	local targetColor = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 110)
	
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local positionTween = game:GetService("TweenService"):Create(toggleCircle, tweenInfo, {Position = targetPos})
	local colorTween = game:GetService("TweenService"):Create(toggleContainer, tweenInfo, {BackgroundColor3 = targetColor})
	
	positionTween:Play()
	colorTween:Play()
	
	statusLabel.Text = enabled and "ENABLED" or "DISABLED"
	statusLabel.TextColor3 = enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 160)
end

-- Store original transparencies and connections
local invisiblePlayerData = {}

-- Function to check if character is invisible
local function isCharacterInvisible(character)
	local invisibleCount = 0
	local totalParts = 0
	
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			totalParts = totalParts + 1
			if part.Transparency >= 1 then
				invisibleCount = invisibleCount + 1
			end
		end
	end
	
	-- If most parts are invisible, character is considered invisible
	return totalParts > 0 and invisibleCount >= totalParts * 0.7
end

-- Function to keep arms visible (prevent flickering using RenderStepped)
local function maintainArmVisibility(character)
	local leftArm = character:FindFirstChild("Left Arm")
	local rightArm = character:FindFirstChild("Right Arm")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	
	-- Use RenderStepped to force transparency every frame
	local connection = RunService.RenderStepped:Connect(function()
		if not character.Parent then
			return
		end
		
		if leftArm and leftArm.Parent then
			leftArm.Transparency = 0
		end
		
		if rightArm and rightArm.Parent then
			rightArm.Transparency = 0
		end
		
		if hrp and hrp.Parent then
			hrp.Transparency = 0
		end
	end)
	
	return connection
end

-- Function to add highlight to a character
local function addHighlight(character)
	if not highlightEnabled then return end
	
	-- Check if highlight already exists
	if character:FindFirstChild("PlayerHighlight") then
		return
	end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Check if character is invisible
	local isInvisible = isCharacterInvisible(character)
	
	if isInvisible then
		-- Make HumanoidRootPart and arms visible with anti-flicker
		local connection = maintainArmVisibility(character)
		
		-- Store connection for cleanup
		invisiblePlayerData[character] = {
			connection = connection
		}
		
		-- Highlight the entire character (all visible parts)
		local highlight = Instance.new("Highlight")
		highlight.Name = "PlayerHighlight"
		highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow
		highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
		highlight.FillTransparency = 0.3
		highlight.OutlineTransparency = 0
		highlight.Parent = character -- Highlight entire character, not just HRP
		
		highlights[character] = highlight
	else
		-- Normal highlight for visible characters
		local highlight = Instance.new("Highlight")
		highlight.Name = "PlayerHighlight"
		highlight.FillColor = highlightColor
		highlight.OutlineColor = highlightOutlineColor
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = character
		
		highlights[character] = highlight
	end
end

-- Function to remove highlight from a character
local function removeHighlight(character)
	if highlights[character] then
		highlights[character]:Destroy()
		highlights[character] = nil
	end
	
	-- Disconnect anti-flicker connection
	if invisiblePlayerData[character] then
		if invisiblePlayerData[character].connection then
			invisiblePlayerData[character].connection:Disconnect()
		end
		invisiblePlayerData[character] = nil
	end
	
	local highlight = character:FindFirstChild("PlayerHighlight")
	if highlight then
		highlight:Destroy()
	end
end

-- Function to refresh all highlights
local function refreshHighlights()
	-- Clear existing highlights
	for character, highlight in pairs(highlights) do
		if highlight then
			highlight:Destroy()
		end
	end
	highlights = {}
	
	-- Add highlights to all players if enabled
	if highlightEnabled then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.Character then
				addHighlight(otherPlayer.Character)
			end
		end
	end
end

-- Handle player character added
local function onCharacterAdded(character, targetPlayer)
	-- Wait for character to fully load
	character:WaitForChild("HumanoidRootPart")
	
	if highlightEnabled then
		addHighlight(character)
	end
	
	-- Monitor for transparency changes to detect invisibility
	local function checkInvisibility()
		if highlightEnabled and character.Parent then
			-- Remove old highlight
			removeHighlight(character)
			-- Add new highlight (will detect if invisible)
			addHighlight(character)
		end
	end
	
	-- Check every second for invisibility changes
	task.spawn(function()
		while character.Parent do
			task.wait(1)
			checkInvisibility()
		end
	end)
end

-- Handle player added
local function onPlayerAdded(targetPlayer)
	if targetPlayer.Character then
		onCharacterAdded(targetPlayer.Character, targetPlayer)
	end
	
	targetPlayer.CharacterAdded:Connect(function(character)
		onCharacterAdded(character, targetPlayer)
	end)
end

-- Handle player removing
local function onPlayerRemoving(targetPlayer)
	if targetPlayer.Character then
		removeHighlight(targetPlayer.Character)
	end
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
	highlightEnabled = not highlightEnabled
	animateToggle(highlightEnabled)
	refreshHighlights()
end)

-- Connect to all existing players
for _, otherPlayer in ipairs(Players:GetPlayers()) do
	onPlayerAdded(otherPlayer)
end

-- Connect to new players joining
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Initial animation
animateToggle(highlightEnabled)
