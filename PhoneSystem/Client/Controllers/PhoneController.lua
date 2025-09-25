-- PhoneController.lua
-- Controller utama untuk mengelola semua fungsi handphone

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Import UI components
local PhoneUI = require(script.Parent.Parent.UI.Phone.PhoneUI)
local MenuButton = require(script.Parent.Parent.UI.Phone.MenuButton)
local ContactsUI = require(script.Parent.Parent.UI.Contacts.ContactsUI)
local ChatUI = require(script.Parent.Parent.UI.Chat.ChatUI)
local CallUI = require(script.Parent.Parent.UI.Calls.CallUI)
local GroupCallUI = require(script.Parent.Parent.UI.Calls.GroupCallUI)

-- Import services
local VoiceChatService = require(script.Parent.Parent.Services.VoiceChatService)

-- Import shared modules
local PhoneConfig = require(script.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Shared.PhoneTypes)
local UIScale = require(script.Parent.Parent.Shared.Utils.UIScale)

local PhoneController = {}

-- Phone state
local phoneState = {
    isOpen = false,
    currentScreen = PhoneTypes.UIState.HIDDEN,
    previousScreen = nil,
    phoneFrame = nil,
    menuButton = nil,
    contactsScreen = nil,
    chatScreen = nil,
    callScreen = nil,
    groupCallScreen = nil,
    currentChatContact = nil,
    currentCallContact = nil,
    currentGroupCall = nil
}

-- Initialize phone system
function PhoneController.initialize()
    print("Initializing Phone System...")
    
    -- Initialize voice chat service
    VoiceChatService.initialize()
    
    -- Create phone UI components
    PhoneController.createUIComponents()
    
    -- Setup event listeners
    PhoneController.setupEventListeners()
    
    -- Setup input handling
    PhoneController.setupInputHandling()
    
    print("Phone System initialized successfully")
end

-- Create all UI components
function PhoneController.createUIComponents()
    -- Create menu button
    phoneState.menuButton = MenuButton.createMenuButton()
    
    -- Create phone frame
    phoneState.phoneFrame, phoneState.screenGui = PhoneUI.createPhoneFrame()
    
    -- Create screens
    phoneState.contactsScreen = ContactsUI.createContactsScreen(phoneState.phoneFrame)
    phoneState.chatScreen = ChatUI.createChatScreen(phoneState.phoneFrame)
    phoneState.callScreen = CallUI.createCallScreen(phoneState.phoneFrame)
    phoneState.groupCallScreen = GroupCallUI.createGroupCallScreen(phoneState.phoneFrame)
    
    -- Setup menu button click handler
    phoneState.menuButton.MouseButton1Click:Connect(function()
        PhoneController.togglePhone()
    end)
end

-- Setup event listeners
function PhoneController.setupEventListeners()
    -- Listen for remote events from server
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    
    remoteEvent.OnClientEvent:Connect(function(action, data)
        PhoneController.handleServerEvent(action, data)
    end)
    
    -- Listen for voice chat events
    VoiceChatService.ParticipantSpeakingChanged:Connect(function(participant, speaking)
        PhoneController.onParticipantSpeakingChanged(participant, speaking)
    end)
end

-- Setup input handling
function PhoneController.setupInputHandling()
    -- Handle escape key to close phone
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Escape and phoneState.isOpen then
            PhoneController.closePhone()
        end
    end)
    
    -- Handle back button on mobile
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Backspace and phoneState.isOpen then
            PhoneController.goBack()
        end
    end)
end

-- Toggle phone open/close
function PhoneController.togglePhone()
    if phoneState.isOpen then
        PhoneController.closePhone()
    else
        PhoneController.openPhone()
    end
end

-- Open phone
function PhoneController.openPhone()
    if phoneState.isOpen then return end
    
    phoneState.isOpen = true
    phoneState.currentScreen = PhoneTypes.UIState.PHONE_MENU
    
    -- Show phone with animation
    PhoneUI.showPhone(phoneState.phoneFrame)
    
    -- Animate menu button
    MenuButton.animateButtonState(phoneState.menuButton, true)
    
    print("Phone opened")
end

-- Close phone
function PhoneController.closePhone()
    if not phoneState.isOpen then return end
    
    phoneState.isOpen = false
    phoneState.currentScreen = PhoneTypes.UIState.HIDDEN
    
    -- Hide all screens
    PhoneController.hideAllScreens()
    
    -- Hide phone with animation
    PhoneUI.hidePhone(phoneState.phoneFrame)
    
    -- Animate menu button
    MenuButton.animateButtonState(phoneState.menuButton, false)
    
    print("Phone closed")
end

-- Navigate to screen
function PhoneController.navigateToScreen(screenType, data)
    if not phoneState.isOpen then
        PhoneController.openPhone()
    end
    
    -- Store previous screen
    phoneState.previousScreen = phoneState.currentScreen
    phoneState.currentScreen = screenType
    
    -- Hide current screen
    PhoneController.hideCurrentScreen()
    
    -- Show new screen
    PhoneController.showScreen(screenType, data)
    
    print("Navigated to:", screenType)
end

-- Show screen
function PhoneController.showScreen(screenType, data)
    if screenType == PhoneTypes.UIState.CONTACTS then
        ContactsUI.showContactsScreen(phoneState.contactsScreen)
        
    elseif screenType == PhoneTypes.UIState.CHAT then
        if data and data.contact then
            phoneState.currentChatContact = data.contact
            ChatUI.updateContactInfo(data.contact)
        end
        ChatUI.showChatScreen(phoneState.chatScreen)
        
    elseif screenType == PhoneTypes.UIState.CALL then
        if data and data.contact then
            phoneState.currentCallContact = data.contact
            -- Update call UI with contact info
        end
        CallUI.showCallScreen(phoneState.callScreen)
        
    elseif screenType == PhoneTypes.UIState.GROUP_CALL then
        if data and data.participants then
            phoneState.currentGroupCall = data
            -- Update group call UI with participants
        end
        GroupCallUI.showGroupCallScreen(phoneState.groupCallScreen)
        
    elseif screenType == PhoneTypes.UIState.PHONE_MENU then
        -- Show home screen (default state)
        -- Home screen is always visible when phone is open
    end
end

-- Hide current screen
function PhoneController.hideCurrentScreen()
    if phoneState.currentScreen == PhoneTypes.UIState.CONTACTS then
        ContactsUI.hideContactsScreen(phoneState.contactsScreen)
        
    elseif phoneState.currentScreen == PhoneTypes.UIState.CHAT then
        ChatUI.hideChatScreen(phoneState.chatScreen)
        
    elseif phoneState.currentScreen == PhoneTypes.UIState.CALL then
        CallUI.hideCallScreen(phoneState.callScreen)
        
    elseif phoneState.currentScreen == PhoneTypes.UIState.GROUP_CALL then
        GroupCallUI.hideGroupCallScreen(phoneState.groupCallScreen)
    end
end

-- Hide all screens
function PhoneController.hideAllScreens()
    ContactsUI.hideContactsScreen(phoneState.contactsScreen)
    ChatUI.hideChatScreen(phoneState.chatScreen)
    CallUI.hideCallScreen(phoneState.callScreen)
    GroupCallUI.hideGroupCallScreen(phoneState.groupCallScreen)
end

-- Go back to previous screen
function PhoneController.goBack()
    if phoneState.previousScreen then
        local previousScreen = phoneState.previousScreen
        phoneState.previousScreen = nil
        PhoneController.navigateToScreen(previousScreen)
    else
        PhoneController.closePhone()
    end
end

-- Handle server events
function PhoneController.handleServerEvent(action, data)
    print("Received server event:", action, data)
    
    if action == "IncomingCall" then
        PhoneController.handleIncomingCall(data)
        
    elseif action == "CallAnswered" then
        PhoneController.handleCallAnswered(data)
        
    elseif action == "CallEnded" then
        PhoneController.handleCallEnded(data)
        
    elseif action == "MessageReceived" then
        PhoneController.handleMessageReceived(data)
        
    elseif action == "GroupCallStarted" then
        PhoneController.handleGroupCallStarted(data)
        
    elseif action == "ParticipantSpeakingChanged" then
        PhoneController.handleParticipantSpeakingChanged(data)
        
    elseif action == "VoiceChatFailed" then
        PhoneController.handleVoiceChatFailed(data)
    end
end

-- Handle incoming call
function PhoneController.handleIncomingCall(data)
    local contact = data.contact
    local callId = data.callId
    
    -- Show incoming call notification
    CallUI.createIncomingCallNotification(contact)
    
    -- Show notification badge on menu button
    MenuButton.showNotificationBadge(phoneState.menuButton)
    
    print("Incoming call from:", contact.username)
end

-- Handle call answered
function PhoneController.handleCallAnswered(data)
    -- Navigate to call screen
    PhoneController.navigateToScreen(PhoneTypes.UIState.CALL, {
        contact = data.contact,
        callId = data.callId
    })
    
    -- Hide notification badge
    MenuButton.hideNotificationBadge(phoneState.menuButton)
    
    print("Call answered:", data.contact.username)
end

-- Handle call ended
function PhoneController.handleCallEnded(data)
    -- Close call screen
    if phoneState.currentScreen == PhoneTypes.UIState.CALL or 
       phoneState.currentScreen == PhoneTypes.UIState.GROUP_CALL then
        PhoneController.navigateToScreen(PhoneTypes.UIState.PHONE_MENU)
    end
    
    print("Call ended")
end

-- Handle message received
function PhoneController.handleMessageReceived(data)
    -- Show notification if not in chat with this contact
    if not phoneState.currentChatContact or 
       phoneState.currentChatContact.userId ~= data.senderId then
        MenuButton.showNotificationBadge(phoneState.menuButton)
    end
    
    -- Add message to chat if chat is open with this contact
    if phoneState.currentChatContact and 
       phoneState.currentChatContact.userId == data.senderId then
        local messagesContainer = phoneState.chatScreen:FindFirstChild("MessagesContainer")
        if messagesContainer then
            local isOwnMessage = data.senderId == player.UserId
            ChatUI.addMessage(messagesContainer, data.message, isOwnMessage, 
                            UIScale.calculateScale(), UIScale.getDeviceType())
        end
    end
    
    print("Message received from:", data.senderId)
end

-- Handle group call started
function PhoneController.handleGroupCallStarted(data)
    PhoneController.navigateToScreen(PhoneTypes.UIState.GROUP_CALL, {
        participants = data.participants,
        callId = data.callId
    })
    
    print("Group call started with", #data.participants, "participants")
end

-- Handle participant speaking changed
function PhoneController.handleParticipantSpeakingChanged(data)
    if phoneState.currentScreen == PhoneTypes.UIState.GROUP_CALL then
        GroupCallUI.updateParticipantSpeaking(data.participant, data.speaking)
    end
end

-- Handle voice chat failed
function PhoneController.handleVoiceChatFailed(data)
    -- Show error notification
    print("Voice chat failed:", data.error)
    
    -- Hide notification badge
    MenuButton.hideNotificationBadge(phoneState.menuButton)
end

-- Handle participant speaking changed (from voice chat service)
function PhoneController.onParticipantSpeakingChanged(participant, speaking)
    if phoneState.currentScreen == PhoneTypes.UIState.GROUP_CALL then
        GroupCallUI.updateParticipantSpeaking(participant.Name, speaking)
    end
end

-- App navigation functions (called from UI)
function PhoneController.openContacts()
    PhoneController.navigateToScreen(PhoneTypes.UIState.CONTACTS)
end

function PhoneController.openChat(contact)
    PhoneController.navigateToScreen(PhoneTypes.UIState.CHAT, {contact = contact})
end

function PhoneController.startCall(contact)
    -- Send call request to server
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("StartCall", {
        targetUserId = contact.userId,
        contact = contact
    })
    
    -- Navigate to call screen
    PhoneController.navigateToScreen(PhoneTypes.UIState.CALL, {
        contact = contact,
        isOutgoing = true
    })
    
    print("Starting call with:", contact.username)
end

function PhoneController.startGroupCall(participants)
    -- Send group call request to server
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("StartGroupCall", {
        participantUserIds = participants
    })
    
    -- Navigate to group call screen
    PhoneController.navigateToScreen(PhoneTypes.UIState.GROUP_CALL, {
        participants = participants,
        isOutgoing = true
    })
    
    print("Starting group call with", #participants, "participants")
end

function PhoneController.answerCall()
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("AnswerCall", {})
    
    print("Answering call")
end

function PhoneController.declineCall()
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("DeclineCall", {})
    
    print("Declining call")
end

function PhoneController.endCall()
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("EndCall", {})
    
    VoiceChatService.endCall()
    
    -- Navigate back to previous screen
    PhoneController.goBack()
    
    print("Ending call")
end

function PhoneController.sendMessage(messageText, receiverId)
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("SendMessage", {
        receiverId = receiverId,
        content = messageText
    })
    
    print("Sending message to:", receiverId)
end

-- Get phone state
function PhoneController.getState()
    return phoneState
end

-- Cleanup phone system
function PhoneController.cleanup()
    VoiceChatService.cleanup()
    
    if phoneState.screenGui then
        phoneState.screenGui:Destroy()
    end
    
    phoneState = {
        isOpen = false,
        currentScreen = PhoneTypes.UIState.HIDDEN,
        previousScreen = nil,
        phoneFrame = nil,
        menuButton = nil,
        contactsScreen = nil,
        chatScreen = nil,
        callScreen = nil,
        groupCallScreen = nil,
        currentChatContact = nil,
        currentCallContact = nil,
        currentGroupCall = nil
    }
    
    print("Phone system cleaned up")
end

return PhoneController