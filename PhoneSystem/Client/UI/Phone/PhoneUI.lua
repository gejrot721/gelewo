-- PhoneUI.lua
-- Main phone UI component dengan Android-style design

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PhoneConfig = require(script.Parent.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Parent.Shared.PhoneTypes)
local UIScale = require(script.Parent.Parent.Parent.Shared.Utils.UIScale)

local PhoneUI = {}

-- Create main phone frame
function PhoneUI.createPhoneFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PhoneSystem"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Main phone frame
    local phoneFrame = Instance.new("Frame")
    phoneFrame.Name = "PhoneFrame"
    phoneFrame.BackgroundColor3 = PhoneConfig.UI.COLORS.BACKGROUND
    phoneFrame.BorderSizePixel = 0
    phoneFrame.ClipsDescendants = true
    phoneFrame.Parent = screenGui
    
    -- Apply responsive scaling
    local scale, deviceType = UIScale.calculateScale()
    phoneFrame.Size = UDim2.new(0, PhoneConfig.UI.PHONE_WIDTH * scale, 0, PhoneConfig.UI.PHONE_HEIGHT * scale)
    phoneFrame.Position = UDim2.new(0.5, -PhoneConfig.UI.PHONE_WIDTH * scale / 2, 0.5, -PhoneConfig.UI.PHONE_HEIGHT * scale / 2)
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20 * scale)
    corner.Parent = phoneFrame
    
    -- Add drop shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.Size = UDim2.new(1, 10 * scale, 1, 10 * scale)
    shadow.Position = UDim2.new(0, -5 * scale, 0, -5 * scale)
    shadow.ZIndex = phoneFrame.ZIndex - 1
    shadow.Parent = phoneFrame.Parent
    
    -- Add shadow corner
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 25 * scale)
    shadowCorner.Parent = shadow
    
    -- Create phone structure
    PhoneUI.createStatusBar(phoneFrame, scale, deviceType)
    PhoneUI.createHomeScreen(phoneFrame, scale, deviceType)
    PhoneUI.createNavigationBar(phoneFrame, scale, deviceType)
    
    -- Initially hidden
    phoneFrame.Visible = false
    
    return phoneFrame, screenGui
end

-- Create status bar (Android style)
function PhoneUI.createStatusBar(parent, scale, deviceType)
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.BackgroundColor3 = PhoneConfig.UI.COLORS.STATUS_BAR
    statusBar.BorderSizePixel = 0
    statusBar.Size = UDim2.new(1, 0, 0, 24 * scale)
    statusBar.Position = UDim2.new(0, 0, 0, 0)
    statusBar.Parent = parent
    
    -- Status bar corner (top only)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20 * scale)
    corner.Parent = statusBar
    
    -- Time display
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "12:34"
    timeLabel.TextColor3 = PhoneConfig.UI.COLORS.STATUS_BAR_TEXT
    timeLabel.TextScaled = true
    timeLabel.Font = PhoneConfig.UI.FONTS.BODY
    timeLabel.TextSize = UIScale.getFontSize(12, deviceType)
    timeLabel.Size = UDim2.new(0, 60 * scale, 1, 0)
    timeLabel.Position = UDim2.new(0, 16 * scale, 0, 0)
    timeLabel.Parent = statusBar
    
    -- Battery indicator
    local batteryFrame = Instance.new("Frame")
    batteryFrame.Name = "BatteryFrame"
    batteryFrame.BackgroundColor3 = PhoneConfig.UI.COLORS.STATUS_BAR_TEXT
    batteryFrame.BorderSizePixel = 0
    batteryFrame.Size = UDim2.new(0, 24 * scale, 0, 12 * scale)
    batteryFrame.Position = UDim2.new(1, -40 * scale, 0.5, -6 * scale)
    batteryFrame.Parent = statusBar
    
    local batteryCorner = Instance.new("UICorner")
    batteryCorner.CornerRadius = UDim.new(0, 2 * scale)
    batteryCorner.Parent = batteryFrame
    
    -- Battery level
    local batteryLevel = Instance.new("Frame")
    batteryLevel.Name = "BatteryLevel"
    batteryLevel.BackgroundColor3 = PhoneConfig.UI.COLORS.SUCCESS
    batteryLevel.BorderSizePixel = 0
    batteryLevel.Size = UDim2.new(0.8, 0, 1, 0)
    batteryLevel.Position = UDim2.new(0, 0, 0, 0)
    batteryLevel.Parent = batteryFrame
    
    local batteryLevelCorner = Instance.new("UICorner")
    batteryLevelCorner.CornerRadius = UDim.new(0, 2 * scale)
    batteryLevelCorner.Parent = batteryLevel
    
    -- Signal strength
    local signalFrame = Instance.new("Frame")
    signalFrame.Name = "SignalFrame"
    signalFrame.BackgroundTransparency = 1
    signalFrame.Size = UDim2.new(0, 20 * scale, 1, 0)
    signalFrame.Position = UDim2.new(1, -65 * scale, 0, 0)
    signalFrame.Parent = statusBar
    
    -- Create signal bars
    for i = 1, 4 do
        local bar = Instance.new("Frame")
        bar.Name = "Bar" .. i
        bar.BackgroundColor3 = PhoneConfig.UI.COLORS.STATUS_BAR_TEXT
        bar.BorderSizePixel = 0
        bar.Size = UDim2.new(0, 2 * scale, i / 4, -2 * scale)
        bar.Position = UDim2.new((i - 1) * 0.25, 0, 1 - i / 4, 1 * scale)
        bar.Parent = signalFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 1 * scale)
        barCorner.Parent = bar
    end
end

-- Create home screen with app icons
function PhoneUI.createHomeScreen(parent, scale, deviceType)
    local homeScreen = Instance.new("Frame")
    homeScreen.Name = "HomeScreen"
    homeScreen.BackgroundTransparency = 1
    homeScreen.Size = UDim2.new(1, 0, 1, -48 * scale) -- Account for status bar
    homeScreen.Position = UDim2.new(0, 0, 0, 24 * scale)
    homeScreen.Parent = parent
    
    -- App grid container
    local appGrid = Instance.new("Frame")
    appGrid.Name = "AppGrid"
    appGrid.BackgroundTransparency = 1
    appGrid.Size = UDim2.new(1, -32 * scale, 1, -100 * scale)
    appGrid.Position = UDim2.new(0, 16 * scale, 0, 80 * scale)
    appGrid.Parent = homeScreen
    
    -- Create app icons
    PhoneUI.createAppIcon(appGrid, "Contacts", "📞", UDim2.new(0, 0, 0, 0), scale, deviceType)
    PhoneUI.createAppIcon(appGrid, "Chat", "💬", UDim2.new(0.33, 0, 0, 0), scale, deviceType)
    PhoneUI.createAppIcon(appGrid, "Calls", "📱", UDim2.new(0.66, 0, 0, 0), scale, deviceType)
    PhoneUI.createAppIcon(appGrid, "Settings", "⚙️", UDim2.new(0, 0, 0.33, 0), scale, deviceType)
    PhoneUI.createAppIcon(appGrid, "Group", "👥", UDim2.new(0.33, 0, 0.33, 0), scale, deviceType)
    PhoneUI.createAppIcon(appGrid, "History", "📋", UDim2.new(0.66, 0, 0.33, 0), scale, deviceType)
end

-- Create app icon
function PhoneUI.createAppIcon(parent, name, icon, position, scale, deviceType)
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = name .. "Icon"
    iconFrame.BackgroundTransparency = 1
    iconFrame.Size = UDim2.new(0.3, -8 * scale, 0.3, -8 * scale)
    iconFrame.Position = position
    iconFrame.Parent = parent
    
    -- Icon background
    local iconBg = Instance.new("Frame")
    iconBg.Name = "IconBg"
    iconBg.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    iconBg.BorderSizePixel = 0
    iconBg.Size = UDim2.new(1, 0, 0.7, 0)
    iconBg.Position = UDim2.new(0, 0, 0, 0)
    iconBg.Parent = iconFrame
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 12 * scale)
    iconCorner.Parent = iconBg
    
    -- Add subtle shadow
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.9
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 2 * scale, 0, 2 * scale)
    shadow.ZIndex = iconBg.ZIndex - 1
    shadow.Parent = iconBg
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12 * scale)
    shadowCorner.Parent = shadow
    
    -- Icon text
    local iconText = Instance.new("TextLabel")
    iconText.Name = "IconText"
    iconText.BackgroundTransparency = 1
    iconText.Text = icon
    iconText.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    iconText.TextScaled = true
    iconText.Font = PhoneConfig.UI.FONTS.BODY
    iconText.TextSize = UIScale.getFontSize(24, deviceType)
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.Position = UDim2.new(0, 0, 0, 0)
    iconText.Parent = iconBg
    
    -- App name
    local appName = Instance.new("TextLabel")
    appName.Name = "AppName"
    appName.BackgroundTransparency = 1
    appName.Text = name
    appName.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    appName.TextScaled = true
    appName.Font = PhoneConfig.UI.FONTS.BODY
    appName.TextSize = UIScale.getFontSize(10, deviceType)
    appName.Size = UDim2.new(1, 0, 0.3, 0)
    appName.Position = UDim2.new(0, 0, 0.7, 0)
    appName.Parent = iconFrame
    
    -- Make clickable
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.Parent = iconFrame
    
    -- Add click effect
    button.MouseButton1Click:Connect(function()
        PhoneUI.animateIconClick(iconBg, scale)
        -- Trigger app opening
        PhoneUI.openApp(name)
    end)
    
    return iconFrame
end

-- Create navigation bar (Android style)
function PhoneUI.createNavigationBar(parent, scale, deviceType)
    local navBar = Instance.new("Frame")
    navBar.Name = "NavigationBar"
    navBar.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    navBar.BorderSizePixel = 0
    navBar.Size = UDim2.new(1, 0, 0, 56 * scale)
    navBar.Position = UDim2.new(0, 0, 1, -56 * scale)
    navBar.Parent = parent
    
    -- Navigation bar corner (bottom only)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20 * scale)
    corner.Parent = navBar
    
    -- Home button
    local homeButton = Instance.new("TextButton")
    homeButton.Name = "HomeButton"
    homeButton.BackgroundTransparency = 1
    homeButton.Text = "🏠"
    homeButton.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    homeButton.TextScaled = true
    homeButton.Font = PhoneConfig.UI.FONTS.BODY
    homeButton.TextSize = UIScale.getFontSize(20, deviceType)
    homeButton.Size = UDim2.new(0, 56 * scale, 0, 56 * scale)
    homeButton.Position = UDim2.new(0, 0, 0, 0)
    homeButton.Parent = navBar
    
    -- Back button
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.BackgroundTransparency = 1
    backButton.Text = "◀"
    backButton.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    backButton.TextScaled = true
    backButton.Font = PhoneConfig.UI.FONTS.BODY
    backButton.TextSize = UIScale.getFontSize(20, deviceType)
    backButton.Size = UDim2.new(0, 56 * scale, 0, 56 * scale)
    backButton.Position = UDim2.new(1, -56 * scale, 0, 0)
    backButton.Parent = navBar
    
    -- Recent apps button
    local recentButton = Instance.new("TextButton")
    recentButton.Name = "RecentButton"
    recentButton.BackgroundTransparency = 1
    recentButton.Text = "⏸"
    recentButton.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    recentButton.TextScaled = true
    recentButton.Font = PhoneConfig.UI.FONTS.BODY
    recentButton.TextSize = UIScale.getFontSize(20, deviceType)
    recentButton.Size = UDim2.new(0, 56 * scale, 0, 56 * scale)
    recentButton.Position = UDim2.new(0.5, -28 * scale, 0, 0)
    recentButton.Parent = navBar
    
    -- Add button click effects
    homeButton.MouseButton1Click:Connect(function()
        PhoneUI.goToHomeScreen()
    end)
    
    backButton.MouseButton1Click:Connect(function()
        PhoneUI.goBack()
    end)
    
    recentButton.MouseButton1Click:Connect(function()
        PhoneUI.showRecentApps()
    end)
end

-- Animation functions
function PhoneUI.animateIconClick(icon, scale)
    local originalSize = icon.Size
    local pressedSize = UDim2.new(
        originalSize.X.Scale * 0.95,
        originalSize.X.Offset * 0.95,
        originalSize.Y.Scale * 0.95,
        originalSize.Y.Offset * 0.95
    )
    
    local pressTween = TweenService:Create(
        icon,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = pressedSize}
    )
    
    local releaseTween = TweenService:Create(
        icon,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = originalSize}
    )
    
    pressTween:Play()
    pressTween.Completed:Connect(function()
        releaseTween:Play()
    end)
end

-- App navigation functions
function PhoneUI.openApp(appName)
    print("Opening app:", appName)
    -- This will be handled by the PhoneController
end

function PhoneUI.goToHomeScreen()
    print("Going to home screen")
    -- This will be handled by the PhoneController
end

function PhoneUI.goBack()
    print("Going back")
    -- This will be handled by the PhoneController
end

function PhoneUI.showRecentApps()
    print("Showing recent apps")
    -- This will be handled by the PhoneController
end

-- Show/hide phone
function PhoneUI.showPhone(phoneFrame)
    phoneFrame.Visible = true
    phoneFrame.Size = UDim2.new(0, 0, 0, 0)
    
    local scale, deviceType = UIScale.calculateScale()
    local targetSize = UDim2.new(0, PhoneConfig.UI.PHONE_WIDTH * scale, 0, PhoneConfig.UI.PHONE_HEIGHT * scale)
    
    local tween = TweenService:Create(
        phoneFrame,
        TweenInfo.new(PhoneConfig.UI.ANIMATION_SPEED, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    
    tween:Play()
end

function PhoneUI.hidePhone(phoneFrame)
    local scale, deviceType = UIScale.calculateScale()
    local targetSize = UDim2.new(0, 0, 0, 0)
    
    local tween = TweenService:Create(
        phoneFrame,
        TweenInfo.new(PhoneConfig.UI.ANIMATION_SPEED, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = targetSize}
    )
    
    tween:Play()
    tween.Completed:Connect(function()
        phoneFrame.Visible = false
    end)
end

return PhoneUI