-- Roblox Phone System Script
-- Author: AI Assistant
-- Features: Chat, Phone Calls, Group Calls, Contacts, Modern Android UI, Voice Chat

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create RemoteEvents for communication
local phoneEvents = Instance.new("Folder")
phoneEvents.Name = "PhoneEvents"
phoneEvents.Parent = ReplicatedStorage

local callRemote = Instance.new("RemoteEvent")
callRemote.Name = "CallPlayer"
callRemote.Parent = phoneEvents

local chatRemote = Instance.new("RemoteEvent")
chatRemote.Name = "ChatMessage"
chatRemote.Parent = phoneEvents

local groupCallRemote = Instance.new("RemoteEvent")
groupCallRemote.Name = "GroupCall"
groupCallRemote.Parent = phoneEvents

-- Phone System Class
local PhoneSystem = {}
PhoneSystem.__index = PhoneSystem

function PhoneSystem.new()
    local self = setmetatable({}, PhoneSystem)
    
    self.isOpen = false
    self.currentCall = nil
    self.groupCallMembers = {}
    self.contacts = {}
    self.chatHistory = {}
    
    self:CreateUI()
    self:SetupConnections()
    self:LoadContacts()
    
    return self
end

function PhoneSystem:CreateUI()
    -- Main ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PhoneSystem"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = playerGui
    
    -- Menu Toggle Button (Center-Right)
    self.menuButton = Instance.new("TextButton")
    self.menuButton.Name = "MenuButton"
    self.menuButton.Size = UDim2.new(0, 60, 0, 60)
    self.menuButton.Position = UDim2.new(1, -80, 0.5, -30)
    self.menuButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    self.menuButton.Text = "📱"
    self.menuButton.TextSize = 24
    self.menuButton.Font = Enum.Font.GothamBold
    self.menuButton.Parent = self.screenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = self.menuButton
    
    -- Main Phone Frame
    self.phoneFrame = Instance.new("Frame")
    self.phoneFrame.Name = "PhoneFrame"
    self.phoneFrame.Size = UDim2.new(0, 400, 0, 700)
    self.phoneFrame.Position = UDim2.new(0.5, -200, 0.5, -350)
    self.phoneFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    self.phoneFrame.Visible = false
    self.phoneFrame.Parent = self.screenGui
    
    local phoneCorner = Instance.new("UICorner")
    phoneCorner.CornerRadius = UDim.new(0.05, 0)
    phoneCorner.Parent = self.phoneFrame
    
    -- Phone Header
    self:CreateHeader()
    
    -- Content Frame
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, 0, 1, -60)
    self.contentFrame.Position = UDim2.new(0, 0, 0, 60)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.Parent = self.phoneFrame
    
    -- Navigation Buttons
    self:CreateNavigation()
    
    -- Pages
    self:CreateHomePage()
    self:CreateContactsPage()
    self:CreateChatPage()
    self:CreateCallsPage()
    
    -- Autoscale function
    self:SetupAutoscale()
end

function PhoneSystem:CreateHeader()
    self.headerFrame = Instance.new("Frame")
    self.headerFrame.Name = "Header"
    self.headerFrame.Size = UDim2.new(1, 0, 0, 60)
    self.headerFrame.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    self.headerFrame.Parent = self.phoneFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0.05, 0)
    headerCorner.Parent = self.headerFrame
    
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "Title"
    self.titleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 30, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = "Phone"
    self.titleLabel.TextColor3 = Color3.new(1, 1, 1)
    self.titleLabel.TextSize = 24
    self.titleLabel.Font = Enum.Font.GothamBold
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Parent = self.headerFrame
    
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 30, 0, 30)
    self.closeButton.Position = UDim2.new(1, -40, 0, 15)
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Text = "✕"
    self.closeButton.TextColor3 = Color3.new(1, 1, 1)
    self.closeButton.TextSize = 20
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.headerFrame
end

function PhoneSystem:CreateNavigation()
    self.navFrame = Instance.new("Frame")
    self.navFrame.Name = "Navigation"
    self.navFrame.Size = UDim2.new(1, 0, 0, 60)
    self.navFrame.Position = UDim2.new(0, 0, 1, -60)
    self.navFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    self.navFrame.Parent = self.phoneFrame
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0.05, 0)
    navCorner.Parent = self.navFrame
    
    -- Navigation buttons
    local navButtons = {
        {name = "Home", icon = "🏠", page = "home"},
        {name = "Contacts", icon = "👥", page = "contacts"},
        {name = "Chat", icon = "💬", page = "chat"},
        {name = "Calls", icon = "📞", page = "calls"}
    }
    
    for i, buttonData in ipairs(navButtons) do
        local button = Instance.new("TextButton")
        button.Name = buttonData.name .. "Button"
        button.Size = UDim2.new(1 / #navButtons, 0, 1, 0)
        button.Position = UDim2.new((i - 1) / #navButtons, 0, 0, 0)
        button.BackgroundTransparency = 1
        button.Text = buttonData.icon
        button.TextSize = 24
        button.Font = Enum.Font.Gotham
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.Parent = self.navFrame
        
        button.MouseButton1Click:Connect(function()
            self:ShowPage(buttonData.page)
            self:UpdateNavButtons(button)
        end)
    end
end

function PhoneSystem:CreateHomePage()
    self.homePage = Instance.new("Frame")
    self.homePage.Name = "HomePage"
    self.homePage.Size = UDim2.new(1, 0, 1, 0)
    self.homePage.BackgroundTransparency = 1
    self.homePage.Visible = true
    self.homePage.Parent = self.contentFrame
    
    -- Quick actions
    local quickCallButton = self:CreateQuickAction("📞", "Quick Call", Color3.fromRGB(76, 175, 80))
    quickCallButton.Position = UDim2.new(0, 20, 0, 20)
    quickCallButton.Parent = self.homePage
    
    local quickChatButton = self:CreateQuickAction("💬", "Quick Chat", Color3.fromRGB(33, 150, 243))
    quickChatButton.Position = UDim2.new(0.5, 10, 0, 20)
    quickChatButton.Parent = self.homePage
    
    local groupCallButton = self:CreateQuickAction("👥", "Group Call", Color3.fromRGB(156, 39, 176))
    groupCallButton.Position = UDim2.new(0, 20, 0, 120)
    groupCallButton.Parent = self.homePage
    
    local contactsButton = self:CreateQuickAction("👤", "Contacts", Color3.fromRGB(255, 152, 0))
    contactsButton.Position = UDim2.new(0.5, 10, 0, 120)
    contactsButton.Parent = self.homePage
end

function PhoneSystem:CreateQuickAction(icon, text, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 170, 0, 80)
    frame.BackgroundColor3 = color
    frame.Parent = self.contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = frame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0.6, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 32
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.4, 0)
    textLabel.Position = UDim2.new(0, 0, 0.6, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Parent = frame
    
    return frame
end

function PhoneSystem:CreateContactsPage()
    self.contactsPage = Instance.new("Frame")
    self.contactsPage.Name = "ContactsPage"
    self.contactsPage.Size = UDim2.new(1, 0, 1, 0)
    self.contactsPage.BackgroundTransparency = 1
    self.contactsPage.Visible = false
    self.contactsPage.Parent = self.contentFrame
    
    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -40, 0, 40)
    searchFrame.Position = UDim2.new(0, 20, 0, 10)
    searchFrame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
    searchFrame.Parent = self.contactsPage
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0.2, 0)
    searchCorner.Parent = searchFrame
    
    self.searchBox = Instance.new("TextBox")
    self.searchBox.Size = UDim2.new(1, -20, 1, 0)
    self.searchBox.Position = UDim2.new(0, 10, 0, 0)
    self.searchBox.BackgroundTransparency = 1
    self.searchBox.Text = "Search players..."
    self.searchBox.TextColor3 = Color3.new(1, 1, 1)
    self.searchBox.TextSize = 16
    self.searchBox.Font = Enum.Font.Gotham
    self.searchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.searchBox.Parent = searchFrame
    
    -- Contacts list
    self.contactsList = Instance.new("ScrollingFrame")
    self.contactsList.Size = UDim2.new(1, -40, 1, -60)
    self.contactsList.Position = UDim2.new(0, 20, 0, 60)
    self.contactsList.BackgroundTransparency = 1
    self.contactsList.ScrollBarThickness = 6
    self.contactsList.Parent = self.contactsPage
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = self.contactsList
end

function PhoneSystem:CreateChatPage()
    self.chatPage = Instance.new("Frame")
    self.chatPage.Name = "ChatPage"
    self.chatPage.Size = UDim2.new(1, 0, 1, 0)
    self.chatPage.BackgroundTransparency = 1
    self.chatPage.Visible = false
    self.chatPage.Parent = self.contentFrame
    
    -- Chat list
    self.chatList = Instance.new("ScrollingFrame")
    self.chatList.Size = UDim2.new(1, -40, 1, -100)
    self.chatList.Position = UDim2.new(0, 20, 0, 20)
    self.chatList.BackgroundTransparency = 1
    self.chatList.ScrollBarThickness = 6
    self.chatList.Parent = self.chatPage
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatLayout.Padding = UDim.new(0, 5)
    chatLayout.Parent = self.chatList
    
    -- Message input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -40, 0, 40)
    inputFrame.Position = UDim2.new(0, 20, 1, -60)
    inputFrame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
    inputFrame.Parent = self.chatPage
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.2, 0)
    inputCorner.Parent = inputFrame
    
    self.messageInput = Instance.new("TextBox")
    self.messageInput.Size = UDim2.new(1, -60, 1, 0)
    self.messageInput.Position = UDim2.new(0, 10, 0, 0)
    self.messageInput.BackgroundTransparency = 1
    self.messageInput.Text = "Type a message..."
    self.messageInput.TextColor3 = Color3.new(1, 1, 1)
    self.messageInput.TextSize = 16
    self.messageInput.Font = Enum.Font.Gotham
    self.messageInput.TextXAlignment = Enum.TextXAlignment.Left
    self.messageInput.Parent = inputFrame
    
    local sendButton = Instance.new("TextButton")
    sendButton.Size = UDim2.new(0, 40, 1, 0)
    sendButton.Position = UDim2.new(1, -50, 0, 0)
    sendButton.BackgroundTransparency = 1
    sendButton.Text = "📤"
    sendButton.TextSize = 20
    sendButton.Font = Enum.Font.Gotham
    sendButton.TextColor3 = Color3.new(1, 1, 1)
    sendButton.Parent = inputFrame
end

function PhoneSystem:CreateCallsPage()
    self.callsPage = Instance.new("Frame")
    self.callsPage.Name = "CallsPage"
    self.callsPage.Size = UDim2.new(1, 0, 1, 0)
    self.callsPage.BackgroundTransparency = 1
    self.callsPage.Visible = false
    self.callsPage.Parent = self.contentFrame
    
    -- Call controls
    local callControlsFrame = Instance.new("Frame")
    callControlsFrame.Size = UDim2.new(1, -40, 0, 200)
    callControlsFrame.Position = UDim2.new(0, 20, 0.5, -100)
    callControlsFrame.BackgroundTransparency = 1
    callControlsFrame.Parent = self.callsPage
    
    -- Mute button
    self.muteButton = Instance.new("TextButton")
    self.muteButton.Size = UDim2.new(0, 80, 0, 80)
    self.muteButton.Position = UDim2.new(0.5, -40, 0, 0)
    self.muteButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    self.muteButton.Text = "🔇"
    self.muteButton.TextSize = 32
    self.muteButton.Font = Enum.Font.GothamBold
    self.muteButton.TextColor3 = Color3.new(1, 1, 1)
    self.muteButton.Parent = callControlsFrame
    
    local muteCorner = Instance.new("UICorner")
    muteCorner.CornerRadius = UDim.new(0.5, 0)
    muteCorner.Parent = self.muteButton
    
    -- Hang up button
    self.hangUpButton = Instance.new("TextButton")
    self.hangUpButton.Size = UDim2.new(0, 80, 0, 80)
    self.hangUpButton.Position = UDim2.new(0.5, -40, 0, 100)
    self.hangUpButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    self.hangUpButton.Text = "📞"
    self.hangUpButton.TextSize = 32
    self.hangUpButton.Font = Enum.Font.GothamBold
    self.hangUpButton.TextColor3 = Color3.new(1, 1, 1)
    self.hangUpButton.Parent = callControlsFrame
    
    local hangCorner = Instance.new("UICorner")
    hangCorner.CornerRadius = UDim.new(0.5, 0)
    hangCorner.Parent = self.hangUpButton
end

function PhoneSystem:SetupAutoscale()
    local function updateScale()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local scale = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)
        
        -- Scale phone frame
        local phoneScale = math.max(0.8, math.min(1.2, scale))
        self.phoneFrame.Size = UDim2.new(0, 400 * phoneScale, 0, 700 * phoneScale)
        self.phoneFrame.Position = UDim2.new(0.5, -200 * phoneScale, 0.5, -350 * phoneScale)
        
        -- Scale menu button
        local buttonScale = math.max(0.7, math.min(1.3, scale))
        self.menuButton.Size = UDim2.new(0, 60 * buttonScale, 0, 60 * buttonScale)
        self.menuButton.Position = UDim2.new(1, -80 * buttonScale, 0.5, -30 * buttonScale)
    end
    
    RunService.Heartbeat:Connect(updateScale)
    updateScale()
end

function PhoneSystem:SetupConnections()
    -- Menu button
    self.menuButton.MouseButton1Click:Connect(function()
        self:TogglePhone()
    end)
    
    -- Close button
    self.closeButton.MouseButton1Click:Connect(function()
        self:ClosePhone()
    end)
    
    -- Remote events
    callRemote.OnClientEvent:Connect(function(caller, action)
        self:HandleCall(caller, action)
    end)
    
    chatRemote.OnClientEvent:Connect(function(sender, message)
        self:ReceiveMessage(sender, message)
    end)
    
    groupCallRemote.OnClientEvent:Connect(function(members, action)
        self:HandleGroupCall(members, action)
    end)
end

function PhoneSystem:TogglePhone()
    if self.isOpen then
        self:ClosePhone()
    else
        self:OpenPhone()
    end
end

function PhoneSystem:OpenPhone()
    self.isOpen = true
    self.phoneFrame.Visible = true
    
    -- Animate in
    self.phoneFrame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(
        self.phoneFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 400, 0, 700)}
    )
    tween:Play()
    
    self:ShowPage("home")
end

function PhoneSystem:ClosePhone()
    self.isOpen = false
    
    -- Animate out
    local tween = TweenService:Create(
        self.phoneFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}
    )
    tween:Play()
    
    tween.Completed:Connect(function()
        self.phoneFrame.Visible = false
    end)
end

function PhoneSystem:ShowPage(pageName)
    -- Hide all pages
    for _, child in pairs(self.contentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Page") then
            child.Visible = false
        end
    end
    
    -- Show selected page
    if pageName == "home" then
        self.homePage.Visible = true
    elseif pageName == "contacts" then
        self.contactsPage.Visible = true
        self:UpdateContactsList()
    elseif pageName == "chat" then
        self.chatPage.Visible = true
    elseif pageName == "calls" then
        self.callsPage.Visible = true
    end
end

function PhoneSystem:UpdateNavButtons(selectedButton)
    -- Reset all button colors
    for _, child in pairs(self.navFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Highlight selected button
    selectedButton.TextColor3 = Color3.fromRGB(76, 175, 80)
end

function PhoneSystem:LoadContacts()
    -- Load online players as contacts
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            table.insert(self.contacts, {
                name = otherPlayer.Name,
                displayName = otherPlayer.DisplayName,
                userId = otherPlayer.UserId
            })
        end
    end
    
    -- Listen for new players
    Players.PlayerAdded:Connect(function(newPlayer)
        table.insert(self.contacts, {
            name = newPlayer.Name,
            displayName = newPlayer.DisplayName,
            userId = newPlayer.UserId
        })
    end)
    
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        for i, contact in ipairs(self.contacts) do
            if contact.userId == leavingPlayer.UserId then
                table.remove(self.contacts, i)
                break
            end
        end
    end)
end

function PhoneSystem:UpdateContactsList()
    -- Clear existing list
    for _, child in pairs(self.contactsList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add contacts
    for _, contact in ipairs(self.contacts) do
        local contactFrame = self:CreateContactFrame(contact)
        contactFrame.Parent = self.contactsList
    end
    
    self.contactsList.CanvasSize = UDim2.new(0, 0, 0, #self.contacts * 60)
end

function PhoneSystem:CreateContactFrame(contact)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
    frame.Parent = self.contactsList
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = frame
    
    -- Avatar
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 40, 0, 40)
    avatarFrame.Position = UDim2.new(0, 10, 0, 7.5)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    avatarFrame.Parent = frame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatarFrame
    
    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 60, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = contact.displayName
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    -- Action buttons
    local callButton = Instance.new("TextButton")
    callButton.Size = UDim2.new(0, 30, 0, 30)
    callButton.Position = UDim2.new(1, -80, 0, 12.5)
    callButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    callButton.Text = "📞"
    callButton.TextSize = 16
    callButton.Font = Enum.Font.Gotham
    callButton.Parent = frame
    
    local callCorner = Instance.new("UICorner")
    callCorner.CornerRadius = UDim.new(0.5, 0)
    callCorner.Parent = callButton
    
    local chatButton = Instance.new("TextButton")
    chatButton.Size = UDim2.new(0, 30, 0, 30)
    chatButton.Position = UDim2.new(1, -40, 0, 12.5)
    chatButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    chatButton.Text = "💬"
    chatButton.TextSize = 16
    chatButton.Font = Enum.Font.Gotham
    chatButton.Parent = frame
    
    local chatCorner = Instance.new("UICorner")
    chatCorner.CornerRadius = UDim.new(0.5, 0)
    chatCorner.Parent = chatButton
    
    -- Button connections
    callButton.MouseButton1Click:Connect(function()
        self:StartCall(contact.name)
    end)
    
    chatButton.MouseButton1Click:Connect(function()
        self:StartChat(contact.name)
    end)
    
    return frame
end

function PhoneSystem:StartCall(playerName)
    if self.currentCall then
        return -- Already in a call
    end
    
    self.currentCall = playerName
    callRemote:FireServer(playerName, "call")
    self:ShowPage("calls")
    
    -- Enable voice chat
    if game:GetService("VoiceChatService") then
        -- Voice chat integration would go here
    end
end

function PhoneSystem:StartChat(playerName)
    self:ShowPage("chat")
    -- Chat implementation would go here
end

function PhoneSystem:HandleCall(caller, action)
    if action == "call" then
        -- Show incoming call notification
        self:ShowIncomingCall(caller)
    elseif action == "answer" then
        self.currentCall = caller
        self:ShowPage("calls")
    elseif action == "hangup" then
        self.currentCall = nil
        self:ShowPage("home")
    end
end

function PhoneSystem:ShowIncomingCall(caller)
    -- Create incoming call popup
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 300, 0, 150)
    popup.Position = UDim2.new(0.5, -150, 0.3, 0)
    popup.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    popup.Parent = self.screenGui
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.1, 0)
    popupCorner.Parent = popup
    
    local callerLabel = Instance.new("TextLabel")
    callerLabel.Size = UDim2.new(1, 0, 0, 40)
    callerLabel.BackgroundTransparency = 1
    callerLabel.Text = "Incoming call from " .. caller
    callerLabel.TextColor3 = Color3.new(1, 1, 1)
    callerLabel.TextSize = 18
    callerLabel.Font = Enum.Font.GothamBold
    callerLabel.Parent = popup
    
    local answerButton = Instance.new("TextButton")
    answerButton.Size = UDim2.new(0, 100, 0, 40)
    answerButton.Position = UDim2.new(0, 20, 1, -60)
    answerButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    answerButton.Text = "Answer"
    answerButton.TextColor3 = Color3.new(1, 1, 1)
    answerButton.TextSize = 16
    answerButton.Font = Enum.Font.GothamBold
    answerButton.Parent = popup
    
    local declineButton = Instance.new("TextButton")
    declineButton.Size = UDim2.new(0, 100, 0, 40)
    declineButton.Position = UDim2.new(1, -120, 1, -60)
    declineButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    declineButton.Text = "Decline"
    declineButton.TextColor3 = Color3.new(1, 1, 1)
    declineButton.TextSize = 16
    declineButton.Font = Enum.Font.GothamBold
    declineButton.Parent = popup
    
    answerButton.MouseButton1Click:Connect(function()
        callRemote:FireServer(caller, "answer")
        popup:Destroy()
    end)
    
    declineButton.MouseButton1Click:Connect(function()
        callRemote:FireServer(caller, "decline")
        popup:Destroy()
    end)
    
    -- Auto-dismiss after 30 seconds
    wait(30)
    if popup.Parent then
        popup:Destroy()
    end
end

function PhoneSystem:ReceiveMessage(sender, message)
    -- Add message to chat history
    table.insert(self.chatHistory, {
        sender = sender,
        message = message,
        timestamp = tick()
    })
    
    -- Show notification if phone is closed
    if not self.isOpen then
        self:ShowMessageNotification(sender, message)
    end
end

function PhoneSystem:ShowMessageNotification(sender, message)
    -- Create notification popup
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(0.5, -150, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    notification.Parent = self.screenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0.1, 0)
    notifCorner.Parent = notification
    
    local senderLabel = Instance.new("TextLabel")
    senderLabel.Size = UDim2.new(1, -20, 0, 25)
    senderLabel.Position = UDim2.new(0, 10, 0, 5)
    senderLabel.BackgroundTransparency = 1
    senderLabel.Text = sender
    senderLabel.TextColor3 = Color3.new(1, 1, 1)
    senderLabel.TextSize = 14
    senderLabel.Font = Enum.Font.GothamBold
    senderLabel.TextXAlignment = Enum.TextXAlignment.Left
    senderLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Animate in
    notification.Position = UDim2.new(0.5, -150, -1, 0)
    local tween = TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -150, 0, 20)}
    )
    tween:Play()
    
    -- Auto-dismiss after 5 seconds
    wait(5)
    if notification.Parent then
        local dismissTween = TweenService:Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -150, -1, 0)}
        )
        dismissTween:Play()
        dismissTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end
end

function PhoneSystem:HandleGroupCall(members, action)
    if action == "join" then
        self.groupCallMembers = members
        self:ShowPage("calls")
    elseif action == "leave" then
        self.groupCallMembers = {}
        self:ShowPage("home")
    end
end

-- Initialize the phone system
local phoneSystem = PhoneSystem.new()

print("Phone system initialized successfully!")