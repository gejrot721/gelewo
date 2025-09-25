-- PhoneSystemClient_iPhone.lua
-- Client-side iPhone-style phone system with menu on right-center
-- Place this in StarterPlayer > StarterPlayerScripts

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Wait for RemoteEvents
local PhoneEvents = ReplicatedStorage:WaitForChild("PhoneEvents")
local Events = {}

-- Safely get RemoteEvents
for _, child in pairs(PhoneEvents:GetChildren()) do
    if child:IsA("RemoteEvent") then
        Events[child.Name] = child
    end
end

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- iPhone System Variables
local phoneGui = nil
local phoneContainer = nil
local menuButton = nil
local phoneFrame = nil
local isPhoneOpen = false
local currentFeature = "home"
local phoneSounds = {}
local currentData = {}
local isAnimating = false

-- Device Detection
local function getDeviceType()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "mobile"
    elseif UserInputService.GamepadEnabled then
        return "console"
    else
        return "pc"
    end
end

-- Sound Management
local function createSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.3
    sound.Parent = SoundService
    return sound
end

-- Initialize iPhone Sounds
local function initializeSounds()
    phoneSounds = {
        click = createSound(131961136, 0.2),
        open = createSound(131961136, 0.3),
        close = createSound(131961136, 0.2),
        notification = createSound(131961136, 0.3),
        call = createSound(131961136, 0.4)
    }
end

-- Create Main iPhone GUI
local function createiPhoneGUI()
    phoneGui = Instance.new("ScreenGui")
    phoneGui.Name = "iPhoneSystemGUI"
    phoneGui.ResetOnSpawn = false
    phoneGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    phoneGui.Parent = playerGui
    
    return phoneGui
end

-- Create iPhone Menu Button (Right-Center)
local function createMenuButton()
    menuButton = Instance.new("TextButton")
    menuButton.Name = "iPhoneMenuButton"
    menuButton.Size = UDim2.new(0, 60, 0, 60)
    menuButton.Position = UDim2.new(1, -80, 0.5, -30)
    menuButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    menuButton.BackgroundTransparency = 0.2
    menuButton.BorderSizePixel = 0
    menuButton.Text = ""
    menuButton.ZIndex = 1000
    menuButton.Parent = phoneGui
    
    -- iPhone-style rounded button
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = menuButton
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    gradient.Rotation = 45
    gradient.Parent = menuButton
    
    -- iPhone home indicator
    local homeIndicator = Instance.new("Frame")
    homeIndicator.Name = "HomeIndicator"
    homeIndicator.Size = UDim2.new(0, 30, 0, 30)
    homeIndicator.Position = UDim2.new(0.5, -15, 0.5, -15)
    homeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    homeIndicator.BorderSizePixel = 0
    homeIndicator.Parent = menuButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 15)
    indicatorCorner.Parent = homeIndicator
    
    -- Icon inside indicator
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "📱"
    icon.TextColor3 = Color3.fromRGB(0, 0, 0)
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = homeIndicator
    
    -- Hover effect
    menuButton.MouseEnter:Connect(function()
        if not isAnimating then
            TweenService:Create(menuButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 70, 0, 70),
                Position = UDim2.new(1, -85, 0.5, -35)
            }):Play()
        end
    end)
    
    menuButton.MouseLeave:Connect(function()
        if not isAnimating then
            TweenService:Create(menuButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 60, 0, 60),
                Position = UDim2.new(1, -80, 0.5, -30)
            }):Play()
        end
    end)
    
    return menuButton
end

-- Create iPhone Container
local function createiPhoneContainer()
    phoneContainer = Instance.new("Frame")
    phoneContainer.Name = "iPhoneContainer"
    phoneContainer.Size = UDim2.new(0, 400, 0, 700)
    phoneContainer.Position = UDim2.new(1, -420, 0.5, -350)
    phoneContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    phoneContainer.BorderSizePixel = 0
    phoneContainer.ClipsDescendants = true
    phoneContainer.Visible = false
    phoneContainer.ZIndex = 100
    phoneContainer.Parent = phoneGui
    
    -- iPhone rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 40)
    corner.Parent = phoneContainer
    
    -- iPhone bezel
    local bezel = Instance.new("Frame")
    bezel.Name = "Bezel"
    bezel.Size = UDim2.new(1, -20, 1, -20)
    bezel.Position = UDim2.new(0, 10, 0, 10)
    bezel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bezel.BorderSizePixel = 0
    bezel.Parent = phoneContainer
    
    local bezelCorner = Instance.new("UICorner")
    bezelCorner.CornerRadius = UDim.new(0, 30)
    bezelCorner.Parent = bezel
    
    -- Screen area
    phoneFrame = Instance.new("Frame")
    phoneFrame.Name = "Screen"
    phoneFrame.Size = UDim2.new(1, -10, 1, -80)
    phoneFrame.Position = UDim2.new(0, 5, 0, 40)
    phoneFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    phoneFrame.BorderSizePixel = 0
    phoneFrame.Parent = bezel
    
    local screenCorner = Instance.new("UICorner")
    screenCorner.CornerRadius = UDim.new(0, 25)
    screenCorner.Parent = phoneFrame
    
    -- Dynamic Island (iPhone 14 style)
    local dynamicIsland = Instance.new("Frame")
    dynamicIsland.Name = "DynamicIsland"
    dynamicIsland.Size = UDim2.new(0, 120, 0, 30)
    dynamicIsland.Position = UDim2.new(0.5, -60, 0, -35)
    dynamicIsland.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dynamicIsland.BorderSizePixel = 0
    dynamicIsland.Parent = bezel
    
    local islandCorner = Instance.new("UICorner")
    islandCorner.CornerRadius = UDim.new(0, 15)
    islandCorner.Parent = dynamicIsland
    
    -- Home indicator
    local homeBar = Instance.new("Frame")
    homeBar.Name = "HomeBar"
    homeBar.Size = UDim2.new(0, 140, 0, 4)
    homeBar.Position = UDim2.new(0.5, -70, 1, -10)
    homeBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    homeBar.BackgroundTransparency = 0.7
    homeBar.BorderSizePixel = 0
    homeBar.Parent = bezel
    
    local homeCorner = Instance.new("UICorner")
    homeCorner.CornerRadius = UDim.new(0, 2)
    homeCorner.Parent = homeBar
    
    return phoneContainer
end

-- Create iPhone Status Bar
local function createStatusBar(parent)
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, 0, 0, 40)
    statusBar.Position = UDim2.new(0, 0, 0, 0)
    statusBar.BackgroundTransparency = 1
    statusBar.Parent = parent
    
    -- Time
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Time"
    timeLabel.Size = UDim2.new(0, 80, 1, 0)
    timeLabel.Position = UDim2.new(0, 20, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = statusBar
    
    -- Battery and signal
    local statusIcons = Instance.new("TextLabel")
    statusIcons.Name = "StatusIcons"
    statusIcons.Size = UDim2.new(0, 100, 1, 0)
    statusIcons.Position = UDim2.new(1, -120, 0, 0)
    statusIcons.BackgroundTransparency = 1
    statusIcons.Text = "📶 🔋100%"
    statusIcons.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusIcons.TextScaled = true
    statusIcons.Font = Enum.Font.Gotham
    statusIcons.TextXAlignment = Enum.TextXAlignment.Right
    statusIcons.Parent = statusBar
    
    -- Update time every minute
    spawn(function()
        while statusBar.Parent do
            timeLabel.Text = os.date("%H:%M")
            wait(60)
        end
    end)
    
    return statusBar
end

-- Create iPhone App Grid
local function createAppGrid(parent)
    local appGrid = Instance.new("ScrollingFrame")
    appGrid.Name = "AppGrid"
    appGrid.Size = UDim2.new(1, -40, 1, -100)
    appGrid.Position = UDim2.new(0, 20, 0, 50)
    appGrid.BackgroundTransparency = 1
    appGrid.BorderSizePixel = 0
    appGrid.ScrollBarThickness = 0
    appGrid.CanvasSize = UDim2.new(0, 0, 0, 600)
    appGrid.Parent = parent
    
    -- App icons data
    local apps = {
        {name = "Games", icon = "🎮", color = Color3.fromRGB(255, 100, 100)},
        {name = "Messages", icon = "💬", color = Color3.fromRGB(100, 255, 100)},
        {name = "Phone", icon = "📞", color = Color3.fromRGB(100, 100, 255)},
        {name = "Music", icon = "🎵", color = Color3.fromRGB(255, 255, 100)},
        {name = "Settings", icon = "⚙️", color = Color3.fromRGB(150, 150, 150)},
        {name = "Camera", icon = "📷", color = Color3.fromRGB(100, 100, 100)},
        {name = "Photos", icon = "🖼️", color = Color3.fromRGB(255, 150, 100)},
        {name = "Safari", icon = "🌐", color = Color3.fromRGB(100, 200, 255)},
        {name = "Maps", icon = "🗺️", color = Color3.fromRGB(0, 255, 100)},
        {name = "Weather", icon = "🌤️", color = Color3.fromRGB(100, 150, 255)},
        {name = "Calendar", icon = "📅", color = Color3.fromRGB(255, 100, 150)},
        {name = "Notes", icon = "📝", color = Color3.fromRGB(255, 255, 150)}
    }
    
    -- Create app icons in 4x3 grid
    for i, app in ipairs(apps) do
        local row = math.floor((i-1) / 4)
        local col = (i-1) % 4
        
        local appIcon = Instance.new("TextButton")
        appIcon.Name = app.name .. "App"
        appIcon.Size = UDim2.new(0, 70, 0, 70)
        appIcon.Position = UDim2.new(0, col * 85 + 10, 0, row * 100 + 20)
        appIcon.BackgroundColor3 = app.color
        appIcon.BorderSizePixel = 0
        appIcon.Text = ""
        appIcon.Parent = appGrid
        
        -- App icon styling
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 15)
        iconCorner.Parent = appIcon
        
        -- App icon gradient
        local iconGradient = Instance.new("UIGradient")
        iconGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, app.color),
            ColorSequenceKeypoint.new(1, Color3.new(app.color.R * 0.7, app.color.G * 0.7, app.color.B * 0.7))
        }
        iconGradient.Rotation = 45
        iconGradient.Parent = appIcon
        
        -- Icon symbol
        local symbol = Instance.new("TextLabel")
        symbol.Size = UDim2.new(0.7, 0, 0.7, 0)
        symbol.Position = UDim2.new(0.15, 0, 0.15, 0)
        symbol.BackgroundTransparency = 1
        symbol.Text = app.icon
        symbol.TextColor3 = Color3.fromRGB(255, 255, 255)
        symbol.TextScaled = true
        symbol.Font = Enum.Font.GothamBold
        symbol.Parent = appIcon
        
        -- App name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 70, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 1, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = app.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = appIcon
        
        -- App click animation and function
        appIcon.MouseButton1Click:Connect(function()
            if phoneSounds.click then
                phoneSounds.click:Play()
            end
            
            -- Click animation
            local clickTween = TweenService:Create(appIcon, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 60, 0, 60)
            })
            clickTween:Play()
            
            clickTween.Completed:Connect(function()
                TweenService:Create(appIcon, TweenInfo.new(0.1), {
                    Size = UDim2.new(0, 70, 0, 70)
                }):Play()
            end)
            
            -- Switch to feature
            switchFeature(app.name:lower())
        end)
        
        -- App press effect
        appIcon.MouseButton1Down:Connect(function()
            TweenService:Create(appIcon, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 65, 0, 65)
            }):Play()
        end)
        
        appIcon.MouseButton1Up:Connect(function()
            TweenService:Create(appIcon, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 70, 0, 70)
            }):Play()
        end)
    end
    
    return appGrid
end

-- Create Content Area for Features
local function createContentArea(parent)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -40)
    contentArea.Position = UDim2.new(0, 0, 0, 40)
    contentArea.BackgroundTransparency = 1
    contentArea.Visible = false
    contentArea.Parent = parent
    
    return contentArea
end

-- iPhone Animation Functions
local function animateiPhoneOpen()
    if isAnimating then return end
    isAnimating = true
    
    if phoneSounds.open then
        phoneSounds.open:Play()
    end
    
    phoneContainer.Visible = true
    phoneContainer.Size = UDim2.new(0, 0, 0, 0)
    phoneContainer.Position = UDim2.new(1, -420, 0.5, 0)
    
    -- iPhone-style spring animation
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(phoneContainer, tweenInfo, {
        Size = UDim2.new(0, 400, 0, 700),
        Position = UDim2.new(1, -420, 0.5, -350)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        isPhoneOpen = true
        isAnimating = false
    end)
end

local function animateiPhoneClose()
    if isAnimating then return end
    isAnimating = true
    
    if phoneSounds.close then
        phoneSounds.close:Play()
    end
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tween = TweenService:Create(phoneContainer, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(1, -420, 0.5, 0)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        phoneContainer.Visible = false
        isPhoneOpen = false
        isAnimating = false
        
        -- Reset to home screen
        resetToHomeScreen()
    end)
end

-- Feature Management
local function switchFeature(featureName)
    currentFeature = featureName
    
    if Events.SwitchFeature then
        Events.SwitchFeature:FireServer(featureName)
    end
    
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    local appGrid = phoneFrame:FindFirstChild("AppGrid")
    
    if featureName == "home" then
        if contentArea then contentArea.Visible = false end
        if appGrid then appGrid.Visible = true end
    else
        if appGrid then appGrid.Visible = false end
        if contentArea then contentArea.Visible = true end
    end
end

local function resetToHomeScreen()
    switchFeature("home")
end

-- Initialize iPhone System
local function initializeiPhoneSystem()
    initializeSounds()
    createiPhoneGUI()
    createMenuButton()
    createiPhoneContainer()
    
    local statusBar = createStatusBar(phoneFrame)
    local appGrid = createAppGrid(phoneFrame)
    local contentArea = createContentArea(phoneFrame)
    
    -- Connect menu button
    menuButton.MouseButton1Click:Connect(function()
        if Events.TogglePhone then
            Events.TogglePhone:FireServer()
        end
        
        if isPhoneOpen then
            animateiPhoneClose()
        else
            animateiPhoneOpen()
        end
    end)
    
    print("📱 iPhone-style Phone System initialized!")
end

-- Initialize when loaded
initializeiPhoneSystem()

-- Keyboard shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if isPhoneOpen then
            animateiPhoneClose()
        else
            animateiPhoneOpen()
        end
    end
end)

print("📱 iPhone-style Phone System Client ready!")
print("🔑 Press F1 or click the menu button on the right to open")