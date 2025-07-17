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
  - [📊 默认配置值](#-默认配置值)
  - [🎯 一、常用参数组合示例](#-一常用参数组合示例)
  - [🚀 二、性能优化建议](#-二性能优化建议)
  - [🔧 三、常见故障排除](#-三常见故障排除)

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

---

## 📊 默认配置值

| 配置项 | 默认值 | 说明 |
|:---|:---:|:---|
| **缓存配置** |  |  |
| 预缓存大小 | 10MB | 预加载视频的缓存大小 |
| 最大缓存 | 300MB | 总缓存大小上限 |
| 单文件最大缓存 | 50MB | 单个视频文件的缓存上限 |
| **缓冲配置** |  |  |
| 直播最小缓冲 | 15秒 | 直播流的最小缓冲时间 |
| 点播最小缓冲 | 20秒 | 点播视频的最小缓冲时间 |
| 直播最大缓冲 | 15秒 | 直播流的最大缓冲时间 |
| 点播最大缓冲 | 30秒 | 点播视频的最大缓冲时间 |
| 播放缓冲 | 3秒 | 开始播放所需的缓冲时间 |
| 重新缓冲后播放 | 5秒 | 卡顿后重新开始播放所需的缓冲时间 |
| **界面配置** |  |  |
| 默认活动名称 | `MainActivity` | Android通知栏使用的活动名称 |
| 图片缩放模式 | `BoxFit.cover` | 背景图片和占位图的默认缩放模式 |
| 图片质量 | `FilterQuality.medium` | 本地图片的渲染质量 |
| 默认旋转角度 | 0° | 视频的默认旋转角度 |
| **其他配置** |  |  |
| 视频标题格式 | `视频 ${index+1}` | 播放列表中未指定标题时的默认格式 |
| 字幕名称 | `字幕` | 默认字幕轨道名称 |
| 播放列表切换延迟 | 1秒 | 自动播放下一个视频的延迟时间 |
| URL格式缓存 | 1000条 | 最多缓存1000个URL的格式检测结果 |

### 直播流特殊配置
直播流会自动应用以下特殊配置：
- **不使用缓存** - 直播内容实时性要求高
- **启用HLS轨道** - 支持多码率切换
- **启用音轨选择** - 支持多语言音轨
- **禁用循环播放** - 直播流不支持循环

### URL格式检测说明
- 系统会自动检测URL格式，支持带查询参数的URL
- 检测时会先去除查询参数（`?`后的部分），然后检查文件扩展名
- 检测结果会被缓存，避免重复检测相同的URL

---

## 🎯 一、常用参数组合示例

### 🎬 1. 最简单的视频播放

```dart
// createPlayer 返回 PlayerResult 对象，包含控制器引用
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
  // 可以在父组件调用的时候传入下面参数，指定优先的解码器
  // 使用硬件解码优先（默认）
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
  // 或者使用软件解码优先（兼容性更好，但性能消耗更大）
  // preferredDecoderType: IAppPlayerDecoderType.softwareFirst,
);

// 检查播放器是否创建成功
if (result.activeController == null) {
  print('播放器创建失败，请检查URL是否有效');
  return;
}

// PlayerResult 提供了便捷的访问方式
final controller = result.controller;  // 单视频控制器
// 或使用 activeController 自动获取当前活动控制器
final activeController = result.activeController;

// 如果视频播放出现兼容性问题，可以切换解码器类型重试
void switchDecoder() async {
  await IAppPlayerConfig.playSource(
    controller: controller!,
    source: 'https://example.com/video.mp4',
    preferredDecoderType: IAppPlayerDecoderType.softwareFirst,
  );
}
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
// 单个音频文件播放
final singleMusicPlayer = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: '歌曲名称',
  audioOnly: true,  // 启用音频控件界面，而不是视频控件
  subtitleContent: '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人''',  // LRC歌词内容
  eventListener: (event) {
    print('音乐播放器事件: ${event.iappPlayerEventType}');
  },
);

// 音乐播放列表（带LRC歌词）
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
  subtitleContents: [  // LRC歌词格式
    '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人
[00:34.23]陪伴我度过漫长岁月的那个人''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody
[00:10.00]Love is in the air
[00:15.00]Everywhere I look around''',
    '''[00:01.00]第三首歌
[00:06.00]这是示例歌词
[00:12.00]支持LRC格式''',
  ],
  audioOnly: true,  // 启用音频控件界面
  shuffleMode: true,  // 随机播放
  autoPlay: true,
  eventListener: (event) {
    switch (event.iappPlayerEventType) {
      case IAppPlayerEventType.changedPlaylistItem:
        final index = event.parameters?['index'] as int?;
        print('切换到第${index! + 1}首');
        break;
      case IAppPlayerEventType.changedPlaylistShuffle:
        final shuffleMode = event.parameters?['shuffleMode'] as bool?;
        print('随机模式: ${shuffleMode! ? "开启" : "关闭"}');
        break;
      default:
        break;
    }
  },
);

// 控制播放列表
musicPlaylist.playlistController?.playNext();
musicPlaylist.playlistController?.toggleShuffleMode();

// 也可以使用外部LRC文件
final musicWithLrcFile = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: '歌曲名称',
  audioOnly: true,
  subtitleUrl: 'https://example.com/lyrics.lrc',  // LRC歌词文件URL
  eventListener: (event) {},
);
```

### 📺 4. 直播流（HLS）

```dart
// URL格式自动检测说明：
// IAppPlayerConfig 会自动检测URL格式并设置合适的参数：
// - .m3u8 -> HLS格式，自动识别为直播流
// - .mpd -> DASH格式
// - .flv -> FLV格式，自动识别为直播流
// - .ism -> Smooth Streaming格式
// - rtmp://, rtsp:// -> 流媒体协议，自动识别为直播流

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

// 直播流会自动应用以下配置：
// - 禁用缓存（useCache: false）
// - 启用HLS轨道（useAsmsTracks: true）
// - 启用音轨选择（useAsmsAudioTracks: true）
// - 较小的缓冲区（15秒）
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
      // 可能需要刷新token
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
  eventListener: (event) {
    // TV模式下的事件处理
  },
);

// TV模式特点：
// - 自动禁用系统通知
// - 适合大屏幕展示
// - 建议配合遥控器操作
```

### 🎯 7. 高级播放列表（每个视频不同配置）

```dart
// 方式一：使用 URLs 创建播放列表（简单模式）
final simplePlaylist = await IAppPlayerConfig.createPlayer(
  urls: ['url1', 'url2', 'url3'],
  titles: ['视频1', '视频2', '视频3'],
  imageUrls: ['cover1.jpg', 'cover2.jpg', 'cover3.jpg'],  // 每个视频的封面
  subtitleUrls: ['sub1.srt', 'sub2.srt', 'sub3.srt'],  // 每个视频的字幕
  // 或者使用 subtitleContents 提供字幕内容
  eventListener: (event) {},
);

// 方式二：使用数据源创建播放列表（高级模式）
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

// 使用 createPlaylistPlayer 创建高级播放列表
final result = IAppPlayerConfig.createPlaylistPlayer(
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('播放模式: ${shuffleMode! ? "随机播放" : "顺序播放"}');
    }
  },
  dataSources: dataSources,
  shuffleMode: false,  // false: 顺序播放, true: 随机播放
  loopVideos: true,    // 播放列表循环
  initialStartIndex: 0,  // 从第一个视频开始
  nextVideoDelay: Duration(seconds: 3),  // 视频切换延迟
  playerConfiguration: null,  // 可选的自定义播放器配置
);

// 动态切换播放模式
void togglePlayMode() {
  result.playlistController?.toggleShuffleMode();
  print('当前模式: ${result.playlistController?.shuffleMode ? "随机" : "顺序"}');
}

// 跳转到指定视频
void jumpToVideo(int index) {
  result.playlistController?.setupDataSource(index);
}
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
  preloadOnly: false,  // 立即播放
);

// 预加载下一个视频（不播放）
await IAppPlayerConfig.playSource(
  controller: result.activeController!,
  source: 'https://example.com/next_video.mp4',
  preloadOnly: true,  // 仅预加载，不播放
);
```

### 👂 9. 完整的事件处理示例

```dart
eventListener: (IAppPlayerEvent event) {
  switch (event.iappPlayerEventType) {
    // 初始化事件
    case IAppPlayerEventType.initialized:
      print('播放器初始化完成');
      final duration = result.activeController?.videoPlayerController?.value.duration;
      print('视频总时长: ${duration?.inSeconds}秒');
      break;
      
    // 播放控制事件
    case IAppPlayerEventType.play:
      print('开始播放');
      break;
    case IAppPlayerEventType.pause:
      print('暂停播放');
      break;
      
    // 进度事件
    case IAppPlayerEventType.progress:
      final progress = event.parameters?['progress'] as Duration?;
      final duration = event.parameters?['duration'] as Duration?;
      if (progress != null && duration != null) {
        final percent = (progress.inSeconds / duration.inSeconds * 100).toStringAsFixed(1);
        print('播放进度: ${progress.inSeconds}/${duration.inSeconds}秒 ($percent%)');
      }
      break;
      
    // 缓冲事件
    case IAppPlayerEventType.bufferingStart:
      print('开始缓冲...');
      break;
    case IAppPlayerEventType.bufferingEnd:
      print('缓冲完成');
      break;
    case IAppPlayerEventType.bufferingUpdate:
      final buffered = event.parameters?['buffered'] as List<Duration>?;
      if (buffered != null && buffered.isNotEmpty) {
        print('已缓冲: ${buffered.last.inSeconds}秒');
      }
      break;
      
    // 完成事件
    case IAppPlayerEventType.finished:
      print('播放完成');
      // 可以在这里实现自动播放下一个
      break;
      
    // 错误事件
    case IAppPlayerEventType.exception:
      final error = event.parameters?['exception'];
      print('播放错误: $error');
      // 可以显示错误提示或尝试重试
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('播放错误'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                result.activeController?.retryDataSource();
              },
              child: Text('重试'),
            ),
          ],
        ),
      );
      break;
      
    // 全屏事件
    case IAppPlayerEventType.openFullscreen:
      print('进入全屏');
      break;
    case IAppPlayerEventType.hideFullscreen:
      print('退出全屏');
      break;
      
    // 播放列表事件
    case IAppPlayerEventType.changedPlaylistItem:
      final index = event.parameters?['index'] as int?;
      print('切换到播放列表第${index! + 1}个视频');
      break;
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('随机模式: ${shuffleMode ? "开启" : "关闭"}');
      break;
      
    // 字幕事件
    case IAppPlayerEventType.changedSubtitles:
      final subtitlesSource = event.parameters?['subtitlesSource'] as IAppPlayerSubtitlesSource?;
      print('切换字幕: ${subtitlesSource?.name}');
      break;
      
    // 画质切换事件
    case IAppPlayerEventType.changedResolution:
      final url = event.parameters?['url'] as String?;
      print('切换画质: $url');
      break;
      
    default:
      break;
  }
}
```

### 🎮 10. 完整的控制器使用示例

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

// 播放列表控制
if (result.isPlaylist) {
  // 播放控制
  result.playlistController?.playNext();
  result.playlistController?.playPrevious();
  result.playlistController?.setupDataSource(3); // 播放第4个视频
  
  // 随机播放
  result.playlistController?.toggleShuffleMode();
  
  // 获取播放列表信息
  final currentIndex = result.playlistController?.currentDataSourceIndex ?? 0;
  final hasNext = result.playlistController?.hasNext ?? false;
  final hasPrevious = result.playlistController?.hasPrevious ?? false;
  final shuffleMode = result.playlistController?.shuffleMode ?? false;
  final totalVideos = result.playlistController?.dataSourceList.length ?? 0;
  
  print('当前播放: ${currentIndex + 1}/$totalVideos');
  print('随机模式: $shuffleMode');
}

// 高级功能
result.activeController?.enablePictureInPicture();
result.activeController?.setMixWithOthers(true);

// 缓存管理
result.activeController?.clearCache();
await result.activeController?.preCache(dataSource);

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

// 自定义控件实现
class MyCustomControls extends StatefulWidget {
  final IAppPlayerController controller;
  final Function(bool) onPlayerVisibilityChanged;

  MyCustomControls({
    required this.controller,
    required this.onPlayerVisibilityChanged,
  });

  @override
  _MyCustomControlsState createState() => _MyCustomControlsState();
}

class _MyCustomControlsState extends State<MyCustomControls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // 实现自定义控件UI
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.replay_10),
            onPressed: () {
              final currentPosition = widget.controller.videoPlayerController?.value.position ?? Duration.zero;
              widget.controller.seekTo(currentPosition - Duration(seconds: 10));
            },
          ),
          IconButton(
            icon: Icon(widget.controller.isPlaying() ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (widget.controller.isPlaying()) {
                widget.controller.pause();
              } else {
                widget.controller.play();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.forward_10),
            onPressed: () {
              final currentPosition = widget.controller.videoPlayerController?.value.position ?? Duration.zero;
              widget.controller.seekTo(currentPosition + Duration(seconds: 10));
            },
          ),
        ],
      ),
    );
  }
}
```

### 📊 12. 多分辨率切换示例

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video_720p.mp4',
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.changedResolution) {
      final url = event.parameters?['url'];
      print('已切换到: $url');
    }
  },
);

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
// 网络状态监听和重连机制
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math' as math;

class VideoPlayerWithNetworkHandling extends StatefulWidget {
  @override
  _VideoPlayerWithNetworkHandlingState createState() => _VideoPlayerWithNetworkHandlingState();
}

class _VideoPlayerWithNetworkHandlingState extends State<VideoPlayerWithNetworkHandling> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  PlayerResult? playerResult;
  bool wasDisconnected = false;
  int retryCount = 0;
  static const maxRetries = 3;
  
  @override
  void initState() {
    super.initState();
    initializePlayer();
  }
  
  Future<void> initializePlayer() async {
    // 创建播放器
    playerResult = await IAppPlayerConfig.createPlayer(
      url: 'https://example.com/video.mp4',
      eventListener: handlePlayerEvent,
    );
    
    // 监听网络状态
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && wasDisconnected) {
        // 网络恢复，重试播放
        print('网络已恢复，尝试重新连接...');
        playerResult?.activeController?.retryDataSource();
        wasDisconnected = false;
        retryCount = 0;
      } else if (result == ConnectivityResult.none) {
        wasDisconnected = true;
        print('网络已断开');
      }
    });
  }
  
  void handlePlayerEvent(IAppPlayerEvent event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
      final error = event.parameters?['exception'] as String?;
      
      // 判断是否为网络错误
      if (error != null && (error.contains('network') || 
          error.contains('timeout') || 
          error.contains('connection'))) {
        
        if (retryCount < maxRetries) {
          // 指数退避重试策略
          final delay = Duration(seconds: math.pow(2, retryCount).toInt());
          print('网络错误，将在 ${delay.inSeconds} 秒后重试（第 ${retryCount + 1}/$maxRetries 次）');
          
          Future.delayed(delay, () {
            playerResult?.activeController?.retryDataSource();
            retryCount++;
          });
        } else {
          // 达到最大重试次数
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('网络错误'),
              content: Text('无法连接到服务器，请检查网络设置'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    retryCount = 0;  // 重置重试计数
                    playerResult?.activeController?.retryDataSource();
                  },
                  child: Text('重试'),
                ),
              ],
            ),
          );
        }
      }
    } else if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
      // 播放成功，重置重试计数
      retryCount = 0;
    }
  }
  
  @override
  void dispose() {
    connectivitySubscription.cancel();
    playerResult?.activeController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 构建你的UI
    return Container();
  }
}
```

### 🔑 14. 完整的初始化示例

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
  handleAllGestures: true,
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
    IAppPlayerTranslations(
      languageCode: 'zh',
      generalDefaultError: '无法播放视频',
      generalNone: '无',
      generalDefault: '默认',
      generalRetry: '重试',
      playlistLoadingNextVideo: '正在加载下一个视频',
      controlsLive: '直播',
      controlsNextVideoIn: '下一个视频',
      overflowMenuPlaybackSpeed: '播放速度',
      overflowMenuSubtitles: '字幕',
      overflowMenuQuality: '画质',
      overflowMenuAudioTracks: '音轨',
      qualityAuto: '自动',
    ),
  ],
  
  // 可见性变化回调
  playerVisibilityChangedBehavior: (visibility) {
    print('播放器可见性: $visibility');
  },
  
  // 路由页面构建器
  routePageBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
);
```

### 🌟 15. 背景图片使用示例

```dart
// 使用网络背景图片
final result1 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'https://example.com/background.jpg',  // 网络图片
  eventListener: (event) {},
);

// 使用本地资源背景图片
final result2 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'assets/images/video_bg.png',  // 本地资源
  eventListener: (event) {},
);

// 背景图片特性：
// - 自动使用 BoxFit.cover 缩放模式
// - 本地图片使用 FilterQuality.medium 渲染质量
// - 如果设置了 errorBuilder，背景图片也会作为错误时的显示内容
// - 支持网络图片（http/https）和本地资源图片
```

### 🚀 16. URL格式检测缓存优化示例

```dart
// 在应用启动时预热常用URL格式
void preloadUrlFormats() {
  final commonUrls = [
    'https://example.com/video.mp4',
    'https://example.com/live.m3u8',
    'https://example.com/stream.mpd',
    'https://example.com/video.mp4?token=abc123',  // 带查询参数的URL
  ];
  
  // 预先检测URL格式，结果会被缓存
  for (final url in commonUrls) {
    IAppPlayerConfig.createDataSource(
      url: url,
      liveStream: false,  // 会触发URL格式检测
    );
  }
}

// 在应用退出或内存紧张时清理缓存
void onAppCleanup() {
  IAppPlayerConfig.clearAllCaches();
  print('已清理URL格式检测缓存');
}

// URL格式检测缓存说明：
// - 自动缓存最近1000个URL的格式检测结果
// - 使用LRU算法，自动淘汰最久未使用的条目
// - 提高重复播放相同URL时的性能
// - 缓存包含：是否为直播流、视频格式信息
// - 检测时会先去除查询参数，然后检查文件扩展名
```

---

## 🚀 二、性能优化建议

### 📊 播放列表优化

#### 1. 预加载策略
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

#### 2. 懒加载大型列表
```dart
// 分页加载播放列表
import 'dart:math';

const pageSize = 20;
var currentPage = 0;

void loadMoreVideos() {
  final startIndex = currentPage * pageSize;
  final endIndex = min(startIndex + pageSize, allVideos.length);
  final pageVideos = allVideos.sublist(startIndex, endIndex);
  
  // 添加到播放列表
  final dataSources = pageVideos.map((video) => 
    IAppPlayerConfig.createDataSource(
      url: video.url,
      liveStream: false,
    )
  ).toList();
  
  result.playlistController?.setupDataSourceList([
    ...result.playlistController!.dataSourceList,
    ...dataSources,
  ]);
  
  currentPage++;
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

### 💾 缓存策略

#### 1. 智能缓存配置
```dart
// 根据视频类型设置缓存
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
```

#### 2. 缓存清理
```dart
// 定期清理缓存
void cleanupCache() async {
  // 清理视频缓存
  result.activeController?.clearCache();
  
  // 清理URL格式检测缓存
  IAppPlayerConfig.clearAllCaches();
}
```

### 🔋 电池优化

```dart
// 根据电量调整播放策略
void optimizeForBattery(int batteryLevel) {
  if (batteryLevel < 20) {
    // 低电量模式
    result.activeController?.setSpeed(1.0);  // 正常速度
    // 可以考虑降低画质
  }
}
```

### 📈 URL格式检测优化

```dart
// URL格式检测缓存机制说明：
// 1. 自动缓存最近1000个URL的格式检测结果
// 2. 使用LRU（最近最少使用）算法管理缓存
// 3. 避免重复检测相同URL，提高性能

// 批量预检测URL格式
void batchPreloadUrlFormats(List<String> urls) {
  for (final url in urls) {
    // 触发格式检测并缓存结果
    IAppPlayerConfig.createDataSource(
      url: url,
      liveStream: false,
    );
  }
}

// 在适当时机清理缓存
void performMaintenance() {
  // 清理URL格式检测缓存
  IAppPlayerConfig.clearAllCaches();
  
  // 可以立即预加载常用URL
  final frequentlyUsedUrls = [
    'https://example.com/common1.m3u8',
    'https://example.com/common2.mp4',
  ];
  batchPreloadUrlFormats(frequentlyUsedUrls);
}
```

### 📊 性能基准测试数据

基于实际测试的性能参考数据：

| 设备类型 | 视频分辨率 | CPU占用 | 内存占用 | 建议并发数 |
|:---:|:---:|:---:|:---:|:---:|
| 低端手机 | 480p | 15-25% | 30-50MB | 1 |
| 中端手机 | 720p | 20-30% | 50-80MB | 1-2 |
| 高端手机 | 1080p | 25-35% | 80-120MB | 2-3 |
| 平板 | 1080p | 20-30% | 100-150MB | 2-3 |
| TV盒子 | 4K | 40-60% | 150-200MB | 1 |

---

## 🔧 三、常见故障排除

### ❌ 常见问题及解决方案

#### 1. 视频无法播放

**问题描述**: 视频加载失败或黑屏

**解决方案**:
```dart
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
    final error = event.parameters?['exception'];
    
    // 检查错误类型
    if (error.toString().contains('403')) {
      print('认证失败，请检查headers配置');
    } else if (error.toString().contains('404')) {
      print('视频不存在');
    } else if (error.toString().contains('format')) {
      print('视频格式不支持');
      // 尝试切换解码器
      result.activeController?.retryDataSource();
    }
  }
}
```

#### 2. 字幕不显示

**问题描述**: 字幕文件已加载但不显示

**解决方案**:
```dart
// 检查字幕配置
final subtitlesConfig = IAppPlayerSubtitlesConfiguration(
  fontSize: 16,  // 确保字体大小合适
  fontColor: Colors.white,
  outlineEnabled: true,
  outlineColor: Colors.black,
  backgroundColor: Colors.transparent,
);

// 检查字幕源
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

#### 3. 播放卡顿

**问题描述**: 视频播放不流畅

**解决方案**:
```dart
// 调整缓冲配置
final bufferingConfig = IAppPlayerBufferingConfiguration(
  minBufferMs: 15000,  // 增加最小缓冲
  maxBufferMs: 30000,  // 增加最大缓冲
  bufferForPlaybackMs: 2500,
  bufferForPlaybackAfterRebufferMs: 5000,
);

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
        // 等待缓冲足够后继续播放
      }
    }
  }
}
```

#### 4. 全屏问题

**问题描述**: 全屏切换异常或方向错误

**解决方案**:
```dart
// 自定义全屏行为
final config = IAppPlayerConfiguration(
  autoDetectFullscreenDeviceOrientation: true,
  autoDetectFullscreenAspectRatio: true,
  deviceOrientationsOnFullScreen: [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ],
  deviceOrientationsAfterFullScreen: [
    DeviceOrientation.portraitUp,
  ],
  fullScreenByDefault: false,
);

// 监听全屏事件
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

#### 5. 空值处理

**问题描述**: 未传入有效URL导致播放器创建失败

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
  // 显示错误提示给用户
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('无法加载视频')),
  );
  return;
}

// 安全地使用控制器
result.activeController?.play();
```

#### 6. URL格式验证错误

**问题描述**: 播放列表中包含空URL

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

### 🐛 调试技巧

#### 1. 启用详细日志
```dart
// 在事件监听器中打印所有事件
eventListener: (event) {
  print('IAppPlayer Event: ${event.iappPlayerEventType}');
  if (event.parameters != null) {
    print('Parameters: ${event.parameters}');
  }
}
```

#### 2. 检查播放器状态
```dart
void debugPlayerState() {
  final controller = result.activeController;
  print('=== Player State ===');
  print('Is Playing: ${controller?.isPlaying()}');
  print('Is Buffering: ${controller?.isBuffering()}');
  print('Is Initialized: ${controller?.isVideoInitialized()}');
  print('Is Fullscreen: ${controller?.isFullScreen}');
  
  final value = controller?.videoPlayerController?.value;
  if (value != null) {
    print('Duration: ${value.duration}');
    print('Position: ${value.position}');
    print('Buffered: ${value.buffered}');
    print('Is Playing: ${value.isPlaying}');
    print('Volume: ${value.volume}');
    print('PlaybackSpeed: ${value.speed}');
  }
}
```

#### 3. 网络请求调试
```dart
// 使用代理调试网络请求
final headers = {
  'Authorization': 'Bearer token',
  'X-Debug-Mode': 'true',  // 添加调试标记
};

// 监听网络相关错误
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
    final error = event.parameters?['exception'];
    // 记录详细错误信息
    print('Video playback error: $error');
  }
}
```

---

<div align="center">

**🎯 本文档包含了 IAppPlayer 的常用示例说明和最佳实践**

**👍 如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

**📚 [⬅️ 返回首页](../README.md)   [⬆ 回到顶部](#-iappplayer-常用示例文档)**

</div>
