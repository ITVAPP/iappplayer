# IAppPlayer

[![返回首页](https://img.shields.io/badge/🏠-电视宝应用商店-blue?style=for-the-badge)](https://www.itvapp.net)
[![English](https://img.shields.io/badge/📄-English-green?style=for-the-badge)](../README.md)
[![GitHub Issues](https://img.shields.io/github/issues/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/issues)
[![GitHub Forks](https://img.shields.io/github/forks/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/network)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

> 🎥 **IAppPlayer** 是基于 Flutter 开发的高性能视频和音频播放器，支持优先软件或硬件解码和多种流媒体格式！

## 📖 文档导航

| 📋 文档类型 | 🔗 链接 | 📝 说明 |
|:---:|:---:|:---|
| 🚀 **快速开始** | [👇 下方内容](#-快速开始) | 基础使用和简单示例 |
| 📖 **详细文档** | [📚 参数说明](./API_REFERENCE_CN.md) | 完整API参数文档 |
| 🎯 **常用示例** | [📚 常用示例](./API_CODE_CN.md) | 常用示例说明文档 |

## ✨ 功能特性

- 修复常见错误
- 针对低配置设备（如果TV和车机系统）做了大量优化适配
- 高级配置选项（支持设置优先软件或硬件解码，音频支持仅显示播放控件）
- 支持使用 Cronet 数据源和自动降级 Http 数据源（仅在安卓系统）
- 支持 FFmpeg 软件解码器，增强媒体格式支持
- 支持 RTMP 协议（包括分段字幕、音轨切换）
- 支持 RTSP 协议（包括轨道选择、分段字幕、音轨切换）
- 支持 HLS 协议（包括轨道选择、分段字幕、音轨切换）
- 支持 DASH 协议（包括轨道选择、字幕、音轨切换）
- 支持 SmoothStreaming 协议（包括轨道选择、字幕、音轨切换）
- 支持播放列表功能
- 支持字幕和歌词功能（支持 LRC、SRT、WEBVTT 格式及 HTML 标签，HLS 字幕，多字幕切换）
- 支持 ListView 视频播放
- 支持HTTP头部设置
- 支持视频适配（BoxFit）
- 支持播放速度调节
- 支持多种分辨率切换
- 支持缓存功能
- 支持通知功能
- 支持画中画模式
- 支持DRM保护（包括令牌、Widevine、FairPlay EZDRM）
- ……更多功能待体验！

## 🚀 快速开始

### 📋 环境要求

#### Flutter 环境
- **Flutter**: 3.3.0 或更高版本
- **Dart**: 2.17.0 或更高版本

#### 平台要求
- **Android**: API 21+ (Android 5.0+)、compileSdkVersion 35+
- **iOS**: 11.0 或更高版本

### 📦 安装步骤

#### 1. **添加依赖**

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  iapp_player: ^1.0.0  # 或使用本地路径
  # 如果使用本地版本
  # iapp_player:
  #   path: ./path/iapp_player

dev_dependencies:
  flutter_test:
    sdk: flutter
```

#### 2. **平台特定配置**

##### Android 配置

在 `android/app/build.gradle` 中确保最低 SDK 版本：

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21  // 重要：最低 API 21
        targetSdkVersion 33
    }
}
```

在 `android/app/src/main/AndroidManifest.xml` 中添加网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

##### iOS 配置

在 `ios/Runner/Info.plist` 中添加网络安全配置：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

确保 `ios/Podfile` 中的 iOS 版本：

```ruby
platform :ios, '11.0'
```

## 💻 基础使用

### 📌 导入包

在你的 Dart 文件中导入 IAppPlayer：

```dart
import 'package:iapp_player/iapp_player.dart';
```

### 🎬 播放单个视频

如果你的音视频播放有问题，可以指定优先的解码器（如果没有指定，使用硬件解码优先），使用硬件解码优先 preferredDecoderType: IAppPlayerDecoderType.hardwareFirst，使用软件解码优先 preferredDecoderType: IAppPlayerDecoderType.softwareFirst

```dart
final player = IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {
    print('播放器事件: ${event.iappPlayerEventType}');
  },
  // 可选参数：指定优先的解码器类型
  // IAppPlayerDecoderType.hardwareFirst - 硬件解码优先（默认）
  // IAppPlayerDecoderType.softwareFirst - 软件解码优先
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
);

_playerController = player.activeController;
```

### 🎵 播放列表

你可以通过 shuffleMode 来为播放列表设定播放模式：true=随机播放，false=顺序播放，设定 loopVideos 来决定是否循环播放整个播放列表

```dart
final player = IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/video1.mp4',
    'https://example.com/video2.mp4',
    'https://example.com/video3.mp4',
  ],
  eventListener: (event) {
    print('播放器事件: ${event.iappPlayerEventType}');
  },
  // 可选参数：设置播放模式
  shuffleMode: false,  // true=随机播放，false=顺序播放（默认）
  loopVideos: true,    // true=循环播放整个列表（默认），false=播放完停止
);

_playerController = player.activeController;
```

### 🎤 音乐播放器（带歌词）

支持传入LRC歌词，播放音频时建议设置 audioOnly: true ，将显示音频控件而不是视频控件

```dart
final musicPlayer = IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/song1.mp3',
    'https://example.com/song2.mp3',
  ],
  titles: ['歌曲1', '歌曲2'],
  subtitleContents: [  // LRC歌词格式
    '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody
[00:10.00]Love is in the air''',
  ],
  eventListener: (event) {
    print('音乐播放器事件: ${event.iappPlayerEventType}');
  },
  // 可选参数：启用音频模式
  audioOnly: true,  // true=显示音频控件，false=显示视频控件（默认）
);

_playerController = musicPlayer.activeController;
```

### 🧹 资源释放

**重要**：为了避免内存泄漏，必须在页面销毁时正确释放播放器资源。以下是推荐的释放方式：

```dart
Future<void> _releasePlayer() async {
    try {
      // 1. 清理播放器缓存
      IAppPlayerConfig.clearAllCaches();
      if (_playerController != null) {
        try {
          // 2. 移除事件监听器
          _playerController!.removeEventsListener(_videoListener);
          // 3. 如果正在播放，先暂停并静音
          if (_playerController!.isPlaying() ?? false) {
            await _playerController!.pause();
            await _playerController!.setVolume(0);
          }
          // 4. 释放播放器资源
          await Future.microtask(() {
            _playerController!.dispose(forceDispose: true);
          });
          _playerController = null;
        } catch (e) {
          print('播放器清理失败: $e');
          _playerController = null;
        }
      }
    } catch (e) {
      print('播放器清理失败: $e');
      _playerController = null;
    }
}

@override
void dispose() {
  _releasePlayer();
  super.dispose();
}
```

## 🔧 高级功能

> 💡 **更多高级功能和详细配置请查看：**
> 
> 📚 **[完整API参数文档](docs/API_REFERENCE_CN.md)** - 包含所有参数详细说明

### 🎯 主要高级功能

- **多语言字幕** - 支持多种字幕格式和语言切换
- **DRM保护** - 支持 Widevine、FairPlay 等DRM方案
- **缓存控制** - 智能缓存策略和缓存管理
- **网络配置** - HTTP头部设置和网络优化
- **播放控制** - 精确的播放控制和事件监听
- **UI自定义** - 完全自定义播放器界面
- **画中画模式** - 支持Android和iOS画中画
- **通知集成** - 媒体通知和锁屏控制

## 📚 更多文档资源

> 💡 **如果本说明文档有不详尽的地方，请查看源代码中的详细注释** - 我们在代码中提供了丰富的注释说明，涵盖了各个API的用法、参数说明和使用示例。

## 🚨 重要提示

本库不对video_player库引发的问题负责，仅作为其上层UI封装。

即：应用中因视频播放导致的PlatformExceptions（平台异常）均由video_player库引起。

请向Flutter团队提交相关问题。

## 🔀 Flutter版本兼容性

本库至少尽力支持Flutter倒数第二个版本（N-1支持）。

但因Flutter版本重大变化，可能无法完全保证兼容性，必要时将发布重大或次要版本更新。

## 🤝 开源贡献

> 💡 **该插件正在积极开发中，欢迎社区参与！**
> 
> 🔄 **版本更新说明** - 由于项目处于快速迭代期，您可能会在每个版本中遇到不兼容的变化，我们会尽量在更新日志中详细说明。
> 
> 💪 **如何参与贡献** - 此插件由【电视宝应用商店（www.itvapp.net）】免费开发和维护，我们热烈欢迎您通过以下方式参与：
> - 🐛 **提交Bug报告** - 通过GitHub Issues发现问题请及时反馈
> - ✨ **功能建议** - 提出您的需求和改进想法  
> - 🔧 **代码贡献** - 直接提交Pull Request修复问题或增加新功能
> - 📝 **文档完善** - 帮助改进和完善项目文档
> 
> 🌟 **所有有价值的贡献都会被认真审查，让我们一起打造更好的播放器！**

## 📄 许可证

本项目遵循 **Apache License, Version 2.0** 开源协议。

### 许可证要求

根据 Apache 2.0 许可证：

- ✅ **可以自由使用、修改和分发**
- ✅ **可用于商业目的**
- ✅ **可以私有化修改**
- ⚠️ **需要保留版权声明和许可证**

### 版权信息

**原项目版权：**
```
Copyright 2020 Jakub Homlala and Better Player / Chewie / Video Player contributors
```

**本项目版权：**
```
Copyright [WWW.ITVAPP.NET] 2025 for modifications
```

完整许可证文本请查看 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 特别感谢 [Better Player / Chewie / Video Player] 项目提供的优秀开源代码基础。
- 感谢所有为IAppPlayer项目贡献代码、反馈问题和建议的开发者们。
- 感谢Flutter社区和开源社区的支持。

## 📞 联系方式

- 🌍 **官方网站**：[电视宝应用商店](https://www.itvapp.net)
- 🐛 **问题反馈**：[GitHub Issues](https://github.com/ITVAPP/IAppPlayer/issues)
- 📧 **邮箱联系**：service # itvapp.net（#替换为@）

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

[⬆ 回到顶部](#IAppPlayer)

</div>
