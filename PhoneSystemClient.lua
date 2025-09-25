-- 📱 PHONE SYSTEM CLIENT SCRIPT
-- Handles client-side phone GUI, interactions, and server communication
-- Place this script in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for RemoteEvents
local PhoneEvents = ReplicatedStorage:WaitForChild("PhoneEvents")
local PhoneToggleEvent = PhoneEvents:WaitForChild("PhoneToggle")
local PhoneUnlockEvent = PhoneEvents:WaitForChild("PhoneUnlock")
local PhoneCallEvent = PhoneEvents:WaitForChild("PhoneCall")
local PhoneMessageEvent = PhoneEvents:WaitForChild("PhoneMessage")
local PhoneAppEvent = PhoneEvents:WaitForChild("PhoneApp")
local PhoneSettingsEvent = PhoneEvents:WaitForChild("PhoneSettings")

-- Get player
local player = Players.LocalPlayer

-- Phone Client Class
local PhoneClient = {}
PhoneClient.__index = PhoneClient

function PhoneClient.new()
    local self = setmetatable({}, PhoneClient)
    
    -- Client state
    self.isPhoneOpen = false
    self.isLocked = true
    self.currentApp = "lockscreen"
    self.enteredPasscode = ""
    self.scale = 1
    
    -- UI Elements
    self.screenGui = nil
    self.phoneFrame = nil
    self.toggleButton = nil
    self.lockScreen = nil
    self.homeScreen = nil
    self.statusBar = nil
    
    -- Initialize
    self:createGUI()
    self:setupEventHandlers()
    self:setupControls()
    
    return self
end

-- Create GUI
function PhoneClient:createGUI()
    -- Main ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PhoneSystemClient"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.DisplayOrder = 100
    self.screenGui.Parent = player.PlayerGui
    
    -- Calculate scale
    local screenSize = workspace.CurrentCamera.ViewportSize
    self.scale = math.min(screenSize.X / 1920, screenSize.Y / 1080)
    self.scale = math.max(0.4, math.min(1.5, self.scale))
    
    -- Create toggle button in right center
    self:createToggleButton()
    
    -- Create phone frame
    self:createPhoneFrame()
    
    print("📱 Phone Client GUI created successfully!")
end

-- Create Toggle Button (RIGHT CENTER)
function PhoneClient:createToggleButton()
    -- Main toggle container
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(0, 120 * self.scale, 0, 120 * self.scale)
    toggleContainer.Position = UDim2.new(1, -140 * self.scale, 0.5, -60 * self.scale)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.ZIndex = 1000
    toggleContainer.Parent = self.screenGui
    
    -- Background glow
    local glowBackground = Instance.new("Frame")
    glowBackground.Size = UDim2.new(1, 20, 1, 20)
    glowBackground.Position = UDim2.new(0, -10, 0, -10)
    glowBackground.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    glowBackground.BackgroundTransparency = 0.8
    glowBackground.BorderSizePixel = 0
    glowBackground.ZIndex = 999
    glowBackground.Parent = toggleContainer
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glowBackground
    
    -- Main toggle button
    self.toggleButton = Instance.new("TextButton")
    self.toggleButton.Name = "PhoneToggle"
    self.toggleButton.Size = UDim2.new(0, 100 * self.scale, 0, 100 * self.scale)
    self.toggleButton.Position = UDim2.new(0.5, -50 * self.scale, 0.5, -50 * self.scale)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
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
    
    -- Button shadow
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 1000
    shadow.Parent = self.toggleButton
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = shadow
    
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
    statusText.Size = UDim2.new(1, 0, 0, 25 * self.scale)
    statusText.Position = UDim2.new(0, 0, 1, 10 * self.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = "PHONE CLOSED"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.GothamBold
    statusText.ZIndex = 1001
    statusText.Parent = toggleContainer
    
    -- Instructions text
    local instructionsText = Instance.new("TextLabel")
    instructionsText.Size = UDim2.new(1.5, 0, 0, 20 * self.scale)
    instructionsText.Position = UDim2.new(-0.25, 0, 1, 40 * self.scale)
    instructionsText.BackgroundTransparency = 1
    instructionsText.Text = "Click to Open/Close Phone"
    instructionsText.TextColor3 = Color3.fromRGB(200, 200, 200)
    instructionsText.TextScaled = true
    instructionsText.Font = Enum.Font.Gotham
    instructionsText.ZIndex = 1001
    instructionsText.Parent = toggleContainer
    
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
            {Size = UDim2.new(0, 110 * self.scale, 0, 110 * self.scale)}):Play()
        TweenService:Create(glowBackground, TweenInfo.new(0.3), 
            {BackgroundTransparency = 0.6}):Play()
    end)
    
    self.toggleButton.MouseLeave:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), 
            {Size = UDim2.new(0, 100 * self.scale, 0, 100 * self.scale)}):Play()
        TweenService:Create(glowBackground, TweenInfo.new(0.3), 
            {BackgroundTransparency = 0.8}):Play()
    end)
    
    -- Press effects
    self.toggleButton.MouseButton1Down:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.1), 
            {Size = UDim2.new(0, 95 * self.scale, 0, 95 * self.scale)}):Play()
    end)
    
    self.toggleButton.MouseButton1Up:Connect(function()
        TweenService:Create(self.toggleButton, TweenInfo.new(0.1), 
            {Size = UDim2.new(0, 100 * self.scale, 0, 100 * self.scale)}):Play()
    end)
    
    -- Pulsing animation to make it more visible
    spawn(function()
        while self.toggleButton and self.toggleButton.Parent do
            TweenService:Create(self.toggleButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Size = UDim2.new(0, 105 * self.scale, 0, 105 * self.scale)}):Play()
            wait(1.5)
            TweenService:Create(self.toggleButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Size = UDim2.new(0, 100 * self.scale, 0, 100 * self.scale)}):Play()
            wait(1.5)
        end
    end)
end

-- Create Phone Frame
function PhoneClient:createPhoneFrame()
    local phoneWidth = 400 * self.scale
    local phoneHeight = 800 * self.scale
    
    -- Main phone frame
    self.phoneFrame = Instance.new("Frame")
    self.phoneFrame.Name = "PhoneFrame"
    self.phoneFrame.Size = UDim2.new(0, phoneWidth, 0, phoneHeight)
    self.phoneFrame.Position = UDim2.new(0.5, -phoneWidth/2, 0.5, -phoneHeight/2)
    self.phoneFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    self.phoneFrame.BorderSizePixel = 0
    self.phoneFrame.Visible = false
    self.phoneFrame.ZIndex = 5
    self.phoneFrame.Parent = self.screenGui
    
    -- Phone corners
    local phoneCorner = Instance.new("UICorner")
    phoneCorner.CornerRadius = UDim.new(0, 35 * self.scale)
    phoneCorner.Parent = self.phoneFrame
    
    -- Screen area
    local screenArea = Instance.new("Frame")
    screenArea.Name = "ScreenArea"
    screenArea.Size = UDim2.new(1, -20 * self.scale, 1, -40 * self.scale)
    screenArea.Position = UDim2.new(0, 10 * self.scale, 0, 20 * self.scale)
    screenArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    screenArea.BorderSizePixel = 0
    screenArea.ZIndex = 6
    screenArea.Parent = self.phoneFrame
    
    local screenCorner = Instance.new("UICorner")
    screenCorner.CornerRadius = UDim.new(0, 25 * self.scale)
    screenCorner.Parent = screenArea
    
    -- Create lock screen
    self:createLockScreen(screenArea)
    
    -- Create home screen
    self:createHomeScreen(screenArea)
    
    -- Create status bar
    self:createStatusBar(screenArea)
end

-- Create Lock Screen
function PhoneClient:createLockScreen(parent)
    self.lockScreen = Instance.new("Frame")
    self.lockScreen.Name = "LockScreen"
    self.lockScreen.Size = UDim2.new(1, 0, 1, 0)
    self.lockScreen.Position = UDim2.new(0, 0, 0, 0)
    self.lockScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.lockScreen.BorderSizePixel = 0
    self.lockScreen.ZIndex = 7
    self.lockScreen.Visible = true
    self.lockScreen.Parent = parent
    
    -- Wallpaper
    local wallpaper = Instance.new("ImageLabel")
    wallpaper.Size = UDim2.new(1, 0, 1, 0)
    wallpaper.BackgroundTransparency = 1
    wallpaper.Image = "rbxasset://textures/sky/sky512_hr_ft.jpg"
    wallpaper.ScaleType = Enum.ScaleType.Crop
    wallpaper.ZIndex = 7
    wallpaper.Parent = self.lockScreen
    
    -- Time display
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, 0, 0, 100 * self.scale)
    timeLabel.Position = UDim2.new(0, 0, 0, 150 * self.scale)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.ZIndex = 8
    timeLabel.Parent = self.lockScreen
    
    -- Date display
    local dateLabel = Instance.new("TextLabel")
    dateLabel.Size = UDim2.new(1, 0, 0, 40 * self.scale)
    dateLabel.Position = UDim2.new(0, 0, 0, 250 * self.scale)
    dateLabel.BackgroundTransparency = 1
    dateLabel.Text = os.date("%A, %B %d")
    dateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dateLabel.TextScaled = true
    dateLabel.Font = Enum.Font.Gotham
    dateLabel.ZIndex = 8
    dateLabel.Parent = self.lockScreen
    
    -- Unlock interface
    self:createUnlockInterface(self.lockScreen)
    
    -- Update time
    spawn(function()
        while true do
            timeLabel.Text = os.date("%H:%M")
            dateLabel.Text = os.date("%A, %B %d")
            wait(1)
        end
    end)
end

-- Create Unlock Interface
function PhoneClient:createUnlockInterface(parent)
    -- Passcode frame
    local passcodeFrame = Instance.new("Frame")
    passcodeFrame.Name = "PasscodeFrame"
    passcodeFrame.Size = UDim2.new(0.9, 0, 0, 400 * self.scale)
    passcodeFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
    passcodeFrame.BackgroundTransparency = 1
    passcodeFrame.ZIndex = 8
    passcodeFrame.Parent = parent
    
    -- Passcode title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40 * self.scale)
    title.BackgroundTransparency = 1
    title.Text = "Enter Passcode"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.Gotham
    title.ZIndex = 8
    title.Parent = passcodeFrame
    
    -- Passcode dots
    local dotsFrame = Instance.new("Frame")
    dotsFrame.Size = UDim2.new(0, 140 * self.scale, 0, 20 * self.scale)
    dotsFrame.Position = UDim2.new(0.5, -70 * self.scale, 0, 60 * self.scale)
    dotsFrame.BackgroundTransparency = 1
    dotsFrame.ZIndex = 8
    dotsFrame.Parent = passcodeFrame
    
    local dotsLayout = Instance.new("UIListLayout")
    dotsLayout.FillDirection = Enum.FillDirection.Horizontal
    dotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    dotsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    dotsLayout.Padding = UDim.new(0, 20 * self.scale)
    dotsLayout.Parent = dotsFrame
    
    self.passcodeDots = {}
    for i = 1, 4 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 15 * self.scale, 0, 15 * self.scale)
        dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        dot.BorderSizePixel = 0
        dot.ZIndex = 8
        dot.Parent = dotsFrame
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        table.insert(self.passcodeDots, dot)
    end
    
    -- Number pad
    local numberPad = Instance.new("Frame")
    numberPad.Size = UDim2.new(1, 0, 0, 300 * self.scale)
    numberPad.Position = UDim2.new(0, 0, 0, 100 * self.scale)
    numberPad.BackgroundTransparency = 1
    numberPad.ZIndex = 8
    numberPad.Parent = passcodeFrame
    
    local padLayout = Instance.new("UIGridLayout")
    padLayout.CellSize = UDim2.new(0, 80 * self.scale, 0, 80 * self.scale)
    padLayout.CellPadding = UDim2.new(0, 10 * self.scale, 0, 10 * self.scale)
    padLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    padLayout.Parent = numberPad
    
    -- Create number buttons
    local numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"}
    
    for i, number in ipairs(numbers) do
        local button = Instance.new("TextButton")
        button.BackgroundColor3 = number == "" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(60, 60, 60)
        button.BackgroundTransparency = number == "" and 1 or 0.2
        button.BorderSizePixel = 0
        button.Text = number
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.ZIndex = 8
        button.Parent = numberPad
        
        if number ~= "" then
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(1, 0)
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                self:handlePasscodeInput(number)
            end)
        end
    end
end

-- Handle Passcode Input
function PhoneClient:handlePasscodeInput(input)
    if input == "⌫" then
        if #self.enteredPasscode > 0 then
            self.enteredPasscode = string.sub(self.enteredPasscode, 1, -2)
            self:updatePasscodeDots()
        end
    elseif #self.enteredPasscode < 4 then
        self.enteredPasscode = self.enteredPasscode .. input
        self:updatePasscodeDots()
        
        if #self.enteredPasscode == 4 then
            self:attemptUnlock()
        end
    end
end

-- Update Passcode Dots
function PhoneClient:updatePasscodeDots()
    for i, dot in ipairs(self.passcodeDots) do
        if i <= #self.enteredPasscode then
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end

-- Attempt Unlock
function PhoneClient:attemptUnlock()
    PhoneUnlockEvent:FireServer(self.enteredPasscode)
end

-- Create Home Screen
function PhoneClient:createHomeScreen(parent)
    self.homeScreen = Instance.new("ScrollingFrame")
    self.homeScreen.Name = "HomeScreen"
    self.homeScreen.Size = UDim2.new(1, 0, 1, -60 * self.scale)
    self.homeScreen.Position = UDim2.new(0, 0, 0, 40 * self.scale)
    self.homeScreen.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.homeScreen.BorderSizePixel = 0
    self.homeScreen.ScrollBarThickness = 0
    self.homeScreen.Visible = false
    self.homeScreen.ZIndex = 7
    self.homeScreen.Parent = parent
    
    -- Apps grid
    local appsGrid = Instance.new("UIGridLayout")
    appsGrid.CellSize = UDim2.new(0, 80 * self.scale, 0, 100 * self.scale)
    appsGrid.CellPadding = UDim2.new(0, 20 * self.scale, 0, 15 * self.scale)
    appsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    appsGrid.Parent = self.homeScreen
    
    -- Create app icons
    local apps = {
        {icon = "📞", name = "Phone", color = Color3.fromRGB(76, 217, 100)},
        {icon = "💬", name = "Messages", color = Color3.fromRGB(52, 199, 89)},
        {icon = "📧", name = "Mail", color = Color3.fromRGB(10, 132, 255)},
        {icon = "🧭", name = "Safari", color = Color3.fromRGB(0, 122, 255)},
        {icon = "🎵", name = "Music", color = Color3.fromRGB(250, 45, 85)},
        {icon = "📷", name = "Camera", color = Color3.fromRGB(102, 102, 102)},
        {icon = "🖼️", name = "Photos", color = Color3.fromRGB(255, 149, 0)},
        {icon = "⏰", name = "Clock", color = Color3.fromRGB(0, 0, 0)},
        {icon = "🌤️", name = "Weather", color = Color3.fromRGB(30, 144, 255)},
        {icon = "📝", name = "Notes", color = Color3.fromRGB(255, 204, 0)},
        {icon = "✅", name = "Reminders", color = Color3.fromRGB(255, 59, 48)},
        {icon = "📅", name = "Calendar", color = Color3.fromRGB(255, 45, 85)},
        {icon = "🔢", name = "Calculator", color = Color3.fromRGB(0, 0, 0)},
        {icon = "⚙️", name = "Settings", color = Color3.fromRGB(142, 142, 147)},
        {icon = "🏪", name = "App Store", color = Color3.fromRGB(10, 132, 255)},
        {icon = "📹", name = "FaceTime", color = Color3.fromRGB(52, 199, 89)}
    }
    
    for _, appData in ipairs(apps) do
        self:createAppIcon(appData)
    end
end

-- Create App Icon
function PhoneClient:createAppIcon(appData)
    local appButton = Instance.new("TextButton")
    appButton.BackgroundColor3 = appData.color
    appButton.BorderSizePixel = 0
    appButton.Text = ""
    appButton.ZIndex = 8
    appButton.Parent = self.homeScreen
    
    local appCorner = Instance.new("UICorner")
    appCorner.CornerRadius = UDim.new(0, 15 * self.scale)
    appCorner.Parent = appButton
    
    local appIcon = Instance.new("TextLabel")
    appIcon.Size = UDim2.new(1, 0, 0.7, 0)
    appIcon.BackgroundTransparency = 1
    appIcon.Text = appData.icon
    appIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    appIcon.TextScaled = true
    appIcon.Font = Enum.Font.GothamBold
    appIcon.ZIndex = 9
    appIcon.Parent = appButton
    
    local appLabel = Instance.new("TextLabel")
    appLabel.Size = UDim2.new(1, 0, 0.3, 0)
    appLabel.Position = UDim2.new(0, 0, 0.7, 0)
    appLabel.BackgroundTransparency = 1
    appLabel.Text = appData.name
    appLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    appLabel.TextScaled = true
    appLabel.Font = Enum.Font.Gotham
    appLabel.ZIndex = 9
    appLabel.Parent = appButton
    
    appButton.MouseButton1Click:Connect(function()
        PhoneAppEvent:FireServer(appData.name:lower(), "open")
    end)
end

-- Create Status Bar
function PhoneClient:createStatusBar(parent)
    self.statusBar = Instance.new("Frame")
    self.statusBar.Name = "StatusBar"
    self.statusBar.Size = UDim2.new(1, 0, 0, 40 * self.scale)
    self.statusBar.BackgroundTransparency = 1
    self.statusBar.ZIndex = 10
    self.statusBar.Parent = parent
    
    -- Time
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.3, 0, 1, 0)
    timeLabel.Position = UDim2.new(0, 15, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.ZIndex = 11
    timeLabel.Parent = self.statusBar
    
    -- Battery and signal
    local iconsFrame = Instance.new("Frame")
    iconsFrame.Size = UDim2.new(0.3, 0, 1, 0)
    iconsFrame.Position = UDim2.new(0.7, 0, 0, 0)
    iconsFrame.BackgroundTransparency = 1
    iconsFrame.ZIndex = 11
    iconsFrame.Parent = self.statusBar
    
    local iconsLayout = Instance.new("UIListLayout")
    iconsLayout.FillDirection = Enum.FillDirection.Horizontal
    iconsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    iconsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    iconsLayout.Padding = UDim.new(0, 5)
    iconsLayout.Parent = iconsFrame
    
    local batteryIcon = Instance.new("TextLabel")
    batteryIcon.Size = UDim2.new(0, 25 * self.scale, 1, 0)
    batteryIcon.BackgroundTransparency = 1
    batteryIcon.Text = "🔋"
    batteryIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    batteryIcon.TextScaled = true
    batteryIcon.ZIndex = 11
    batteryIcon.Parent = iconsFrame
    
    local signalIcon = Instance.new("TextLabel")
    signalIcon.Size = UDim2.new(0, 25 * self.scale, 1, 0)
    signalIcon.BackgroundTransparency = 1
    signalIcon.Text = "📶"
    signalIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    signalIcon.TextScaled = true
    signalIcon.ZIndex = 11
    signalIcon.Parent = iconsFrame
    
    -- Update time
    spawn(function()
        while true do
            timeLabel.Text = os.date("%H:%M")
            wait(1)
        end
    end)
end

-- Setup Event Handlers
function PhoneClient:setupEventHandlers()
    -- Phone toggle response
    PhoneToggleEvent.OnClientEvent:Connect(function(isOpen)
        self.isPhoneOpen = isOpen
        self:updateToggleStatus()
    end)
    
    -- Phone unlock response
    PhoneUnlockEvent.OnClientEvent:Connect(function(success)
        if success then
            self:unlockPhone()
        else
            self:shakePasscode()
            self.enteredPasscode = ""
            self:updatePasscodeDots()
        end
    end)
    
    -- Call events
    PhoneCallEvent.OnClientEvent:Connect(function(action, ...)
        if action == "incoming_call" then
            self:showIncomingCall(...)
        elseif action == "call_initiated" then
            self:showOutgoingCall(...)
        end
    end)
    
    -- Message events
    PhoneMessageEvent.OnClientEvent:Connect(function(action, ...)
        if action == "new_message" then
            self:showNewMessage(...)
        elseif action == "notification" then
            self:showNotification(...)
        end
    end)
end

-- Setup Controls
function PhoneClient:setupControls()
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
function PhoneClient:togglePhone()
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
function PhoneClient:updateToggleStatus()
    if self.statusDot and self.statusText then
        if self.isPhoneOpen then
            self.statusDot.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
            self.statusText.Text = "PHONE OPEN"
            self.statusText.TextColor3 = Color3.fromRGB(52, 199, 89)
        else
            self.statusDot.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
            self.statusText.Text = "PHONE CLOSED"
            self.statusText.TextColor3 = Color3.fromRGB(255, 59, 48)
        end
    end
end

-- Unlock Phone
function PhoneClient:unlockPhone()
    self.isLocked = false
    self.lockScreen.Visible = false
    self.homeScreen.Visible = true
    self.currentApp = "home"
end

-- Shake Passcode
function PhoneClient:shakePasscode()
    local passcodeFrame = self.lockScreen:FindFirstChild("PasscodeFrame")
    if passcodeFrame then
        for i = 1, 3 do
            TweenService:Create(passcodeFrame, TweenInfo.new(0.1), 
                {Position = UDim2.new(0.07, 0, 0.6, 0)}):Play()
            wait(0.1)
            TweenService:Create(passcodeFrame, TweenInfo.new(0.1), 
                {Position = UDim2.new(0.03, 0, 0.6, 0)}):Play()
            wait(0.1)
        end
        TweenService:Create(passcodeFrame, TweenInfo.new(0.1), 
            {Position = UDim2.new(0.05, 0, 0.6, 0)}):Play()
    end
end

-- Show Incoming Call
function PhoneClient:showIncomingCall(callId, callerName, callType)
    print("📞 Incoming " .. callType .. " call from " .. callerName)
    -- Implementation for incoming call UI
end

-- Show Outgoing Call
function PhoneClient:showOutgoingCall(callId, receiverName)
    print("📞 Calling " .. receiverName .. "...")
    -- Implementation for outgoing call UI
end

-- Show New Message
function PhoneClient:showNewMessage(senderName, message)
    print("💬 New message from " .. senderName .. ": " .. message)
    -- Implementation for message notification
end

-- Show Notification
function PhoneClient:showNotification(message, type)
    print("🔔 " .. (type or "info"):upper() .. ": " .. message)
    -- Implementation for notification popup
end

-- Initialize Client
local phoneClient = PhoneClient.new()

print("📱 PHONE SYSTEM CLIENT LOADED!")
print("🎮 Client Features:")
print("  📱 Interactive Phone GUI")
print("  🔒 Realistic Lock Screen")
print("  📞 Call Interface")
print("  💬 Messaging System")
print("  📱 App Icons & Navigation")
print("  🎮 Multi-platform Controls")
print("")
print("🎮 CONTROLS:")
print("  📱 Click the blue phone button (right center)")
print("  💻 Press 'P' or 'ESC' to toggle")
print("  📱 Double tap (mobile)")
print("  🔢 Default passcode: 1234")
print("")
print("✅ Client ready! Look for the phone button on the right!")