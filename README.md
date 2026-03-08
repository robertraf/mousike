# Mousike

A macOS music player inspired by the legendary Winamp, built with SwiftUI.

## Features

- **Classic Winamp-style UI** — Compact player with LCD display, transport controls, and spectrum visualizer
- **Theme System** — 5 built-in themes with live preview:
  - **Classic** — The iconic green-on-black Winamp look
  - **Midnight** — Modern dark purple aesthetic
  - **Retrowave** — Synthwave-inspired neon pink and cyan
  - **Amber Terminal** — Retro amber monochrome
  - **Ocean** — Cool blue tones
- **Playlist Management** — Add, remove, reorder tracks with drag & drop
- **Drag & Drop** — Drop audio files directly onto the player
- **Audio Format Support** — MP3, WAV, AIFF, M4A, FLAC
- **Playback Controls** — Play, pause, stop, next, previous, seek
- **Shuffle & Repeat** — Shuffle mode, repeat all, repeat one
- **Volume Control** — Slider with visual feedback
- **Scrolling Title** — Classic scrolling track title display
- **Keyboard Shortcuts** — Space for play/pause, Cmd+arrows for next/prev

## Requirements

- macOS 14.0+
- Xcode 15.0+

## Building

1. Open `Mousike.xcodeproj` in Xcode
2. Select a signing team
3. Build and run (Cmd+R)

## Adding Custom Themes

Themes are defined in `Mousike/Models/Theme.swift`. To add a new theme, create a new static property on `Theme` and add it to `allThemes`:

```swift
static let myTheme = Theme(
    id: "mytheme",
    name: "My Theme",
    background: Color(hex: "1A1A2E"),
    // ... configure all color properties
)
```
