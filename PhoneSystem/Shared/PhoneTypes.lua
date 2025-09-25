-- PhoneTypes.lua
-- Type definitions untuk sistem handphone

local PhoneTypes = {}

-- Call status types
PhoneTypes.CallStatus = {
    IDLE = "idle",
    RINGING = "ringing",
    CONNECTED = "connected",
    ENDED = "ended",
    DECLINED = "declined",
    BUSY = "busy"
}

-- Message types
PhoneTypes.MessageType = {
    TEXT = "text",
    SYSTEM = "system",
    CALL_STARTED = "call_started",
    CALL_ENDED = "call_ended"
}

-- UI States
PhoneTypes.UIState = {
    HIDDEN = "hidden",
    PHONE_MENU = "phone_menu",
    CONTACTS = "contacts",
    CHAT = "chat",
    CALL = "call",
    GROUP_CALL = "group_call",
    SETTINGS = "settings"
}

-- Contact data structure
PhoneTypes.Contact = {
    userId = "number",
    username = "string",
    displayName = "string",
    avatar = "string",
    isOnline = "boolean",
    lastSeen = "number",
    phoneNumber = "string"
}

-- Call data structure
PhoneTypes.Call = {
    callId = "string",
    participants = "table", -- Array of user IDs
    startTime = "number",
    endTime = "number",
    status = "string",
    isGroupCall = "boolean"
}

-- Message data structure
PhoneTypes.Message = {
    messageId = "string",
    senderId = "string",
    receiverId = "string",
    content = "string",
    timestamp = "number",
    messageType = "string",
    isRead = "boolean"
}

-- Notification types
PhoneTypes.NotificationType = {
    INCOMING_CALL = "incoming_call",
    MESSAGE_RECEIVED = "message_received",
    CALL_ENDED = "call_ended",
    CONTACT_ONLINE = "contact_online"
}

-- Device types untuk responsive design
PhoneTypes.DeviceType = {
    MOBILE = "mobile",
    TABLET = "tablet",
    DESKTOP = "desktop",
    CONSOLE = "console"
}

return PhoneTypes