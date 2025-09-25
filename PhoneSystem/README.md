# Sistem Handphone Roblox

Sistem handphone lengkap untuk Roblox dengan fitur chat, telepon, dan panggilan grup yang menggunakan voice chat Roblox.

## Fitur Utama

### 📱 Desain Handphone Modern
- UI dengan gaya Android Material Design
- Responsif untuk mobile, PC, dan konsol
- Auto-scaling berdasarkan ukuran layar
- Animasi smooth dan transisi yang halus

### 📞 Sistem Telepon
- **Panggilan Individu**: Telepon satu-satu dengan voice chat
- **Panggilan Grup**: Telepon grup hingga 8 peserta
- **Voice Chat**: Integrasi penuh dengan sistem voice chat Roblox
- **Kontrol Panggilan**: Mute, speaker, video, keypad
- **Notifikasi**: Notifikasi panggilan masuk yang menarik

### 💬 Sistem Chat
- **Pesan Teks**: Chat real-time antar pemain
- **Riwayat Pesan**: Penyimpanan dan tampilan riwayat percakapan
- **Status Pesan**: Indikator pesan terkirim dan dibaca
- **UI Modern**: Bubble chat dengan desain yang menarik

### 👥 Sistem Kontak
- **Daftar Kontak**: Lihat semua pemain online
- **Pencarian**: Cari kontak berdasarkan nama
- **Status Online**: Indikator status online/offline
- **Aksi Cepat**: Tombol telepon dan chat langsung dari kontak

### 🎛️ Tombol Menu Responsif
- **Floating Button**: Tombol menu yang dapat dipindah-pindah
- **Draggable**: Dapat diseret ke posisi yang diinginkan
- **Responsif**: Ukuran dan posisi menyesuaikan perangkat
- **Animasi**: Efek hover dan click yang menarik

## Instalasi

### 1. Struktur Folder
Pastikan struktur folder di ReplicatedStorage sebagai berikut:
```
ReplicatedStorage/
└── PhoneSystem/
    ├── Client/
    │   ├── Controllers/
    │   │   └── PhoneController.lua
    │   ├── Services/
    │   │   └── VoiceChatService.lua
    │   ├── UI/
    │   │   ├── Phone/
    │   │   │   ├── PhoneUI.lua
    │   │   │   └── MenuButton.lua
    │   │   ├── Contacts/
    │   │   │   └── ContactsUI.lua
    │   │   ├── Chat/
    │   │   │   └── ChatUI.lua
    │   │   └── Calls/
    │   │       ├── CallUI.lua
    │   │       └── GroupCallUI.lua
    │   └── PhoneSystemClient.lua
    ├── Server/
    │   ├── PhoneServer.lua
    │   └── PhoneSystemServer.lua
    └── Shared/
        ├── PhoneConfig.lua
        ├── PhoneTypes.lua
        └── Utils/
            └── UIScale.lua
```

### 2. Script Setup

#### Server Script
Buat **Server Script** baru di ServerScriptService dengan nama `PhoneSystemServer` dan masukkan kode dari `Server/PhoneSystemServer.lua`.

#### Local Script
Buat **Local Script** baru di StarterPlayerScripts dengan nama `PhoneSystemClient` dan masukkan kode dari `Client/PhoneSystemClient.lua`.

### 3. Remote Events
Script akan secara otomatis membuat Remote Events berikut di ReplicatedStorage:
- `PhoneSystemEvent`: Event utama untuk komunikasi client-server
- `PhoneVoiceChatEvent`: Event untuk voice chat
- `PhoneContactEvent`: Event untuk sistem kontak

## Konfigurasi

### PhoneConfig.lua
File konfigurasi utama yang berisi:
- **UI Colors**: Warna-warna untuk tema Material Design
- **Feature Flags**: Enable/disable fitur tertentu
- **Voice Chat Settings**: Pengaturan voice chat
- **Auto-scale Settings**: Pengaturan responsive design
- **Network Settings**: Pengaturan jaringan dan rate limits

### Contoh Konfigurasi
```lua
-- Mengubah warna tema
PhoneConfig.UI.COLORS.PRIMARY = Color3.fromRGB(76, 175, 80) -- Hijau

-- Mengubah ukuran maksimal grup call
PhoneConfig.VOICE_CHAT.MAX_GROUP_PARTICIPANTS = 12

-- Mengubah animasi speed
PhoneConfig.UI.ANIMATION_SPEED = 0.5
```

## Penggunaan

### Untuk Pemain
1. **Buka Handphone**: Klik tombol 📱 di kanan tengah layar
2. **Navigasi**: Gunakan tombol back/home di navigation bar
3. **Kontak**: Buka app Contacts untuk melihat pemain online
4. **Telepon**: Klik tombol telepon di kontak untuk memanggil
5. **Chat**: Klik tombol chat untuk mengirim pesan
6. **Grup Call**: Gunakan tombol + di contacts untuk membuat grup call

### Untuk Developer
```lua
-- Mendapatkan state phone
local phoneState = PhoneController.getState()

-- Membuka kontak programmatically
PhoneController.openContacts()

-- Memulai panggilan
PhoneController.startCall(contactData)
```

## Kompatibilitas

### Platform Support
- ✅ **PC**: Full support dengan mouse dan keyboard
- ✅ **Mobile**: Touch-optimized dengan haptic feedback
- ✅ **Console**: Gamepad support dengan UI yang disesuaikan
- ✅ **Tablet**: Responsive design untuk layar besar

### Device Detection
Sistem secara otomatis mendeteksi perangkat dan menyesuaikan:
- Ukuran UI dan font
- Spacing dan padding
- Input handling
- Animation speed

## Voice Chat Requirements

### Roblox Voice Chat
- Voice chat harus diaktifkan di game settings
- Pemain harus memiliki Voice Chat enabled
- Game harus memiliki permission untuk voice chat

### Platform Support
- PC: Full voice chat support
- Mobile: Voice chat support (iOS 14.5+, Android 8+)
- Console: Voice chat support pada Xbox One/Series dan PS4/PS5

## Troubleshooting

### Voice Chat Tidak Berfungsi
1. Pastikan Voice Chat diaktifkan di game settings
2. Cek apakah pemain memiliki Voice Chat permission
3. Restart game jika voice chat tidak terdeteksi

### UI Tidak Responsif
1. Pastikan UIScale.lua ter-load dengan benar
2. Cek apakah PhoneConfig.AUTOSCALE settings sudah benar
3. Restart client script jika perlu

### Panggilan Tidak Terhubung
1. Cek koneksi internet
2. Pastikan server script berjalan dengan baik
3. Cek console untuk error messages

## Performance

### Optimasi
- UI menggunakan Object Pooling untuk message bubbles
- Animasi dioptimalkan dengan TweenService
- Voice chat menggunakan native Roblox VoiceChatService
- Network traffic diminimalkan dengan rate limiting

### System Requirements
- **Minimum**: 1GB RAM, DirectX 11
- **Recommended**: 2GB RAM, DirectX 12
- **Network**: Stable internet connection untuk voice chat

## License

Sistem ini dibuat untuk penggunaan di Roblox games. Silakan modifikasi sesuai kebutuhan project Anda.

## Support

Jika mengalami masalah atau membutuhkan bantuan:
1. Cek console untuk error messages
2. Pastikan semua file ter-install dengan benar
3. Verifikasi Voice Chat settings di game

---

**Catatan**: Pastikan untuk menguji sistem di berbagai perangkat untuk memastikan kompatibilitas yang optimal.