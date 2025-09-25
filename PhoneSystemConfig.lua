-- Phone System Configuration
-- Customize the phone system appearance and behavior

local PhoneConfig = {}

-- UI Colors (Android Material Design inspired)
PhoneConfig.Colors = {
    Primary = Color3.fromRGB(76, 175, 80),      -- Green
    PrimaryDark = Color3.fromRGB(56, 142, 60),  -- Dark Green
    Accent = Color3.fromRGB(33, 150, 243),      -- Blue
    Background = Color3.fromRGB(33, 33, 33),    -- Dark Gray
    Surface = Color3.fromRGB(45, 45, 45),       -- Medium Gray
    Text = Color3.new(1, 1, 1),                 -- White
    TextSecondary = Color3.fromRGB(200, 200, 200), -- Light Gray
    Error = Color3.fromRGB(244, 67, 54),        -- Red
    Warning = Color3.fromRGB(255, 152, 0),      -- Orange
    Success = Color3.fromRGB(76, 175, 80)       -- Green
}

-- Phone Dimensions
PhoneConfig.PhoneSize = {
    Width = 400,
    Height = 700
}

-- Animation Settings
PhoneConfig.Animations = {
    OpenDuration = 0.3,
    CloseDuration = 0.3,
    EasingStyle = Enum.EasingStyle.Back,
    EasingDirection = {
        In = Enum.EasingDirection.In,
        Out = Enum.EasingDirection.Out
    }
}

-- Autoscale Settings
PhoneConfig.Autoscale = {
    MinScale = 0.8,
    MaxScale = 1.2,
    ReferenceResolution = {X = 1920, Y = 1080}
}

-- Menu Button Settings
PhoneConfig.MenuButton = {
    Size = 60,
    Position = {
        X = -80,  -- Distance from right edge
        Y = -30   -- Offset from center
    },
    Icon = "📱",
    IconSize = 24
}

-- Call Settings
PhoneConfig.Call = {
    RingDuration = 30,      -- Seconds to ring before auto-decline
    MaxMessageLength = 200,
    AutoMuteDuration = 300  -- 5 minutes auto-mute for spam protection
}

-- Voice Chat Settings
PhoneConfig.VoiceChat = {
    Enabled = true,
    MaxDistance = 1000,     -- Studs
    Quality = "High",       -- Low, Medium, High
    EchoCancellation = true,
    NoiseSuppression = true
}

-- Notification Settings
PhoneConfig.Notifications = {
    Duration = 5,           -- Seconds to show notification
    MaxOnScreen = 3,        -- Maximum notifications at once
    Position = {
        X = -150,           -- Offset from center
        Y = 20              -- Distance from top
    }
}

-- Feature Toggles
PhoneConfig.Features = {
    IndividualCalls = true,
    GroupCalls = true,
    Chat = true,
    VoiceChat = true,
    ContactSearch = true,
    CallHistory = true,
    MessageHistory = true,
    Notifications = true,
    AutoScale = true,
    CrossPlatform = true
}

-- Platform-specific Settings
PhoneConfig.Platform = {
    Mobile = {
        TouchFriendly = true,
        SwipeGestures = true,
        HapticFeedback = true,
        LargerButtons = true
    },
    PC = {
        KeyboardShortcuts = true,
        MouseWheelScrolling = true,
        RightClickContext = true
    },
    Console = {
        ControllerSupport = true,
        GamepadNavigation = true,
        LargeUI = true
    }
}

-- Security Settings
PhoneConfig.Security = {
    MessageFiltering = true,
    SpamProtection = true,
    RateLimiting = true,
    MaxCallsPerMinute = 10,
    MaxMessagesPerMinute = 20,
    BlacklistEnabled = true
}

-- Performance Settings
PhoneConfig.Performance = {
    UpdateFrequency = 60,   -- FPS
    MemoryLimit = 50,       -- MB
    TextureQuality = "High", -- Low, Medium, High
    ParticleEffects = true,
    SmoothAnimations = true
}

-- Localization
PhoneConfig.Language = "English"

PhoneConfig.Texts = {
    English = {
        Phone = "Phone",
        Home = "Home",
        Contacts = "Contacts",
        Chat = "Chat",
        Calls = "Calls",
        SearchPlayers = "Search players...",
        TypeMessage = "Type a message...",
        IncomingCall = "Incoming call from",
        Answer = "Answer",
        Decline = "Decline",
        HangUp = "Hang Up",
        Mute = "Mute",
        Unmute = "Unmute",
        QuickCall = "Quick Call",
        QuickChat = "Quick Chat",
        GroupCall = "Group Call",
        Contacts = "Contacts",
        Online = "Online",
        Offline = "Offline",
        Busy = "Busy",
        NoAnswer = "No Answer"
    }
}

-- Helper function to get localized text
function PhoneConfig:GetText(key)
    local language = self.Language
    if self.Texts[language] and self.Texts[language][key] then
        return self.Texts[language][key]
    end
    return self.Texts.English[key] or key
end

-- Helper function to check if feature is enabled
function PhoneConfig:IsFeatureEnabled(feature)
    return self.Features[feature] == true
end

-- Helper function to get platform-specific setting
function PhoneConfig:GetPlatformSetting(platform, setting)
    if self.Platform[platform] then
        return self.Platform[platform][setting]
    end
    return nil
end

return PhoneConfig