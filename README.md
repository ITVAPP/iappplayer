# IAppPlayer

[![Back to Home](https://img.shields.io/badge/🏠-TV%20Treasure%20App%20Store-blue?style=for-the-badge)](https://www.itvapp.net)
[![中文](https://img.shields.io/badge/📄-中文-green?style=for-the-badge)](docs/README_CN.md)
[![GitHub Issues](https://img.shields.io/github/issues/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/issues)
[![GitHub Forks](https://img.shields.io/github/forks/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/network)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)


> 🎥 **IAppPlayer** is a high-performance video and audio player developed with Flutter, supporting prioritized software or hardware decoding and multiple streaming formats!

## 📖 Documentation Navigation

| 📋 Document Type | 🔗 Link | 📝 Description |
|:---:|:---:|:---|
| 🚀 **Quick Start** | [👇 Content Below](#-quick-start) | Basic usage and simple examples |
| 📖 **Detailed Documentation** | [📚 Parameter Reference](docs/API_REFERENCE.md) | Complete API parameter documentation |
| 🎯 **Common Examples** | [📚 Common Examples](docs/API_CODE.md) | Common examples documentation |

## ✨ Features

- Fixed common bugs
- Extensively optimized and adapted for low-end devices (such as TV boxes and car systems)
- Advanced configuration options (support for prioritizing software or hardware decoding, audio support for displaying playback controls only)
- Support for Cronet data source and automatic degradation to Http data source (Android only)
- Support for FFmpeg software decoder, enhanced media format support
- Support for RTMP protocol (including segmented subtitles, audio track switching)
- Support for RTSP protocol (including track selection, segmented subtitles, audio track switching)
- Support for HLS protocol (including track selection, segmented subtitles, audio track switching)
- Support for DASH protocol (including track selection, subtitles, audio track switching)
- Support for SmoothStreaming protocol (including track selection, subtitles, audio track switching)
- Support for playlist functionality
- Support for subtitles and lyrics (supporting LRC, SRT, WEBVTT formats and HTML tags, HLS subtitles, multiple subtitle switching)
- Support for ListView video playback
- Support for HTTP header settings
- Support for video fitting (BoxFit)
- Support for playback speed adjustment
- Support for multiple resolution switching
- Support for caching functionality
- Support for notification functionality
- Support for Picture-in-Picture mode
- Support for DRM protection (including tokens, Widevine, FairPlay EZDRM)
- ...More features to explore!

## 🚀 Quick Start

### 📋 Requirements

#### Flutter Environment
- **Flutter**: 3.3.0 or higher
- **Dart**: 2.17.0 or higher

#### Platform Requirements
- **Android**: API 21+ (Android 5.0+)、compileSdkVersion 35+
- **iOS**: 11.0 or higher

### 📦 Installation Steps

#### 1. **Add Dependency**

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  iapp_player: ^1.0.0  # or use local path
  # If using local version
  # iapp_player:
  #   path: ./path/iapp_player

dev_dependencies:
  flutter_test:
    sdk: flutter
```

#### 2. **Platform-Specific Configuration**

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

If you experience issues with audio or video playback, you can specify the preferred decoder type. (If not specified, hardware decoding is used by default.), To prioritize hardware decoding: preferredDecoderType: IAppPlayerDecoderType.hardwareFirst, To prioritize software decoding: preferredDecoderType: IAppPlayerDecoderType.softwareFirst

```dart
final player = IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {
    print('Player event: ${event.iappPlayerEventType}');
  },
  // Optional parameter: Specify the preferred decoder type
  // IAppPlayerDecoderType.hardwareFirst - Hardware decoding priority (default)
  // IAppPlayerDecoderType.softwareFirst - Software decoding priority
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
);

_playerController = player.activeController;
```

### 🎵 Playlist

You can use shuffleMode to set the playback mode for the playlist: true = shuffle playback ,  false = sequential playback , Set loopVideos to determine whether the entire playlist should loop.

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
  // Optional parameters: Set playback mode
  shuffleMode: false,  // true=shuffle playback, false=sequential playback (default)
  loopVideos: true,    // true=loop entire playlist (default), false=stop after playing all
);

_playerController = player.activeController;
```

### 🎤 Music Player (with Lyrics)

LRC lyrics are supported. When playing audio, it is recommended to set audioOnly: true, which will display audio controls instead of video controls.

```dart
final musicPlayer = IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/song1.mp3',
    'https://example.com/song2.mp3',
  ],
  titles: ['Song 1', 'Song 2'],
  subtitleContents: [  // LRC lyrics format
    '''[00:02.05]Wish to have someone's heart
[00:08.64]Lyrics: Hu Xiaojian Music: Luo Junlin
[00:27.48]The person who was in the small compartment of my backpack''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody
[00:10.00]Love is in the air''',
  ],
  eventListener: (event) {
    print('Music player event: ${event.iappPlayerEventType}');
  },
  // Optional parameter: Enable audio mode
  audioOnly: true,  // true=display audio controls, false=display video controls (default)
);

_playerController = musicPlayer.activeController;
```

### 🧹 Resource Release

**Important**: To avoid memory leaks, you must properly release player resources when the page is destroyed. Here is the recommended release method:

```dart
Future<void> _releasePlayer() async {
    try {
      // 1. Clear player caches
      IAppPlayerConfig.clearAllCaches();
      if (_playerController != null) {
        try {
          // 2. Remove event listeners
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

## 🔧 Advanced Features

> 💡 **For more advanced features and detailed configuration, please see:**
> 
> 📚 **[Complete API Parameter Documentation](docs/API_REFERENCE.md)** - Contains detailed explanations of all parameters

### 🎯 Main Advanced Features

- **Multi-language Subtitles** - Support for multiple subtitle formats and language switching
- **DRM Protection** - Support for Widevine, FairPlay and other DRM solutions
- **Cache Control** - Intelligent caching strategies and cache management
- **Network Configuration** - HTTP header settings and network optimization
- **Playback Control** - Precise playback control and event listening
- **UI Customization** - Fully customizable player interface
- **Picture-in-Picture Mode** - Support for Android and iOS PiP
- **Notification Integration** - Media notifications and lock screen controls

## 📚 More Documentation Resources

> 💡 **If this documentation is not comprehensive enough, please check the detailed comments in the source code** - We provide rich comments in the code, covering the usage, parameter descriptions, and examples of each API.

## 🚨 Important Notice

This library is not responsible for issues caused by the video_player library, it only serves as a UI wrapper on top of it.

That is: PlatformExceptions (platform exceptions) caused by video playback in the application are all caused by the video_player library.

Please submit related issues to the Flutter team.

## 🔀 Flutter Version Compatibility

This library strives to support at least the second-to-last version of Flutter (N-1 support).

However, due to major changes in Flutter versions, compatibility cannot be fully guaranteed, and major or minor version updates will be released when necessary.

## 🤝 Open Source Contribution

> 💡 **This plugin is under active development, and community participation is welcome!**
> 
> 🔄 **Version Update Notice** - Due to the rapid iteration of the project, you may encounter incompatible changes in each version, and we will try to provide detailed explanations in the changelog.
> 
> 💪 **How to Contribute** - This plugin is developed and maintained for free by [TV Treasure App Store (www.itvapp.net)]. We warmly welcome your participation through the following ways:
> - 🐛 **Submit Bug Reports** - Please provide timely feedback through GitHub Issues when you find issues
> - ✨ **Feature Suggestions** - Propose your needs and improvement ideas  
> - 🔧 **Code Contributions** - Directly submit Pull Requests to fix issues or add new features
> - 📝 **Documentation Improvements** - Help improve and refine project documentation
> 
> 🌟 **All valuable contributions will be carefully reviewed. Let's build a better player together!**

## 📄 License

This project follows the **Apache License, Version 2.0** open source license.

### License Requirements

According to Apache 2.0 License:

- ✅ **Free to use, modify and distribute**
- ✅ **Can be used for commercial purposes**
- ✅ **Can privately modify**
- ⚠️ **Must retain copyright notice and license**

### Copyright Information

**Original Project Copyright:**
```
Copyright 2020 Jakub Homlala and Better Player / Chewie / Video Player contributors
```

**This Project Copyright:**
```
Copyright [WWW.ITVAPP.NET] 2025 for modifications
```

For the full license text, please see the [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- Special thanks to the [Better Player / Chewie / Video Player] project for providing excellent open source code foundation.
- Thanks to all developers who have contributed code, feedback, and suggestions to the IAppPlayer project.
- Thanks to the Flutter community and open source community for their support.

## 📞 Contact

- 🌍 **Official Website**: [TV Treasure App Store](https://www.itvapp.net)
- 🐛 **Issue Feedback**: [GitHub Issues](https://github.com/ITVAPP/IAppPlayer/issues)
- 📧 **Email Contact**: service # itvapp.net (replace # with @)

---

<div align="center">

**If this project helps you, please give it a ⭐ Star to support!**

[⬆ Back to Top](#IAppPlayer)

</div>
