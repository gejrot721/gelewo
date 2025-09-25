-- Tutorial Interaktif Pemasangan Sistem Handphone
-- Script ini akan memandu Anda step-by-step

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Fungsi untuk menampilkan notifikasi tutorial
local function showTutorialNotification(title, message, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = duration or 5,
        Button1 = "OK"
    })
end

-- Fungsi untuk menampilkan GUI tutorial
local function createTutorialGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TutorialGUI"
    screenGui.Parent = playerGui
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.Parent = screenGui
    
    -- Tutorial Frame
    local tutorialFrame = Instance.new("Frame")
    tutorialFrame.Size = UDim2.new(0, 500, 0, 400)
    tutorialFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    tutorialFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    tutorialFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = tutorialFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "📱 Tutorial Pemasangan Sistem Handphone"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = tutorialFrame
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -40, 1, -100)
    contentLabel.Position = UDim2.new(0, 20, 0, 60)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = ""
    contentLabel.TextColor3 = Color3.new(1, 1, 1)
    contentLabel.TextSize = 14
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = tutorialFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(1, -120, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    closeButton.Text = "Tutup"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = tutorialFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.2, 0)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return contentLabel
end

-- Tutorial steps
local tutorialSteps = {
    {
        title = "Langkah 1: Persiapan",
        content = [[1. Buka Roblox Studio
2. Pilih game yang ingin dipasangi sistem handphone
3. Pastikan Anda memiliki akses admin
4. Backup game Anda terlebih dahulu

✅ Pastikan Voice Chat sudah diaktifkan di Game Settings!]]
    },
    {
        title = "Langkah 2: Buat Folder",
        content = [[1. Klik kanan pada ServerStorage
2. Insert Object → Folder
3. Rename menjadi "PhoneSystem"

📁 Folder ini akan menyimpan semua script sistem handphone]]
    },
    {
        title = "Langkah 3: Script Konfigurasi",
        content = [[1. Klik kanan pada folder PhoneSystem
2. Insert Object → ModuleScript
3. Rename menjadi "PhoneConfig"
4. Copy-paste isi file PhoneSystemConfig.lua
5. Save script (Ctrl+S)

⚙️ Script ini berisi semua pengaturan sistem]]
    },
    {
        title = "Langkah 4: Server Script",
        content = [[1. Klik kanan pada ServerScriptService
2. Insert Object → Script
3. Rename menjadi "PhoneSystemServer"
4. Copy-paste isi file PhoneSystemServer.lua
5. Edit require path sesuai struktur folder
6. Save script (Ctrl+S)

🖥️ Script ini menangani logika server]]
    },
    {
        title = "Langkah 5: Client Script",
        content = [[1. Buka StarterPlayer → StarterPlayerScripts
2. Klik kanan → Insert Object → LocalScript
3. Rename menjadi "PhoneSystemClient"
4. Copy-paste isi file PhoneSystem.lua
5. Edit require path untuk PhoneConfig
6. Save script (Ctrl+S)

📱 Script ini menangani UI dan interaksi client]]
    },
    {
        title = "Langkah 6: RemoteEvents",
        content = [[1. Klik kanan pada ReplicatedStorage
2. Insert Object → Folder
3. Rename menjadi "PhoneEvents"
4. Buat 3 RemoteEvent dengan nama:
   - CallPlayer
   - ChatMessage
   - GroupCall

📡 RemoteEvents untuk komunikasi client-server]]
    },
    {
        title = "Langkah 7: Voice Chat",
        content = [[1. Klik Game Settings (gear icon)
2. Pilih tab Privacy
3. Centang "Allow Voice Chat"
4. Set "Voice Chat Mode" ke "Enabled"
5. Klik Save

🎤 Aktifkan Voice Chat untuk fitur panggilan]]
    },
    {
        title = "Langkah 8: Testing",
        content = [[1. Klik Play untuk test di studio
2. Atau publish dan test di server
3. Cek apakah tombol handphone muncul
4. Test fitur call dan chat dengan player lain

🧪 Pastikan semua fitur berfungsi dengan baik!]]
    }
}

-- Menampilkan tutorial
local currentStep = 1
local contentLabel = createTutorialGUI()

local function updateTutorial()
    if currentStep <= #tutorialSteps then
        local step = tutorialSteps[currentStep]
        contentLabel.Text = step.content
        
        showTutorialNotification(
            "📱 " .. step.title,
            "Lihat GUI tutorial untuk detail lengkap",
            3
        )
    end
end

-- Tombol navigasi
local function createNavigationButtons()
    local screenGui = playerGui:FindFirstChild("TutorialGUI")
    if not screenGui then return end
    
    local tutorialFrame = screenGui:FindFirstChild("Frame")
    if not tutorialFrame then return end
    
    -- Previous button
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0, 80, 0, 30)
    prevButton.Position = UDim2.new(0, 20, 1, -40)
    prevButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    prevButton.Text = "← Sebelumnya"
    prevButton.TextColor3 = Color3.new(1, 1, 1)
    prevButton.TextSize = 12
    prevButton.Font = Enum.Font.Gotham
    prevButton.Parent = tutorialFrame
    
    local prevCorner = Instance.new("UICorner")
    prevCorner.CornerRadius = UDim.new(0.2, 0)
    prevCorner.Parent = prevButton
    
    -- Next button
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0, 80, 0, 30)
    nextButton.Position = UDim2.new(0, 110, 1, -40)
    nextButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    nextButton.Text = "Selanjutnya →"
    nextButton.TextColor3 = Color3.new(1, 1, 1)
    nextButton.TextSize = 12
    nextButton.Font = Enum.Font.Gotham
    nextButton.Parent = tutorialFrame
    
    local nextCorner = Instance.new("UICorner")
    nextCorner.CornerRadius = UDim.new(0.2, 0)
    nextCorner.Parent = nextButton
    
    -- Step indicator
    local stepLabel = Instance.new("TextLabel")
    stepLabel.Size = UDim2.new(0, 100, 0, 30)
    stepLabel.Position = UDim2.new(0, 200, 1, -40)
    stepLabel.BackgroundTransparency = 1
    stepLabel.Text = "Langkah " .. currentStep .. "/" .. #tutorialSteps
    stepLabel.TextColor3 = Color3.new(1, 1, 1)
    stepLabel.TextSize = 12
    stepLabel.Font = Enum.Font.Gotham
    stepLabel.Parent = tutorialFrame
    
    -- Button connections
    prevButton.MouseButton1Click:Connect(function()
        if currentStep > 1 then
            currentStep = currentStep - 1
            updateTutorial()
            stepLabel.Text = "Langkah " .. currentStep .. "/" .. #tutorialSteps
            prevButton.Visible = currentStep > 1
        end
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        if currentStep < #tutorialSteps then
            currentStep = currentStep + 1
            updateTutorial()
            stepLabel.Text = "Langkah " .. currentStep .. "/" .. #tutorialSteps
            prevButton.Visible = currentStep > 1
        end
    end)
    
    -- Hide previous button on first step
    prevButton.Visible = currentStep > 1
end

-- Inisialisasi tutorial
updateTutorial()
createNavigationButtons()

-- Notifikasi selamat datang
wait(1)
showTutorialNotification(
    "🎉 Selamat Datang!",
    "Tutorial pemasangan sistem handphone akan dimulai. Ikuti langkah-langkahnya dengan seksama!",
    5
)