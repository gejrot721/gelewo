-- 💬 PRIVATE CHAT SYSTEM - CLIENT SCRIPT
-- Features: Private Chat, Group Chat, Modern UI, Auto-scale
-- Place this script in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for RemoteEvents
local ChatEvents = ReplicatedStorage:WaitForChild("ChatEvents")
local ChatToggleEvent = ChatEvents:WaitForChild("ChatToggle")
local PrivateChatEvent = ChatEvents:WaitForChild("PrivateChat")
local GroupChatEvent = ChatEvents:WaitForChild("GroupChat")
local ChatDataEvent = ChatEvents:WaitForChild("ChatData")
local NotificationEvent = ChatEvents:WaitForChild("Notification")

local player = Players.LocalPlayer

-- Private Chat Client Class
local PrivateChatClient = {}
PrivateChatClient.__index = PrivateChatClient

function PrivateChatClient.new()
    local self = setmetatable({}, PrivateChatClient)
    
    -- Client state
    self.isChatOpen = false
    self.currentChat = "home"
    self.currentPrivateChat = nil
    self.currentGroupChat = nil
    self.scale = 1
    self.deviceType = "pc"
    
    -- UI Elements
    self.screenGui = nil
    self.chatFrame = nil
    self.toggleButton = nil
    self.homeScreen = nil
    self.privateChatScreen = nil
    self.groupChatScreen = nil
    self.onlinePlayersList = nil
    
    -- Initialize
    self:detectDevice()
    self:createGUI()
    self:setupEventHandlers()
    self:setupControls()
    
    return self
end

-- Detect Device Type
function PrivateChatClient:detectDevice()
    if UserInputService.TouchEnabled then
        self.deviceType = "mobile"
    elseif UserInputService.GamepadEnabled then
        self.deviceType = "console"
    else
        self.deviceType = "pc"
    end
end

-- Create GUI with Auto-scale
function PrivateChatClient:createGUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PrivateChatClient"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.DisplayOrder = 100
    self.screenGui.Parent = player.PlayerGui
    
    -- Calculate scale based on device
    local screenSize = workspace.CurrentCamera.ViewportSize
    if self.deviceType == "mobile" then
        self.scale = math.min(screenSize.X / 400, screenSize.Y / 800)
    elseif self.deviceType == "console" then
        self.scale = math.min(screenSize.X / 1920, screenSize.Y / 1080) * 1.2
    else
        self.scale = math.min(screenSize.X / 1920, screenSize.Y / 1080)
    end
    
    self.scale = math.max(0.3, math.min(2, self.scale))
    
    -- Create toggle button (RIGHT SIDE)
    self:createToggleButton()
    
    -- Create chat frame
    self:createChatFrame()
    
    print("💬 Private Chat Client GUI created! Device: " .. self.deviceType .. ", Scale: " .. self.scale)
end

-- Create Toggle Button (RIGHT SIDE)
function PrivateChatClient:createToggleButton()
    local buttonSize = self.deviceType == "mobile" and 90 or 70
    local containerSize = buttonSize + 30
    
    -- Toggle container
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(0, containerSize * self.scale, 0, containerSize * self.scale)
    toggleContainer.Position = UDim2.new(1, -containerSize * self.scale - 15, 0.5, -containerSize * self.scale / 2)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.ZIndex = 1000
    toggleContainer.Parent = self.screenGui
    
    -- Glow effect
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 15, 1, 15)
    glow.Position = UDim2.new(0, -7.5, 0, -7.5)
    glow.BackgroundColor3 = Color3.fromRGB(0, 123, 255) -- Modern blue
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.ZIndex = 999
    glow.Parent = toggleContainer
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    
    -- Main toggle button
    self.toggleButton = Instance.new("TextButton")
    self.toggleButton.Name = "ChatToggle"
    self.toggleButton.Size = UDim2.new(0, buttonSize * self.scale, 0, buttonSize * self.scale)
    self.toggleButton.Position = UDim2.new(0.5, -buttonSize * self.scale / 2, 0.5, -buttonSize * self.scale / 2)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(0, 123, 255) -- Modern blue
    self.toggleButton.BorderSizePixel = 0
    self.toggleButton.Text = "💬"
    self.toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.toggleButton.TextScaled = true
    self.toggleButton.Font = Enum.Font.GothamBold
    self.toggleButton.ZIndex = 1001
    self.toggleButton.Parent = toggleContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = self.toggleButton
    
    -- Status indicator
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 18 * self.scale, 0, 18 * self.scale)
    statusDot.Position = UDim2.new(1, -22 * self.scale, 0, 3 * self.scale)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 1002
    statusDot.Parent = toggleContainer
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1.8, 0, 0, 22 * self.scale)
    statusText.Position = UDim2.new(-0.4, 0, 1, 8 * self.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = "CHAT CLOSED"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.GothamBold
    statusText.ZIndex = 1001
    statusText.Parent = toggleContainer
    
    -- Instructions
    local instructions = Instance.new("TextLabel")
    instructions.Size = UDim2.new(2.2, 0, 0, 18 * self.scale)
    instructions.Position = UDim2.new(-0.6, 0, 1, 35 * self.scale)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Click to Open Private Chat"
    instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
    instructions.TextScaled = true
    instructions.Font = Enum.Font.Gotham
    instructions.ZIndex = 1001
    instructions.Parent = toggleContainer
    
    -- Store references
    self.statusDot = statusDot
    self.statusText = statusText
    self.toggleContainer = toggleContainer
    
    -- Click functionality
    self.toggleButton.MouseButton1Click:Connect(function()
        self:toggleChat()
    end)
    
    -- Hover effects
    self.toggleButton.MouseEnter:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), 
            {Size = UDim2.new(0, (buttonSize + 8) * self.scale, 0, (buttonSize + 8) * self.scale)}):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
    end)
    
    self.toggleButton.MouseLeave:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), 
            {Size = UDim2.new(0, buttonSize * self.scale, 0, buttonSize * self.scale)}):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
    end)
    
    -- Pulsing animation
    spawn(function()
        while self.toggleButton and self.toggleButton.Parent do
            TweenService:Create(self.toggleButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Size = UDim2.new(0, (buttonSize + 4) * self.scale, 0, (buttonSize + 4) * self.scale)}):Play()
            wait(1.5)
            TweenService:Create(self.toggleButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Size = UDim2.new(0, buttonSize * self.scale, 0, buttonSize * self.scale)}):Play()
            wait(1.5)
        end
    end)
end

-- Create Chat Frame
function PrivateChatClient:createChatFrame()
    local chatWidth = self.deviceType == "mobile" and 320 or 400
    local chatHeight = self.deviceType == "mobile" and 600 or 700
    
    self.chatFrame = Instance.new("Frame")
    self.chatFrame.Name = "PrivateChatFrame"
    self.chatFrame.Size = UDim2.new(0, chatWidth * self.scale, 0, chatHeight * self.scale)
    self.chatFrame.Position = UDim2.new(1, -chatWidth * self.scale - 20, 0.5, -chatHeight * self.scale / 2)
    self.chatFrame.BackgroundColor3 = Color3.fromRGB(0, 123, 255) -- Modern blue
    self.chatFrame.BorderSizePixel = 0
    self.chatFrame.Visible = false
    self.chatFrame.ZIndex = 5
    self.chatFrame.Parent = self.screenGui
    
    -- Chat corners
    local chatCorner = Instance.new("UICorner")
    chatCorner.CornerRadius = UDim.new(0, 25 * self.scale)
    chatCorner.Parent = self.chatFrame
    
    -- Screen area
    local screenArea = Instance.new("Frame")
    screenArea.Name = "ScreenArea"
    screenArea.Size = UDim2.new(1, -15 * self.scale, 1, -35 * self.scale)
    screenArea.Position = UDim2.new(0, 7.5 * self.scale, 0, 17.5 * self.scale)
    screenArea.BackgroundColor3 = Color3.fromRGB(248, 249, 250) -- Light background
    screenArea.BorderSizePixel = 0
    screenArea.ZIndex = 6
    screenArea.Parent = self.chatFrame
    
    local screenCorner = Instance.new("UICorner")
    screenCorner.CornerRadius = UDim.new(0, 20 * self.scale)
    screenCorner.Parent = screenArea
    
    -- Create screens
    self:createHomeScreen(screenArea)
    self:createPrivateChatScreen(screenArea)
    self:createGroupChatScreen(screenArea)
end

-- Create Home Screen
function PrivateChatClient:createHomeScreen(parent)
    self.homeScreen = Instance.new("ScrollingFrame")
    self.homeScreen.Name = "HomeScreen"
    self.homeScreen.Size = UDim2.new(1, 0, 1, 0)
    self.homeScreen.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    self.homeScreen.BorderSizePixel = 0
    self.homeScreen.ScrollBarThickness = 0
    self.homeScreen.Visible = true
    self.homeScreen.ZIndex = 7
    self.homeScreen.Parent = parent
    
    -- Modern header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 70 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.homeScreen
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20 * self.scale)
    headerCorner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.6, 0)
    title.Position = UDim2.new(0, 20 * self.scale, 0, 10 * self.scale)
    title.BackgroundTransparency = 1
    title.Text = "Private Chat"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0.4, 0)
    subtitle.Position = UDim2.new(0, 20 * self.scale, 0.6, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Private & Group Chats"
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 9
    subtitle.Parent = header
    
    -- Apps grid
    local appsGrid = Instance.new("UIGridLayout")
    appsGrid.CellSize = UDim2.new(0, 90 * self.scale, 0, 110 * self.scale)
    appsGrid.CellPadding = UDim2.new(0, 15 * self.scale, 0, 15 * self.scale)
    appsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    appsGrid.Parent = self.homeScreen
    
    -- Create modern chat apps
    local apps = {
        {icon = "💬", name = "Private", color = Color3.fromRGB(0, 123, 255), action = "private"},
        {icon = "👥", name = "Groups", color = Color3.fromRGB(0, 123, 255), action = "groups"},
        {icon = "👤", name = "Online", color = Color3.fromRGB(0, 123, 255), action = "online"},
        {icon = "⚙️", name = "Settings", color = Color3.fromRGB(0, 123, 255), action = "settings"}
    }
    
    for _, appData in ipairs(apps) do
        self:createAppIcon(appData)
    end
end

-- Create App Icon
function PrivateChatClient:createAppIcon(appData)
    local appButton = Instance.new("TextButton")
    appButton.BackgroundColor3 = appData.color
    appButton.BorderSizePixel = 0
    appButton.Text = ""
    appButton.ZIndex = 8
    appButton.Parent = self.homeScreen
    
    local appCorner = Instance.new("UICorner")
    appCorner.CornerRadius = UDim.new(0, 15 * self.scale)
    appCorner.Parent = appButton
    
    -- Shadow effect
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 7
    shadow.Parent = appButton
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15 * self.scale)
    shadowCorner.Parent = shadow
    
    local appIcon = Instance.new("TextLabel")
    appIcon.Size = UDim2.new(1, 0, 0.6, 0)
    appIcon.BackgroundTransparency = 1
    appIcon.Text = appData.icon
    appIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    appIcon.TextScaled = true
    appIcon.Font = Enum.Font.GothamBold
    appIcon.ZIndex = 9
    appIcon.Parent = appButton
    
    local appLabel = Instance.new("TextLabel")
    appLabel.Size = UDim2.new(1, 0, 0.4, 0)
    appLabel.Position = UDim2.new(0, 0, 0.6, 0)
    appLabel.BackgroundTransparency = 1
    appLabel.Text = appData.name
    appLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    appLabel.TextScaled = true
    appLabel.Font = Enum.Font.Gotham
    appLabel.ZIndex = 9
    appLabel.Parent = appButton
    
    appButton.MouseButton1Click:Connect(function()
        self:openApp(appData.action)
    end)
    
    -- Press effect
    appButton.MouseButton1Down:Connect(function()
        TweenService:Create(appButton, TweenInfo.new(0.1), 
            {Size = UDim2.new(0, 85 * self.scale, 0, 105 * self.scale)}):Play()
    end)
    
    appButton.MouseButton1Up:Connect(function()
        TweenService:Create(appButton, TweenInfo.new(0.1), 
            {Size = UDim2.new(0, 90 * self.scale, 0, 110 * self.scale)}):Play()
    end)
end

-- Create Private Chat Screen
function PrivateChatClient:createPrivateChatScreen(parent)
    self.privateChatScreen = Instance.new("Frame")
    self.privateChatScreen.Name = "PrivateChatScreen"
    self.privateChatScreen.Size = UDim2.new(1, 0, 1, 0)
    self.privateChatScreen.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    self.privateChatScreen.BorderSizePixel = 0
    self.privateChatScreen.Visible = false
    self.privateChatScreen.ZIndex = 7
    self.privateChatScreen.Parent = parent
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.privateChatScreen
    
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(0, 45 * self.scale, 0, 45 * self.scale)
    backButton.Position = UDim2.new(0, 10 * self.scale, 0.5, -22.5 * self.scale)
    backButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundTransparency = 0.8
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.fromRGB(0, 123, 255)
    backButton.TextScaled = true
    backButton.Font = Enum.Font.GothamBold
    backButton.ZIndex = 9
    backButton.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(1, 0)
    backCorner.Parent = backButton
    
    backButton.MouseButton1Click:Connect(function()
        self:goHome()
    end)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -65 * self.scale, 1, 0)
    title.Position = UDim2.new(0, 65 * self.scale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Private Chats"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
    
    -- Online players list
    self.onlinePlayersList = Instance.new("ScrollingFrame")
    self.onlinePlayersList.Size = UDim2.new(1, 0, 1, -60 * self.scale)
    self.onlinePlayersList.Position = UDim2.new(0, 0, 0, 60 * self.scale)
    self.onlinePlayersList.BackgroundTransparency = 1
    self.onlinePlayersList.BorderSizePixel = 0
    self.onlinePlayersList.ScrollBarThickness = 0
    self.onlinePlayersList.ZIndex = 7
    self.onlinePlayersList.Parent = self.privateChatScreen
    
    local playersLayout = Instance.new("UIListLayout")
    playersLayout.Padding = UDim.new(0, 2)
    playersLayout.Parent = self.onlinePlayersList
    
    -- Load online players
    ChatDataEvent:FireServer("get_online_players")
end

-- Create Group Chat Screen
function PrivateChatClient:createGroupChatScreen(parent)
    self.groupChatScreen = Instance.new("Frame")
    self.groupChatScreen.Name = "GroupChatScreen"
    self.groupChatScreen.Size = UDim2.new(1, 0, 1, 0)
    self.groupChatScreen.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    self.groupChatScreen.BorderSizePixel = 0
    self.groupChatScreen.Visible = false
    self.groupChatScreen.ZIndex = 7
    self.groupChatScreen.Parent = parent
    
    -- Similar structure to private chat screen
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.groupChatScreen
    
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(0, 45 * self.scale, 0, 45 * self.scale)
    backButton.Position = UDim2.new(0, 10 * self.scale, 0.5, -22.5 * self.scale)
    backButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundTransparency = 0.8
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.fromRGB(0, 123, 255)
    backButton.TextScaled = true
    backButton.Font = Enum.Font.GothamBold
    backButton.ZIndex = 9
    backButton.Parent = header
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(1, 0)
    backCorner.Parent = backButton
    
    backButton.MouseButton1Click:Connect(function()
        self:goHome()
    end)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -65 * self.scale, 1, 0)
    title.Position = UDim2.new(0, 65 * self.scale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Group Chats"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
    
    -- Create group button
    local createGroupButton = Instance.new("TextButton")
    createGroupButton.Size = UDim2.new(0, 120 * self.scale, 0, 40 * self.scale)
    createGroupButton.Position = UDim2.new(0.5, -60 * self.scale, 0, 70 * self.scale)
    createGroupButton.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
    createGroupButton.BorderSizePixel = 0
    createGroupButton.Text = "Create Group"
    createGroupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createGroupButton.TextScaled = true
    createGroupButton.Font = Enum.Font.GothamBold
    createGroupButton.ZIndex = 8
    createGroupButton.Parent = self.groupChatScreen
    
    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 20 * self.scale)
    createCorner.Parent = createGroupButton
    
    createGroupButton.MouseButton1Click:Connect(function()
        self:createGroup()
    end)
end

-- Setup Event Handlers
function PrivateChatClient:setupEventHandlers()
    -- Chat toggle
    ChatToggleEvent.OnClientEvent:Connect(function(isOpen)
        self.isChatOpen = isOpen
        self:updateToggleStatus()
    end)
    
    -- Private chat events
    PrivateChatEvent.OnClientEvent:Connect(function(action, ...)
        if action == "private_conversations" then
            self:loadPrivateConversations(...)
        elseif action == "new_private_message" then
            self:showNewPrivateMessage(...)
        elseif action == "private_chat_started" then
            self:showPrivateChatStarted(...)
        end
    end)
    
    -- Group chat events
    GroupChatEvent.OnClientEvent:Connect(function(action, ...)
        if action == "group_created" then
            self:showGroupCreated(...)
        elseif action == "new_group_message" then
            self:showNewGroupMessage(...)
        elseif action == "group_invite" then
            self:showGroupInvite(...)
        end
    end)
    
    -- Chat data events
    ChatDataEvent.OnClientEvent:Connect(function(action, ...)
        if action == "online_players" then
            self:loadOnlinePlayers(...)
        end
    end)
    
    -- Notifications
    NotificationEvent.OnClientEvent:Connect(function(message, type)
        self:showNotification(message, type)
    end)
end

-- Setup Controls
function PrivateChatClient:setupControls()
    -- Keyboard controls
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.C then
            self:toggleChat()
        elseif input.KeyCode == Enum.KeyCode.Escape and self.isChatOpen then
            self:toggleChat()
        end
    end)
    
    -- Touch controls for mobile
    if UserInputService.TouchEnabled then
        local lastTapTime = 0
        UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
            if gameProcessed then return end
            
            local currentTime = tick()
            if currentTime - lastTapTime < 0.5 then
                self:toggleChat()
            end
            lastTapTime = currentTime
        end)
    end
end

-- Toggle Chat
function PrivateChatClient:toggleChat()
    ChatToggleEvent:FireServer()
    
    self.isChatOpen = not self.isChatOpen
    
    if self.isChatOpen then
        self.chatFrame.Visible = true
        TweenService:Create(self.chatFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), 
            {Position = UDim2.new(1, -420 * self.scale, 0.5, -350 * self.scale)}):Play()
    else
        TweenService:Create(self.chatFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), 
            {Position = UDim2.new(1.5, 0, 0.5, -350 * self.scale)}):Play()
        wait(0.3)
        self.chatFrame.Visible = false
    end
    
    self:updateToggleStatus()
end

-- Update Toggle Status
function PrivateChatClient:updateToggleStatus()
    if self.statusDot and self.statusText then
        if self.isChatOpen then
            self.statusDot.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
            self.statusText.Text = "CHAT OPEN"
            self.statusText.TextColor3 = Color3.fromRGB(52, 199, 89)
        else
            self.statusDot.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
            self.statusText.Text = "CHAT CLOSED"
            self.statusText.TextColor3 = Color3.fromRGB(255, 59, 48)
        end
    end
end

-- Open App
function PrivateChatClient:openApp(appType)
    self.homeScreen.Visible = false
    self.privateChatScreen.Visible = false
    self.groupChatScreen.Visible = false
    
    if appType == "private" then
        self.privateChatScreen.Visible = true
        self.currentChat = "private"
    elseif appType == "groups" then
        self.groupChatScreen.Visible = true
        self.currentChat = "groups"
    elseif appType == "online" then
        self.privateChatScreen.Visible = true
        self.currentChat = "online"
    end
end

-- Go Home
function PrivateChatClient:goHome()
    self.homeScreen.Visible = true
    self.privateChatScreen.Visible = false
    self.groupChatScreen.Visible = false
    self.currentChat = "home"
end

-- Load Online Players
function PrivateChatClient:loadOnlinePlayers(players)
    -- Clear existing players
    for _, child in pairs(self.onlinePlayersList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add online players
    for _, playerData in ipairs(players) do
        self:createPlayerButton(playerData)
    end
end

-- Create Player Button
function PrivateChatClient:createPlayerButton(playerData)
    local playerButton = Instance.new("TextButton")
    playerButton.Size = UDim2.new(1, -20 * self.scale, 0, 60 * self.scale)
    playerButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    playerButton.BorderSizePixel = 0
    playerButton.Text = ""
    playerButton.ZIndex = 8
    playerButton.Parent = self.onlinePlayersList
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10 * self.scale)
    buttonCorner.Parent = playerButton
    
    -- Player avatar
    local avatar = Instance.new("TextLabel")
    avatar.Size = UDim2.new(0, 40 * self.scale, 0, 40 * self.scale)
    avatar.Position = UDim2.new(0, 10 * self.scale, 0.5, -20 * self.scale)
    avatar.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
    avatar.BorderSizePixel = 0
    avatar.Text = "👤"
    avatar.TextColor3 = Color3.fromRGB(255, 255, 255)
    avatar.TextScaled = true
    avatar.Font = Enum.Font.GothamBold
    avatar.ZIndex = 9
    avatar.Parent = playerButton
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    
    -- Player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60 * self.scale, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 60 * self.scale, 0, 5 * self.scale)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerData.name
    nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 9
    nameLabel.Parent = playerButton
    
    -- Player status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60 * self.scale, 0.5, 0)
    statusLabel.Position = UDim2.new(0, 60 * self.scale, 0.5, -5 * self.scale)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = playerData.status
    statusLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 9
    statusLabel.Parent = playerButton
    
    -- Click to start chat
    playerButton.MouseButton1Click:Connect(function()
        self:startPrivateChat(playerData.name)
    end)
end

-- Start Private Chat
function PrivateChatClient:startPrivateChat(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer then
        PrivateChatEvent:FireServer("start_chat", targetPlayer)
        self:showNotification("Started chat with " .. playerName .. "! 💬", "success")
    end
end

-- Create Group
function PrivateChatClient:createGroup()
    local groupName = "My Group " .. math.random(100, 999)
    GroupChatEvent:FireServer("create_group", nil, groupName)
end

-- Load Private Conversations
function PrivateChatClient:loadPrivateConversations(conversations)
    print("💬 Loaded " .. (conversations and #conversations or 0) .. " private conversations")
end

-- Show New Private Message
function PrivateChatClient:showNewPrivateMessage(senderName, message, messageId)
    print("💬 New private message from " .. senderName .. ": " .. message)
end

-- Show Private Chat Started
function PrivateChatClient:showPrivateChatStarted(targetName)
    print("💬 Started private chat with " .. targetName)
end

-- Show Group Created
function PrivateChatClient:showGroupCreated(groupId, groupName)
    print("👥 Group created: " .. groupName)
end

-- Show New Group Message
function PrivateChatClient:showNewGroupMessage(groupId, senderName, message, messageId)
    print("👥 New group message from " .. senderName .. ": " .. message)
end

-- Show Group Invite
function PrivateChatClient:showGroupInvite(groupId, groupName, inviterName)
    print("👥 Invited to group '" .. groupName .. "' by " .. inviterName)
end

-- Show Notification
function PrivateChatClient:showNotification(message, type)
    print("🔔 " .. (type or "info"):upper() .. ": " .. message)
end

-- Initialize Client
local privateChatClient = PrivateChatClient.new()

print("💬 PRIVATE CHAT SYSTEM CLIENT LOADED!")
print("🌟 Client Features:")
print("  💬 Private Chat Interface")
print("  👥 Group Chat Interface")
print("  👤 Online Players List")
print("  📱 Auto-scale for all devices")
print("  🎮 Multi-platform controls")
print("  🎨 Modern UI Design")
print("")
print("🎮 CONTROLS:")
print("  💬 Click the blue chat button (right side)")
print("  💻 Press 'C' or 'ESC' to toggle")
print("  📱 Double tap (mobile)")
print("  🎮 Gamepad support (console)")
print("")
print("📱 DEVICE DETECTED: " .. privateChatClient.deviceType:upper())
print("📏 SCALE FACTOR: " .. privateChatClient.scale)
print("✅ Private Chat Client ready!")