# Musika APK

Native Android music player application built with Flutter.

## Download

[⬇️ Download Musika APK v1.0.1 (arm64-v8a) — 13.7MB](https://github.com/akaanakbaik/musika-apk/releases/download/v1.0.1/musika-arm64-v8a-release.apk)

### Variants

| Architecture | File | Size |
|-------------|------|------|
| **arm64-v8a** (recommended) | `musika-arm64-v8a-release.apk` | **13.7MB** 🔥 |
| armeabi-v7a | `app-armeabi-v7a-release.apk` | 13.2MB |
| x86_64 (emulator) | `app-x86_64-release.apk` | 13.8MB |

All variants: [github.com/akaanakbaik/musika-apk/releases](https://github.com/akaanakbaik/musika-apk/releases)

> **Note:** APK dihosting via GitHub Releases karena CDN yang tersedia memiliki batas upload 5MB.

## Optimasi APK

APK berhasil dioptimasi dari **120MB → 13.7MB** (91% smaller!) melalui:
- **Release mode AOT** — Menghilangkan `kernel_blob.bin` (64MB)
- **Split-per-abi** — Hanya satu `libflutter.so` per APK
- **Hapus 10 package tak terpakai** — Mengurangi ukuran Dart compiled code
- **Tree-shaking icons** — Material/Cupertino icons yang tidak dipakai otomatis dihapus

## Features

- Multi-source music search (YouTube, Spotify, Apple Music, SoundCloud)
- Create and manage playlists
- Favorites and listening history
- AI Chat assistant for music recommendations
- Dark/Light theme
- Download management
- Crossfade playback
- Search, sort, and filter on all list screens
- Batch select/delete downloads
- Time filter for history (Today/Week/Month/All)
- Editable profile, quality & language settings

## Screens

- **Home** — Greeting, quick actions, recommended songs
- **Search** — Multi-source search with filter chips
- **Favorites** — Your liked songs with search & sort
- **Playlists** — Create and manage playlists
- **History** — Recently played songs with time filter
- **Profile** — User settings, theme toggle, quality & language
- **AI Chat** — Music assistant with copy & clear chat
- **Player** — Full-screen music player with controls
- **Downloads** — Download management with search, sort, batch select

## Tech Stack

- **Framework**: Flutter 3.29
- **Backend**: Node.js/Express on NeonDB (PostgreSQL)
- **APIs**: YouTube, Spotify, Apple Music, SoundCloud
- **Auth**: JWT-based authentication
- **AI**: Prexzyapis Copilot + Cuki Gemini (auto-fallback + zenzxz)
- **CDN**: izukaprivate with safeCDNUpload (retry + backoff)

## Build

```bash
# Debug build (120MB, all ABIs)
flutter build apk --debug

# Optimized release build (14MB per ABI)
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```
