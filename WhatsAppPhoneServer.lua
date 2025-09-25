-- 📱 WHATSAPP-LIKE PHONE SYSTEM - SERVER SCRIPT
-- Features: SMS, Voice Calls, Contacts, VoiceChat Integration
-- Place this script in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatService = game:GetService("VoiceChatService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Create RemoteEvents folder
local PhoneEvents = Instance.new("Folder")
PhoneEvents.Name = "PhoneEvents"
PhoneEvents.Parent = ReplicatedStorage

-- RemoteEvents for communication
local PhoneToggleEvent = Instance.new("RemoteEvent")
PhoneToggleEvent.Name = "PhoneToggle"
PhoneToggleEvent.Parent = PhoneEvents

local SMSEvent = Instance.new("RemoteEvent")
SMSEvent.Name = "SMS"
SMSEvent.Parent = PhoneEvents

local CallEvent = Instance.new("RemoteEvent")
CallEvent.Name = "Call"
CallEvent.Parent = PhoneEvents

local ContactEvent = Instance.new("RemoteEvent")
ContactEvent.Name = "Contact"
ContactEvent.Parent = PhoneEvents

local VoiceChatEvent = Instance.new("RemoteEvent")
VoiceChatEvent.Name = "VoiceChat"
VoiceChatEvent.Parent = PhoneEvents

local NotificationEvent = Instance.new("RemoteEvent")
NotificationEvent.Name = "Notification"
NotificationEvent.Parent = PhoneEvents

-- DataStore for persistent data
local PhoneDataStore = DataStoreService:GetDataStore("WhatsAppPhoneData")

-- WhatsApp Phone Server Class
local WhatsAppPhoneServer = {}
WhatsAppPhoneServer.__index = WhatsAppPhoneServer

function WhatsAppPhoneServer.new()
    local self = setmetatable({}, WhatsAppPhoneServer)
    
    -- Server data storage
    self.playerData = {}
    self.activeCalls = {}
    self.smsMessages = {}
    self.contacts = {}
    self.voiceChatRooms = {}
    
    -- Initialize
    self:setupEventHandlers()
    self:setupPlayerHandling()
    
    return self
end

-- Setup Event Handlers
function WhatsAppPhoneServer:setupEventHandlers()
    -- Phone Toggle
    PhoneToggleEvent.OnServerEvent:Connect(function(player)
        self:togglePhone(player)
    end)
    
    -- SMS Events
    SMSEvent.OnServerEvent:Connect(function(player, action, targetPlayer, message)
        if action == "send" then
            self:sendSMS(player, targetPlayer, message)
        elseif action == "get_conversations" then
            self:getSMSConversations(player)
        elseif action == "get_messages" then
            self:getSMSMessages(player, targetPlayer)
        end
    end)
    
    -- Call Events
    CallEvent.OnServerEvent:Connect(function(player, action, targetPlayer, callType)
        if action == "start_call" then
            self:startCall(player, targetPlayer, callType)
        elseif action == "answer_call" then
            self:answerCall(player, targetPlayer)
        elseif action == "end_call" then
            self:endCall(player, targetPlayer)
        elseif action == "reject_call" then
            self:rejectCall(player, targetPlayer)
        end
    end)
    
    -- Contact Events
    ContactEvent.OnServerEvent:Connect(function(player, action, targetPlayer)
        if action == "add_contact" then
            self:addContact(player, targetPlayer)
        elseif action == "remove_contact" then
            self:removeContact(player, targetPlayer)
        elseif action == "get_contacts" then
            self:getContacts(player)
        elseif action == "search_players" then
            self:searchPlayers(player)
        end
    end)
    
    -- VoiceChat Events
    VoiceChatEvent.OnServerEvent:Connect(function(player, action, targetPlayer, roomId)
        if action == "join_voice_room" then
            self:joinVoiceRoom(player, roomId)
        elseif action == "leave_voice_room" then
            self:leaveVoiceRoom(player, roomId)
        elseif action == "create_voice_room" then
            self:createVoiceRoom(player, targetPlayer)
        end
    end)
end

-- Setup Player Handling
function WhatsAppPhoneServer:setupPlayerHandling()
    Players.PlayerAdded:Connect(function(player)
        self:loadPlayerData(player)
        self:notifyPlayer(player, "Welcome to WhatsApp Phone System! 📱", "success")
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:savePlayerData(player)
        self:cleanupPlayerData(player)
    end)
end

-- Load Player Data
function WhatsAppPhoneServer:loadPlayerData(player)
    local success, data = pcall(function()
        return PhoneDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        self.playerData[player.UserId] = data
    else
        -- Default WhatsApp-like data
        self.playerData[player.UserId] = {
            phoneNumber = self:generatePhoneNumber(),
            contacts = {},
            smsConversations = {},
            callHistory = {},
            settings = {
                notifications = true,
                voiceChatEnabled = false,
                autoAnswer = false,
                darkMode = true,
                fontSize = "medium"
            },
            lastSeen = tick(),
            isOnline = true,
            status = "Hey there! I'm using WhatsApp Phone System 📱"
        }
    end
    
    print("📱 Loaded WhatsApp data for " .. player.Name)
end

-- Generate Phone Number
function WhatsAppPhoneServer:generatePhoneNumber()
    local number = "+62"
    for i = 1, 10 do
        number = number .. math.random(0, 9)
    end
    return number
end

-- Save Player Data
function WhatsAppPhoneServer:savePlayerData(player)
    if self.playerData[player.UserId] then
        self.playerData[player.UserId].lastSeen = tick()
        self.playerData[player.UserId].isOnline = false
        
        local success = pcall(function()
            PhoneDataStore:SetAsync(player.UserId, self.playerData[player.UserId])
        end)
        
        if success then
            print("📱 Saved WhatsApp data for " .. player.Name)
        end
    end
end

-- Cleanup Player Data
function WhatsAppPhoneServer:cleanupPlayerData(player)
    -- End active calls
    for callId, callData in pairs(self.activeCalls) do
        if callData.caller == player.UserId or callData.receiver == player.UserId then
            self:endCallInternal(callId)
        end
    end
    
    -- Leave voice rooms
    for roomId, roomData in pairs(self.voiceChatRooms) do
        if roomData.participants[player.UserId] then
            roomData.participants[player.UserId] = nil
            VoiceChatEvent:FireClient(player, "left_voice_room", roomId)
        end
    end
    
    self.playerData[player.UserId] = nil
end

-- Toggle Phone
function WhatsAppPhoneServer:togglePhone(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        playerData.isPhoneOpen = not playerData.isPhoneOpen
        PhoneToggleEvent:FireClient(player, playerData.isPhoneOpen)
        print("📱 " .. player.Name .. " toggled phone: " .. (playerData.isPhoneOpen and "OPEN" or "CLOSED"))
    end
end

-- Send SMS (WhatsApp-like)
function WhatsAppPhoneServer:sendSMS(sender, receiver, message)
    if not receiver or receiver == sender then return end
    
    local senderData = self.playerData[sender.UserId]
    local receiverData = self.playerData[receiver.UserId]
    
    if not senderData or not receiverData then return end
    
    local messageData = {
        id = tick(),
        sender = sender.UserId,
        receiver = receiver.UserId,
        message = message,
        timestamp = tick(),
        read = false,
        delivered = false
    }
    
    -- Store in sender's conversations
    if not senderData.smsConversations[receiver.UserId] then
        senderData.smsConversations[receiver.UserId] = {}
    end
    table.insert(senderData.smsConversations[receiver.UserId], messageData)
    
    -- Store in receiver's conversations
    if not receiverData.smsConversations[sender.UserId] then
        receiverData.smsConversations[sender.UserId] = {}
    end
    table.insert(receiverData.smsConversations[sender.UserId], messageData)
    
    -- Notify receiver
    SMSEvent:FireClient(receiver, "new_message", sender.Name, message, messageData.id)
    self:notifyPlayer(receiver, "New message from " .. sender.Name .. " 💬", "message")
    
    print("💬 " .. sender.Name .. " sent SMS to " .. receiver.Name .. ": " .. message)
end

-- Get SMS Conversations
function WhatsAppPhoneServer:getSMSConversations(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        SMSEvent:FireClient(player, "conversations", playerData.smsConversations)
    end
end

-- Get SMS Messages
function WhatsAppPhoneServer:getSMSMessages(player, targetPlayer)
    local playerData = self.playerData[player.UserId]
    if playerData and playerData.smsConversations[targetPlayer.UserId] then
        SMSEvent:FireClient(player, "messages", playerData.smsConversations[targetPlayer.UserId])
    end
end

-- Start Call
function WhatsAppPhoneServer:startCall(caller, receiver, callType)
    if not receiver or receiver == caller then return end
    
    local callId = tick()
    self.activeCalls[callId] = {
        caller = caller.UserId,
        receiver = receiver.UserId,
        callType = callType or "voice",
        startTime = tick(),
        status = "ringing",
        voiceRoomId = nil
    }
    
    -- Create voice room for voice calls
    if callType == "voice" then
        local roomId = "call_" .. callId
        self.voiceChatRooms[roomId] = {
            participants = {[caller.UserId] = true},
            callId = callId
        }
        self.activeCalls[callId].voiceRoomId = roomId
    end
    
    -- Notify both players
    CallEvent:FireClient(caller, "call_initiated", callId, receiver.Name, callType)
    CallEvent:FireClient(receiver, "incoming_call", callId, caller.Name, callType)
    
    -- Auto-reject after 30 seconds
    spawn(function()
        wait(30)
        if self.activeCalls[callId] and self.activeCalls[callId].status == "ringing" then
            self:rejectCall(receiver, caller)
        end
    end)
    
    print("📞 " .. caller.Name .. " calling " .. receiver.Name .. " (" .. callType .. ")")
end

-- Answer Call
function WhatsAppPhoneServer:answerCall(answerer, caller)
    for callId, callData in pairs(self.activeCalls) do
        if callData.caller == caller.UserId and callData.receiver == answerer.UserId then
            callData.status = "connected"
            callData.answerTime = tick()
            
            -- Add to voice room
            if callData.voiceRoomId and self.voiceChatRooms[callData.voiceRoomId] then
                self.voiceChatRooms[callData.voiceRoomId].participants[answerer.UserId] = true
                VoiceChatEvent:FireClient(answerer, "join_voice_room", callData.voiceRoomId)
                VoiceChatEvent:FireClient(caller, "join_voice_room", callData.voiceRoomId)
            end
            
            CallEvent:FireClient(caller, "call_answered", callId, answerer.Name)
            CallEvent:FireClient(answerer, "call_connected", callId, caller.Name)
            
            print("📞 " .. answerer.Name .. " answered call from " .. caller.Name)
            break
        end
    end
end

-- End Call
function WhatsAppPhoneServer:endCall(ender, otherPlayer)
    for callId, callData in pairs(self.activeCalls) do
        if (callData.caller == ender.UserId and callData.receiver == otherPlayer.UserId) or
           (callData.caller == otherPlayer.UserId and callData.receiver == ender.UserId) then
            self:endCallInternal(callId)
            break
        end
    end
end

-- End Call Internal
function WhatsAppPhoneServer:endCallInternal(callId)
    local callData = self.activeCalls[callId]
    if not callData then return end
    
    local caller = Players:GetPlayerByUserId(callData.caller)
    local receiver = Players:GetPlayerByUserId(callData.receiver)
    
    -- Remove from voice room
    if callData.voiceRoomId and self.voiceChatRooms[callData.voiceRoomId] then
        VoiceChatEvent:FireClient(caller, "leave_voice_room", callData.voiceRoomId)
        VoiceChatEvent:FireClient(receiver, "leave_voice_room", callData.voiceRoomId)
        self.voiceChatRooms[callData.voiceRoomId] = nil
    end
    
    -- Notify both players
    if caller then
        CallEvent:FireClient(caller, "call_ended", callId)
    end
    if receiver then
        CallEvent:FireClient(receiver, "call_ended", callId)
    end
    
    self.activeCalls[callId] = nil
    print("📞 Call " .. callId .. " ended")
end

-- Reject Call
function WhatsAppPhoneServer:rejectCall(rejecter, caller)
    for callId, callData in pairs(self.activeCalls) do
        if callData.caller == caller.UserId and callData.receiver == rejecter.UserId then
            callData.status = "rejected"
            
            CallEvent:FireClient(caller, "call_rejected", callId, rejecter.Name)
            CallEvent:FireClient(rejecter, "call_rejected", callId, caller.Name)
            
            self.activeCalls[callId] = nil
            print("📞 " .. rejecter.Name .. " rejected call from " .. caller.Name)
            break
        end
    end
end

-- Add Contact
function WhatsAppPhoneServer:addContact(player, targetPlayer)
    if not targetPlayer or targetPlayer == player then return end
    
    local playerData = self.playerData[player.UserId]
    local targetData = self.playerData[targetPlayer.UserId]
    
    if playerData and targetData then
        playerData.contacts[targetPlayer.UserId] = {
            name = targetPlayer.Name,
            phoneNumber = targetData.phoneNumber,
            addedTime = tick(),
            lastSeen = targetData.lastSeen,
            isOnline = targetData.isOnline,
            status = targetData.status
        }
        
        ContactEvent:FireClient(player, "contact_added", targetPlayer.Name)
        self:notifyPlayer(player, "Added " .. targetPlayer.Name .. " to contacts ✅", "success")
        
        print("👥 " .. player.Name .. " added " .. targetPlayer.Name .. " to contacts")
    end
end

-- Remove Contact
function WhatsAppPhoneServer:removeContact(player, targetPlayer)
    local playerData = self.playerData[player.UserId]
    if playerData and playerData.contacts[targetPlayer.UserId] then
        playerData.contacts[targetPlayer.UserId] = nil
        ContactEvent:FireClient(player, "contact_removed", targetPlayer.Name)
        print("👥 " .. player.Name .. " removed " .. targetPlayer.Name .. " from contacts")
    end
end

-- Get Contacts
function WhatsAppPhoneServer:getContacts(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        ContactEvent:FireClient(player, "contacts", playerData.contacts)
    end
end

-- Search Players
function WhatsAppPhoneServer:searchPlayers(player)
    local onlinePlayers = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pData = self.playerData[p.UserId]
            table.insert(onlinePlayers, {
                userId = p.UserId,
                name = p.Name,
                phoneNumber = pData and pData.phoneNumber or "Unknown",
                isOnline = true,
                status = pData and pData.status or "Available"
            })
        end
    end
    ContactEvent:FireClient(player, "search_results", onlinePlayers)
end

-- Join Voice Room
function WhatsAppPhoneServer:joinVoiceRoom(player, roomId)
    if self.voiceChatRooms[roomId] then
        self.voiceChatRooms[roomId].participants[player.UserId] = true
        VoiceChatEvent:FireClient(player, "joined_voice_room", roomId)
        print("🎤 " .. player.Name .. " joined voice room " .. roomId)
    end
end

-- Leave Voice Room
function WhatsAppPhoneServer:leaveVoiceRoom(player, roomId)
    if self.voiceChatRooms[roomId] then
        self.voiceChatRooms[roomId].participants[player.UserId] = nil
        VoiceChatEvent:FireClient(player, "left_voice_room", roomId)
        print("🎤 " .. player.Name .. " left voice room " .. roomId)
    end
end

-- Create Voice Room
function WhatsAppPhoneServer:createVoiceRoom(player, targetPlayer)
    local roomId = "room_" .. tick()
    self.voiceChatRooms[roomId] = {
        participants = {[player.UserId] = true},
        createdBy = player.UserId
    }
    
    VoiceChatEvent:FireClient(player, "voice_room_created", roomId)
    VoiceChatEvent:FireClient(targetPlayer, "voice_room_invite", roomId, player.Name)
    
    print("🎤 " .. player.Name .. " created voice room " .. roomId)
end

-- Notify Player
function WhatsAppPhoneServer:notifyPlayer(player, message, type)
    NotificationEvent:FireClient(player, message, type or "info")
end

-- Initialize Server
local whatsappServer = WhatsAppPhoneServer.new()

print("📱 WHATSAPP PHONE SYSTEM SERVER LOADED!")
print("🌟 Server Features:")
print("  💬 WhatsApp-like SMS System")
print("  📞 Voice & Video Calls")
print("  🎤 VoiceChat Integration")
print("  👥 Contact Management")
print("  📊 Data Persistence")
print("  🔔 Real-time Notifications")
print("✅ Server ready for WhatsApp Phone System!")