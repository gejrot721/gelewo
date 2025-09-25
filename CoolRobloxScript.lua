-- Cool Roblox Script - Multi-Feature Game Script
-- Author: AI Assistant
-- Description: A comprehensive script with multiple cool features for Roblox

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoolScriptGUI"
screenGui.Parent = player.PlayerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "🚀 Cool Script v2.0 🚀"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Title corner
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Buttons container
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -20, 1, -70)
buttonsFrame.Position = UDim2.new(0, 10, 0, 60)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- Button creation function
local function createButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = buttonsFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Button hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Features
local features = {
    speedBoost = false,
    jumpBoost = false,
    noclip = false,
    fly = false,
    godMode = false
}

-- Speed Boost Feature
local function toggleSpeedBoost()
    features.speedBoost = not features.speedBoost
    if features.speedBoost then
        humanoid.WalkSpeed = 50
        print("🚀 Speed Boost: ON")
    else
        humanoid.WalkSpeed = 16
        print("🚀 Speed Boost: OFF")
    end
end

-- Jump Boost Feature
local function toggleJumpBoost()
    features.jumpBoost = not features.jumpBoost
    if features.jumpBoost then
        humanoid.JumpPower = 100
        print("🦘 Jump Boost: ON")
    else
        humanoid.JumpPower = 50
        print("🦘 Jump Boost: OFF")
    end
end

-- Noclip Feature
local function toggleNoclip()
    features.noclip = not features.noclip
    if features.noclip then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
        print("👻 Noclip: ON")
    else
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        print("👻 Noclip: OFF")
    end
end

-- Fly Feature
local flyBodyVelocity = nil
local function toggleFly()
    features.fly = not features.fly
    if features.fly then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = rootPart
        print("✈️ Fly: ON")
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        print("✈️ Fly: OFF")
    end
end

-- God Mode Feature
local function toggleGodMode()
    features.godMode = not features.godMode
    if features.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        print("🛡️ God Mode: ON")
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        print("🛡️ God Mode: OFF")
    end
end

-- Teleportation Feature
local function teleportToSpawn()
    local spawnLocation = workspace:FindFirstChild("SpawnLocation")
    if spawnLocation then
        rootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
        print("📍 Teleported to spawn!")
    else
        print("❌ Spawn location not found!")
    end
end

-- Create rainbow effect
local function createRainbowEffect()
    local rainbowPart = Instance.new("Part")
    rainbowPart.Name = "RainbowEffect"
    rainbowPart.Size = Vector3.new(10, 10, 10)
    rainbowPart.Material = Enum.Material.Neon
    rainbowPart.Shape = Enum.PartType.Ball
    rainbowPart.Anchored = true
    rainbowPart.CanCollide = false
    rainbowPart.Parent = workspace
    
    local rainbowTween = TweenService:Create(rainbowPart, 
        TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 
        {Color = Color3.fromRGB(255, 0, 0)}
    )
    
    rainbowTween:Play()
    
    -- Cycle through colors
    local colors = {
        Color3.fromRGB(255, 0, 0),   -- Red
        Color3.fromRGB(255, 165, 0), -- Orange
        Color3.fromRGB(255, 255, 0),  -- Yellow
        Color3.fromRGB(0, 255, 0),    -- Green
        Color3.fromRGB(0, 0, 255),    -- Blue
        Color3.fromRGB(75, 0, 130),   -- Indigo
        Color3.fromRGB(238, 130, 238) -- Violet
    }
    
    local colorIndex = 1
    RunService.Heartbeat:Connect(function()
        if rainbowPart.Parent then
            rainbowPart.Color = colors[colorIndex]
            colorIndex = colorIndex + 1
            if colorIndex > #colors then
                colorIndex = 1
            end
            rainbowPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
        end
    end)
    
    -- Remove after 10 seconds
    wait(10)
    rainbowPart:Destroy()
    print("🌈 Rainbow effect created!")
end

-- Create explosion effect
local function createExplosion()
    local explosion = Instance.new("Explosion")
    explosion.Position = rootPart.Position
    explosion.BlastRadius = 50
    explosion.BlastPressure = 1000000
    explosion.Parent = workspace
    print("💥 Explosion created!")
end

-- Create buttons
createButton("SpeedBoost", "🚀 Speed Boost", UDim2.new(0, 0, 0, 0), toggleSpeedBoost)
createButton("JumpBoost", "🦘 Jump Boost", UDim2.new(0, 0, 0, 50), toggleJumpBoost)
createButton("Noclip", "👻 Noclip", UDim2.new(0, 0, 0, 100), toggleNoclip)
createButton("Fly", "✈️ Fly", UDim2.new(0, 0, 0, 150), toggleFly)
createButton("GodMode", "🛡️ God Mode", UDim2.new(0, 0, 0, 200), toggleGodMode)
createButton("Teleport", "📍 Teleport to Spawn", UDim2.new(0, 0, 0, 250), teleportToSpawn)
createButton("Rainbow", "🌈 Rainbow Effect", UDim2.new(0, 0, 0, 300), createRainbowEffect)
createButton("Explosion", "💥 Create Explosion", UDim2.new(0, 0, 0, 350), createExplosion)

-- Fly controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if features.fly and flyBodyVelocity then
        if input.KeyCode == Enum.KeyCode.W then
            flyBodyVelocity.Velocity = rootPart.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.S then
            flyBodyVelocity.Velocity = -rootPart.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.A then
            flyBodyVelocity.Velocity = -rootPart.CFrame.RightVector * 50
        elseif input.KeyCode == Enum.KeyCode.D then
            flyBodyVelocity.Velocity = rootPart.CFrame.RightVector * 50
        elseif input.KeyCode == Enum.KeyCode.Space then
            flyBodyVelocity.Velocity = Vector3.new(0, 50, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            flyBodyVelocity.Velocity = Vector3.new(0, -50, 0)
        end
    end
end)

-- Auto-heal for god mode
RunService.Heartbeat:Connect(function()
    if features.godMode then
        humanoid.Health = humanoid.MaxHealth
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reapply features
    if features.speedBoost then
        humanoid.WalkSpeed = 50
    end
    if features.jumpBoost then
        humanoid.JumpPower = 100
    end
    if features.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end)

-- Welcome message
print("🎉 Cool Roblox Script loaded successfully!")
print("📋 Available features:")
print("  🚀 Speed Boost - Increases walk speed")
print("  🦘 Jump Boost - Increases jump power")
print("  👻 Noclip - Walk through walls")
print("  ✈️ Fly - Fly around (WASD + Space/Shift)")
print("  🛡️ God Mode - Invincibility")
print("  📍 Teleport - Teleport to spawn")
print("  🌈 Rainbow Effect - Cool visual effect")
print("  💥 Explosion - Create explosion at your position")

-- Script completed
print("✅ Script initialization complete!")