-- PhoneSystemServer.lua
-- Server-side script untuk sistem telepon Roblox
-- Place this in ServerScriptService

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
    UpdateSettings = Instance.new("RemoteEvent"),
    LaunchGame = Instance.new("RemoteEvent")
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
    PlayerSettings = {}
}

-- Sample data
local SampleData = {
    Games = {
        {
            name = "Adopt Me!",
            description = "Pet simulation game",
            icon = "🐾",
            gameId = 920587237,
            color = Color3.fromRGB(255, 182, 193)
        },
        {
            name = "Brookhaven RP",
            description = "Roleplay simulation",
            icon = "🏠",
            gameId = 4924922222,
            color = Color3.fromRGB(144, 238, 144)
        },
        {
            name = "Tower Defense",
            description = "Strategy tower defense",
            icon = "🏰",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 215, 0)
        },
        {
            name = "Obby Creator",
            description = "Create your own obby",
            icon = "🎯",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 165, 0)
        },
        {
            name = "Simulator Games",
            description = "Various simulator games",
            icon = "⚡",
            gameId = 1962086868,
            color = Color3.fromRGB(138, 43, 226)
        },
        {
            name = "Racing Games",
            description = "Fast-paced racing",
            icon = "🏎️",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 69, 0)
        }
    },
    
    Contacts = {
        {
            name = "Mom",
            number = "+1-555-0101",
            avatar = "👩",
            color = Color3.fromRGB(255, 182, 193),
            status = "online"
        },
        {
            name = "Dad",
            number = "+1-555-0102",
            avatar = "👨",
            color = Color3.fromRGB(173, 216, 230),
            status = "busy"
        },
        {
            name = "Best Friend",
            number = "+1-555-0103",
            avatar = "👫",
            color = Color3.fromRGB(144, 238, 144),
            status = "online"
        },
        {
            name = "Sister",
            number = "+1-555-0104",
            avatar = "👧",
            color = Color3.fromRGB(255, 215, 0),
            status = "away"
        },
        {
            name = "Brother",
            number = "+1-555-0105",
            avatar = "👦",
            color = Color3.fromRGB(255, 165, 0),
            status = "online"
        },
        {
            name = "Emergency",
            number = "911",
            avatar = "🚨",
            color = Color3.fromRGB(255, 69, 0),
            status = "always"
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
            soundId = 131961136
        },
        {
            title = "Chill Vibes",
            artist = "Relax Music",
            duration = "4:20",
            genre = "Chill",
            icon = "🌊",
            color = Color3.fromRGB(100, 255, 100),
            soundId = 131961136
        },
        {
            title = "Electronic Dreams",
            artist = "Synth Master",
            duration = "3:15",
            genre = "Electronic",
            icon = "⚡",
            color = Color3.fromRGB(100, 100, 255),
            soundId = 131961136
        },
        {
            title = "Rock Anthem",
            artist = "Rock Band",
            duration = "4:05",
            genre = "Rock",
            icon = "🎸",
            color = Color3.fromRGB(255, 255, 100),
            soundId = 131961136
        },
        {
            title = "Jazz Night",
            artist = "Smooth Jazz",
            duration = "5:30",
            genre = "Jazz",
            icon = "🎷",
            color = Color3.fromRGB(255, 165, 0),
            soundId = 131961136
        },
        {
            title = "Classical Symphony",
            artist = "Orchestra",
            duration = "6:15",
            genre = "Classical",
            icon = "🎼",
            color = Color3.fromRGB(138, 43, 226),
            soundId = 131961136
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
        language = "en"
    }
    
    -- Send initial data to client
    Events.SwitchFeature:FireClient(player, "data", {
        games = SampleData.Games,
        contacts = SampleData.Contacts,
        music = SampleData.MusicLibrary
    })
    
    print("📱 Initialized phone data for " .. player.Name)
end

-- Handle player joining
local function onPlayerAdded(player)
    initializePlayerData(player)
    
    -- Send welcome message after a delay
    spawn(function()
        wait(3)
        local welcomeMessage = {
            sender = "System",
            text = "Welcome to the Phone System! Press F1 or click ☰ to open your phone.",
            time = os.date("%H:%M"),
            channel = "Global"
        }
        
        table.insert(ServerData.ChatMessages, welcomeMessage)
        Events.SendChatMessage:FireAllClients(welcomeMessage)
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
    
    print("📱 Cleaned up phone data for " .. player.Name)
end

-- Event handlers
Events.TogglePhone.OnServerEvent:Connect(function(player)
    print("📱 " .. player.Name .. " toggled phone")
end)

Events.SwitchFeature.OnServerEvent:Connect(function(player, feature, data)
    print("📱 " .. player.Name .. " switched to " .. feature)
    
    if feature == "games" then
        Events.SwitchFeature:FireClient(player, "games", SampleData.Games)
    elseif feature == "chat" then
        Events.SwitchFeature:FireClient(player, "chat", ServerData.ChatMessages)
    elseif feature == "phone" then
        Events.SwitchFeature:FireClient(player, "phone", SampleData.Contacts)
    elseif feature == "music" then
        Events.SwitchFeature:FireClient(player, "music", SampleData.MusicLibrary)
    elseif feature == "settings" then
        Events.SwitchFeature:FireClient(player, "settings", ServerData.PlayerSettings[player.UserId])
    end
end)

Events.SendChatMessage.OnServerEvent:Connect(function(player, messageData)
    messageData.sender = player.Name
    messageData.time = os.date("%H:%M")
    
    table.insert(ServerData.ChatMessages, messageData)
    
    -- Broadcast to all players
    Events.SendChatMessage:FireAllClients(messageData)
    
    print("💬 " .. player.Name .. " sent message: " .. messageData.text)
end)

Events.StartCall.OnServerEvent:Connect(function(player, contactData)
    ServerData.ActiveCalls[player.UserId] = {
        contact = contactData,
        startTime = tick(),
        status = "ringing"
    }
    
    -- Notify all clients about the call
    Events.StartCall:FireAllClients(player.UserId, contactData)
    
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
        isPlaying = true
    }
    
    print("🎵 " .. player.Name .. " playing: " .. trackData.title)
end)

Events.UpdateSettings.OnServerEvent:Connect(function(player, settingsData)
    ServerData.PlayerSettings[player.UserId] = settingsData
    
    print("⚙️ " .. player.Name .. " updated settings")
end)

Events.LaunchGame.OnServerEvent:Connect(function(player, gameData)
    -- In a real implementation, you would use MarketplaceService here
    print("🎮 " .. player.Name .. " launching game: " .. gameData.name)
    
    -- Simulate game launch
    Events.LaunchGame:FireClient(player, gameData)
end)

-- Simulate random chat messages
spawn(function()
    while true do
        wait(math.random(15, 45))
        
        local randomMessages = {
            "Anyone want to play together?",
            "This game is so fun! 🎉",
            "Check out my new build!",
            "Need help with something?",
            "Great job everyone! 👏",
            "What's everyone up to?",
            "Just discovered this awesome game!",
            "Anyone know any good games?",
            "Having a great time here! 😊"
        }
        
        local randomSenders = {"Player" .. math.random(1, 10), "Guest" .. math.random(1000, 9999)}
        
        local message = {
            sender = randomSenders[math.random(1, #randomSenders)],
            text = randomMessages[math.random(1, #randomMessages)],
            time = os.date("%H:%M"),
            channel = "Global"
        }
        
        table.insert(ServerData.ChatMessages, message)
        Events.SendChatMessage:FireAllClients(message)
    end
end)

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

print("🚀 Phone System Server initialized successfully!")
print("📱 Server ready to handle phone system requests")
print("💬 Chat system active with random messages")
print("📞 Call system ready")
print("🎵 Music system ready")
print("⚙️ Settings system ready")