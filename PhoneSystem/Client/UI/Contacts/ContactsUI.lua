-- ContactsUI.lua
-- UI untuk sistem kontak dan pencarian pemain

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local PhoneConfig = require(script.Parent.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Parent.Shared.PhoneTypes)
local UIScale = require(script.Parent.Parent.Parent.Shared.Utils.UIScale)

local ContactsUI = {}

-- Create contacts screen
function ContactsUI.createContactsScreen(parent)
    local scale, deviceType = UIScale.calculateScale()
    
    local contactsScreen = Instance.new("Frame")
    contactsScreen.Name = "ContactsScreen"
    contactsScreen.BackgroundTransparency = 1
    contactsScreen.Size = UDim2.new(1, 0, 1, -48 * scale)
    contactsScreen.Position = UDim2.new(0, 0, 0, 24 * scale)
    contactsScreen.Visible = false
    contactsScreen.Parent = parent
    
    -- Header
    ContactsUI.createHeader(contactsScreen, scale, deviceType)
    
    -- Search bar
    ContactsUI.createSearchBar(contactsScreen, scale, deviceType)
    
    -- Contacts list
    ContactsUI.createContactsList(contactsScreen, scale, deviceType)
    
    -- Floating action button
    ContactsUI.createFloatingActionButton(contactsScreen, scale, deviceType)
    
    return contactsScreen
end

-- Create header with title and back button
function ContactsUI.createHeader(parent, scale, deviceType)
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
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Contacts"
    titleLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    titleLabel.TextScaled = true
    titleLabel.Font = PhoneConfig.UI.FONTS.HEADER
    titleLabel.TextSize = UIScale.getFontSize(18, deviceType)
    titleLabel.Size = UDim2.new(1, -112 * scale, 1, 0)
    titleLabel.Position = UDim2.new(0, 56 * scale, 0, 0)
    titleLabel.Parent = header
    
    -- Add back button functionality
    backButton.MouseButton1Click:Connect(function()
        ContactsUI.goBack()
    end)
end

-- Create search bar
function ContactsUI.createSearchBar(parent, scale, deviceType)
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    searchContainer.BorderSizePixel = 0
    searchContainer.Size = UDim2.new(1, -32 * scale, 0, 48 * scale)
    searchContainer.Position = UDim2.new(0, 16 * scale, 0, 72 * scale)
    searchContainer.Parent = parent
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 24 * scale)
    searchCorner.Parent = searchContainer
    
    -- Search icon
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    searchIcon.TextScaled = true
    searchIcon.Font = PhoneConfig.UI.FONTS.BODY
    searchIcon.TextSize = UIScale.getFontSize(16, deviceType)
    searchIcon.Size = UDim2.new(0, 24 * scale, 0, 24 * scale)
    searchIcon.Position = UDim2.new(0, 12 * scale, 0.5, -12 * scale)
    searchIcon.Parent = searchContainer
    
    -- Search text box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search contacts..."
    searchBox.PlaceholderColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    searchBox.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    searchBox.TextScaled = true
    searchBox.Font = PhoneConfig.UI.FONTS.BODY
    searchBox.TextSize = UIScale.getFontSize(14, deviceType)
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Size = UDim2.new(1, -48 * scale, 1, 0)
    searchBox.Position = UDim2.new(0, 48 * scale, 0, 0)
    searchBox.Parent = searchContainer
    
    -- Add search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        ContactsUI.searchContacts(searchBox.Text)
    end)
end

-- Create contacts list
function ContactsUI.createContactsList(parent, scale, deviceType)
    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Name = "ContactsList"
    listContainer.BackgroundTransparency = 1
    listContainer.BorderSizePixel = 0
    listContainer.Size = UDim2.new(1, -32 * scale, 1, -136 * scale)
    listContainer.Position = UDim2.new(0, 16 * scale, 0, 136 * scale)
    listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    listContainer.ScrollBarThickness = 4 * scale
    listContainer.ScrollBarImageColor3 = PhoneConfig.UI.COLORS.PRIMARY
    listContainer.Parent = parent
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2 * scale)
    listLayout.Parent = listContainer
    
    -- Create contact items
    ContactsUI.populateContactsList(listContainer, scale, deviceType)
    
    return listContainer
end

-- Populate contacts list
function ContactsUI.populateContactsList(listContainer, scale, deviceType)
    -- Clear existing contacts
    for _, child in pairs(listContainer:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    
    -- Get all players
    local players = Players:GetPlayers()
    local contacts = {}
    
    for _, player in pairs(players) do
        if player ~= Players.LocalPlayer then
            local contact = {
                userId = player.UserId,
                username = player.Name,
                displayName = player.DisplayName,
                isOnline = true,
                lastSeen = tick()
            }
            table.insert(contacts, contact)
        end
    end
    
    -- Sort contacts alphabetically
    table.sort(contacts, function(a, b)
        return a.displayName < b.displayName
    end)
    
    -- Create contact items
    for i, contact in pairs(contacts) do
        local contactItem = ContactsUI.createContactItem(contact, i, scale, deviceType)
        contactItem.Parent = listContainer
    end
    
    -- Update canvas size
    local listLayout = listContainer:FindFirstChild("UIListLayout")
    if listLayout then
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            listContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
    end
end

-- Create individual contact item
function ContactsUI.createContactItem(contact, index, scale, deviceType)
    local contactFrame = Instance.new("Frame")
    contactFrame.Name = "ContactItem" .. index
    contactFrame.BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE
    contactFrame.BorderSizePixel = 0
    contactFrame.Size = UDim2.new(1, 0, 0, 64 * scale)
    contactFrame.Parent = parent
    
    local contactCorner = Instance.new("UICorner")
    contactCorner.CornerRadius = UDim.new(0, 8 * scale)
    contactCorner.Parent = contactFrame
    
    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Size = UDim2.new(0, 40 * scale, 0, 40 * scale)
    avatar.Position = UDim2.new(0, 12 * scale, 0.5, -20 * scale)
    avatar.Parent = contactFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatar
    
    -- Online indicator
    local onlineIndicator = Instance.new("Frame")
    onlineIndicator.Name = "OnlineIndicator"
    onlineIndicator.BackgroundColor3 = contact.isOnline and PhoneConfig.UI.COLORS.SUCCESS or PhoneConfig.UI.COLORS.ERROR
    onlineIndicator.BorderSizePixel = 0
    onlineIndicator.Size = UDim2.new(0, 12 * scale, 0, 12 * scale)
    onlineIndicator.Position = UDim2.new(0, 44 * scale, 0, 44 * scale)
    onlineIndicator.Parent = contactFrame
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0.5, 0)
    indicatorCorner.Parent = onlineIndicator
    
    -- Contact name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = contact.displayName or contact.username
    nameLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    nameLabel.TextScaled = true
    nameLabel.Font = PhoneConfig.UI.FONTS.BODY
    nameLabel.TextSize = UIScale.getFontSize(14, deviceType)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Size = UDim2.new(1, -120 * scale, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 64 * scale, 0, 8 * scale)
    nameLabel.Parent = contactFrame
    
    -- Username
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. contact.username
    usernameLabel.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    usernameLabel.TextTransparency = 0.6
    usernameLabel.TextScaled = true
    usernameLabel.Font = PhoneConfig.UI.FONTS.BODY
    usernameLabel.TextSize = UIScale.getFontSize(12, deviceType)
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Size = UDim2.new(1, -120 * scale, 0.5, 0)
    usernameLabel.Position = UDim2.new(0, 64 * scale, 0.5, -8 * scale)
    usernameLabel.Parent = contactFrame
    
    -- Action buttons container
    local actionButtons = Instance.new("Frame")
    actionButtons.Name = "ActionButtons"
    actionButtons.BackgroundTransparency = 1
    actionButtons.Size = UDim2.new(0, 80 * scale, 0, 32 * scale)
    actionButtons.Position = UDim2.new(1, -92 * scale, 0.5, -16 * scale)
    actionButtons.Parent = contactFrame
    
    -- Call button
    local callButton = Instance.new("TextButton")
    callButton.Name = "CallButton"
    callButton.BackgroundColor3 = PhoneConfig.UI.COLORS.SUCCESS
    callButton.BorderSizePixel = 0
    callButton.Text = "📞"
    callButton.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    callButton.TextScaled = true
    callButton.Font = PhoneConfig.UI.FONTS.BODY
    callButton.TextSize = UIScale.getFontSize(14, deviceType)
    callButton.Size = UDim2.new(0, 32 * scale, 1, 0)
    callButton.Position = UDim2.new(0, 0, 0, 0)
    callButton.Parent = actionButtons
    
    local callCorner = Instance.new("UICorner")
    callCorner.CornerRadius = UDim.new(0, 16 * scale)
    callCorner.Parent = callButton
    
    -- Message button
    local messageButton = Instance.new("TextButton")
    messageButton.Name = "MessageButton"
    messageButton.BackgroundColor3 = PhoneConfig.UI.COLORS.PRIMARY
    messageButton.BorderSizePixel = 0
    messageButton.Text = "💬"
    messageButton.TextColor3 = PhoneConfig.UI.COLORS.ON_PRIMARY
    messageButton.TextScaled = true
    messageButton.Font = PhoneConfig.UI.FONTS.BODY
    messageButton.TextSize = UIScale.getFontSize(14, deviceType)
    messageButton.Size = UDim2.new(0, 32 * scale, 1, 0)
    messageButton.Position = UDim2.new(0, 40 * scale, 0, 0)
    messageButton.Parent = actionButtons
    
    local messageCorner = Instance.new("UICorner")
    messageCorner.CornerRadius = UDim.new(0, 16 * scale)
    messageCorner.Parent = messageButton
    
    -- Add click functionality
    callButton.MouseButton1Click:Connect(function()
        ContactsUI.startCall(contact)
    end)
    
    messageButton.MouseButton1Click:Connect(function()
        ContactsUI.startChat(contact)
    end)
    
    -- Add hover effects
    ContactsUI.addHoverEffects(contactFrame, callButton, messageButton)
    
    return contactFrame
end

-- Create floating action button
function ContactsUI.createFloatingActionButton(parent, scale, deviceType)
    local fab = Instance.new("TextButton")
    fab.Name = "FloatingActionButton"
    fab.BackgroundColor3 = PhoneConfig.UI.COLORS.ACCENT
    fab.BorderSizePixel = 0
    fab.Text = "+"
    fab.TextColor3 = PhoneConfig.UI.COLORS.ON_SURFACE
    fab.TextScaled = true
    fab.Font = PhoneConfig.UI.FONTS.HEADER
    fab.TextSize = UIScale.getFontSize(24, deviceType)
    fab.Size = UDim2.new(0, 56 * scale, 0, 56 * scale)
    fab.Position = UDim2.new(1, -72 * scale, 1, -72 * scale)
    fab.Parent = parent
    
    local fabCorner = Instance.new("UICorner")
    fabCorner.CornerRadius = UDim.new(0.5, 0)
    fabCorner.Parent = fab
    
    -- Add shadow
    local fabShadow = Instance.new("Frame")
    fabShadow.Name = "Shadow"
    fabShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fabShadow.BackgroundTransparency = 0.7
    fabShadow.BorderSizePixel = 0
    fabShadow.Size = UDim2.new(1, 4, 1, 4)
    fabShadow.Position = UDim2.new(0, -2, 0, -2)
    fabShadow.ZIndex = fab.ZIndex - 1
    fabShadow.Parent = parent
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0.5, 0)
    shadowCorner.Parent = fabShadow
    
    -- Add click functionality
    fab.MouseButton1Click:Connect(function()
        ContactsUI.showAddContactDialog()
    end)
    
    -- Add rotation animation on click
    fab.MouseButton1Click:Connect(function()
        local rotateTween = TweenService:Create(
            fab,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Rotation = fab.Rotation + 45}
        )
        rotateTween:Play()
    end)
end

-- Add hover effects to contact items
function ContactsUI.addHoverEffects(contactFrame, callButton, messageButton)
    contactFrame.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            contactFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = PhoneConfig.UI.COLORS.BACKGROUND}
        )
        hoverTween:Play()
    end)
    
    contactFrame.MouseLeave:Connect(function()
        local unhoverTween = TweenService:Create(
            contactFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = PhoneConfig.UI.COLORS.SURFACE}
        )
        unhoverTween:Play()
    end)
end

-- Search contacts function
function ContactsUI.searchContacts(searchTerm)
    print("Searching for:", searchTerm)
    -- This will be implemented with the contact service
end

-- Navigation functions
function ContactsUI.goBack()
    print("Going back from contacts")
    -- This will be handled by the PhoneController
end

function ContactsUI.startCall(contact)
    print("Starting call with:", contact.username)
    -- This will be handled by the CallController
end

function ContactsUI.startChat(contact)
    print("Starting chat with:", contact.username)
    -- This will be handled by the ChatController
end

function ContactsUI.showAddContactDialog()
    print("Showing add contact dialog")
    -- This will be implemented later
end

-- Show/hide contacts screen
function ContactsUI.showContactsScreen(contactsScreen)
    contactsScreen.Visible = true
    local slideTween = TweenService:Create(
        contactsScreen,
        TweenInfo.new(PhoneConfig.UI.ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 24)}
    )
    slideTween:Play()
end

function ContactsUI.hideContactsScreen(contactsScreen)
    local slideTween = TweenService:Create(
        contactsScreen,
        TweenInfo.new(PhoneConfig.UI.ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(-1, 0, 0, 24)}
    )
    slideTween:Play()
    slideTween.Completed:Connect(function()
        contactsScreen.Visible = false
    end)
end

return ContactsUI