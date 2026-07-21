# Musika APK

Musika - Native Android Music Player built with Flutter.

[![Download](https://img.shields.io/badge/Download-APK-brightgreen)](https://github.com/akaanakbaik/musika-apk/releases/latest)

## Features

- Multi-source music search (YouTube, Spotify, Apple Music, SoundCloud)
- Music download and offline playback
- Dark theme UI with Material You design
- AI Chat assistant with smart responses
- Favorites, playlists, and listening history
- Auto-fallback API (multiple providers for reliability)
- Cloud sync via NeonDB

## Tech Stack

- **Framework:** Flutter 3.29+
- **State Management:** Provider
- **Storage:** flutter_secure_storage
- **Backend:** Bun + Express (Vercel)
- **Database:** NeonDB (PostgreSQL)
- **Email:** Resend

## Backend API

- **URL:** [api-server-flax-xi.vercel.app](https://api-server-flax-xi.vercel.app)
- **Health:** [api-server-flax-xi.vercel.app/api/health](https://api-server-flax-xi.vercel.app/api/health)

## Download

| Source | Link | Notes |
|--------|------|-------|
| **Direct APK** (Recommended) | [⬇️ Download v1.0.0](https://github.com/akaanakbaik/musika-apk/releases/download/v1.0.0/app-arm64-v8a-release.apk) | 13.7 MB, arm64-v8a |
| **All Releases** | [View all releases](https://github.com/akaanakbaik/musika-apk/releases) | Changelog & older versions |

> ⚠️ CDN mirror tidak tersedia karena ukuran APK (14 MB) melebihi batas CDN gratis. Gunakan tautan GitHub Release di atas.

### Installation
1. Download the `.apk` file from the link above
2. Open the file on your Android device
3. Allow installation from unknown sources if prompted
4. Open Musika and enjoy!

## Build Locally

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

---

Contact: musika@akadev.me
