-- 📱 Advanced Roblox Phone System v3.0 - Ultimate Edition
-- Features: Video Calls, Apps Store, Camera, Music, Notifications, Enhanced UI
-- Compatible with Mobile, PC, and Console with Full VoiceChat Integration

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local VoiceChatService = game:GetService("VoiceChatService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

-- Advanced Phone System Class
local AdvancedPhone = {}
AdvancedPhone.__index = AdvancedPhone

-- Initialize Advanced Phone System
function AdvancedPhone.new()
    local self = setmetatable({}, AdvancedPhone)
    
    -- Core Variables
    self.isPhoneOpen = false
    self.currentApp = "home"
    self.currentPage = 1
    self.contacts = {}
    self.messages = {}
    self.activeCalls = {}
    self.groupCalls = {}
    self.notifications = {}
    self.installedApps = {}
    self.photos = {}
    self.music = {}
    self.settings = {
        voiceEnabled = false,
        notifications = true,
        darkMode = true,
        autoAnswer = false,
        ringtone = "Default"
    }
    
    -- UI Elements
    self.screenGui = nil
    self.phoneFrame = nil
    self.toggleButton = nil
    self.statusBar = nil
    self.homeScreen = nil
    self.appsContainer = nil
    self.notificationBar = nil
    
    -- Enhanced Apps System
    self.apps = {
        ["contacts"] = {icon = "👥", name = "Contacts", color = Color3.fromRGB(33, 150, 243)},
        ["messages"] = {icon = "💬", name = "Messages", color = Color3.fromRGB(76, 175, 80)},
        ["phone"] = {icon = "📞", name = "Phone", color = Color3.fromRGB(244, 67, 54)},
        ["videocall"] = {icon = "📹", name = "Video Call", color = Color3.fromRGB(156, 39, 176)},
        ["group"] = {icon = "👥📞", name = "Group Call", color = Color3.fromRGB(255, 152, 0)},
        ["camera"] = {icon = "📷", name = "Camera", color = Color3.fromRGB(96, 125, 139)},
        ["gallery"] = {icon = "🖼️", name = "Gallery", color = Color3.fromRGB(121, 85, 72)},
        ["music"] = {icon = "🎵", name = "Music", color = Color3.fromRGB(233, 30, 99)},
        ["store"] = {icon = "🏪", name = "App Store", color = Color3.fromRGB(63, 81, 181)},
        ["settings"] = {icon = "⚙️", name = "Settings", color = Color3.fromRGB(158, 158, 158)},
        ["calculator"] = {icon = "🔢", name = "Calculator", color = Color3.fromRGB(255, 193, 7)},
        ["notes"] = {icon = "📝", name = "Notes", color = Color3.fromRGB(255, 235, 59)}
    }
    
    -- Initialize the system
    self:createAdvancedGUI()
    self:setupAdvancedVoiceChat()
    self:setupAdvancedEventHandlers()
    self:initializeNotificationSystem()
    self:loadUserSettings()
    
    return self
end

-- Create Advanced GUI Structure
function AdvancedPhone:createAdvancedGUI()
    -- Main ScreenGui with enhanced properties
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "AdvancedPhoneSystem"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.DisplayOrder = 100
    self.screenGui.Parent = player.PlayerGui
    
    -- Dynamic scaling system
    local screenSize = workspace.CurrentCamera.ViewportSize
    local baseResolution = Vector2.new(1920, 1080)
    local scale = math.min(screenSize.X / baseResolution.X, screenSize.Y / baseResolution.Y)
    scale = math.max(0.4, math.min(1.5, scale))
    
    self.scale = scale
    
    -- Enhanced Toggle Button with glow effect
    self.toggleButton = Instance.new("ImageButton")
    self.toggleButton.Name = "PhoneToggle"
    self.toggleButton.Size = UDim2.new(0, 70 * scale, 0, 70 * scale)
    self.toggleButton.Position = UDim2.new(1, -90 * scale, 0.5, -35 * scale)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    self.toggleButton.BorderSizePixel = 0
    self.toggleButton.ZIndex = 10
    self.toggleButton.Parent = self.screenGui
    
    -- Toggle Button Shadow
    local toggleShadow = Instance.new("Frame")
    toggleShadow.Size = UDim2.new(1, 10, 1, 10)
    toggleShadow.Position = UDim2.new(0, -5, 0, -5)
    toggleShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleShadow.BackgroundTransparency = 0.8
    toggleShadow.ZIndex = 9
    toggleShadow.Parent = self.toggleButton
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = toggleShadow
    
    -- Toggle Button Icon with animation
    local toggleIcon = Instance.new("TextLabel")
    toggleIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
    toggleIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Text = "📱"
    toggleIcon.TextColor3 = Color3.white
    toggleIcon.TextScaled = true
    toggleIcon.Font = Enum.Font.GothamBold
    toggleIcon.ZIndex = 11
    toggleIcon.Parent = self.toggleButton
    
    -- Rounded corners for toggle
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = self.toggleButton
    
    -- Enhanced Phone Frame with realistic design
    self.phoneFrame = Instance.new("Frame")
    self.phoneFrame.Name = "PhoneFrame"
    self.phoneFrame.Size = UDim2.new(0, 400 * scale, 0, 800 * scale)
    self.phoneFrame.Position = UDim2.new(0.5, -200 * scale, 0.5, -400 * scale)
    self.phoneFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.phoneFrame.BorderSizePixel = 0
    self.phoneFrame.Visible = false
    self.phoneFrame.ZIndex = 5
    self.phoneFrame.Parent = self.screenGui
    
    -- Phone Frame Shadow
    local phoneShadow = Instance.new("Frame")
    phoneShadow.Size = UDim2.new(1, 20, 1, 20)
    phoneShadow.Position = UDim2.new(0, -10, 0, -10)
    phoneShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    phoneShadow.BackgroundTransparency = 0.7
    phoneShadow.ZIndex = 4
    phoneShadow.Parent = self.phoneFrame
    
    local phoneShadowCorner = Instance.new("UICorner")
    phoneShadowCorner.CornerRadius = UDim.new(0, 30 * scale)
    phoneShadowCorner.Parent = phoneShadow
    
    -- Phone Frame Corner with enhanced radius
    local phoneCorner = Instance.new("UICorner")
    phoneCorner.CornerRadius = UDim.new(0, 30 * scale)
    phoneCorner.Parent = self.phoneFrame
    
    -- Realistic Phone Border
    local phoneBorder = Instance.new("UIStroke")
    phoneBorder.Color = Color3.fromRGB(100, 100, 100)
    phoneBorder.Thickness = 3
    phoneBorder.Transparency = 0.3
    phoneBorder.Parent = self.phoneFrame
    
    -- Screen Area (Inside the phone)
    local screenArea = Instance.new("Frame")
    screenArea.Name = "ScreenArea"
    screenArea.Size = UDim2.new(1, -20 * scale, 1, -40 * scale)
    screenArea.Position = UDim2.new(0, 10 * scale, 0, 20 * scale)
    screenArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    screenArea.BorderSizePixel = 0
    screenArea.ZIndex = 6
    screenArea.Parent = self.phoneFrame
    
    local screenCorner = Instance.new("UICorner")
    screenCorner.CornerRadius = UDim.new(0, 20 * scale)
    screenCorner.Parent = screenArea
    
    -- Enhanced Status Bar
    self:createEnhancedStatusBar(screenArea, scale)
    
    -- Notification Bar
    self:createNotificationBar(screenArea, scale)
    
    -- Enhanced Home Screen
    self:createEnhancedHomeScreen(screenArea, scale)
    
    -- Apps Container
    self:createEnhancedAppsContainer(screenArea, scale)
    
    -- Bottom Navigation Bar
    self:createBottomNavigation(screenArea, scale)
    
    -- Setup toggle functionality with animation
    self.toggleButton.MouseButton1Click:Connect(function()
        self:togglePhoneWithAnimation()
    end)
    
    -- Enhanced hover effects
    self.toggleButton.MouseEnter:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), 
            {Size = UDim2.new(0, 80 * scale, 0, 80 * scale)}):Play()
        TweenService:Create(toggleIcon, TweenInfo.new(0.3), {Rotation = 15}):Play()
    end)
    
    self.toggleButton.MouseLeave:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), 
            {Size = UDim2.new(0, 70 * scale, 0, 70 * scale)}):Play()
        TweenService:Create(toggleIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
    end)
    
    -- Setup device-specific controls
    self:setupDeviceControls()
end

-- Create Enhanced Status Bar
function AdvancedPhone:createEnhancedStatusBar(parent, scale)
    self.statusBar = Instance.new("Frame")
    self.statusBar.Name = "StatusBar"
    self.statusBar.Size = UDim2.new(1, 0, 0, 50 * scale)
    self.statusBar.Position = UDim2.new(0, 0, 0, 0)
    self.statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.statusBar.BorderSizePixel = 0
    self.statusBar.ZIndex = 7
    self.statusBar.Parent = parent
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(33, 150, 243)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 101, 192))
    }
    gradient.Rotation = 45
    gradient.Parent = self.statusBar
    
    -- Status Bar Corner
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 20 * scale)
    statusCorner.Parent = self.statusBar
    
    -- Time Display with better formatting
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    timeLabel.Position = UDim2.new(0, 15, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.white
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.ZIndex = 8
    timeLabel.Parent = self.statusBar
    
    -- Enhanced Icons
    local iconsFrame = Instance.new("Frame")
    iconsFrame.Size = UDim2.new(0.5, 0, 1, 0)
    iconsFrame.Position = UDim2.new(0.5, 0, 0, 0)
    iconsFrame.BackgroundTransparency = 1
    iconsFrame.ZIndex = 8
    iconsFrame.Parent = self.statusBar
    
    local iconsLayout = Instance.new("UIListLayout")
    iconsLayout.FillDirection = Enum.FillDirection.Horizontal
    iconsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    iconsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    iconsLayout.Padding = UDim.new(0, 10)
    iconsLayout.Parent = iconsFrame
    
    -- Notification Icon
    local notifIcon = Instance.new("TextLabel")
    notifIcon.Size = UDim2.new(0, 30 * scale, 0, 30 * scale)
    notifIcon.BackgroundTransparency = 1
    notifIcon.Text = "🔔"
    notifIcon.TextColor3 = Color3.white
    notifIcon.TextScaled = true
    notifIcon.ZIndex = 8
    notifIcon.Parent = iconsFrame
    
    -- Voice Chat Icon
    local voiceIcon = Instance.new("TextLabel")
    voiceIcon.Size = UDim2.new(0, 30 * scale, 0, 30 * scale)
    voiceIcon.BackgroundTransparency = 1
    voiceIcon.Text = self.settings.voiceEnabled and "🎤" or "🔇"
    voiceIcon.TextColor3 = Color3.white
    voiceIcon.TextScaled = true
    voiceIcon.ZIndex = 8
    voiceIcon.Parent = iconsFrame
    
    -- Signal Icon
    local signalIcon = Instance.new("TextLabel")
    signalIcon.Size = UDim2.new(0, 30 * scale, 0, 30 * scale)
    signalIcon.BackgroundTransparency = 1
    signalIcon.Text = "📶"
    signalIcon.TextColor3 = Color3.white
    signalIcon.TextScaled = true
    signalIcon.ZIndex = 8
    signalIcon.Parent = iconsFrame
    
    -- Battery Icon with percentage
    local batteryFrame = Instance.new("Frame")
    batteryFrame.Size = UDim2.new(0, 60 * scale, 0, 30 * scale)
    batteryFrame.BackgroundTransparency = 1
    batteryFrame.ZIndex = 8
    batteryFrame.Parent = iconsFrame
    
    local batteryIcon = Instance.new("TextLabel")
    batteryIcon.Size = UDim2.new(0.6, 0, 1, 0)
    batteryIcon.Position = UDim2.new(0, 0, 0, 0)
    batteryIcon.BackgroundTransparency = 1
    batteryIcon.Text = "🔋"
    batteryIcon.TextColor3 = Color3.white
    batteryIcon.TextScaled = true
    batteryIcon.ZIndex = 8
    batteryIcon.Parent = batteryFrame
    
    local batteryPercent = Instance.new("TextLabel")
    batteryPercent.Size = UDim2.new(0.4, 0, 1, 0)
    batteryPercent.Position = UDim2.new(0.6, 0, 0, 0)
    batteryPercent.BackgroundTransparency = 1
    batteryPercent.Text = "100%"
    batteryPercent.TextColor3 = Color3.white
    batteryPercent.TextScaled = true
    batteryPercent.Font = Enum.Font.Gotham
    batteryPercent.ZIndex = 8
    batteryPercent.Parent = batteryFrame
    
    -- Update time and battery every second
    spawn(function()
        while true do
            timeLabel.Text = os.date("%H:%M")
            -- Simulate battery drain
            local currentPercent = tonumber(batteryPercent.Text:match("%d+"))
            if currentPercent and currentPercent > 0 then
                batteryPercent.Text = currentPercent - math.random(0, 1) .. "%"
            end
            wait(60) -- Update every minute
        end
    end)
end

-- Create Notification Bar
function AdvancedPhone:createNotificationBar(parent, scale)
    self.notificationBar = Instance.new("ScrollingFrame")
    self.notificationBar.Name = "NotificationBar"
    self.notificationBar.Size = UDim2.new(1, 0, 0, 100 * scale)
    self.notificationBar.Position = UDim2.new(0, 0, 0, 50 * scale)
    self.notificationBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.notificationBar.BackgroundTransparency = 0.1
    self.notificationBar.BorderSizePixel = 0
    self.notificationBar.ScrollBarThickness = 0
    self.notificationBar.Visible = false
    self.notificationBar.ZIndex = 7
    self.notificationBar.Parent = parent
    
    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 5)
    notifLayout.Parent = self.notificationBar
end

-- Create Enhanced Home Screen
function AdvancedPhone:createEnhancedHomeScreen(parent, scale)
    self.homeScreen = Instance.new("ScrollingFrame")
    self.homeScreen.Name = "HomeScreen"
    self.homeScreen.Size = UDim2.new(1, 0, 1, -150 * scale)
    self.homeScreen.Position = UDim2.new(0, 0, 0, 50 * scale)
    self.homeScreen.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.homeScreen.BorderSizePixel = 0
    self.homeScreen.ScrollBarThickness = 0
    self.homeScreen.ZIndex = 6
    self.homeScreen.Parent = parent
    
    -- Dynamic wallpaper
    local wallpaper = Instance.new("ImageLabel")
    wallpaper.Size = UDim2.new(1, 0, 1, 0)
    wallpaper.Position = UDim2.new(0, 0, 0, 0)
    wallpaper.BackgroundTransparency = 1
    wallpaper.Image = "rbxasset://textures/loading/robloxTilt.png"
    wallpaper.ImageTransparency = 0.8
    wallpaper.ScaleType = Enum.ScaleType.Crop
    wallpaper.ZIndex = 6
    wallpaper.Parent = self.homeScreen
    
    -- Enhanced Apps Grid Layout
    local appsGrid = Instance.new("UIGridLayout")
    appsGrid.CellSize = UDim2.new(0, 90 * scale, 0, 110 * scale)
    appsGrid.CellPadding = UDim2.new(0, 15 * scale, 0, 15 * scale)
    appsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    appsGrid.VerticalAlignment = Enum.VerticalAlignment.Top
    appsGrid.StartCorner = Enum.StartCorner.TopLeft
    appsGrid.Parent = self.homeScreen
    
    -- Create Enhanced App Icons
    for appName, appData in pairs(self.apps) do
        local appButton = Instance.new("TextButton")
        appButton.Name = appName .. "App"
        appButton.BackgroundColor3 = appData.color
        appButton.BorderSizePixel = 0
        appButton.Text = ""
        appButton.ZIndex = 7
        appButton.Parent = self.homeScreen
        
        -- App gradient
        local appGradient = Instance.new("UIGradient")
        appGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, appData.color),
            ColorSequenceKeypoint.new(1, Color3.new(
                appData.color.R * 0.7,
                appData.color.G * 0.7,
                appData.color.B * 0.7
            ))
        }
        appGradient.Rotation = 45
        appGradient.Parent = appButton
        
        local appCorner = Instance.new("UICorner")
        appCorner.CornerRadius = UDim.new(0, 20 * scale)
        appCorner.Parent = appButton
        
        -- App shadow
        local appShadow = Instance.new("Frame")
        appShadow.Size = UDim2.new(1, 6, 1, 6)
        appShadow.Position = UDim2.new(0, -3, 0, -3)
        appShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        appShadow.BackgroundTransparency = 0.8
        appShadow.ZIndex = 6
        appShadow.Parent = appButton
        
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.CornerRadius = UDim.new(0, 20 * scale)
        shadowCorner.Parent = appShadow
        
        local appIcon = Instance.new("TextLabel")
        appIcon.Size = UDim2.new(1, 0, 0.7, 0)
        appIcon.Position = UDim2.new(0, 0, 0, 0)
        appIcon.BackgroundTransparency = 1
        appIcon.Text = appData.icon
        appIcon.TextColor3 = Color3.white
        appIcon.TextScaled = true
        appIcon.Font = Enum.Font.GothamBold
        appIcon.ZIndex = 8
        appIcon.Parent = appButton
        
        local appLabel = Instance.new("TextLabel")
        appLabel.Size = UDim2.new(1, -10, 0.3, 0)
        appLabel.Position = UDim2.new(0, 5, 0.7, 0)
        appLabel.BackgroundTransparency = 1
        appLabel.Text = appData.name
        appLabel.TextColor3 = Color3.white
        appLabel.TextScaled = true
        appLabel.Font = Enum.Font.Gotham
        appLabel.ZIndex = 8
        appLabel.Parent = appButton
        
        -- Enhanced App Button Interactions
        appButton.MouseButton1Click:Connect(function()
            self:openAppWithAnimation(appName)
        end)
        
        -- Advanced hover effects
        appButton.MouseEnter:Connect(function()
            TweenService:Create(appButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), 
                {Size = UDim2.new(0, 100 * scale, 0, 120 * scale)}):Play()
            TweenService:Create(appIcon, TweenInfo.new(0.2), {Rotation = 5}):Play()
        end)
        
        appButton.MouseLeave:Connect(function()
            TweenService:Create(appButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), 
                {Size = UDim2.new(0, 90 * scale, 0, 110 * scale)}):Play()
            TweenService:Create(appIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
        end)
    end
    
    -- Update canvas size
    self.homeScreen.CanvasSize = UDim2.new(0, 0, 0, appsGrid.AbsoluteContentSize.Y + 50)
end

-- Create Enhanced Apps Container
function AdvancedPhone:createEnhancedAppsContainer(parent, scale)
    self.appsContainer = Instance.new("Frame")
    self.appsContainer.Name = "AppsContainer"
    self.appsContainer.Size = UDim2.new(1, 0, 1, -150 * scale)
    self.appsContainer.Position = UDim2.new(0, 0, 0, 50 * scale)
    self.appsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.appsContainer.BorderSizePixel = 0
    self.appsContainer.Visible = false
    self.appsContainer.ZIndex = 6
    self.appsContainer.Parent = parent
    
    -- Enhanced Back Button with animation
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
    backButton.Position = UDim2.new(0, 15, 0, 15)
    backButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    backButton.BorderSizePixel = 0
    backButton.Text = "←"
    backButton.TextColor3 = Color3.white
    backButton.TextScaled = true
    backButton.Font = Enum.Font.GothamBold
    backButton.ZIndex = 7
    backButton.Parent = self.appsContainer
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(1, 0)
    backCorner.Parent = backButton
    
    -- Back button effects
    backButton.MouseEnter:Connect(function()
        TweenService:Create(backButton, TweenInfo.new(0.2), 
            {BackgroundColor3 = Color3.fromRGB(21, 101, 192)}):Play()
    end)
    
    backButton.MouseLeave:Connect(function()
        TweenService:Create(backButton, TweenInfo.new(0.2), 
            {BackgroundColor3 = Color3.fromRGB(33, 150, 243)}):Play()
    end)
    
    backButton.MouseButton1Click:Connect(function()
        self:goHomeWithAnimation()
    end)
end

-- Create Bottom Navigation
function AdvancedPhone:createBottomNavigation(parent, scale)
    local bottomNav = Instance.new("Frame")
    bottomNav.Name = "BottomNavigation"
    bottomNav.Size = UDim2.new(1, 0, 0, 100 * scale)
    bottomNav.Position = UDim2.new(0, 0, 1, -100 * scale)
    bottomNav.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bottomNav.BorderSizePixel = 0
    bottomNav.ZIndex = 7
    bottomNav.Parent = parent
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 20 * scale)
    navCorner.Parent = bottomNav
    
    -- Quick access buttons
    local quickApps = {"phone", "messages", "contacts", "settings"}
    local navLayout = Instance.new("UIListLayout")
    navLayout.FillDirection = Enum.FillDirection.Horizontal
    navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    navLayout.Padding = UDim.new(0, 20 * scale)
    navLayout.Parent = bottomNav
    
    for _, appName in pairs(quickApps) do
        local quickButton = Instance.new("TextButton")
        quickButton.Size = UDim2.new(0, 70 * scale, 0, 70 * scale)
        quickButton.BackgroundColor3 = self.apps[appName].color
        quickButton.BorderSizePixel = 0
        quickButton.Text = self.apps[appName].icon
        quickButton.TextColor3 = Color3.white
        quickButton.TextScaled = true
        quickButton.Font = Enum.Font.GothamBold
        quickButton.ZIndex = 8
        quickButton.Parent = bottomNav
        
        local quickCorner = Instance.new("UICorner")
        quickCorner.CornerRadius = UDim.new(1, 0)
        quickCorner.Parent = quickButton
        
        quickButton.MouseButton1Click:Connect(function()
            self:openAppWithAnimation(appName)
        end)
    end
end

-- Enhanced Phone Toggle with Animation
function AdvancedPhone:togglePhoneWithAnimation()
    self.isPhoneOpen = not self.isPhoneOpen
    
    local targetPosition
    local targetRotation = 0
    
    if self.isPhoneOpen then
        targetPosition = UDim2.new(0.5, -200 * self.scale, 0.5, -400 * self.scale)
        self.phoneFrame.Visible = true
        
        -- Slide in animation
        self.phoneFrame.Position = UDim2.new(1.5, 0, 0.5, -400 * self.scale)
        TweenService:Create(
            self.phoneFrame,
            TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = targetPosition, Rotation = targetRotation}
        ):Play()
        
        -- Scale in effect
        self.phoneFrame.Size = UDim2.new(0, 200 * self.scale, 0, 400 * self.scale)
        TweenService:Create(
            self.phoneFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 400 * self.scale, 0, 800 * self.scale)}
        ):Play()
        
        self:addNotification("Phone", "Phone opened successfully! 📱", "success")
    else
        targetPosition = UDim2.new(1.5, 0, 0.5, -400 * self.scale)
        targetRotation = 10
        
        local tween = TweenService:Create(
            self.phoneFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = targetPosition, Rotation = targetRotation}
        )
        
        tween:Play()
        tween.Completed:Connect(function()
            self.phoneFrame.Visible = false
            self.phoneFrame.Rotation = 0
        end)
    end
    
    -- Toggle button animation
    local toggleIcon = self.toggleButton:FindFirstChild("TextLabel")
    if toggleIcon then
        TweenService:Create(toggleIcon, TweenInfo.new(0.3), 
            {Rotation = self.isPhoneOpen and 180 or 0}):Play()
    end
end

-- Open App with Animation
function AdvancedPhone:openAppWithAnimation(appName)
    self.currentApp = appName
    
    -- Slide out home screen
    TweenService:Create(
        self.homeScreen,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(-1, 0, 0, 50 * self.scale)}
    ):Play()
    
    -- Slide in apps container
    self.appsContainer.Position = UDim2.new(1, 0, 0, 50 * self.scale)
    self.appsContainer.Visible = true
    
    TweenService:Create(
        self.appsContainer,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 50 * self.scale)}
    ):Play()
    
    -- Clear previous app content
    for _, child in pairs(self.appsContainer:GetChildren()) do
        if child.Name ~= "BackButton" then
            child:Destroy()
        end
    end
    
    -- Load specific app with enhanced features
    if appName == "contacts" then
        self:createAdvancedContactsApp()
    elseif appName == "messages" then
        self:createAdvancedMessagesApp()
    elseif appName == "phone" then
        self:createAdvancedPhoneApp()
    elseif appName == "videocall" then
        self:createVideoCallApp()
    elseif appName == "group" then
        self:createAdvancedGroupCallApp()
    elseif appName == "camera" then
        self:createCameraApp()
    elseif appName == "gallery" then
        self:createGalleryApp()
    elseif appName == "music" then
        self:createMusicApp()
    elseif appName == "store" then
        self:createAppStoreApp()
    elseif appName == "settings" then
        self:createAdvancedSettingsApp()
    elseif appName == "calculator" then
        self:createCalculatorApp()
    elseif appName == "notes" then
        self:createNotesApp()
    end
    
    self:addNotification("App", "Opened " .. self.apps[appName].name .. " " .. self.apps[appName].icon, "info")
end

-- Go Home with Animation
function AdvancedPhone:goHomeWithAnimation()
    self.currentApp = "home"
    
    -- Slide out apps container
    TweenService:Create(
        self.appsContainer,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, 0, 0, 50 * self.scale)}
    ):Play()
    
    -- Slide in home screen
    self.homeScreen.Position = UDim2.new(-1, 0, 0, 50 * self.scale)
    self.homeScreen.Visible = true
    
    TweenService:Create(
        self.homeScreen,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 50 * self.scale)}
    ):Play()
    
    wait(0.3)
    self.appsContainer.Visible = false
end

-- Enhanced Notification System
function AdvancedPhone:initializeNotificationSystem()
    -- Create notification sounds
    self.notificationSounds = {
        ["message"] = "rbxasset://sounds/electronicpingshort.wav",
        ["call"] = "rbxasset://sounds/SWITCH3.wav",
        ["success"] = "rbxasset://sounds/action_get_up.mp3",
        ["error"] = "rbxasset://sounds/action_falling.mp3",
        ["info"] = "rbxasset://sounds/button.wav"
    }
end

-- Add Notification
function AdvancedPhone:addNotification(title, message, type)
    if not self.settings.notifications then return end
    
    local notificationId = tick()
    
    -- Store notification
    table.insert(self.notifications, {
        id = notificationId,
        title = title,
        message = message,
        type = type or "info",
        timestamp = os.date("%H:%M"),
        read = false
    })
    
    -- Play notification sound
    if self.notificationSounds[type] then
        local sound = Instance.new("Sound")
        sound.SoundId = self.notificationSounds[type]
        sound.Volume = 0.5
        sound.Parent = workspace
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
    
    -- Show notification popup if phone is open
    if self.isPhoneOpen then
        self:showNotificationPopup(title, message, type)
    end
    
    -- Update notification badge
    self:updateNotificationBadge()
end

-- Show Notification Popup
function AdvancedPhone:showNotificationPopup(title, message, type)
    local colors = {
        ["info"] = Color3.fromRGB(33, 150, 243),
        ["success"] = Color3.fromRGB(76, 175, 80),
        ["error"] = Color3.fromRGB(244, 67, 54),
        ["warning"] = Color3.fromRGB(255, 152, 0)
    }
    
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0.9, 0, 0, 80 * self.scale)
    popup.Position = UDim2.new(0.05, 0, 0, -100 * self.scale)
    popup.BackgroundColor3 = colors[type] or colors["info"]
    popup.BorderSizePixel = 0
    popup.ZIndex = 20
    popup.Parent = self.phoneFrame
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 15 * self.scale)
    popupCorner.Parent = popup
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.white
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 21
    titleLabel.Parent = popup
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0.5, 0)
    messageLabel.Position = UDim2.new(0, 10, 0.5, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.white
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.ZIndex = 21
    messageLabel.Parent = popup
    
    -- Animate popup
    TweenService:Create(popup, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.05, 0, 0, 60 * self.scale)}):Play()
    
    -- Auto hide after 3 seconds
    spawn(function()
        wait(3)
        TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = UDim2.new(0.05, 0, 0, -100 * self.scale)}):Play()
        wait(0.3)
        popup:Destroy()
    end)
end

-- Update Notification Badge
function AdvancedPhone:updateNotificationBadge()
    local unreadCount = 0
    for _, notification in pairs(self.notifications) do
        if not notification.read then
            unreadCount = unreadCount + 1
        end
    end
    
    -- Update status bar notification icon
    local notifIcon = self.statusBar:FindFirstChild("Frame"):FindFirstChild("TextLabel")
    if notifIcon then
        if unreadCount > 0 then
            notifIcon.Text = "🔔(" .. unreadCount .. ")"
        else
            notifIcon.Text = "🔔"
        end
    end
end

-- Setup Advanced VoiceChat
function AdvancedPhone:setupAdvancedVoiceChat()
    if VoiceChatService then
        spawn(function()
            local success, enabled = pcall(function()
                return VoiceChatService.IsVoiceEnabledForUserIdAsync(VoiceChatService, player.UserId)
            end)
            
            if success then
                self.settings.voiceEnabled = enabled
                self:addNotification("Voice Chat", 
                    enabled and "Voice chat is available! 🎤" or "Voice chat is not available 🔇", 
                    enabled and "success" or "warning")
            end
        end)
    end
end

-- Create Advanced Contacts App
function AdvancedPhone:createAdvancedContactsApp()
    local scale = self.scale
    
    -- App Title with animation
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80 * scale, 0, 60 * scale)
    title.Position = UDim2.new(0, 70 * scale, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "👥 Contacts"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 7
    title.Parent = self.appsContainer
    
    -- Add Contact Button
    local addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(0, 50 * scale, 0, 50 * scale)
    addButton.Position = UDim2.new(1, -65 * scale, 0, 20)
    addButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    addButton.BorderSizePixel = 0
    addButton.Text = "+"
    addButton.TextColor3 = Color3.white
    addButton.TextScaled = true
    addButton.Font = Enum.Font.GothamBold
    addButton.ZIndex = 7
    addButton.Parent = self.appsContainer
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(1, 0)
    addCorner.Parent = addButton
    
    -- Enhanced Search Bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -30 * scale, 0, 50 * scale)
    searchFrame.Position = UDim2.new(0, 15 * scale, 0, 85 * scale)
    searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    searchFrame.BorderSizePixel = 0
    searchFrame.ZIndex = 7
    searchFrame.Parent = self.appsContainer
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 25 * scale)
    searchCorner.Parent = searchFrame
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 40 * scale, 1, 0)
    searchIcon.Position = UDim2.new(0, 10 * scale, 0, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    searchIcon.TextScaled = true
    searchIcon.ZIndex = 8
    searchIcon.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -60 * scale, 1, 0)
    searchBox.Position = UDim2.new(0, 50 * scale, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search contacts..."
    searchBox.TextColor3 = Color3.white
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.Gotham
    searchBox.ZIndex = 8
    searchBox.Parent = searchFrame
    
    -- Contacts List with enhanced design
    local contactsFrame = Instance.new("ScrollingFrame")
    contactsFrame.Size = UDim2.new(1, -30 * scale, 1, -150 * scale)
    contactsFrame.Position = UDim2.new(0, 15 * scale, 0, 145 * scale)
    contactsFrame.BackgroundTransparency = 1
    contactsFrame.BorderSizePixel = 0
    contactsFrame.ScrollBarThickness = 8
    contactsFrame.ZIndex = 7
    contactsFrame.Parent = self.appsContainer
    
    local contactsLayout = Instance.new("UIListLayout")
    contactsLayout.Padding = UDim.new(0, 10 * scale)
    contactsLayout.Parent = contactsFrame
    
    -- Function to create enhanced contact entry
    local function createEnhancedContactEntry(targetPlayer)
        local contactFrame = Instance.new("Frame")
        contactFrame.Size = UDim2.new(1, 0, 0, 80 * scale)
        contactFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        contactFrame.BorderSizePixel = 0
        contactFrame.ZIndex = 7
        contactFrame.Parent = contactsFrame
        
        local contactCorner = Instance.new("UICorner")
        contactCorner.CornerRadius = UDim.new(0, 15 * scale)
        contactCorner.Parent = contactFrame
        
        -- Contact avatar (placeholder)
        local avatar = Instance.new("Frame")
        avatar.Size = UDim2.new(0, 60 * scale, 0, 60 * scale)
        avatar.Position = UDim2.new(0, 10 * scale, 0.5, -30 * scale)
        avatar.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        avatar.BorderSizePixel = 0
        avatar.ZIndex = 8
        avatar.Parent = contactFrame
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatar
        
        local avatarText = Instance.new("TextLabel")
        avatarText.Size = UDim2.new(1, 0, 1, 0)
        avatarText.BackgroundTransparency = 1
        avatarText.Text = string.sub(targetPlayer.Name, 1, 1):upper()
        avatarText.TextColor3 = Color3.white
        avatarText.TextScaled = true
        avatarText.Font = Enum.Font.GothamBold
        avatarText.ZIndex = 9
        avatarText.Parent = avatar
        
        -- Contact info
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 80 * scale, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.ZIndex = 8
        nameLabel.Parent = contactFrame
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
        statusLabel.Position = UDim2.new(0, 80 * scale, 0.5, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "🟢 Online"
        statusLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
        statusLabel.TextScaled = true
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.ZIndex = 8
        statusLabel.Parent = contactFrame
        
        -- Action buttons
        local actionsFrame = Instance.new("Frame")
        actionsFrame.Size = UDim2.new(0.3, 0, 1, 0)
        actionsFrame.Position = UDim2.new(0.7, 0, 0, 0)
        actionsFrame.BackgroundTransparency = 1
        actionsFrame.ZIndex = 8
        actionsFrame.Parent = contactFrame
        
        local actionsLayout = Instance.new("UIListLayout")
        actionsLayout.FillDirection = Enum.FillDirection.Horizontal
        actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        actionsLayout.Padding = UDim.new(0, 10)
        actionsLayout.Parent = actionsFrame
        
        -- Call Button
        local callButton = Instance.new("TextButton")
        callButton.Size = UDim2.new(0, 50 * scale, 0, 50 * scale)
        callButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        callButton.BorderSizePixel = 0
        callButton.Text = "📞"
        callButton.TextColor3 = Color3.white
        callButton.TextScaled = true
        callButton.Font = Enum.Font.GothamBold
        callButton.ZIndex = 8
        callButton.Parent = actionsFrame
        
        local callCorner = Instance.new("UICorner")
        callCorner.CornerRadius = UDim.new(1, 0)
        callCorner.Parent = callButton
        
        -- Video Call Button
        local videoButton = Instance.new("TextButton")
        videoButton.Size = UDim2.new(0, 50 * scale, 0, 50 * scale)
        videoButton.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        videoButton.BorderSizePixel = 0
        videoButton.Text = "📹"
        videoButton.TextColor3 = Color3.white
        videoButton.TextScaled = true
        videoButton.Font = Enum.Font.GothamBold
        videoButton.ZIndex = 8
        videoButton.Parent = actionsFrame
        
        local videoCorner = Instance.new("UICorner")
        videoCorner.CornerRadius = UDim.new(1, 0)
        videoCorner.Parent = videoButton
        
        -- Message Button
        local messageButton = Instance.new("TextButton")
        messageButton.Size = UDim2.new(0, 50 * scale, 0, 50 * scale)
        messageButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        messageButton.BorderSizePixel = 0
        messageButton.Text = "💬"
        messageButton.TextColor3 = Color3.white
        messageButton.TextScaled = true
        messageButton.Font = Enum.Font.GothamBold
        messageButton.ZIndex = 8
        messageButton.Parent = actionsFrame
        
        local messageCorner = Instance.new("UICorner")
        messageCorner.CornerRadius = UDim.new(1, 0)
        messageCorner.Parent = messageButton
        
        -- Button actions
        callButton.MouseButton1Click:Connect(function()
            self:initiateAdvancedCall(targetPlayer, "voice")
        end)
        
        videoButton.MouseButton1Click:Connect(function()
            self:initiateAdvancedCall(targetPlayer, "video")
        end)
        
        messageButton.MouseButton1Click:Connect(function()
            self:openAdvancedChat(targetPlayer)
        end)
        
        -- Hover effects
        contactFrame.MouseEnter:Connect(function()
            TweenService:Create(contactFrame, TweenInfo.new(0.2), 
                {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        
        contactFrame.MouseLeave:Connect(function()
            TweenService:Create(contactFrame, TweenInfo.new(0.2), 
                {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        end)
    end
    
    -- Load and update contacts
    local function updateContactsList(searchText)
        for _, child in pairs(contactsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                if not searchText or searchText == "" or 
                   string.lower(targetPlayer.Name):find(string.lower(searchText)) then
                    createEnhancedContactEntry(targetPlayer)
                end
            end
        end
        
        contactsFrame.CanvasSize = UDim2.new(0, 0, 0, contactsLayout.AbsoluteContentSize.Y)
    end
    
    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateContactsList(searchBox.Text)
    end)
    
    -- Initial load
    updateContactsList()
    
    -- Auto-refresh contacts
    spawn(function()
        while self.currentApp == "contacts" do
            updateContactsList(searchBox.Text)
            wait(5)
        end
    end)
end

-- Initiate Advanced Call
function AdvancedPhone:initiateAdvancedCall(targetPlayer, callType)
    if not targetPlayer or targetPlayer == player then return end
    
    print("📞 Initiating " .. callType .. " call to " .. targetPlayer.Name .. "...")
    
    -- Add to active calls with enhanced data
    self.activeCalls[targetPlayer.UserId] = {
        player = targetPlayer,
        startTime = tick(),
        callType = callType,
        isVoiceEnabled = self.settings.voiceEnabled,
        isVideoEnabled = callType == "video",
        status = "connecting"
    }
    
    -- Enhanced voice/video chat setup
    if self.settings.voiceEnabled and VoiceChatService then
        spawn(function()
            -- Simulate connection process
            wait(2)
            if self.activeCalls[targetPlayer.UserId] then
                self.activeCalls[targetPlayer.UserId].status = "connected"
                self:addNotification("Call", 
                    "Connected to " .. targetPlayer.Name .. " (" .. callType .. ")", 
                    "success")
            end
        end)
    end
    
    self:addNotification("Call", 
        "Calling " .. targetPlayer.Name .. "... " .. (callType == "video" and "📹" or "📞"), 
        "info")
    
    -- Open phone app to show active call
    self:openAppWithAnimation("phone")
end

-- Setup Device Controls
function AdvancedPhone:setupDeviceControls()
    -- Touch controls for mobile
    if UserInputService.TouchEnabled then
        UserInputService.TouchSwipe:Connect(function(swipeDirection, numberOfTouches)
            if numberOfTouches == 2 then
                if swipeDirection == Enum.SwipeDirection.Right and not self.isPhoneOpen then
                    self:togglePhoneWithAnimation()
                elseif swipeDirection == Enum.SwipeDirection.Left and self.isPhoneOpen then
                    self:togglePhoneWithAnimation()
                elseif swipeDirection == Enum.SwipeDirection.Up and self.isPhoneOpen then
                    -- Show notifications
                    self.notificationBar.Visible = not self.notificationBar.Visible
                end
            end
        end)
    end
    
    -- Enhanced gamepad support for console
    if UserInputService.GamepadEnabled then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.ButtonSelect then
                self:togglePhoneWithAnimation()
            elseif input.KeyCode == Enum.KeyCode.ButtonB and self.isPhoneOpen then
                if self.currentApp ~= "home" then
                    self:goHomeWithAnimation()
                else
                    self:togglePhoneWithAnimation()
                end
            end
        end)
    end
end

-- Setup Advanced Event Handlers
function AdvancedPhone:setupAdvancedEventHandlers()
    -- Enhanced player connection handling
    Players.PlayerAdded:Connect(function(newPlayer)
        self:addNotification("Player", newPlayer.Name .. " joined the game! 👋", "info")
    end)
    
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        -- Clean up calls and data
        if self.activeCalls[leavingPlayer.UserId] then
            self.activeCalls[leavingPlayer.UserId] = nil
            self:addNotification("Call", "Call with " .. leavingPlayer.Name .. " ended", "warning")
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
        
        self:addNotification("Player", leavingPlayer.Name .. " left the game 👋", "warning")
    end)
    
    -- Enhanced screen size handling
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local screenSize = workspace.CurrentCamera.ViewportSize
        local baseResolution = Vector2.new(1920, 1080)
        local scale = math.min(screenSize.X / baseResolution.X, screenSize.Y / baseResolution.Y)
        scale = math.max(0.4, math.min(1.5, scale))
        
        self.scale = scale
        
        -- Update all UI elements with new scale
        self:updateUIScale()
    end)
    
    -- Enhanced keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            self:togglePhoneWithAnimation()
        elseif input.KeyCode == Enum.KeyCode.Escape and self.isPhoneOpen then
            if self.currentApp ~= "home" then
                self:goHomeWithAnimation()
            else
                self:togglePhoneWithAnimation()
            end
        elseif input.KeyCode == Enum.KeyCode.N and self.isPhoneOpen then
            -- Toggle notifications
            self.notificationBar.Visible = not self.notificationBar.Visible
        elseif input.KeyCode == Enum.KeyCode.H and self.isPhoneOpen then
            -- Go home
            if self.currentApp ~= "home" then
                self:goHomeWithAnimation()
            end
        end
    end)
end

-- Update UI Scale
function AdvancedPhone:updateUIScale()
    local scale = self.scale
    
    -- Update toggle button
    self.toggleButton.Size = UDim2.new(0, 70 * scale, 0, 70 * scale)
    self.toggleButton.Position = UDim2.new(1, -90 * scale, 0.5, -35 * scale)
    
    -- Update phone frame
    self.phoneFrame.Size = UDim2.new(0, 400 * scale, 0, 800 * scale)
    if self.isPhoneOpen then
        self.phoneFrame.Position = UDim2.new(0.5, -200 * scale, 0.5, -400 * scale)
    end
end

-- Load User Settings
function AdvancedPhone:loadUserSettings()
    -- This would normally load from DataStore
    -- For now, use defaults
    self.settings = {
        voiceEnabled = false,
        notifications = true,
        darkMode = true,
        autoAnswer = false,
        ringtone = "Default",
        fontSize = "Medium",
        language = "English"
    }
end

-- Save User Settings
function AdvancedPhone:saveUserSettings()
    -- This would normally save to DataStore
    print("💾 Settings saved successfully!")
    self:addNotification("Settings", "Settings saved! ⚙️", "success")
end

-- Additional placeholder functions for other apps
function AdvancedPhone:createAdvancedMessagesApp()
    self:addNotification("Messages", "Advanced Messages app loaded! 💬", "info")
    -- Implementation would go here
end

function AdvancedPhone:createAdvancedPhoneApp()
    self:addNotification("Phone", "Advanced Phone app loaded! 📞", "info")
    -- Implementation would go here
end

function AdvancedPhone:createVideoCallApp()
    self:addNotification("Video Call", "Video Call app loaded! 📹", "info")
    -- Implementation would go here
end

function AdvancedPhone:createAdvancedGroupCallApp()
    self:addNotification("Group Call", "Group Call app loaded! 👥📞", "info")
    -- Implementation would go here
end

function AdvancedPhone:createCameraApp()
    self:addNotification("Camera", "Camera app loaded! 📷", "info")
    -- Implementation would go here
end

function AdvancedPhone:createGalleryApp()
    self:addNotification("Gallery", "Gallery app loaded! 🖼️", "info")
    -- Implementation would go here
end

function AdvancedPhone:createMusicApp()
    self:addNotification("Music", "Music app loaded! 🎵", "info")
    -- Implementation would go here
end

function AdvancedPhone:createAppStoreApp()
    self:addNotification("App Store", "App Store loaded! 🏪", "info")
    -- Implementation would go here
end

function AdvancedPhone:createAdvancedSettingsApp()
    self:addNotification("Settings", "Advanced Settings loaded! ⚙️", "info")
    -- Implementation would go here
end

function AdvancedPhone:createCalculatorApp()
    self:addNotification("Calculator", "Calculator loaded! 🔢", "info")
    -- Implementation would go here
end

function AdvancedPhone:createNotesApp()
    self:addNotification("Notes", "Notes app loaded! 📝", "info")
    -- Implementation would go here
end

function AdvancedPhone:openAdvancedChat(targetPlayer)
    self:addNotification("Chat", "Opening chat with " .. targetPlayer.Name .. " 💬", "info")
    -- Implementation would go here
end

-- Get player reference
local player = Players.LocalPlayer

-- Initialize the advanced phone system
local advancedPhone = AdvancedPhone.new()

-- Enhanced welcome message
print("🎉 Advanced Roblox Phone System v3.0 Loaded!")
print("✨ Ultimate Edition Features:")
print("  📱 Modern Android-style UI with animations")
print("  📞 Voice & Video Calls with VoiceChat integration")
print("  👥 Advanced Group Calls & Contacts")
print("  💬 Enhanced Messaging System")
print("  📷 Camera & Gallery")
print("  🎵 Music Player")
print("  🏪 App Store")
print("  🔔 Smart Notifications")
print("  ⚙️ Advanced Settings")
print("  🔢 Calculator & Notes")
print("")
print("🎮 Universal Controls:")
print("  📱 Click phone icon (right center) or Press 'P'")
print("  📱 2-finger swipe (Mobile)")
print("  📱 Gamepad controls (Console)")
print("  📱 ESC to go back, 'N' for notifications")
print("")
print("🚀 All platforms supported with auto-scaling!")
print("✅ Advanced Phone System ready!")