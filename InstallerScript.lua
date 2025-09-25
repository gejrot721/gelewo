-- Script Pemasangan Otomatis Sistem Handphone Roblox
-- Jalankan script ini di ServerScriptService untuk setup otomatis

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🚀 Memulai pemasangan sistem handphone...")

-- Fungsi untuk membuat folder jika belum ada
local function createFolderIfNotExists(parent, folderName)
    local folder = parent:FindFirstChild(folderName)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = parent
        print("✅ Folder " .. folderName .. " berhasil dibuat")
    else
        print("📁 Folder " .. folderName .. " sudah ada")
    end
    return folder
end

-- Fungsi untuk membuat RemoteEvent jika belum ada
local function createRemoteEventIfNotExists(parent, eventName)
    local event = parent:FindFirstChild(eventName)
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = eventName
        event.Parent = parent
        print("✅ RemoteEvent " .. eventName .. " berhasil dibuat")
    else
        print("📡 RemoteEvent " .. eventName .. " sudah ada")
    end
    return event
end

-- 1. Buat folder PhoneSystem di ServerStorage
local phoneSystemFolder = createFolderIfNotExists(ServerStorage, "PhoneSystem")

-- 2. Buat PhoneConfig ModuleScript
local phoneConfig = phoneSystemFolder:FindFirstChild("PhoneConfig")
if not phoneConfig then
    phoneConfig = Instance.new("ModuleScript")
    phoneConfig.Name = "PhoneConfig"
    phoneConfig.Parent = phoneSystemFolder
    
    -- Isi konfigurasi (akan diisi manual)
    phoneConfig.Source = [[
-- Phone System Configuration
local PhoneConfig = {}

-- UI Colors (Android Material Design inspired)
PhoneConfig.Colors = {
    Primary = Color3.fromRGB(76, 175, 80),
    PrimaryDark = Color3.fromRGB(56, 142, 60),
    Accent = Color3.fromRGB(33, 150, 243),
    Background = Color3.fromRGB(33, 33, 33),
    Surface = Color3.fromRGB(45, 45, 45),
    Text = Color3.new(1, 1, 1),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    Error = Color3.fromRGB(244, 67, 54),
    Warning = Color3.fromRGB(255, 152, 0),
    Success = Color3.fromRGB(76, 175, 80)
}

-- Bahasa default
PhoneConfig.Language = "Indonesian"

-- Text dalam bahasa Indonesia
PhoneConfig.Texts = {
    Indonesian = {
        Phone = "Handphone",
        Home = "Beranda",
        Contacts = "Kontak",
        Chat = "Pesan",
        Calls = "Panggilan",
        SearchPlayers = "Cari pemain...",
        TypeMessage = "Ketik pesan...",
        IncomingCall = "Panggilan masuk dari",
        Answer = "Angkat",
        Decline = "Tolak",
        HangUp = "Tutup",
        Mute = "Bisukan",
        Unmute = "Suarakan",
        QuickCall = "Panggilan Cepat",
        QuickChat = "Chat Cepat",
        GroupCall = "Panggilan Grup",
        Online = "Online",
        Offline = "Offline",
        Busy = "Sibuk",
        NoAnswer = "Tidak Menjawab",
        StartCall = "Mulai Panggilan",
        EndCall = "Akhiri Panggilan",
        JoinCall = "Bergabung",
        LeaveCall = "Keluar",
        Settings = "Pengaturan",
        Volume = "Volume",
        Microphone = "Mikrofon",
        Speaker = "Speaker",
        Connected = "Terhubung",
        Disconnected = "Terputus",
        Connecting = "Menghubungkan...",
        CallEnded = "Panggilan Berakhir",
        CallStarted = "Panggilan Dimulai",
        ErrorOccurred = "Terjadi Kesalahan",
        TryAgain = "Coba Lagi",
        Cancel = "Batal",
        Confirm = "Konfirmasi",
        Yes = "Ya",
        No = "Tidak",
        OK = "OK"
    }
}

-- Helper function
function PhoneConfig:GetText(key)
    local language = self.Language
    if self.Texts[language] and self.Texts[language][key] then
        return self.Texts[language][key]
    end
    return self.Texts.Indonesian[key] or key
end

return PhoneConfig
]]
    
    print("✅ PhoneConfig berhasil dibuat")
else
    print("⚙️ PhoneConfig sudah ada")
end

-- 3. Buat folder PhoneEvents di ReplicatedStorage
local phoneEventsFolder = createFolderIfNotExists(ReplicatedStorage, "PhoneEvents")

-- 4. Buat RemoteEvents
createRemoteEventIfNotExists(phoneEventsFolder, "CallPlayer")
createRemoteEventIfNotExists(phoneEventsFolder, "ChatMessage")
createRemoteEventIfNotExists(phoneEventsFolder, "GroupCall")

-- 5. Buat PhoneConfig copy di ReplicatedStorage (untuk client access)
local clientPhoneConfig = ReplicatedStorage:FindFirstChild("PhoneConfig")
if not clientPhoneConfig then
    clientPhoneConfig = phoneConfig:Clone()
    clientPhoneConfig.Parent = ReplicatedStorage
    print("✅ PhoneConfig berhasil di-copy ke ReplicatedStorage")
else
    print("📋 PhoneConfig sudah ada di ReplicatedStorage")
end

print("🎉 Setup otomatis selesai!")
print("📝 Langkah selanjutnya:")
print("1. Masukkan script server ke ServerScriptService")
print("2. Masukkan script client ke StarterPlayerScripts")
print("3. Aktifkan Voice Chat di Game Settings")
print("4. Test sistem handphone")

-- Pemberitahuan untuk developer
wait(2)
print("🔔 PERINGATAN: Jangan lupa untuk:")
print("- Mengaktifkan Voice Chat di Game Settings")
print("- Test semua fitur dengan player lain")
print("- Cek console untuk error messages")