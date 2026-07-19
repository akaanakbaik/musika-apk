# Musika APK

Native Android music player application built with Flutter.

## Download

[⬇️ Download Musika APK v1.0.0](https://github.com/akaanakbaik/musika-apk/releases/download/v1.0.0/app-debug.apk)

Or browse all releases: [github.com/akaanakbaik/musika-apk/releases](https://github.com/akaanakbaik/musika-apk/releases)

## Features

- Multi-source music search (YouTube, Spotify, Apple Music, SoundCloud)
- Create and manage playlists
- Favorites and listening history
- AI Chat assistant for music recommendations
- Dark/Light theme
- Download management
- Crossfade playback

## Screens

- **Home** - Greeting, quick actions, recommended songs
- **Search** - Multi-source search with filter chips
- **Favorites** - Your liked songs
- **Playlists** - Create and manage playlists
- **History** - Recently played songs
- **Profile** - User settings, theme toggle
- **AI Chat** - Music assistant with smart recommendations
- **Player** - Full-screen music player with controls

## Tech Stack

- **Framework**: Flutter 3.29
- **Backend**: Node.js/Express on NeonDB (PostgreSQL)
- **APIs**: YouTube, Spotify, Apple Music, SoundCloud
- **Auth**: JWT-based authentication
- **AI**: Prexzyapis Copilot + Cuki Gemini (auto-fallback)

## Build

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`
