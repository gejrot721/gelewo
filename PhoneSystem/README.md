# 📱 Sistem Telepon Roblox

Sistem telepon modern dan lengkap untuk Roblox dengan fitur-fitur canggih dan desain yang responsif.

## ✨ Fitur Utama

### 🎮 **Fitur Games**
- Menu game dengan kartu interaktif
- Sistem peluncuran game
- Animasi hover dan efek visual
- Tombol "Add More Games" untuk ekspansi

### 💬 **Fitur Chat**
- Integrasi dengan Chat service Roblox
- Multiple channel (Global, Team, Private)
- Bubble chat dengan animasi
- Auto-scroll dan real-time messaging
- Simulasi pesan masuk otomatis

### 📞 **Fitur Telepon**
- Daftar kontak dengan avatar dan status
- Simulasi panggilan telepon dan video
- Interface panggilan dengan kontrol lengkap
- Timer durasi panggilan
- Tombol mute, speaker, dan end call

### 🎵 **Fitur Musik**
- Music player dengan kontrol lengkap
- Library musik dengan berbagai genre
- Progress bar dan timer
- Kontrol volume
- Play, pause, next, previous
- Auto-play dan loop

### ⚙️ **Panel Pengaturan**
- Slider volume master
- Toggle notifikasi dan auto-play
- Dropdown tema dan bahasa
- Tombol reset ke default
- Informasi tentang sistem

## 🎨 **Desain Modern**

- **UI Responsif**: Auto-scaling untuk mobile, PC, dan konsol
- **Animasi Halus**: Transisi dan efek visual yang smooth
- **Desain Clean**: Interface modern dengan sudut melengkung
- **Gradient Background**: Efek visual yang menarik
- **Ikon Intuitif**: Emoji dan simbol yang mudah dipahami

## 🔧 **Instalasi**

1. **Upload Files**: Upload semua file ke Roblox Studio
2. **Struktur Folder**:
   ```
   PhoneSystem/
   ├── PhoneSystem.lua (Main system)
   ├── MainScript.lua (Initialization)
   └── Features/
       ├── GamesFeature.lua
       ├── ChatFeature.lua
       ├── PhoneCallFeature.lua
       ├── MusicFeature.lua
       └── SettingsPanel.lua
   ```

3. **Setup**: 
   - Place `MainScript.lua` in ServerScriptService
   - Place `PhoneSystem.lua` and `Features/` folder in ReplicatedStorage

## 🎮 **Cara Penggunaan**

### **Membuka Telepon**
- Klik tombol **☰** di pojok kanan atas
- Atau tekan **F1** pada keyboard
- Telepon akan muncul dengan animasi halus

### **Navigasi**
- Gunakan tombol di navigation bar bawah:
  - 🎮 **Games**: Akses library game
  - 💬 **Chat**: Kirim pesan dan chat
  - 📞 **Phone**: Lihat kontak dan panggilan
  - 🎵 **Music**: Putar musik dan kontrol audio
  - ⚙️ **Settings**: Pengaturan sistem

### **Fitur Games**
- Klik kartu game untuk melihat detail
- Klik tombol **PLAY** untuk meluncurkan game
- Gunakan tombol **➕ Add More Games** untuk menambah game

### **Fitur Chat**
- Pilih channel di bagian atas (Global/Team/Private)
- Ketik pesan di text box bawah
- Tekan Enter atau klik tombol **📤** untuk mengirim
- Pesan akan muncul dengan bubble chat

### **Fitur Telepon**
- Lihat daftar kontak dengan status online
- Klik tombol **📞** untuk panggilan suara
- Klik tombol **📹** untuk panggilan video
- Gunakan kontrol saat panggilan aktif

### **Fitur Musik**
- Pilih lagu dari library
- Gunakan kontrol play/pause, next/previous
- Atur volume dengan slider
- Lihat progress lagu yang sedang diputar

### **Pengaturan**
- Atur volume master
- Toggle notifikasi dan auto-play
- Ubah tema dan bahasa
- Reset ke pengaturan default

## 📱 **Responsive Design**

### **Mobile**
- UI skala 0.8 untuk layar kecil
- Tombol besar untuk touch
- Scrollable content

### **PC**
- UI skala 0.7 untuk layar desktop
- Hover effects
- Keyboard shortcuts

### **Console**
- UI skala 0.9 untuk controller
- Optimized untuk gamepad
- Large touch targets

## 🔧 **Kustomisasi**

### **Menambah Game Baru**
Edit `GamesFeature.lua`:
```lua
local gameData = {
    {
        name = "Your Game",
        description = "Game description",
        icon = "🎮",
        gameId = YOUR_GAME_ID,
        color = Color3.fromRGB(255, 100, 100)
    }
}
```

### **Menambah Kontak Baru**
Edit `PhoneCallFeature.lua`:
```lua
local sampleContacts = {
    {
        name = "Contact Name",
        number = "+1-555-XXXX",
        avatar = "👤",
        color = Color3.fromRGB(100, 100, 255),
        status = "online"
    }
}
```

### **Menambah Lagu Baru**
Edit `MusicFeature.lua`:
```lua
local musicLibrary = {
    {
        title = "Song Title",
        artist = "Artist Name",
        duration = "3:45",
        genre = "Genre",
        icon = "🎵",
        color = Color3.fromRGB(255, 100, 100),
        soundId = SOUND_ID
    }
}
```

## 🎵 **Sound Effects**

Sistem dilengkapi dengan efek suara untuk:
- Klik tombol
- Membuka/menutup menu
- Panggilan telepon
- Notifikasi

## 🚀 **Fitur Lanjutan**

- **Auto-scaling**: UI menyesuaikan perangkat otomatis
- **Animasi**: Transisi halus antar fitur
- **Sound Integration**: Efek suara untuk interaksi
- **Real-time Updates**: Chat dan status kontak real-time
- **Modular Design**: Mudah menambah fitur baru

## 📝 **Catatan Penting**

- Pastikan semua file diupload dengan struktur yang benar
- Sound ID harus valid untuk musik dan efek suara
- Game ID harus valid untuk fitur games
- Sistem kompatibel dengan semua perangkat Roblox

## 🎯 **Pengembangan Selanjutnya**

- [ ] Integrasi dengan RemoteEvents untuk multiplayer
- [ ] Database untuk menyimpan kontak dan pengaturan
- [ ] Fitur grup chat
- [ ] Video call dengan camera
- [ ] Push notifications
- [ ] Themes dan customization lebih banyak

---

**Dibuat dengan ❤️ untuk komunitas Roblox**

*Sistem telepon modern yang responsif dan mudah digunakan!*