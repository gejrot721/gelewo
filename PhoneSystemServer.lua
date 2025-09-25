-- 📱 PHONE SYSTEM SERVER SCRIPT
-- Handles server-side phone functionality, data storage, and communication
-- Place this script in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Create RemoteEvents for client-server communication
local PhoneEvents = Instance.new("Folder")
PhoneEvents.Name = "PhoneEvents"
PhoneEvents.Parent = ReplicatedStorage

-- RemoteEvents
local PhoneToggleEvent = Instance.new("RemoteEvent")
PhoneToggleEvent.Name = "PhoneToggle"
PhoneToggleEvent.Parent = PhoneEvents

local PhoneUnlockEvent = Instance.new("RemoteEvent")
PhoneUnlockEvent.Name = "PhoneUnlock"
PhoneUnlockEvent.Parent = PhoneEvents

local PhoneCallEvent = Instance.new("RemoteEvent")
PhoneCallEvent.Name = "PhoneCall"
PhoneCallEvent.Parent = PhoneEvents

local PhoneMessageEvent = Instance.new("RemoteEvent")
PhoneMessageEvent.Name = "PhoneMessage"
PhoneMessageEvent.Parent = PhoneEvents

local PhoneAppEvent = Instance.new("RemoteEvent")
PhoneAppEvent.Name = "PhoneApp"
PhoneAppEvent.Parent = PhoneEvents

local PhoneSettingsEvent = Instance.new("RemoteEvent")
PhoneSettingsEvent.Name = "PhoneSettings"
PhoneSettingsEvent.Parent = PhoneEvents

-- DataStore for phone data
local PhoneDataStore = DataStoreService:GetDataStore("PhoneData")

-- Phone System Server Class
local PhoneServer = {}
PhoneServer.__index = PhoneServer

function PhoneServer.new()
    local self = setmetatable({}, PhoneServer)
    
    -- Server data storage
    self.playerData = {}
    self.activeCalls = {}
    self.groupCalls = {}
    self.notifications = {}
    
    -- Initialize server
    self:setupEventHandlers()
    self:setupPlayerHandling()
    
    return self
end

-- Setup Event Handlers
function PhoneServer:setupEventHandlers()
    -- Phone Toggle Event
    PhoneToggleEvent.OnServerEvent:Connect(function(player)
        self:togglePhone(player)
    end)
    
    -- Phone Unlock Event
    PhoneUnlockEvent.OnServerEvent:Connect(function(player, passcode)
        self:unlockPhone(player, passcode)
    end)
    
    -- Phone Call Event
    PhoneCallEvent.OnServerEvent:Connect(function(player, targetPlayer, callType)
        self:handlePhoneCall(player, targetPlayer, callType)
    end)
    
    -- Phone Message Event
    PhoneMessageEvent.OnServerEvent:Connect(function(player, targetPlayer, message)
        self:handleMessage(player, targetPlayer, message)
    end)
    
    -- Phone App Event
    PhoneAppEvent.OnServerEvent:Connect(function(player, appId, action, data)
        self:handleAppAction(player, appId, action, data)
    end)
    
    -- Phone Settings Event
    PhoneSettingsEvent.OnServerEvent:Connect(function(player, setting, value)
        self:updateSettings(player, setting, value)
    end)
end

-- Setup Player Handling
function PhoneServer:setupPlayerHandling()
    -- Player Added
    Players.PlayerAdded:Connect(function(player)
        self:loadPlayerData(player)
        self:notifyAllPlayers("Player " .. player.Name .. " joined!", "info")
    end)
    
    -- Player Removing
    Players.PlayerRemoving:Connect(function(player)
        self:savePlayerData(player)
        self:cleanupPlayerData(player)
        self:notifyAllPlayers("Player " .. player.Name .. " left!", "warning")
    end)
end

-- Load Player Data
function PhoneServer:loadPlayerData(player)
    local success, data = pcall(function()
        return PhoneDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        self.playerData[player.UserId] = data
    else
        -- Default data
        self.playerData[player.UserId] = {
            passcode = "1234",
            contacts = {},
            messages = {},
            settings = {
                voiceEnabled = false,
                notifications = true,
                darkMode = true,
                autoAnswer = false,
                ringtone = "Default"
            },
            apps = {
                downloaded = {},
                favorites = {}
            },
            batteryLevel = 100,
            lastActive = tick()
        }
    end
    
    print("📱 Loaded data for " .. player.Name)
end

-- Save Player Data
function PhoneServer:savePlayerData(player)
    if self.playerData[player.UserId] then
        local success = pcall(function()
            PhoneDataStore:SetAsync(player.UserId, self.playerData[player.UserId])
        end)
        
        if success then
            print("📱 Saved data for " .. player.Name)
        else
            warn("❌ Failed to save data for " .. player.Name)
        end
    end
end

-- Cleanup Player Data
function PhoneServer:cleanupPlayerData(player)
    -- End any active calls
    for callId, callData in pairs(self.activeCalls) do
        if callData.caller == player.UserId or callData.receiver == player.UserId then
            self.activeCalls[callId] = nil
        end
    end
    
    -- Remove from group calls
    for groupId, groupData in pairs(self.groupCalls) do
        for i, participantId in pairs(groupData.participants) do
            if participantId == player.UserId then
                table.remove(groupData.participants, i)
                break
            end
        end
    end
    
    -- Clean up player data
    self.playerData[player.UserId] = nil
end

-- Toggle Phone
function PhoneServer:togglePhone(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        playerData.isPhoneOpen = not playerData.isPhoneOpen
        playerData.lastActive = tick()
        
        -- Notify client
        PhoneToggleEvent:FireClient(player, playerData.isPhoneOpen)
        
        print("📱 " .. player.Name .. " toggled phone: " .. (playerData.isPhoneOpen and "OPEN" or "CLOSED"))
    end
end

-- Unlock Phone
function PhoneServer:unlockPhone(player, passcode)
    local playerData = self.playerData[player.UserId]
    if playerData and playerData.passcode == passcode then
        playerData.isLocked = false
        playerData.lastActive = tick()
        
        -- Notify client
        PhoneUnlockEvent:FireClient(player, true)
        
        print("🔓 " .. player.Name .. " unlocked phone successfully")
    else
        -- Notify client of failed unlock
        PhoneUnlockEvent:FireClient(player, false)
        
        print("🔒 " .. player.Name .. " failed to unlock phone")
    end
end

-- Handle Phone Call
function PhoneServer:handlePhoneCall(player, targetPlayer, callType)
    if not targetPlayer or targetPlayer == player then return end
    
    local callId = tick()
    self.activeCalls[callId] = {
        caller = player.UserId,
        receiver = targetPlayer.UserId,
        callType = callType or "voice",
        startTime = tick(),
        status = "connecting"
    }
    
    -- Notify both players
    PhoneCallEvent:FireClient(player, "call_initiated", callId, targetPlayer.Name)
    PhoneCallEvent:FireClient(targetPlayer, "incoming_call", callId, player.Name, callType)
    
    print("📞 " .. player.Name .. " calling " .. targetPlayer.Name .. " (" .. callType .. ")")
end

-- Handle Message
function PhoneServer:handleMessage(player, targetPlayer, message)
    if not targetPlayer or targetPlayer == player then return end
    
    local messageData = {
        sender = player.UserId,
        receiver = targetPlayer.UserId,
        message = message,
        timestamp = tick(),
        read = false
    }
    
    -- Store message
    if not self.playerData[player.UserId].messages then
        self.playerData[player.UserId].messages = {}
    end
    if not self.playerData[targetPlayer.UserId].messages then
        self.playerData[targetPlayer.UserId].messages = {}
    end
    
    table.insert(self.playerData[player.UserId].messages, messageData)
    table.insert(self.playerData[targetPlayer.UserId].messages, messageData)
    
    -- Notify receiver
    PhoneMessageEvent:FireClient(targetPlayer, "new_message", player.Name, message)
    
    print("💬 " .. player.Name .. " sent message to " .. targetPlayer.Name)
end

-- Handle App Action
function PhoneServer:handleAppAction(player, appId, action, data)
    local playerData = self.playerData[player.UserId]
    if not playerData then return end
    
    if action == "download" then
        -- Download app
        if not playerData.apps.downloaded then
            playerData.apps.downloaded = {}
        end
        playerData.apps.downloaded[appId] = true
        
        PhoneAppEvent:FireClient(player, "app_downloaded", appId)
        print("📱 " .. player.Name .. " downloaded app: " .. appId)
        
    elseif action == "delete" then
        -- Delete app
        if playerData.apps.downloaded and playerData.apps.downloaded[appId] then
            playerData.apps.downloaded[appId] = nil
            PhoneAppEvent:FireClient(player, "app_deleted", appId)
            print("🗑️ " .. player.Name .. " deleted app: " .. appId)
        end
        
    elseif action == "open" then
        -- Open app
        PhoneAppEvent:FireClient(player, "app_opened", appId, data)
        print("📱 " .. player.Name .. " opened app: " .. appId)
    end
end

-- Update Settings
function PhoneServer:updateSettings(player, setting, value)
    local playerData = self.playerData[player.UserId]
    if playerData and playerData.settings then
        playerData.settings[setting] = value
        playerData.lastActive = tick()
        
        PhoneSettingsEvent:FireClient(player, setting, value)
        print("⚙️ " .. player.Name .. " updated setting: " .. setting .. " = " .. tostring(value))
    end
end

-- Notify All Players
function PhoneServer:notifyAllPlayers(message, type)
    for _, player in pairs(Players:GetPlayers()) do
        PhoneMessageEvent:FireClient(player, "notification", message, type or "info")
    end
end

-- Battery Management
function PhoneServer:startBatterySimulation()
    spawn(function()
        while true do
            wait(60) -- Every minute
            
            for userId, playerData in pairs(self.playerData) do
                local player = Players:GetPlayerByUserId(userId)
                if player and playerData.batteryLevel > 0 then
                    playerData.batteryLevel = math.max(0, playerData.batteryLevel - math.random(1, 3))
                    
                    if playerData.batteryLevel <= 20 and playerData.batteryLevel > 0 then
                        PhoneMessageEvent:FireClient(player, "notification", "Low battery: " .. playerData.batteryLevel .. "%", "warning")
                    elseif playerData.batteryLevel == 0 then
                        PhoneMessageEvent:FireClient(player, "notification", "Phone powered off due to low battery", "error")
                        playerData.isPhoneOpen = false
                        PhoneToggleEvent:FireClient(player, false)
                    end
                end
            end
        end
    end)
end

-- Initialize Server
local phoneServer = PhoneServer.new()
phoneServer:startBatterySimulation()

print("📱 PHONE SYSTEM SERVER LOADED!")
print("🔧 Server Features:")
print("  📊 Data Storage & Management")
print("  📞 Call Handling & Routing")
print("  💬 Message System")
print("  📱 App Management")
print("  ⚙️ Settings Sync")
print("  🔋 Battery Simulation")
print("  🔔 Notification System")
print("✅ Server ready for client connections!")