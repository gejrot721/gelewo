-- CallUI.lua
-- UI untuk sistem panggilan telepon individu dan grup

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local PhoneConfig = require(script.Parent.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Parent.Shared.PhoneTypes)
local UIScale = require(script.Parent.Parent.Parent.Shared.Utils.UIScale)

local CallUI = {}

-- Create call screen
function CallUI.createCallScreen(parent)
    local scale, deviceType = UIScale.calculateScale()
    
    local callScreen = Instance.new("Frame")
    callScreen.Name = "CallScreen"
    callScreen.BackgroundTransparency = 1
    callScreen.Size = UDim2.new(1, 0, 1, 0)
    callScreen.Position = UDim2.new(0, 0, 0, 0)
    callScreen.Visible = false
    callScreen.Parent = parent
    
    -- Background gradient
    CallUI.createBackground(callScreen, scale, deviceType)
    
    -- Call content
    CallUI.createCallContent(callScreen, scale, deviceType)
    
    -- Call controls
    CallUI.createCallControls(callScreen, scale, deviceType)
    
    return callScreen
end

-- Create background with gradient
function CallUI.createBackground(parent, scale, deviceType)
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    background.BorderSizePixel = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.Parent = parent
    
    -- Add gradient effect using multiple frames
    local gradient1 = Instance.new("Frame")
    gradient1.Name = "Gradient1"
    gradient1.BackgroundColor3 = Color3.fromRGB(25, 118, 210)
    gradient1.BorderSizePixel = 0
    gradient1.Size = UDim2.new(1, 0, 0.5, 0)
    gradient1.Position = UDim2.new(0, 0, 0, 0)
    gradient1.Parent = background
    
    local gradient2 = Instance.new("Frame")
    gradient2.Name = "Gradient2"
    gradient2.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    gradient2.BorderSizePixel = 0
    gradient2.Size = UDim2.new(1, 0, 0.5, 0)
    gradient2.Position = UDim2.new(0, 0, 0.5, 0)
    gradient2.Parent = background
end

-- Create call content (contact info, avatar, etc.)
function CallUI.createCallContent(parent, scale, deviceType)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 0.6, 0)
    contentContainer.Position = UDim2.new(0, 0, 0, 0)
    contentContainer.Parent = parent
    
    -- Call status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Calling..."
    statusLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    statusLabel.TextScaled = true
    statusLabel.Font = PhoneConfig.UI.FONTS.BODY
    statusLabel.TextSize = UIScale.getFontSize(16, deviceType)
    statusLabel.Size = UDim2.new(1, 0, 0, 32 * scale)
    statusLabel.Position = UDim2.new(0, 0, 0.3, 0)
    statusLabel.Parent = contentContainer
    
    -- Contact avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Size = UDim2.new(0, 120 * scale, 0, 120 * scale)
    avatar.Position = UDim2.new(0.5, -60 * scale, 0.4, -60 * scale)
    avatar.Parent = contentContainer
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar
    
    -- Contact name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Contact Name"
    nameLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    nameLabel.TextScaled = true
    nameLabel.Font = PhoneConfig.UI.FONTS.HEADER
    nameLabel.TextSize = UIScale.getFontSize(24, deviceType)
    nameLabel.Size = UDim2.new(1, 0, 0, 32 * scale)
    nameLabel.Position = UDim2.new(0, 0, 0.65, 0)
    nameLabel.Parent = contentContainer
    
    -- Call duration
    local durationLabel = Instance.new("TextLabel")
    durationLabel.Name = "DurationLabel"
    durationLabel.BackgroundTransparency = 1
    durationLabel.Text = "00:00"
    durationLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    durationLabel.TextTransparency = 0.7
    durationLabel.TextScaled = true
    durationLabel.Font = PhoneConfig.UI.FONTS.BODY
    durationLabel.TextSize = UIScale.getFontSize(14, deviceType)
    durationLabel.Size = UDim2.new(1, 0, 0, 24 * scale)
    durationLabel.Position = UDim2.new(0, 0, 0.75, 0)
    durationLabel.Parent = contentContainer
    
    -- Add pulsing animation to avatar during ringing
    CallUI.addPulsingAnimation(avatar)
end

-- Create call controls (buttons)
function CallUI.createCallControls(parent, scale, deviceType)
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "ControlsContainer"
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Size = UDim2.new(1, 0, 0.4, 0)
    controlsContainer.Position = UDim2.new(0, 0, 0.6, 0)
    controlsContainer.Parent = parent
    
    -- Control buttons grid
    local buttonsGrid = Instance.new("Frame")
    buttonsGrid.Name = "ButtonsGrid"
    buttonsGrid.BackgroundTransparency = 1
    buttonsGrid.Size = UDim2.new(1, -64 * scale, 0, 200 * scale)
    buttonsGrid.Position = UDim2.new(0, 32 * scale, 0.5, -100 * scale)
    buttonsGrid.Parent = controlsContainer
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 80 * scale, 0, 80 * scale)
    gridLayout.CellPadding = UDim2.new(0, 16 * scale, 0, 16 * scale)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    gridLayout.Parent = buttonsGrid
    
    -- Answer/End call button (center, larger)
    local endCallButton = CallUI.createCallButton("❌", PhoneConfig.UI.COLORS.ERROR, 1.5, scale, deviceType)
    endCallButton.Name = "EndCallButton"
    endCallButton.Parent = buttonsGrid
    
    -- Mute button
    local muteButton = CallUI.createCallButton("🔇", PhoneConfig.UI.COLORS.ON_PRIMARY, 1, scale, deviceType)
    muteButton.Name = "MuteButton"
    muteButton.Parent = buttonsGrid
    
    -- Speaker button
    local speakerButton = CallUI.createCallButton("🔊", PhoneConfig.UI.COLORS.ON_PRIMARY, 1, scale, deviceType)
    speakerButton.Name = "SpeakerButton"
    speakerButton.Parent = buttonsGrid
    
    -- Add call button (for group calls)
    local addCallButton = CallUI.createCallButton("👥", PhoneConfig.UI.COLORS.ON_PRIMARY, 1, scale, deviceType)
    addCallButton.Name = "AddCallButton"
    addCallButton.Parent = buttonsGrid
    
    -- Video call button
    local videoButton = CallUI.createCallButton("📹", PhoneConfig.UI.COLORS.ON_PRIMARY, 1, scale, deviceType)
    videoButton.Name = "VideoButton"
    videoButton.Parent = buttonsGrid
    
    -- Keypad button
    local keypadButton = CallUI.createCallButton("⌨", PhoneConfig.UI.COLORS.ON_PRIMARY, 1, scale, deviceType)
    keypadButton.Name = "KeypadButton"
    keypadButton.Parent = buttonsGrid
    
    -- Add button functionality
    CallUI.setupCallButtonFunctions(endCallButton, muteButton, speakerButton, addCallButton, videoButton, keypadButton)
end

-- Create individual call button
function CallUI.createCallButton(icon, color, scaleMultiplier, scale, deviceType)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = icon
    button.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    button.TextScaled = true
    button.Font = PhoneConfig.UI.FONTS.BODY
    button.TextSize = UIScale.getFontSize(24 * scaleMultiplier, deviceType)
    button.Size = UDim2.new(0, 80 * scale * scaleMultiplier, 0, 80 * scale * scaleMultiplier)
    
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
    
    -- Add click effects
    button.MouseButton1Down:Connect(function()
        local pressTween = TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 72 * scale * scaleMultiplier, 0, 72 * scale * scaleMultiplier)}
        )
        pressTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local releaseTween = TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 80 * scale * scaleMultiplier, 0, 80 * scale * scaleMultiplier)}
        )
        releaseTween:Play()
    end)
    
    return button
end

-- Setup call button functions
function CallUI.setupCallButtonFunctions(endCallButton, muteButton, speakerButton, addCallButton, videoButton, keypadButton)
    endCallButton.MouseButton1Click:Connect(function()
        CallUI.endCall()
    end)
    
    muteButton.MouseButton1Click:Connect(function()
        CallUI.toggleMute(muteButton)
    end)
    
    speakerButton.MouseButton1Click:Connect(function()
        CallUI.toggleSpeaker(speakerButton)
    end)
    
    addCallButton.MouseButton1Click:Connect(function()
        CallUI.addToCall()
    end)
    
    videoButton.MouseButton1Click:Connect(function()
        CallUI.toggleVideo(videoButton)
    end)
    
    keypadButton.MouseButton1Click:Connect(function()
        CallUI.showKeypad()
    end)
end

-- Add pulsing animation to avatar
function CallUI.addPulsingAnimation(avatar)
    local originalSize = avatar.Size
    local pulseSize = UDim2.new(
        originalSize.X.Scale * 1.1,
        originalSize.X.Offset * 1.1,
        originalSize.Y.Scale * 1.1,
        originalSize.Y.Offset * 1.1
    )
    
    local pulseTween = TweenService:Create(
        avatar,
        TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = pulseSize}
    )
    
    pulseTween:Play()
    
    return pulseTween
end

-- Update call status
function CallUI.updateCallStatus(statusLabel, status, contactName)
    local statusTexts = {
        [PhoneTypes.CallStatus.IDLE] = "Ready",
        [PhoneTypes.CallStatus.RINGING] = "Calling...",
        [PhoneTypes.CallStatus.CONNECTED] = "Connected",
        [PhoneTypes.CallStatus.ENDED] = "Call Ended",
        [PhoneTypes.CallStatus.DECLINED] = "Call Declined",
        [PhoneTypes.CallStatus.BUSY] = "Line Busy"
    }
    
    statusLabel.Text = statusTexts[status] or status
end

-- Update call duration
function CallUI.updateCallDuration(durationLabel, startTime)
    local currentTime = tick()
    local duration = currentTime - startTime
    
    local minutes = math.floor(duration / 60)
    local seconds = math.floor(duration % 60)
    
    durationLabel.Text = string.format("%02d:%02d", minutes, seconds)
end

-- Call control functions
function CallUI.endCall()
    print("Ending call")
    -- This will be handled by the CallController
end

function CallUI.toggleMute(muteButton)
    local isMuted = muteButton.Text == "🔇"
    muteButton.Text = isMuted and "🎤" or "🔇"
    
    -- Toggle button color
    local newColor = isMuted and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.ERROR
    local colorTween = TweenService:Create(
        muteButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = newColor}
    )
    colorTween:Play()
    
    print("Toggling mute:", not isMuted)
    -- This will be handled by the CallController
end

function CallUI.toggleSpeaker(speakerButton)
    local isSpeakerOn = speakerButton.Text == "🔊"
    speakerButton.Text = isSpeakerOn and "📱" or "🔊"
    
    -- Toggle button color
    local newColor = isSpeakerOn and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.SUCCESS
    local colorTween = TweenService:Create(
        speakerButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = newColor}
    )
    colorTween:Play()
    
    print("Toggling speaker:", not isSpeakerOn)
    -- This will be handled by the CallController
end

function CallUI.addToCall()
    print("Adding to call")
    -- This will open the contacts screen to add more people
end

function CallUI.toggleVideo(videoButton)
    local isVideoOn = videoButton.Text == "📹"
    videoButton.Text = isVideoOn and "📷" or "📹"
    
    -- Toggle button color
    local newColor = isVideoOn and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.SUCCESS
    local colorTween = TweenService:Create(
        videoButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = newColor}
    )
    colorTween:Play()
    
    print("Toggling video:", not isVideoOn)
    -- This will be handled by the CallController
end

function CallUI.showKeypad()
    print("Showing keypad")
    -- This will show a dial pad for DTMF tones
end

-- Show/hide call screen
function CallUI.showCallScreen(callScreen)
    callScreen.Visible = true
    callScreen.BackgroundTransparency = 1
    
    local fadeTween = TweenService:Create(
        callScreen,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    
    fadeTween:Play()
end

function CallUI.hideCallScreen(callScreen)
    local fadeTween = TweenService:Create(
        callScreen,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        callScreen.Visible = false
    end)
end

-- Create incoming call notification
function CallUI.createIncomingCallNotification(contact)
    local screenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "IncomingCallNotification"
    notificationFrame.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Size = UDim2.new(0, 350, 0, 100)
    notificationFrame.Position = UDim2.new(0.5, -175, 0, 50)
    notificationFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = notificationFrame
    
    -- Contact info
    local contactName = Instance.new("TextLabel")
    contactName.BackgroundTransparency = 1
    contactName.Text = contact.displayName or contact.username
    contactName.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    contactName.TextScaled = true
    contactName.Font = PhoneConfig.UI.FONTS.HEADER
    contactName.TextSize = 18
    contactName.Size = UDim2.new(1, -120, 0.5, 0)
    contactName.Position = UDim2.new(0, 60, 0, 10)
    contactName.Parent = notificationFrame
    
    local callerInfo = Instance.new("TextLabel")
    callerInfo.BackgroundTransparency = 1
    callerInfo.Text = "Incoming call"
    callerInfo.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    callerInfo.TextTransparency = 0.6
    callerInfo.TextScaled = true
    callerInfo.Font = PhoneConfig.UI.FONTS.BODY
    callerInfo.TextSize = 14
    callerInfo.Size = UDim2.new(1, -120, 0.5, 0)
    callerInfo.Position = UDim2.new(0, 60, 0.5, -10)
    callerInfo.Parent = notificationFrame
    
    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Position = UDim2.new(0, 10, 0.5, -20)
    avatar.Parent = notificationFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar
    
    -- Answer button
    local answerButton = Instance.new("TextButton")
    answerButton.BackgroundColor3 = PhoneConfig.UI.COLORS.SUCCESS
    answerButton.BorderSizePixel = 0
    answerButton.Text = "📞"
    answerButton.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    answerButton.TextScaled = true
    answerButton.Font = PhoneConfig.UI.FONTS.BODY
    answerButton.TextSize = 16
    answerButton.Size = UDim2.new(0, 40, 0, 40)
    answerButton.Position = UDim2.new(1, -100, 0.5, -20)
    answerButton.Parent = notificationFrame
    
    local answerCorner = Instance.new("UICorner")
    answerCorner.CornerRadius = UDim.new(0.5, 0)
    answerCorner.Parent = answerButton
    
    -- Decline button
    local declineButton = Instance.new("TextButton")
    declineButton.BackgroundColor3 = PhoneConfig.UI.COLORS.ERROR
    declineButton.BorderSizePixel = 0
    declineButton.Text = "❌"
    declineButton.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    declineButton.TextScaled = true
    declineButton.Font = PhoneConfig.UI.FONTS.BODY
    declineButton.TextSize = 16
    declineButton.Size = UDim2.new(0, 40, 0, 40)
    declineButton.Position = UDim2.new(1, -50, 0.5, -20)
    declineButton.Parent = notificationFrame
    
    local declineCorner = Instance.new("UICorner")
    declineCorner.CornerRadius = UDim.new(0.5, 0)
    declineCorner.Parent = declineButton
    
    -- Add button functionality
    answerButton.MouseButton1Click:Connect(function()
        CallUI.answerCall()
        notificationFrame:Destroy()
    end)
    
    declineButton.MouseButton1Click:Connect(function()
        CallUI.declineCall()
        notificationFrame:Destroy()
    end)
    
    -- Auto-dismiss after 30 seconds
    wait(30)
    if notificationFrame.Parent then
        notificationFrame:Destroy()
    end
    
    return notificationFrame
end

function CallUI.answerCall()
    print("Answering call")
    -- This will be handled by the CallController
end

function CallUI.declineCall()
    print("Declining call")
    -- This will be handled by the CallController
end

return CallUI