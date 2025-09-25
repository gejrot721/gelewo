-- PhoneSystemClient.lua
-- Main client script untuk menjalankan sistem handphone

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Import main controller
local PhoneController = require(script.Parent.Controllers.PhoneController)

-- Initialize phone system when player spawns
local function initializePhoneSystem()
    -- Wait for ReplicatedStorage to be available
    ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    
    -- Initialize the phone system
    PhoneController.initialize()
    
    print("Phone System loaded for player:", player.Name)
end

-- Handle player respawning
player.CharacterAdded:Connect(function()
    -- Reinitialize if needed
    if not PhoneController.getState().screenGui then
        initializePhoneSystem()
    end
end)

-- Initialize on first spawn
if player.Character then
    initializePhoneSystem()
else
    player.CharacterAdded:Connect(initializePhoneSystem)
end

-- Cleanup when player leaves
game:BindToClose(function()
    PhoneController.cleanup()
end)