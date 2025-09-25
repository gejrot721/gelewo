-- PhoneCallFeature.lua
-- Fitur Telepon untuk sistem telepon dengan daftar kontak dan simulasi panggilan

local PhoneCallFeature = {}
PhoneCallFeature.__index = PhoneCallFeature

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Phone Variables
local contacts = {}
local currentCall = nil
local callStatus = "idle" -- idle, ringing, connected, ended

-- Sample Contacts Data
local sampleContacts = {
    {
        name = "Mom",
        number = "+1-555-0101",
        avatar = "👩",
        color = Color3.fromRGB(255, 182, 193),
        status = "online"
    },
    {
        name = "Dad",
        number = "+1-555-0102",
        avatar = "👨",
        color = Color3.fromRGB(173, 216, 230),
        status = "busy"
    },
    {
        name = "Best Friend",
        number = "+1-555-0103",
        avatar = "👫",
        color = Color3.fromRGB(144, 238, 144),
        status = "online"
    },
    {
        name = "Sister",
        number = "+1-555-0104",
        avatar = "👧",
        color = Color3.fromRGB(255, 215, 0),
        status = "away"
    },
    {
        name = "Brother",
        number = "+1-555-0105",
        avatar = "👦",
        color = Color3.fromRGB(255, 165, 0),
        status = "online"
    },
    {
        name = "Emergency",
        number = "911",
        avatar = "🚨",
        color = Color3.fromRGB(255, 69, 0),
        status = "always"
    }
}

-- Create Contact Card
local function createContactCard(parent, contactData, index)
    local card = Instance.new("Frame")
    card.Name = contactData.name .. "Card"
    card.Size = UDim2.new(1, -20, 0, 80)
    card.Position = UDim2.new(0, 10, 0, (index-1) * 90)
    card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    card.BorderSizePixel = 0
    card.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = card
    
    -- Avatar
    local avatarLabel = Instance.new("TextLabel")
    avatarLabel.Name = "Avatar"
    avatarLabel.Size = UDim2.new(0, 60, 0, 60)
    avatarLabel.Position = UDim2.new(0, 10, 0, 10)
    avatarLabel.BackgroundColor3 = contactData.color
    avatarLabel.BorderSizePixel = 0
    avatarLabel.Text = contactData.avatar
    avatarLabel.TextScaled = true
    avatarLabel.Font = Enum.Font.GothamBold
    avatarLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    avatarLabel.Parent = card
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 30)
    avatarCorner.Parent = avatarLabel
    
    -- Contact name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -200, 0, 30)
    nameLabel.Position = UDim2.new(0, 80, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = contactData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    -- Contact number
    local numberLabel = Instance.new("TextLabel")
    numberLabel.Name = "Number"
    numberLabel.Size = UDim2.new(1, -200, 0, 20)
    numberLabel.Position = UDim2.new(0, 80, 0, 40)
    numberLabel.BackgroundTransparency = 1
    numberLabel.Text = contactData.number
    numberLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    numberLabel.TextScaled = true
    numberLabel.Font = Enum.Font.Gotham
    numberLabel.TextXAlignment = Enum.TextXAlignment.Left
    numberLabel.Parent = card
    
    -- Status indicator
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 80, 0, 20)
    statusLabel.Position = UDim2.new(0, 80, 0, 60)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "● " .. contactData.status
    statusLabel.TextColor3 = contactData.status == "online" and Color3.fromRGB(0, 255, 0) or 
                            contactData.status == "busy" and Color3.fromRGB(255, 0, 0) or
                            contactData.status == "away" and Color3.fromRGB(255, 255, 0) or
                            Color3.fromRGB(100, 100, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = card
    
    -- Call button
    local callBtn = Instance.new("TextButton")
    callBtn.Name = "CallButton"
    callBtn.Size = UDim2.new(0, 60, 0, 40)
    callBtn.Position = UDim2.new(1, -80, 0, 20)
    callBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    callBtn.BorderSizePixel = 0
    callBtn.Text = "📞"
    callBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    callBtn.TextScaled = true
    callBtn.Font = Enum.Font.GothamBold
    callBtn.Parent = card
    
    local callCorner = Instance.new("UICorner")
    callCorner.CornerRadius = UDim.new(0, 10)
    callCorner.Parent = callBtn
    
    -- Video call button
    local videoBtn = Instance.new("TextButton")
    videoBtn.Name = "VideoButton"
    videoBtn.Size = UDim2.new(0, 60, 0, 40)
    videoBtn.Position = UDim2.new(1, -150, 0, 20)
    videoBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    videoBtn.BorderSizePixel = 0
    videoBtn.Text = "📹"
    videoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    videoBtn.TextScaled = true
    videoBtn.Font = Enum.Font.GothamBold
    videoBtn.Parent = card
    
    local videoCorner = Instance.new("UICorner")
    videoCorner.CornerRadius = UDim.new(0, 10)
    videoCorner.Parent = videoBtn
    
    -- Hover effects
    card.MouseEnter:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    card.MouseLeave:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    -- Call button click
    callBtn.MouseButton1Click:Connect(function()
        PhoneCallFeature:StartCall(contactData)
    end)
    
    -- Video button click
    videoBtn.MouseButton1Click:Connect(function()
        PhoneCallFeature:StartVideoCall(contactData)
    end)
    
    return card
end

-- Create Call Interface
local function createCallInterface(parent, contactData)
    local callFrame = Instance.new("Frame")
    callFrame.Name = "CallInterface"
    callFrame.Size = UDim2.new(1, 0, 1, 0)
    callFrame.Position = UDim2.new(0, 0, 0, 0)
    callFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    callFrame.BorderSizePixel = 0
    callFrame.Parent = parent
    
    -- Call avatar (large)
    local callAvatar = Instance.new("TextLabel")
    callAvatar.Name = "CallAvatar"
    callAvatar.Size = UDim2.new(0, 200, 0, 200)
    callAvatar.Position = UDim2.new(0.5, -100, 0.3, -100)
    callAvatar.BackgroundColor3 = contactData.color
    callAvatar.BorderSizePixel = 0
    callAvatar.Text = contactData.avatar
    callAvatar.TextScaled = true
    callAvatar.Font = Enum.Font.GothamBold
    callAvatar.TextColor3 = Color3.fromRGB(255, 255, 255)
    callAvatar.Parent = callFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 100)
    avatarCorner.Parent = callAvatar
    
    -- Contact name
    local callName = Instance.new("TextLabel")
    callName.Name = "CallName"
    callName.Size = UDim2.new(1, 0, 0, 40)
    callName.Position = UDim2.new(0, 0, 0.6, 0)
    callName.BackgroundTransparency = 1
    callName.Text = contactData.name
    callName.TextColor3 = Color3.fromRGB(255, 255, 255)
    callName.TextScaled = true
    callName.Font = Enum.Font.GothamBold
    callName.Parent = callFrame
    
    -- Call status
    local callStatusLabel = Instance.new("TextLabel")
    callStatusLabel.Name = "CallStatus"
    callStatusLabel.Size = UDim2.new(1, 0, 0, 30)
    callStatusLabel.Position = UDim2.new(0, 0, 0.7, 0)
    callStatusLabel.BackgroundTransparency = 1
    callStatusLabel.Text = "Calling..."
    callStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    callStatusLabel.TextScaled = true
    callStatusLabel.Font = Enum.Font.Gotham
    callStatusLabel.Parent = callFrame
    
    -- Control buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, 0, 0, 100)
    buttonFrame.Position = UDim2.new(0, 0, 1, -100)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = callFrame
    
    -- End call button
    local endBtn = Instance.new("TextButton")
    endBtn.Name = "EndButton"
    endBtn.Size = UDim2.new(0, 80, 0, 80)
    endBtn.Position = UDim2.new(0.5, -40, 0, 10)
    endBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    endBtn.BorderSizePixel = 0
    endBtn.Text = "📞"
    endBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    endBtn.TextScaled = true
    endBtn.Font = Enum.Font.GothamBold
    endBtn.Parent = buttonFrame
    
    local endCorner = Instance.new("UICorner")
    endCorner.CornerRadius = UDim.new(0, 40)
    endCorner.Parent = endBtn
    
    -- Mute button
    local muteBtn = Instance.new("TextButton")
    muteBtn.Name = "MuteButton"
    muteBtn.Size = UDim2.new(0, 60, 0, 60)
    muteBtn.Position = UDim2.new(0.2, -30, 0, 20)
    muteBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    muteBtn.BorderSizePixel = 0
    muteBtn.Text = "🔇"
    muteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    muteBtn.TextScaled = true
    muteBtn.Font = Enum.Font.GothamBold
    muteBtn.Parent = buttonFrame
    
    local muteCorner = Instance.new("UICorner")
    muteCorner.CornerRadius = UDim.new(0, 30)
    muteCorner.Parent = muteBtn
    
    -- Speaker button
    local speakerBtn = Instance.new("TextButton")
    speakerBtn.Name = "SpeakerButton"
    speakerBtn.Size = UDim2.new(0, 60, 0, 60)
    speakerBtn.Position = UDim2.new(0.8, -30, 0, 20)
    speakerBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    speakerBtn.BorderSizePixel = 0
    speakerBtn.Text = "🔊"
    speakerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speakerBtn.TextScaled = true
    speakerBtn.Font = Enum.Font.GothamBold
    speakerBtn.Parent = buttonFrame
    
    local speakerCorner = Instance.new("UICorner")
    speakerCorner.CornerRadius = UDim.new(0, 30)
    speakerCorner.Parent = speakerBtn
    
    -- Button click handlers
    endBtn.MouseButton1Click:Connect(function()
        PhoneCallFeature:EndCall()
    end)
    
    muteBtn.MouseButton1Click:Connect(function()
        PhoneCallFeature:ToggleMute()
    end)
    
    speakerBtn.MouseButton1Click:Connect(function()
        PhoneCallFeature:ToggleSpeaker()
    end)
    
    return callFrame, callStatusLabel
end

-- Phone Call Methods
function PhoneCallFeature:StartCall(contactData)
    print("📞 Calling " .. contactData.name .. " (" .. contactData.number .. ")")
    
    currentCall = contactData
    callStatus = "ringing"
    
    -- Create call interface
    local contentArea = self.parent:FindFirstChild("ContentArea")
    if contentArea then
        contentArea:ClearAllChildren()
        local callInterface, statusLabel = createCallInterface(contentArea, contactData)
        
        -- Simulate call progression
        spawn(function()
            wait(2)
            if callStatus == "ringing" then
                statusLabel.Text = "Connected"
                callStatus = "connected"
                
                -- Add call duration timer
                local startTime = tick()
                spawn(function()
                    while callStatus == "connected" do
                        wait(1)
                        local duration = math.floor(tick() - startTime)
                        local minutes = math.floor(duration / 60)
                        local seconds = duration % 60
                        statusLabel.Text = string.format("Connected - %02d:%02d", minutes, seconds)
                    end
                end)
            end
        end)
    end
end

function PhoneCallFeature:StartVideoCall(contactData)
    print("📹 Starting video call with " .. contactData.name)
    -- Similar to StartCall but with video interface
    self:StartCall(contactData)
end

function PhoneCallFeature:EndCall()
    print("📞 Call ended")
    callStatus = "ended"
    currentCall = nil
    
    -- Return to contacts list
    local contentArea = self.parent:FindFirstChild("ContentArea")
    if contentArea then
        contentArea:ClearAllChildren()
        self:CreateUI(contentArea)
    end
end

function PhoneCallFeature:ToggleMute()
    print("🔇 Mute toggled")
end

function PhoneCallFeature:ToggleSpeaker()
    print("🔊 Speaker toggled")
end

-- Create Phone Feature UI
function PhoneCallFeature:CreateUI(parent)
    self.parent = parent
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📞 Contacts"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(1, -20, 0, 40)
    searchFrame.Position = UDim2.new(0, 10, 0, 50)
    searchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = parent
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 10)
    searchCorner.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -50, 1, -10)
    searchBox.Position = UDim2.new(0, 10, 0, 5)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search contacts..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchFrame
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.new(0, 30, 0, 30)
    searchIcon.Position = UDim2.new(1, -40, 0, 5)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextScaled = true
    searchIcon.Font = Enum.Font.GothamBold
    searchIcon.Parent = searchFrame
    
    -- Contacts list
    local contactsFrame = Instance.new("ScrollingFrame")
    contactsFrame.Name = "ContactsFrame"
    contactsFrame.Size = UDim2.new(1, 0, 1, -100)
    contactsFrame.Position = UDim2.new(0, 0, 0, 100)
    contactsFrame.BackgroundTransparency = 1
    contactsFrame.BorderSizePixel = 0
    contactsFrame.ScrollBarThickness = 8
    contactsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    contactsFrame.CanvasSize = UDim2.new(0, 0, 0, #sampleContacts * 90)
    contactsFrame.Parent = parent
    
    -- Create contact cards
    for i, contactData in ipairs(sampleContacts) do
        createContactCard(contactsFrame, contactData, i)
    end
    
    -- Add contact button
    local addContactBtn = Instance.new("TextButton")
    addContactBtn.Name = "AddContactButton"
    addContactBtn.Size = UDim2.new(0, 200, 0, 50)
    addContactBtn.Position = UDim2.new(0.5, -100, 1, -60)
    addContactBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    addContactBtn.BorderSizePixel = 0
    addContactBtn.Text = "➕ Add Contact"
    addContactBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addContactBtn.TextScaled = true
    addContactBtn.Font = Enum.Font.GothamBold
    addContactBtn.Parent = parent
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 10)
    addCorner.Parent = addContactBtn
    
    -- Add contact button click
    addContactBtn.MouseButton1Click:Connect(function()
        print("➕ Add Contact feature - In real implementation, this would open a contact form")
    end)
    
    return parent
end

return PhoneCallFeature