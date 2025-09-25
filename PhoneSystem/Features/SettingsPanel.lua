-- SettingsPanel.lua
-- Panel pengaturan tambahan untuk sistem telepon

local SettingsPanel = {}
SettingsPanel.__index = SettingsPanel

-- Services
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

-- Settings Variables
local settings = {
    volume = 0.5,
    notifications = true,
    autoPlay = false,
    theme = "dark",
    language = "en"
}

-- Create Slider Control
local function createSlider(parent, name, value, min, max, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. math.floor(value * 100) .. "%"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBackground"
    sliderBg.Size = UDim2.new(0.4, 0, 0, 20)
    sliderBg.Position = UDim2.new(0.6, 0, 0, 10)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 10)
    bgCorner.Parent = sliderBg
    
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(value, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = sliderFill
    
    -- Slider handle
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(value, -10, 0, 0)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Parent = sliderBg
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 10)
    handleCorner.Parent = handle
    
    -- Make handle draggable
    local dragging = false
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position.X
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderSize = sliderBg.AbsoluteSize.X
            local mouseX = input.Position.X - sliderBg.AbsolutePosition.X
            local newValue = math.clamp(mouseX / sliderSize, 0, 1)
            
            sliderFill.Size = UDim2.new(newValue, 0, 1, 0)
            handle.Position = UDim2.new(newValue, -10, 0, 0)
            label.Text = name .. ": " .. math.floor(newValue * 100) .. "%"
            
            if callback then
                callback(newValue)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return sliderFrame
end

-- Create Toggle Control
local function createToggle(parent, name, value, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle background
    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBackground"
    toggleBg.Size = UDim2.new(0, 60, 0, 30)
    toggleBg.Position = UDim2.new(1, -70, 0, 5)
    toggleBg.BackgroundColor3 = value and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = toggleFrame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 15)
    bgCorner.Parent = toggleBg
    
    -- Toggle handle
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 24, 0, 24)
    handle.Position = UDim2.new(value and 1 or 0, value and -26 or 3, 0, 3)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Parent = toggleBg
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 12)
    handleCorner.Parent = handle
    
    -- Toggle click
    toggleBg.MouseButton1Click:Connect(function()
        value = not value
        
        -- Animate toggle
        local tween = TweenService:Create(handle, TweenInfo.new(0.2), {
            Position = UDim2.new(value and 1 or 0, value and -26 or 3, 0, 3)
        })
        tween:Play()
        
        local colorTween = TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = value and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        })
        colorTween:Play()
        
        if callback then
            callback(value)
        end
    end)
    
    return toggleFrame
end

-- Create Dropdown Control
local function createDropdown(parent, name, options, currentValue, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = parent
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    -- Dropdown button
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "DropdownButton"
    dropdownBtn.Size = UDim2.new(0.4, 0, 0, 30)
    dropdownBtn.Position = UDim2.new(0.6, 0, 0, 5)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = currentValue
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextScaled = true
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.Parent = dropdownFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = dropdownBtn
    
    -- Dropdown arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -25, 0, 5)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.TextScaled = true
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = dropdownBtn
    
    -- Dropdown options (hidden by default)
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(0.4, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0.6, 0, 1, 0)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    optionsFrame.Visible = false
    optionsFrame.Parent = dropdownFrame
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 8)
    optionsCorner.Parent = optionsFrame
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Name = option .. "Option"
        optionBtn.Size = UDim2.new(1, -10, 0, 25)
        optionBtn.Position = UDim2.new(0, 5, 0, (i-1) * 30)
        optionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        optionBtn.BorderSizePixel = 0
        optionBtn.Text = option
        optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionBtn.TextScaled = true
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.Parent = optionsFrame
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 5)
        optionCorner.Parent = optionBtn
        
        -- Option click
        optionBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = option
            optionsFrame.Visible = false
            if callback then
                callback(option)
            end
        end)
        
        -- Option hover
        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
    end
    
    -- Dropdown toggle
    dropdownBtn.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        if optionsFrame.Visible then
            optionsFrame.Size = UDim2.new(0.4, 0, 0, math.min(#options * 30, 150))
        end
    end)
    
    return dropdownFrame
end

-- Create Settings Panel UI
function SettingsPanel:CreateUI(parent)
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Settings container
    local settingsFrame = Instance.new("ScrollingFrame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Size = UDim2.new(1, 0, 1, -50)
    settingsFrame.Position = UDim2.new(0, 0, 0, 50)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.BorderSizePixel = 0
    settingsFrame.ScrollBarThickness = 8
    settingsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    settingsFrame.Parent = parent
    
    -- Volume slider
    local volumeSlider = createSlider(settingsFrame, "Master Volume", settings.volume, 0, 1, function(value)
        settings.volume = value
        SoundService.Volume = value
        print("🔊 Volume set to: " .. math.floor(value * 100) .. "%")
    end)
    
    -- Notifications toggle
    local notificationsToggle = createToggle(settingsFrame, "Enable Notifications", settings.notifications, function(value)
        settings.notifications = value
        print("🔔 Notifications: " .. (value and "ON" or "OFF"))
    end)
    
    -- Auto-play toggle
    local autoPlayToggle = createToggle(settingsFrame, "Auto-play Music", settings.autoPlay, function(value)
        settings.autoPlay = value
        print("🎵 Auto-play: " .. (value and "ON" or "OFF"))
    end)
    
    -- Theme dropdown
    local themeDropdown = createDropdown(settingsFrame, "Theme", {"Dark", "Light", "Blue", "Green"}, "Dark", function(value)
        settings.theme = value:lower()
        print("🎨 Theme changed to: " .. value)
    end)
    
    -- Language dropdown
    local languageDropdown = createDropdown(settingsFrame, "Language", {"English", "Indonesian", "Spanish", "French"}, "English", function(value)
        settings.language = value:lower()
        print("🌐 Language changed to: " .. value)
    end)
    
    -- Reset button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Name = "ResetButton"
    resetBtn.Size = UDim2.new(0, 200, 0, 50)
    resetBtn.Position = UDim2.new(0.5, -100, 1, -60)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    resetBtn.BorderSizePixel = 0
    resetBtn.Text = "🔄 Reset to Default"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.TextScaled = true
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.Parent = parent
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 10)
    resetCorner.Parent = resetBtn
    
    -- Reset button click
    resetBtn.MouseButton1Click:Connect(function()
        -- Reset all settings
        settings.volume = 0.5
        settings.notifications = true
        settings.autoPlay = false
        settings.theme = "dark"
        settings.language = "en"
        
        -- Update UI
        volumeSlider:FindFirstChild("Label").Text = "Master Volume: 50%"
        volumeSlider:FindFirstChild("SliderBackground"):FindFirstChild("SliderFill").Size = UDim2.new(0.5, 0, 1, 0)
        volumeSlider:FindFirstChild("SliderBackground"):FindFirstChild("Handle").Position = UDim2.new(0.5, -10, 0, 0)
        
        print("🔄 Settings reset to default")
    end)
    
    -- About section
    local aboutFrame = Instance.new("Frame")
    aboutFrame.Name = "AboutFrame"
    aboutFrame.Size = UDim2.new(1, -20, 0, 100)
    aboutFrame.Position = UDim2.new(0, 10, 0, 300)
    aboutFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    aboutFrame.BorderSizePixel = 0
    aboutFrame.Parent = settingsFrame
    
    local aboutCorner = Instance.new("UICorner")
    aboutCorner.CornerRadius = UDim.new(0, 15)
    aboutCorner.Parent = aboutFrame
    
    local aboutTitle = Instance.new("TextLabel")
    aboutTitle.Name = "AboutTitle"
    aboutTitle.Size = UDim2.new(1, 0, 0, 30)
    aboutTitle.Position = UDim2.new(0, 0, 0, 0)
    aboutTitle.BackgroundTransparency = 1
    aboutTitle.Text = "📱 About Phone System"
    aboutTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    aboutTitle.TextScaled = true
    aboutTitle.Font = Enum.Font.GothamBold
    aboutTitle.Parent = aboutFrame
    
    local aboutText = Instance.new("TextLabel")
    aboutText.Name = "AboutText"
    aboutText.Size = UDim2.new(1, -20, 0, 60)
    aboutText.Position = UDim2.new(0, 10, 0, 30)
    aboutText.BackgroundTransparency = 1
    aboutText.Text = "Version 1.0.0\nModern phone system for Roblox\nCreated with ❤️"
    aboutText.TextColor3 = Color3.fromRGB(200, 200, 200)
    aboutText.TextScaled = true
    aboutText.Font = Enum.Font.Gotham
    aboutText.TextXAlignment = Enum.TextXAlignment.Left
    aboutText.TextYAlignment = Enum.TextYAlignment.Top
    aboutText.Parent = aboutFrame
    
    return parent
end

return SettingsPanel