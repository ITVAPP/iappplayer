# 📚 IAppPlayer 常用示例文档

[![返回首页](https://img.shields.io/badge/🏠-电视宝应用商店-blue?style=for-the-badge)](https://www.itvapp.net)
[![GitHub](https://img.shields.io/badge/GitHub-项目地址-black?style=for-the-badge&logo=github)](https://github.com/ITVAPP/IAppPlayer)
[![English](https://img.shields.io/badge/📄-English-green?style=for-the-badge)](./API_CODE.md)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

---

## 📋 目录

- [📚 IAppPlayer 常用示例文档](#-iappplayer-常用示例文档)
  - [📋 目录](#-目录)
  - [⚠️ 重要说明](#️-重要说明)
  - [🎯 一、常用参数组合示例](#-一常用参数组合示例)
  - [🚀 二、性能优化建议](#-二性能优化建议)
  - [🔧 三、常见问题解决](#-三常见问题解决)

---

## ⚠️ 重要说明

### 参数互斥性
- `url` 和 `urls` 参数**不能同时使用**，系统会抛出 `ArgumentError`
- 单视频使用 `url` 参数
- 播放列表使用 `urls` 参数

### URL验证
- URL不能为空字符串
- 播放列表中的每个URL都会进行验证，空URL会抛出错误

### 返回值处理
- 当没有提供有效URL时，`createPlayer` 返回一个空的 `PlayerResult` 对象
- 使用前应检查 `result.activeController` 是否为 null

### 异步调用
- `createPlayer` 是异步方法，返回 `Future<PlayerResult>`
- 调用时需要使用 `await` 关键字

### URL格式自动检测
播放器会自动检测URL格式，支持带查询参数的URL。检测时会先去除查询参数（`?`后的部分），然后检查文件扩展名。支持的格式包括：
- `.m3u8` - HLS格式，自动识别为直播流
- `.mpd` - DASH格式
- `.flv` - FLV格式，自动识别为直播流
- `rtmp://`, `rtsp://` - 流媒体协议，自动识别为直播流

### 直播流特殊配置
直播流会自动应用以下特殊配置：
- 不使用缓存 - 直播内容实时性要求高
- 启用HLS轨道 - 支持多码率切换
- 启用音轨选择 - 支持多语言音轨
- 禁用循环播放 - 直播流不支持循环

---

## 🎯 一、常用参数组合示例

### 🎬 1. 最简单的视频播放

```dart
// createPlayer 返回 PlayerResult 对象
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
);

// 检查播放器是否创建成功
if (result.activeController == null) {
  print('播放器创建失败，请检查URL是否有效');
  return;
}

// 使用控制器
final controller = result.activeController;
```

### 📑 2. 带字幕的视频

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  title: '视频标题',
  subtitleUrl: 'https://example.com/subtitles.srt',
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
      print('播放器初始化完成');
    }
  },
);
```

### 🎵 3. 音乐播放器（支持LRC歌词）

```dart
// 单个音频文件播放 - 封面模式
final squareMusicPlayer = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: '歌曲名称',
  audioOnly: true,
  aspectRatio: 1.0,  // 封面模式
  subtitleContent: '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人''',  // LRC歌词内容
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
      // 获取当前歌词
      final subtitle = result.activeController?.renderedSubtitle;
      if (subtitle != null && subtitle.texts != null) {
        final currentLyric = subtitle.texts!.join(' ');
        print('当前歌词: $currentLyric');
      }
    }
  },
);

// 紧凑模式音乐播放器
final compactMusicPlayer = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: '歌曲名称',
  audioOnly: true,
  aspectRatio: 2.0,  // 紧凑模式（2:1比例）
  subtitleContent: lrcContent,
);

// 音乐播放列表
final musicPlaylist = await IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/song1.mp3',
    'https://example.com/song2.mp3',
    'https://example.com/song3.mp3',
  ],
  titles: ['歌曲1', '歌曲2', '歌曲3'],
  imageUrls: [  // 专辑封面
    'https://example.com/album1.jpg',
    'https://example.com/album2.jpg',
    'https://example.com/album3.jpg',
  ],
  subtitleContents: [  // LRC歌词
    '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody''',
    '''[00:01.00]第三首歌
[00:06.00]这是示例歌词''',
  ],
  audioOnly: true,
  shuffleMode: true,  // 随机播放
  autoPlay: true,
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistItem) {
      final index = event.parameters?['index'] as int?;
      print('切换到第${index! + 1}首');
    }
  },
);
```

### 📺 4. 直播流（HLS）

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/live.m3u8',
  title: '直播频道',
  autoPlay: true,
  looping: false,     // 直播不循环
  liveStream: true,   // 明确指定为直播流（通常会自动检测）
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.bufferingStart) {
      print('开始缓冲');
    } else if (event.iappPlayerEventType == IAppPlayerEventType.bufferingEnd) {
      print('缓冲结束');
    }
  },
);
```

### 🔐 5. 需要认证的视频

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/protected.mp4',
  headers: {
    'Authorization': 'Bearer your-token-here',
    'User-Agent': 'MyApp/1.0',
  },
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
      final error = event.parameters?['exception'];
      print('播放错误: $error');
    }
  },
);
```

### 📺 6. TV模式（禁用通知）

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  isTV: true,  // TV模式，自动禁用通知
  autoPlay: true,
  eventListener: (event) {},
);
```

### 🎯 7. 高级播放列表

```dart
// 创建数据源列表
final dataSources = [
  IAppPlayerConfig.createDataSource(
    url: 'https://example.com/video1.mp4',
    liveStream: false,
    title: '视频1',
    subtitleUrl: 'https://example.com/sub1.srt',
    headers: {'Authorization': 'Bearer token1'},
  ),
  IAppPlayerConfig.createDataSource(
    url: 'https://example.com/live.m3u8',
    liveStream: true,
    title: '直播流',
  ),
  IAppPlayerConfig.createDataSource(
    url: 'https://example.com/drm_video.mpd',
    liveStream: false,
    title: 'DRM保护视频',
    drmConfiguration: IAppPlayerDrmConfiguration(
      drmType: IAppPlayerDrmType.widevine,
      licenseUrl: 'https://example.com/license',
    ),
  ),
];

// 创建高级播放列表
final result = IAppPlayerConfig.createPlaylistPlayer(
  eventListener: (event) {},
  dataSources: dataSources,
  shuffleMode: false,
  loopVideos: true,
  initialStartIndex: 0,
);
```

### 🔄 8. 动态切换播放源

```dart
// 初始播放器
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video1.mp4',
  eventListener: (event) {},
);

// 稍后切换到新视频
await IAppPlayerConfig.playSource(
  controller: result.activeController!,
  source: 'https://example.com/video2.mp4',
  title: '新视频',
  subtitleUrl: 'https://example.com/new_sub.srt',
);

// 预加载下一个视频（不播放）
await IAppPlayerConfig.playSource(
  controller: result.activeController!,
  source: 'https://example.com/next_video.mp4',
  preloadOnly: true,  // 仅预加载
);
```

### 👂 9. 完整的事件处理示例

```dart
eventListener: (IAppPlayerEvent event) {
  switch (event.iappPlayerEventType) {
    case IAppPlayerEventType.initialized:
      print('播放器初始化完成');
      final duration = result.activeController?.videoPlayerController?.value.duration;
      print('视频总时长: ${duration?.inSeconds}秒');
      break;
      
    case IAppPlayerEventType.play:
      print('开始播放');
      break;
      
    case IAppPlayerEventType.pause:
      print('暂停播放');
      break;
      
    case IAppPlayerEventType.progress:
      final progress = event.parameters?['progress'] as Duration?;
      final duration = event.parameters?['duration'] as Duration?;
      if (progress != null && duration != null) {
        final percent = (progress.inSeconds / duration.inSeconds * 100).toStringAsFixed(1);
        print('播放进度: $percent%');
      }
      break;
      
    case IAppPlayerEventType.bufferingStart:
      print('开始缓冲...');
      break;
      
    case IAppPlayerEventType.bufferingEnd:
      print('缓冲完成');
      break;
      
    case IAppPlayerEventType.finished:
      print('播放完成');
      break;
      
    case IAppPlayerEventType.exception:
      final error = event.parameters?['exception'];
      print('播放错误: $error');
      break;
      
    case IAppPlayerEventType.openFullscreen:
      print('进入全屏');
      break;
      
    case IAppPlayerEventType.hideFullscreen:
      print('退出全屏');
      break;
      
    case IAppPlayerEventType.changedPlaylistItem:
      final index = event.parameters?['index'] as int?;
      print('切换到播放列表第${index! + 1}个视频');
      break;
      
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('随机模式: ${shuffleMode ? "开启" : "关闭"}');
      break;
      
    default:
      break;
  }
}
```

### 🎮 10. 控制器使用示例

```dart
// 基本播放控制
result.activeController?.play();
result.activeController?.pause();
result.activeController?.seekTo(Duration(minutes: 5, seconds: 30));
result.activeController?.setVolume(0.8);
result.activeController?.setSpeed(1.5);

// 全屏控制
result.activeController?.enterFullScreen();
result.activeController?.exitFullScreen();
result.activeController?.toggleFullScreen();

// 字幕控制
final subtitleSource = IAppPlayerSubtitlesSource(
  type: IAppPlayerSubtitlesSourceType.network,
  urls: ['https://example.com/new_subtitle.srt'],
  name: '中文字幕',
);
result.activeController?.setupSubtitleSource(subtitleSource);

// 获取播放状态
final isPlaying = result.activeController?.isPlaying() ?? false;
final isBuffering = result.activeController?.isBuffering() ?? false;
final isInitialized = result.activeController?.isVideoInitialized() ?? false;

// 获取当前歌词（适用于音乐播放器）
final subtitle = result.activeController?.renderedSubtitle;
if (subtitle != null && subtitle.texts != null && subtitle.texts!.isNotEmpty) {
  final currentLyric = subtitle.texts!.join(' ');
  print('当前歌词: $currentLyric');
}

// 播放列表控制
if (result.isPlaylist) {
  result.playlistController?.playNext();
  result.playlistController?.playPrevious();
  result.playlistController?.setupDataSource(3); // 播放第4个视频
  result.playlistController?.toggleShuffleMode();
  
  // 获取播放列表信息
  final currentIndex = result.playlistController?.currentDataSourceIndex ?? 0;
  final totalVideos = result.playlistController?.dataSourceList.length ?? 0;
  print('当前播放: ${currentIndex + 1}/$totalVideos');
}

// 释放资源
result.activeController?.dispose();
result.playlistController?.dispose();
```

### 🎨 11. 自定义控件示例

```dart
// 创建播放器时设置自定义控件配置
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {},
  controlsConfiguration: IAppPlayerControlsConfiguration(
    customControlsBuilder: (controller, onPlayerVisibilityChanged) {
      return MyCustomControls(
        controller: controller,
        onPlayerVisibilityChanged: onPlayerVisibilityChanged,
      );
    },
    playerTheme: IAppPlayerTheme.custom,
  ),
);
```

### 📊 12. 多分辨率切换示例

```dart
// 创建带多分辨率的数据源
final dataSource = IAppPlayerConfig.createDataSource(
  url: 'https://example.com/video_720p.mp4',
  liveStream: false,
  resolutions: {
    "360p": "https://example.com/video_360p.mp4",
    "720p": "https://example.com/video_720p.mp4",
    "1080p": "https://example.com/video_1080p.mp4",
    "自动": "auto",
  },
);

// 应用数据源
await result.controller?.setupDataSource(dataSource);
```

### 🌐 13. 网络异常处理示例

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
      final error = event.parameters?['exception'] as String?;
      
      // 显示错误提示
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('播放错误'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 重试播放
                result.activeController?.retryDataSource();
              },
              child: Text('重试'),
            ),
          ],
        ),
      );
    }
  },
);
```

### 🎵 14. 音频播放器显示模式示例

```dart
// 封面模式（1:1） - 适合单曲展示
final squarePlayer = await IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 1.0,  // 触发封面模式
  title: '歌曲名称',
  imageUrl: 'album_cover.jpg',
  subtitleContent: lrcContent,
);

// 紧凑模式（2:1） - 适合播放列表或嵌入式播放器
final compactPlayer = await IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 2.0,  // 触发紧凑模式
  title: '歌曲名称',
  imageUrl: 'album_cover.jpg',
);

// 扩展模式（其他比例） - 适合全屏播放
final expandedPlayer = await IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 16/9,  // 触发扩展模式
  title: '歌曲名称',
  imageUrl: 'album_cover.jpg',
);

// 也可以通过高度限制触发紧凑模式
Container(
  height: 180,  // 高度 <= 200px 会触发紧凑模式
  child: IAppPlayer(controller: result.activeController!),
)
```

### 🔑 15. 完整的初始化示例

```dart
// 这是一个包含所有可用参数的完整示例
final result = await IAppPlayerConfig.createPlayer(
  // 基础参数
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
  title: '示例视频',
  imageUrl: 'https://example.com/cover.jpg',
  backgroundImage: 'assets/background.png',
  
  // 字幕参数
  subtitleUrl: 'https://example.com/subtitle.srt',
  subtitles: [
    IAppPlayerSubtitlesSource(
      type: IAppPlayerSubtitlesSourceType.network,
      name: "中文",
      urls: ["https://example.com/chinese.srt"],
      selectedByDefault: true,
    ),
  ],
  
  // 播放控制
  autoPlay: false,
  looping: true,
  startAt: Duration(seconds: 10),
  
  // 高级参数
  isTV: false,
  audioOnly: false,
  liveStream: false,
  headers: {
    'Authorization': 'Bearer token',
    'User-Agent': 'MyApp/1.0',
  },
  
  // 视频配置
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
  videoFormat: IAppPlayerVideoFormat.hls,
  videoExtension: '.m3u8',
  dataSourceType: IAppPlayerDataSourceType.network,
  resolutions: {
    "720p": "https://example.com/video_720p.mp4",
    "1080p": "https://example.com/video_1080p.mp4",
  },
  
  // 界面配置
  placeholder: CircularProgressIndicator(),
  errorBuilder: (context, error) => Center(child: Text('播放错误: $error')),
  overlay: Container(
    alignment: Alignment.topRight,
    padding: EdgeInsets.all(8),
    child: Text('水印', style: TextStyle(color: Colors.white)),
  ),
  aspectRatio: 16 / 9,
  fit: BoxFit.contain,
  rotation: 0,
  showPlaceholderUntilPlay: true,
  placeholderOnTop: true,
  
  // 控件功能开关
  enableSubtitles: true,
  enableQualities: true,
  enableAudioTracks: true,
  enableFullscreen: true,
  enableOverflowMenu: true,
  handleAllGestures: true,  // 默认值：true
  showNotification: true,
  
  // 全屏配置
  fullScreenByDefault: false,
  fullScreenAspectRatio: 16 / 9,
  deviceOrientationsOnFullScreen: [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ],
  deviceOrientationsAfterFullScreen: [
    DeviceOrientation.portraitUp,
  ],
  systemOverlaysAfterFullScreen: SystemUiOverlay.values,
  autoDetectFullscreenDeviceOrientation: false,
  autoDetectFullscreenAspectRatio: false,
  
  // 流媒体参数
  useAsmsTracks: true,
  useAsmsAudioTracks: true,
  useAsmsSubtitles: true,
  overriddenDuration: Duration(minutes: 30),
  
  // 其他参数
  handleLifecycle: true,
  autoDispose: true,
  allowedScreenSleep: false,
  expandToFill: true,
  useRootNavigator: false,
  author: '作者名称',
  notificationChannelName: 'MyApp Video Player',
  
  // 多语言配置
  translations: [
    IAppPlayerTranslations.chinese(),
  ],
  
  // 可见性变化回调
  playerVisibilityChangedBehavior: (visibility) {
    print('播放器可见性: $visibility');
  },
);
```

### 🌟 16. 背景图片使用示例

```dart
// 使用网络背景图片
final result1 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'https://example.com/background.jpg',
  eventListener: (event) {},
);

// 使用本地资源背景图片
final result2 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'assets/images/video_bg.png',
  eventListener: (event) {},
);
```

### 📊 17. 列表自动播放（可见性处理）

```dart
// 在列表中使用播放器，根据可见度自动播放/暂停
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {},
  playerVisibilityChangedBehavior: (visibilityFraction) {
    // visibilityFraction: 0.0 = 完全不可见, 1.0 = 完全可见
    final controller = result.activeController;
    if (controller == null) return;
    
    if (visibilityFraction < 0.5) {
      // 少于50%可见时暂停
      if (controller.isPlaying()) {
        controller.pause();
      }
    } else if (visibilityFraction > 0.8) {
      // 超过80%可见时播放
      if (!controller.isPlaying() && controller.isVideoInitialized()) {
        controller.play();
      }
    }
  },
);
```

---

## 🚀 二、性能优化建议

### 📊 播放列表优化

#### 预加载策略
```dart
// 预加载下一个视频
final playlistController = result.playlistController;
if (playlistController != null) {
  final nextIndex = playlistController.currentDataSourceIndex + 1;
  if (nextIndex < playlistController.dataSourceList.length) {
    final nextDataSource = playlistController.dataSourceList[nextIndex];
    
    // 使用 playSource 的预加载功能
    await IAppPlayerConfig.playSource(
      controller: result.activeController!,
      source: nextDataSource.uri!,
      liveStream: nextDataSource.liveStream,
      preloadOnly: true,  // 仅预加载
    );
  }
}
```

### 🎥 视频质量自适应

```dart
// 根据网络状况自动切换画质
void adaptVideoQuality(double bandwidth) {
  String quality;
  if (bandwidth > 5.0) {
    quality = "1080p";
  } else if (bandwidth > 2.5) {
    quality = "720p";
  } else {
    quality = "360p";
  }
  
  // 切换到合适的画质
  final controller = result.activeController;
  final resolutions = controller?.iappPlayerDataSource?.resolutions;
  if (resolutions != null && resolutions.containsKey(quality)) {
    final url = resolutions[quality]!;
    controller?.setupDataSource(
      IAppPlayerConfig.createDataSource(
        url: url,
        liveStream: false,
        resolutions: resolutions,
      ),
    );
  }
}
```

### 💾 缓存配置

```dart
// 根据视频类型设置不同的缓存策略
IAppPlayerCacheConfiguration getCacheConfig(String videoType) {
  switch (videoType) {
    case 'short':  // 短视频
      return IAppPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 52428800,  // 50MB
        maxCacheFileSize: 10485760,  // 10MB
      );
    case 'long':  // 长视频
      return IAppPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 209715200,  // 200MB
        maxCacheFileSize: 52428800,  // 50MB
      );
    case 'live':  // 直播
      return IAppPlayerCacheConfiguration(
        useCache: false,  // 直播不缓存
      );
    default:
      return IAppPlayerCacheConfiguration(useCache: true);
  }
}

// 清理缓存
void cleanupCache() {
  result.activeController?.clearCache();
  IAppPlayerConfig.clearAllCaches();  // 清理URL格式检测缓存
}
```

### 🔋 内存管理建议

```dart
// 1. 及时释放资源
@override
void dispose() {
  playerResult?.activeController?.dispose();
  playerResult?.playlistController?.dispose();
  super.dispose();
}

// 2. 手动管理资源生命周期（复杂UI场景）
final result = await IAppPlayerConfig.createPlayer(
  url: 'video.mp4',
  autoDispose: false,  // 禁用自动释放
  eventListener: (event) {},
);

// 在合适的时机手动释放
void manualDispose() {
  result.activeController?.dispose();
}

// 3. 大型播放列表使用分页加载
void loadMoreVideos(List<String> newUrls) {
  final dataSources = newUrls.map((url) => 
    IAppPlayerConfig.createDataSource(url: url, liveStream: false)
  ).toList();
  
  result.playlistController?.setupDataSourceList([
    ...result.playlistController!.dataSourceList,
    ...dataSources,
  ]);
}
```

---

## 🔧 三、常见问题解决

### ❌ 视频无法播放

**问题**: 视频加载失败或黑屏

**解决方案**:
```dart
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
    final error = event.parameters?['exception'];
    
    // 检查错误类型并处理
    if (error.toString().contains('403')) {
      print('认证失败，请检查headers配置');
    } else if (error.toString().contains('404')) {
      print('视频不存在');
    } else if (error.toString().contains('format')) {
      print('视频格式不支持，尝试切换解码器');
      result.activeController?.retryDataSource();
    }
  }
}
```

### 📝 字幕不显示

**问题**: 字幕文件已加载但不显示

**解决方案**:
```dart
// 检查字幕是否正确加载
if (result.activeController?.subtitlesLines?.isEmpty ?? true) {
  print('字幕未正确加载');
  // 重新设置字幕
  result.activeController?.setupSubtitleSource(
    IAppPlayerSubtitlesSource(
      type: IAppPlayerSubtitlesSourceType.network,
      urls: [subtitleUrl],
      selectedByDefault: true,
    ),
  );
}
```

### 🔄 播放卡顿

**问题**: 视频播放不流畅

**解决方案**:
```dart
// 监控缓冲状态
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.bufferingUpdate) {
    final buffered = event.parameters?['buffered'] as List<Duration>?;
    if (buffered != null && buffered.isNotEmpty) {
      final totalBuffered = buffered.last.inSeconds;
      print('已缓冲: $totalBuffered 秒');
      
      // 如果缓冲不足，可以暂停等待
      if (totalBuffered < 5) {
        result.activeController?.pause();
      }
    }
  }
}
```

### 📱 全屏问题

**问题**: 全屏切换异常或方向错误

**解决方案**:
```dart
// 监听全屏事件并自定义处理
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.openFullscreen) {
    // 进入全屏时的自定义逻辑
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else if (event.iappPlayerEventType == IAppPlayerEventType.hideFullscreen) {
    // 退出全屏时的自定义逻辑
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
```

### ❓ 空值处理

**问题**: 未传入有效URL导致播放器创建失败

**解决方案**:
```dart
// 创建播放器前进行参数检查
final result = await IAppPlayerConfig.createPlayer(
  url: videoUrl,  // 可能为 null
  eventListener: (event) {},
);

// 检查播放器是否创建成功
if (result.activeController == null) {
  print('播放器创建失败，请检查URL是否有效');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('无法加载视频')),
  );
  return;
}

// 安全地使用控制器
result.activeController?.play();
```

### 🔗 URL格式验证错误

**问题**: 播放列表中包含空URL

**解决方案**:
```dart
// 在创建播放列表前验证URLs
final validUrls = urls.where((url) => url.isNotEmpty).toList();

if (validUrls.isEmpty) {
  print('没有有效的视频URL');
  return;
}

// 使用验证后的URLs创建播放器
final result = await IAppPlayerConfig.createPlayer(
  urls: validUrls,
  eventListener: (event) {},
);
```

### 🎵 歌词同步问题

**问题**: LRC歌词不同步或获取不到

**解决方案**:
```dart
// 在进度事件中获取当前歌词
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
    // 获取当前显示的歌词
    final subtitle = result.activeController?.renderedSubtitle;
    if (subtitle != null && subtitle.texts != null) {
      final currentLyric = subtitle.texts!.join(' ');
      // 更新UI显示当前歌词
      setState(() {
        _currentLyric = currentLyric;
      });
    }
  }
}
```

### 🐛 调试技巧

```dart
// 在事件监听器中打印关键事件
eventListener: (event) {
  print('IAppPlayer Event: ${event.iappPlayerEventType}');
  if (event.parameters != null) {
    print('Parameters: ${event.parameters}');
  }
}

// 检查播放器状态
void debugPlayerState() {
  final controller = result.activeController;
  print('=== Player State ===');
  print('Is Playing: ${controller?.isPlaying()}');
  print('Is Buffering: ${controller?.isBuffering()}');
  print('Is Initialized: ${controller?.isVideoInitialized()}');
  
  final value = controller?.videoPlayerController?.value;
  if (value != null) {
    print('Duration: ${value.duration}');
    print('Position: ${value.position}');
    print('Volume: ${value.volume}');
    print('Speed: ${value.speed}');
  }
  
  // 音频播放器专用：检查当前歌词
  final subtitle = controller?.renderedSubtitle;
  if (subtitle != null && subtitle.texts != null) {
    print('Current Lyric: ${subtitle.texts!.join(' ')}');
  }
}
```

---

<div align="center">

**🎯 本文档包含了 IAppPlayer 的常用示例和最佳实践**

**👍 如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

**📚 [⬅️ 返回首页](../README.md)   [⬆ 回到顶部](#-iappplayer-常用示例文档)**

</div>
