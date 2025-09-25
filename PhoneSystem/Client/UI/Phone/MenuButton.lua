-- MenuButton.lua
-- Tombol menu yang responsif untuk membuka/menutup handphone

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PhoneConfig = require(script.Parent.Parent.Parent.Shared.PhoneConfig)
local UIScale = require(script.Parent.Parent.Parent.Shared.Utils.UIScale)

local MenuButton = {}

-- Create the floating menu button
function MenuButton.createMenuButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PhoneMenuButton"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Main button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(0, 80, 0, 80)
    buttonContainer.Position = UDim2.new(1, -100, 0.5, -40) -- Right center
    buttonContainer.Parent = screenGui
    
    -- Menu button
    local menuButton = Instance.new("TextButton")
    menuButton.Name = "MenuButton"
    menuButton.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    menuButton.BorderSizePixel = 0
    menuButton.Text = "📱"
    menuButton.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    menuButton.TextScaled = true
    menuButton.Font = PhoneConfig.UI.FONTS.BODY
    menuButton.TextSize = 32
    menuButton.Size = UDim2.new(1, 0, 1, 0)
    menuButton.Position = UDim2.new(0, 0, 0, 0)
    menuButton.Parent = buttonContainer
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = menuButton
    
    -- Add shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.ZIndex = menuButton.ZIndex - 1
    shadow.Parent = buttonContainer
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0.5, 0)
    shadowCorner.Parent = shadow
    
    -- Add pulsing animation
    MenuButton.addPulsingAnimation(menuButton)
    
    -- Add responsive scaling
    MenuButton.setupResponsiveScaling(buttonContainer, menuButton)
    
    -- Add click effects
    MenuButton.addClickEffects(menuButton)
    
    -- Make draggable
    MenuButton.makeDraggable(buttonContainer)
    
    return menuButton, screenGui
end

-- Add pulsing animation to attract attention
function MenuButton.addPulsingAnimation(button)
    local originalSize = button.Size
    local pulseSize = UDim2.new(
        originalSize.X.Scale * 1.1,
        originalSize.X.Offset * 1.1,
        originalSize.Y.Scale * 1.1,
        originalSize.Y.Offset * 1.1
    )
    
    local pulseTween = TweenService:Create(
        button,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = pulseSize}
    )
    
    pulseTween:Play()
    
    -- Stop pulsing after 10 seconds
    wait(10)
    pulseTween:Cancel()
    button.Size = originalSize
end

-- Setup responsive scaling
function MenuButton.setupResponsiveScaling(container, button)
    local scale, deviceType = UIScale.calculateScale()
    
    -- Adjust button size based on device type
    local buttonSize = 80
    if deviceType == "mobile" then
        buttonSize = 70
    elseif deviceType == "tablet" then
        buttonSize = 75
    elseif deviceType == "console" then
        buttonSize = 85
    end
    
    container.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    button.Size = UDim2.new(1, 0, 1, 0)
    
    -- Adjust position for different devices
    local xOffset = -buttonSize - 20
    if deviceType == "mobile" then
        xOffset = -buttonSize - 15
    elseif deviceType == "console" then
        xOffset = -buttonSize - 25
    end
    
    container.Position = UDim2.new(1, xOffset, 0.5, -buttonSize / 2)
    
    -- Listen for screen size changes
    local connection
    connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        MenuButton.setupResponsiveScaling(container, button)
    end)
end

-- Add click effects
function MenuButton.addClickEffects(button)
    local originalSize = button.Size
    local pressedSize = UDim2.new(
        originalSize.X.Scale * 0.9,
        originalSize.X.Offset * 0.9,
        originalSize.Y.Scale * 0.9,
        originalSize.Y.Offset * 0.9
    )
    
    button.MouseButton1Down:Connect(function()
        local pressTween = TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = pressedSize}
        )
        pressTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local releaseTween = TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize}
        )
        releaseTween:Play()
    end)
    
    button.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY_DARK}
        )
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local unhoverTween = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY}
        )
        unhoverTween:Play()
    end)
end

-- Make button draggable
function MenuButton.makeDraggable(container)
    local dragging = false
    local dragStart = nil
    local startPosition = nil
    
    local function updatePosition(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
        
        -- Keep button within screen bounds
        local screenSize = workspace.CurrentCamera.ViewportSize
        local buttonSize = container.Size.X.Offset
        
        local minX = 0
        local maxX = screenSize.X - buttonSize
        local minY = 0
        local maxY = screenSize.Y - buttonSize
        
        local clampedX = math.clamp(newPosition.X.Offset, minX, maxX)
        local clampedY = math.clamp(newPosition.Y.Offset, minY, maxY)
        
        container.Position = UDim2.new(0, clampedX, 0, clampedY)
    end
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = container.Position
        end
    end)
    
    container.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updatePosition(input)
        end
    end)
    
    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Show notification badge on button
function MenuButton.showNotificationBadge(button)
    local badge = Instance.new("Frame")
    badge.Name = "NotificationBadge"
    badge.BackgroundColor3 = PhoneConfig.UI.COLORS.ERROR
    badge.BorderSizePixel = 0
    badge.Size = UDim2.new(0, 20, 0, 20)
    badge.Position = UDim2.new(1, -10, 0, -10)
    badge.ZIndex = button.ZIndex + 1
    badge.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = badge
    
    -- Add pulse animation
    local pulseTween = TweenService:Create(
        badge,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = 0.3}
    )
    pulseTween:Play()
    
    return badge
end

-- Hide notification badge
function MenuButton.hideNotificationBadge(button)
    local badge = button:FindFirstChild("NotificationBadge")
    if badge then
        badge:Destroy()
    end
end

-- Animate button when phone is opened/closed
function MenuButton.animateButtonState(button, isPhoneOpen)
    local targetRotation = isPhoneOpen and 45 or 0
    local targetScale = isPhoneOpen and 0.8 or 1
    
    local rotationTween = TweenService:Create(
        button,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Rotation = targetRotation}
    )
    
    local scaleTween = TweenService:Create(
        button,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(scale, 0, scale, 0)}
    )
    
    rotationTween:Play()
    scaleTween:Play()
end

-- Add haptic feedback for mobile devices
function MenuButton.addHapticFeedback(button)
    button.MouseButton1Click:Connect(function()
        if UserInputService.TouchEnabled then
            -- Simulate haptic feedback
            local hapticEvent = Instance.new("BindableEvent")
            hapticEvent:Fire()
            hapticEvent:Destroy()
        end
    end)
end

return MenuButton