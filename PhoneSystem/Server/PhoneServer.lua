-- PhoneServer.lua
-- Server-side script untuk mengelola sistem handphone

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PhoneConfig = require(script.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Shared.PhoneTypes)

local PhoneServer = {}

-- Server state
local serverState = {
    activeCalls = {}, -- callId -> call data
    activeGroupCalls = {}, -- callId -> group call data
    playerCalls = {}, -- userId -> callId
    messageHistory = {}, -- conversationId -> messages
    onlinePlayers = {} -- userId -> player data
}

-- Initialize server
function PhoneServer.initialize()
    print("Initializing Phone Server...")
    
    -- Create remote events
    PhoneServer.createRemoteEvents()
    
    -- Setup player connections
    PhoneServer.setupPlayerConnections()
    
    -- Start server heartbeat
    PhoneServer.startHeartbeat()
    
    print("Phone Server initialized successfully")
end

-- Create remote events
function PhoneServer.createRemoteEvents()
    local remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = "PhoneSystemEvent"
    remoteEvent.Parent = ReplicatedStorage
    
    local voiceChatEvent = Instance.new("RemoteEvent")
    voiceChatEvent.Name = "PhoneVoiceChatEvent"
    voiceChatEvent.Parent = ReplicatedStorage
    
    local contactEvent = Instance.new("RemoteEvent")
    contactEvent.Name = "PhoneContactEvent"
    contactEvent.Parent = ReplicatedStorage
end

-- Setup player connections
function PhoneServer.setupPlayerConnections()
    Players.PlayerAdded:Connect(function(player)
        PhoneServer.onPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        PhoneServer.onPlayerRemoving(player)
    end)
    
    -- Setup remote event connections
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent.OnServerEvent:Connect(function(player, action, data)
        PhoneServer.handleClientEvent(player, action, data)
    end)
end

-- Handle player added
function PhoneServer.onPlayerAdded(player)
    print("Player joined:", player.Name)
    
    -- Add player to online list
    serverState.onlinePlayers[player.UserId] = {
        userId = player.UserId,
        username = player.Name,
        displayName = player.DisplayName,
        isOnline = true,
        lastSeen = tick(),
        joinTime = tick()
    }
    
    -- Notify other players about new player
    PhoneServer.notifyPlayerOnline(player)
end

-- Handle player removing
function PhoneServer.onPlayerRemoving(player)
    print("Player leaving:", player.Name)
    
    -- End any active calls for this player
    PhoneServer.endPlayerCalls(player.UserId)
    
    -- Update player status
    if serverState.onlinePlayers[player.UserId] then
        serverState.onlinePlayers[player.UserId].isOnline = false
        serverState.onlinePlayers[player.UserId].lastSeen = tick()
    end
    
    -- Notify other players about player going offline
    PhoneServer.notifyPlayerOffline(player)
end

-- Handle client events
function PhoneServer.handleClientEvent(player, action, data)
    print("Received event from", player.Name, ":", action)
    
    if action == "StartCall" then
        PhoneServer.handleStartCall(player, data)
        
    elseif action == "AnswerCall" then
        PhoneServer.handleAnswerCall(player, data)
        
    elseif action == "DeclineCall" then
        PhoneServer.handleDeclineCall(player, data)
        
    elseif action == "EndCall" then
        PhoneServer.handleEndCall(player, data)
        
    elseif action == "StartGroupCall" then
        PhoneServer.handleStartGroupCall(player, data)
        
    elseif action == "SendMessage" then
        PhoneServer.handleSendMessage(player, data)
        
    elseif action == "GetOnlinePlayers" then
        PhoneServer.handleGetOnlinePlayers(player, data)
        
    elseif action == "ParticipantSpeakingChanged" then
        PhoneServer.handleParticipantSpeakingChanged(player, data)
        
    elseif action == "VoiceChatFailed" then
        PhoneServer.handleVoiceChatFailed(player, data)
    end
end

-- Handle start call
function PhoneServer.handleStartCall(player, data)
    local targetUserId = data.targetUserId
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    
    if not targetPlayer then
        print("Target player not found:", targetUserId)
        return
    end
    
    -- Generate call ID
    local callId = "call_" .. player.UserId .. "_" .. targetUserId .. "_" .. tostring(tick())
    
    -- Create call data
    local callData = {
        callId = callId,
        callerId = player.UserId,
        calleeId = targetUserId,
        startTime = tick(),
        status = PhoneTypes.CallStatus.RINGING,
        isGroupCall = false,
        participants = {player.UserId, targetUserId}
    }
    
    -- Store call
    serverState.activeCalls[callId] = callData
    serverState.playerCalls[player.UserId] = callId
    serverState.playerCalls[targetUserId] = callId
    
    -- Send incoming call to target player
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireClient(targetPlayer, "IncomingCall", {
        callId = callId,
        contact = {
            userId = player.UserId,
            username = player.Name,
            displayName = player.DisplayName
        }
    })
    
    print("Call started:", callId, "from", player.Name, "to", targetPlayer.Name)
end

-- Handle answer call
function PhoneServer.handleAnswerCall(player, data)
    local callId = serverState.playerCalls[player.UserId]
    if not callId or not serverState.activeCalls[callId] then
        print("No active call found for player:", player.Name)
        return
    end
    
    local callData = serverState.activeCalls[callId]
    callData.status = PhoneTypes.CallStatus.CONNECTED
    
    -- Notify both players
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    
    -- Notify caller
    local callerPlayer = Players:GetPlayerByUserId(callData.callerId)
    if callerPlayer then
        remoteEvent:FireClient(callerPlayer, "CallAnswered", {
            callId = callId,
            contact = {
                userId = player.UserId,
                username = player.Name,
                displayName = player.DisplayName
            }
        })
    end
    
    -- Notify callee
    remoteEvent:FireClient(player, "CallAnswered", {
        callId = callId,
        contact = {
            userId = callData.callerId,
            username = callerPlayer and callerPlayer.Name or "Unknown",
            displayName = callerPlayer and callerPlayer.DisplayName or "Unknown"
        }
    })
    
    print("Call answered:", callId, "by", player.Name)
end

-- Handle decline call
function PhoneServer.handleDeclineCall(player, data)
    local callId = serverState.playerCalls[player.UserId]
    if not callId or not serverState.activeCalls[callId] then
        return
    end
    
    local callData = serverState.activeCalls[callId]
    callData.status = PhoneTypes.CallStatus.DECLINED
    
    -- Notify caller
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    local callerPlayer = Players:GetPlayerByUserId(callData.callerId)
    if callerPlayer then
        remoteEvent:FireClient(callerPlayer, "CallEnded", {
            callId = callId,
            reason = "declined"
        })
    end
    
    -- Clean up call
    PhoneServer.cleanupCall(callId)
    
    print("Call declined:", callId, "by", player.Name)
end

-- Handle end call
function PhoneServer.handleEndCall(player, data)
    local callId = serverState.playerCalls[player.UserId]
    if not callId then
        return
    end
    
    local callData = serverState.activeCalls[callId]
    if callData then
        callData.status = PhoneTypes.CallStatus.ENDED
        callData.endTime = tick()
        
        -- Notify all participants
        local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
        for _, participantId in pairs(callData.participants) do
            local participant = Players:GetPlayerByUserId(participantId)
            if participant then
                remoteEvent:FireClient(participant, "CallEnded", {
                    callId = callId,
                    reason = "ended"
                })
            end
        end
        
        -- Clean up call
        PhoneServer.cleanupCall(callId)
        
        print("Call ended:", callId, "by", player.Name)
    end
end

-- Handle start group call
function PhoneServer.handleStartGroupCall(player, data)
    local participantUserIds = data.participantUserIds
    if #participantUserIds < 2 then
        print("Group call requires at least 2 participants")
        return
    end
    
    -- Generate group call ID
    local callId = "group_" .. player.UserId .. "_" .. tostring(tick())
    
    -- Create group call data
    local groupCallData = {
        callId = callId,
        creatorId = player.UserId,
        startTime = tick(),
        status = PhoneTypes.CallStatus.CONNECTED,
        isGroupCall = true,
        participants = participantUserIds
    }
    
    -- Store group call
    serverState.activeGroupCalls[callId] = groupCallData
    for _, userId in pairs(participantUserIds) do
        serverState.playerCalls[userId] = callId
    end
    
    -- Notify all participants
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    for _, userId in pairs(participantUserIds) do
        local participant = Players:GetPlayerByUserId(userId)
        if participant then
            remoteEvent:FireClient(participant, "GroupCallStarted", {
                callId = callId,
                participants = PhoneServer.getParticipantData(participantUserIds)
            })
        end
    end
    
    print("Group call started:", callId, "with", #participantUserIds, "participants")
end

-- Handle send message
function PhoneServer.handleSendMessage(player, data)
    local receiverId = data.receiverId
    local content = data.content
    
    if not content or content:gsub("%s+", "") == "" then
        return
    end
    
    -- Create message
    local message = {
        messageId = "msg_" .. tostring(tick()),
        senderId = player.UserId,
        receiverId = receiverId,
        content = content,
        timestamp = tick(),
        messageType = PhoneTypes.MessageType.TEXT,
        isRead = false
    }
    
    -- Store message
    local conversationId = PhoneServer.getConversationId(player.UserId, receiverId)
    if not serverState.messageHistory[conversationId] then
        serverState.messageHistory[conversationId] = {}
    end
    table.insert(serverState.messageHistory[conversationId], message)
    
    -- Send message to receiver
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    local receiver = Players:GetPlayerByUserId(receiverId)
    if receiver then
        remoteEvent:FireClient(receiver, "MessageReceived", {
            message = message,
            senderId = player.UserId
        })
    end
    
    print("Message sent from", player.Name, "to", receiverId)
end

-- Handle get online players
function PhoneServer.handleGetOnlinePlayers(player, data)
    local onlinePlayers = {}
    for userId, playerData in pairs(serverState.onlinePlayers) do
        if playerData.isOnline and userId ~= player.UserId then
            table.insert(onlinePlayers, playerData)
        end
    end
    
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireClient(player, "OnlinePlayers", {
        players = onlinePlayers
    })
end

-- Handle participant speaking changed
function PhoneServer.handleParticipantSpeakingChanged(player, data)
    -- Broadcast speaking changes to other participants in the same call
    local callId = serverState.playerCalls[player.UserId]
    if not callId then return end
    
    local callData = serverState.activeCalls[callId] or serverState.activeGroupCalls[callId]
    if not callData then return end
    
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    for _, participantId in pairs(callData.participants) do
        if participantId ~= player.UserId then
            local participant = Players:GetPlayerByUserId(participantId)
            if participant then
                remoteEvent:FireClient(participant, "ParticipantSpeakingChanged", {
                    participant = player.UserId,
                    speaking = data.speaking
                })
            end
        end
    end
end

-- Handle voice chat failed
function PhoneServer.handleVoiceChatFailed(player, data)
    -- Log the failure and potentially notify other players
    print("Voice chat failed for player:", player.Name, "Error:", data.error)
end

-- Utility functions
function PhoneServer.getConversationId(userId1, userId2)
    if userId1 < userId2 then
        return userId1 .. "_" .. userId2
    else
        return userId2 .. "_" .. userId1
    end
end

function PhoneServer.getParticipantData(participantUserIds)
    local participantData = {}
    for _, userId in pairs(participantUserIds) do
        local playerData = serverState.onlinePlayers[userId]
        if playerData then
            table.insert(participantData, playerData)
        end
    end
    return participantData
end

function PhoneServer.endPlayerCalls(userId)
    local callId = serverState.playerCalls[userId]
    if callId then
        local callData = serverState.activeCalls[callId] or serverState.activeGroupCalls[callId]
        if callData then
            callData.status = PhoneTypes.CallStatus.ENDED
            callData.endTime = tick()
            
            -- Notify other participants
            local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
            for _, participantId in pairs(callData.participants) do
                if participantId ~= userId then
                    local participant = Players:GetPlayerByUserId(participantId)
                    if participant then
                        remoteEvent:FireClient(participant, "CallEnded", {
                            callId = callId,
                            reason = "player_left"
                        })
                    end
                end
            end
            
            PhoneServer.cleanupCall(callId)
        end
    end
end

function PhoneServer.cleanupCall(callId)
    local callData = serverState.activeCalls[callId] or serverState.activeGroupCalls[callId]
    if callData then
        -- Remove from player calls
        for _, participantId in pairs(callData.participants) do
            serverState.playerCalls[participantId] = nil
        end
        
        -- Remove from active calls
        serverState.activeCalls[callId] = nil
        serverState.activeGroupCalls[callId] = nil
        
        print("Call cleaned up:", callId)
    end
end

function PhoneServer.notifyPlayerOnline(player)
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    
    -- Notify all other players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            remoteEvent:FireClient(otherPlayer, "PlayerOnline", {
                userId = player.UserId,
                username = player.Name,
                displayName = player.DisplayName
            })
        end
    end
end

function PhoneServer.notifyPlayerOffline(player)
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    
    -- Notify all other players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            remoteEvent:FireClient(otherPlayer, "PlayerOffline", {
                userId = player.UserId,
                username = player.Name,
                displayName = player.DisplayName
            })
        end
    end
end

-- Start server heartbeat
function PhoneServer.startHeartbeat()
    RunService.Heartbeat:Connect(function()
        -- Clean up old calls (longer than 1 hour)
        local currentTime = tick()
        for callId, callData in pairs(serverState.activeCalls) do
            if currentTime - callData.startTime > 3600 then -- 1 hour
                PhoneServer.cleanupCall(callId)
            end
        end
        
        for callId, callData in pairs(serverState.activeGroupCalls) do
            if currentTime - callData.startTime > 3600 then -- 1 hour
                PhoneServer.cleanupCall(callId)
            end
        end
        
        -- Update player online status
        for _, player in pairs(Players:GetPlayers()) do
            if serverState.onlinePlayers[player.UserId] then
                serverState.onlinePlayers[player.UserId].lastSeen = currentTime
            end
        end
    end)
end

-- Initialize server
PhoneServer.initialize()

return PhoneServer