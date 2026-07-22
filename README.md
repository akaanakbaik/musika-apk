# MUSIKA APK

<p align="center">
  <img src="https://raw.githubusercontent.com/akaanakbaik/my-cdn/main/musika/logonobglatar121212.png" width="120" height="120" alt="MUSIKA Logo">
</p>

<p align="center">
  <strong>🎵 Pemutar Musik Android Native — Multi-Sumber, Cerdas, dan Elegan</strong>
</p>

<p align="center">
  <a href="https://github.com/akaanakbaik/musika-apk/releases/latest">
    <img src="https://img.shields.io/badge/Download-APK-brightgreen?logo=github" alt="Download">
  </a>
  <a href="https://api-server-flax-xi.vercel.app/api/health">
    <img src="https://img.shields.io/badge/API-Online-success?logo=vercel" alt="API Status">
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.29-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android-brightgreen?logo=android" alt="Android">
  <img src="https://img.shields.io/badge/API-4%20Sources-orange" alt="Sources">
</p>

---

## ✨ Fitur Unggulan

### 🔍 Pencarian Multi-Sumber
Cari lagu dari **YouTube, Spotify, Apple Music, dan SoundCloud** sekaligus dalam satu pencarian. Hasil digabung dan diduplikasi otomatis.

### ▶️ Pemutaran Musik
Putar musik langsung dari aplikasi dengan kontrol pemutaran lengkap (play, pause, next, previous, shuffle, repeat).

### ⬇️ Download & Offline
Download lagu favoritmu untuk didengarkan offline kapan saja. Manajemen antrean download dengan status real-time.

### ❤️ Favorit & Playlist
Simpan lagu favorit, buat playlist kustom, dan kelola koleksi musikmu.

### 🤖 AI Chat Assistant
Tanya rekomendasi musik, lirik lagu, atau informasi artis langsung dari aplikasi. Auto-fallback antara 2 provider AI.

### 📜 Riwayat & Saran
Riwayat pemutaran otomatis, rekomendasi personal, dan saran pencarian cerdas.

### 🌙 Tampilan Premium
- Dark theme elegan
- Bahasa Indonesia sebagai default
- Loading shimmer halus
- Animasi transisi mulus
- Bottom player bar
- Source badge untuk setiap lagu

## 📥 Download APK

### Untuk Oppo A58 / Device Modern (arm64-v8a)
| Tautan | Ukuran |
|--------|--------|
| [⬇️ Download MUSIKA v1.1.1](https://github.com/akaanakbaik/musika-apk/releases/download/v1.1.1/app-arm64-v8a-release.apk) | ~14 MB |
| [Lihat Semua Rilis](https://github.com/akaanakbaik/musika-apk/releases) | - |

### Untuk Device Lawas (armeabi-v7a)
| Tautan | Ukuran |
|--------|--------|
| [⬇️ Download v1.1.1 (32-bit)](https://github.com/akaanakbaik/musika-apk/releases/download/v1.1.1/app-armeabi-v7a-release.apk) | ~11 MB |

### Panduan Install
1. Download file `.apk` yang sesuai dengan device kamu
2. Buka file di Android → tap **"Install"**
3. Jika muncul peringatan Play Protect, tap **"Install anyway"** (ini normal untuk APK sideload)
4. Buka MUSIKA dan mulai menikmati musik! 🎉

## 🆚 Perbandingan Versi APK

| File | Arsitektur | Cocok Untuk | Ukuran |
|------|------------|-------------|--------|
| `app-arm64-v8a-release.apk` ✅ | 64-bit | Samsung, Oppo, Xiaomi, Vivo modern (2017+) | 13.7 MB |
| `app-armeabi-v7a-release.apk` | 32-bit | HP lawas (2015-2017) | 11.2 MB |
| `app-x86_64-release.apk` | Intel/AMD | Emulator Android, tablet Intel | 14.1 MB |

> 🔍 **Cek arsitektur HP kamu:** Buka Settings → About Phone → lihat bagian "CPU" atau "Architecture"

## 🏗️ Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| **Framework** | Flutter 3.29+ |
| **State Management** | Provider |
| **HTTP Client** | http package + retry logic |
| **Storage** | flutter_secure_storage |
| **Images** | cached_network_image |
| **Animasi** | Shimmer |

## 🔗 Backend API

**URL:** [api-server-flax-xi.vercel.app](https://api-server-flax-xi.vercel.app)

| Endpoint | Method | Deskripsi |
|----------|--------|-----------|
| `/api/health` | GET | Cek status server |
| `/api/music/search?q=` | GET | Cari musik (all/youtube/spotify/dll) |
| `/api/music/prepare?url=&source=` | GET | Siapkan streaming |
| `/api/music/download?url=&source=` | GET | Download musik |
| `/api/music/recommendations` | GET | Rekomendasi lagu |
| `/api/auth/register` | POST | Daftar akun |
| `/api/auth/login` | POST | Masuk akun |
| `/api/auth/me` | GET | Profil saya |
| `/api/favorites` | GET/POST/DELETE | Kelola favorit |
| `/api/playlists` | GET/POST/DELETE | Kelola playlist |
| `/api/history` | GET/POST/DELETE | Riwayat putar |
| `/api/downloads` | GET/POST/DELETE | Manajemen download |
| `/api/ai/chat` | POST | AI chat assistant |

## 📊 Rilis APK

| Versi | Tanggal | Fitur Baru |
|-------|---------|------------|
| **v1.1.1** (Latest 🆕) | 23 Jul 2026 | • 7 fitur baru: Sleep Timer, Queue Screen, Artist Screen, Lyrics, Quick Settings, Stats, Share • Download offline ke storage • AI typing animation + Markdown • Search optimization + debounce + CI auto-release pipeline |
| **v1.0.2** | 21 Jul 2026 | • UI Bahasa Indonesia • Loading shimmer animasi • Fallback rekomendasi • Izin lengkap • Nama MUSIKA • CI Matrix build |
| **v1.0.1** | 19 Jul 2026 | • Fix widget tests • Flutter analyze bersih |
| **v1.0.0** | 19 Jul 2026 | • Rilis perdana • Search multi-source • Play music • Auth OTP |

## 🛠️ Build Lokal

```bash
# Clone repo
git clone https://github.com/akaanakbaik/musika-apk.git
cd musika-apk

# Install dependencies
flutter pub get

# Build APK (semua arsitektur)
flutter build apk --release --split-per-abi

# Atau spesifik arsitektur
flutter build apk --release --target-platform android-arm64
```

## 🔐 Izin Aplikasi

| Izin | Alasan |
|------|--------|
| Internet | Streaming & download musik |
| Foreground Service | Putar musik di background |
| Notifikasi | Kontrol pemutaran dari notifikasi |
| Penyimpanan | Simpan musik offline |
| Wi-Fi State | Deteksi koneksi untuk auto-quality |

## 📝 Catatan Rilis

### v1.1.1 (23 Juli 2026)
- **⏰ Sleep Timer**: Auto-stop pemutaran (15/30/45/60 menit), integrasi quick settings
- **📋 Queue Screen**: Manajemen antrian dengan reorder, shuffle, repeat, clear
- **🎤 Artist Screen**: Lihat semua lagu dari artis tertentu
- **📝 Lyrics Screen**: Cari dan lihat lirik lagu
- **⚡ Quick Settings Panel**: 8 aksi cepat (tema, timer, antrian, acak, ulang, volume, lirik, profil)
- **📊 Listening Stats**: Statistik mendengarkan di profil
- **🔗 Share Song**: Bagikan lagu via clipboard (info + link + aplikasi)
- **💾 Download Offline**: Simpan lagu ke storage, dukungan offline penuh
- **💬 AI Typing Animation**: Efek mengetik smooth + format markdown pada respon AI
- **🔍 Search Optimization**: Debounce, cache scoring, paralel fallback
- **🤖 CI Auto-Release Pipeline**: Build & rilis otomatis via GitHub Actions

---

<p align="center">
  <strong>MUSIKA</strong> — Made with ❤️<br>
  📧 musika@akadev.me<br>
  🎵 Stream, Discover, and Enjoy Music from Multiple Sources
</p>
