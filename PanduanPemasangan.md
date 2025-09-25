# 📱 Panduan Lengkap Pemasangan Sistem Handphone Roblox

## 🎯 Daftar Isi
1. [Persiapan](#persiapan)
2. [Langkah-langkah Pemasangan](#langkah-langkah-pemasangan)
3. [Konfigurasi Bahasa Indonesia](#konfigurasi-bahasa-indonesia)
4. [Pengaturan Voice Chat](#pengaturan-voice-chat)
5. [Troubleshooting](#troubleshooting)
6. [FAQ](#faq)

## 🛠️ Persiapan

### Yang Diperlukan:
- **Roblox Studio** (versi terbaru)
- **Akses Admin** ke game/place Anda
- **Voice Chat** sudah diaktifkan di game
- **Pengetahuan dasar** tentang scripting Roblox

### Persiapan Game:
1. Buka Roblox Studio
2. Pilih game/place yang ingin dipasangi sistem handphone
3. Pastikan Anda memiliki akses untuk mengedit script

## 📋 Langkah-langkah Pemasangan

### **Langkah 1: Membuat Folder Struktur**

1. **Buka Explorer** di Roblox Studio
2. **Klik kanan** pada `ServerStorage`
3. **Pilih** `Insert Object` → `Folder`
4. **Rename** folder menjadi `PhoneSystem`

### **Langkah 2: Memasang Script Konfigurasi**

1. **Klik kanan** pada folder `PhoneSystem`
2. **Pilih** `Insert Object` → `ModuleScript`
3. **Rename** menjadi `PhoneConfig`
4. **Copy-paste** isi dari file `PhoneSystemConfig.lua` ke dalam script ini
5. **Save** script (Ctrl+S)

### **Langkah 3: Memasang Server Script**

1. **Klik kanan** pada `ServerScriptService`
2. **Pilih** `Insert Object` → `Script`
3. **Rename** menjadi `PhoneSystemServer`
4. **Copy-paste** isi dari file `PhoneSystemServer.lua`
5. **Edit** baris ini di bagian atas script:
   ```lua
   local PhoneConfig = require(game.ServerStorage.PhoneSystem.PhoneConfig)
   ```
6. **Save** script (Ctrl+S)

### **Langkah 4: Memasang Client Script**

1. **Buka** `StarterPlayer` → `StarterPlayerScripts`
2. **Klik kanan** → `Insert Object` → `LocalScript`
3. **Rename** menjadi `PhoneSystemClient`
4. **Copy-paste** isi dari file `PhoneSystem.lua`
5. **Edit** baris ini di bagian atas script:
   ```lua
   local PhoneConfig = require(game.ReplicatedStorage.PhoneConfig)
   ```
6. **Save** script (Ctrl+S)

### **Langkah 5: Mengatur ReplicatedStorage**

1. **Klik kanan** pada `ReplicatedStorage`
2. **Pilih** `Insert Object` → `Folder`
3. **Rename** menjadi `PhoneEvents`
4. **Klik kanan** pada folder `PhoneEvents`
5. **Insert** → `RemoteEvent` (3 kali)
6. **Rename** menjadi:
   - `CallPlayer`
   - `ChatMessage`
   - `GroupCall`

### **Langkah 6: Mengatur Voice Chat**

1. **Klik** `Game Settings` (gear icon di toolbar)
2. **Pilih** tab `Privacy`
3. **Centang** `Allow Voice Chat`
4. **Set** `Voice Chat Mode` ke `Enabled`
5. **Klik** `Save`

### **Langkah 7: Testing**

1. **Klik** `Play` untuk test di studio
2. **Atau** publish game dan test di server
3. **Cek** apakah tombol handphone muncul di layar
4. **Test** fitur call dan chat

## 🇮🇩 Konfigurasi Bahasa Indonesia

### **Langkah 1: Update Konfigurasi Bahasa**

Buka script `PhoneConfig` dan tambahkan bahasa Indonesia:

```lua
-- Tambahkan di bagian PhoneConfig.Texts
PhoneConfig.Texts = {
    English = {
        -- ... (text bahasa Inggris yang sudah ada)
    },
    
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
        Contacts = "Kontak",
        Online = "Online",
        Offline = "Offline",
        Busy = "Sibuk",
        NoAnswer = "Tidak Menjawab",
        StartCall = "Mulai Panggilan",
        EndCall = "Akhiri Panggilan",
        JoinCall = "Bergabung",
        LeaveCall = "Keluar",
        InviteToCall = "Undang ke Panggilan",
        CallHistory = "Riwayat Panggilan",
        MessageHistory = "Riwayat Pesan",
        Settings = "Pengaturan",
        Volume = "Volume",
        Microphone = "Mikrofon",
        Speaker = "Speaker",
        ConnectionStatus = "Status Koneksi",
        Connected = "Terhubung",
        Disconnected = "Terputus",
        Connecting = "Menghubungkan...",
        CallEnded = "Panggilan Berakhir",
        CallStarted = "Panggilan Dimulai",
        UserJoined = "Bergabung",
        UserLeft = "Keluar",
        ErrorOccurred = "Terjadi Kesalahan",
        TryAgain = "Coba Lagi",
        Cancel = "Batal",
        Confirm = "Konfirmasi",
        Yes = "Ya",
        No = "Tidak",
        OK = "OK"
    }
}
```

### **Langkah 2: Set Bahasa Default**

Ubah bahasa default di konfigurasi:

```lua
-- Ubah baris ini di PhoneConfig
PhoneConfig.Language = "Indonesian"
```

### **Langkah 3: Update Client Script**

Tambahkan fungsi untuk mengganti bahasa di client script:

```lua
-- Tambahkan di PhoneSystem class
function PhoneSystem:ChangeLanguage(language)
    PhoneConfig.Language = language
    self:UpdateUITexts()
end

function PhoneSystem:UpdateUITexts()
    -- Update semua text di UI dengan bahasa yang dipilih
    self.titleLabel.Text = PhoneConfig:GetText("Phone")
    -- Tambahkan update untuk semua text lainnya
end
```

## 🎤 Pengaturan Voice Chat

### **Untuk Developer:**

1. **Aktifkan Voice Chat** di Game Settings
2. **Set Permissions** yang sesuai
3. **Test** di studio dan server

### **Untuk Player:**

1. **Buka Settings** di Roblox
2. **Pilih** `Privacy` → `Voice Chat`
3. **Aktifkan** microphone
4. **Set** volume yang sesuai
5. **Test** dengan teman

## 🔧 Troubleshooting

### **Masalah Umum:**

#### **Tombol Handphone Tidak Muncul:**
- ✅ Cek apakah script ada di `StarterPlayerScripts`
- ✅ Pastikan tidak ada error di console
- ✅ Restart game dan coba lagi

#### **Voice Chat Tidak Bekerja:**
- ✅ Pastikan Voice Chat enabled di Game Settings
- ✅ Cek microphone permissions player
- ✅ Test dengan player lain

#### **Call Tidak Terhubung:**
- ✅ Cek server script berjalan dengan benar
- ✅ Pastikan RemoteEvents sudah dibuat
- ✅ Cek network connection

#### **UI Tidak Responsif:**
- ✅ Cek autoscale settings di config
- ✅ Test di device yang berbeda
- ✅ Adjust phone size di konfigurasi

### **Error Messages:**

#### **"PhoneConfig not found":**
- Pastikan script `PhoneConfig` ada di `ServerStorage.PhoneSystem`
- Cek require path di script lain

#### **"RemoteEvent not found":**
- Pastikan RemoteEvents dibuat di `ReplicatedStorage.PhoneEvents`
- Cek nama RemoteEvent sesuai dengan script

#### **"Voice Chat Service not available":**
- Aktifkan Voice Chat di Game Settings
- Pastikan player sudah enable microphone

## ❓ FAQ (Frequently Asked Questions)

### **Q: Apakah sistem ini gratis?**
A: Ya, sistem ini gratis dan open source.

### **Q: Berapa banyak player yang bisa bergabung dalam group call?**
A: Maksimal 8 player dalam satu group call.

### **Q: Apakah bisa di-customize tampilannya?**
A: Ya, semua warna dan ukuran bisa diubah di file konfigurasi.

### **Q: Apakah kompatibel dengan semua device?**
A: Ya, sudah dioptimasi untuk mobile, PC, dan console.

### **Q: Bagaimana cara menambah fitur baru?**
A: Edit script sesuai kebutuhan atau hubungi developer.

### **Q: Apakah ada limit untuk chat messages?**
A: Ya, maksimal 200 karakter per pesan untuk mencegah spam.

### **Q: Bagaimana cara backup sistem ini?**
A: Save semua script ke file terpisah atau publish game sebagai template.

## 📞 Support

Jika mengalami masalah:

1. **Baca** troubleshooting guide di atas
2. **Cek** console untuk error messages
3. **Test** di studio terlebih dahulu
4. **Hubungi** developer jika perlu bantuan

## 🎉 Selamat!

Sistem handphone Roblox Anda sudah siap digunakan! Player bisa:
- 📞 Melakukan panggilan individual dan grup
- 💬 Mengirim pesan text
- 👥 Mengelola kontak
- 🎤 Menggunakan voice chat
- 📱 Menikmati UI yang modern dan responsif

**Tips:** Test semua fitur dengan player lain untuk memastikan semuanya berfungsi dengan baik!