-- Installation Guide
-- Panduan instalasi sistem telepon Roblox

--[[
    📱 SISTEM TELEPON ROBLOX - PANDUAN INSTALASI
    =============================================
    
    Sistem telepon modern dan lengkap untuk Roblox dengan fitur:
    - Games, Chat, Phone Calls, Music Player, Settings
    - UI responsif untuk Mobile, PC, dan Console
    - Animasi halus dan efek suara
    - Desain modern dengan tema yang dapat dikustomisasi
    
    LANGKAH INSTALASI:
    =================
    
    1. PREPARASI FOLDER
    -------------------
    - Buat folder "PhoneSystem" di ReplicatedStorage
    - Buat subfolder "Features" di dalam PhoneSystem
    
    2. UPLOAD FILES
    --------------
    Upload file-file berikut ke lokasi yang sesuai:
    
    ReplicatedStorage/PhoneSystem/
    ├── PhoneSystem.lua (Main system file)
    ├── Config.lua (Configuration file)
    └── Features/
        ├── GamesFeature.lua
        ├── ChatFeature.lua
        ├── PhoneCallFeature.lua
        ├── MusicFeature.lua
        └── SettingsPanel.lua
    
    ServerScriptService/
    └── MainScript.lua (Initialization script)
    
    3. KONFIGURASI
    --------------
    - Edit Config.lua untuk mengubah pengaturan default
    - Ganti Sound IDs dengan ID yang valid
    - Sesuaikan Game IDs dengan game yang ingin ditampilkan
    - Kustomisasi warna dan tema sesuai kebutuhan
    
    4. TESTING
    ----------
    - Upload TestScript.lua ke ServerScriptService untuk testing
    - Jalankan game dan tekan F1 untuk membuka telepon
    - Test semua fitur untuk memastikan berfungsi dengan baik
    
    5. PENYESUAIAN
    --------------
    - Tambahkan game baru di GamesFeature.lua
    - Tambahkan kontak baru di PhoneCallFeature.lua
    - Tambahkan lagu baru di MusicFeature.lua
    - Kustomisasi tema di Config.lua
    
    CARA PENGGUNAAN:
    ================
    
    Membuka Telepon:
    - Klik tombol ☰ di pojok kanan atas
    - Atau tekan F1 pada keyboard
    
    Navigasi:
    - Games: Akses library game
    - Chat: Kirim pesan dan chat
    - Phone: Lihat kontak dan panggilan
    - Music: Putar musik dan kontrol audio
    - Settings: Pengaturan sistem
    
    Fitur Utama:
    - UI auto-scaling untuk semua perangkat
    - Animasi halus dan efek visual
    - Sound effects untuk interaksi
    - Real-time chat dan status kontak
    - Music player dengan kontrol lengkap
    
    TROUBLESHOOTING:
    ================
    
    Masalah Umum:
    1. Telepon tidak muncul
       - Pastikan MainScript.lua ada di ServerScriptService
       - Check console untuk error messages
       - Pastikan semua file sudah diupload dengan benar
    
    2. Fitur tidak berfungsi
       - Check apakah file Features sudah ada
       - Pastikan struktur folder sudah benar
       - Check console untuk error messages
    
    3. Sound tidak berfungsi
       - Pastikan Sound IDs valid
       - Check apakah SoundService berfungsi
       - Pastikan volume tidak di-mute
    
    4. UI tidak responsif
       - Check device detection
       - Pastikan scaling configuration benar
       - Test di berbagai ukuran layar
    
    KUSTOMISASI LANJUTAN:
    =====================
    
    Menambah Fitur Baru:
    1. Buat file baru di folder Features/
    2. Implementasikan interface dan logic
    3. Tambahkan ke PhoneSystem.lua
    4. Update navigation bar jika diperlukan
    
    Mengubah Tema:
    1. Edit Config.lua
    2. Ubah warna dan styling
    3. Test di berbagai kondisi
    
    Menambah Sound:
    1. Upload sound ke Roblox
    2. Dapatkan Sound ID
    3. Update Config.lua
    4. Test sound effects
    
    SUPPORT:
    ========
    
    Untuk bantuan lebih lanjut:
    - Check README.md untuk dokumentasi lengkap
    - Gunakan TestScript.lua untuk debugging
    - Check console output untuk error messages
    - Pastikan semua dependencies sudah terpenuhi
    
    VERSI: 1.0.0
    UPDATE: 2024
    AUTHOR: Phone System Developer
    
    Selamat menggunakan sistem telepon Roblox! 📱
]]

-- Export installation guide
return {
    VERSION = "1.0.0",
    AUTHOR = "Phone System Developer",
    LAST_UPDATED = "2024",
    FEATURES = {
        "Games Library",
        "Chat System", 
        "Phone Calls",
        "Music Player",
        "Settings Panel",
        "Responsive UI",
        "Sound Effects",
        "Animations"
    },
    SUPPORTED_DEVICES = {
        "Mobile",
        "PC", 
        "Console"
    }
}