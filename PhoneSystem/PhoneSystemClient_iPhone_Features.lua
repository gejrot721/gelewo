-- PhoneSystemClient_iPhone_Features.lua
-- Extended features for iPhone-style phone system
-- This extends the main iPhone client with full feature implementations

-- Feature Creation Functions

-- Create Games Feature UI (iPhone Style)
local function createGamesFeature(parent)
    parent:ClearAllChildren()
    
    -- Header with back button
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 40, 0, 40)
    backBtn.Position = UDim2.new(0, 10, 0, 10)
    backBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "←"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.TextScaled = true
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 20)
    backCorner.Parent = backBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Games"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Search button
    local searchBtn = Instance.new("TextButton")
    searchBtn.Name = "SearchButton"
    searchBtn.Size = UDim2.new(0, 40, 0, 40)
    searchBtn.Position = UDim2.new(1, -50, 0, 10)
    searchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    searchBtn.BorderSizePixel = 0
    searchBtn.Text = "🔍"
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.TextScaled = true
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.Parent = header
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 20)
    searchCorner.Parent = searchBtn
    
    -- Games scroll area
    local gamesScroll = Instance.new("ScrollingFrame")
    gamesScroll.Name = "GamesScroll"
    gamesScroll.Size = UDim2.new(1, -20, 1, -80)
    gamesScroll.Position = UDim2.new(0, 10, 0, 70)
    gamesScroll.BackgroundTransparency = 1
    gamesScroll.BorderSizePixel = 0
    gamesScroll.ScrollBarThickness = 8
    gamesScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    gamesScroll.CanvasSize = UDim2.new(0, 0, 0, 800)
    gamesScroll.Parent = parent
    
    -- Back button function
    backBtn.MouseButton1Click:Connect(function()
        resetToHomeScreen()
    end)
    
    return parent
end

-- Create Chat Feature UI (iPhone Style)
local function createChatFeature(parent)
    parent:ClearAllChildren()
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 40, 0, 40)
    backBtn.Position = UDim2.new(0, 10, 0, 10)
    backBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "←"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.TextScaled = true
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 20)
    backCorner.Parent = backBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "💬 Messages"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Messages area
    local messagesArea = Instance.new("ScrollingFrame")
    messagesArea.Name = "MessagesArea"
    messagesArea.Size = UDim2.new(1, -20, 1, -130)
    messagesArea.Position = UDim2.new(0, 10, 0, 70)
    messagesArea.BackgroundTransparency = 1
    messagesArea.BorderSizePixel = 0
    messagesArea.ScrollBarThickness = 6
    messagesArea.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    messagesArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    messagesArea.Parent = parent
    
    -- Input area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -20, 0, 50)
    inputArea.Position = UDim2.new(0, 10, 1, -60)
    inputArea.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputArea.BorderSizePixel = 0
    inputArea.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 25)
    inputCorner.Parent = inputArea
    
    -- Text input
    local textInput = Instance.new("TextBox")
    textInput.Name = "TextInput"
    textInput.Size = UDim2.new(1, -100, 1, -10)
    textInput.Position = UDim2.new(0, 20, 0, 5)
    textInput.BackgroundTransparency = 1
    textInput.Text = ""
    textInput.PlaceholderText = "iMessage"
    textInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    textInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textInput.TextScaled = true
    textInput.Font = Enum.Font.Gotham
    textInput.TextXAlignment = Enum.TextXAlignment.Left
    textInput.Parent = inputArea
    
    -- Send button
    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendButton"
    sendBtn.Size = UDim2.new(0, 40, 0, 40)
    sendBtn.Position = UDim2.new(1, -45, 0, 5)
    sendBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "↗"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextScaled = true
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.Parent = inputArea
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 20)
    sendCorner.Parent = sendBtn
    
    -- Back button function
    backBtn.MouseButton1Click:Connect(function()
        resetToHomeScreen()
    end)
    
    -- Send message function
    local function sendMessage()
        local messageText = textInput.Text
        if messageText and messageText ~= "" then
            if Events.SendChatMessage then
                Events.SendChatMessage:FireServer({
                    text = messageText,
                    channel = "Global"
                })
            end
            textInput.Text = ""
        end
    end
    
    sendBtn.MouseButton1Click:Connect(sendMessage)
    textInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    return parent
end

-- Create Phone Feature UI (iPhone Style)
local function createPhoneFeature(parent)
    parent:ClearAllChildren()
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 40, 0, 40)
    backBtn.Position = UDim2.new(0, 10, 0, 10)
    backBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "←"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.TextScaled = true
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 20)
    backCorner.Parent = backBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📞 Phone"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Add contact button
    local addBtn = Instance.new("TextButton")
    addBtn.Name = "AddButton"
    addBtn.Size = UDim2.new(0, 40, 0, 40)
    addBtn.Position = UDim2.new(1, -50, 0, 10)
    addBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    addBtn.BorderSizePixel = 0
    addBtn.Text = "+"
    addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addBtn.TextScaled = true
    addBtn.Font = Enum.Font.GothamBold
    addBtn.Parent = header
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 20)
    addCorner.Parent = addBtn
    
    -- Contacts scroll area
    local contactsScroll = Instance.new("ScrollingFrame")
    contactsScroll.Name = "ContactsScroll"
    contactsScroll.Size = UDim2.new(1, -20, 1, -80)
    contactsScroll.Position = UDim2.new(0, 10, 0, 70)
    contactsScroll.BackgroundTransparency = 1
    contactsScroll.BorderSizePixel = 0
    contactsScroll.ScrollBarThickness = 8
    contactsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    contactsScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    contactsScroll.Parent = parent
    
    -- Back button function
    backBtn.MouseButton1Click:Connect(function()
        resetToHomeScreen()
    end)
    
    return parent
end

-- Create Music Feature UI (iPhone Style)
local function createMusicFeature(parent)
    parent:ClearAllChildren()
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 40, 0, 40)
    backBtn.Position = UDim2.new(0, 10, 0, 10)
    backBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "←"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.TextScaled = true
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 20)
    backCorner.Parent = backBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎵 Music"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Now Playing area (top section)
    local nowPlaying = Instance.new("Frame")
    nowPlaying.Name = "NowPlaying"
    nowPlaying.Size = UDim2.new(1, -20, 0, 120)
    nowPlaying.Position = UDim2.new(0, 10, 0, 70)
    nowPlaying.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    nowPlaying.BorderSizePixel = 0
    nowPlaying.Parent = parent
    
    local nowPlayingCorner = Instance.new("UICorner")
    nowPlayingCorner.CornerRadius = UDim.new(0, 15)
    nowPlayingCorner.Parent = nowPlaying
    
    -- Album art
    local albumArt = Instance.new("Frame")
    albumArt.Name = "AlbumArt"
    albumArt.Size = UDim2.new(0, 80, 0, 80)
    albumArt.Position = UDim2.new(0, 20, 0, 20)
    albumArt.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    albumArt.BorderSizePixel = 0
    albumArt.Parent = nowPlaying
    
    local artCorner = Instance.new("UICorner")
    artCorner.CornerRadius = UDim.new(0, 10)
    artCorner.Parent = albumArt
    
    local artIcon = Instance.new("TextLabel")
    artIcon.Size = UDim2.new(1, 0, 1, 0)
    artIcon.Position = UDim2.new(0, 0, 0, 0)
    artIcon.BackgroundTransparency = 1
    artIcon.Text = "🎵"
    artIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    artIcon.TextScaled = true
    artIcon.Font = Enum.Font.GothamBold
    artIcon.Parent = albumArt
    
    -- Track info
    local trackTitle = Instance.new("TextLabel")
    trackTitle.Name = "TrackTitle"
    trackTitle.Size = UDim2.new(1, -130, 0, 25)
    trackTitle.Position = UDim2.new(0, 110, 0, 30)
    trackTitle.BackgroundTransparency = 1
    trackTitle.Text = "No track playing"
    trackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    trackTitle.TextScaled = true
    trackTitle.Font = Enum.Font.GothamBold
    trackTitle.TextXAlignment = Enum.TextXAlignment.Left
    trackTitle.Parent = nowPlaying
    
    local trackArtist = Instance.new("TextLabel")
    trackArtist.Name = "TrackArtist"
    trackArtist.Size = UDim2.new(1, -130, 0, 20)
    trackArtist.Position = UDim2.new(0, 110, 0, 55)
    trackArtist.BackgroundTransparency = 1
    trackArtist.Text = "Select a song to play"
    trackArtist.TextColor3 = Color3.fromRGB(200, 200, 200)
    trackArtist.TextScaled = true
    trackArtist.Font = Enum.Font.Gotham
    trackArtist.TextXAlignment = Enum.TextXAlignment.Left
    trackArtist.Parent = nowPlaying
    
    -- Control buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "Controls"
    controlFrame.Size = UDim2.new(1, -20, 0, 60)
    controlFrame.Position = UDim2.new(0, 10, 0, 200)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = parent
    
    -- Previous button
    local prevBtn = Instance.new("TextButton")
    prevBtn.Name = "PreviousButton"
    prevBtn.Size = UDim2.new(0, 50, 0, 50)
    prevBtn.Position = UDim2.new(0.3, -25, 0, 5)
    prevBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    prevBtn.BorderSizePixel = 0
    prevBtn.Text = "⏮"
    prevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    prevBtn.TextScaled = true
    prevBtn.Font = Enum.Font.GothamBold
    prevBtn.Parent = controlFrame
    
    local prevCorner = Instance.new("UICorner")
    prevCorner.CornerRadius = UDim.new(0, 25)
    prevCorner.Parent = prevBtn
    
    -- Play/Pause button
    local playBtn = Instance.new("TextButton")
    playBtn.Name = "PlayButton"
    playBtn.Size = UDim2.new(0, 60, 0, 60)
    playBtn.Position = UDim2.new(0.5, -30, 0, 0)
    playBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    playBtn.BorderSizePixel = 0
    playBtn.Text = "▶"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.TextScaled = true
    playBtn.Font = Enum.Font.GothamBold
    playBtn.Parent = controlFrame
    
    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 30)
    playCorner.Parent = playBtn
    
    -- Next button
    local nextBtn = Instance.new("TextButton")
    nextBtn.Name = "NextButton"
    nextBtn.Size = UDim2.new(0, 50, 0, 50)
    nextBtn.Position = UDim2.new(0.7, -25, 0, 5)
    nextBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    nextBtn.BorderSizePixel = 0
    nextBtn.Text = "⏭"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.TextScaled = true
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.Parent = controlFrame
    
    local nextCorner = Instance.new("UICorner")
    nextCorner.CornerRadius = UDim.new(0, 25)
    nextCorner.Parent = nextBtn
    
    -- Library scroll area
    local libraryScroll = Instance.new("ScrollingFrame")
    libraryScroll.Name = "LibraryScroll"
    libraryScroll.Size = UDim2.new(1, -20, 1, -280)
    libraryScroll.Position = UDim2.new(0, 10, 0, 270)
    libraryScroll.BackgroundTransparency = 1
    libraryScroll.BorderSizePixel = 0
    libraryScroll.ScrollBarThickness = 8
    libraryScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    libraryScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    libraryScroll.Parent = parent
    
    -- Back button function
    backBtn.MouseButton1Click:Connect(function()
        resetToHomeScreen()
    end)
    
    return parent
end

-- Create Settings Feature UI (iPhone Style)
local function createSettingsFeature(parent)
    parent:ClearAllChildren()
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 40, 0, 40)
    backBtn.Position = UDim2.new(0, 10, 0, 10)
    backBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "←"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.TextScaled = true
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 20)
    backCorner.Parent = backBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Settings scroll area
    local settingsScroll = Instance.new("ScrollingFrame")
    settingsScroll.Name = "SettingsScroll"
    settingsScroll.Size = UDim2.new(1, -20, 1, -80)
    settingsScroll.Position = UDim2.new(0, 10, 0, 70)
    settingsScroll.BackgroundTransparency = 1
    settingsScroll.BorderSizePixel = 0
    settingsScroll.ScrollBarThickness = 8
    settingsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    settingsScroll.Parent = parent
    
    -- Settings options
    local settingsOptions = {
        {icon = "🔊", title = "Sound & Haptics", description = "Ringer and alert volume"},
        {icon = "📱", title = "Display & Brightness", description = "Auto-lock, text size"},
        {icon = "🔔", title = "Notifications", description = "Badges, sounds, alerts"},
        {icon = "🛡️", title = "Privacy & Security", description = "Location, contacts"},
        {icon = "⏰", title = "Screen Time", description = "App usage and limits"},
        {icon = "ℹ️", title = "About", description = "Phone System v2.0"}
    }
    
    for i, option in ipairs(settingsOptions) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = option.title .. "Option"
        optionFrame.Size = UDim2.new(1, -20, 0, 70)
        optionFrame.Position = UDim2.new(0, 10, 0, (i-1) * 80 + 10)
        optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        optionFrame.BorderSizePixel = 0
        optionFrame.Parent = settingsScroll
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 15)
        optionCorner.Parent = optionFrame
        
        -- Icon
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 50, 0, 50)
        iconLabel.Position = UDim2.new(0, 15, 0, 10)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = option.icon
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconLabel.TextScaled = true
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Parent = optionFrame
        
        -- Title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -120, 0, 30)
        titleLabel.Position = UDim2.new(0, 75, 0, 15)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = option.title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = optionFrame
        
        -- Description
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -120, 0, 20)
        descLabel.Position = UDim2.new(0, 75, 0, 45)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = option.description
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = optionFrame
        
        -- Arrow
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 30, 0, 30)
        arrow.Position = UDim2.new(1, -40, 0, 20)
        arrow.BackgroundTransparency = 1
        arrow.Text = ">"
        arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
        arrow.TextScaled = true
        arrow.Font = Enum.Font.GothamBold
        arrow.Parent = optionFrame
    end
    
    -- Back button function
    backBtn.MouseButton1Click:Connect(function()
        resetToHomeScreen()
    end)
    
    return parent
end

-- Export feature creation functions
return {
    createGamesFeature = createGamesFeature,
    createChatFeature = createChatFeature,
    createPhoneFeature = createPhoneFeature,
    createMusicFeature = createMusicFeature,
    createSettingsFeature = createSettingsFeature
}