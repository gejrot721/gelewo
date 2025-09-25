-- GroupCallUI.lua
-- UI untuk sistem panggilan grup dengan voice chat

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local PhoneConfig = require(script.Parent.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Parent.Shared.PhoneTypes)
local UIScale = require(script.Parent.Parent.Parent.Shared.Utils.UIScale)

local GroupCallUI = {}

-- Create group call screen
function GroupCallUI.createGroupCallScreen(parent)
    local scale, deviceType = UIScale.calculateScale()
    
    local groupCallScreen = Instance.new("Frame")
    groupCallScreen.Name = "GroupCallScreen"
    groupCallScreen.BackgroundTransparency = 1
    groupCallScreen.Size = UDim2.new(1, 0, 1, 0)
    groupCallScreen.Position = UDim2.new(0, 0, 0, 0)
    groupCallScreen.Visible = false
    groupCallScreen.Parent = parent
    
    -- Background gradient
    GroupCallUI.createBackground(groupCallScreen, scale, deviceType)
    
    -- Participants grid
    GroupCallUI.createParticipantsGrid(groupCallScreen, scale, deviceType)
    
    -- Group call controls
    GroupCallUI.createGroupCallControls(groupCallScreen, scale, deviceType)
    
    -- Call info
    GroupCallUI.createCallInfo(groupCallScreen, scale, deviceType)
    
    return groupCallScreen
end

-- Create background with gradient
function GroupCallUI.createBackground(parent, scale, deviceType)
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    background.BorderSizePixel = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.Parent = parent
    
    -- Add animated gradient effect
    local gradient1 = Instance.new("Frame")
    gradient1.Name = "Gradient1"
    gradient1.BackgroundColor3 = Color3.fromRGB(25, 118, 210)
    gradient1.BorderSizePixel = 0
    gradient1.Size = UDim2.new(1, 0, 0.33, 0)
    gradient1.Position = UDim2.new(0, 0, 0, 0)
    gradient1.Parent = background
    
    local gradient2 = Instance.new("Frame")
    gradient2.Name = "Gradient2"
    gradient2.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    gradient2.BorderSizePixel = 0
    gradient2.Size = UDim2.new(1, 0, 0.33, 0)
    gradient2.Position = UDim2.new(0, 0, 0.33, 0)
    gradient2.Parent = background
    
    local gradient3 = Instance.new("Frame")
    gradient3.Name = "Gradient3"
    gradient3.BackgroundColor3 = Color3.fromRGB(41, 182, 246)
    gradient3.BorderSizePixel = 0
    gradient3.Size = UDim2.new(1, 0, 0.34, 0)
    gradient3.Position = UDim2.new(0, 0, 0.66, 0)
    gradient3.Parent = background
    
    -- Add animated gradient movement
    GroupCallUI.animateGradient(gradient1, gradient2, gradient3)
end

-- Create participants grid
function GroupCallUI.createParticipantsGrid(parent, scale, deviceType)
    local participantsContainer = Instance.new("Frame")
    participantsContainer.Name = "ParticipantsContainer"
    participantsContainer.BackgroundTransparency = 1
    participantsContainer.Size = UDim2.new(1, -32 * scale, 0.5, -32 * scale)
    participantsContainer.Position = UDim2.new(0, 16 * scale, 0, 80 * scale)
    participantsContainer.Parent = parent
    
    local participantsGrid = Instance.new("Frame")
    participantsGrid.Name = "ParticipantsGrid"
    participantsGrid.BackgroundTransparency = 1
    participantsGrid.Size = UDim2.new(1, 0, 1, 0)
    participantsGrid.Position = UDim2.new(0, 0, 0, 0)
    participantsGrid.Parent = participantsContainer
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 100 * scale, 0, 100 * scale)
    gridLayout.CellPadding = UDim2.new(0, 8 * scale, 0, 8 * scale)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    gridLayout.Parent = participantsGrid
    
    -- Add sample participants (will be populated dynamically)
    GroupCallUI.addParticipant(participantsGrid, "Player1", true, scale, deviceType)
    GroupCallUI.addParticipant(participantsGrid, "Player2", false, scale, deviceType)
    GroupCallUI.addParticipant(participantsGrid, "Player3", true, scale, deviceType)
    GroupCallUI.addParticipant(participantsGrid, "You", true, scale, deviceType)
    
    return participantsGrid
end

-- Add participant to grid
function GroupCallUI.addParticipant(parent, participantName, isSpeaking, scale, deviceType)
    local participantFrame = Instance.new("Frame")
    participantFrame.Name = "Participant_" .. participantName
    participantFrame.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    participantFrame.BorderSizePixel = 0
    participantFrame.Size = UDim2.new(0, 100 * scale, 0, 100 * scale)
    participantFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16 * scale)
    corner.Parent = participantFrame
    
    -- Speaking indicator (animated border)
    if isSpeaking then
        local speakingBorder = Instance.new("Frame")
        speakingBorder.Name = "SpeakingBorder"
        speakingBorder.BackgroundTransparency = 1
        speakingBorder.BorderSizePixel = 0
        speakingBorder.Size = UDim2.new(1, 4, 1, 4)
        speakingBorder.Position = UDim2.new(0, -2, 0, -2)
        speakingBorder.ZIndex = participantFrame.ZIndex - 1
        speakingBorder.Parent = participantFrame
        
        local borderCorner = Instance.new("UICorner")
        borderCorner.CornerRadius = UDim.new(0, 18 * scale)
        borderCorner.Parent = speakingBorder
        
        -- Animate speaking indicator
        GroupCallUI.animateSpeakingIndicator(speakingBorder)
    end
    
    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
    avatar.Position = UDim2.new(0.5, -30 * scale, 0, 10 * scale)
    avatar.Parent = participantFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = participantName
    nameLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    nameLabel.TextScaled = true
    nameLabel.Font = PhoneConfig.UI.FONTS.BODY
    nameLabel.TextSize = UIScale.getFontSize(10, deviceType)
    nameLabel.Size = UDim2.new(1, -8 * scale, 0, 20 * scale)
    nameLabel.Position = UDim2.new(0, 4 * scale, 1, -25 * scale)
    nameLabel.Parent = participantFrame
    
    -- Mute indicator
    local muteIndicator = Instance.new("Frame")
    muteIndicator.Name = "MuteIndicator"
    muteIndicator.BackgroundColor3 = PhoneConfig.UI.COLORS.ERROR
    muteIndicator.BorderSizePixel = 0
    muteIndicator.Size = UDim2.new(0, 16 * scale, 0, 16 * scale)
    muteIndicator.Position = UDim2.new(1, -20 * scale, 0, 4 * scale)
    muteIndicator.Visible = false -- Will be shown if muted
    muteIndicator.Parent = participantFrame
    
    local muteCorner = Instance.new("UICorner")
    muteCorner.CornerRadius = UDim.new(0.5, 0)
    muteCorner.Parent = muteIndicator
    
    local muteIcon = Instance.new("TextLabel")
    muteIcon.Name = "MuteIcon"
    muteIcon.BackgroundTransparency = 1
    muteIcon.Text = "🔇"
    muteIcon.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    muteIcon.TextScaled = true
    muteIcon.Font = PhoneConfig.UI.FONTS.BODY
    muteIcon.TextSize = UIScale.getFontSize(8, deviceType)
    muteIcon.Size = UDim2.new(1, 0, 1, 0)
    muteIcon.Position = UDim2.new(0, 0, 0, 0)
    muteIcon.Parent = muteIndicator
    
    return participantFrame
end

-- Create group call controls
function GroupCallUI.createGroupCallControls(parent, scale, deviceType)
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "ControlsContainer"
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Size = UDim2.new(1, 0, 0.3, 0)
    controlsContainer.Position = UDim2.new(0, 0, 0.7, 0)
    controlsContainer.Parent = parent
    
    -- Control buttons
    local buttonsContainer = Instance.new("Frame")
    buttonsContainer.Name = "ButtonsContainer"
    buttonsContainer.BackgroundTransparency = 1
    buttonsContainer.Size = UDim2.new(1, -64 * scale, 0, 80 * scale)
    buttonsContainer.Position = UDim2.new(0, 32 * scale, 0.5, -40 * scale)
    buttonsContainer.Parent = controlsContainer
    
    local buttonsLayout = Instance.new("UIGridLayout")
    buttonsLayout.CellSize = UDim2.new(0, 60 * scale, 0, 60 * scale)
    buttonsLayout.CellPadding = UDim2.new(0, 20 * scale, 0, 0)
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonsLayout.Parent = buttonsContainer
    
    -- Mute button
    local muteButton = GroupCallUI.createGroupCallButton("🎤", PhoneConfig.UI.COLORS.ON_PRIMARY, scale, deviceType)
    muteButton.Name = "MuteButton"
    muteButton.Parent = buttonsContainer
    
    -- Speaker button
    local speakerButton = GroupCallUI.createGroupCallButton("🔊", PhoneConfig.UI.COLORS.ON_PRIMARY, scale, deviceType)
    speakerButton.Name = "SpeakerButton"
    speakerButton.Parent = buttonsContainer
    
    -- Add participant button
    local addButton = GroupCallUI.createGroupCallButton("👥", PhoneConfig.UI.COLORS.ON_PRIMARY, scale, deviceType)
    addButton.Name = "AddButton"
    addButton.Parent = buttonsContainer
    
    -- End call button (larger, different color)
    local endCallButton = GroupCallUI.createGroupCallButton("❌", PhoneConfig.UI.COLORS.ERROR, scale, deviceType)
    endCallButton.Name = "EndCallButton"
    endCallButton.Size = UDim2.new(0, 80 * scale, 0, 80 * scale)
    endCallButton.Parent = buttonsContainer
    
    -- Setup button functions
    GroupCallUI.setupGroupCallButtonFunctions(muteButton, speakerButton, addButton, endCallButton)
end

-- Create group call button
function GroupCallUI.createGroupCallButton(icon, color, scale, deviceType)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = icon
    button.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    button.TextScaled = true
    button.Font = PhoneConfig.UI.FONTS.BODY
    button.TextSize = UIScale.getFontSize(20, deviceType)
    button.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0)
    buttonCorner.Parent = button
    
    -- Add shadow
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.ZIndex = button.ZIndex - 1
    shadow.Parent = button
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0.5, 0)
    shadowCorner.Parent = shadow
    
    return button
end

-- Setup group call button functions
function GroupCallUI.setupGroupCallButtonFunctions(muteButton, speakerButton, addButton, endCallButton)
    muteButton.MouseButton1Click:Connect(function()
        GroupCallUI.toggleMute(muteButton)
    end)
    
    speakerButton.MouseButton1Click:Connect(function()
        GroupCallUI.toggleSpeaker(speakerButton)
    end)
    
    addButton.MouseButton1Click:Connect(function()
        GroupCallUI.addParticipant()
    end)
    
    endCallButton.MouseButton1Click:Connect(function()
        GroupCallUI.endGroupCall()
    end)
end

-- Create call info
function GroupCallUI.createCallInfo(parent, scale, deviceType)
    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "InfoContainer"
    infoContainer.BackgroundTransparency = 1
    infoContainer.Size = UDim2.new(1, 0, 0, 60 * scale)
    infoContainer.Position = UDim2.new(0, 0, 0, 10 * scale)
    infoContainer.Parent = parent
    
    -- Call duration
    local durationLabel = Instance.new("TextLabel")
    durationLabel.Name = "DurationLabel"
    durationLabel.BackgroundTransparency = 1
    durationLabel.Text = "00:00"
    durationLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    durationLabel.TextScaled = true
    durationLabel.Font = PhoneConfig.UI.FONTS.HEADER
    durationLabel.TextSize = UIScale.getFontSize(24, deviceType)
    durationLabel.Size = UDim2.new(1, 0, 0.5, 0)
    durationLabel.Position = UDim2.new(0, 0, 0, 0)
    durationLabel.Parent = infoContainer
    
    -- Participant count
    local participantCountLabel = Instance.new("TextLabel")
    participantCountLabel.Name = "ParticipantCountLabel"
    participantCountLabel.BackgroundTransparency = 1
    participantCountLabel.Text = "4 participants"
    participantCountLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    participantCountLabel.TextTransparency = 0.7
    participantCountLabel.TextScaled = true
    participantCountLabel.Font = PhoneConfig.UI.FONTS.BODY
    participantCountLabel.TextSize = UIScale.getFontSize(14, deviceType)
    participantCountLabel.Size = UDim2.new(1, 0, 0.5, 0)
    participantCountLabel.Position = UDim2.new(0, 0, 0.5, 0)
    participantCountLabel.Parent = infoContainer
end

-- Animate gradient background
function GroupCallUI.animateGradient(gradient1, gradient2, gradient3)
    local function animateGradientFrame(frame, delay)
        local originalPosition = frame.Position
        local targetPosition = UDim2.new(0, 0, 1, 0)
        
        local tween = TweenService:Create(
            frame,
            TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Position = targetPosition}
        )
        
        wait(delay)
        tween:Play()
    end
    
    spawn(function()
        animateGradientFrame(gradient1, 0)
        animateGradientFrame(gradient2, 1)
        animateGradientFrame(gradient3, 2)
    end)
end

-- Animate speaking indicator
function GroupCallUI.animateSpeakingIndicator(border)
    local function animateBorder()
        local pulseTween = TweenService:Create(
            border,
            TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.3}
        )
        pulseTween:Play()
        
        -- Also animate size slightly
        local sizeTween = TweenService:Create(
            border,
            TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Size = UDim2.new(1, 8, 1, 8)}
        )
        sizeTween:Play()
    end
    
    spawn(animateBorder)
end

-- Group call control functions
function GroupCallUI.toggleMute(muteButton)
    local isMuted = muteButton.Text == "🔇"
    muteButton.Text = isMuted and "🎤" or "🔇"
    
    local newColor = isMuted and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.ERROR
    local colorTween = TweenService:Create(
        muteButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = newColor}
    )
    colorTween:Play()
    
    print("Toggling group call mute:", not isMuted)
    -- This will be handled by the GroupCallController
end

function GroupCallUI.toggleSpeaker(speakerButton)
    local isSpeakerOn = speakerButton.Text == "🔊"
    speakerButton.Text = isSpeakerOn and "📱" or "🔊"
    
    local newColor = isSpeakerOn and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.SUCCESS
    local colorTween = TweenService:Create(
        speakerButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = newColor}
    )
    colorTween:Play()
    
    print("Toggling group call speaker:", not isSpeakerOn)
    -- This will be handled by the GroupCallController
end

function GroupCallUI.addParticipant()
    print("Adding participant to group call")
    -- This will open contacts to add more people
end

function GroupCallUI.endGroupCall()
    print("Ending group call")
    -- This will be handled by the GroupCallController
end

-- Update participant speaking status
function GroupCallUI.updateParticipantSpeaking(participantName, isSpeaking)
    -- Find participant frame and update speaking indicator
    print("Updating speaking status for", participantName, ":", isSpeaking)
end

-- Update call duration
function GroupCallUI.updateCallDuration(durationLabel, startTime)
    local currentTime = tick()
    local duration = currentTime - startTime
    
    local minutes = math.floor(duration / 60)
    local seconds = math.floor(duration % 60)
    
    durationLabel.Text = string.format("%02d:%02d", minutes, seconds)
end

-- Update participant count
function GroupCallUI.updateParticipantCount(countLabel, count)
    countLabel.Text = count .. " participant" .. (count == 1 and "" or "s")
end

-- Show/hide group call screen
function GroupCallUI.showGroupCallScreen(groupCallScreen)
    groupCallScreen.Visible = true
    groupCallScreen.BackgroundTransparency = 1
    
    local fadeTween = TweenService:Create(
        groupCallScreen,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    
    fadeTween:Play()
end

function GroupCallUI.hideGroupCallScreen(groupCallScreen)
    local fadeTween = TweenService:Create(
        groupCallScreen,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        groupCallScreen.Visible = false
    end)
end

return GroupCallUI