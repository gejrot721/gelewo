-- PhoneSystem.lua
-- Sistem Telepon Roblox dengan fitur lengkap

local PhoneSystem = {}
PhoneSystem.__index = PhoneSystem

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Phone System Variables
local phoneFrame = nil
local isPhoneOpen = false
local currentFeature = "home"
local phoneSounds = {}

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
    sound.Volume = volume or 0.5
    sound.Parent = SoundService
    return sound
end

-- Initialize Phone Sounds
local function initializeSounds()
    phoneSounds = {
        click = createSound(131961136, 0.3), -- Click sound
        open = createSound(131961136, 0.4), -- Open sound
        close = createSound(131961136, 0.3), -- Close sound
        call = createSound(131961136, 0.5), -- Call sound
        notification = createSound(131961136, 0.4) -- Notification sound
    }
end

-- Device-specific UI Scaling
local function getUIScale()
    local deviceType = getDeviceType()
    local scale = 1
    
    if deviceType == "mobile" then
        scale = 0.8
    elseif deviceType == "console" then
        scale = 0.9
    else
        scale = 0.7
    end
    
    return scale
end

-- Create Main Phone Frame
local function createPhoneFrame()
    local scale = getUIScale()
    
    phoneFrame = Instance.new("Frame")
    phoneFrame.Name = "PhoneFrame"
    phoneFrame.Size = UDim2.new(scale, 0, scale, 0)
    phoneFrame.Position = UDim2.new(0.5 - scale/2, 0, 0.5 - scale/2, 0)
    phoneFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    phoneFrame.BorderSizePixel = 0
    phoneFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    phoneFrame.Parent = playerGui
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = phoneFrame
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = phoneFrame.ZIndex - 1
    shadow.Parent = phoneFrame
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    gradient.Rotation = 45
    gradient.Parent = phoneFrame
    
    return phoneFrame
end

-- Create Header Bar
local function createHeaderBar(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    -- Rounded top corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0.25, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📱 Telepon"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(1, -60, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "☰"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = header
    
    -- Toggle button corner
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleBtn
    
    return header, toggleBtn
end

-- Create Navigation Bar
local function createNavigationBar(parent)
    local navBar = Instance.new("Frame")
    navBar.Name = "NavigationBar"
    navBar.Size = UDim2.new(1, 0, 0, 80)
    navBar.Position = UDim2.new(0, 0, 1, -80)
    navBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    navBar.BorderSizePixel = 0
    navBar.Parent = parent
    
    -- Rounded bottom corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = navBar
    
    -- Navigation buttons
    local buttons = {}
    local buttonData = {
        {name = "Games", icon = "🎮", color = Color3.fromRGB(255, 100, 100)},
        {name = "Chat", icon = "💬", color = Color3.fromRGB(100, 255, 100)},
        {name = "Phone", icon = "📞", color = Color3.fromRGB(100, 100, 255)},
        {name = "Music", icon = "🎵", color = Color3.fromRGB(255, 255, 100)},
        {name = "Settings", icon = "⚙️", color = Color3.fromRGB(200, 200, 200)}
    }
    
    for i, data in ipairs(buttonData) do
        local btn = Instance.new("TextButton")
        btn.Name = data.name .. "Button"
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = data.icon .. "\n" .. data.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = navBar
        
        -- Button hover effect
        btn.MouseEnter:Connect(function()
            btn.TextColor3 = data.color
        end)
        
        btn.MouseLeave:Connect(function()
            if currentFeature ~= data.name:lower() then
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)
        
        buttons[data.name:lower()] = btn
    end
    
    return navBar, buttons
end

-- Create Content Area
local function createContentArea(parent)
    local content = Instance.new("Frame")
    content.Name = "ContentArea"
    content.Size = UDim2.new(1, -20, 1, -140)
    content.Position = UDim2.new(0, 10, 0, 70)
    content.BackgroundTransparency = 1
    content.Parent = parent
    
    return content
end

-- Animation Functions
local function animatePhoneOpen()
    if phoneSounds.open then
        phoneSounds.open:Play()
    end
    
    phoneFrame.Size = UDim2.new(0, 0, 0, 0)
    phoneFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(phoneFrame, tweenInfo, {
        Size = UDim2.new(getUIScale(), 0, getUIScale(), 0),
        BackgroundTransparency = 0
    })
    
    tween:Play()
    tween.Completed:Wait()
    isPhoneOpen = true
end

local function animatePhoneClose()
    if phoneSounds.close then
        phoneSounds.close:Play()
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tween = TweenService:Create(phoneFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Wait()
    isPhoneOpen = false
end

-- Feature Management
local function switchFeature(featureName)
    if phoneSounds.click then
        phoneSounds.click:Play()
    end
    
    currentFeature = featureName
    
    -- Update navigation buttons
    local navBar = phoneFrame:FindFirstChild("NavigationBar")
    if navBar then
        for _, child in pairs(navBar:GetChildren()) do
            if child:IsA("TextButton") then
                if child.Name:lower():find(featureName:lower()) then
                    child.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    child.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end
    end
    
    -- Clear content area
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if contentArea then
        contentArea:ClearAllChildren()
    end
    
    -- Load feature content
    if featureName == "games" then
        PhoneSystem:loadGamesFeature()
    elseif featureName == "chat" then
        PhoneSystem:loadChatFeature()
    elseif featureName == "phone" then
        PhoneSystem:loadPhoneFeature()
    elseif featureName == "music" then
        PhoneSystem:loadMusicFeature()
    elseif featureName == "settings" then
        PhoneSystem:loadSettingsFeature()
    end
end

-- Initialize Phone System
function PhoneSystem:Initialize()
    initializeSounds()
    
    -- Create phone frame
    createPhoneFrame()
    
    -- Create UI elements
    local header, toggleBtn = createHeaderBar(phoneFrame)
    local navBar, navButtons = createNavigationBar(phoneFrame)
    local contentArea = createContentArea(phoneFrame)
    
    -- Connect toggle button
    toggleBtn.MouseButton1Click:Connect(function()
        if isPhoneOpen then
            animatePhoneClose()
        else
            animatePhoneOpen()
        end
    end)
    
    -- Connect navigation buttons
    for featureName, button in pairs(navButtons) do
        button.MouseButton1Click:Connect(function()
            switchFeature(featureName)
        end)
    end
    
    -- Start with phone closed
    phoneFrame.Size = UDim2.new(0, 0, 0, 0)
    phoneFrame.BackgroundTransparency = 1
    
    print("📱 Phone System initialized successfully!")
end

-- Feature Loading Methods
function PhoneSystem:loadGamesFeature()
    local GamesFeature = require(script.Parent.Features.GamesFeature)
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if contentArea then
        GamesFeature:CreateUI(contentArea)
    end
end

function PhoneSystem:loadChatFeature()
    local ChatFeature = require(script.Parent.Features.ChatFeature)
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if contentArea then
        ChatFeature:CreateUI(contentArea)
    end
end

function PhoneSystem:loadPhoneFeature()
    local PhoneCallFeature = require(script.Parent.Features.PhoneCallFeature)
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if contentArea then
        PhoneCallFeature:CreateUI(contentArea)
    end
end

function PhoneSystem:loadMusicFeature()
    local MusicFeature = require(script.Parent.Features.MusicFeature)
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if contentArea then
        MusicFeature:CreateUI(contentArea)
    end
end

function PhoneSystem:loadSettingsFeature()
    local SettingsPanel = require(script.Parent.Features.SettingsPanel)
    local contentArea = phoneFrame:FindFirstChild("ContentArea")
    if contentArea then
        SettingsPanel:CreateUI(contentArea)
    end
end

-- Export PhoneSystem
return PhoneSystem