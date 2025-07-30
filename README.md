# IAppPlayer

<p align="center">
  <img src="https://www.itvapp.net/images/logo-1.png" alt="IAppPlayer Logo" width="120"/>
</p>

[![Back to Home](https://img.shields.io/badge/🏠-TV%20Treasure%20App%20Store-blue?style=for-the-badge)](https://www.itvapp.net)
[![中文](https://img.shields.io/badge/📄-中文-green?style=for-the-badge)](docs/README_CN.md)
[![GitHub Issues](https://img.shields.io/github/issues/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/issues)
[![GitHub Forks](https://img.shields.io/github/forks/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/network)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

> 🎥 **IAppPlayer** - A powerful player solution for the Flutter ecosystem! High-performance player designed for professional applications like OTT/IPTV, music players, and video platforms.

## 💡 Why Choose IAppPlayer?

🚀 **Streaming Support** - Complete support for mainstream protocols like HLS, DASH, RTMP, RTSP  
⚡ **Performance Optimization** - Deep optimization for low-spec devices like TVs and car systems  
🛡️ **Enterprise DRM** - Built-in copyright protection solutions like Widevine and FairPlay  
🎵 **Music Player Expert** - Native LRC lyrics support, 3 audio UI modes  
📱 **Multi-platform Coverage** - Native adaptation for iOS/Android, safe and reliable

## 📖 Documentation Navigation

| 📋 Document Type | 🔗 Link | 📝 Description |
|:---:|:---:|:---|
| 🚀 **Quick Start** | [👇 Content Below](#-quick-start) | Basic usage and simple examples |
| 📖 **Detailed Documentation** | [📚 API Reference](docs/API_REFERENCE.md) | Complete API parameter documentation |
| 🎯 **Common Examples** | [📚 Code Examples](docs/API_CODE.md) | Common usage examples documentation |
| 🖼️ **Screenshots** | [📸 Screenshot Gallery](docs/APP_SCREENSHOTS.md) | Player UI screenshots |

## ✨ Core Features

### 🎯 Basic Features
- ✅ **Complete Playback Control** - Full control suite including play/pause/seek/volume/speed
- ✅ **Smart Playlist** - Continuous play/shuffle/loop modes, memory optimized
- ✅ **Multi-format Subtitles** - SRT/LRC/WebVTT/HLS segmented subtitles, HTML tag support
- ✅ **Dedicated Audio UI** - 3 display modes (square/compact/extended)
- ✅ **Perfect Lyrics Display** - LRC lyrics engine optimized for music playback
- ✅ **System-level Control** - Notification control, lock screen control, picture-in-picture
- ✅ **Smart Caching** - Preload, cache management, offline playback

### 🔥 Professional Features

#### 📡 Complete Streaming Protocol Suite
```
• HLS - Complete m3u8 support, including track selection, segmented subtitles, audio track switching
• DASH - MPD parsing, adaptive bitrate, subtitle/audio track switching  
• RTMP/RTSP - Low-latency live streaming, real-time media streaming
• SmoothStreaming - Microsoft streaming protocol support
• HTTP/HTTPS - Standard streaming, supports resume
• FLV - Low-latency live streaming
```

#### 🛠️ Advanced Technical Features
```
• Hardware/Software Decoder Smart Switching - Auto-select optimal decoding solution
• FFmpeg Software Decoder - Supports almost all media formats
• Cronet Network Stack - Google high-performance network (Android)
• Auto-fallback Mechanism - Smart source switching on network failures
• DRM Protection - Widevine L1/L3, FairPlay, ClearKey
• Low-spec Device Optimization - Smooth running on TV/car systems
• Complete Event System - 23 event types for precise control
```

## 🚀 Quick Start

### 📋 Environment Requirements

#### Flutter Environment
- **Flutter**: 3.3.0 or higher
- **Dart**: 2.17.0 or higher

#### Platform Requirements
- **Android**: API 21+ (Android 5.0+), compileSdkVersion 35+
- **iOS**: 11.0 or higher

### 📦 Installation Steps

#### 1. **Add Dependency**

Add dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  iapp_player: ^1.0.0  # Or use local path
  # If using local version
  # iapp_player:
  #   path: ./path/iapp_player

dev_dependencies:
  flutter_test:
    sdk: flutter
```

#### 2. **Platform-specific Configuration**

##### Android Configuration

Ensure minimum SDK version in `android/app/build.gradle`:

```gradle
android {
    namespace 'com.example.yourapp'
    compileSdkVersion 35
    
    defaultConfig {
        minSdkVersion 21  // Important: Minimum API 21
        targetSdkVersion 34
    }
}
```

Add network permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

##### iOS Configuration

Add network security configuration in `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

Ensure iOS version in `ios/Podfile`:

```ruby
platform :ios, '11.0'
```

## 💻 Basic Usage

### 📌 Import Package

Import IAppPlayer in your Dart file:

```dart
import 'package:iapp_player/iapp_player.dart';
```

### 🎬 Play Single Video

Smart decoder selection, automatically adapts to different devices and video formats:

```dart
final player = IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {
    print('Player event: ${event.iappPlayerEventType}');
  },
  // Optional: specify preferred decoder type
  // IAppPlayerDecoderType.hardwareFirst - Hardware decoding priority (default)
  // IAppPlayerDecoderType.softwareFirst - Software decoding priority
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
);

_playerController = player.activeController;
```

### 🎵 Playlist

Supports smart continuous play, shuffle, and loop modes:

```dart
final player = IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/video1.mp4',
    'https://example.com/video2.mp4',
    'https://example.com/video3.mp4',
  ],
  eventListener: (event) {
    print('Player event: ${event.iappPlayerEventType}');
  },
  // Optional: set playback mode
  shuffleMode: false,  // true=shuffle, false=sequential (default)
  loopVideos: true,    // true=loop playlist (default), false=stop after completion
);

_playerController = player.activeController;
```

### 🎤 Music Player (with Lyrics)

Professional audio playback experience with LRC lyrics sync display support:

```dart
final musicPlayer = IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/song1.mp3',
    'https://example.com/song2.mp3',
  ],
  titles: ['Song 1', 'Song 2'],
  subtitleContents: [  // LRC lyrics format
    '''[00:02.05]May I have your heart
[00:08.64]Lyrics: Hu Xiaojian Music: Luo Junlin
[00:27.48]The person in my backpack's small compartment''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody
[00:10.00]Love is in the air''',
  ],
  eventListener: (event) {
    print('Music player event: ${event.iappPlayerEventType}');
  },
  // Optional: enable audio mode
  audioOnly: true,  // true=show audio controls, false=show video controls (default)
);

_playerController = musicPlayer.activeController;
```

### 🧹 Resource Release

**Important**: To avoid memory leaks, you must properly release player resources when the page is destroyed:

```dart
Future<void> _releasePlayer() async {
    try {
      // 1. Clear player cache
      IAppPlayerConfig.clearAllCaches();
      if (_playerController != null) {
        try {
          // 2. Remove event listener
          _playerController!.removeEventsListener(_videoListener);
          // 3. If playing, pause and mute first
          if (_playerController!.isPlaying() ?? false) {
            await _playerController!.pause();
            await _playerController!.setVolume(0);
          }
          // 4. Release player resources
          await Future.microtask(() {
            _playerController!.dispose(forceDispose: true);
          });
          _playerController = null;
        } catch (e) {
          print('Player cleanup failed: $e');
          _playerController = null;
        }
      }
    } catch (e) {
      print('Player cleanup failed: $e');
      _playerController = null;
    }
}

@override
void dispose() {
  _releasePlayer();
  super.dispose();
}
```

## 🔧 Advanced Features Overview

> 💡 **For more advanced features and detailed configuration, please see:**
> 
> 📚 **[Complete API Documentation](docs/API_REFERENCE.md)** - Contains all parameter details

### 🎯 Main Advanced Features

- **Multi-language Subtitles** - Support for multiple subtitle formats and language switching
- **DRM Protection** - Enterprise-level copyright protection solutions
- **Smart Caching** - Preload and offline playback
- **Network Optimization** - HTTP header settings and adaptive bitrate
- **Precise Control** - Complete playback control and event listening
- **UI Customization** - Fully customizable player interface
- **Picture-in-Picture** - System-level PiP support
- **Notification Integration** - Media notifications and lock screen controls

## 📚 More Documentation Resources

> 💡 **If this documentation is not comprehensive enough, please check the detailed comments in the source code** - We provide rich comments in the code, covering usage, parameter descriptions, and examples for each API.

## 🚨 Important Notice

This library is not responsible for issues caused by the video_player library, as it only serves as a UI wrapper on top of it.

That is: PlatformExceptions caused by video playback in the application are all caused by the video_player library.

Please submit related issues to the Flutter team.

## 🔀 Flutter Version Compatibility

This library strives to support at least the second-to-last Flutter version (N-1 support).

However, due to major changes in Flutter versions, complete compatibility cannot be fully guaranteed. Major or minor version updates will be released when necessary.

## 🤝 Open Source Contribution

> 💡 **This plugin is under active development, and community participation is welcome!**
> 
> 🔄 **Version Update Notes** - As the project is in rapid iteration, you may encounter incompatible changes in each version. We will try to detail them in the changelog.
> 
> 💪 **How to Contribute** - This plugin is freely developed and maintained by [TV Treasure App Store (www.itvapp.net)]. We warmly welcome your participation through:
> - 🐛 **Submit Bug Reports** - Report issues promptly through GitHub Issues
> - ✨ **Feature Suggestions** - Propose your needs and improvement ideas  
> - 🔧 **Code Contributions** - Submit Pull Requests directly to fix issues or add new features
> - 📝 **Documentation Improvements** - Help improve and enhance project documentation
> 
> 🌟 **All valuable contributions will be carefully reviewed. Let's build a better player together!**

## ☕ Support the Developer

### 💝 Buy Me a Coffee

> 🎯 **IAppPlayer is a completely free and open-source project**  
> 
> We've invested significant time and effort in developing, maintaining, and improving this player, hoping it can help more developers. If IAppPlayer has saved you development time or contributed to your project's success, feel free to buy us a coffee! ☕

<div align="center">

### 🌟 Your support drives us forward!

<table>
  <tr>
    <td align="center" width="50%">
      <img src="./media/donate-wechat.png" alt="WeChat Donation" width="260"/>
      <br/>
      <b>WeChat Pay</b>
      <br/>
      <sub>Scan with WeChat</sub>
    </td>
    <td align="center" width="50%">
      <img src="./media/donate-alipay.png" alt="Alipay Donation" width="260"/>
      <br/>
      <b>Alipay</b>
      <br/>
      <sub>Scan with Alipay</sub>
    </td>
  </tr>
</table>

</div>

### 💌 About Donations

- 💰 **Any amount** - The price of a coffee can make a developer happy all day!
- 🙏 **Non-mandatory** - IAppPlayer is forever free, donations are completely voluntary
- 📢 **Acknowledgments** - If you wish, we'll thank you for your support in the project
- 🚀 **Continuous updates** - Your support helps us:
  - 🔧 Continuously fix bugs and optimize performance
  - ✨ Develop more practical features
  - 📚 Improve documentation and examples
  - 💡 Explore more innovative features

> 💭 **Developer's Note**: Every bit of support is recognition for open source. Thank you for making the open source world better!

## 📄 License

This project follows the **Apache License, Version 2.0** open source license.

### License Requirements

According to Apache 2.0 License:

- ✅ **Free to use, modify, and distribute**
- ✅ **Can be used for commercial purposes**
- ✅ **Can privatize modifications**
- ⚠️ **Must retain copyright notice and license**

### Copyright Information

```
Copyright [WWW.ITVAPP.NET] 2025 for modifications
```

For complete license text, see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- Special thanks to [Better Player / Chewie / Video Player] projects for providing excellent open source code foundation.
- Thanks to all developers who have contributed code, reported issues, and provided suggestions for the IAppPlayer project.

## 📞 Contact

- 🌍 **Official Website**: [TV App Store](https://www.itvapp.net)
- 🐛 **Issue Feedback**: [GitHub Issues](https://github.com/ITVAPP/IAppPlayer/issues)
- 📧 **Email**: service # itvapp.net (replace # with @)

---

<div align="center">

**If this project helps you, please give it a ⭐ Star!**

**IAppPlayer - Making video playback simple yet powerful!**

[⬆ Back to Top](#IAppPlayer)

</div>
