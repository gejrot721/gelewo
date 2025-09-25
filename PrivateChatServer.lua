-- 💬 PRIVATE CHAT SYSTEM - SERVER SCRIPT
-- Features: Private Chat, Group Chat, Modern UI, Auto-scale
-- Place this script in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Create RemoteEvents folder
local ChatEvents = Instance.new("Folder")
ChatEvents.Name = "ChatEvents"
ChatEvents.Parent = ReplicatedStorage

-- RemoteEvents for communication
local ChatToggleEvent = Instance.new("RemoteEvent")
ChatToggleEvent.Name = "ChatToggle"
ChatToggleEvent.Parent = ChatEvents

local PrivateChatEvent = Instance.new("RemoteEvent")
PrivateChatEvent.Name = "PrivateChat"
PrivateChatEvent.Parent = ChatEvents

local GroupChatEvent = Instance.new("RemoteEvent")
GroupChatEvent.Name = "GroupChat"
GroupChatEvent.Parent = ChatEvents

local ChatDataEvent = Instance.new("RemoteEvent")
ChatDataEvent.Name = "ChatData"
ChatDataEvent.Parent = ChatEvents

local NotificationEvent = Instance.new("RemoteEvent")
NotificationEvent.Name = "Notification"
NotificationEvent.Parent = ChatEvents

-- DataStore for persistent data
local ChatDataStore = DataStoreService:GetDataStore("PrivateChatData")

-- Private Chat Server Class
local PrivateChatServer = {}
PrivateChatServer.__index = PrivateChatServer

function PrivateChatServer.new()
    local self = setmetatable({}, PrivateChatServer)
    
    -- Server data storage
    self.playerData = {}
    self.privateChats = {}
    self.groupChats = {}
    self.onlinePlayers = {}
    
    -- Initialize
    self:setupEventHandlers()
    self:setupPlayerHandling()
    
    return self
end

-- Setup Event Handlers
function PrivateChatServer:setupEventHandlers()
    -- Chat Toggle
    ChatToggleEvent.OnServerEvent:Connect(function(player)
        self:toggleChat(player)
    end)
    
    -- Private Chat Events
    PrivateChatEvent.OnServerEvent:Connect(function(player, action, targetPlayer, message)
        if action == "send_message" then
            self:sendPrivateMessage(player, targetPlayer, message)
        elseif action == "get_conversation" then
            self:getPrivateConversation(player, targetPlayer)
        elseif action == "get_conversations" then
            self:getPrivateConversations(player)
        elseif action == "start_chat" then
            self:startPrivateChat(player, targetPlayer)
        end
    end)
    
    -- Group Chat Events
    GroupChatEvent.OnServerEvent:Connect(function(player, action, groupId, message, groupName)
        if action == "create_group" then
            self:createGroupChat(player, groupName)
        elseif action == "join_group" then
            self:joinGroupChat(player, groupId)
        elseif action == "leave_group" then
            self:leaveGroupChat(player, groupId)
        elseif action == "send_group_message" then
            self:sendGroupMessage(player, groupId, message)
        elseif action == "get_group_messages" then
            self:getGroupMessages(player, groupId)
        elseif action == "get_groups" then
            self:getPlayerGroups(player)
        elseif action == "invite_to_group" then
            self:inviteToGroup(player, groupId, targetPlayer)
        end
    end)
    
    -- Chat Data Events
    ChatDataEvent.OnServerEvent:Connect(function(player, action)
        if action == "get_online_players" then
            self:getOnlinePlayers(player)
        elseif action == "get_player_data" then
            self:getPlayerData(player)
        end
    end)
end

-- Setup Player Handling
function PrivateChatServer:setupPlayerHandling()
    Players.PlayerAdded:Connect(function(player)
        self:loadPlayerData(player)
        self.onlinePlayers[player.UserId] = {
            name = player.Name,
            userId = player.UserId,
            joinTime = tick(),
            isOnline = true,
            status = "Online"
        }
        self:notifyAllPlayers(player.Name .. " joined the chat! 👋", "join")
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:savePlayerData(player)
        self.onlinePlayers[player.UserId] = nil
        self:notifyAllPlayers(player.Name .. " left the chat 👋", "leave")
    end)
end

-- Load Player Data
function PrivateChatServer:loadPlayerData(player)
    local success, data = pcall(function()
        return ChatDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        self.playerData[player.UserId] = data
    else
        -- Default chat data
        self.playerData[player.UserId] = {
            privateChats = {},
            groupChats = {},
            settings = {
                notifications = true,
                soundEnabled = true,
                darkMode = true,
                fontSize = "medium",
                autoScroll = true
            },
            lastSeen = tick(),
            isOnline = true,
            status = "Available",
            avatar = "👤"
        }
    end
    
    print("💬 Loaded chat data for " .. player.Name)
end

-- Save Player Data
function PrivateChatServer:savePlayerData(player)
    if self.playerData[player.UserId] then
        self.playerData[player.UserId].lastSeen = tick()
        self.playerData[player.UserId].isOnline = false
        
        local success = pcall(function()
            ChatDataStore:SetAsync(player.UserId, self.playerData[player.UserId])
        end)
        
        if success then
            print("💬 Saved chat data for " .. player.Name)
        end
    end
end

-- Toggle Chat
function PrivateChatServer:toggleChat(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        playerData.isChatOpen = not playerData.isChatOpen
        ChatToggleEvent:FireClient(player, playerData.isChatOpen)
        print("💬 " .. player.Name .. " toggled chat: " .. (playerData.isChatOpen and "OPEN" or "CLOSED"))
    end
end

-- Send Private Message
function PrivateChatServer:sendPrivateMessage(sender, receiver, message)
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
    
    -- Store in sender's private chats
    if not senderData.privateChats[receiver.UserId] then
        senderData.privateChats[receiver.UserId] = {}
    end
    table.insert(senderData.privateChats[receiver.UserId], messageData)
    
    -- Store in receiver's private chats
    if not receiverData.privateChats[sender.UserId] then
        receiverData.privateChats[sender.UserId] = {}
    end
    table.insert(receiverData.privateChats[sender.UserId], messageData)
    
    -- Notify receiver
    PrivateChatEvent:FireClient(receiver, "new_private_message", sender.Name, message, messageData.id)
    self:notifyPlayer(receiver, "New message from " .. sender.Name .. " 💬", "message")
    
    print("💬 " .. sender.Name .. " sent private message to " .. receiver.Name .. ": " .. message)
end

-- Get Private Conversation
function PrivateChatServer:getPrivateConversation(player, targetPlayer)
    local playerData = self.playerData[player.UserId]
    if playerData and playerData.privateChats[targetPlayer.UserId] then
        PrivateChatEvent:FireClient(player, "private_conversation", playerData.privateChats[targetPlayer.UserId])
    end
end

-- Get Private Conversations
function PrivateChatServer:getPrivateConversations(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        PrivateChatEvent:FireClient(player, "private_conversations", playerData.privateChats)
    end
end

-- Start Private Chat
function PrivateChatServer:startPrivateChat(player, targetPlayer)
    if not targetPlayer or targetPlayer == player then return end
    
    local playerData = self.playerData[player.UserId]
    local targetData = self.playerData[targetPlayer.UserId]
    
    if playerData and targetData then
        -- Initialize chat if doesn't exist
        if not playerData.privateChats[targetPlayer.UserId] then
            playerData.privateChats[targetPlayer.UserId] = {}
        end
        if not targetData.privateChats[player.UserId] then
            targetData.privateChats[player.UserId] = {}
        end
        
        PrivateChatEvent:FireClient(player, "private_chat_started", targetPlayer.Name)
        print("💬 " .. player.Name .. " started private chat with " .. targetPlayer.Name)
    end
end

-- Create Group Chat
function PrivateChatServer:createGroupChat(player, groupName)
    local groupId = "group_" .. tick()
    local playerData = self.playerData[player.UserId]
    
    if playerData then
        self.groupChats[groupId] = {
            id = groupId,
            name = groupName or "Group Chat",
            creator = player.UserId,
            members = {[player.UserId] = true},
            messages = {},
            createdTime = tick(),
            settings = {
                maxMembers = 20,
                allowInvites = true,
                public = false
            }
        }
        
        -- Add to player's groups
        if not playerData.groupChats then
            playerData.groupChats = {}
        end
        playerData.groupChats[groupId] = true
        
        GroupChatEvent:FireClient(player, "group_created", groupId, groupName)
        self:notifyPlayer(player, "Group '" .. groupName .. "' created! 🎉", "success")
        
        print("👥 " .. player.Name .. " created group chat: " .. groupName)
    end
end

-- Join Group Chat
function PrivateChatServer:joinGroupChat(player, groupId)
    local groupData = self.groupChats[groupId]
    local playerData = self.playerData[player.UserId]
    
    if groupData and playerData and not groupData.members[player.UserId] then
        -- Check if group has space
        local memberCount = 0
        for _ in pairs(groupData.members) do
            memberCount = memberCount + 1
        end
        
        if memberCount < groupData.settings.maxMembers then
            groupData.members[player.UserId] = true
            
            -- Add to player's groups
            if not playerData.groupChats then
                playerData.groupChats = {}
            end
            playerData.groupChats[groupId] = true
            
            GroupChatEvent:FireClient(player, "joined_group", groupId, groupData.name)
            self:notifyGroupMembers(groupId, player.Name .. " joined the group! 👋", "join")
            
            print("👥 " .. player.Name .. " joined group: " .. groupData.name)
        else
            self:notifyPlayer(player, "Group is full! 😔", "error")
        end
    end
end

-- Leave Group Chat
function PrivateChatServer:leaveGroupChat(player, groupId)
    local groupData = self.groupChats[groupId]
    local playerData = self.playerData[player.UserId]
    
    if groupData and playerData and groupData.members[player.UserId] then
        groupData.members[player.UserId] = nil
        
        -- Remove from player's groups
        if playerData.groupChats then
            playerData.groupChats[groupId] = nil
        end
        
        GroupChatEvent:FireClient(player, "left_group", groupId)
        self:notifyGroupMembers(groupId, player.Name .. " left the group 👋", "leave")
        
        -- If creator leaves, transfer ownership or delete group
        if groupData.creator == player.UserId then
            local newCreator = nil
            for memberId, _ in pairs(groupData.members) do
                newCreator = memberId
                break
            end
            
            if newCreator then
                groupData.creator = newCreator
                self:notifyGroupMembers(groupId, "Group ownership transferred", "info")
            else
                self.groupChats[groupId] = nil
                print("👥 Group " .. groupData.name .. " deleted (no members left)")
            end
        end
        
        print("👥 " .. player.Name .. " left group: " .. groupData.name)
    end
end

-- Send Group Message
function PrivateChatServer:sendGroupMessage(sender, groupId, message)
    local groupData = self.groupChats[groupId]
    local senderData = self.playerData[sender.UserId]
    
    if groupData and senderData and groupData.members[sender.UserId] then
        local messageData = {
            id = tick(),
            sender = sender.UserId,
            senderName = sender.Name,
            message = message,
            timestamp = tick(),
            groupId = groupId
        }
        
        table.insert(groupData.messages, messageData)
        
        -- Notify all group members
        for memberId, _ in pairs(groupData.members) do
            local member = Players:GetPlayerByUserId(memberId)
            if member and member ~= sender then
                GroupChatEvent:FireClient(member, "new_group_message", groupId, sender.Name, message, messageData.id)
            end
        end
        
        print("👥 " .. sender.Name .. " sent group message in " .. groupData.name .. ": " .. message)
    end
end

-- Get Group Messages
function PrivateChatServer:getGroupMessages(player, groupId)
    local groupData = self.groupChats[groupId]
    local playerData = self.playerData[player.UserId]
    
    if groupData and playerData and groupData.members[player.UserId] then
        GroupChatEvent:FireClient(player, "group_messages", groupId, groupData.messages)
    end
end

-- Get Player Groups
function PrivateChatServer:getPlayerGroups(player)
    local playerData = self.playerData[player.UserId]
    if playerData and playerData.groupChats then
        local groups = {}
        for groupId, _ in pairs(playerData.groupChats) do
            if self.groupChats[groupId] then
                table.insert(groups, {
                    id = groupId,
                    name = self.groupChats[groupId].name,
                    memberCount = self:getGroupMemberCount(groupId),
                    lastMessage = self:getLastGroupMessage(groupId)
                })
            end
        end
        GroupChatEvent:FireClient(player, "player_groups", groups)
    end
end

-- Invite to Group
function PrivateChatServer:inviteToGroup(inviter, groupId, targetPlayer)
    local groupData = self.groupChats[groupId]
    local inviterData = self.playerData[inviter.UserId]
    
    if groupData and inviterData and groupData.members[inviter.UserId] and targetPlayer ~= inviter then
        -- Check if group has space
        local memberCount = 0
        for _ in pairs(groupData.members) do
            memberCount = memberCount + 1
        end
        
        if memberCount < groupData.settings.maxMembers then
            GroupChatEvent:FireClient(targetPlayer, "group_invite", groupId, groupData.name, inviter.Name)
            self:notifyPlayer(targetPlayer, "You're invited to join '" .. groupData.name .. "' by " .. inviter.Name .. "! 🎉", "invite")
            print("👥 " .. inviter.Name .. " invited " .. targetPlayer.Name .. " to group: " .. groupData.name)
        else
            self:notifyPlayer(inviter, "Group is full! Cannot invite more members 😔", "error")
        end
    end
end

-- Get Online Players
function PrivateChatServer:getOnlinePlayers(player)
    local onlineList = {}
    for userId, playerData in pairs(self.onlinePlayers) do
        if userId ~= player.UserId then
            table.insert(onlineList, {
                userId = userId,
                name = playerData.name,
                status = playerData.status,
                isOnline = playerData.isOnline
            })
        end
    end
    ChatDataEvent:FireClient(player, "online_players", onlineList)
end

-- Get Player Data
function PrivateChatServer:getPlayerData(player)
    local playerData = self.playerData[player.UserId]
    if playerData then
        ChatDataEvent:FireClient(player, "player_data", playerData)
    end
end

-- Helper Functions
function PrivateChatServer:getGroupMemberCount(groupId)
    local groupData = self.groupChats[groupId]
    if groupData then
        local count = 0
        for _ in pairs(groupData.members) do
            count = count + 1
        end
        return count
    end
    return 0
end

function PrivateChatServer:getLastGroupMessage(groupId)
    local groupData = self.groupChats[groupId]
    if groupData and #groupData.messages > 0 then
        return groupData.messages[#groupData.messages]
    end
    return nil
end

function PrivateChatServer:notifyGroupMembers(groupId, message, type)
    local groupData = self.groupChats[groupId]
    if groupData then
        for memberId, _ in pairs(groupData.members) do
            local member = Players:GetPlayerByUserId(memberId)
            if member then
                self:notifyPlayer(member, message, type)
            end
        end
    end
end

function PrivateChatServer:notifyPlayer(player, message, type)
    NotificationEvent:FireClient(player, message, type or "info")
end

function PrivateChatServer:notifyAllPlayers(message, type)
    for _, player in pairs(Players:GetPlayers()) do
        self:notifyPlayer(player, message, type)
    end
end

-- Initialize Server
local privateChatServer = PrivateChatServer.new()

print("💬 PRIVATE CHAT SYSTEM SERVER LOADED!")
print("🌟 Server Features:")
print("  💬 Private Chat System")
print("  👥 Group Chat System")
print("  📊 Data Persistence")
print("  🔔 Real-time Notifications")
print("  👥 Online Player Management")
print("  📱 Modern Chat Interface")
print("✅ Server ready for Private Chat System!")