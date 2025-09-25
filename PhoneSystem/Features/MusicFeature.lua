-- MusicFeature.lua
-- Fitur Musik untuk sistem telepon dengan music player dan kontrol audio

local MusicFeature = {}
MusicFeature.__index = MusicFeature

-- Services
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

-- Music Variables
local currentTrack = 1
local isPlaying = false
local isPaused = false
local volume = 0.5
local currentTime = 0
local trackDuration = 0
local musicSound = nil

-- Sample Music Data
local musicLibrary = {
    {
        title = "Epic Adventure",
        artist = "Game Music Studio",
        duration = "3:45",
        genre = "Epic",
        icon = "🎵",
        color = Color3.fromRGB(255, 100, 100),
        soundId = 131961136 -- Placeholder sound ID
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

-- Create Music Track Card
local function createTrackCard(parent, trackData, index)
    local card = Instance.new("Frame")
    card.Name = trackData.title .. "Card"
    card.Size = UDim2.new(1, -20, 0, 70)
    card.Position = UDim2.new(0, 10, 0, (index-1) * 80)
    card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    card.BorderSizePixel = 0
    card.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = card
    
    -- Track icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 50, 0, 50)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.BackgroundColor3 = trackData.color
    iconLabel.BorderSizePixel = 0
    iconLabel.Text = trackData.icon
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.Parent = card
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 25)
    iconCorner.Parent = iconLabel
    
    -- Track title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -200, 0, 25)
    titleLabel.Position = UDim2.new(0, 70, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = trackData.title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    -- Artist name
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Name = "Artist"
    artistLabel.Size = UDim2.new(1, -200, 0, 20)
    artistLabel.Position = UDim2.new(0, 70, 0, 35)
    artistLabel.BackgroundTransparency = 1
    artistLabel.Text = trackData.artist .. " • " .. trackData.genre
    artistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    artistLabel.TextScaled = true
    artistLabel.Font = Enum.Font.Gotham
    artistLabel.TextXAlignment = Enum.TextXAlignment.Left
    artistLabel.Parent = card
    
    -- Duration
    local durationLabel = Instance.new("TextLabel")
    durationLabel.Name = "Duration"
    durationLabel.Size = UDim2.new(0, 60, 0, 20)
    durationLabel.Position = UDim2.new(0, 70, 0, 50)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Text = trackData.duration
    durationLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    durationLabel.TextScaled = true
    durationLabel.Font = Enum.Font.Gotham
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.Parent = card
    
    -- Play button
    local playBtn = Instance.new("TextButton")
    playBtn.Name = "PlayButton"
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
    
    -- Hover effects
    card.MouseEnter:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    card.MouseLeave:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    -- Play button click
    playBtn.MouseButton1Click:Connect(function()
        MusicFeature:PlayTrack(index)
    end)
    
    return card
end

-- Create Music Player Interface
local function createPlayerInterface(parent)
    local playerFrame = Instance.new("Frame")
    playerFrame.Name = "PlayerInterface"
    playerFrame.Size = UDim2.new(1, 0, 0, 200)
    playerFrame.Position = UDim2.new(0, 0, 1, -200)
    playerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    playerFrame.BorderSizePixel = 0
    playerFrame.Parent = parent
    
    -- Rounded top corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = playerFrame
    
    -- Current track info
    local trackInfo = Instance.new("Frame")
    trackInfo.Name = "TrackInfo"
    trackInfo.Size = UDim2.new(1, 0, 0, 60)
    trackInfo.Position = UDim2.new(0, 0, 0, 0)
    trackInfo.BackgroundTransparency = 1
    trackInfo.Parent = playerFrame
    
    -- Track icon (large)
    local trackIcon = Instance.new("TextLabel")
    trackIcon.Name = "TrackIcon"
    trackIcon.Size = UDim2.new(0, 50, 0, 50)
    trackIcon.Position = UDim2.new(0, 10, 0, 5)
    trackIcon.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    trackIcon.BorderSizePixel = 0
    trackIcon.Text = "🎵"
    trackIcon.TextScaled = true
    trackIcon.Font = Enum.Font.GothamBold
    trackIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    trackIcon.Parent = trackInfo
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 25)
    iconCorner.Parent = trackIcon
    
    -- Track title
    local trackTitle = Instance.new("TextLabel")
    trackTitle.Name = "TrackTitle"
    trackTitle.Size = UDim2.new(1, -70, 0, 25)
    trackTitle.Position = UDim2.new(0, 70, 0, 5)
    trackTitle.BackgroundTransparency = 1
    trackTitle.Text = "Select a track"
    trackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    trackTitle.TextScaled = true
    trackTitle.Font = Enum.Font.GothamBold
    trackTitle.TextXAlignment = Enum.TextXAlignment.Left
    trackTitle.Parent = trackInfo
    
    -- Track artist
    local trackArtist = Instance.new("TextLabel")
    trackArtist.Name = "TrackArtist"
    trackArtist.Size = UDim2.new(1, -70, 0, 20)
    trackArtist.Position = UDim2.new(0, 70, 0, 30)
    trackArtist.BackgroundTransparency = 1
    trackArtist.Text = ""
    trackArtist.TextColor3 = Color3.fromRGB(200, 200, 200)
    trackArtist.TextScaled = true
    trackArtist.Font = Enum.Font.Gotham
    trackArtist.TextXAlignment = Enum.TextXAlignment.Left
    trackArtist.Parent = trackInfo
    
    -- Progress bar
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = "ProgressFrame"
    progressFrame.Size = UDim2.new(1, -20, 0, 20)
    progressFrame.Position = UDim2.new(0, 10, 0, 70)
    progressFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressFrame.BorderSizePixel = 0
    progressFrame.Parent = playerFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 10)
    progressCorner.Parent = progressFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 10)
    barCorner.Parent = progressBar
    
    -- Time labels
    local currentTimeLabel = Instance.new("TextLabel")
    currentTimeLabel.Name = "CurrentTime"
    currentTimeLabel.Size = UDim2.new(0, 50, 0, 20)
    currentTimeLabel.Position = UDim2.new(0, 10, 0, 95)
    currentTimeLabel.BackgroundTransparency = 1
    currentTimeLabel.Text = "0:00"
    currentTimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    currentTimeLabel.TextScaled = true
    currentTimeLabel.Font = Enum.Font.Gotham
    currentTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentTimeLabel.Parent = playerFrame
    
    local totalTimeLabel = Instance.new("TextLabel")
    totalTimeLabel.Name = "TotalTime"
    totalTimeLabel.Size = UDim2.new(0, 50, 0, 20)
    totalTimeLabel.Position = UDim2.new(1, -60, 0, 95)
    totalTimeLabel.BackgroundTransparency = 1
    totalTimeLabel.Text = "0:00"
    totalTimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    totalTimeLabel.TextScaled = true
    totalTimeLabel.Font = Enum.Font.Gotham
    totalTimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    totalTimeLabel.Parent = playerFrame
    
    -- Control buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlFrame"
    controlFrame.Size = UDim2.new(1, 0, 0, 60)
    controlFrame.Position = UDim2.new(0, 0, 1, -60)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = playerFrame
    
    -- Previous button
    local prevBtn = Instance.new("TextButton")
    prevBtn.Name = "PreviousButton"
    prevBtn.Size = UDim2.new(0, 50, 0, 50)
    prevBtn.Position = UDim2.new(0.2, -25, 0, 5)
    prevBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
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
    local playPauseBtn = Instance.new("TextButton")
    playPauseBtn.Name = "PlayPauseButton"
    playPauseBtn.Size = UDim2.new(0, 60, 0, 60)
    playPauseBtn.Position = UDim2.new(0.5, -30, 0, 0)
    playPauseBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    playPauseBtn.BorderSizePixel = 0
    playPauseBtn.Text = "▶"
    playPauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playPauseBtn.TextScaled = true
    playPauseBtn.Font = Enum.Font.GothamBold
    playPauseBtn.Parent = controlFrame
    
    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 30)
    playCorner.Parent = playPauseBtn
    
    -- Next button
    local nextBtn = Instance.new("TextButton")
    nextBtn.Name = "NextButton"
    nextBtn.Size = UDim2.new(0, 50, 0, 50)
    nextBtn.Position = UDim2.new(0.8, -25, 0, 5)
    nextBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    nextBtn.BorderSizePixel = 0
    nextBtn.Text = "⏭"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.TextScaled = true
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.Parent = controlFrame
    
    local nextCorner = Instance.new("UICorner")
    nextCorner.CornerRadius = UDim.new(0, 25)
    nextCorner.Parent = nextBtn
    
    -- Volume control
    local volumeFrame = Instance.new("Frame")
    volumeFrame.Name = "VolumeFrame"
    volumeFrame.Size = UDim2.new(0, 120, 0, 30)
    volumeFrame.Position = UDim2.new(1, -130, 0, 5)
    volumeFrame.BackgroundTransparency = 1
    volumeFrame.Parent = controlFrame
    
    local volumeIcon = Instance.new("TextLabel")
    volumeIcon.Name = "VolumeIcon"
    volumeIcon.Size = UDim2.new(0, 30, 0, 30)
    volumeIcon.Position = UDim2.new(0, 0, 0, 0)
    volumeIcon.BackgroundTransparency = 1
    volumeIcon.Text = "🔊"
    volumeIcon.TextScaled = true
    volumeIcon.Font = Enum.Font.GothamBold
    volumeIcon.Parent = volumeFrame
    
    local volumeSlider = Instance.new("Frame")
    volumeSlider.Name = "VolumeSlider"
    volumeSlider.Size = UDim2.new(0, 80, 0, 20)
    volumeSlider.Position = UDim2.new(0, 35, 0, 5)
    volumeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    volumeSlider.BorderSizePixel = 0
    volumeSlider.Parent = volumeFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = volumeSlider
    
    local volumeBar = Instance.new("Frame")
    volumeBar.Name = "VolumeBar"
    volumeBar.Size = UDim2.new(volume, 0, 1, 0)
    volumeBar.Position = UDim2.new(0, 0, 0, 0)
    volumeBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    volumeBar.BorderSizePixel = 0
    volumeBar.Parent = volumeSlider
    
    local barCorner2 = Instance.new("UICorner")
    barCorner2.CornerRadius = UDim.new(0, 10)
    barCorner2.Parent = volumeBar
    
    -- Button click handlers
    prevBtn.MouseButton1Click:Connect(function()
        MusicFeature:PreviousTrack()
    end)
    
    playPauseBtn.MouseButton1Click:Connect(function()
        MusicFeature:TogglePlayPause()
    end)
    
    nextBtn.MouseButton1Click:Connect(function()
        MusicFeature:NextTrack()
    end)
    
    return playerFrame, trackTitle, trackArtist, trackIcon, progressBar, currentTimeLabel, totalTimeLabel, playPauseBtn
end

-- Music Control Methods
function MusicFeature:PlayTrack(trackIndex)
    if trackIndex and trackIndex >= 1 and trackIndex <= #musicLibrary then
        currentTrack = trackIndex
        local trackData = musicLibrary[trackIndex]
        
        print("🎵 Playing: " .. trackData.title .. " by " .. trackData.artist)
        
        -- Update player interface
        local playerFrame = self.parent:FindFirstChild("PlayerInterface")
        if playerFrame then
            local trackTitle = playerFrame:FindFirstChild("TrackInfo"):FindFirstChild("TrackTitle")
            local trackArtist = playerFrame:FindFirstChild("TrackInfo"):FindFirstChild("TrackArtist")
            local trackIcon = playerFrame:FindFirstChild("TrackInfo"):FindFirstChild("TrackIcon")
            
            if trackTitle then trackTitle.Text = trackData.title end
            if trackArtist then trackArtist.Text = trackData.artist end
            if trackIcon then 
                trackIcon.Text = trackData.icon
                trackIcon.BackgroundColor3 = trackData.color
            end
        end
        
        -- Create and play sound
        if musicSound then
            musicSound:Destroy()
        end
        
        musicSound = Instance.new("Sound")
        musicSound.SoundId = "rbxassetid://" .. trackData.soundId
        musicSound.Volume = volume
        musicSound.Looped = false
        musicSound.Parent = SoundService
        
        musicSound:Play()
        isPlaying = true
        isPaused = false
        
        -- Update play/pause button
        local playPauseBtn = playerFrame:FindFirstChild("ControlFrame"):FindFirstChild("PlayPauseButton")
        if playPauseBtn then
            playPauseBtn.Text = "⏸"
        end
        
        -- Simulate progress
        self:StartProgressSimulation()
    end
end

function MusicFeature:TogglePlayPause()
    if musicSound then
        if isPlaying and not isPaused then
            musicSound:Pause()
            isPaused = true
            print("⏸ Music paused")
        elseif isPaused then
            musicSound:Resume()
            isPaused = false
            print("▶ Music resumed")
        end
        
        -- Update play/pause button
        local playerFrame = self.parent:FindFirstChild("PlayerInterface")
        if playerFrame then
            local playPauseBtn = playerFrame:FindFirstChild("ControlFrame"):FindFirstChild("PlayPauseButton")
            if playPauseBtn then
                playPauseBtn.Text = isPaused and "▶" or "⏸"
            end
        end
    end
end

function MusicFeature:NextTrack()
    local nextTrack = currentTrack + 1
    if nextTrack > #musicLibrary then
        nextTrack = 1
    end
    self:PlayTrack(nextTrack)
end

function MusicFeature:PreviousTrack()
    local prevTrack = currentTrack - 1
    if prevTrack < 1 then
        prevTrack = #musicLibrary
    end
    self:PlayTrack(prevTrack)
end

function MusicFeature:StartProgressSimulation()
    spawn(function()
        while isPlaying and musicSound do
            wait(0.1)
            
            if not isPaused then
                currentTime = currentTime + 0.1
                
                -- Update progress bar
                local playerFrame = self.parent:FindFirstChild("PlayerInterface")
                if playerFrame then
                    local progressBar = playerFrame:FindFirstChild("ProgressFrame"):FindFirstChild("ProgressBar")
                    local currentTimeLabel = playerFrame:FindFirstChild("CurrentTime")
                    
                    if progressBar then
                        local progress = math.min(currentTime / 60, 1) -- Simulate 60 second tracks
                        progressBar.Size = UDim2.new(progress, 0, 1, 0)
                    end
                    
                    if currentTimeLabel then
                        local minutes = math.floor(currentTime / 60)
                        local seconds = math.floor(currentTime % 60)
                        currentTimeLabel.Text = string.format("%d:%02d", minutes, seconds)
                    end
                end
                
                -- Auto next track
                if currentTime >= 60 then
                    self:NextTrack()
                    currentTime = 0
                end
            end
        end
    end)
end

-- Create Music Feature UI
function MusicFeature:CreateUI(parent)
    self.parent = parent
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎵 Music Library"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Music library
    local libraryFrame = Instance.new("ScrollingFrame")
    libraryFrame.Name = "LibraryFrame"
    libraryFrame.Size = UDim2.new(1, 0, 1, -200)
    libraryFrame.Position = UDim2.new(0, 0, 0, 50)
    libraryFrame.BackgroundTransparency = 1
    libraryFrame.BorderSizePixel = 0
    libraryFrame.ScrollBarThickness = 8
    libraryFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    libraryFrame.CanvasSize = UDim2.new(0, 0, 0, #musicLibrary * 80)
    libraryFrame.Parent = parent
    
    -- Create track cards
    for i, trackData in ipairs(musicLibrary) do
        createTrackCard(libraryFrame, trackData, i)
    end
    
    -- Create player interface
    local playerFrame, trackTitle, trackArtist, trackIcon, progressBar, currentTimeLabel, totalTimeLabel, playPauseBtn = createPlayerInterface(parent)
    
    return parent
end

return MusicFeature