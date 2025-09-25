-- Config.lua
-- File konfigurasi untuk sistem telepon Roblox

local Config = {}

-- ========================================
-- UI CONFIGURATION
-- ========================================

-- Phone frame settings
Config.PHONE_FRAME = {
    BACKGROUND_COLOR = Color3.fromRGB(20, 20, 20),
    CORNER_RADIUS = 20,
    SHADOW_SIZE = 20,
    SHADOW_TRANSPARENCY = 0.5
}

-- Device-specific scaling
Config.DEVICE_SCALING = {
    MOBILE = 0.8,
    PC = 0.7,
    CONSOLE = 0.9
}

-- Header settings
Config.HEADER = {
    HEIGHT = 60,
    BACKGROUND_COLOR = Color3.fromRGB(40, 40, 40),
    TITLE_TEXT = "📱 Telepon",
    TITLE_FONT = Enum.Font.GothamBold,
    TITLE_COLOR = Color3.fromRGB(255, 255, 255)
}

-- Navigation bar settings
Config.NAVIGATION = {
    HEIGHT = 80,
    BACKGROUND_COLOR = Color3.fromRGB(30, 30, 30),
    BUTTON_COUNT = 5,
    BUTTON_SPACING = 0.2 -- 20% each for 5 buttons
}

-- ========================================
-- FEATURE CONFIGURATION
-- ========================================

-- Games feature
Config.GAMES = {
    CARDS_PER_ROW = 2,
    CARD_HEIGHT = 120,
    CARD_SPACING = 10,
    DEFAULT_GAMES = {
        {
            name = "Adopt Me!",
            description = "Pet simulation game",
            icon = "🐾",
            gameId = 920587237,
            color = Color3.fromRGB(255, 182, 193)
        },
        {
            name = "Brookhaven RP",
            description = "Roleplay simulation",
            icon = "🏠",
            gameId = 4924922222,
            color = Color3.fromRGB(144, 238, 144)
        },
        {
            name = "Tower Defense",
            description = "Strategy tower defense",
            icon = "🏰",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 215, 0)
        },
        {
            name = "Obby Creator",
            description = "Create your own obby",
            icon = "🎯",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 165, 0)
        },
        {
            name = "Simulator Games",
            description = "Various simulator games",
            icon = "⚡",
            gameId = 1962086868,
            color = Color3.fromRGB(138, 43, 226)
        },
        {
            name = "Racing Games",
            description = "Fast-paced racing",
            icon = "🏎️",
            gameId = 1962086868,
            color = Color3.fromRGB(255, 69, 0)
        }
    }
}

-- Chat feature
Config.CHAT = {
    CHANNELS = {"Global", "Team", "Private"},
    DEFAULT_CHANNEL = "Global",
    MESSAGE_HEIGHT = 80,
    BUBBLE_COLORS = {
        OWN = Color3.fromRGB(0, 122, 255),
        OTHER = Color3.fromRGB(60, 60, 60)
    },
    SAMPLE_MESSAGES = {
        {sender = "Player1", text = "Hello everyone! 👋", time = "10:30"},
        {sender = "Player2", text = "How's everyone doing?", time = "10:31"},
        {sender = "Player3", text = "Great! Just playing some games 🎮", time = "10:32"}
    }
}

-- Phone feature
Config.PHONE = {
    DEFAULT_CONTACTS = {
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
    },
    CALL_DURATION_SIMULATION = 60 -- seconds
}

-- Music feature
Config.MUSIC = {
    DEFAULT_LIBRARY = {
        {
            title = "Epic Adventure",
            artist = "Game Music Studio",
            duration = "3:45",
            genre = "Epic",
            icon = "🎵",
            color = Color3.fromRGB(255, 100, 100),
            soundId = 131961136
        },
        {
            title = "Chill Vibes",
            artist = "Relax Music",
            duration = "4:20",
            genre = "Chill",
            icon = "🌊",
            color = Color3.fromRGB(100, 255, 100),
            soundId = 131961136
        },
        {
            title = "Electronic Dreams",
            artist = "Synth Master",
            duration = "3:15",
            genre = "Electronic",
            icon = "⚡",
            color = Color3.fromRGB(100, 100, 255),
            soundId = 131961136
        },
        {
            title = "Rock Anthem",
            artist = "Rock Band",
            duration = "4:05",
            genre = "Rock",
            icon = "🎸",
            color = Color3.fromRGB(255, 255, 100),
            soundId = 131961136
        },
        {
            title = "Jazz Night",
            artist = "Smooth Jazz",
            duration = "5:30",
            genre = "Jazz",
            icon = "🎷",
            color = Color3.fromRGB(255, 165, 0),
            soundId = 131961136
        },
        {
            title = "Classical Symphony",
            artist = "Orchestra",
            duration = "6:15",
            genre = "Classical",
            icon = "🎼",
            color = Color3.fromRGB(138, 43, 226),
            soundId = 131961136
        }
    },
    DEFAULT_VOLUME = 0.5,
    TRACK_HEIGHT = 70
}

-- Settings feature
Config.SETTINGS = {
    DEFAULT_VALUES = {
        volume = 0.5,
        notifications = true,
        autoPlay = false,
        theme = "dark",
        language = "en"
    },
    THEMES = {"Dark", "Light", "Blue", "Green"},
    LANGUAGES = {"English", "Indonesian", "Spanish", "French"}
}

-- ========================================
-- ANIMATION CONFIGURATION
-- ========================================

Config.ANIMATIONS = {
    PHONE_OPEN = {
        Duration = 0.5,
        EasingStyle = Enum.EasingStyle.Back,
        EasingDirection = Enum.EasingDirection.Out
    },
    PHONE_CLOSE = {
        Duration = 0.3,
        EasingStyle = Enum.EasingStyle.Back,
        EasingDirection = Enum.EasingDirection.In
    },
    BUTTON_HOVER = {
        Duration = 0.2,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out
    },
    FEATURE_SWITCH = {
        Duration = 0.3,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out
    }
}

-- ========================================
-- SOUND CONFIGURATION
-- ========================================

Config.SOUNDS = {
    CLICK = {
        SoundId = 131961136,
        Volume = 0.3
    },
    OPEN = {
        SoundId = 131961136,
        Volume = 0.4
    },
    CLOSE = {
        SoundId = 131961136,
        Volume = 0.3
    },
    CALL = {
        SoundId = 131961136,
        Volume = 0.5
    },
    NOTIFICATION = {
        SoundId = 131961136,
        Volume = 0.4
    }
}

-- ========================================
-- COLOR THEMES
-- ========================================

Config.COLORS = {
    PRIMARY = Color3.fromRGB(0, 122, 255),
    SECONDARY = Color3.fromRGB(100, 100, 100),
    SUCCESS = Color3.fromRGB(0, 200, 0),
    WARNING = Color3.fromRGB(255, 255, 0),
    ERROR = Color3.fromRGB(255, 0, 0),
    BACKGROUND = Color3.fromRGB(20, 20, 20),
    SURFACE = Color3.fromRGB(40, 40, 40),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    TEXT_DISABLED = Color3.fromRGB(150, 150, 150)
}

-- ========================================
-- FEATURE COLORS
-- ========================================

Config.FEATURE_COLORS = {
    GAMES = Color3.fromRGB(255, 100, 100),
    CHAT = Color3.fromRGB(100, 255, 100),
    PHONE = Color3.fromRGB(100, 100, 255),
    MUSIC = Color3.fromRGB(255, 255, 100),
    SETTINGS = Color3.fromRGB(200, 200, 200)
}

-- ========================================
-- KEYBOARD SHORTCUTS
-- ========================================

Config.SHORTCUTS = {
    TOGGLE_PHONE = Enum.KeyCode.F1,
    QUICK_GAMES = Enum.KeyCode.F2,
    QUICK_CHAT = Enum.KeyCode.F3,
    QUICK_PHONE = Enum.KeyCode.F4,
    QUICK_MUSIC = Enum.KeyCode.F5,
    QUICK_SETTINGS = Enum.KeyCode.F6
}

-- ========================================
-- DEBUG CONFIGURATION
-- ========================================

Config.DEBUG = {
    ENABLED = true,
    VERBOSE_LOGGING = true,
    SHOW_FPS = false,
    TEST_MODE = false
}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function Config:GetDeviceScale(deviceType)
    return self.DEVICE_SCALING[deviceType:upper()] or self.DEVICE_SCALING.PC
end

function Config:GetFeatureColor(featureName)
    return self.FEATURE_COLORS[featureName:upper()] or self.COLORS.PRIMARY
end

function Config:GetAnimationInfo(animationType)
    return self.ANIMATIONS[animationType:upper()] or self.ANIMATIONS.BUTTON_HOVER
end

function Config:GetSoundInfo(soundType)
    return self.SOUNDS[soundType:upper()] or self.SOUNDS.CLICK
end

-- Export configuration
return Config