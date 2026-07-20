# Musika APK

Musika - Native Android Music Player built with Flutter.

[![Download](https://img.shields.io/badge/Download-APK-green)](https://github.com/akaanakbaik/musika/releases/latest)

## Features

- 🎵 Multi-source music search (YouTube, Spotify, Apple Music, SoundCloud)
- ⬇️ Music download & offline playback
- 🎨 Dark theme UI
- 🤖 AI Chat assistant
- ❤️ Favorites, playlists, history
- 🔄 Auto-fallback API (multiple providers)

## Tech Stack

- **Framework:** Flutter 3.29+
- **State Management:** Provider
- **Storage:** flutter_secure_storage + shared_preferences
- **HTTP:** http package

## Backend API

Backend server: [api-server-flax-xi.vercel.app](https://api-server-flax-xi.vercel.app)

API health check: [api-server-flax-xi.vercel.app/api/health](https://api-server-flax-xi.vercel.app/api/health)

## Build

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

## Download

Download latest APK from [GitHub Releases](https://github.com/akaanakbaik/musika/releases).

---

📧 Contact: musika@akadev.me
