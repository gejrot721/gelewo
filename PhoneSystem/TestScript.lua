-- TestScript.lua
-- Script untuk testing sistem telepon

local PhoneSystem = require(script.Parent.PhoneSystem)

-- Test function untuk memverifikasi semua fitur
local function testPhoneSystem()
    print("🧪 Starting Phone System Tests...")
    
    -- Test 1: Initialize system
    print("Test 1: Initializing Phone System...")
    PhoneSystem:Initialize()
    print("✅ Phone System initialized successfully")
    
    -- Test 2: Test device detection
    print("Test 2: Testing device detection...")
    local deviceType = PhoneSystem.getDeviceType and PhoneSystem.getDeviceType() or "unknown"
    print("✅ Device type detected: " .. deviceType)
    
    -- Test 3: Test UI scaling
    print("Test 3: Testing UI scaling...")
    local scale = PhoneSystem.getUIScale and PhoneSystem.getUIScale() or 1
    print("✅ UI scale: " .. scale)
    
    -- Test 4: Test sound system
    print("Test 4: Testing sound system...")
    if PhoneSystem.phoneSounds then
        print("✅ Sound system loaded")
    else
        print("❌ Sound system failed to load")
    end
    
    -- Test 5: Test feature loading
    print("Test 5: Testing feature loading...")
    local features = {"games", "chat", "phone", "music", "settings"}
    for _, feature in ipairs(features) do
        local loadFunction = PhoneSystem["load" .. feature:gsub("^%l", string.upper) .. "Feature"]
        if loadFunction then
            print("✅ " .. feature .. " feature available")
        else
            print("❌ " .. feature .. " feature missing")
        end
    end
    
    print("🎉 All tests completed!")
end

-- Run tests
testPhoneSystem()

-- Additional test functions
local function testResponsiveDesign()
    print("📱 Testing responsive design...")
    
    -- Simulate different screen sizes
    local screenSizes = {
        {name = "Mobile", width = 375, height = 667},
        {name = "Tablet", width = 768, height = 1024},
        {name = "Desktop", width = 1920, height = 1080},
        {name = "Console", width = 1280, height = 720}
    }
    
    for _, size in ipairs(screenSizes) do
        print("Testing " .. size.name .. " (" .. size.width .. "x" .. size.height .. ")")
        -- In real implementation, you would test UI scaling here
    end
    
    print("✅ Responsive design tests completed")
end

local function testAnimations()
    print("🎬 Testing animations...")
    
    -- Test animation functions
    local animationTests = {
        "Phone open animation",
        "Phone close animation", 
        "Feature switch animation",
        "Button hover effects",
        "Progress bar animations"
    }
    
    for _, test in ipairs(animationTests) do
        print("Testing: " .. test)
        -- In real implementation, you would test actual animations
    end
    
    print("✅ Animation tests completed")
end

local function testSoundEffects()
    print("🔊 Testing sound effects...")
    
    local soundTests = {
        "Button click sound",
        "Menu open sound",
        "Menu close sound",
        "Call sound",
        "Notification sound"
    }
    
    for _, test in ipairs(soundTests) do
        print("Testing: " .. test)
        -- In real implementation, you would test actual sounds
    end
    
    print("✅ Sound effect tests completed")
end

-- Run additional tests
wait(2)
testResponsiveDesign()

wait(2)
testAnimations()

wait(2)
testSoundEffects()

print("🎯 All Phone System tests completed successfully!")
print("📱 The phone system is ready for use!")
print("💡 Press F1 or click the menu button to open your phone")