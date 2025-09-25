-- PhoneSystemServer.lua
-- Server-side script untuk sistem telepon Roblox dengan menu iPhone terbaru
-- Place this in ServerScriptService

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Create RemoteEvents for client-server communication
local PhoneEvents = Instance.new("Folder")
PhoneEvents.Name = "PhoneEvents"
PhoneEvents.Parent = ReplicatedStorage

-- RemoteEvents
local Events = {
    TogglePhone = Instance.new("RemoteEvent"),
    SwitchFeature = Instance.new("RemoteEvent"),
    SendChatMessage = Instance.new("RemoteEvent"),
    StartCall = Instance.new("RemoteEvent"),
    EndCall = Instance.new("RemoteEvent"),
    PlayMusic = Instance.new("RemoteEvent"),
    StopMusic = Instance.new("RemoteEvent"),
    UpdateSettings = Instance.new("RemoteEvent"),
    LaunchGame = Instance.new("RemoteEvent"),
    AddContact = Instance.new("RemoteEvent"),
    DeleteContact = Instance.new("RemoteEvent"),
    UpdateContactStatus = Instance.new("RemoteEvent"),
    SendNotification = Instance.new("RemoteEvent"),
    GetPlayerData = Instance.new("RemoteEvent")
}

for name, event in pairs(Events) do
    event.Name = name
    event.Parent = PhoneEvents
end

-- Server-side data storage
local ServerData = {
    ActiveCalls = {},
    ChatMessages = {},
    MusicPlayers = {},
    PlayerSettings = {},
    PlayerContacts = {},
    Notifications = {}
}

-- Enhanced sample data with more realistic content
local SampleData = {
    Games = {
        {
            name = "Adopt Me!",
            description = "Pet simulation game",
            icon = "🐾",
            gameId = 920587237,
            color = Color3.fromRGB(255, 182, 193),
            category = "Simulation",
            rating = 4.8,
            players = "500K+"
        },
        {
            name = "Brookhaven RP",
            description = "Roleplay simulation",
            icon = "🏠",
            gameId = 4924922222,
            color = Color3.fromRGB(144, 238, 144),
            category = "Roleplay",
            rating = 4.7,
            players = "1M+"
        },
        {
            name = "Tower Defense",
            description = "Strategy tower defense",
            icon = "🏰",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 215, 0),
            category = "Strategy",
            rating = 4.5,
            players = "100K+"
        },
        {
            name = "Obby Creator",
            description = "Create your own obby",
            icon = "🎯",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 165, 0),
            category = "Building",
            rating = 4.6,
            players = "200K+"
        },
        {
            name = "Simulator Games",
            description = "Various simulator games",
            icon = "⚡",
            gameId = 1962086868,
            color = Color3.fromRGB(138, 43, 226),
            category = "Simulation",
            rating = 4.4,
            players = "300K+"
        },
        {
            name = "Racing Games",
            description = "Fast-paced racing",
            icon = "🏎️",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 69, 0),
            category = "Racing",
            rating = 4.3,
            players = "150K+"
        },
        {
            name = "FPS Games",
            description = "First person shooter",
            icon = "🔫",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 100, 100),
            category = "Action",
            rating = 4.2,
            players = "250K+"
        },
        {
            name = "Puzzle Games",
            description = "Brain teasers and puzzles",
            icon = "🧩",
            gameId = 1962086868,
            color = Color3.fromRGB(100, 200, 255),
            category = "Puzzle",
            rating = 4.5,
            players = "80K+"
        }
    },
    
    Contacts = {
        {
            name = "Mom",
            number = "+1-555-0101",
            avatar = "👩",
            color = Color3.fromRGB(255, 182, 193),
            status = "online",
            lastSeen = "2 minutes ago",
            isFavorite = true
        },
        {
            name = "Dad",
            number = "+1-555-0102",
            avatar = "👨",
            color = Color3.fromRGB(173, 216, 230),
            status = "busy",
            lastSeen = "1 hour ago",
            isFavorite = true
        },
        {
            name = "Best Friend",
            number = "+1-555-0103",
            avatar = "👫",
            color = Color3.fromRGB(144, 238, 144),
            status = "online",
            lastSeen = "now",
            isFavorite = true
        },
        {
            name = "Sister",
            number = "+1-555-0104",
            avatar = "👧",
            color = Color3.fromRGB(255, 215, 0),
            status = "away",
            lastSeen = "30 minutes ago",
            isFavorite = false
        },
        {
            name = "Brother",
            number = "+1-555-0105",
            avatar = "👦",
            color = Color3.fromRGB(255, 165, 0),
            status = "online",
            lastSeen = "5 minutes ago",
            isFavorite = false
        },
        {
            name = "Emergency",
            number = "911",
            avatar = "🚨",
            color = Color3.fromRGB(255, 69, 0),
            status = "always",
            lastSeen = "always available",
            isFavorite = true
        },
        {
            name = "Work",
            number = "+1-555-0200",
            avatar = "💼",
            color = Color3.fromRGB(100, 100, 100),
            status = "offline",
            lastSeen = "yesterday",
            isFavorite = false
        },
        {
            name = "Doctor",
            number = "+1-555-0300",
            avatar = "👨‍⚕️",
            color = Color3.fromRGB(255, 255, 255),
            status = "offline",
            lastSeen = "2 days ago",
            isFavorite = false
        }
    },
    
    MusicLibrary = {
        {
            title = "Epic Adventure",
            artist = "Game Music Studio",
            duration = "3:45",
            genre = "Epic",
            icon = "🎵",
            color = Color3.fromRGB(255, 100, 100),
            soundId = 131961136,
            album = "Game Soundtracks Vol. 1",
            year = 2024,
            isFavorite = true
        },
        {
            title = "Chill Vibes",
            artist = "Relax Music",
            duration = "4:20",
            genre = "Chill",
            icon = "🌊",
            color = Color3.fromRGB(100, 255, 100),
            soundId = 131961136,
            album = "Relaxation Collection",
            year = 2024,
            isFavorite = true
        },
        {
            title = "Electronic Dreams",
            artist = "Synth Master",
            duration = "3:15",
            genre = "Electronic",
            icon = "⚡",
            color = Color3.fromRGB(100, 100, 255),
            soundId = 131961136,
            album = "Digital Universe",
            year = 2024,
            isFavorite = false
        },
        {
            title = "Rock Anthem",
            artist = "Rock Band",
            duration = "4:05",
            genre = "Rock",
            icon = "🎸",
            color = Color3.fromRGB(255, 255, 100),
            soundId = 131961136,
            album = "Rock Legends",
            year = 2024,
            isFavorite = true
        },
        {
            title = "Jazz Night",
            artist = "Smooth Jazz",
            duration = "5:30",
            genre = "Jazz",
            icon = "🎷",
            color = Color3.fromRGB(255, 165, 0),
            soundId = 131961136,
            album = "Midnight Sessions",
            year = 2024,
            isFavorite = false
        },
        {
            title = "Classical Symphony",
            artist = "Orchestra",
            duration = "6:15",
            genre = "Classical",
            icon = "🎼",
            color = Color3.fromRGB(138, 43, 226),
            soundId = 131961136,
            album = "Symphony Collection",
            year = 2024,
            isFavorite = true
        },
        {
            title = "Pop Hit",
            artist = "Pop Star",
            duration = "3:30",
            genre = "Pop",
            icon = "🎤",
            color = Color3.fromRGB(255, 20, 147),
            soundId = 131961136,
            album = "Chart Toppers",
            year = 2024,
            isFavorite = true
        },
        {
            title = "Hip Hop Beat",
            artist = "Rap Artist",
            duration = "4:00",
            genre = "Hip Hop",
            icon = "🎧",
            color = Color3.fromRGB(0, 255, 0),
            soundId = 131961136,
            album = "Street Vibes",
            year = 2024,
            isFavorite = false
        }
    }
}

-- Initialize player data
local function initializePlayerData(player)
    ServerData.PlayerSettings[player.UserId] = {
        volume = 0.5,
        notifications = true,
        autoPlay = false,
        theme = "dark",
        language = "en",
        wallpaper = "default",
        ringtone = "default",
        vibration = true,
        darkMode = true,
        fontSize = "medium"
    }
    
    ServerData.PlayerContacts[player.UserId] = SampleData.Contacts
    
    -- Send initial data to client
    Events.SwitchFeature:FireClient(player, "data", {
        games = SampleData.Games,
        contacts = SampleData.Contacts,
        music = SampleData.MusicLibrary,
        settings = ServerData.PlayerSettings[player.UserId]
    })
    
    print("📱 Initialized enhanced phone data for " .. player.Name)
end

-- Handle player joining
local function onPlayerAdded(player)
    initializePlayerData(player)
    
    -- Send welcome notification
    spawn(function()
        wait(2)
        local welcomeNotification = {
            id = "welcome_" .. player.UserId,
            title = "Welcome to Phone System!",
            message = "Press F1 or click the menu button to open your phone",
            icon = "📱",
            timestamp = os.time(),
            isRead = false
        }
        
        if not ServerData.Notifications[player.UserId] then
            ServerData.Notifications[player.UserId] = {}
        end
        
        table.insert(ServerData.Notifications[player.UserId], welcomeNotification)
        Events.SendNotification:FireClient(player, welcomeNotification)
    end)
end

-- Handle player leaving
local function onPlayerRemoving(player)
    -- Clean up player data
    if ServerData.ActiveCalls[player.UserId] then
        ServerData.ActiveCalls[player.UserId] = nil
    end
    
    if ServerData.MusicPlayers[player.UserId] then
        ServerData.MusicPlayers[player.UserId] = nil
    end
    
    ServerData.PlayerSettings[player.UserId] = nil
    ServerData.PlayerContacts[player.UserId] = nil
    ServerData.Notifications[player.UserId] = nil
    
    print("📱 Cleaned up enhanced phone data for " .. player.Name)
end

-- Enhanced Event handlers
Events.TogglePhone.OnServerEvent:Connect(function(player)
    print("📱 " .. player.Name .. " toggled iPhone-style phone")
end)

Events.SwitchFeature.OnServerEvent:Connect(function(player, feature, data)
    print("📱 " .. player.Name .. " switched to " .. feature)
    
    if feature == "games" then
        Events.SwitchFeature:FireClient(player, "games", SampleData.Games)
    elseif feature == "chat" then
        Events.SwitchFeature:FireClient(player, "chat", ServerData.ChatMessages)
    elseif feature == "phone" then
        local playerContacts = ServerData.PlayerContacts[player.UserId] or SampleData.Contacts
        Events.SwitchFeature:FireClient(player, "phone", playerContacts)
    elseif feature == "music" then
        Events.SwitchFeature:FireClient(player, "music", SampleData.MusicLibrary)
    elseif feature == "settings" then
        Events.SwitchFeature:FireClient(player, "settings", ServerData.PlayerSettings[player.UserId])
    elseif feature == "notifications" then
        local notifications = ServerData.Notifications[player.UserId] or {}
        Events.SwitchFeature:FireClient(player, "notifications", notifications)
    end
end)

Events.SendChatMessage.OnServerEvent:Connect(function(player, messageData)
    messageData.sender = player.Name
    messageData.time = os.date("%H:%M")
    messageData.timestamp = os.time()
    
    table.insert(ServerData.ChatMessages, messageData)
    
    -- Broadcast to all players
    Events.SendChatMessage:FireAllClients(messageData)
    
    print("💬 " .. player.Name .. " sent message: " .. messageData.text)
end)

Events.StartCall.OnServerEvent:Connect(function(player, contactData)
    ServerData.ActiveCalls[player.UserId] = {
        contact = contactData,
        startTime = tick(),
        status = "ringing",
        callId = "call_" .. player.UserId .. "_" .. os.time()
    }
    
    -- Notify all clients about the call
    Events.StartCall:FireAllClients(player.UserId, contactData)
    
    -- Send notification to other players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local notification = {
                id = "call_" .. player.UserId,
                title = "Incoming Call",
                message = player.Name .. " is calling " .. contactData.name,
                icon = "📞",
                timestamp = os.time(),
                isRead = false
            }
            
            if not ServerData.Notifications[otherPlayer.UserId] then
                ServerData.Notifications[otherPlayer.UserId] = {}
            end
            
            table.insert(ServerData.Notifications[otherPlayer.UserId], notification)
            Events.SendNotification:FireClient(otherPlayer, notification)
        end
    end
    
    print("📞 " .. player.Name .. " started call with " .. contactData.name)
end)

Events.EndCall.OnServerEvent:Connect(function(player)
    if ServerData.ActiveCalls[player.UserId] then
        local callData = ServerData.ActiveCalls[player.UserId]
        ServerData.ActiveCalls[player.UserId] = nil
        
        -- Notify all clients about call end
        Events.EndCall:FireAllClients(player.UserId)
        
        print("📞 " .. player.Name .. " ended call with " .. callData.contact.name)
    end
end)

Events.PlayMusic.OnServerEvent:Connect(function(player, trackData)
    ServerData.MusicPlayers[player.UserId] = {
        track = trackData,
        startTime = tick(),
        isPlaying = true,
        position = 0
    }
    
    print("🎵 " .. player.Name .. " playing: " .. trackData.title)
end)

Events.StopMusic.OnServerEvent:Connect(function(player)
    if ServerData.MusicPlayers[player.UserId] then
        ServerData.MusicPlayers[player.UserId] = nil
        print("🎵 " .. player.Name .. " stopped music")
    end
end)

Events.UpdateSettings.OnServerEvent:Connect(function(player, settingsData)
    ServerData.PlayerSettings[player.UserId] = settingsData
    
    print("⚙️ " .. player.Name .. " updated settings")
end)

Events.LaunchGame.OnServerEvent:Connect(function(player, gameData)
    print("🎮 " .. player.Name .. " launching game: " .. gameData.name)
    
    -- In real implementation, you would use MarketplaceService here
    -- MarketplaceService:PromptGamePassPurchase(player, gameData.gameId)
    
    -- Simulate game launch
    Events.LaunchGame:FireClient(player, gameData)
end)

Events.AddContact.OnServerEvent:Connect(function(player, contactData)
    if not ServerData.PlayerContacts[player.UserId] then
        ServerData.PlayerContacts[player.UserId] = {}
    end
    
    table.insert(ServerData.PlayerContacts[player.UserId], contactData)
    
    print("📞 " .. player.Name .. " added contact: " .. contactData.name)
end)

Events.DeleteContact.OnServerEvent:Connect(function(player, contactId)
    if ServerData.PlayerContacts[player.UserId] then
        for i, contact in ipairs(ServerData.PlayerContacts[player.UserId]) do
            if contact.id == contactId then
                table.remove(ServerData.PlayerContacts[player.UserId], i)
                print("📞 " .. player.Name .. " deleted contact: " .. contact.name)
                break
            end
        end
    end
end)

Events.UpdateContactStatus.OnServerEvent:Connect(function(player, contactId, newStatus)
    if ServerData.PlayerContacts[player.UserId] then
        for _, contact in ipairs(ServerData.PlayerContacts[player.UserId]) do
            if contact.id == contactId then
                contact.status = newStatus
                contact.lastSeen = "now"
                print("📞 " .. player.Name .. " updated contact status: " .. contact.name .. " -> " .. newStatus)
                break
            end
        end
    end
end)

Events.SendNotification.OnServerEvent:Connect(function(player, notificationData)
    if not ServerData.Notifications[player.UserId] then
        ServerData.Notifications[player.UserId] = {}
    end
    
    table.insert(ServerData.Notifications[player.UserId], notificationData)
    
    print("🔔 " .. player.Name .. " received notification: " .. notificationData.title)
end)

Events.GetPlayerData.OnServerEvent:Connect(function(player)
    local playerData = {
        settings = ServerData.PlayerSettings[player.UserId],
        contacts = ServerData.PlayerContacts[player.UserId],
        notifications = ServerData.Notifications[player.UserId],
        activeCall = ServerData.ActiveCalls[player.UserId],
        musicPlayer = ServerData.MusicPlayers[player.UserId]
    }
    
    Events.GetPlayerData:FireClient(player, playerData)
end)

-- Enhanced random chat messages
spawn(function()
    while true do
        wait(math.random(20, 60))
        
        local randomMessages = {
            "Anyone want to play together?",
            "This game is so fun! 🎉",
            "Check out my new build!",
            "Need help with something?",
            "Great job everyone! 👏",
            "What's everyone up to?",
            "Just discovered this awesome game!",
            "Anyone know any good games?",
            "Having a great time here! 😊",
            "This phone system is amazing! 📱",
            "Love the new features! ✨",
            "Anyone want to chat? 💬",
            "Playing some music 🎵",
            "Making new friends! 👥"
        }
        
        local randomSenders = {"Player" .. math.random(1, 20), "Guest" .. math.random(1000, 9999), "RobloxUser" .. math.random(100, 999)}
        
        local message = {
            sender = randomSenders[math.random(1, #randomSenders)],
            text = randomMessages[math.random(1, #randomMessages)],
            time = os.date("%H:%M"),
            channel = "Global",
            timestamp = os.time()
        }
        
        table.insert(ServerData.ChatMessages, message)
        Events.SendChatMessage:FireAllClients(message)
    end
end)

-- Simulate contact status updates
spawn(function()
    while true do
        wait(math.random(30, 120))
        
        for userId, contacts in pairs(ServerData.PlayerContacts) do
            for _, contact in ipairs(contacts) do
                if contact.status ~= "always" and contact.status ~= "emergency" then
                    local statuses = {"online", "away", "busy", "offline"}
                    contact.status = statuses[math.random(1, #statuses)]
                    
                    if contact.status == "online" then
                        contact.lastSeen = "now"
                    elseif contact.status == "away" then
                        contact.lastSeen = math.random(5, 30) .. " minutes ago"
                    elseif contact.status == "busy" then
                        contact.lastSeen = math.random(1, 3) .. " hours ago"
                    else
                        contact.lastSeen = math.random(1, 7) .. " days ago"
                    end
                end
            end
        end
    end
end)

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

print("🚀 Enhanced iPhone-style Phone System Server initialized!")
print("📱 Server ready to handle advanced phone system requests")
print("💬 Enhanced chat system with timestamps")
print("📞 Advanced call management with notifications")
print("🎵 Music system with player tracking")
print("⚙️ Enhanced settings with more options")
print("🔔 Notification system active")
print("📞 Contact management system ready")
print("🎮 Game launching system ready")