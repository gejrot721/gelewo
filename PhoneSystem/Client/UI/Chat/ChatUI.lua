-- ChatUI.lua
-- UI untuk sistem chat dan pesan teks

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local PhoneConfig = require(script.Parent.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Parent.Shared.PhoneTypes)
local UIScale = require(script.Parent.Parent.Parent.Shared.Utils.UIScale)

local ChatUI = {}

-- Create chat screen
function ChatUI.createChatScreen(parent)
    local scale, deviceType = UIScale.calculateScale()
    
    local chatScreen = Instance.new("Frame")
    chatScreen.Name = "ChatScreen"
    chatScreen.BackgroundTransparency = 1
    chatScreen.Size = UDim2.new(1, 0, 1, -48 * scale)
    chatScreen.Position = UDim2.new(0, 0, 0, 24 * scale)
    chatScreen.Visible = false
    chatScreen.Parent = parent
    
    -- Header
    ChatUI.createHeader(chatScreen, scale, deviceType)
    
    -- Messages area
    ChatUI.createMessagesArea(chatScreen, scale, deviceType)
    
    -- Input area
    ChatUI.createInputArea(chatScreen, scale, deviceType)
    
    return chatScreen
end

-- Create chat header
function ChatUI.createHeader(parent, scale, deviceType)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 56 * scale)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Parent = parent
    
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
    backButton.Position = UDim2.new(0, 0, 0, 0)
    backButton.Parent = header
    
    -- Contact info
    local contactInfo = Instance.new("Frame")
    contactInfo.Name = "ContactInfo"
    contactInfo.BackgroundTransparency = 1
    contactInfo.Size = UDim2.new(1, -112 * scale, 1, 0)
    contactInfo.Position = UDim2.new(0, 56 * scale, 0, 0)
    contactInfo.Parent = header
    
    -- Contact avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Size = UDim2.new(0, 32 * scale, 0, 32 * scale)
    avatar.Position = UDim2.new(0, 8 * scale, 0.5, -16 * scale)
    avatar.Parent = contactInfo
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar
    
    -- Online indicator
    local onlineIndicator = Instance.new("Frame")
    onlineIndicator.Name = "OnlineIndicator"
    onlineIndicator.BackgroundColor3 = PhoneConfig.UI.COLORS.SUCCESS
    onlineIndicator.BorderSizePixel = 0
    onlineIndicator.Size = UDim2.new(0, 8 * scale, 0, 8 * scale)
    onlineIndicator.Position = UDim2.new(0, 32 * scale, 0, 32 * scale)
    onlineIndicator.Parent = contactInfo
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0.5, 0)
    indicatorCorner.Parent = onlineIndicator
    
    -- Contact name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Contact Name"
    nameLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    nameLabel.TextScaled = true
    nameLabel.Font = PhoneConfig.UI.FONTS.HEADER
    nameLabel.TextSize = UIScale.getFontSize(16, deviceType)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Size = UDim2.new(1, -48 * scale, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 48 * scale, 0, 4 * scale)
    nameLabel.Parent = contactInfo
    
    -- Status text
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Online"
    statusLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    statusLabel.TextTransparency = 0.6
    statusLabel.TextScaled = true
    statusLabel.Font = PhoneConfig.UI.FONTS.BODY
    statusLabel.TextSize = UIScale.getFontSize(12, deviceType)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Size = UDim2.new(1, -48 * scale, 0.5, 0)
    statusLabel.Position = UDim2.new(0, 48 * scale, 0.5, -4 * scale)
    statusLabel.Parent = contactInfo
    
    -- More options button
    local moreButton = Instance.new("TextButton")
    moreButton.Name = "MoreButton"
    moreButton.BackgroundTransparency = 1
    moreButton.Text = "⋮"
    moreButton.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    moreButton.TextScaled = true
    moreButton.Font = PhoneConfig.UI.FONTS.BODY
    moreButton.TextSize = UIScale.getFontSize(20, deviceType)
    moreButton.Size = UDim2.new(0, 56 * scale, 0, 56 * scale)
    moreButton.Position = UDim2.new(1, -56 * scale, 0, 0)
    moreButton.Parent = header
    
    -- Add button functionality
    backButton.MouseButton1Click:Connect(function()
        ChatUI.goBack()
    end)
    
    moreButton.MouseButton1Click:Connect(function()
        ChatUI.showMoreOptions()
    end)
end

-- Create messages area
function ChatUI.createMessagesArea(parent, scale, deviceType)
    local messagesContainer = Instance.new("ScrollingFrame")
    messagesContainer.Name = "MessagesContainer"
    messagesContainer.BackgroundTransparency = 1
    messagesContainer.BorderSizePixel = 0
    messagesContainer.Size = UDim2.new(1, 0, 1, -120 * scale)
    messagesContainer.Position = UDim2.new(0, 0, 0, 56 * scale)
    messagesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    messagesContainer.ScrollBarThickness = 4 * scale
    messagesContainer.ScrollBarImageColor3 = PhoneConfig.UI.COLORS.PRIMARY
    messagesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    messagesContainer.ScrollBarImageTransparency = 0.5
    messagesContainer.Parent = parent
    
    local messagesLayout = Instance.new("UIListLayout")
    messagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    messagesLayout.Padding = UDim.new(0, 8 * scale)
    messagesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    messagesLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    messagesLayout.Parent = messagesContainer
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 16 * scale)
    padding.PaddingBottom = UDim.new(0, 16 * scale)
    padding.PaddingLeft = UDim.new(0, 16 * scale)
    padding.PaddingRight = UDim.new(0, 16 * scale)
    padding.Parent = messagesContainer
    
    return messagesContainer
end

-- Create input area
function ChatUI.createInputArea(parent, scale, deviceType)
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    inputContainer.BorderSizePixel = 0
    inputContainer.Size = UDim2.new(1, 0, 0, 64 * scale)
    inputContainer.Position = UDim2.new(0, 0, 1, -64 * scale)
    inputContainer.Parent = parent
    
    -- Input frame
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.BackgroundColor3 = PhoneConfig.UI.COLORS.BACKGROUND
    inputFrame.BorderSizePixel = 0
    inputFrame.Size = UDim2.new(1, -80 * scale, 0, 40 * scale)
    inputFrame.Position = UDim2.new(0, 16 * scale, 0.5, -20 * scale)
    inputFrame.Parent = inputContainer
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 20 * scale)
    inputCorner.Parent = inputFrame
    
    -- Message input
    local messageInput = Instance.new("TextBox")
    messageInput.Name = "MessageInput"
    messageInput.BackgroundTransparency = 1
    messageInput.Text = ""
    messageInput.PlaceholderText = "Type a message..."
    messageInput.PlaceholderColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    messageInput.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    messageInput.TextScaled = true
    messageInput.Font = PhoneConfig.UI.FONTS.BODY
    messageInput.TextSize = UIScale.getFontSize(14, deviceType)
    messageInput.TextXAlignment = Enum.TextXAlignment.Left
    messageInput.Size = UDim2.new(1, -16 * scale, 1, 0)
    messageInput.Position = UDim2.new(0, 16 * scale, 0, 0)
    messageInput.Parent = inputFrame
    
    -- Send button
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    sendButton.BorderSizePixel = 0
    sendButton.Text = "📤"
    sendButton.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    sendButton.TextScaled = true
    sendButton.Font = PhoneConfig.UI.FONTS.BODY
    sendButton.TextSize = UIScale.getFontSize(16, deviceType)
    sendButton.Size = UDim2.new(0, 48 * scale, 0, 48 * scale)
    sendButton.Position = UDim2.new(1, -64 * scale, 0.5, -24 * scale)
    sendButton.Parent = inputContainer
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0.5, 0)
    sendCorner.Parent = sendButton
    
    -- Add send functionality
    sendButton.MouseButton1Click:Connect(function()
        ChatUI.sendMessage(messageInput.Text)
        messageInput.Text = ""
    end)
    
    -- Send on Enter key
    messageInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and messageInput.Text:gsub("%s+", "") ~= "" then
            ChatUI.sendMessage(messageInput.Text)
            messageInput.Text = ""
        end
    end)
    
    return inputContainer
end

-- Create message bubble
function ChatUI.createMessageBubble(message, isOwnMessage, scale, deviceType)
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageBubble"
    messageFrame.BackgroundTransparency = 1
    messageFrame.Size = UDim2.new(1, -32 * scale, 0, 0)
    messageFrame.AutomaticSize = Enum.AutomaticSize.Y
    messageFrame.Parent = parent
    
    local bubbleContainer = Instance.new("Frame")
    bubbleContainer.Name = "BubbleContainer"
    bubbleContainer.BackgroundColor3 = isOwnMessage and PhoneConfig.UI.COLORS.PRIMARY or PhoneConfig.UI.COLORS.SURFACE
    bubbleContainer.BorderSizePixel = 0
    bubbleContainer.Size = UDim2.new(0, 0, 0, 0)
    bubbleContainer.AutomaticSize = Enum.AutomaticSize.XY
    bubbleContainer.Parent = messageFrame
    
    -- Position bubble based on message ownership
    if isOwnMessage then
        bubbleContainer.Position = UDim2.new(1, -16 * scale, 0, 0)
        bubbleContainer.AnchorPoint = Vector2.new(1, 0)
    else
        bubbleContainer.Position = UDim2.new(0, 16 * scale, 0, 0)
    end
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(0, 16 * scale)
    bubbleCorner.Parent = bubbleContainer
    
    -- Message text
    local messageText = Instance.new("TextLabel")
    messageText.Name = "MessageText"
    messageText.BackgroundTransparency = 1
    messageText.Text = message.content
    messageText.TextColor3 = isOwnMessage and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.ON_SURFACE
    messageText.TextScaled = true
    messageText.Font = PhoneConfig.UI.FONTS.BODY
    messageText.TextSize = UIScale.getFontSize(14, deviceType)
    messageText.TextWrapped = true
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Top
    messageText.Size = UDim2.new(0, 0, 0, 0)
    messageText.AutomaticSize = Enum.AutomaticSize.XY
    messageText.Parent = bubbleContainer
    
    -- Add padding to text
    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingTop = UDim.new(0, 8 * scale)
    textPadding.PaddingBottom = UDim.new(0, 8 * scale)
    textPadding.PaddingLeft = UDim.new(0, 12 * scale)
    textPadding.PaddingRight = UDim.new(0, 12 * scale)
    textPadding.Parent = bubbleContainer
    
    -- Time label
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = ChatUI.formatTime(message.timestamp)
    timeLabel.TextColor3 = isOwnMessage and PhoneConfig.UI.COLORS.ON_PRIMARY or PhoneConfig.UI.COLORS.ON_SURFACE
    timeLabel.TextTransparency = 0.6
    timeLabel.TextScaled = true
    timeLabel.Font = PhoneConfig.UI.FONTS.BODY
    timeLabel.TextSize = UIScale.getFontSize(10, deviceType)
    timeLabel.Size = UDim2.new(1, 0, 0, 16 * scale)
    timeLabel.Position = UDim2.new(0, 0, 1, 0)
    timeLabel.Parent = messageFrame
    
    -- Add read indicator for own messages
    if isOwnMessage then
        local readIndicator = Instance.new("TextLabel")
        readIndicator.Name = "ReadIndicator"
        readIndicator.BackgroundTransparency = 1
        readIndicator.Text = message.isRead and "✓✓" or "✓"
        readIndicator.TextColor3 = message.isRead and PhoneConfig.UI.COLORS.SUCCESS or PhoneConfig.UI.COLORS.ON_PRIMARY
        readIndicator.TextTransparency = 0.6
        readIndicator.TextScaled = true
        readIndicator.Font = PhoneConfig.UI.FONTS.BODY
        readIndicator.TextSize = UIScale.getFontSize(10, deviceType)
        readIndicator.Size = UDim2.new(0, 20 * scale, 0, 16 * scale)
        readIndicator.Position = UDim2.new(1, -20 * scale, 1, 0)
        readIndicator.Parent = messageFrame
    end
    
    return messageFrame
end

-- Add message to chat
function ChatUI.addMessage(messagesContainer, message, isOwnMessage, scale, deviceType)
    local messageBubble = ChatUI.createMessageBubble(message, isOwnMessage, scale, deviceType)
    messageBubble.Parent = messagesContainer
    
    -- Animate message appearance
    messageBubble.Size = UDim2.new(1, -32 * scale, 0, 0)
    messageBubble.BackgroundTransparency = 1
    
    local appearTween = TweenService:Create(
        messageBubble,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    
    -- Auto scroll to bottom
    wait(0.1)
    messagesContainer.CanvasPosition = Vector2.new(0, messagesContainer.CanvasSize.Y.Offset)
    
    appearTween:Play()
end

-- Format timestamp
function ChatUI.formatTime(timestamp)
    local currentTime = tick()
    local timeDiff = currentTime - timestamp
    
    if timeDiff < 60 then
        return "Just now"
    elseif timeDiff < 3600 then
        return math.floor(timeDiff / 60) .. "m ago"
    elseif timeDiff < 86400 then
        return math.floor(timeDiff / 3600) .. "h ago"
    else
        return os.date("%m/%d", timestamp)
    end
end

-- Navigation and action functions
function ChatUI.goBack()
    print("Going back from chat")
    -- This will be handled by the PhoneController
end

function ChatUI.sendMessage(messageText)
    if messageText:gsub("%s+", "") == "" then
        return
    end
    
    print("Sending message:", messageText)
    -- This will be handled by the ChatController
end

function ChatUI.showMoreOptions()
    print("Showing more options")
    -- This will show options like call, video call, etc.
end

-- Show/hide chat screen
function ChatUI.showChatScreen(chatScreen)
    chatScreen.Visible = true
    local slideTween = TweenService:Create(
        chatScreen,
        TweenInfo.new(PhoneConfig.UI.ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 24)}
    )
    slideTween:Play()
end

function ChatUI.hideChatScreen(chatScreen)
    local slideTween = TweenService:Create(
        chatScreen,
        TweenInfo.new(PhoneConfig.UI.ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 0, 0, 24)}
    )
    slideTween:Play()
    slideTween.Completed:Connect(function()
        chatScreen.Visible = false
    end)
end

-- Update contact info in header
function ChatUI.updateContactInfo(contact)
    -- This will update the contact info in the chat header
    print("Updating contact info for:", contact.username)
end

return ChatUI