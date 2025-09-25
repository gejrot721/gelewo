-- TestDemo.lua
-- Demo script untuk testing sistem handphone

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local TestDemo = {}

-- Test data
local testContacts = {
    {
        userId = 12345,
        username = "TestPlayer1",
        displayName = "Test Player 1",
        isOnline = true,
        lastSeen = tick()
    },
    {
        userId = 67890,
        username = "TestPlayer2", 
        displayName = "Test Player 2",
        isOnline = true,
        lastSeen = tick()
    },
    {
        userId = 11111,
        username = "TestPlayer3",
        displayName = "Test Player 3",
        isOnline = false,
        lastSeen = tick() - 300
    }
}

-- Initialize demo
function TestDemo.initialize()
    print("Initializing Phone System Demo...")
    
    -- Wait for phone system to load
    local phoneSystem = ReplicatedStorage:WaitForChild("PhoneSystem")
    print("Phone System found!")
    
    -- Setup demo controls
    TestDemo.setupDemoControls()
    
    -- Start demo scenarios
    TestDemo.startDemoScenarios()
    
    print("Demo initialized successfully!")
end

-- Setup demo controls
function TestDemo.setupDemoControls()
    -- Create demo UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PhoneDemo"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Demo controls frame
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Size = UDim2.new(0, 300, 0, 400)
    controlsFrame.Position = UDim2.new(0, 20, 0, 20)
    controlsFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = controlsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Phone System Demo"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Parent = controlsFrame
    
    -- Demo buttons
    local buttonHeight = 35
    local buttonSpacing = 5
    
    local buttons = {
        {text = "Test Phone Open/Close", func = TestDemo.testPhoneToggle},
        {text = "Test Contacts", func = TestDemo.testContacts},
        {text = "Test Chat", func = TestDemo.testChat},
        {text = "Test Individual Call", func = TestDemo.testIndividualCall},
        {text = "Test Group Call", func = TestDemo.testGroupCall},
        {text = "Test Voice Chat", func = TestDemo.testVoiceChat},
        {text = "Test Responsive UI", func = TestDemo.testResponsiveUI},
        {text = "Simulate Incoming Call", func = TestDemo.simulateIncomingCall},
        {text = "Simulate Message", func = TestDemo.simulateMessage},
        {text = "Performance Test", func = TestDemo.performanceTest}
    }
    
    for i, buttonData in pairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = "DemoButton" .. i
        button.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        button.BorderSizePixel = 0
        button.Text = buttonData.text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.Size = UDim2.new(1, -20, 0, buttonHeight)
        button.Position = UDim2.new(0, 10, 0, 50 + (i - 1) * (buttonHeight + buttonSpacing))
        button.Parent = controlsFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            buttonData.func()
        end)
    end
end

-- Demo test functions
function TestDemo.testPhoneToggle()
    print("Testing phone open/close...")
    -- This would trigger the phone toggle
    local phoneSystem = ReplicatedStorage:WaitForChild("PhoneSystem")
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("TestPhoneToggle", {})
end

function TestDemo.testContacts()
    print("Testing contacts system...")
    -- Simulate adding test contacts
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("TestContacts", {contacts = testContacts})
end

function TestDemo.testChat()
    print("Testing chat system...")
    -- Simulate chat message
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("TestMessage", {
        senderId = 12345,
        receiverId = Players.LocalPlayer.UserId,
        content = "This is a test message from the demo!",
        timestamp = tick()
    })
end

function TestDemo.testIndividualCall()
    print("Testing individual call...")
    -- Simulate incoming call
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("TestIncomingCall", {
        callerId = 12345,
        contact = testContacts[1]
    })
end

function TestDemo.testGroupCall()
    print("Testing group call...")
    -- Simulate group call
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("TestGroupCall", {
        participants = testContacts
    })
end

function TestDemo.testVoiceChat()
    print("Testing voice chat...")
    -- Check voice chat availability
    local VoiceChatService = game:GetService("VoiceChatService")
    if VoiceChatService.Available then
        print("Voice chat is available!")
        VoiceChatService:RequestPermissionsForVoiceChat()
    else
        print("Voice chat is not available on this platform")
    end
end

function TestDemo.testResponsiveUI()
    print("Testing responsive UI...")
    -- Simulate screen size changes
    local currentSize = workspace.CurrentCamera.ViewportSize
    print("Current screen size:", currentSize.X, "x", currentSize.Y)
    
    -- Test different device types
    local deviceTypes = {"mobile", "tablet", "desktop", "console"}
    for _, deviceType in pairs(deviceTypes) do
        print("Testing UI for device type:", deviceType)
    end
end

function TestDemo.simulateIncomingCall()
    print("Simulating incoming call...")
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("SimulateIncomingCall", {
        contact = testContacts[2],
        callId = "demo_call_" .. tostring(tick())
    })
end

function TestDemo.simulateMessage()
    print("Simulating incoming message...")
    local remoteEvent = ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    remoteEvent:FireServer("SimulateMessage", {
        senderId = 67890,
        content = "Demo message received!",
        timestamp = tick()
    })
end

function TestDemo.performanceTest()
    print("Running performance test...")
    
    local startTime = tick()
    local iterations = 1000
    
    -- Test UI creation performance
    for i = 1, iterations do
        local testFrame = Instance.new("Frame")
        testFrame.Name = "TestFrame" .. i
        testFrame.Parent = workspace
        testFrame:Destroy()
    end
    
    local endTime = tick()
    local duration = endTime - startTime
    
    print("Performance test completed:")
    print("- Iterations:", iterations)
    print("- Duration:", string.format("%.3f", duration), "seconds")
    print("- Average per iteration:", string.format("%.6f", duration / iterations), "seconds")
end

-- Start demo scenarios
function TestDemo.startDemoScenarios()
    -- Auto-run basic tests after 5 seconds
    wait(5)
    
    print("Starting automated demo scenarios...")
    
    -- Scenario 1: Basic functionality
    TestDemo.testPhoneToggle()
    wait(2)
    
    -- Scenario 2: Contacts
    TestDemo.testContacts()
    wait(2)
    
    -- Scenario 3: Chat
    TestDemo.testChat()
    wait(2)
    
    -- Scenario 4: Voice chat
    TestDemo.testVoiceChat()
    wait(2)
    
    -- Scenario 5: Responsive UI
    TestDemo.testResponsiveUI()
    
    print("Demo scenarios completed!")
end

-- Handle keyboard shortcuts for demo
function TestDemo.setupKeyboardShortcuts()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F1 then
            TestDemo.testPhoneToggle()
        elseif input.KeyCode == Enum.KeyCode.F2 then
            TestDemo.testContacts()
        elseif input.KeyCode == Enum.KeyCode.F3 then
            TestDemo.testChat()
        elseif input.KeyCode == Enum.KeyCode.F4 then
            TestDemo.testIndividualCall()
        elseif input.KeyCode == Enum.KeyCode.F5 then
            TestDemo.testGroupCall()
        elseif input.KeyCode == Enum.KeyCode.F6 then
            TestDemo.performanceTest()
        end
    end)
end

-- Initialize demo
TestDemo.initialize()
TestDemo.setupKeyboardShortcuts()

print("Phone System Demo loaded!")
print("Keyboard shortcuts:")
print("F1 - Test Phone Toggle")
print("F2 - Test Contacts")
print("F3 - Test Chat")
print("F4 - Test Individual Call")
print("F5 - Test Group Call")
print("F6 - Performance Test")

return TestDemo