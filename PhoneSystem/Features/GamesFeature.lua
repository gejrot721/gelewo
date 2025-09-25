-- GamesFeature.lua
-- Fitur Games untuk sistem telepon

local GamesFeature = {}
GamesFeature.__index = GamesFeature

-- Services
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Game Data
local gameData = {
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

-- Create Game Card
local function createGameCard(parent, gameInfo, index)
    local card = Instance.new("Frame")
    card.Name = gameInfo.name .. "Card"
    card.Size = UDim2.new(0.45, 0, 0, 120)
    card.Position = UDim2.new((index-1) % 2 * 0.5, 10, math.floor((index-1)/2) * 0.3, 10)
    card.BackgroundColor3 = gameInfo.color
    card.BorderSizePixel = 0
    card.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = card
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, gameInfo.color),
        ColorSequenceKeypoint.new(1, Color3.new(gameInfo.color.R * 0.7, gameInfo.color.G * 0.7, gameInfo.color.B * 0.7))
    }
    gradient.Rotation = 45
    gradient.Parent = card
    
    -- Game Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 60, 0, 60)
    iconLabel.Position = UDim2.new(0, 15, 0, 15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = gameInfo.icon
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.Parent = card
    
    -- Game Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -90, 0, 30)
    nameLabel.Position = UDim2.new(0, 85, 0, 15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = gameInfo.name
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    -- Game Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -90, 0, 20)
    descLabel.Position = UDim2.new(0, 85, 0, 45)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = gameInfo.description
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = card
    
    -- Play Button
    local playBtn = Instance.new("TextButton")
    playBtn.Name = "PlayButton"
    playBtn.Size = UDim2.new(0, 60, 0, 30)
    playBtn.Position = UDim2.new(1, -75, 1, -45)
    playBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    playBtn.BackgroundTransparency = 0.3
    playBtn.BorderSizePixel = 0
    playBtn.Text = "PLAY"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.TextScaled = true
    playBtn.Font = Enum.Font.GothamBold
    playBtn.Parent = card
    
    -- Play button corner
    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 8)
    playCorner.Parent = playBtn
    
    -- Hover effects
    card.MouseEnter:Connect(function()
        local tween = TweenService:Create(card, TweenInfo.new(0.2), {
            Size = UDim2.new(0.47, 0, 0, 125)
        })
        tween:Play()
    end)
    
    card.MouseLeave:Connect(function()
        local tween = TweenService:Create(card, TweenInfo.new(0.2), {
            Size = UDim2.new(0.45, 0, 0, 120)
        })
        tween:Play()
    end)
    
    -- Play button click
    playBtn.MouseButton1Click:Connect(function()
        -- Animate button press
        local pressTween = TweenService:Create(playBtn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 55, 0, 28)
        })
        pressTween:Play()
        
        pressTween.Completed:Connect(function()
            local releaseTween = TweenService:Create(playBtn, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 60, 0, 30)
            })
            releaseTween:Play()
        end)
        
        -- Launch game (placeholder - in real implementation, you'd use MarketplaceService)
        print("🎮 Launching " .. gameInfo.name .. "...")
        
        -- Simulate game launch
        local launchLabel = Instance.new("TextLabel")
        launchLabel.Size = UDim2.new(1, 0, 0, 40)
        launchLabel.Position = UDim2.new(0, 0, 1, -40)
        launchLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        launchLabel.Text = "🚀 Launching " .. gameInfo.name .. "..."
        launchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        launchLabel.TextScaled = true
        launchLabel.Font = Enum.Font.GothamBold
        launchLabel.Parent = card
        
        local launchCorner = Instance.new("UICorner")
        launchCorner.CornerRadius = UDim.new(0, 8)
        launchCorner.Parent = launchLabel
        
        -- Remove launch message after 2 seconds
        game:GetService("Debris"):AddItem(launchLabel, 2)
    end)
    
    return card
end

-- Create Games Feature UI
function GamesFeature:CreateUI(parent)
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Games"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    
    -- Scrollable frame for games
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "GamesScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, -50)
    scrollFrame.Position = UDim2.new(0, 0, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (#gameData * 130) + 20)
    scrollFrame.Parent = parent
    
    -- Create game cards
    for i, gameInfo in ipairs(gameData) do
        createGameCard(scrollFrame, gameInfo, i)
    end
    
    -- Add Game Button
    local addGameBtn = Instance.new("TextButton")
    addGameBtn.Name = "AddGameButton"
    addGameBtn.Size = UDim2.new(0, 200, 0, 50)
    addGameBtn.Position = UDim2.new(0.5, -100, 1, -60)
    addGameBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    addGameBtn.BorderSizePixel = 0
    addGameBtn.Text = "➕ Add More Games"
    addGameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addGameBtn.TextScaled = true
    addGameBtn.Font = Enum.Font.GothamBold
    addGameBtn.Parent = parent
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 10)
    addCorner.Parent = addGameBtn
    
    -- Add game button hover effect
    addGameBtn.MouseEnter:Connect(function()
        addGameBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    addGameBtn.MouseLeave:Connect(function()
        addGameBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    -- Add game button click
    addGameBtn.MouseButton1Click:Connect(function()
        print("➕ Add Game feature - In real implementation, this would open a game browser or search")
        
        -- Show add game dialog
        local dialog = Instance.new("Frame")
        dialog.Name = "AddGameDialog"
        dialog.Size = UDim2.new(0.8, 0, 0.6, 0)
        dialog.Position = UDim2.new(0.1, 0, 0.2, 0)
        dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dialog.BorderSizePixel = 0
        dialog.Parent = parent
        
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 15)
        dialogCorner.Parent = dialog
        
        local dialogTitle = Instance.new("TextLabel")
        dialogTitle.Size = UDim2.new(1, 0, 0, 50)
        dialogTitle.Position = UDim2.new(0, 0, 0, 0)
        dialogTitle.BackgroundTransparency = 1
        dialogTitle.Text = "➕ Add New Game"
        dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        dialogTitle.TextScaled = true
        dialogTitle.Font = Enum.Font.GothamBold
        dialogTitle.Parent = dialog
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 40, 0, 40)
        closeBtn.Position = UDim2.new(1, -50, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextScaled = true
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = dialog
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            dialog:Destroy()
        end)
        
        -- Auto-close dialog after 3 seconds
        game:GetService("Debris"):AddItem(dialog, 3)
    end)
    
    return parent
end

return GamesFeature