-- PhoneSystemClient.lua
-- Client-side script untuk sistem telepon Roblox
-- Place this in StarterPlayer > StarterPlayerScripts

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Wait for RemoteEvents
local PhoneEvents = ReplicatedStorage:WaitForChild("PhoneEvents")
local Events = {
    TogglePhone = PhoneEvents:WaitForChild("TogglePhone"),
    SwitchFeature = PhoneEvents:WaitForChild("SwitchFeature"),
    SendChatMessage = PhoneEvents:WaitForChild("SendChatMessage"),
    StartCall = PhoneEvents:WaitForChild("StartCall"),
    EndCall = PhoneEvents:WaitForChild("EndCall"),
    PlayMusic = PhoneEvents:WaitForChild("PlayMusic"),
    UpdateSettings = PhoneEvents:WaitForChild("UpdateSettings"),
    LaunchGame = PhoneEvents:WaitForChild("LaunchGame")
}

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Phone System Variables
local phoneGui = nil
local phoneFrame = nil
local isPhoneOpen = false
local currentFeature = "home"
local phoneSounds = {}
local currentData = {}

-- Device Detection
local function getDeviceType()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "mobile"
    elseif UserInputService.GamepadEnabled then
        return "console"
    else
        return "pc"
    end
end

-- Device-specific UI Scaling
local function getUIScale()
    local deviceType = getDeviceType()
    local scale = 1
    
    if deviceType == "mobile" then
        scale = 0.8
    elseif deviceType == "console" then
        scale = 0.9
    else
        scale = 0.7
    end
    
    return scale
end

-- Sound Management
local function createSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.5
    sound.Parent = SoundService
    return sound
end

-- Initialize Phone Sounds
local function initializeSounds()
    phoneSounds = {
        click = createSound(131961136, 0.3),
        open = createSound(131961136, 0.4),
        close = createSound(131961136, 0.3),
        call = createSound(131961136, 0.5),
        notification = createSound(131961136, 0.4)
    }
end

-- Create Main Phone GUI
local function createPhoneGUI()
    phoneGui = Instance.new("ScreenGui")
    phoneGui.Name = "PhoneSystemGUI"
    phoneGui.ResetOnSpawn = false
    phoneGui.Parent = playerGui
    
    return phoneGui
end

-- Create Phone Frame
local function createPhoneFrame()
    local scale = getUIScale()
    
    phoneFrame = Instance.new("Frame")
    phoneFrame.Name = "PhoneFrame"
    phoneFrame.Size = UDim2.new(0, 350 * scale, 0, 600 * scale)
    phoneFrame.Position = UDim2.new(0.5, -175 * scale, 0.5, -300 * scale)
    phoneFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    phoneFrame.BorderSizePixel = 0
    phoneFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    phoneFrame.Parent = phoneGui
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = phoneFrame
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    gradient.Rotation = 45
    gradient.Parent = phoneFrame
    
    return phoneFrame
end

-- Create Header Bar
local function createHeaderBar(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    -- Rounded top corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0.25, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📱 Telepon"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(1, -60, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "☰"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = header
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleBtn
    
    return header, toggleBtn
end

-- Create Navigation Bar
local function createNavigationBar(parent)
    local navBar = Instance.new("Frame")
    navBar.Name = "NavigationBar"
    navBar.Size = UDim2.new(1, 0, 0, 80)
    navBar.Position = UDim2.new(0, 0, 1, -80)
    navBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    navBar.BorderSizePixel = 0
    navBar.Parent = parent
    
    -- Rounded bottom corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = navBar
    
    -- Navigation buttons
    local buttons = {}
    local buttonData = {
        {name = "Games", icon = "🎮", color = Color3.fromRGB(255, 100, 100)},
        {name = "Chat", icon = "💬", color = Color3.fromRGB(100, 255, 100)},
        {name = "Phone", icon = "📞", color = Color3.fromRGB(100, 100, 255)},
        {name = "Music", icon = "🎵", color = Color3.fromRGB(255, 255, 100)},
        {name = "Settings", icon = "⚙️", color = Color3.fromRGB(200, 200, 200)}
    }
    
    for i, data in ipairs(buttonData) do
        local btn = Instance.new("TextButton")
        btn.Name = data.name .. "Button"
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = data.icon .. "\n" .. data.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = navBar
        
        -- Button hover effect
        btn.MouseEnter:Connect(function()
            btn.TextColor3 = data.color
        end)
        
        btn.MouseLeave:Connect(function()
            if currentFeature ~= data.name:lower() then
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)
        
        buttons[data.name:lower()] = btn
    end
    
    return navBar, buttons
end

-- Create Content Area
local function createContentArea(parent)
    local content = Instance.new("ScrollingFrame")
    content.Name = "ContentArea"
    content.Size = UDim2.new(1, -20, 1, -160)
    content.Position = UDim2.new(0, 10, 0, 70)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 8
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = parent
    
    return content
end

-- Animation Functions
local function animatePhoneOpen()
    if phoneSounds.open then
        phoneSounds.open:Play()
    end
    
    phoneFrame.Size = UDim2.new(0, 0, 0, 0)
    phoneFrame.BackgroundTransparency = 1
    
    local scale = getUIScale()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(phoneFrame, tweenInfo, {
        Size = UDim2.new(0, 350 * scale, 0, 600 * scale),
        BackgroundTransparency = 0
    })
    
    tween:Play()
    isPhoneOpen = true
end

local function animatePhoneClose()
    if phoneSounds.close then
        phoneSounds.close:Play()
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tween = TweenService:Create(phoneFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    isPhoneOpen = false
end

-- Feature Management
local function switchFeature(featureName)
    if phoneSounds.click then
        phoneSounds.click:Play()
    end
    
    currentFeature = featureName
    Events.SwitchFeature:FireServer(featureName)
    
    -- Update navigation buttons
    local navBar = phoneFrame:FindFirstChild("NavigationBar")
    if navBar then
        for _, child in pairs(navBar:GetChildren()) do
            if child:IsA("TextButton") then
                if child.Name:lower():find(featureName:lower()) then
                    child.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    child.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end
    end
end

-- Create Games Feature UI
local function createGamesUI(parent, gameData)
    -- Clear content
    parent:ClearAllChildren()
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Games"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Games grid
    for i, game in ipairs(gameData or {}) do
        local card = Instance.new("Frame")
        card.Name = game.name .. "Card"
        card.Size = UDim2.new(0.45, 0, 0, 120)
        card.Position = UDim2.new((i-1) % 2 * 0.5, 5, math.floor((i-1)/2) * 0.25, 50)
        card.BackgroundColor3 = game.color or Color3.fromRGB(100, 100, 100)
        card.BorderSizePixel = 0
        card.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = card
        
        -- Game icon
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 50, 0, 50)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Text = game.icon or "🎮"
        icon.TextScaled = true
        icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Parent = card
        
        -- Game name
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -70, 0, 30)
        name.Position = UDim2.new(0, 70, 0, 10)
        name.BackgroundTransparency = 1
        name.Text = game.name or "Game"
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextScaled = true
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card
        
        -- Description
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -70, 0, 20)
        desc.Position = UDim2.new(0, 70, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Text = game.description or "Description"
        desc.TextColor3 = Color3.fromRGB(220, 220, 220)
        desc.TextScaled = true
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = card
        
        -- Play button
        local playBtn = Instance.new("TextButton")
        playBtn.Size = UDim2.new(0, 60, 0, 30)
        playBtn.Position = UDim2.new(1, -70, 1, -40)
        playBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        playBtn.BorderSizePixel = 0
        playBtn.Text = "PLAY"
        playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        playBtn.TextScaled = true
        playBtn.Font = Enum.Font.GothamBold
        playBtn.Parent = card
        
        local playCorner = Instance.new("UICorner")
        playCorner.CornerRadius = UDim.new(0, 8)
        playCorner.Parent = playBtn
        
        -- Play button click
        playBtn.MouseButton1Click:Connect(function()
            Events.LaunchGame:FireServer(game)
        end)
    end
    
    -- Update canvas size
    parent.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#(gameData or {}) / 2) * 140 + 60)
end

-- Create Chat Feature UI
local function createChatUI(parent, chatData)
    parent:ClearAllChildren()
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "💬 Chat"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Chat messages area
    local messagesFrame = Instance.new("ScrollingFrame")
    messagesFrame.Name = "MessagesFrame"
    messagesFrame.Size = UDim2.new(1, 0, 1, -100)
    messagesFrame.Position = UDim2.new(0, 0, 0, 50)
    messagesFrame.BackgroundTransparency = 1
    messagesFrame.BorderSizePixel = 0
    messagesFrame.ScrollBarThickness = 8
    messagesFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    messagesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    messagesFrame.Parent = parent
    
    -- Chat input
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "ChatInput"
    inputFrame.Size = UDim2.new(1, 0, 0, 50)
    inputFrame.Position = UDim2.new(0, 0, 1, -50)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 15)
    inputCorner.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "MessageInput"
    textBox.Size = UDim2.new(1, -110, 1, -10)
    textBox.Position = UDim2.new(0, 10, 0, 5)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.BorderSizePixel = 0
    textBox.Text = ""
    textBox.PlaceholderText = "Type your message..."
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextScaled = true
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    
    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 10)
    textCorner.Parent = textBox
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendButton"
    sendBtn.Size = UDim2.new(0, 80, 0, 40)
    sendBtn.Position = UDim2.new(1, -90, 0, 5)
    sendBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "📤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextScaled = true
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.Parent = inputFrame
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 10)
    sendCorner.Parent = sendBtn
    
    -- Send message function
    local function sendMessage()
        local messageText = textBox.Text
        if messageText and messageText ~= "" then
            Events.SendChatMessage:FireServer({
                text = messageText,
                channel = "Global"
            })
            textBox.Text = ""
        end
    end
    
    sendBtn.MouseButton1Click:Connect(sendMessage)
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    -- Display messages
    local function addMessage(messageData)
        local isOwnMessage = messageData.sender == player.Name
        
        local messageFrame = Instance.new("Frame")
        messageFrame.Size = UDim2.new(1, -20, 0, 60)
        messageFrame.BackgroundTransparency = 1
        messageFrame.Parent = messagesFrame
        
        local bubble = Instance.new("Frame")
        bubble.Size = UDim2.new(0.7, 0, 0, 50)
        bubble.BackgroundColor3 = isOwnMessage and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(60, 60, 60)
        bubble.BorderSizePixel = 0
        bubble.Parent = messageFrame
        
        if isOwnMessage then
            bubble.Position = UDim2.new(0.3, 0, 0, 5)
        else
            bubble.Position = UDim2.new(0, 0, 0, 5)
        end
        
        local bubbleCorner = Instance.new("UICorner")
        bubbleCorner.CornerRadius = UDim.new(0, 15)
        bubbleCorner.Parent = bubble
        
        local messageText = Instance.new("TextLabel")
        messageText.Size = UDim2.new(1, -20, 1, -20)
        messageText.Position = UDim2.new(0, 10, 0, 10)
        messageText.BackgroundTransparency = 1
        messageText.Text = messageData.text
        messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
        messageText.TextScaled = true
        messageText.Font = Enum.Font.Gotham
        messageText.TextXAlignment = Enum.TextXAlignment.Left
        messageText.TextWrapped = true
        messageText.Parent = bubble
        
        -- Update canvas size and scroll
        messagesFrame.CanvasSize = UDim2.new(0, 0, 0, #messagesFrame:GetChildren() * 70)
        messagesFrame.CanvasPosition = Vector2.new(0, messagesFrame.CanvasSize.Y.Offset)
    end
    
    -- Handle incoming messages
    currentData.addMessage = addMessage
    
    -- Add existing messages
    for _, message in ipairs(chatData or {}) do
        addMessage(message)
    end
end

-- Create Phone Feature UI
local function createPhoneUI(parent, contactData)
    parent:ClearAllChildren()
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📞 Contacts"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Contacts list
    for i, contact in ipairs(contactData or {}) do
        local card = Instance.new("Frame")
        card.Name = contact.name .. "Card"
        card.Size = UDim2.new(1, -20, 0, 80)
        card.Position = UDim2.new(0, 10, 0, 50 + (i-1) * 90)
        card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        card.BorderSizePixel = 0
        card.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = card
        
        -- Avatar
        local avatar = Instance.new("TextLabel")
        avatar.Size = UDim2.new(0, 60, 0, 60)
        avatar.Position = UDim2.new(0, 10, 0, 10)
        avatar.BackgroundColor3 = contact.color or Color3.fromRGB(100, 100, 100)
        avatar.BorderSizePixel = 0
        avatar.Text = contact.avatar or "👤"
        avatar.TextScaled = true
        avatar.Font = Enum.Font.GothamBold
        avatar.TextColor3 = Color3.fromRGB(255, 255, 255)
        avatar.Parent = card
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(0, 30)
        avatarCorner.Parent = avatar
        
        -- Name
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -200, 0, 30)
        name.Position = UDim2.new(0, 80, 0, 10)
        name.BackgroundTransparency = 1
        name.Text = contact.name or "Contact"
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextScaled = true
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card
        
        -- Number
        local number = Instance.new("TextLabel")
        number.Size = UDim2.new(1, -200, 0, 20)
        number.Position = UDim2.new(0, 80, 0, 40)
        number.BackgroundTransparency = 1
        number.Text = contact.number or "No number"
        number.TextColor3 = Color3.fromRGB(200, 200, 200)
        number.TextScaled = true
        number.Font = Enum.Font.Gotham
        number.TextXAlignment = Enum.TextXAlignment.Left
        number.Parent = card
        
        -- Call button
        local callBtn = Instance.new("TextButton")
        callBtn.Size = UDim2.new(0, 60, 0, 40)
        callBtn.Position = UDim2.new(1, -80, 0, 20)
        callBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        callBtn.BorderSizePixel = 0
        callBtn.Text = "📞"
        callBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        callBtn.TextScaled = true
        callBtn.Font = Enum.Font.GothamBold
        callBtn.Parent = card
        
        local callCorner = Instance.new("UICorner")
        callCorner.CornerRadius = UDim.new(0, 10)
        callCorner.Parent = callBtn
        
        callBtn.MouseButton1Click:Connect(function()
            Events.StartCall:FireServer(contact)
        end)
    end
    
    parent.CanvasSize = UDim2.new(0, 0, 0, 50 + #(contactData or {}) * 90)
end

-- Create Music Feature UI
local function createMusicUI(parent, musicData)
    parent:ClearAllChildren()
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎵 Music"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Music tracks
    for i, track in ipairs(musicData or {}) do
        local card = Instance.new("Frame")
        card.Name = track.title .. "Card"
        card.Size = UDim2.new(1, -20, 0, 70)
        card.Position = UDim2.new(0, 10, 0, 50 + (i-1) * 80)
        card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        card.BorderSizePixel = 0
        card.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = card
        
        -- Track icon
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 50, 0, 50)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.BackgroundColor3 = track.color or Color3.fromRGB(100, 100, 100)
        icon.BorderSizePixel = 0
        icon.Text = track.icon or "🎵"
        icon.TextScaled = true
        icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Parent = card
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 25)
        iconCorner.Parent = icon
        
        -- Track title
        local trackTitle = Instance.new("TextLabel")
        trackTitle.Size = UDim2.new(1, -150, 0, 25)
        trackTitle.Position = UDim2.new(0, 70, 0, 10)
        trackTitle.BackgroundTransparency = 1
        trackTitle.Text = track.title or "Track"
        trackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        trackTitle.TextScaled = true
        trackTitle.Font = Enum.Font.GothamBold
        trackTitle.TextXAlignment = Enum.TextXAlignment.Left
        trackTitle.Parent = card
        
        -- Artist
        local artist = Instance.new("TextLabel")
        artist.Size = UDim2.new(1, -150, 0, 20)
        artist.Position = UDim2.new(0, 70, 0, 35)
        artist.BackgroundTransparency = 1
        artist.Text = track.artist or "Artist"
        artist.TextColor3 = Color3.fromRGB(200, 200, 200)
        artist.TextScaled = true
        artist.Font = Enum.Font.Gotham
        artist.TextXAlignment = Enum.TextXAlignment.Left
        artist.Parent = card
        
        -- Play button
        local playBtn = Instance.new("TextButton")
        playBtn.Size = UDim2.new(0, 50, 0, 50)
        playBtn.Position = UDim2.new(1, -70, 0, 10)
        playBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        playBtn.BorderSizePixel = 0
        playBtn.Text = "▶"
        playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        playBtn.TextScaled = true
        playBtn.Font = Enum.Font.GothamBold
        playBtn.Parent = card
        
        local playCorner = Instance.new("UICorner")
        playCorner.CornerRadius = UDim.new(0, 25)
        playCorner.Parent = playBtn
        
        playBtn.MouseButton1Click:Connect(function()
            Events.PlayMusic:FireServer(track)
        end)
    end
    
    parent.CanvasSize = UDim2.new(0, 0, 0, 50 + #(musicData or {}) * 80)
end

-- Create Settings Feature UI
local function createSettingsUI(parent, settingsData)
    parent:ClearAllChildren()
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Settings options
    local settings = settingsData or {volume = 0.5, notifications = true}
    
    -- Volume setting
    local volumeFrame = Instance.new("Frame")
    volumeFrame.Size = UDim2.new(1, -20, 0, 50)
    volumeFrame.Position = UDim2.new(0, 10, 0, 60)
    volumeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    volumeFrame.BorderSizePixel = 0
    volumeFrame.Parent = parent
    
    local volumeCorner = Instance.new("UICorner")
    volumeCorner.CornerRadius = UDim.new(0, 10)
    volumeCorner.Parent = volumeFrame
    
    local volumeLabel = Instance.new("TextLabel")
    volumeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    volumeLabel.Position = UDim2.new(0, 10, 0, 0)
    volumeLabel.BackgroundTransparency = 1
    volumeLabel.Text = "🔊 Volume: " .. math.floor((settings.volume or 0.5) * 100) .. "%"
    volumeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    volumeLabel.TextScaled = true
    volumeLabel.Font = Enum.Font.Gotham
    volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
    volumeLabel.Parent = volumeFrame
    
    -- Notifications setting
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(1, -20, 0, 50)
    notifFrame.Position = UDim2.new(0, 10, 0, 130)
    notifFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = parent
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notifFrame
    
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(0.7, 0, 1, 0)
    notifLabel.Position = UDim2.new(0, 10, 0, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "🔔 Notifications: " .. (settings.notifications and "ON" or "OFF")
    notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifLabel.TextScaled = true
    notifLabel.Font = Enum.Font.Gotham
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = notifFrame
    
    -- About section
    local aboutFrame = Instance.new("Frame")
    aboutFrame.Size = UDim2.new(1, -20, 0, 100)
    aboutFrame.Position = UDim2.new(0, 10, 0, 200)
    aboutFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    aboutFrame.BorderSizePixel = 0
    aboutFrame.Parent = parent
    
    local aboutCorner = Instance.new("UICorner")
    aboutCorner.CornerRadius = UDim.new(0, 15)
    aboutCorner.Parent = aboutFrame
    
    local aboutText = Instance.new("TextLabel")
    aboutText.Size = UDim2.new(1, -20, 1, -20)
    aboutText.Position = UDim2.new(0, 10, 0, 10)
    aboutText.BackgroundTransparency = 1
    aboutText.Text = "📱 Phone System v1.0\nModern phone system for Roblox\nCreated with ❤️"
    aboutText.TextColor3 = Color3.fromRGB(200, 200, 200)
    aboutText.TextScaled = true
    aboutText.Font = Enum.Font.Gotham
    aboutText.TextXAlignment = Enum.TextXAlignment.Left
    aboutText.TextYAlignment = Enum.TextYAlignment.Top
    aboutText.Parent = aboutFrame
    
    parent.CanvasSize = UDim2.new(0, 0, 0, 320)
end

-- Initialize Phone System
local function initializePhoneSystem()
    initializeSounds()
    createPhoneGUI()
    createPhoneFrame()
    
    local header, toggleBtn = createHeaderBar(phoneFrame)
    local navBar, navButtons = createNavigationBar(phoneFrame)
    local contentArea = createContentArea(phoneFrame)
    
    -- Connect toggle button
    toggleBtn.MouseButton1Click:Connect(function()
        Events.TogglePhone:FireServer()
        if isPhoneOpen then
            animatePhoneClose()
        else
            animatePhoneOpen()
        end
    end)
    
    -- Connect navigation buttons
    for featureName, button in pairs(navButtons) do
        button.MouseButton1Click:Connect(function()
            switchFeature(featureName)
        end)
    end
    
    -- Start with phone closed
    phoneFrame.Size = UDim2.new(0, 0, 0, 0)
    phoneFrame.BackgroundTransparency = 1
    
    print("📱 Phone System Client initialized successfully!")
end

-- Event Handlers
Events.SwitchFeature.OnClientEvent:Connect(function(feature, data)
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if not contentArea then return end
    
    if feature == "games" then
        createGamesUI(contentArea, data)
    elseif feature == "chat" then
        createChatUI(contentArea, data)
    elseif feature == "phone" then
        createPhoneUI(contentArea, data)
    elseif feature == "music" then
        createMusicUI(contentArea, data)
    elseif feature == "settings" then
        createSettingsUI(contentArea, data)
    end
end)

Events.SendChatMessage.OnClientEvent:Connect(function(messageData)
    if currentData.addMessage then
        currentData.addMessage(messageData)
    end
end)

Events.StartCall.OnClientEvent:Connect(function(playerId, contactData)
    print("📞 " .. Players:GetPlayerByUserId(playerId).Name .. " started call with " .. contactData.name)
end)

Events.EndCall.OnClientEvent:Connect(function(playerId)
    print("📞 " .. Players:GetPlayerByUserId(playerId).Name .. " ended call")
end)

Events.LaunchGame.OnClientEvent:Connect(function(gameData)
    print("🎮 Launching " .. gameData.name .. "...")
    -- In real implementation, you would use TeleportService here
end)

-- Keyboard shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if isPhoneOpen then
            animatePhoneClose()
        else
            animatePhoneOpen()
        end
    end
end)

-- Initialize when player spawns
initializePhoneSystem()

print("📱 Phone System Client ready!")
print("🔑 Press F1 to toggle phone")