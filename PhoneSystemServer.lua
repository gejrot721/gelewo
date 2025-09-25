-- Roblox Phone System Server Script
-- Handles server-side phone system logic

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatService = game:GetService("VoiceChatService")

-- Wait for RemoteEvents
local phoneEvents = ReplicatedStorage:WaitForChild("PhoneEvents")
local callRemote = phoneEvents:WaitForChild("CallPlayer")
local chatRemote = phoneEvents:WaitForChild("ChatMessage")
local groupCallRemote = phoneEvents:WaitForChild("GroupCall")

-- Server-side phone system
local PhoneServer = {}
PhoneServer.activeCalls = {}
PhoneServer.groupCalls = {}
PhoneServer.playerStates = {}

function PhoneServer:InitializePlayer(player)
    self.playerStates[player.UserId] = {
        inCall = false,
        currentCall = nil,
        groupCallId = nil,
        muted = false
    }
end

function PhoneServer:HandleCall(sender, targetPlayerName, action)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if not targetPlayer then
        return
    end
    
    local senderState = self.playerStates[sender.UserId]
    local targetState = self.playerStates[targetPlayer.UserId]
    
    if not senderState or not targetState then
        return
    end
    
    if action == "call" then
        -- Check if target is available
        if targetState.inCall then
            -- Send busy signal
            callRemote:FireClient(sender, targetPlayerName, "busy")
            return
        end
        
        -- Send incoming call notification
        callRemote:FireClient(targetPlayer, sender.Name, "call")
        
        -- Store call info
        self.activeCalls[sender.UserId] = {
            caller = sender,
            target = targetPlayer,
            status = "ringing",
            startTime = tick()
        }
        
    elseif action == "answer" then
        local call = self.activeCalls[sender.UserId]
        if call and call.status == "ringing" then
            -- Accept call
            call.status = "active"
            senderState.inCall = true
            senderState.currentCall = targetPlayerName
            targetState.inCall = true
            targetState.currentCall = sender.Name
            
            -- Notify both players
            callRemote:FireClient(sender, targetPlayerName, "answer")
            callRemote:FireClient(targetPlayer, sender.Name, "answer")
            
            -- Set up voice chat channel if available
            if VoiceChatService then
                local channel = VoiceChatService:CreateChannel("Call_" .. sender.UserId .. "_" .. targetPlayer.UserId)
                VoiceChatService:JoinChannel(channel)
                sender:SetAttribute("VoiceChannel", channel)
                targetPlayer:SetAttribute("VoiceChannel", channel)
            end
            
        end
        
    elseif action == "decline" then
        local call = self.activeCalls[sender.UserId]
        if call then
            -- Decline call
            callRemote:FireClient(sender, targetPlayerName, "decline")
            self.activeCalls[sender.UserId] = nil
        end
        
    elseif action == "hangup" then
        -- Handle hangup
        if senderState.inCall then
            local callPartner = senderState.currentCall
            local callPartnerPlayer = Players:FindFirstChild(callPartner)
            
            if callPartnerPlayer then
                local partnerState = self.playerStates[callPartnerPlayer.UserId]
                if partnerState then
                    partnerState.inCall = false
                    partnerState.currentCall = nil
                    callRemote:FireClient(callPartnerPlayer, sender.Name, "hangup")
                end
            end
            
            senderState.inCall = false
            senderState.currentCall = nil
            
            -- Leave voice channel
            if sender:GetAttribute("VoiceChannel") then
                VoiceChatService:LeaveChannel(sender:GetAttribute("VoiceChannel"))
                sender:SetAttribute("VoiceChannel", nil)
            end
            
            callRemote:FireClient(sender, callPartner, "hangup")
        end
        
        -- Clean up call
        for userId, call in pairs(self.activeCalls) do
            if (call.caller == sender and call.target.Name == targetPlayerName) or
               (call.target == sender and call.caller.Name == targetPlayerName) then
                self.activeCalls[userId] = nil
                break
            end
        end
    end
end

function PhoneServer:HandleChat(sender, targetPlayerName, message)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if not targetPlayer then
        return
    end
    
    -- Validate message
    if not message or message == "" or #message > 200 then
        return
    end
    
    -- Filter inappropriate content (basic implementation)
    local filteredMessage = message:gsub("[<>]", "")
    
    -- Send message to target
    chatRemote:FireClient(targetPlayer, sender.Name, filteredMessage)
    
    -- Log message for moderation
    print("Chat: " .. sender.Name .. " -> " .. targetPlayerName .. ": " .. filteredMessage)
end

function PhoneServer:HandleGroupCall(sender, action, members)
    if action == "create" then
        local groupCallId = "Group_" .. sender.UserId .. "_" .. tick()
        self.groupCalls[groupCallId] = {
            creator = sender,
            members = {sender},
            status = "active",
            startTime = tick()
        }
        
        -- Add creator to group call
        self.playerStates[sender.UserId].groupCallId = groupCallId
        
        -- Notify creator
        groupCallRemote:FireClient(sender, {sender.Name}, "created")
        
    elseif action == "invite" then
        local groupCallId = self.playerStates[sender.UserId].groupCallId
        local groupCall = self.groupCalls[groupCallId]
        
        if groupCall and groupCall.creator == sender then
            for _, memberName in ipairs(members) do
                local memberPlayer = Players:FindFirstChild(memberName)
                if memberPlayer and not self.playerStates[memberPlayer.UserId].inCall then
                    table.insert(groupCall.members, memberPlayer)
                    self.playerStates[memberPlayer.UserId].groupCallId = groupCallId
                    self.playerStates[memberPlayer.UserId].inCall = true
                    
                    -- Send invitation
                    groupCallRemote:FireClient(memberPlayer, self:GetMemberNames(groupCall.members), "invite")
                end
            end
            
            -- Update all members
            groupCallRemote:FireClient(sender, self:GetMemberNames(groupCall.members), "updated")
        end
        
    elseif action == "join" then
        local groupCallId = self.playerStates[sender.UserId].groupCallId
        local groupCall = self.groupCalls[groupCallId]
        
        if groupCall then
            sender:SetAttribute("VoiceChannel", groupCallId)
            
            -- Set up voice chat
            if VoiceChatService then
                local channel = VoiceChatService:CreateChannel(groupCallId)
                VoiceChatService:JoinChannel(channel)
            end
            
            -- Notify all members
            for _, member in ipairs(groupCall.members) do
                if member ~= sender then
                    groupCallRemote:FireClient(member, self:GetMemberNames(groupCall.members), "join")
                end
            end
            
            groupCallRemote:FireClient(sender, self:GetMemberNames(groupCall.members), "joined")
        end
        
    elseif action == "leave" then
        local groupCallId = self.playerStates[sender.UserId].groupCallId
        local groupCall = self.groupCalls[groupCallId]
        
        if groupCall then
            -- Remove from group
            for i, member in ipairs(groupCall.members) do
                if member == sender then
                    table.remove(groupCall.members, i)
                    break
                end
            end
            
            -- Update states
            self.playerStates[sender.UserId].groupCallId = nil
            self.playerStates[sender.UserId].inCall = false
            
            -- Leave voice channel
            if sender:GetAttribute("VoiceChannel") then
                VoiceChatService:LeaveChannel(sender:GetAttribute("VoiceChannel"))
                sender:SetAttribute("VoiceChannel", nil)
            end
            
            -- Notify remaining members
            for _, member in ipairs(groupCall.members) do
                groupCallRemote:FireClient(member, self:GetMemberNames(groupCall.members), "updated")
            end
            
            -- Clean up if empty
            if #groupCall.members == 0 then
                self.groupCalls[groupCallId] = nil
            end
        end
    end
end

function PhoneServer:GetMemberNames(members)
    local names = {}
    for _, member in ipairs(members) do
        table.insert(names, member.Name)
    end
    return names
end

function PhoneServer:CleanupPlayer(player)
    local playerState = self.playerStates[player.UserId]
    if playerState then
        -- Handle ongoing calls
        if playerState.inCall then
            if playerState.currentCall then
                local callPartner = Players:FindFirstChild(playerState.currentCall)
                if callPartner then
                    local partnerState = self.playerStates[callPartner.UserId]
                    if partnerState then
                        partnerState.inCall = false
                        partnerState.currentCall = nil
                        callRemote:FireClient(callPartner, player.Name, "hangup")
                    end
                end
            end
        end
        
        -- Handle group calls
        if playerState.groupCallId then
            self:HandleGroupCall(player, "leave")
        end
        
        -- Clean up state
        self.playerStates[player.UserId] = nil
        
        -- Clean up active calls
        for userId, call in pairs(self.activeCalls) do
            if call.caller == player or call.target == player then
                self.activeCalls[userId] = nil
            end
        end
    end
end

-- Set up event connections
callRemote.OnServerEvent:Connect(function(player, targetPlayerName, action)
    PhoneServer:HandleCall(player, targetPlayerName, action)
end)

chatRemote.OnServerEvent:Connect(function(player, targetPlayerName, message)
    PhoneServer:HandleChat(player, targetPlayerName, message)
end)

groupCallRemote.OnServerEvent:Connect(function(player, action, members)
    PhoneServer:HandleGroupCall(player, action, members)
end)

-- Initialize players
Players.PlayerAdded:Connect(function(player)
    PhoneServer:InitializePlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    PhoneServer:CleanupPlayer(player)
end)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
    PhoneServer:InitializePlayer(player)
end

print("Phone system server initialized successfully!")