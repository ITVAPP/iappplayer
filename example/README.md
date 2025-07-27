# IAppPlayer Example

<p align="center">
  <img src="https://www.itvapp.net/images/logo-1.png" alt="IAppPlayer Logo" width="120"/>
</p>

## Table of Contents

- [English](#english)
  - [Features](#features)
  - [Project Structure](#project-structure)
  - [UI Components](#ui-components)
- [中文](#中文)
  - [功能特性](#功能特性)
  - [项目结构](#项目结构)
  - [UI 组件](#ui-组件)

---

## English

### Features

#### 🎬 Video Player
Single video playback with advanced controls
- Hardware/Software decoder switching
- Fullscreen mode
- Picture-in-Picture (PiP)
- Subtitle support

#### 📋 Video Playlist  
Continuous playback of multiple videos
- Next/Previous navigation
- Shuffle & Sequential modes
- Playlist management

#### 🎵 Music Player
Beautiful audio player with lyrics
- LRC lyrics synchronization
- Visual effects and animations
- Gradient design

#### 🎶 Music Playlist
Alternative music playback interface
- Continuous playback
- Advanced controls
- Modern UI design

#### 🌍 Internationalization
Supports 8 languages: English, Simplified Chinese, Traditional Chinese, Japanese, French, Spanish, Portuguese, Russian

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── single_video_page.dart    # Video player example
├── playlist_page.dart        # Video playlist example
├── music_player_page.dart    # Music player example
├── music_playlist_page.dart  # Music playlist example
├── app_localizations.dart    # Localization support
└── common_utils.dart         # Common utilities
```

### UI Components

- **UIConstants** - Design system constants (spacing, radius, sizes)
- **PlayerOrientationMixin** - Auto rotation handler for fullscreen
- **LyricDisplay** - Animated lyrics widget with real-time sync
- **ModernControlButton** - Gradient control buttons with ripple effects

---

## 中文

### 功能特性

#### 🎬 视频播放器
单视频播放及高级控制功能
- 硬件/软件解码切换
- 全屏模式
- 画中画模式
- 字幕支持

#### 📋 视频播放列表
多视频连续播放
- 上一个/下一个切换
- 随机和顺序播放模式
- 播放列表管理

#### 🎵 音乐播放器
带歌词显示的精美音频播放器
- LRC 歌词同步
- 视觉效果和动画
- 渐变设计

#### 🎶 音乐播放列表
另一种音乐播放界面
- 连续播放
- 高级控制
- 现代化 UI 设计

#### 🌍 国际化
支持 8 种语言：英语、简体中文、繁体中文、日语、法语、西班牙语、葡萄牙语、俄语

### 项目结构

```
lib/
├── main.dart                 # 应用入口
├── single_video_page.dart    # 视频播放器示例
├── playlist_page.dart        # 视频列表示例
├── music_player_page.dart    # 音乐播放器示例
├── music_playlist_page.dart  # 音乐列表示例
├── app_localizations.dart    # 本地化支持
└── common_utils.dart         # 通用工具类
```

### UI 组件

- **UIConstants** - 设计系统常量（间距、圆角、尺寸）
- **PlayerOrientationMixin** - 自动旋转处理全屏切换
- **LyricDisplay** - 实时同步的动画歌词组件
- **ModernControlButton** - 带涟漪效果的渐变控制按钮

---

<p align="center">
  <strong>Built with IAppPlayer Flutter Plugin</strong>
</p>
