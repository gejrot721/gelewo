-- PhoneConfig.lua
-- Konfigurasi global untuk sistem handphone

local PhoneConfig = {}

-- UI Configuration
PhoneConfig.UI = {
    -- Phone dimensions (akan di-scale berdasarkan screen size)
    PHONE_WIDTH = 400,
    PHONE_HEIGHT = 700,
    
    -- Animation settings
    ANIMATION_SPEED = 0.3,
    MENU_TRANSITION_SPEED = 0.2,
    
    -- Colors (Android Material Design)
    COLORS = {
        PRIMARY = Color3.fromRGB(33, 150, 243), -- Blue
        PRIMARY_DARK = Color3.fromRGB(25, 118, 210),
        ACCENT = Color3.fromRGB(255, 193, 7), -- Amber
        BACKGROUND = Color3.fromRGB(250, 250, 250),
        SURFACE = Color3.fromRGB(255, 255, 255),
        ON_SURFACE = Color3.fromRGB(33, 33, 33),
        ON_PRIMARY = Color3.fromRGB(255, 255, 255),
        ERROR = Color3.fromRGB(244, 67, 54),
        SUCCESS = Color3.fromRGB(76, 175, 80),
        
        -- Status bar colors
        STATUS_BAR = Color3.fromRGB(33, 150, 243),
        STATUS_BAR_TEXT = Color3.fromRGB(255, 255, 255)
    },
    
    -- Typography
    FONTS = {
        HEADER = Enum.Font.GothamBold,
        BODY = Enum.Font.Gotham,
        BUTTON = Enum.Font.GothamMedium
    },
    
    -- Icon sizes
    ICON_SIZE = 24,
    AVATAR_SIZE = 40,
    BUTTON_HEIGHT = 48
}

-- Feature flags
PhoneConfig.FEATURES = {
    VOICE_CHAT_ENABLED = true,
    GROUP_CALLS_ENABLED = true,
    CONTACT_SEARCH = true,
    MESSAGE_HISTORY = true,
    NOTIFICATION_SYSTEM = true
}

-- Voice chat settings
PhoneConfig.VOICE_CHAT = {
    MAX_GROUP_PARTICIPANTS = 8,
    AUDIO_QUALITY = "High",
    ECHO_CANCELLATION = true,
    NOISE_SUPPRESSION = true
}

-- Network settings
PhoneConfig.NETWORK = {
    REMOTE_EVENT_NAMES = {
        PHONE_EVENT = "PhoneSystemEvent",
        VOICE_CHAT_EVENT = "PhoneVoiceChatEvent",
        CONTACT_EVENT = "PhoneContactEvent"
    },
    RATE_LIMITS = {
        MESSAGES_PER_MINUTE = 30,
        CALLS_PER_MINUTE = 5
    }
}

-- Auto-scale settings
PhoneConfig.AUTOSCALE = {
    MIN_SCALE = 0.7,
    MAX_SCALE = 1.3,
    BASE_RESOLUTION = {1920, 1080},
    
    -- Breakpoints untuk berbagai device
    BREAKPOINTS = {
        MOBILE = 480,
        TABLET = 768,
        DESKTOP = 1024
    }
}

-- Contact settings
PhoneConfig.CONTACTS = {
    MAX_CONTACTS = 100,
    SEARCH_RESULTS_LIMIT = 20,
    RECENT_CALLS_LIMIT = 50
}

return PhoneConfig