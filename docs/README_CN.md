# IAppPlayer

[![返回首页](https://img.shields.io/badge/🏠-电视宝应用商店-blue?style=for-the-badge)](https://www.itvapp.net)
[![English](https://img.shields.io/badge/📄-English-green?style=for-the-badge)](../README.md)
[![GitHub Issues](https://img.shields.io/github/issues/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/issues)
[![GitHub Forks](https://img.shields.io/github/forks/ITVAPP/IAppPlayer?style=for-the-badge)](https://github.com/ITVAPP/IAppPlayer/network)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

> 🎥 **IAppPlayer** - Flutter生态强大的播放器解决方案！专为OTT/IPTV、音乐播放器、视频平台等专业应用打造的高性能播放器。

## 💡 为什么选择 IAppPlayer？

🚀 **流媒体支持** - 完整支持HLS、DASH、RTMP、RTSP等主流协议  
⚡ **性能优化** - 针对TV、车机等低配设备深度优化  
🛡️ **企业级DRM** - 内置Widevine、FairPlay等版权保护方案  
🎵 **音乐播放专家** - 原生LRC歌词支持，3种音频UI模式  
📱 **多平台覆盖** -  iOS/Android原生适配，安全可靠

## 📖 文档导航

| 📋 文档类型 | 🔗 链接 | 📝 说明 |
|:---:|:---:|:---|
| 🚀 **快速开始** | [👇 下方内容](#-快速开始) | 基础使用和简单示例 |
| 📖 **详细文档** | [📚 参数说明](./API_REFERENCE_CN.md) | 完整API参数文档 |
| 🎯 **常用示例** | [📚 常用示例](./API_CODE_CN.md) | 常用示例说明文档 |
| 🖼️ **应用截图** | [📸 截图展示](./APP_SCREENSHOTS_CN.md) | 播放器实际效果展示 |
| 🌐 **在线文档** | [🔗 网页文档](https://iappplayer.itvapp.net) | 在线文档和互动演示 |

## ✨ 核心功能特性

### 🎯 基础功能
- ✅ **完整播放控制** - 播放/暂停/快进/音量/速度等全套控制
- ✅ **智能播放列表** - 连播/随机播放/循环模式，内存优化
- ✅ **多格式字幕** - SRT/LRC/WebVTT/HLS分段字幕，HTML标签支持
- ✅ **音频专用UI** - 3种显示模式（正方形/紧凑/扩展）
- ✅ **歌词完美呈现** - 专为音乐播放优化的LRC歌词引擎
- ✅ **系统级控制** - 通知栏控制、锁屏控制、画中画模式
- ✅ **智能缓存** - 预加载、缓存管理、离线播放

### 🔥 专业级特性

#### 📡 流媒体协议全家桶
```
• HLS - 完整的m3u8支持，包括轨道选择、分段字幕、音轨切换
• DASH - MPD解析，自适应码率，字幕/音轨切换  
• RTMP/RTSP - 低延迟直播，实时流媒体
• SmoothStreaming - 微软流媒体协议支持
• HTTP/HTTPS - 标准流媒体，支持断点续传
• FLV - 低延迟直播流
```

#### 🛠️ 高级技术特性
```
• 硬件/软件解码智能切换 - 自动选择最佳解码方案
• FFmpeg软解码器 - 支持几乎所有媒体格式
• Cronet网络栈 - Google高性能网络（Android）
• 自动降级机制 - 网络异常时智能切换数据源
• DRM保护 - Widevine L1/L3、FairPlay、ClearKey
• 低配设备专项优化 - TV/车机系统流畅运行
• 完整事件系统 - 23种事件类型，精确控制
```

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
    namespace 'com.example.yourapp'
    compileSdkVersion 35
    
    defaultConfig {
        minSdkVersion 21  // 重要：最低 API 21
        targetSdkVersion 34
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

智能解码器选择，自动适配不同设备和视频格式：

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

支持智能连播、随机播放和循环模式：

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

专业的音频播放体验，支持LRC歌词同步显示：

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

**重要**：为了避免内存泄漏，必须在页面销毁时正确释放播放器资源：

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

## 🔧 高级功能速览

> 💡 **更多高级功能和详细配置请查看：**
> 
> 📚 **[完整API参数文档](docs/API_REFERENCE_CN.md)** - 包含所有参数详细说明

### 🎯 主要高级功能

- **多语言字幕** - 支持多种字幕格式和语言切换
- **DRM保护** - 企业级版权保护方案
- **智能缓存** - 预加载和离线播放
- **网络优化** - HTTP头部设置和自适应码率
- **精确控制** - 完整的播放控制和事件监听
- **UI自定义** - 完全自定义播放器界面
- **画中画模式** - 系统级画中画支持
- **通知集成** - 媒体通知和锁屏控制

> 💡 **如果本说明文档有不详尽的地方，请查看源代码中的详细注释**

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

## ☕ 支持开发者

### 💝 请开发者喝杯咖啡

> 🎯 **IAppPlayer 是一个完全免费和开源的项目**  
> 
> 我们投入了大量的时间和精力来开发、维护和改进这个播放器，希望它能帮助到更多的开发者。如果 IAppPlayer 帮助您节省了开发时间，或者您的项目因此获得了成功，欢迎请我们喝杯咖啡！☕

<div align="center">

### 🌟 您的支持是我们前进的动力！

<table>
  <tr>
    <td align="center" width="33%">
      <img src="../media/donate-wechat.png" alt="微信赞赏码" width="200"/>
      <br/>
      <b>微信赞赏</b>
      <br/>
      <sub>使用微信扫一扫</sub>
    </td>
    <td align="center" width="33%">
      <img src="../media/donate-alipay.png" alt="支付宝捐赠" width="200"/>
      <br/>
      <b>支付宝捐赠</b>
      <br/>
      <sub>使用支付宝扫一扫</sub>
    </td>
    <td align="center" width="33%">
      <img src="../media/donate-paypal.png" alt="PayPal捐赠" width="200"/>
      <br/>
      <b>PayPal 捐赠</b>
      <br/>
      <sub><a href="https://paypal.me/itvapp/" target="_blank">点击前往 PayPal</a></sub>
    </td>
  </tr>
</table>

</div>

### 💌 捐赠说明

- 💰 **金额随意** - 一杯咖啡的钱就能让开发者开心一整天！
- 🙏 **非强制性** - IAppPlayer 永远免费，捐赠完全自愿

> 💭 **开发者寄语**：每一份支持都是对开源事业的认可，感谢您让开源世界变得更美好！

## 📄 许可证

本项目遵循 **Apache License, Version 2.0** 开源协议。

### 许可证要求

根据 Apache 2.0 许可证：

- ✅ **可以自由使用、修改和分发**
- ✅ **可用于商业目的**
- ✅ **可以私有化修改**
- ⚠️ **需要保留版权声明和许可证**

### 版权信息

```
Copyright [WWW.ITVAPP.NET] 2025 for modifications
```

完整许可证文本请查看 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 特别感谢 [Better Player / Chewie / Video Player] 项目提供的优秀开源代码基础。
- 感谢所有为IAppPlayer项目贡献代码、反馈问题和建议的开发者们。

## 📞 联系方式

- 🌍 **官方网站**：[电视应用商店](https://www.itvapp.net)
- 🐛 **问题反馈**：[GitHub Issues](https://github.com/ITVAPP/IAppPlayer/issues)
- 📧 **邮箱联系**：service # itvapp.net（#替换为@）

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

**IAppPlayer - 让视频播放变得简单而强大！**

[⬆ 回到顶部](#IAppPlayer)

</div>
