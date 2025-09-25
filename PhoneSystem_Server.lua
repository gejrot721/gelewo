-- ========================================
-- SISTEM HANDPHONE ROBLOX - SERVER SCRIPT
-- ========================================
-- Pasang script ini di ServerScriptService
-- Script ini akan membuat semua yang diperlukan secara otomatis!

print("🚀 Memulai instalasi sistem handphone...")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local VoiceChatService = game:GetService("VoiceChatService")

-- ========================================
-- KONFIGURASI SISTEM
-- ========================================
local PhoneConfig = {
    Colors = {
        Primary = Color3.fromRGB(76, 175, 80),
        PrimaryDark = Color3.fromRGB(56, 142, 60),
        Accent = Color3.fromRGB(33, 150, 243),
        Background = Color3.fromRGB(33, 33, 33),
        Surface = Color3.fromRGB(45, 45, 45),
        Text = Color3.new(1, 1, 1),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Error = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Success = Color3.fromRGB(76, 175, 80)
    },
    Language = "Indonesian",
    Texts = {
        Indonesian = {
            Phone = "Handphone",
            Home = "Beranda",
            Contacts = "Kontak",
            Chat = "Pesan",
            Calls = "Panggilan",
            SearchPlayers = "Cari pemain...",
            TypeMessage = "Ketik pesan...",
            IncomingCall = "Panggilan masuk dari",
            Answer = "Angkat",
            Decline = "Tolak",
            HangUp = "Tutup",
            Mute = "Bisukan",
            Unmute = "Suarakan",
            QuickCall = "Panggilan Cepat",
            QuickChat = "Chat Cepat",
            GroupCall = "Panggilan Grup",
            Online = "Online",
            Offline = "Offline",
            Busy = "Sibuk",
            NoAnswer = "Tidak Menjawab",
            StartCall = "Mulai Panggilan",
            EndCall = "Akhiri Panggilan",
            JoinCall = "Bergabung",
            LeaveCall = "Keluar",
            Settings = "Pengaturan",
            Volume = "Volume",
            Microphone = "Mikrofon",
            Speaker = "Speaker",
            Connected = "Terhubung",
            Disconnected = "Terputus",
            Connecting = "Menghubungkan...",
            CallEnded = "Panggilan Berakhir",
            CallStarted = "Panggilan Dimulai",
            ErrorOccurred = "Terjadi Kesalahan",
            TryAgain = "Coba Lagi",
            Cancel = "Batal",
            Confirm = "Konfirmasi",
            Yes = "Ya",
            No = "Tidak",
            OK = "OK"
        }
    }
}

function PhoneConfig:GetText(key)
    return self.Texts[self.Language][key] or key
end

-- ========================================
-- SETUP OTOMATIS
-- ========================================
local function createFolderIfNotExists(parent, folderName)
    local folder = parent:FindFirstChild(folderName)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = parent
        print("✅ Folder " .. folderName .. " berhasil dibuat")
    end
    return folder
end

local function createRemoteEventIfNotExists(parent, eventName)
    local event = parent:FindFirstChild(eventName)
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = eventName
        event.Parent = parent
        print("✅ RemoteEvent " .. eventName .. " berhasil dibuat")
    end
    return event
end

-- Setup PhoneEvents di ReplicatedStorage
local phoneEventsFolder = createFolderIfNotExists(ReplicatedStorage, "PhoneEvents")
local callRemote = createRemoteEventIfNotExists(phoneEventsFolder, "CallPlayer")
local chatRemote = createRemoteEventIfNotExists(phoneEventsFolder, "ChatMessage")
local groupCallRemote = createRemoteEventIfNotExists(phoneEventsFolder, "GroupCall")

-- Setup PhoneConfig di ReplicatedStorage untuk client
local phoneConfig = ReplicatedStorage:FindFirstChild("PhoneConfig")
if not phoneConfig then
    phoneConfig = Instance.new("ModuleScript")
    phoneConfig.Name = "PhoneConfig"
    phoneConfig.Parent = ReplicatedStorage
    phoneConfig.Source = [[
local PhoneConfig = {}

PhoneConfig.Colors = {
    Primary = Color3.fromRGB(76, 175, 80),
    PrimaryDark = Color3.fromRGB(56, 142, 60),
    Accent = Color3.fromRGB(33, 150, 243),
    Background = Color3.fromRGB(33, 33, 33),
    Surface = Color3.fromRGB(45, 45, 45),
    Text = Color3.new(1, 1, 1),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    Error = Color3.fromRGB(244, 67, 54),
    Warning = Color3.fromRGB(255, 152, 0),
    Success = Color3.fromRGB(76, 175, 80)
}

PhoneConfig.Language = "Indonesian"
PhoneConfig.Texts = {
    Indonesian = {
        Phone = "Handphone",
        Home = "Beranda",
        Contacts = "Kontak",
        Chat = "Pesan",
        Calls = "Panggilan",
        SearchPlayers = "Cari pemain...",
        TypeMessage = "Ketik pesan...",
        IncomingCall = "Panggilan masuk dari",
        Answer = "Angkat",
        Decline = "Tolak",
        HangUp = "Tutup",
        Mute = "Bisukan",
        Unmute = "Suarakan",
        QuickCall = "Panggilan Cepat",
        QuickChat = "Chat Cepat",
        GroupCall = "Panggilan Grup",
        Online = "Online",
        Offline = "Offline",
        Busy = "Sibuk",
        NoAnswer = "Tidak Menjawab",
        StartCall = "Mulai Panggilan",
        EndCall = "Akhiri Panggilan",
        JoinCall = "Bergabung",
        LeaveCall = "Keluar",
        Settings = "Pengaturan",
        Volume = "Volume",
        Microphone = "Mikrofon",
        Speaker = "Speaker",
        Connected = "Terhubung",
        Disconnected = "Terputus",
        Connecting = "Menghubungkan...",
        CallEnded = "Panggilan Berakhir",
        CallStarted = "Panggilan Dimulai",
        ErrorOccurred = "Terjadi Kesalahan",
        TryAgain = "Coba Lagi",
        Cancel = "Batal",
        Confirm = "Konfirmasi",
        Yes = "Ya",
        No = "Tidak",
        OK = "OK"
    }
}

function PhoneConfig:GetText(key)
    return self.Texts[self.Language][key] or key
end

return PhoneConfig
]]
    print("✅ PhoneConfig berhasil dibuat untuk client")
end

print("🎉 Setup otomatis selesai!")

-- ========================================
-- SISTEM HANDPHONE SERVER
-- ========================================
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
    print("📱 Player " .. player.Name .. " berhasil diinisialisasi")
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
        if targetState.inCall then
            callRemote:FireClient(sender, targetPlayerName, "busy")
            return
        end
        
        callRemote:FireClient(targetPlayer, sender.Name, "call")
        
        self.activeCalls[sender.UserId] = {
            caller = sender,
            target = targetPlayer,
            status = "ringing",
            startTime = tick()
        }
        
    elseif action == "answer" then
        local call = self.activeCalls[sender.UserId]
        if call and call.status == "ringing" then
            call.status = "active"
            senderState.inCall = true
            senderState.currentCall = targetPlayerName
            targetState.inCall = true
            targetState.currentCall = sender.Name
            
            callRemote:FireClient(sender, targetPlayerName, "answer")
            callRemote:FireClient(targetPlayer, sender.Name, "answer")
            
            -- Voice chat setup
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
            callRemote:FireClient(sender, targetPlayerName, "decline")
            self.activeCalls[sender.UserId] = nil
        end
        
    elseif action == "hangup" then
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
            
            if sender:GetAttribute("VoiceChannel") then
                VoiceChatService:LeaveChannel(sender:GetAttribute("VoiceChannel"))
                sender:SetAttribute("VoiceChannel", nil)
            end
            
            callRemote:FireClient(sender, callPartner, "hangup")
        end
        
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
    
    if not message or message == "" or #message > 200 then
        return
    end
    
    local filteredMessage = message:gsub("[<>]", "")
    chatRemote:FireClient(targetPlayer, sender.Name, filteredMessage)
    
    print("💬 Chat: " .. sender.Name .. " -> " .. targetPlayerName .. ": " .. filteredMessage)
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
        
        self.playerStates[sender.UserId].groupCallId = groupCallId
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
                    
                    groupCallRemote:FireClient(memberPlayer, self:GetMemberNames(groupCall.members), "invite")
                end
            end
            
            groupCallRemote:FireClient(sender, self:GetMemberNames(groupCall.members), "updated")
        end
        
    elseif action == "join" then
        local groupCallId = self.playerStates[sender.UserId].groupCallId
        local groupCall = self.groupCalls[groupCallId]
        
        if groupCall then
            sender:SetAttribute("VoiceChannel", groupCallId)
            
            if VoiceChatService then
                local channel = VoiceChatService:CreateChannel(groupCallId)
                VoiceChatService:JoinChannel(channel)
            end
            
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
            for i, member in ipairs(groupCall.members) do
                if member == sender then
                    table.remove(groupCall.members, i)
                    break
                end
            end
            
            self.playerStates[sender.UserId].groupCallId = nil
            self.playerStates[sender.UserId].inCall = false
            
            if sender:GetAttribute("VoiceChannel") then
                VoiceChatService:LeaveChannel(sender:GetAttribute("VoiceChannel"))
                sender:SetAttribute("VoiceChannel", nil)
            end
            
            for _, member in ipairs(groupCall.members) do
                groupCallRemote:FireClient(member, self:GetMemberNames(groupCall.members), "updated")
            end
            
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
        
        if playerState.groupCallId then
            self:HandleGroupCall(player, "leave")
        end
        
        self.playerStates[player.UserId] = nil
        
        for userId, call in pairs(self.activeCalls) do
            if call.caller == player or call.target == player then
                self.activeCalls[userId] = nil
            end
        end
    end
end

-- ========================================
-- EVENT CONNECTIONS
-- ========================================
callRemote.OnServerEvent:Connect(function(player, targetPlayerName, action)
    PhoneServer:HandleCall(player, targetPlayerName, action)
end)

chatRemote.OnServerEvent:Connect(function(player, targetPlayerName, message)
    PhoneServer:HandleChat(player, targetPlayerName, message)
end)

groupCallRemote.OnServerEvent:Connect(function(player, action, members)
    PhoneServer:HandleGroupCall(player, action, members)
end)

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

print("🎉 Sistem handphone server berhasil diinisialisasi!")
print("📱 Player dapat menggunakan fitur:")
print("   • Panggilan individual dan grup")
print("   • Chat text real-time")
print("   • Voice chat integration")
print("   • UI dalam bahasa Indonesia")
print("⚠️  Jangan lupa aktifkan Voice Chat di Game Settings!")