-- MainScript.lua
-- Script utama untuk menjalankan sistem telepon Roblox

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create PhoneSystem folder in ReplicatedStorage
local phoneSystemFolder = Instance.new("Folder")
phoneSystemFolder.Name = "PhoneSystem"
phoneSystemFolder.Parent = ReplicatedStorage

-- Create Features folder
local featuresFolder = Instance.new("Folder")
featuresFolder.Name = "Features"
featuresFolder.Parent = phoneSystemFolder

-- Load PhoneSystem
local PhoneSystem = require(script.Parent.PhoneSystem)

-- Initialize the phone system
print("🚀 Starting Phone System...")
PhoneSystem:Initialize()

-- Add some additional functionality
local function onPlayerAdded(newPlayer)
    print("👋 Player joined: " .. newPlayer.Name)
    
    -- Send welcome message
    wait(2)
    if newPlayer == player then
        print("📱 Welcome to the Phone System! Click the menu button (☰) to open your phone.")
    end
end

-- Connect player added event
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle existing players
for _, existingPlayer in pairs(Players:GetPlayers()) do
    onPlayerAdded(existingPlayer)
end

-- Add keyboard shortcut to toggle phone (F1 key)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        -- Toggle phone system
        local phoneFrame = playerGui:FindFirstChild("PhoneFrame")
        if phoneFrame then
            local toggleBtn = phoneFrame:FindFirstChild("Header"):FindFirstChild("ToggleButton")
            if toggleBtn then
                toggleBtn:Activate()
            end
        end
    end
end)

print("✅ Phone System loaded successfully!")
print("📱 Press F1 or click the menu button (☰) to open your phone")
print("🎮 Features available: Games, Chat, Phone Calls, Music, Settings")