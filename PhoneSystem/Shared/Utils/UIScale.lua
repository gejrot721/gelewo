-- UIScale.lua
-- Utility untuk auto-scaling UI berdasarkan device type dan screen size

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local PhoneConfig = require(script.Parent.Parent.PhoneConfig)

local UIScale = {}

-- Deteksi device type
function UIScale.getDeviceType()
    local platform = UserInputService:GetPlatform()
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    if platform == Enum.Platform.Android or platform == Enum.Platform.IOS then
        if screenSize.X <= PhoneConfig.AUTOSCALE.BREAKPOINTS.MOBILE then
            return "mobile"
        else
            return "tablet"
        end
    elseif platform == Enum.Platform.XBoxOne or platform == Enum.Platform.PS4 or platform == Enum.Platform.PS5 or platform == Enum.Platform.XBoxSeriesX then
        return "console"
    else
        return "desktop"
    end
end

-- Hitung scale factor berdasarkan screen size
function UIScale.calculateScale()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local deviceType = UIScale.getDeviceType()
    
    local baseWidth, baseHeight = PhoneConfig.AUTOSCALE.BASE_RESOLUTION[1], PhoneConfig.AUTOSCALE.BASE_RESOLUTION[2]
    local screenRatio = screenSize.X / screenSize.Y
    local baseRatio = baseWidth / baseHeight
    
    -- Hitung scale berdasarkan width atau height yang lebih kecil
    local scaleX = screenSize.X / baseWidth
    local scaleY = screenSize.Y / baseHeight
    local scale = math.min(scaleX, scaleY)
    
    -- Apply device-specific adjustments
    if deviceType == "mobile" then
        scale = scale * 0.8 -- Slightly smaller on mobile
    elseif deviceType == "tablet" then
        scale = scale * 0.9
    elseif deviceType == "console" then
        scale = scale * 1.1 -- Slightly larger on console
    end
    
    -- Clamp scale within limits
    scale = math.clamp(scale, PhoneConfig.AUTOSCALE.MIN_SCALE, PhoneConfig.AUTOSCALE.MAX_SCALE)
    
    return scale, deviceType
end

-- Scale UI element dengan smooth transition
function UIScale.scaleElement(gui, targetScale, duration)
    duration = duration or PhoneConfig.UI.ANIMATION_SPEED
    
    local startScale = gui.Size
    local startTime = tick()
    
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.min(elapsed / duration, 1)
        
        -- Smooth easing function
        alpha = 1 - math.pow(1 - alpha, 3)
        
        local currentScale = UDim2.new(
            startScale.X.Scale * (1 - alpha) + targetScale.X.Scale * alpha,
            startScale.X.Offset * (1 - alpha) + targetScale.X.Offset * alpha,
            startScale.Y.Scale * (1 - alpha) + targetScale.Y.Scale * alpha,
            startScale.Y.Offset * (1 - alpha) + targetScale.Y.Offset * alpha
        )
        
        gui.Size = currentScale
        
        if alpha >= 1 then
            connection:Disconnect()
        end
    end)
end

-- Get responsive font size
function UIScale.getFontSize(baseSize, deviceType)
    local scale = UIScale.calculateScale()
    
    if deviceType == "mobile" then
        return math.floor(baseSize * 0.9)
    elseif deviceType == "tablet" then
        return math.floor(baseSize * 1.0)
    elseif deviceType == "console" then
        return math.floor(baseSize * 1.1)
    else
        return math.floor(baseSize * 1.0)
    end
end

-- Get responsive spacing
function UIScale.getSpacing(baseSpacing, deviceType)
    local scale = UIScale.calculateScale()
    return math.floor(baseSpacing * scale)
end

-- Create responsive frame
function UIScale.createResponsiveFrame(parent, size, position, deviceType)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    
    -- Calculate responsive size and position
    local scale, detectedDeviceType = UIScale.calculateScale()
    deviceType = deviceType or detectedDeviceType
    
    -- Apply device-specific adjustments
    local sizeMultiplier = 1
    local positionMultiplier = 1
    
    if deviceType == "mobile" then
        sizeMultiplier = 0.85
        positionMultiplier = 0.9
    elseif deviceType == "tablet" then
        sizeMultiplier = 0.95
        positionMultiplier = 0.95
    elseif deviceType == "console" then
        sizeMultiplier = 1.05
        positionMultiplier = 1.0
    end
    
    frame.Size = UDim2.new(
        size.X.Scale * sizeMultiplier,
        size.X.Offset * scale,
        size.Y.Scale * sizeMultiplier,
        size.Y.Offset * scale
    )
    
    frame.Position = UDim2.new(
        position.X.Scale * positionMultiplier,
        position.X.Offset * scale,
        position.Y.Scale * positionMultiplier,
        position.Y.Offset * scale
    )
    
    frame.Parent = parent
    
    return frame
end

-- Update all UI elements when screen size changes
function UIScale.setupResponsiveUI(phoneFrame)
    local scale, deviceType = UIScale.calculateScale()
    
    -- Update phone frame
    phoneFrame.Size = UDim2.new(0, PhoneConfig.UI.PHONE_WIDTH * scale, 0, PhoneConfig.UI.PHONE_HEIGHT * scale)
    
    -- Update all child elements
    UIScale.updateChildElements(phoneFrame, scale, deviceType)
    
    -- Listen for screen size changes
    local connection
    connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local newScale, newDeviceType = UIScale.calculateScale()
        UIScale.updateChildElements(phoneFrame, newScale, newDeviceType)
    end)
    
    return connection
end

-- Update child elements recursively
function UIScale.updateChildElements(parent, scale, deviceType)
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("GuiObject") then
            -- Update font sizes for text elements
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                if child.TextSize then
                    child.TextSize = UIScale.getFontSize(child.TextSize, deviceType)
                end
            end
            
            -- Update icon sizes
            if child:IsA("ImageLabel") and child.Name:find("Icon") then
                local iconSize = PhoneConfig.UI.ICON_SIZE * scale
                child.Size = UDim2.new(0, iconSize, 0, iconSize)
            end
            
            -- Update avatar sizes
            if child:IsA("ImageLabel") and child.Name:find("Avatar") then
                local avatarSize = PhoneConfig.UI.AVATAR_SIZE * scale
                child.Size = UDim2.new(0, avatarSize, 0, avatarSize)
            end
            
            -- Update button heights
            if child:IsA("TextButton") and child.Name:find("Button") then
                local buttonHeight = PhoneConfig.UI.BUTTON_HEIGHT * scale
                child.Size = UDim2.new(child.Size.X.Scale, child.Size.X.Offset, 0, buttonHeight)
            end
            
            -- Recursively update children
            UIScale.updateChildElements(child, scale, deviceType)
        end
    end
end

return UIScale