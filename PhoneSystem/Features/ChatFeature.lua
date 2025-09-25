-- ChatFeature.lua
-- Fitur Chat untuk sistem telepon dengan integrasi Chat service Roblox

local ChatFeature = {}
ChatFeature.__index = ChatFeature

-- Services
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- Chat Variables
local chatMessages = {}
local currentChatChannel = "Global"
local chatChannels = {"Global", "Team", "Private"}

-- Create Chat Message Bubble
local function createMessageBubble(parent, messageData, isOwnMessage)
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(1, -20, 0, 0)
    messageFrame.BackgroundTransparency = 1
    messageFrame.Parent = parent
    
    -- Message bubble
    local bubble = Instance.new("Frame")
    bubble.Name = "Bubble"
    bubble.Size = UDim2.new(0.7, 0, 0, 0)
    bubble.BackgroundColor3 = isOwnMessage and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(60, 60, 60)
    bubble.BorderSizePixel = 0
    bubble.Parent = messageFrame
    
    -- Position bubble based on message ownership
    if isOwnMessage then
        bubble.Position = UDim2.new(0.3, 0, 0, 0)
    else
        bubble.Position = UDim2.new(0, 0, 0, 0)
    end
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = bubble
    
    -- Sender name (only for other messages)
    if not isOwnMessage then
        local senderLabel = Instance.new("TextLabel")
        senderLabel.Name = "Sender"
        senderLabel.Size = UDim2.new(1, 0, 0, 20)
        senderLabel.Position = UDim2.new(0, 10, 0, 5)
        senderLabel.BackgroundTransparency = 1
        senderLabel.Text = messageData.sender
        senderLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        senderLabel.TextScaled = true
        senderLabel.Font = Enum.Font.GothamBold
        senderLabel.TextXAlignment = Enum.TextXAlignment.Left
        senderLabel.Parent = bubble
    end
    
    -- Message text
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, isOwnMessage and 5 or 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = messageData.text
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = bubble
    
    -- Calculate text size
    local textSize = TextService:GetTextSize(
        messageData.text,
        messageLabel.TextSize,
        messageLabel.Font,
        Vector2.new(300, math.huge)
    )
    
    -- Adjust bubble and frame size
    local bubbleHeight = math.max(40, textSize.Y + (isOwnMessage and 10 or 30))
    bubble.Size = UDim2.new(0.7, 0, 0, bubbleHeight)
    messageFrame.Size = UDim2.new(1, -20, 0, bubbleHeight + 10)
    
    -- Timestamp
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Time"
    timeLabel.Size = UDim2.new(0, 100, 0, 15)
    timeLabel.Position = UDim2.new(0, 10, 1, -20)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = messageData.time
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = messageFrame
    
    -- Animation for new message
    bubble.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(bubble, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0.7, 0, 0, bubbleHeight)
    })
    tween:Play()
    
    return messageFrame
end

-- Create Chat Input
local function createChatInput(parent)
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "ChatInput"
    inputFrame.Size = UDim2.new(1, 0, 0, 60)
    inputFrame.Position = UDim2.new(0, 0, 1, -60)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = parent
    
    -- Rounded top corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = inputFrame
    
    -- Text input
    local textBox = Instance.new("TextBox")
    textBox.Name = "MessageInput"
    textBox.Size = UDim2.new(1, -120, 1, -20)
    textBox.Position = UDim2.new(0, 10, 0, 10)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.BorderSizePixel = 0
    textBox.Text = ""
    textBox.PlaceholderText = "Type your message..."
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextScaled = true
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = textBox
    
    -- Send button
    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendButton"
    sendBtn.Size = UDim2.new(0, 80, 0, 40)
    sendBtn.Position = UDim2.new(1, -90, 0, 10)
    sendBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "📤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextScaled = true
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.Parent = inputFrame
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 10)
    sendCorner.Parent = sendBtn
    
    -- Send button hover effect
    sendBtn.MouseEnter:Connect(function()
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end)
    
    sendBtn.MouseLeave:Connect(function()
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    end)
    
    -- Send message function
    local function sendMessage()
        local messageText = textBox.Text
        if messageText and messageText ~= "" then
            local messageData = {
                sender = Players.LocalPlayer.Name,
                text = messageText,
                time = os.date("%H:%M"),
                channel = currentChatChannel
            }
            
            -- Add to chat messages
            table.insert(chatMessages, messageData)
            
            -- Clear input
            textBox.Text = ""
            
            -- Send to Roblox chat (if enabled)
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = messageText,
                Color = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                FontSize = Enum.FontSize.Size18
            })
            
            print("💬 Message sent: " .. messageText)
        end
    end
    
    -- Connect send button
    sendBtn.MouseButton1Click:Connect(sendMessage)
    
    -- Connect enter key
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    return inputFrame, textBox, sendBtn
end

-- Create Channel Selector
local function createChannelSelector(parent)
    local channelFrame = Instance.new("Frame")
    channelFrame.Name = "ChannelSelector"
    channelFrame.Size = UDim2.new(1, 0, 0, 50)
    channelFrame.Position = UDim2.new(0, 0, 0, 0)
    channelFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    channelFrame.BorderSizePixel = 0
    channelFrame.Parent = parent
    
    -- Rounded bottom corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = channelFrame
    
    -- Channel buttons
    for i, channel in ipairs(chatChannels) do
        local channelBtn = Instance.new("TextButton")
        channelBtn.Name = channel .. "Channel"
        channelBtn.Size = UDim2.new(1/#chatChannels, -10, 1, -10)
        channelBtn.Position = UDim2.new((i-1) * (1/#chatChannels), 5, 0, 5)
        channelBtn.BackgroundColor3 = currentChatChannel == channel and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(70, 70, 70)
        channelBtn.BorderSizePixel = 0
        channelBtn.Text = channel
        channelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        channelBtn.TextScaled = true
        channelBtn.Font = Enum.Font.GothamBold
        channelBtn.Parent = channelFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = channelBtn
        
        -- Channel button click
        channelBtn.MouseButton1Click:Connect(function()
            currentChatChannel = channel
            
            -- Update all channel buttons
            for _, child in pairs(channelFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    if child.Name:find(channel) then
                        child.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
                    else
                        child.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    end
                end
            end
            
            print("💬 Switched to " .. channel .. " channel")
        end)
    end
    
    return channelFrame
end

-- Create Chat Feature UI
function ChatFeature:CreateUI(parent)
    -- Channel selector
    local channelSelector = createChannelSelector(parent)
    
    -- Chat messages area
    local messagesFrame = Instance.new("ScrollingFrame")
    messagesFrame.Name = "MessagesFrame"
    messagesFrame.Size = UDim2.new(1, 0, 1, -110)
    messagesFrame.Position = UDim2.new(0, 0, 0, 50)
    messagesFrame.BackgroundTransparency = 1
    messagesFrame.BorderSizePixel = 0
    messagesFrame.ScrollBarThickness = 8
    messagesFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    messagesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    messagesFrame.Parent = parent
    
    -- Chat input
    local inputFrame, textBox, sendBtn = createChatInput(parent)
    
    -- Add some sample messages
    local sampleMessages = {
        {sender = "Player1", text = "Hello everyone! 👋", time = "10:30", channel = "Global"},
        {sender = "Player2", text = "How's everyone doing?", time = "10:31", channel = "Global"},
        {sender = "Player3", text = "Great! Just playing some games 🎮", time = "10:32", channel = "Global"},
        {sender = Players.LocalPlayer.Name, text = "This chat system is awesome! 💬", time = "10:33", channel = "Global"}
    }
    
    -- Add sample messages to chat
    for _, messageData in ipairs(sampleMessages) do
        table.insert(chatMessages, messageData)
        local isOwnMessage = messageData.sender == Players.LocalPlayer.Name
        createMessageBubble(messagesFrame, messageData, isOwnMessage)
    end
    
    -- Update canvas size
    messagesFrame.CanvasSize = UDim2.new(0, 0, 0, #chatMessages * 80)
    
    -- Auto-scroll to bottom
    messagesFrame.CanvasPosition = Vector2.new(0, messagesFrame.CanvasSize.Y.Offset)
    
    -- Simulate incoming messages
    spawn(function()
        while true do
            wait(math.random(10, 30))
            
            local randomMessages = {
                "Anyone want to play together?",
                "This game is so fun! 🎉",
                "Check out my new build!",
                "Need help with something?",
                "Great job everyone! 👏"
            }
            
            local randomSenders = {"Player4", "Player5", "Player6", "Player7", "Player8"}
            
            local newMessage = {
                sender = randomSenders[math.random(1, #randomSenders)],
                text = randomMessages[math.random(1, #randomMessages)],
                time = os.date("%H:%M"),
                channel = currentChatChannel
            }
            
            table.insert(chatMessages, newMessage)
            createMessageBubble(messagesFrame, newMessage, false)
            
            -- Update canvas size and scroll
            messagesFrame.CanvasSize = UDim2.new(0, 0, 0, #chatMessages * 80)
            messagesFrame.CanvasPosition = Vector2.new(0, messagesFrame.CanvasSize.Y.Offset)
        end
    end)
    
    return parent
end

return ChatFeature