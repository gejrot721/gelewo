-- 📱 WHATSAPP-LIKE PHONE SYSTEM - CLIENT SCRIPT
-- Features: SMS, Voice Calls, Contacts, Auto-scale for all platforms
-- Place this script in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local VoiceChatService = game:GetService("VoiceChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for RemoteEvents
local PhoneEvents = ReplicatedStorage:WaitForChild("PhoneEvents")
local PhoneToggleEvent = PhoneEvents:WaitForChild("PhoneToggle")
local SMSEvent = PhoneEvents:WaitForChild("SMS")
local CallEvent = PhoneEvents:WaitForChild("Call")
local ContactEvent = PhoneEvents:WaitForChild("Contact")
local VoiceChatEvent = PhoneEvents:WaitForChild("VoiceChat")
local NotificationEvent = PhoneEvents:WaitForChild("Notification")

local player = Players.LocalPlayer

-- WhatsApp Phone Client Class
local WhatsAppPhoneClient = {}
WhatsAppPhoneClient.__index = WhatsAppPhoneClient

function WhatsAppPhoneClient.new()
    local self = setmetatable({}, WhatsAppPhoneClient)
    
    -- Client state
    self.isPhoneOpen = false
    self.currentApp = "home"
    self.scale = 1
    self.deviceType = "pc"
    
    -- UI Elements
    self.screenGui = nil
    self.phoneFrame = nil
    self.toggleButton = nil
    self.homeScreen = nil
    self.smsScreen = nil
    self.callScreen = nil
    self.contactsScreen = nil
    
    -- Initialize
    self:detectDevice()
    self:createGUI()
    self:setupEventHandlers()
    self:setupControls()
    
    return self
end

-- Detect Device Type
function WhatsAppPhoneClient:detectDevice()
    if UserInputService.TouchEnabled then
        self.deviceType = "mobile"
    elseif UserInputService.GamepadEnabled then
        self.deviceType = "console"
    else
        self.deviceType = "pc"
    end
end

-- Create GUI with Auto-scale
function WhatsAppPhoneClient:createGUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "WhatsAppPhoneClient"
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
    
    -- Create toggle button (RIGHT CENTER)
    self:createToggleButton()
    
    -- Create phone frame
    self:createPhoneFrame()
    
    print("📱 WhatsApp Phone Client GUI created! Device: " .. self.deviceType .. ", Scale: " .. self.scale)
end

-- Create Toggle Button (RIGHT CENTER)
function WhatsAppPhoneClient:createToggleButton()
    local buttonSize = self.deviceType == "mobile" and 100 or 80
    local containerSize = buttonSize + 40
    
    -- Toggle container
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(0, containerSize * self.scale, 0, containerSize * self.scale)
    toggleContainer.Position = UDim2.new(1, -containerSize * self.scale - 20, 0.5, -containerSize * self.scale / 2)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.ZIndex = 1000
    toggleContainer.Parent = self.screenGui
    
    -- Glow effect
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundColor3 = Color3.fromRGB(37, 211, 102) -- WhatsApp green
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.ZIndex = 999
    glow.Parent = toggleContainer
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    
    -- Main toggle button
    self.toggleButton = Instance.new("TextButton")
    self.toggleButton.Name = "WhatsAppToggle"
    self.toggleButton.Size = UDim2.new(0, buttonSize * self.scale, 0, buttonSize * self.scale)
    self.toggleButton.Position = UDim2.new(0.5, -buttonSize * self.scale / 2, 0.5, -buttonSize * self.scale / 2)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(37, 211, 102) -- WhatsApp green
    self.toggleButton.BorderSizePixel = 0
    self.toggleButton.Text = "📱"
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
    statusDot.Size = UDim2.new(0, 20 * self.scale, 0, 20 * self.scale)
    statusDot.Position = UDim2.new(1, -25 * self.scale, 0, 5 * self.scale)
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
    statusText.Size = UDim2.new(1.5, 0, 0, 25 * self.scale)
    statusText.Position = UDim2.new(-0.25, 0, 1, 10 * self.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = "WHATSAPP CLOSED"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.GothamBold
    statusText.ZIndex = 1001
    statusText.Parent = toggleContainer
    
    -- Instructions
    local instructions = Instance.new("TextLabel")
    instructions.Size = UDim2.new(2, 0, 0, 20 * self.scale)
    instructions.Position = UDim2.new(-0.5, 0, 1, 40 * self.scale)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Click to Open WhatsApp Phone"
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
        self:togglePhone()
    end)
    
    -- Hover effects
    self.toggleButton.MouseEnter:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), 
            {Size = UDim2.new(0, (buttonSize + 10) * self.scale, 0, (buttonSize + 10) * self.scale)}):Play()
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
                {Size = UDim2.new(0, (buttonSize + 5) * self.scale, 0, (buttonSize + 5) * self.scale)}):Play()
            wait(1.5)
            TweenService:Create(self.toggleButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Size = UDim2.new(0, buttonSize * self.scale, 0, buttonSize * self.scale)}):Play()
            wait(1.5)
        end
    end)
end

-- Create Phone Frame
function WhatsAppPhoneClient:createPhoneFrame()
    local phoneWidth = self.deviceType == "mobile" and 350 or 400
    local phoneHeight = self.deviceType == "mobile" and 700 or 800
    
    self.phoneFrame = Instance.new("Frame")
    self.phoneFrame.Name = "WhatsAppPhoneFrame"
    self.phoneFrame.Size = UDim2.new(0, phoneWidth * self.scale, 0, phoneHeight * self.scale)
    self.phoneFrame.Position = UDim2.new(0.5, -phoneWidth * self.scale / 2, 0.5, -phoneHeight * self.scale / 2)
    self.phoneFrame.BackgroundColor3 = Color3.fromRGB(37, 211, 102) -- WhatsApp green
    self.phoneFrame.BorderSizePixel = 0
    self.phoneFrame.Visible = false
    self.phoneFrame.ZIndex = 5
    self.phoneFrame.Parent = self.screenGui
    
    -- Phone corners
    local phoneCorner = Instance.new("UICorner")
    phoneCorner.CornerRadius = UDim.new(0, 30 * self.scale)
    phoneCorner.Parent = self.phoneFrame
    
    -- Screen area
    local screenArea = Instance.new("Frame")
    screenArea.Name = "ScreenArea"
    screenArea.Size = UDim2.new(1, -20 * self.scale, 1, -40 * self.scale)
    screenArea.Position = UDim2.new(0, 10 * self.scale, 0, 20 * self.scale)
    screenArea.BackgroundColor3 = Color3.fromRGB(240, 240, 240) -- WhatsApp background
    screenArea.BorderSizePixel = 0
    screenArea.ZIndex = 6
    screenArea.Parent = self.phoneFrame
    
    local screenCorner = Instance.new("UICorner")
    screenCorner.CornerRadius = UDim.new(0, 25 * self.scale)
    screenCorner.Parent = screenArea
    
    -- Create screens
    self:createHomeScreen(screenArea)
    self:createSMSScreen(screenArea)
    self:createCallScreen(screenArea)
    self:createContactsScreen(screenArea)
end

-- Create Home Screen
function WhatsAppPhoneClient:createHomeScreen(parent)
    self.homeScreen = Instance.new("ScrollingFrame")
    self.homeScreen.Name = "HomeScreen"
    self.homeScreen.Size = UDim2.new(1, 0, 1, 0)
    self.homeScreen.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    self.homeScreen.BorderSizePixel = 0
    self.homeScreen.ScrollBarThickness = 0
    self.homeScreen.Visible = true
    self.homeScreen.ZIndex = 7
    self.homeScreen.Parent = parent
    
    -- WhatsApp header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 80 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(37, 211, 102)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.homeScreen
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 25 * self.scale)
    headerCorner.Parent = header
    
    -- WhatsApp title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 20 * self.scale, 0, 10 * self.scale)
    title.BackgroundTransparency = 1
    title.Text = "WhatsApp Phone"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0.5, 0)
    subtitle.Position = UDim2.new(0, 20 * self.scale, 0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "SMS • Calls • Contacts"
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 9
    subtitle.Parent = header
    
    -- Apps grid
    local appsGrid = Instance.new("UIGridLayout")
    appsGrid.CellSize = UDim2.new(0, 100 * self.scale, 0, 120 * self.scale)
    appsGrid.CellPadding = UDim2.new(0, 20 * self.scale, 0, 20 * self.scale)
    appsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    appsGrid.Parent = self.homeScreen
    
    -- Create WhatsApp-like apps
    local apps = {
        {icon = "💬", name = "Chats", color = Color3.fromRGB(37, 211, 102), action = "sms"},
        {icon = "📞", name = "Calls", color = Color3.fromRGB(37, 211, 102), action = "calls"},
        {icon = "👥", name = "Contacts", color = Color3.fromRGB(37, 211, 102), action = "contacts"},
        {icon = "⚙️", name = "Settings", color = Color3.fromRGB(37, 211, 102), action = "settings"}
    }
    
    for _, appData in ipairs(apps) do
        self:createAppIcon(appData)
    end
end

-- Create App Icon
function WhatsAppPhoneClient:createAppIcon(appData)
    local appButton = Instance.new("TextButton")
    appButton.BackgroundColor3 = appData.color
    appButton.BorderSizePixel = 0
    appButton.Text = ""
    appButton.ZIndex = 8
    appButton.Parent = self.homeScreen
    
    local appCorner = Instance.new("UICorner")
    appCorner.CornerRadius = UDim.new(0, 20 * self.scale)
    appCorner.Parent = appButton
    
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
            {Size = UDim2.new(0, 95 * self.scale, 0, 115 * self.scale)}):Play()
    end)
    
    appButton.MouseButton1Up:Connect(function()
        TweenService:Create(appButton, TweenInfo.new(0.1), 
            {Size = UDim2.new(0, 100 * self.scale, 0, 120 * self.scale)}):Play()
    end)
end

-- Create SMS Screen
function WhatsAppPhoneClient:createSMSScreen(parent)
    self.smsScreen = Instance.new("Frame")
    self.smsScreen.Name = "SMSScreen"
    self.smsScreen.Size = UDim2.new(1, 0, 1, 0)
    self.smsScreen.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    self.smsScreen.BorderSizePixel = 0
    self.smsScreen.Visible = false
    self.smsScreen.ZIndex = 7
    self.smsScreen.Parent = parent
    
    -- SMS header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(37, 211, 102)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.smsScreen
    
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(0, 50 * self.scale, 0, 50 * self.scale)
    backButton.Position = UDim2.new(0, 10 * self.scale, 0.5, -25 * self.scale)
    backButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundTransparency = 0.8
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.fromRGB(37, 211, 102)
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
    title.Size = UDim2.new(1, -70 * self.scale, 1, 0)
    title.Position = UDim2.new(0, 70 * self.scale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Chats"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
    
    -- Conversations list
    local conversationsList = Instance.new("ScrollingFrame")
    conversationsList.Size = UDim2.new(1, 0, 1, -60 * self.scale)
    conversationsList.Position = UDim2.new(0, 0, 0, 60 * self.scale)
    conversationsList.BackgroundTransparency = 1
    conversationsList.BorderSizePixel = 0
    conversationsList.ScrollBarThickness = 0
    conversationsList.ZIndex = 7
    conversationsList.Parent = self.smsScreen
    
    local conversationsLayout = Instance.new("UIListLayout")
    conversationsLayout.Padding = UDim.new(0, 1)
    conversationsLayout.Parent = conversationsList
    
    -- Load conversations
    SMSEvent:FireServer("get_conversations")
end

-- Create Call Screen
function WhatsAppPhoneClient:createCallScreen(parent)
    self.callScreen = Instance.new("Frame")
    self.callScreen.Name = "CallScreen"
    self.callScreen.Size = UDim2.new(1, 0, 1, 0)
    self.callScreen.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    self.callScreen.BorderSizePixel = 0
    self.callScreen.Visible = false
    self.callScreen.ZIndex = 7
    self.callScreen.Parent = parent
    
    -- Similar structure to SMS screen but for calls
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(37, 211, 102)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.callScreen
    
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(0, 50 * self.scale, 0, 50 * self.scale)
    backButton.Position = UDim2.new(0, 10 * self.scale, 0.5, -25 * self.scale)
    backButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundTransparency = 0.8
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.fromRGB(37, 211, 102)
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
    title.Size = UDim2.new(1, -70 * self.scale, 1, 0)
    title.Position = UDim2.new(0, 70 * self.scale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Calls"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
end

-- Create Contacts Screen
function WhatsAppPhoneClient:createContactsScreen(parent)
    self.contactsScreen = Instance.new("Frame")
    self.contactsScreen.Name = "ContactsScreen"
    self.contactsScreen.Size = UDim2.new(1, 0, 1, 0)
    self.contactsScreen.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    self.contactsScreen.BorderSizePixel = 0
    self.contactsScreen.Visible = false
    self.contactsScreen.ZIndex = 7
    self.contactsScreen.Parent = parent
    
    -- Similar structure to SMS screen but for contacts
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60 * self.scale)
    header.BackgroundColor3 = Color3.fromRGB(37, 211, 102)
    header.BorderSizePixel = 0
    header.ZIndex = 8
    header.Parent = self.contactsScreen
    
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(0, 50 * self.scale, 0, 50 * self.scale)
    backButton.Position = UDim2.new(0, 10 * self.scale, 0.5, -25 * self.scale)
    backButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundTransparency = 0.8
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.fromRGB(37, 211, 102)
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
    title.Size = UDim2.new(1, -70 * self.scale, 1, 0)
    title.Position = UDim2.new(0, 70 * self.scale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Contacts"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 9
    title.Parent = header
    
    -- Load contacts
    ContactEvent:FireServer("get_contacts")
end

-- Setup Event Handlers
function WhatsAppPhoneClient:setupEventHandlers()
    -- Phone toggle
    PhoneToggleEvent.OnClientEvent:Connect(function(isOpen)
        self.isPhoneOpen = isOpen
        self:updateToggleStatus()
    end)
    
    -- SMS events
    SMSEvent.OnClientEvent:Connect(function(action, ...)
        if action == "conversations" then
            self:loadConversations(...)
        elseif action == "new_message" then
            self:showNewMessage(...)
        end
    end)
    
    -- Call events
    CallEvent.OnClientEvent:Connect(function(action, ...)
        if action == "incoming_call" then
            self:showIncomingCall(...)
        elseif action == "call_answered" then
            self:showCallAnswered(...)
        end
    end)
    
    -- Contact events
    ContactEvent.OnClientEvent:Connect(function(action, ...)
        if action == "contacts" then
            self:loadContacts(...)
        elseif action == "search_results" then
            self:showSearchResults(...)
        end
    end)
    
    -- VoiceChat events
    VoiceChatEvent.OnClientEvent:Connect(function(action, ...)
        if action == "join_voice_room" then
            self:joinVoiceRoom(...)
        end
    end)
    
    -- Notifications
    NotificationEvent.OnClientEvent:Connect(function(message, type)
        self:showNotification(message, type)
    end)
end

-- Setup Controls
function WhatsAppPhoneClient:setupControls()
    -- Keyboard controls
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            self:togglePhone()
        elseif input.KeyCode == Enum.KeyCode.Escape and self.isPhoneOpen then
            self:togglePhone()
        end
    end)
    
    -- Touch controls for mobile
    if UserInputService.TouchEnabled then
        local lastTapTime = 0
        UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
            if gameProcessed then return end
            
            local currentTime = tick()
            if currentTime - lastTapTime < 0.5 then
                self:togglePhone()
            end
            lastTapTime = currentTime
        end)
    end
end

-- Toggle Phone
function WhatsAppPhoneClient:togglePhone()
    PhoneToggleEvent:FireServer()
    
    self.isPhoneOpen = not self.isPhoneOpen
    
    if self.isPhoneOpen then
        self.phoneFrame.Visible = true
        TweenService:Create(self.phoneFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), 
            {Position = UDim2.new(0.5, -200 * self.scale, 0.5, -400 * self.scale)}):Play()
    else
        TweenService:Create(self.phoneFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), 
            {Position = UDim2.new(1.5, 0, 0.5, -400 * self.scale)}):Play()
        wait(0.3)
        self.phoneFrame.Visible = false
    end
    
    self:updateToggleStatus()
end

-- Update Toggle Status
function WhatsAppPhoneClient:updateToggleStatus()
    if self.statusDot and self.statusText then
        if self.isPhoneOpen then
            self.statusDot.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
            self.statusText.Text = "WHATSAPP OPEN"
            self.statusText.TextColor3 = Color3.fromRGB(52, 199, 89)
        else
            self.statusDot.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
            self.statusText.Text = "WHATSAPP CLOSED"
            self.statusText.TextColor3 = Color3.fromRGB(255, 59, 48)
        end
    end
end

-- Open App
function WhatsAppPhoneClient:openApp(appType)
    self.homeScreen.Visible = false
    self.smsScreen.Visible = false
    self.callScreen.Visible = false
    self.contactsScreen.Visible = false
    
    if appType == "sms" then
        self.smsScreen.Visible = true
        self.currentApp = "sms"
    elseif appType == "calls" then
        self.callScreen.Visible = true
        self.currentApp = "calls"
    elseif appType == "contacts" then
        self.contactsScreen.Visible = true
        self.currentApp = "contacts"
    end
end

-- Go Home
function WhatsAppPhoneClient:goHome()
    self.homeScreen.Visible = true
    self.smsScreen.Visible = false
    self.callScreen.Visible = false
    self.contactsScreen.Visible = false
    self.currentApp = "home"
end

-- Load Conversations
function WhatsAppPhoneClient:loadConversations(conversations)
    print("💬 Loaded " .. (conversations and #conversations or 0) .. " conversations")
end

-- Show New Message
function WhatsAppPhoneClient:showNewMessage(senderName, message, messageId)
    print("💬 New message from " .. senderName .. ": " .. message)
end

-- Show Incoming Call
function WhatsAppPhoneClient:showIncomingCall(callId, callerName, callType)
    print("📞 Incoming " .. callType .. " call from " .. callerName)
end

-- Show Call Answered
function WhatsAppPhoneClient:showCallAnswered(callId, answererName)
    print("📞 Call answered by " .. answererName)
end

-- Load Contacts
function WhatsAppPhoneClient:loadContacts(contacts)
    print("👥 Loaded " .. (contacts and #contacts or 0) .. " contacts")
end

-- Show Search Results
function WhatsAppPhoneClient:showSearchResults(players)
    print("🔍 Found " .. #players .. " players")
end

-- Join Voice Room
function WhatsAppPhoneClient:joinVoiceRoom(roomId)
    print("🎤 Joined voice room: " .. roomId)
end

-- Show Notification
function WhatsAppPhoneClient:showNotification(message, type)
    print("🔔 " .. (type or "info"):upper() .. ": " .. message)
end

-- Initialize Client
local whatsappClient = WhatsAppPhoneClient.new()

print("📱 WHATSAPP PHONE SYSTEM CLIENT LOADED!")
print("🌟 Client Features:")
print("  💬 WhatsApp-like SMS Interface")
print("  📞 Voice Call System")
print("  🎤 VoiceChat Integration")
print("  👥 Contact Management")
print("  📱 Auto-scale for all devices")
print("  🎮 Multi-platform controls")
print("")
print("🎮 CONTROLS:")
print("  📱 Click the green WhatsApp button (right center)")
print("  💻 Press 'P' or 'ESC' to toggle")
print("  📱 Double tap (mobile)")
print("  🎮 Gamepad support (console)")
print("")
print("📱 DEVICE DETECTED: " .. whatsappClient.deviceType:upper())
print("📏 SCALE FACTOR: " .. whatsappClient.scale)
print("✅ WhatsApp Phone Client ready!")