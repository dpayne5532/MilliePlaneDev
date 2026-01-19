<p align="center">
  <img src="https://danpayne.co/mp.png" alt="MilliePlane Logo" width="200"/>
</p>

<h1 align="center">MilliePlane</h1>

<p align="center">
  <strong>A retro arcade-style endless flyer for iPad</strong>
</p>

<p align="center">
  <a href="https://testflight.apple.com/join/6iP84rAD">
    <img src="https://img.shields.io/badge/TestFlight-Install%20Now-blue?style=for-the-badge&logo=apple" alt="TestFlight"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iPadOS%2012.0+-lightgrey?style=flat-square&logo=apple" alt="Platform"/>
  <img src="https://img.shields.io/badge/Swift-5.0-orange?style=flat-square&logo=swift" alt="Swift"/>
  <img src="https://img.shields.io/badge/Framework-SpriteKit-green?style=flat-square" alt="SpriteKit"/>
</p>

---

<p align="center">
  <em>"Dedicated to the best niece ever... Millie Payne"</em>
</p>

---

## About

**MilliePlane** is a Flappy Bird-inspired game where you pilot Millie's plane through obstacles while collecting Millie Bucks. Features a 1980s arcade-style interface with high score tracking, just like the classic arcade cabinets.

<p align="center">
  <img src="https://danpayne.co/static/media/mpgp.png" alt="MilliePlane Gameplay" width="600"/>
</p>

---

## Features

| Feature | Description |
|:---|:---|
| **Classic Gameplay** | Tap to fly, avoid obstacles, collect coins |
| **Retro Arcade Style** | 1980s-inspired title screen with twinkling stars |
| **High Score Leaderboard** | Top 10 scores with arcade-style name entry |
| **Millie Bucks** | Collect cash to rack up your score |
| **Danger Zone Soundtrack** | Every great pilot needs a great soundtrack |

---

## How to Play

```
1. TAP anywhere on the title screen to start
2. TAP to make the plane fly upward
3. AVOID the obstacles and ground
4. COLLECT Millie Bucks to increase your score
5. COMPETE for a spot on the high score leaderboard
```

---

## Installation

### Option 1: TestFlight (Recommended)

<a href="https://testflight.apple.com/join/6iP84rAD">
  <img src="https://img.shields.io/badge/Download_on-TestFlight-blue?style=for-the-badge&logo=apple" alt="TestFlight"/>
</a>

Install directly on your iPad using Apple's TestFlight Beta platform.

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/dpayne5532/MilliePlaneDev.git

# Open in Xcode
cd MilliePlaneDev
open MilliePlane.xcodeproj
```

Then select your iPad device/simulator and press **⌘R** to build and run.

---

## Project Structure

```
MilliePlane/
├── AppDelegate.swift        # App lifecycle
├── GameViewController.swift # Scene management
├── GameScene.swift          # Core gameplay logic
├── MenuScene.swift          # Title screen & high scores
├── GameOverScene.swift      # Game over & name entry
├── HighScoreManager.swift   # Score persistence
├── GameScene.sks            # SpriteKit scene file
├── PlayerExplosion.sks      # Explosion particle effect
└── Assets.xcassets/         # Images & app icons
```

---

## Requirements

- iPadOS 12.0+
- Xcode 14.0+ (for building from source)

---

## Built With

- **SpriteKit** - Apple's 2D game framework
- **Swift 5** - Programming language
- **UserDefaults** - High score persistence

---

<p align="center">
  <sub>Made with love for Millie</sub>
</p>

<p align="center">
  <strong>Fly high!</strong>
</p>
