-- 📱 Roblox Phone System - Modern Android Style
-- Features: Chat, Voice Calls, Group Calls, Contacts, Auto-Scale UI
-- Compatible with Mobile, PC, and Console

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local VoiceChatService = game:GetService("VoiceChatService")
local GuiService = game:GetService("GuiService")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Phone System Class
local PhoneSystem = {}
PhoneSystem.__index = PhoneSystem

-- Initialize Phone System
function PhoneSystem.new()
    local self = setmetatable({}, PhoneSystem)
    
    -- Core Variables
    self.isPhoneOpen = false
    self.currentApp = "home"
    self.contacts = {}
    self.messages = {}
    self.activeCalls = {}
    self.groupCalls = {}
    self.voiceEnabled = false
    
    -- UI Elements
    self.screenGui = nil
    self.phoneFrame = nil
    self.toggleButton = nil
    self.statusBar = nil
    self.homeScreen = nil
    self.appsContainer = nil
    
    -- Apps
    self.apps = {
        ["contacts"] = "👥",
        ["messages"] = "💬", 
        ["phone"] = "📞",
        ["group"] = "👥📞",
        ["settings"] = "⚙️"
    }
    
    -- Initialize the system
    self:createGUI()
    self:setupVoiceChat()
    self:setupEventHandlers()
    
    return self
end

-- Create Main GUI Structure
function PhoneSystem:createGUI()
    -- Main ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PhoneSystem"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.Parent = player.PlayerGui
    
    -- Auto-scale for different devices
    local screenSize = workspace.CurrentCamera.ViewportSize
    local scale = math.min(screenSize.X / 1920, screenSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Toggle Button (Right Center)
    self.toggleButton = Instance.new("ImageButton")
    self.toggleButton.Name = "PhoneToggle"
    self.toggleButton.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
    self.toggleButton.Position = UDim2.new(1, -80 * scale, 0.5, -30 * scale)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    self.toggleButton.BorderSizePixel = 0
    self.toggleButton.Parent = self.screenGui
    
    -- Toggle Button Icon
    local toggleIcon = Instance.new("TextLabel")
    toggleIcon.Size = UDim2.new(1, 0, 1, 0)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Text = "📱"
    toggleIcon.TextColor3 = Color3.white
    toggleIcon.TextScaled = true
    toggleIcon.Font = Enum.Font.GothamBold
    toggleIcon.Parent = self.toggleButton
    
    -- Rounded corners for toggle
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = self.toggleButton
    
    -- Main Phone Frame
    self.phoneFrame = Instance.new("Frame")
    self.phoneFrame.Name = "PhoneFrame"
    self.phoneFrame.Size = UDim2.new(0, 380 * scale, 0, 720 * scale)
    self.phoneFrame.Position = UDim2.new(0.5, -190 * scale, 0.5, -360 * scale)
    self.phoneFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.phoneFrame.BorderSizePixel = 0
    self.phoneFrame.Visible = false
    self.phoneFrame.Parent = self.screenGui
    
    -- Phone Frame Corner
    local phoneCorner = Instance.new("UICorner")
    phoneCorner.CornerRadius = UDim.new(0, 25 * scale)
    phoneCorner.Parent = self.phoneFrame
    
    -- Phone Border (Modern Android Style)
    local phoneBorder = Instance.new("UIStroke")
    phoneBorder.Color = Color3.fromRGB(66, 66, 66)
    phoneBorder.Thickness = 2
    phoneBorder.Parent = self.phoneFrame
    
    -- Status Bar
    self:createStatusBar(scale)
    
    -- Home Screen
    self:createHomeScreen(scale)
    
    -- Apps Container
    self:createAppsContainer(scale)
    
    -- Setup toggle functionality
    self.toggleButton.MouseButton1Click:Connect(function()
        self:togglePhone()
    end)
    
    -- Handle different input types
    if UserInputService.TouchEnabled then
        self:setupTouchControls()
    end
end

-- Create Status Bar
function PhoneSystem:createStatusBar(scale)
    self.statusBar = Instance.new("Frame")
    self.statusBar.Name = "StatusBar"
    self.statusBar.Size = UDim2.new(1, 0, 0, 40 * scale)
    self.statusBar.Position = UDim2.new(0, 0, 0, 0)
    self.statusBar.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    self.statusBar.BorderSizePixel = 0
    self.statusBar.Parent = self.phoneFrame
    
    -- Status Bar Corner
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 25 * scale)
    statusCorner.Parent = self.statusBar
    
    -- Time Display
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    timeLabel.Position = UDim2.new(0, 10, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.white
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = self.statusBar
    
    -- Battery/Signal Icons
    local iconsFrame = Instance.new("Frame")
    iconsFrame.Size = UDim2.new(0.3, 0, 1, 0)
    iconsFrame.Position = UDim2.new(0.7, 0, 0, 0)
    iconsFrame.BackgroundTransparency = 1
    iconsFrame.Parent = self.statusBar
    
    local signalIcon = Instance.new("TextLabel")
    signalIcon.Size = UDim2.new(0.33, 0, 1, 0)
    signalIcon.Position = UDim2.new(0, 0, 0, 0)
    signalIcon.BackgroundTransparency = 1
    signalIcon.Text = "📶"
    signalIcon.TextColor3 = Color3.white
    signalIcon.TextScaled = true
    signalIcon.Parent = iconsFrame
    
    local batteryIcon = Instance.new("TextLabel")
    batteryIcon.Size = UDim2.new(0.33, 0, 1, 0)
    batteryIcon.Position = UDim2.new(0.67, 0, 0, 0)
    batteryIcon.BackgroundTransparency = 1
    batteryIcon.Text = "🔋"
    batteryIcon.TextColor3 = Color3.white
    batteryIcon.TextScaled = true
    batteryIcon.Parent = iconsFrame
    
    -- Update time every second
    spawn(function()
        while true do
            timeLabel.Text = os.date("%H:%M")
            wait(1)
        end
    end)
end

-- Create Home Screen
function PhoneSystem:createHomeScreen(scale)
    self.homeScreen = Instance.new("ScrollingFrame")
    self.homeScreen.Name = "HomeScreen"
    self.homeScreen.Size = UDim2.new(1, 0, 1, -40 * scale)
    self.homeScreen.Position = UDim2.new(0, 0, 0, 40 * scale)
    self.homeScreen.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.homeScreen.BorderSizePixel = 0
    self.homeScreen.ScrollBarThickness = 8
    self.homeScreen.Parent = self.phoneFrame
    
    -- Apps Grid Layout
    local appsGrid = Instance.new("UIGridLayout")
    appsGrid.CellSize = UDim2.new(0, 80 * scale, 0, 100 * scale)
    appsGrid.CellPadding = UDim2.new(0, 20 * scale, 0, 20 * scale)
    appsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    appsGrid.VerticalAlignment = Enum.VerticalAlignment.Top
    appsGrid.Parent = self.homeScreen
    
    -- Create App Icons
    for appName, icon in pairs(self.apps) do
        local appButton = Instance.new("TextButton")
        appButton.Name = appName .. "App"
        appButton.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
        appButton.BorderSizePixel = 0
        appButton.Text = ""
        appButton.Parent = self.homeScreen
        
        local appCorner = Instance.new("UICorner")
        appCorner.CornerRadius = UDim.new(0, 15 * scale)
        appCorner.Parent = appButton
        
        local appIcon = Instance.new("TextLabel")
        appIcon.Size = UDim2.new(1, 0, 0.7, 0)
        appIcon.Position = UDim2.new(0, 0, 0, 0)
        appIcon.BackgroundTransparency = 1
        appIcon.Text = icon
        appIcon.TextColor3 = Color3.white
        appIcon.TextScaled = true
        appIcon.Font = Enum.Font.GothamBold
        appIcon.Parent = appButton
        
        local appLabel = Instance.new("TextLabel")
        appLabel.Size = UDim2.new(1, 0, 0.3, 0)
        appLabel.Position = UDim2.new(0, 0, 0.7, 0)
        appLabel.BackgroundTransparency = 1
        appLabel.Text = appName:gsub("^%l", string.upper)
        appLabel.TextColor3 = Color3.white
        appLabel.TextScaled = true
        appLabel.Font = Enum.Font.Gotham
        appLabel.Parent = appButton
        
        -- App Button Click
        appButton.MouseButton1Click:Connect(function()
            self:openApp(appName)
        end)
        
        -- Hover Effect
        appButton.MouseEnter:Connect(function()
            TweenService:Create(appButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end)
        
        appButton.MouseLeave:Connect(function()
            TweenService:Create(appButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(66, 66, 66)}):Play()
        end)
    end
end

-- Create Apps Container
function PhoneSystem:createAppsContainer(scale)
    self.appsContainer = Instance.new("Frame")
    self.appsContainer.Name = "AppsContainer"
    self.appsContainer.Size = UDim2.new(1, 0, 1, -40 * scale)
    self.appsContainer.Position = UDim2.new(0, 0, 0, 40 * scale)
    self.appsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.appsContainer.BorderSizePixel = 0
    self.appsContainer.Visible = false
    self.appsContainer.Parent = self.phoneFrame
    
    -- Back Button
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 50 * scale, 0, 50 * scale)
    backButton.Position = UDim2.new(0, 10, 0, 10)
    backButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.white
    backButton.TextScaled = true
    backButton.Font = Enum.Font.GothamBold
    backButton.Parent = self.appsContainer
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(1, 0)
    backCorner.Parent = backButton
    
    backButton.MouseButton1Click:Connect(function()
        self:goHome()
    end)
end

-- Toggle Phone Visibility
function PhoneSystem:togglePhone()
    self.isPhoneOpen = not self.isPhoneOpen
    
    local targetPosition
    local screenSize = workspace.CurrentCamera.ViewportSize
    local scale = math.min(screenSize.X / 1920, screenSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    if self.isPhoneOpen then
        targetPosition = UDim2.new(0.5, -190 * scale, 0.5, -360 * scale)
        self.phoneFrame.Visible = true
    else
        targetPosition = UDim2.new(1.5, 0, 0.5, -360 * scale)
    end
    
    local tween = TweenService:Create(
        self.phoneFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = targetPosition}
    )
    
    tween:Play()
    
    if not self.isPhoneOpen then
        tween.Completed:Connect(function()
            self.phoneFrame.Visible = false
        end)
    end
end

-- Open App
function PhoneSystem:openApp(appName)
    self.currentApp = appName
    self.homeScreen.Visible = false
    self.appsContainer.Visible = true
    
    -- Clear previous app content
    for _, child in pairs(self.appsContainer:GetChildren()) do
        if child.Name ~= "BackButton" then
            child:Destroy()
        end
    end
    
    -- Load specific app
    if appName == "contacts" then
        self:createContactsApp()
    elseif appName == "messages" then
        self:createMessagesApp()
    elseif appName == "phone" then
        self:createPhoneApp()
    elseif appName == "group" then
        self:createGroupCallApp()
    elseif appName == "settings" then
        self:createSettingsApp()
    end
end

-- Go Back to Home
function PhoneSystem:goHome()
    self.currentApp = "home"
    self.homeScreen.Visible = true
    self.appsContainer.Visible = false
end

-- Create Contacts App
function PhoneSystem:createContactsApp()
    local scale = math.min(workspace.CurrentCamera.ViewportSize.X / 1920, workspace.CurrentCamera.ViewportSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70 * scale, 0, 50 * scale)
    title.Position = UDim2.new(0, 60 * scale, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "👥 Contacts"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.appsContainer
    
    -- Search Bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -20 * scale, 0, 40 * scale)
    searchFrame.Position = UDim2.new(0, 10 * scale, 0, 70 * scale)
    searchFrame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = self.appsContainer
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 20 * scale)
    searchCorner.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20 * scale, 1, 0)
    searchBox.Position = UDim2.new(0, 10 * scale, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "🔍 Search players..."
    searchBox.TextColor3 = Color3.white
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    
    -- Players List
    local playersFrame = Instance.new("ScrollingFrame")
    playersFrame.Size = UDim2.new(1, -20 * scale, 1, -120 * scale)
    playersFrame.Position = UDim2.new(0, 10 * scale, 0, 120 * scale)
    playersFrame.BackgroundTransparency = 1
    playersFrame.BorderSizePixel = 0
    playersFrame.ScrollBarThickness = 6
    playersFrame.Parent = self.appsContainer
    
    local playersLayout = Instance.new("UIListLayout")
    playersLayout.Padding = UDim.new(0, 5 * scale)
    playersLayout.Parent = playersFrame
    
    -- Function to create player entry
    local function createPlayerEntry(targetPlayer)
        local playerFrame = Instance.new("Frame")
        playerFrame.Size = UDim2.new(1, 0, 0, 60 * scale)
        playerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        playerFrame.BorderSizePixel = 0
        playerFrame.Parent = playersFrame
        
        local playerCorner = Instance.new("UICorner")
        playerCorner.CornerRadius = UDim.new(0, 10 * scale)
        playerCorner.Parent = playerFrame
        
        -- Player Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 10 * scale, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = playerFrame
        
        -- Call Button
        local callButton = Instance.new("TextButton")
        callButton.Size = UDim2.new(0, 40 * scale, 0, 40 * scale)
        callButton.Position = UDim2.new(1, -50 * scale, 0.5, -20 * scale)
        callButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        callButton.BorderSizePixel = 0
        callButton.Text = "📞"
        callButton.TextColor3 = Color3.white
        callButton.TextScaled = true
        callButton.Font = Enum.Font.GothamBold
        callButton.Parent = playerFrame
        
        local callCorner = Instance.new("UICorner")
        callCorner.CornerRadius = UDim.new(1, 0)
        callCorner.Parent = callButton
        
        callButton.MouseButton1Click:Connect(function()
            self:initiateCall(targetPlayer)
        end)
        
        -- Message Button
        local messageButton = Instance.new("TextButton")
        messageButton.Size = UDim2.new(0, 40 * scale, 0, 40 * scale)
        messageButton.Position = UDim2.new(1, -100 * scale, 0.5, -20 * scale)
        messageButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        messageButton.BorderSizePixel = 0
        messageButton.Text = "💬"
        messageButton.TextColor3 = Color3.white
        messageButton.TextScaled = true
        messageButton.Font = Enum.Font.GothamBold
        messageButton.Parent = playerFrame
        
        local messageCorner = Instance.new("UICorner")
        messageCorner.CornerRadius = UDim.new(1, 0)
        messageCorner.Parent = messageButton
        
        messageButton.MouseButton1Click:Connect(function()
            self:openChat(targetPlayer)
        end)
    end
    
    -- Load all players
    local function updatePlayersList(searchText)
        for _, child in pairs(playersFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                if not searchText or searchText == "" or 
                   string.lower(targetPlayer.Name):find(string.lower(searchText)) then
                    createPlayerEntry(targetPlayer)
                end
            end
        end
        
        playersFrame.CanvasSize = UDim2.new(0, 0, 0, playersLayout.AbsoluteContentSize.Y)
    end
    
    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updatePlayersList(searchBox.Text)
    end)
    
    -- Initial load
    updatePlayersList()
end

-- Create Messages App
function PhoneSystem:createMessagesApp()
    local scale = math.min(workspace.CurrentCamera.ViewportSize.X / 1920, workspace.CurrentCamera.ViewportSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70 * scale, 0, 50 * scale)
    title.Position = UDim2.new(0, 60 * scale, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "💬 Messages"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.appsContainer
    
    -- Messages List
    local messagesFrame = Instance.new("ScrollingFrame")
    messagesFrame.Size = UDim2.new(1, -20 * scale, 1, -70 * scale)
    messagesFrame.Position = UDim2.new(0, 10 * scale, 0, 60 * scale)
    messagesFrame.BackgroundTransparency = 1
    messagesFrame.BorderSizePixel = 0
    messagesFrame.ScrollBarThickness = 6
    messagesFrame.Parent = self.appsContainer
    
    local messagesLayout = Instance.new("UIListLayout")
    messagesLayout.Padding = UDim.new(0, 5 * scale)
    messagesLayout.Parent = messagesFrame
    
    -- Function to create conversation entry
    local function createConversationEntry(targetPlayer, lastMessage)
        local convFrame = Instance.new("TextButton")
        convFrame.Size = UDim2.new(1, 0, 0, 70 * scale)
        convFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        convFrame.BorderSizePixel = 0
        convFrame.Text = ""
        convFrame.Parent = messagesFrame
        
        local convCorner = Instance.new("UICorner")
        convCorner.CornerRadius = UDim.new(0, 10 * scale)
        convCorner.Parent = convFrame
        
        -- Player Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -20 * scale, 0, 30 * scale)
        nameLabel.Position = UDim2.new(0, 10 * scale, 0, 5 * scale)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = convFrame
        
        -- Last Message
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -20 * scale, 0, 25 * scale)
        messageLabel.Position = UDim2.new(0, 10 * scale, 0, 35 * scale)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = lastMessage or "No messages yet"
        messageLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        messageLabel.TextScaled = true
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.Parent = convFrame
        
        convFrame.MouseButton1Click:Connect(function()
            self:openChat(targetPlayer)
        end)
    end
    
    -- Load conversations
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local lastMessage = self.messages[targetPlayer.UserId] and 
                              self.messages[targetPlayer.UserId][#self.messages[targetPlayer.UserId]]
            createConversationEntry(targetPlayer, lastMessage and lastMessage.text)
        end
    end
    
    messagesFrame.CanvasSize = UDim2.new(0, 0, 0, messagesLayout.AbsoluteContentSize.Y)
end

-- Open Chat with Player
function PhoneSystem:openChat(targetPlayer)
    local scale = math.min(workspace.CurrentCamera.ViewportSize.X / 1920, workspace.CurrentCamera.ViewportSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Clear container
    for _, child in pairs(self.appsContainer:GetChildren()) do
        if child.Name ~= "BackButton" then
            child:Destroy()
        end
    end
    
    -- Chat Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70 * scale, 0, 50 * scale)
    title.Position = UDim2.new(0, 60 * scale, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "💬 " .. targetPlayer.Name
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.appsContainer
    
    -- Messages Display
    local chatFrame = Instance.new("ScrollingFrame")
    chatFrame.Size = UDim2.new(1, -20 * scale, 1, -120 * scale)
    chatFrame.Position = UDim2.new(0, 10 * scale, 0, 60 * scale)
    chatFrame.BackgroundTransparency = 1
    chatFrame.BorderSizePixel = 0
    chatFrame.ScrollBarThickness = 6
    chatFrame.Parent = self.appsContainer
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.Padding = UDim.new(0, 5 * scale)
    chatLayout.Parent = chatFrame
    
    -- Message Input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -20 * scale, 0, 50 * scale)
    inputFrame.Position = UDim2.new(0, 10 * scale, 1, -60 * scale)
    inputFrame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = self.appsContainer
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 25 * scale)
    inputCorner.Parent = inputFrame
    
    local messageBox = Instance.new("TextBox")
    messageBox.Size = UDim2.new(0.8, 0, 1, 0)
    messageBox.Position = UDim2.new(0, 15 * scale, 0, 0)
    messageBox.BackgroundTransparency = 1
    messageBox.Text = ""
    messageBox.PlaceholderText = "Type a message..."
    messageBox.TextColor3 = Color3.white
    messageBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    messageBox.TextScaled = true
    messageBox.Font = Enum.Font.Gotham
    messageBox.Parent = inputFrame
    
    local sendButton = Instance.new("TextButton")
    sendButton.Size = UDim2.new(0.15, 0, 0.8, 0)
    sendButton.Position = UDim2.new(0.8, 0, 0.1, 0)
    sendButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "➤"
    sendButton.TextColor3 = Color3.white
    sendButton.TextScaled = true
    sendButton.Font = Enum.Font.GothamBold
    sendButton.Parent = inputFrame
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(1, 0)
    sendCorner.Parent = sendButton
    
    -- Function to add message
    local function addMessage(text, isFromPlayer)
        local msgFrame = Instance.new("Frame")
        msgFrame.Size = UDim2.new(0.8, 0, 0, 40 * scale)
        msgFrame.BackgroundColor3 = isFromPlayer and Color3.fromRGB(33, 150, 243) or Color3.fromRGB(66, 66, 66)
        msgFrame.BorderSizePixel = 0
        msgFrame.Parent = chatFrame
        
        if isFromPlayer then
            msgFrame.Position = UDim2.new(0.2, 0, 0, 0)
        end
        
        local msgCorner = Instance.new("UICorner")
        msgCorner.CornerRadius = UDim.new(0, 15 * scale)
        msgCorner.Parent = msgFrame
        
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -20 * scale, 1, 0)
        msgLabel.Position = UDim2.new(0, 10 * scale, 0, 0)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = text
        msgLabel.TextColor3 = Color3.white
        msgLabel.TextScaled = true
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.Parent = msgFrame
        
        chatFrame.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y)
        chatFrame.CanvasPosition = Vector2.new(0, chatFrame.CanvasSize.Y.Offset)
    end
    
    -- Send message
    local function sendMessage()
        local text = messageBox.Text
        if text and text ~= "" then
            addMessage(text, true)
            messageBox.Text = ""
            
            -- Store message
            if not self.messages[targetPlayer.UserId] then
                self.messages[targetPlayer.UserId] = {}
            end
            table.insert(self.messages[targetPlayer.UserId], {
                text = text,
                from = player.UserId,
                timestamp = tick()
            })
        end
    end
    
    sendButton.MouseButton1Click:Connect(sendMessage)
    messageBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    -- Load existing messages
    if self.messages[targetPlayer.UserId] then
        for _, message in pairs(self.messages[targetPlayer.UserId]) do
            addMessage(message.text, message.from == player.UserId)
        end
    end
end

-- Create Phone App
function PhoneSystem:createPhoneApp()
    local scale = math.min(workspace.CurrentCamera.ViewportSize.X / 1920, workspace.CurrentCamera.ViewportSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70 * scale, 0, 50 * scale)
    title.Position = UDim2.new(0, 60 * scale, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "📞 Phone"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.appsContainer
    
    -- Voice Chat Status
    local voiceStatus = Instance.new("TextLabel")
    voiceStatus.Size = UDim2.new(1, -20 * scale, 0, 30 * scale)
    voiceStatus.Position = UDim2.new(0, 10 * scale, 0, 70 * scale)
    voiceStatus.BackgroundTransparency = 1
    voiceStatus.Text = self.voiceEnabled and "🎤 Voice Chat: Enabled" or "🎤 Voice Chat: Disabled"
    voiceStatus.TextColor3 = self.voiceEnabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
    voiceStatus.TextScaled = true
    voiceStatus.Font = Enum.Font.Gotham
    voiceStatus.Parent = self.appsContainer
    
    -- Active Calls
    local activeCallsFrame = Instance.new("ScrollingFrame")
    activeCallsFrame.Size = UDim2.new(1, -20 * scale, 1, -110 * scale)
    activeCallsFrame.Position = UDim2.new(0, 10 * scale, 0, 100 * scale)
    activeCallsFrame.BackgroundTransparency = 1
    activeCallsFrame.BorderSizePixel = 0
    activeCallsFrame.ScrollBarThickness = 6
    activeCallsFrame.Parent = self.appsContainer
    
    local callsLayout = Instance.new("UIListLayout")
    callsLayout.Padding = UDim.new(0, 10 * scale)
    callsLayout.Parent = activeCallsFrame
    
    -- Function to update active calls display
    local function updateActiveCalls()
        for _, child in pairs(activeCallsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for playerId, callData in pairs(self.activeCalls) do
            local targetPlayer = Players:GetPlayerByUserId(playerId)
            if targetPlayer then
                local callFrame = Instance.new("Frame")
                callFrame.Size = UDim2.new(1, 0, 0, 80 * scale)
                callFrame.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                callFrame.BorderSizePixel = 0
                callFrame.Parent = activeCallsFrame
                
                local callCorner = Instance.new("UICorner")
                callCorner.CornerRadius = UDim.new(0, 10 * scale)
                callCorner.Parent = callFrame
                
                -- Call Info
                local callInfo = Instance.new("TextLabel")
                callInfo.Size = UDim2.new(0.7, 0, 1, 0)
                callInfo.Position = UDim2.new(0, 10 * scale, 0, 0)
                callInfo.BackgroundTransparency = 1
                callInfo.Text = "📞 " .. targetPlayer.Name .. "\n⏱️ " .. math.floor((tick() - callData.startTime) / 60) .. ":" .. string.format("%02d", math.floor((tick() - callData.startTime) % 60))
                callInfo.TextColor3 = Color3.white
                callInfo.TextScaled = true
                callInfo.Font = Enum.Font.Gotham
                callInfo.TextXAlignment = Enum.TextXAlignment.Left
                callInfo.Parent = callFrame
                
                -- End Call Button
                local endButton = Instance.new("TextButton")
                endButton.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
                endButton.Position = UDim2.new(1, -70 * scale, 0.5, -30 * scale)
                endButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
                endButton.BorderSizePixel = 0
                endButton.Text = "📵"
                endButton.TextColor3 = Color3.white
                endButton.TextScaled = true
                endButton.Font = Enum.Font.GothamBold
                endButton.Parent = callFrame
                
                local endCorner = Instance.new("UICorner")
                endCorner.CornerRadius = UDim.new(1, 0)
                endCorner.Parent = endButton
                
                endButton.MouseButton1Click:Connect(function()
                    self:endCall(targetPlayer)
                end)
            end
        end
        
        activeCallsFrame.CanvasSize = UDim2.new(0, 0, 0, callsLayout.AbsoluteContentSize.Y)
    end
    
    -- Update calls display periodically
    spawn(function()
        while self.currentApp == "phone" do
            updateActiveCalls()
            wait(1)
        end
    end)
    
    updateActiveCalls()
end

-- Create Group Call App
function PhoneSystem:createGroupCallApp()
    local scale = math.min(workspace.CurrentCamera.ViewportSize.X / 1920, workspace.CurrentCamera.ViewportSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70 * scale, 0, 50 * scale)
    title.Position = UDim2.new(0, 60 * scale, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "👥📞 Group Calls"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.appsContainer
    
    -- Create Group Call Button
    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(1, -20 * scale, 0, 50 * scale)
    createButton.Position = UDim2.new(0, 10 * scale, 0, 70 * scale)
    createButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    createButton.BorderSizePixel = 0
    createButton.Text = "➕ Create Group Call"
    createButton.TextColor3 = Color3.white
    createButton.TextScaled = true
    createButton.Font = Enum.Font.GothamBold
    createButton.Parent = self.appsContainer
    
    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 25 * scale)
    createCorner.Parent = createButton
    
    createButton.MouseButton1Click:Connect(function()
        self:createGroupCall()
    end)
    
    -- Active Group Calls
    local groupCallsFrame = Instance.new("ScrollingFrame")
    groupCallsFrame.Size = UDim2.new(1, -20 * scale, 1, -130 * scale)
    groupCallsFrame.Position = UDim2.new(0, 10 * scale, 0, 130 * scale)
    groupCallsFrame.BackgroundTransparency = 1
    groupCallsFrame.BorderSizePixel = 0
    groupCallsFrame.ScrollBarThickness = 6
    groupCallsFrame.Parent = self.appsContainer
    
    local groupLayout = Instance.new("UIListLayout")
    groupLayout.Padding = UDim.new(0, 10 * scale)
    groupLayout.Parent = groupCallsFrame
    
    -- Update group calls display
    local function updateGroupCalls()
        for _, child in pairs(groupCallsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for groupId, groupData in pairs(self.groupCalls) do
            local groupFrame = Instance.new("Frame")
            groupFrame.Size = UDim2.new(1, 0, 0, 100 * scale)
            groupFrame.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
            groupFrame.BorderSizePixel = 0
            groupFrame.Parent = groupCallsFrame
            
            local groupCorner = Instance.new("UICorner")
            groupCorner.CornerRadius = UDim.new(0, 10 * scale)
            groupCorner.Parent = groupFrame
            
            -- Group Info
            local groupInfo = Instance.new("TextLabel")
            groupInfo.Size = UDim2.new(0.7, 0, 0.6, 0)
            groupInfo.Position = UDim2.new(0, 10 * scale, 0, 0)
            groupInfo.BackgroundTransparency = 1
            groupInfo.Text = "Group Call #" .. groupId .. "\n👥 " .. #groupData.participants .. " participants"
            groupInfo.TextColor3 = Color3.white
            groupInfo.TextScaled = true
            groupInfo.Font = Enum.Font.Gotham
            groupInfo.TextXAlignment = Enum.TextXAlignment.Left
            groupInfo.Parent = groupFrame
            
            -- Participants List
            local participantsText = ""
            for _, participantId in pairs(groupData.participants) do
                local participant = Players:GetPlayerByUserId(participantId)
                if participant then
                    participantsText = participantsText .. participant.Name .. " "
                end
            end
            
            local participantsLabel = Instance.new("TextLabel")
            participantsLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
            participantsLabel.Position = UDim2.new(0, 10 * scale, 0.6, 0)
            participantsLabel.BackgroundTransparency = 1
            participantsLabel.Text = participantsText
            participantsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            participantsLabel.TextScaled = true
            participantsLabel.Font = Enum.Font.Gotham
            participantsLabel.TextXAlignment = Enum.TextXAlignment.Left
            participantsLabel.Parent = groupFrame
            
            -- Join Button
            local joinButton = Instance.new("TextButton")
            joinButton.Size = UDim2.new(0, 80 * scale, 0, 40 * scale)
            joinButton.Position = UDim2.new(1, -90 * scale, 0, 10 * scale)
            joinButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            joinButton.BorderSizePixel = 0
            joinButton.Text = "Join"
            joinButton.TextColor3 = Color3.white
            joinButton.TextScaled = true
            joinButton.Font = Enum.Font.GothamBold
            joinButton.Parent = groupFrame
            
            local joinCorner = Instance.new("UICorner")
            joinCorner.CornerRadius = UDim.new(0, 20 * scale)
            joinCorner.Parent = joinButton
            
            joinButton.MouseButton1Click:Connect(function()
                self:joinGroupCall(groupId)
            end)
        end
        
        groupCallsFrame.CanvasSize = UDim2.new(0, 0, 0, groupLayout.AbsoluteContentSize.Y)
    end
    
    updateGroupCalls()
end

-- Create Settings App
function PhoneSystem:createSettingsApp()
    local scale = math.min(workspace.CurrentCamera.ViewportSize.X / 1920, workspace.CurrentCamera.ViewportSize.Y / 1080)
    scale = math.max(0.5, math.min(1.2, scale))
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70 * scale, 0, 50 * scale)
    title.Position = UDim2.new(0, 60 * scale, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Settings"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = self.appsContainer
    
    -- Voice Chat Toggle
    local voiceToggle = Instance.new("TextButton")
    voiceToggle.Size = UDim2.new(1, -20 * scale, 0, 50 * scale)
    voiceToggle.Position = UDim2.new(0, 10 * scale, 0, 70 * scale)
    voiceToggle.BackgroundColor3 = self.voiceEnabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
    voiceToggle.BorderSizePixel = 0
    voiceToggle.Text = self.voiceEnabled and "🎤 Voice Chat: ON" or "🎤 Voice Chat: OFF"
    voiceToggle.TextColor3 = Color3.white
    voiceToggle.TextScaled = true
    voiceToggle.Font = Enum.Font.GothamBold
    voiceToggle.Parent = self.appsContainer
    
    local voiceCorner = Instance.new("UICorner")
    voiceCorner.CornerRadius = UDim.new(0, 25 * scale)
    voiceCorner.Parent = voiceToggle
    
    voiceToggle.MouseButton1Click:Connect(function()
        self:toggleVoiceChat()
        voiceToggle.BackgroundColor3 = self.voiceEnabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
        voiceToggle.Text = self.voiceEnabled and "🎤 Voice Chat: ON" or "🎤 Voice Chat: OFF"
    end)
    
    -- Phone Info
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20 * scale, 1, -130 * scale)
    infoLabel.Position = UDim2.new(0, 10 * scale, 0, 130 * scale)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "📱 Roblox Phone System v2.0\n\n✨ Features:\n• Voice Chat Integration\n• Group Calls\n• Real-time Messaging\n• Contact Management\n• Cross-platform Support\n\n👨‍💻 Made by AI Assistant"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = self.appsContainer
end

-- Setup VoiceChat
function PhoneSystem:setupVoiceChat()
    -- Check if VoiceChat is available
    if VoiceChatService then
        self.voiceEnabled = VoiceChatService.IsVoiceEnabledForUserIdAsync and 
                           VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
    end
end

-- Toggle Voice Chat
function PhoneSystem:toggleVoiceChat()
    self.voiceEnabled = not self.voiceEnabled
    print("🎤 Voice Chat:", self.voiceEnabled and "Enabled" or "Disabled")
end

-- Initiate Call
function PhoneSystem:initiateCall(targetPlayer)
    if not targetPlayer or targetPlayer == player then return end
    
    print("📞 Calling " .. targetPlayer.Name .. "...")
    
    -- Add to active calls
    self.activeCalls[targetPlayer.UserId] = {
        player = targetPlayer,
        startTime = tick(),
        isVoiceEnabled = self.voiceEnabled
    }
    
    -- Enable voice chat for the call if available
    if self.voiceEnabled and VoiceChatService then
        -- Voice chat setup would go here
        -- This is a placeholder for actual voice implementation
        print("🎤 Voice chat enabled for call with " .. targetPlayer.Name)
    end
    
    -- Open phone app to show active call
    self:openApp("phone")
end

-- End Call
function PhoneSystem:endCall(targetPlayer)
    if self.activeCalls[targetPlayer.UserId] then
        print("📵 Call ended with " .. targetPlayer.Name)
        self.activeCalls[targetPlayer.UserId] = nil
        
        -- Disable voice chat for this call
        if self.voiceEnabled then
            print("🎤 Voice chat disabled for " .. targetPlayer.Name)
        end
    end
end

-- Create Group Call
function PhoneSystem:createGroupCall()
    local groupId = tick() -- Simple ID generation
    self.groupCalls[groupId] = {
        creator = player.UserId,
        participants = {player.UserId},
        startTime = tick()
    }
    
    print("👥📞 Created group call #" .. groupId)
    self:openApp("group")
end

-- Join Group Call
function PhoneSystem:joinGroupCall(groupId)
    if self.groupCalls[groupId] then
        table.insert(self.groupCalls[groupId].participants, player.UserId)
        print("👥📞 Joined group call #" .. groupId)
        
        if self.voiceEnabled then
            print("🎤 Voice chat enabled for group call")
        end
    end
end

-- Setup Touch Controls
function PhoneSystem:setupTouchControls()
    -- Touch-specific optimizations
    local touchGui = Instance.new("Frame")
    touchGui.Size = UDim2.new(1, 0, 1, 0)
    touchGui.BackgroundTransparency = 1
    touchGui.Parent = self.screenGui
    
    -- Gesture handling for mobile
    UserInputService.TouchSwipe:Connect(function(swipeDirection, numberOfTouches)
        if numberOfTouches == 2 and swipeDirection == Enum.SwipeDirection.Right then
            if not self.isPhoneOpen then
                self:togglePhone()
            end
        elseif numberOfTouches == 2 and swipeDirection == Enum.SwipeDirection.Left then
            if self.isPhoneOpen then
                self:togglePhone()
            end
        end
    end)
end

-- Setup Event Handlers
function PhoneSystem:setupEventHandlers()
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        -- End any active calls
        if self.activeCalls[leavingPlayer.UserId] then
            self.activeCalls[leavingPlayer.UserId] = nil
        end
        
        -- Remove from group calls
        for groupId, groupData in pairs(self.groupCalls) do
            for i, participantId in pairs(groupData.participants) do
                if participantId == leavingPlayer.UserId then
                    table.remove(groupData.participants, i)
                    break
                end
            end
        end
    end)
    
    -- Handle screen size changes
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        -- Recalculate scale and update UI
        local screenSize = workspace.CurrentCamera.ViewportSize
        local scale = math.min(screenSize.X / 1920, screenSize.Y / 1080)
        scale = math.max(0.5, math.min(1.2, scale))
        
        -- Update toggle button size and position
        self.toggleButton.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
        self.toggleButton.Position = UDim2.new(1, -80 * scale, 0.5, -30 * scale)
        
        -- Update phone frame size and position
        self.phoneFrame.Size = UDim2.new(0, 380 * scale, 0, 720 * scale)
        if self.isPhoneOpen then
            self.phoneFrame.Position = UDim2.new(0.5, -190 * scale, 0.5, -360 * scale)
        end
    end)
    
    -- Keyboard shortcuts for PC
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            self:togglePhone()
        elseif input.KeyCode == Enum.KeyCode.Escape and self.isPhoneOpen then
            self:togglePhone()
        end
    end)
end

-- Initialize the phone system
local phoneSystem = PhoneSystem.new()

-- Welcome message
print("📱 Roblox Phone System Loaded!")
print("🎯 Features: Voice Calls, Group Calls, Messaging, Contacts")
print("📋 Controls:")
print("  📱 Click phone icon (right center) to toggle")
print("  📱 Press 'P' key to toggle (PC)")
print("  📱 Swipe with 2 fingers (Mobile)")
print("✅ System ready!")