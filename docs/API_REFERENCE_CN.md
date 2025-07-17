# 📚 IAppPlayer API 参数详细说明文档

[![返回首页](https://img.shields.io/badge/🏠-电视宝应用商店-blue?style=for-the-badge)](https://www.itvapp.net)
[![GitHub](https://img.shields.io/badge/GitHub-项目地址-black?style=for-the-badge&logo=github)](https://github.com/ITVAPP/IAppPlayer)
[![English](https://img.shields.io/badge/📄-English-green?style=for-the-badge)](./API_REFERENCE.md)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

---

## 📋 目录

- [📚 IAppPlayer API 参数详细说明文档](#-iappplayer-api-参数详细说明文档)
  - [🎯 一、createPlayer 方法参数](#-一createplayer-方法参数)
  - [🎮 二、PlayerResult 返回值说明](#-二playerresult-返回值说明)
  - [🎪 三、IAppPlayerEvent 事件类型](#-三iappplayerevent-事件类型)
  - [🎛️ 四、控制器方法说明](#️-四控制器方法说明)
  - [🛠️ 五、工具方法](#️-五工具方法)
  - [🎭 六、解码器类型](#-六解码器类型)
  - [⚙️ 七、播放器配置](#️-七播放器配置)
  - [🎚️ 八、控件配置](#️-八控件配置)
  - [📝 九、字幕配置](#-九字幕配置)
  - [💾 十、数据源配置](#-十数据源配置)
  - [📑 十一、字幕源配置](#-十一字幕源配置)
  - [⚠️ 十二、平台限制与注意事项](#️-十二平台限制与注意事项)

---

## 🎯 一、createPlayer 方法参数

### 🔍 URL格式自动检测规则

播放器会根据URL自动检测视频格式和是否为直播流：

| URL特征 | 检测结果 | 说明 |
|:---:|:---:|:---|
| `.m3u8` | HLS格式，直播流 | HTTP Live Streaming |
| `.mpd` | DASH格式，非直播流 | Dynamic Adaptive Streaming |
| `.flv` | 直播流 | Flash Video |
| `.ism` | SmoothStreaming格式，非直播流 | Microsoft Smooth Streaming |
| `rtmp://` | 直播流 | Real-Time Messaging Protocol |
| `rtmps://` | 直播流 | Secure RTMP |
| `rtsp://` | 直播流 | Real-Time Streaming Protocol |
| `rtsps://` | 直播流 | Secure RTSP |

**注意**：
- 检测结果会被缓存以提高性能（LRU缓存，最大1000条）
- 缓存使用LRU（最近最少使用）策略，当缓存满时会自动删除最旧的条目
- 扩展名检测使用 `lastIndexOf('.')` 优化性能
- 可以通过 `clearAllCaches()` 清除缓存
- 可以通过显式设置 `videoFormat` 和 `liveStream` 参数覆盖自动检测结果

### 🔧 必须参数（二选一）

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `url` | `String?` | 单个视频的URL地址（与urls二选一，必须提供其中一个） |
| `urls` | `List<String>?` | 播放列表的URL数组（与url二选一，必须提供其中一个） |

### 📝 基础参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `eventListener` | `Function(IAppPlayerEvent)?` | `null` | 播放器事件监听器 |
| `title` | `String?` | `null` | 视频标题，同时用作通知栏标题 |
| `titles` | `List<String>?` | `null` | 播放列表标题数组 |
| `imageUrl` | `String?` | `null` | 视频封面图片URL，同时用作通知栏图标 |
| `imageUrls` | `List<String>?` | `null` | 播放列表封面图片URL数组 |
| `author` | `String?` | `null` | 通知栏作者信息（通常为应用名称） |
| `notificationChannelName` | `String?` | `null` | Android通知渠道名称（通常为应用包名） |
| `backgroundImage` | `String?` | `null` | 播放器背景图，支持网络图片（http://或https://开头）和本地资源图片。背景图使用BoxFit.cover缩放模式，错误时返回背景图Widget。本地图片使用gaplessPlayback和FilterQuality.medium优化显示 |

### 📑 字幕参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `subtitleUrl` | `String?` | `null` | 字幕文件URL |
| `subtitleContent` | `String?` | `null` | 字幕内容字符串 |
| `subtitleUrls` | `List<String>?` | `null` | 播放列表字幕URL数组 |
| `subtitleContents` | `List<String>?` | `null` | 播放列表字幕内容数组 |
| `subtitles` | `List<IAppPlayerSubtitlesSource>?` | `null` | 高级字幕配置 |

### ▶️ 播放控制参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `autoPlay` | `bool` | `true` | 是否自动播放。**注意**：播放列表模式下切换视频时会忽略此设置，始终自动播放 |
| `loopVideos` | `bool` | `true` | 播放列表是否循环 |
| `looping` | `bool?` | `null` | 单个视频是否循环播放（null时根据是否为直播流自动设置：非直播流默认true，直播流默认false）。**注意**：播放列表模式下此参数会被强制设置为false |
| `startAt` | `Duration?` | `null` | 起始播放位置 |
| `shuffleMode` | `bool?` | `null` | 是否开启随机播放模式 |
| `nextVideoDelay` | `Duration?` | `null` | 播放列表视频切换延迟时间 |
| `initialStartIndex` | `int?` | `null` | 播放列表起始播放索引 |

### ⚙️ 高级参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `isTV` | `bool` | `false` | 是否为TV模式，TV模式会禁用通知和Logo下载，并且不会创建通知配置 |
| `headers` | `Map<String, String>?` | `null` | HTTP请求头，用于需要认证的视频资源 |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | `null` | 首选解码器类型（硬件/软件/自动） |
| `liveStream` | `bool?` | `null` | 是否为直播流（null时根据[URL格式自动检测](#-url格式自动检测规则)） |
| `audioOnly` | `bool?` | `null` | 是否纯音频模式（便捷参数，也可通过controlsConfiguration设置） |

### 🎥 视频配置参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `videoFormat` | `IAppPlayerVideoFormat?` | `null` | 视频格式（null时根据[URL格式自动检测](#-url格式自动检测规则)） |
| `videoExtension` | `String?` | `null` | 视频扩展名 |
| `dataSourceType` | `IAppPlayerDataSourceType?` | `null` | 数据源类型（network/file/memory） |
| `resolutions` | `Map<String, String>?` | `null` | 分辨率映射表 |
| `overriddenDuration` | `Duration?` | `null` | 覆盖视频时长 |

### 🎨 界面配置参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `placeholder` | `Widget?` | `null` | 视频加载前的占位组件 |
| `errorBuilder` | `Widget Function(BuildContext, String?)?` | `null` | 错误界面构建器 |
| `overlay` | `Widget?` | `null` | 视频上的覆盖组件 |
| `aspectRatio` | `double?` | `null` | 视频宽高比 |
| `fit` | `BoxFit?` | `null` | 视频缩放模式 |
| `rotation` | `double?` | `null` | 视频旋转角度（必须是90的倍数且不超过360度，否则使用默认值0） |
| `showPlaceholderUntilPlay` | `bool?` | `null` | 是否在播放前显示占位符 |
| `placeholderOnTop` | `bool?` | `null` | 占位符是否置于顶层 |

### 🎛️ 配置对象参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `playerConfiguration` | `IAppPlayerConfiguration?` | `null` | 播放器核心配置对象 |
| `controlsConfiguration` | `IAppPlayerControlsConfiguration?` | `null` | 控件配置对象 |
| `subtitlesConfiguration` | `IAppPlayerSubtitlesConfiguration?` | `null` | 字幕配置对象 |
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration?` | `null` | 缓冲配置对象 |
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | `null` | 缓存配置对象 |
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | `null` | 通知配置对象 |
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | `null` | DRM配置对象 |

### 🎚️ 控件功能开关

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `enableSubtitles` | `bool?` | `null` | 启用字幕功能 |
| `enableQualities` | `bool?` | `null` | 启用画质选择 |
| `enableAudioTracks` | `bool?` | `null` | 启用音轨选择 |
| `enableFullscreen` | `bool?` | `null` | 启用全屏功能 |
| `enableOverflowMenu` | `bool?` | `null` | 启用更多菜单 |
| `handleAllGestures` | `bool?` | `null` | 处理所有手势 |
| `showNotification` | `bool?` | `null` | 显示通知栏控制（TV模式下无效） |

### 📱 全屏相关参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `fullScreenByDefault` | `bool?` | `null` | 默认全屏播放 |
| `fullScreenAspectRatio` | `double?` | `null` | 全屏宽高比 |
| `deviceOrientationsOnFullScreen` | `List<DeviceOrientation>?` | `null` | 全屏时设备方向 |
| `deviceOrientationsAfterFullScreen` | `List<DeviceOrientation>?` | `null` | 退出全屏后设备方向 |
| `systemOverlaysAfterFullScreen` | `List<SystemUiOverlay>?` | `null` | 退出全屏后的系统UI |
| `autoDetectFullscreenDeviceOrientation` | `bool?` | `null` | 自动检测全屏设备方向（根据视频宽高比自动选择横屏或竖屏） |
| `autoDetectFullscreenAspectRatio` | `bool?` | `null` | 自动检测全屏宽高比 |

### 🎵 流媒体参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `useAsmsTracks` | `bool?` | `null` | 使用HLS/DASH视频轨道 |
| `useAsmsAudioTracks` | `bool?` | `null` | 使用HLS/DASH音频轨道 |
| `useAsmsSubtitles` | `bool?` | `null` | 使用HLS/DASH内嵌字幕 |

### 🔧 其他参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `handleLifecycle` | `bool?` | `null` | 处理应用生命周期 |
| `autoDispose` | `bool?` | `null` | 自动释放资源 |
| `allowedScreenSleep` | `bool?` | `null` | 允许屏幕休眠 |
| `expandToFill` | `bool?` | `null` | 扩展填充可用空间 |
| `routePageBuilder` | `IAppPlayerRoutePageBuilder?` | `null` | 自定义路由页面构建器 |
| `translations` | `List<IAppPlayerTranslations>?` | `null` | 多语言翻译配置 |
| `useRootNavigator` | `bool?` | `null` | 是否使用根导航器 |
| `playerVisibilityChangedBehavior` | `Function(double)?` | `null` | 播放器可见性变化回调 |

### 📌 播放列表默认值说明

当使用播放列表模式时，如果未提供某些参数，系统会使用以下默认值：

| 场景 | 默认值 | 说明 |
|:---:|:---:|:---|
| 未提供标题 | `视频 1`、`视频 2`... | 自动生成递增的默认标题 |
| 未提供字幕名称 | `字幕` | 默认字幕名称 |
| 通知活动名称 | `MainActivity` | Android默认活动名称 |

**注意**：播放列表使用 `List.generate` 批量创建数据源，确保高效处理大量视频。

### 💡 通知参数使用示例

```dart
// 使用示例：
IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  title: '视频标题',           // 视频标题，同时用作通知栏主标题
  imageUrl: 'cover.jpg',       // 视频封面，同时用作通知栏图标
  author: 'App名称',           // 通知栏副标题（通常是应用名）
  notificationChannelName: 'com.example.app', // Android通知渠道
);
```

---

## 🎮 二、PlayerResult 返回值说明

`PlayerResult` 是 `createPlayer` 方法的返回值，根据播放模式不同包含不同的控制器：

### 🎵 单个视频模式

```dart
final result = IAppPlayerConfig.createPlayer(url: 'video.mp4', ...);
final controller = result.controller;  // 使用 controller
```

### 📺 播放列表模式

```dart
final result = IAppPlayerConfig.createPlayer(urls: [...], ...);
final playlistController = result.playlistController;  // 使用 playlistController
final activeController = result.activeController;      // 获取内部播放器控制器
```

### 🔄 通用获取方式

```dart
final activeController = result.activeController;  // 总是返回当前活动的播放器控制器
```

| 属性 | 类型 | 说明 |
|:---:|:---:|:---|
| `controller` | `IAppPlayerController?` | 单个视频时返回此控制器 |
| `playlistController` | `IAppPlayerPlaylistController?` | 播放列表时返回此控制器 |
| `isPlaylist` | `bool` | 是否为播放列表模式 |
| `activeController` | `IAppPlayerController?` | 获取当前活动的控制器 |

---

## 🎪 三、IAppPlayerEvent 事件类型

### 📡 事件类型枚举

| 事件类型 | 说明 | 参数 |
|:---:|:---|:---|
| `initialized` | 播放器初始化完成 | - |
| `play` | 开始播放 | - |
| `pause` | 暂停播放 | - |
| `seekTo` | 跳转进度 | `{duration: Duration}` |
| `progress` | 播放进度更新（每500毫秒最多触发一次） | `{progress: Duration, duration: Duration}` |
| `finished` | 视频播放完成 | - |
| `exception` | 播放错误 | `{exception: String}` |
| `bufferingStart` | 开始缓冲 | - |
| `bufferingEnd` | 缓冲结束 | - |
| `bufferingUpdate` | 缓冲进度更新 | `{buffered: List<Duration>}` |
| `setVolume` | 音量改变 | `{volume: double}` |
| `setSpeed` | 播放速度改变 | `{speed: double}` |
| `openFullscreen` | 进入全屏 | - |
| `hideFullscreen` | 退出全屏 | - |
| `changedSubtitles` | 字幕切换 | `{subtitlesSource: IAppPlayerSubtitlesSource}` |
| `changedTrack` | 视频轨道切换（HLS多码率） | `{track: IAppPlayerAsmsTrack}` |
| `changedAudioTrack` | 音频轨道切换 | `{audioTrack: IAppPlayerAsmsAudioTrack}` |
| `changedResolution` | 分辨率切换 | `{url: String}` |
| `changedPlayerVisibility` | 播放器可见性改变 | `{visible: bool}` |
| `changedPlaylistItem` | 播放列表项切换 | `{index: int}` |
| `togglePlaylistShuffle` | 触发切换随机模式 | - |
| `changedPlaylistShuffle` | 随机模式已改变 | `{shuffleMode: bool}` |
| `pipStart` | 进入画中画 | - |
| `pipStop` | 退出画中画 | - |
| `setupDataSource` | 设置数据源 | `{dataSource: IAppPlayerDataSource}` |
| `controlsVisible` | 控件显示 | - |
| `controlsHiddenStart` | 控件开始隐藏 | - |
| `controlsHiddenEnd` | 控件隐藏完成 | - |

### 🚨 错误类型分类

播放错误 (`exception` 事件) 常见类型：

| 错误类型 | 说明 | 处理建议 |
|:---:|:---|:---|
| `PlatformException` | 平台相关错误 | 检查设备兼容性 |
| `FormatException` | 视频格式不支持 | 转换视频格式或使用其他源 |
| `NetworkException` | 网络错误（403/404/超时等） | 检查网络连接和URL有效性 |
| `DrmException` | DRM相关错误 | 检查DRM配置和许可证 |
| `UnknownException` | 未知错误 | 查看详细错误信息并重试 |

### 👂 事件监听示例

```dart
eventListener: (IAppPlayerEvent event) {
  switch (event.iappPlayerEventType) {
    case IAppPlayerEventType.progress:
      final progress = event.parameters?['progress'] as Duration?;
      final duration = event.parameters?['duration'] as Duration?;
      print('播放进度: ${progress?.inSeconds}/${duration?.inSeconds}');
      break;
    case IAppPlayerEventType.exception:
      final error = event.parameters?['exception'] as String?;
      print('播放错误: $error');
      // 可以在这里实现重试逻辑
      break;
    case IAppPlayerEventType.bufferingStart:
      print('开始缓冲，可以显示加载动画');
      break;
    case IAppPlayerEventType.bufferingEnd:
      print('缓冲结束，隐藏加载动画');
      break;
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('随机模式: $shuffleMode');
      break;
    case IAppPlayerEventType.changedAudioTrack:
      final audioTrack = event.parameters?['audioTrack'] as IAppPlayerAsmsAudioTrack?;
      print('音频轨道切换: ${audioTrack?.label}');
      break;
  }
}
```

---

## 🎛️ 四、控制器方法说明

### 🎬 IAppPlayerController 主要方法

#### 播放控制

| 方法 | 说明 | 示例 |
|:---:|:---|:---|
| `play()` | 播放 | `controller.play()` |
| `pause()` | 暂停 | `controller.pause()` |
| `seekTo(Duration moment)` | 跳转到指定位置 | `controller.seekTo(Duration(seconds: 30))` |
| `setVolume(double volume)` | 设置音量 (0.0 - 1.0) | `controller.setVolume(0.8)` |
| `setSpeed(double speed)` | 设置播放速度 (大于0且不超过2.0) | `controller.setSpeed(1.5)` |

#### 全屏控制

| 方法 | 说明 |
|:---:|:---|
| `enterFullScreen()` | 进入全屏 |
| `exitFullScreen()` | 退出全屏 |
| `toggleFullScreen()` | 切换全屏状态 |

#### 字幕和轨道

| 方法 | 说明 |
|:---:|:---|
| `setupSubtitleSource(IAppPlayerSubtitlesSource)` | 切换字幕源 |
| `setTrack(IAppPlayerAsmsTrack)` | 设置视频轨道（HLS多码率）。当轨道的高度、宽度、比特率都为0时，会显示为"自动" |
| `setAudioTrack(IAppPlayerAsmsAudioTrack)` | 设置音频轨道 |

#### 高级功能

| 方法 | 说明 |
|:---:|:---|
| `setMixWithOthers(bool)` | 设置是否与其他音频混合播放 |
| `enablePictureInPicture()` | 启用画中画 |
| `disablePictureInPicture()` | 禁用画中画 |
| `setControlsEnabled(bool)` | 启用/禁用控件 |
| `setControlsAlwaysVisible(bool)` | 设置控件始终可见 |
| `retryDataSource()` | 重试当前数据源 |
| `clearCache()` | 清除缓存 |
| `preCache(IAppPlayerDataSource)` | 预缓存视频 |
| `stopPreCache(IAppPlayerDataSource)` | 停止预缓存 |
| `setBufferingDebounceTime(int)` | 设置缓冲状态防抖时间（毫秒） |
| `dispose()` | 释放资源 |

### 📊 属性获取

| 属性/方法 | 返回类型 | 说明 |
|:---:|:---:|:---|
| `isPlaying()` | `bool` | 是否正在播放 |
| `isBuffering()` | `bool` | 是否正在缓冲 |
| `isVideoInitialized()` | `bool` | 视频是否已初始化 |
| `isFullScreen` | `bool` | 是否全屏 |
| `videoPlayerController` | `VideoPlayerController?` | 获取底层视频控制器 |
| `iappPlayerDataSource` | `IAppPlayerDataSource?` | 获取当前数据源 |
| `subtitlesLines` | `List<IAppPlayerSubtitle>` | 获取字幕列表 |
| `renderedSubtitle` | `IAppPlayerSubtitle?` | 获取当前显示的字幕 |
| `iappPlayerAsmsTrack` | `IAppPlayerAsmsTrack?` | 获取当前视频轨道 |
| `iappPlayerAsmsTracks` | `List<IAppPlayerAsmsTrack>` | 获取可用视频轨道列表 |
| `iappPlayerAsmsAudioTrack` | `IAppPlayerAsmsAudioTrack?` | 获取当前音频轨道 |
| `iappPlayerAsmsAudioTracks` | `List<IAppPlayerAsmsAudioTrack>` | 获取可用音频轨道列表 |

### 📜 IAppPlayerPlaylistController 主要方法

| 方法 | 说明 | 示例 |
|:---:|:---|:---|
| `playNext()` | 播放下一个 | `playlistController.playNext()` |
| `playPrevious()` | 播放上一个 | `playlistController.playPrevious()` |
| `setupDataSource(int index)` | 播放指定索引的视频 | `playlistController.setupDataSource(2)` |
| `toggleShuffleMode()` | 切换随机播放模式 | `playlistController.toggleShuffleMode()` |
| `setupDataSourceList(List<IAppPlayerDataSource>)` | 设置新的播放列表 | - |
| `dispose()` | 释放资源（会强制释放内部播放器控制器） | `playlistController.dispose()` |

### 📈 播放列表属性获取

| 属性 | 类型 | 说明 |
|:---:|:---:|:---|
| `currentDataSourceIndex` | `int` | 当前播放索引 |
| `dataSourceList` | `List<IAppPlayerDataSource>` | 获取数据源列表（只读） |
| `hasNext` | `bool` | 是否有下一个 |
| `hasPrevious` | `bool` | 是否有上一个 |
| `shuffleMode` | `bool` | 当前随机模式状态 |
| `iappPlayerController` | `IAppPlayerController?` | 获取内部播放器控制器 |

---

## 🛠️ 五、工具方法

### 🎯 IAppPlayerConfig 静态方法

| 方法 | 说明 | 使用场景 |
|:---:|:---|:---|
| `playSource()` | 简化的播放源切换方法 | 动态切换视频源 |
| `clearAllCaches()` | 清理URL格式检测的LRU缓存（最大1000条）<br>使用LRU策略管理，缓存满时自动删除最旧条目 | 长时间运行后释放内存或强制重新检测URL格式 |
| `createDataSource()` | 创建数据源 | 构建复杂数据源 |
| `createPlayerConfig()` | 创建播放器配置 | 自定义播放器配置 |
| `createPlaylistConfig()` | 创建播放列表配置 | 自定义播放列表配置 |
| `createPlaylistPlayer()` | 创建自定义数据源的播放列表 | 高级播放列表使用 |

### 🔧 playSource 方法参数

```dart
static Future<void> playSource({
  required IAppPlayerController controller,
  required dynamic source,  // 实际必须是 String 类型
  bool? liveStream,
  String? title,              // 视频标题
  String? imageUrl,           // 视频封面
  String? author,             // 通知作者
  String? notificationChannelName,
  bool preloadOnly = false,
  bool isTV = false,
  bool? audioOnly,
  List<IAppPlayerSubtitlesSource>? subtitles,
  String? subtitleUrl,
  String? subtitleContent,
  Map<String, String>? headers,
  IAppPlayerDataSourceType? dataSourceType,
  bool? showNotification,
  IAppPlayerDecoderType? preferredDecoderType,
  IAppPlayerVideoFormat? videoFormat,
  String? videoExtension,
  IAppPlayerBufferingConfiguration? bufferingConfiguration,
  IAppPlayerCacheConfiguration? cacheConfiguration,
  IAppPlayerDrmConfiguration? drmConfiguration,
  Map<String, String>? resolutions,
  bool? useAsmsTracks,
  bool? useAsmsAudioTracks,
  bool? useAsmsSubtitles,
  Duration? overriddenDuration,
  IAppPlayerNotificationConfiguration? notificationConfiguration,
}) async
```

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `controller` | `IAppPlayerController` | 播放器控制器 |
| `source` | `dynamic` (实际必须是String) | 视频源 URL，虽然参数类型是dynamic，但必须传入String类型，否则会抛出ArgumentError |
| `liveStream` | `bool?` | 是否为直播流 |
| `title` | `String?` | 视频标题 |
| `imageUrl` | `String?` | 视频封面URL |
| `author` | `String?` | 作者信息 |
| `notificationChannelName` | `String?` | 通知渠道名 |
| `preloadOnly` | `bool` | 仅预加载不播放（预加载模式只创建简化的数据源） |
| `isTV` | `bool` | 是否TV模式 |
| `audioOnly` | `bool?` | 是否纯音频模式（会更新控制器配置） |
| `subtitles/subtitleUrl/subtitleContent` | - | 字幕参数 |
| `headers` | `Map<String, String>?` | HTTP请求头 |
| `dataSourceType` | `IAppPlayerDataSourceType?` | 数据源类型 |
| `showNotification` | `bool?` | 是否显示通知 |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | 解码器类型 |
| `videoFormat` | `IAppPlayerVideoFormat?` | 视频格式 |
| `videoExtension` | `String?` | 视频扩展名 |
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration?` | 缓冲配置 |
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | 缓存配置 |
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | DRM配置 |
| `resolutions` | `Map<String, String>?` | 分辨率映射 |
| `useAsmsTracks` | `bool?` | 使用HLS轨道 |
| `useAsmsAudioTracks` | `bool?` | 使用音频轨道 |
| `useAsmsSubtitles` | `bool?` | 使用内嵌字幕 |
| `overriddenDuration` | `Duration?` | 覆盖时长 |
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | 通知配置 |

#### 使用示例

```dart
// 切换视频源
await IAppPlayerConfig.playSource(
  controller: player.activeController!,
  source: 'https://example.com/new_video.mp4',  // 必须是String
  title: '新视频标题',
  imageUrl: 'https://example.com/cover.jpg',
  author: '应用名称',
  notificationChannelName: 'com.example.app',
);
```

### 🎯 createDataSource 方法参数

```dart
static IAppPlayerDataSource createDataSource({
  required String url,
  bool? liveStream,
  Map<String, String>? headers,
  String? title,              // 视频标题
  String? imageUrl,           // 视频封面
  String? author,
  String? notificationChannelName,
  bool isTV = false,
  IAppPlayerDecoderType? preferredDecoderType,
  List<IAppPlayerSubtitlesSource>? subtitles,
  String? subtitleUrl,
  String? subtitleContent,
  IAppPlayerVideoFormat? videoFormat,
  String? videoExtension,
  IAppPlayerBufferingConfiguration? bufferingConfiguration,
  IAppPlayerCacheConfiguration? cacheConfiguration,
  IAppPlayerNotificationConfiguration? notificationConfiguration,
  IAppPlayerDrmConfiguration? drmConfiguration,
  Map<String, String>? resolutions,
  bool? useAsmsTracks,
  bool? useAsmsAudioTracks,
  bool? useAsmsSubtitles,
  Duration? overriddenDuration,
  IAppPlayerDataSourceType? dataSourceType,
  bool? showNotification,
})
```

### 🎮 createPlayerConfig 方法参数

```dart
static IAppPlayerConfiguration createPlayerConfig({
  required bool liveStream,
  required Function(IAppPlayerEvent) eventListener,
  bool autoPlay = true,
  bool? audioOnly,
  Widget? placeholder,
  Widget Function(BuildContext, String?)? errorBuilder,
  String? backgroundImage,
  Widget? overlay,
  double? aspectRatio,
  BoxFit? fit,
  double? rotation,
  IAppPlayerControlsConfiguration? controlsConfiguration,
  IAppPlayerSubtitlesConfiguration? subtitlesConfiguration,
  bool? enableSubtitles,
  bool? enableQualities,
  bool? enableAudioTracks,
  bool? enableFullscreen,
  bool? enableOverflowMenu,
  bool? handleAllGestures,
  bool? fullScreenByDefault,
  double? fullScreenAspectRatio,
  List<DeviceOrientation>? deviceOrientationsOnFullScreen,
  List<DeviceOrientation>? deviceOrientationsAfterFullScreen,
  bool? handleLifecycle,
  bool? autoDispose,
  bool? looping,
  Duration? startAt,
  bool? allowedScreenSleep,
  bool? expandToFill,
  bool? showPlaceholderUntilPlay,
  bool? placeholderOnTop,
  List<SystemUiOverlay>? systemOverlaysAfterFullScreen,
  IAppPlayerRoutePageBuilder? routePageBuilder,
  List<IAppPlayerTranslations>? translations,
  bool? autoDetectFullscreenDeviceOrientation,
  bool? autoDetectFullscreenAspectRatio,
  bool? useRootNavigator,
  Function(double)? playerVisibilityChangedBehavior,
})
```

**注意**：`createPlayerConfig` 会根据 `audioOnly` 参数动态构建控件配置，如果提供了 `audioOnly` 参数，会自动创建或更新 `controlsConfiguration`。

### 📋 createPlaylistConfig 方法参数

```dart
static IAppPlayerPlaylistConfiguration createPlaylistConfig({
  bool shuffleMode = false,
  bool loopVideos = true,
  Duration nextVideoDelay = defaultNextVideoDelay,
  int initialStartIndex = 0,
})
```

### 🎵 createPlaylistPlayer 方法参数

```dart
static PlayerResult createPlaylistPlayer({
  required Function(IAppPlayerEvent) eventListener,
  required List<IAppPlayerDataSource> dataSources,
  bool shuffleMode = false,
  bool loopVideos = true,
  Duration nextVideoDelay = defaultNextVideoDelay,
  int initialStartIndex = 0,
  IAppPlayerConfiguration? playerConfiguration,
})
```

### 🔧 常量定义

| 常量 | 值 | 说明 |
|:---:|:---:|:---|
| `defaultNextVideoDelay` | `Duration(seconds: 1)` | IAppPlayerConfig中的默认播放列表切换延迟时间 |

### 📌 内部常量说明

播放器内部使用的默认常量值：

| 常量 | 值 | 说明 |
|:---:|:---:|:---|
| 预缓存大小 | 10MB (10 * 1024 * 1024 字节) | 默认预缓存大小 |
| 最大缓存 | 300MB (300 * 1024 * 1024 字节) | 默认最大缓存大小 |
| 单文件最大缓存 | 50MB (50 * 1024 * 1024 字节) | 单个文件最大缓存大小 |
| 直播最小缓冲 | 15秒 | 直播流最小缓冲时间 |
| 直播最大缓冲 | 15秒 | 直播流最大缓冲时间 |
| 点播最小缓冲 | 20秒 | 点播流最小缓冲时间 |
| 点播最大缓冲 | 30秒 | 点播流最大缓冲时间 |
| 播放缓冲 | 3秒 | 开始播放所需缓冲时间 |
| 重新缓冲后播放 | 5秒 | 重新缓冲后播放所需时间 |
| URL缓存容量 | 1000条 | URL格式检测缓存最大条目数（LRU策略） |
| 默认视频标题前缀 | `视频 ` | 播放列表默认标题前缀 |
| 默认字幕名称 | `字幕` | 默认字幕名称 |
| 默认活动名称 | `MainActivity` | Android默认活动名称 |
| 默认图片缩放模式 | BoxFit.cover | 背景图片默认缩放模式 |
| 默认图片质量 | FilterQuality.medium | 本地图片默认渲染质量 |
| 默认旋转角度 | 0 | 视频默认旋转角度 |
| 缓冲防抖时间 | 500毫秒 | 缓冲状态变化的默认防抖时间 |
| 播放列表切换延迟（IAppPlayerPlaylistConfiguration） | 3秒 | 使用IAppPlayerPlaylistConfiguration时的默认切换延迟 |
| 音频控件隐藏时间 | 不隐藏 | 音频控件始终保持可见 |
| 进度事件节流 | 500毫秒 | Progress事件最小触发间隔 |
| 音频扩展布局阈值 | 200px | 高度超过此值时显示扩展布局 |
| 字幕段检查间隔 | 1秒 | ASMS字幕段位置检查的最小间隔 |

---

## 🎭 六、解码器类型

### 🎨 IAppPlayerDecoderType 选项

| 类型 | 说明 | 适用场景 |
|:---:|:---|:---|
| `auto` | 自动选择解码器 | 系统自动决定最佳解码器 |
| `hardwareFirst` | 优先使用硬件解码，失败后自动切换到软件解码 | 推荐，性能最佳 |
| `softwareFirst` | 优先使用软件解码，失败后自动切换到硬件解码 | 特定设备兼容性问题 |

### 💡 使用建议

```dart
// 一般情况（推荐硬件解码）
preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,

// 软件解码优先
preferredDecoderType: IAppPlayerDecoderType.softwareFirst,

// 自动选择
preferredDecoderType: IAppPlayerDecoderType.auto,
```

---

## ⚙️ 七、播放器配置

**注意**：以下默认值基于 `IAppPlayerConfiguration` 类的定义。使用 `createPlayerConfig()` 方法创建配置时，部分参数会根据 `liveStream` 等参数动态设置。

### 🎮 播放行为参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `autoPlay` | `bool` | `false` | 是否自动播放。**注意**：播放列表模式下切换视频时会忽略此设置，始终自动播放 |
| `startAt` | `Duration?` | `null` | 视频起始播放位置 |
| `looping` | `bool` | `false` | 是否单个视频循环播放。**注意**：<br>1. 这是基础默认值，使用 `createPlayerConfig()` 时会根据 `liveStream` 参数动态设置（非直播流默认true，直播流默认false）<br>2. 播放列表模式下此参数会被强制设置为false |
| `handleLifecycle` | `bool` | `true` | 是否自动处理应用生命周期（后台暂停等） |
| `autoDispose` | `bool` | `true` | 是否自动释放资源 |
| `showControlsOnInitialize` | `bool` | `true` | 初始化时是否显示控件 |

### 🎨 显示参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `aspectRatio` | `double?` | `null` | 视频宽高比，null表示自适应 |
| `fit` | `BoxFit` | `BoxFit.fill` | 视频缩放模式 |
| `rotation` | `double` | `0` | 视频旋转角度（必须是90的倍数且不超过360度） |
| `expandToFill` | `bool` | `true` | 是否扩展填充所有可用空间 |

#### BoxFit 缩放模式说明

| 模式 | 说明 |
|:---:|:---|
| `BoxFit.fill` | 填充整个容器，可能变形 |
| `BoxFit.contain` | 保持宽高比，完整显示 |
| `BoxFit.cover` | 保持宽高比，覆盖整个容器 |
| `BoxFit.fitWidth` | 宽度适应 |
| `BoxFit.fitHeight` | 高度适应 |
| `BoxFit.none` | 原始大小 |
| `BoxFit.scaleDown` | 缩小适应 |

### 🖼️ 占位图参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `placeholder` | `Widget?` | `null` | 视频加载前的占位组件 |
| `showPlaceholderUntilPlay` | `bool` | `false` | 是否在播放前一直显示占位图 |
| `placeholderOnTop` | `bool` | `true` | 占位图是否在视频层上方 |

### 📱 全屏参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `fullScreenByDefault` | `bool` | `false` | 是否默认全屏播放 |
| `allowedScreenSleep` | `bool` | `true` | 全屏时是否允许屏幕休眠 |
| `fullScreenAspectRatio` | `double?` | `null` | 全屏时的宽高比 |
| `autoDetectFullscreenDeviceOrientation` | `bool` | `false` | 是否自动检测全屏方向（根据视频宽高比自动选择横屏或竖屏） |
| `autoDetectFullscreenAspectRatio` | `bool` | `false` | 是否自动检测全屏宽高比 |
| `deviceOrientationsOnFullScreen` | `List<DeviceOrientation>` | `[landscapeLeft, landscapeRight]` | 全屏时允许的设备方向 |
| `deviceOrientationsAfterFullScreen` | `List<DeviceOrientation>` | `[landscapeLeft, landscapeRight, portraitUp]` | 退出全屏后的设备方向 |
| `systemOverlaysAfterFullScreen` | `List<SystemUiOverlay>` | `SystemUiOverlay.values` | 退出全屏后的系统UI（显示所有系统UI） |
| `fullscreenOrientationLocker` | `Function?` | `null` | 自定义全屏方向锁定逻辑 |

### 🎯 其他参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `overlay` | `Widget?` | `null` | 视频上的覆盖组件 |
| `errorBuilder` | `Function?` | `null` | 错误时的自定义组件构建器（使用backgroundImage时会默认返回背景图Widget） |
| `eventListener` | `Function?` | `null` | 事件监听器 |
| `routePageBuilder` | `Function?` | `null` | 自定义全屏页面路由构建器 |
| `translations` | `List<IAppPlayerTranslations>?` | `null` | 多语言翻译配置 |
| `playerVisibilityChangedBehavior` | `Function?` | `null` | 播放器可见性变化回调 |
| `subtitlesConfiguration` | `IAppPlayerSubtitlesConfiguration` | - | 字幕配置 |
| `controlsConfiguration` | `IAppPlayerControlsConfiguration` | - | 控件配置 |
继续 API_REFERENCE_CN.md 的剩余部分：

```markdown
| `useRootNavigator` | `bool` | `false` | 是否使用根导航器 |

### 🌐 多语言配置

`IAppPlayerTranslations` 结构：

```dart
class IAppPlayerTranslations {
  final String languageCode;           // 语言代码（如：zh, en, ja）
  final String generalDefaultError;    // 默认错误信息
  final String generalNone;            // "无"选项文本
  final String generalDefault;         // "默认"文本
  final String generalRetry;           // "重试"按钮文本
  final String playlistLoadingNextVideo; // 加载下一个视频提示
  final String playlistUnavailable;    // 播放列表不可用提示
  final String playlistTitle;          // 播放列表标题
  final String videoItem;              // 视频项目格式（包含{index}占位符）
  final String trackItem;              // 音轨项目格式（包含{index}占位符）
  final String controlsLive;           // "直播"标识文本
  final String controlsNextIn;         // 下一个视频倒计时文本
  final String overflowMenuPlaybackSpeed; // 播放速度菜单文本
  final String overflowMenuSubtitles;  // 字幕菜单文本
  final String overflowMenuQuality;    // 画质菜单文本
  final String overflowMenuAudioTracks; // 音轨菜单文本
  final String qualityAuto;            // 自动画质文本
}
```

### 🗣️ 支持的语言

IAppPlayer 支持以下语言的预设翻译：

| 语言代码 | 语言名称 | 使用方法 |
|:---:|:---|:---|
| `zh` | 中文简体 | `IAppPlayerTranslations.chinese()` |
| `zh-Hant` | 中文繁体 | `IAppPlayerTranslations.traditionalChinese()` |
| `en` | 英语 | `IAppPlayerTranslations()` (默认) |
| `pl` | 波兰语 | `IAppPlayerTranslations.polish()` |
| `hi` | 印地语 | `IAppPlayerTranslations.hindi()` |
| `ar` | 阿拉伯语 | `IAppPlayerTranslations.arabic()` |
| `tr` | 土耳其语 | `IAppPlayerTranslations.turkish()` |
| `vi` | 越南语 | `IAppPlayerTranslations.vietnamese()` |
| `es` | 西班牙语 | `IAppPlayerTranslations.spanish()` |
| `pt` | 葡萄牙语 | `IAppPlayerTranslations.portuguese()` |
| `bn` | 孟加拉语 | `IAppPlayerTranslations.bengali()` |
| `ru` | 俄语 | `IAppPlayerTranslations.russian()` |
| `ja` | 日语 | `IAppPlayerTranslations.japanese()` |
| `fr` | 法语 | `IAppPlayerTranslations.french()` |
| `de` | 德语 | `IAppPlayerTranslations.german()` |
| `id` | 印尼语 | `IAppPlayerTranslations.indonesian()` |
| `ko` | 韩语 | `IAppPlayerTranslations.korean()` |
| `it` | 意大利语 | `IAppPlayerTranslations.italian()` |

使用示例：

```dart
// 使用中文简体
translations: [
  IAppPlayerTranslations.chinese(),
],

// 使用多种语言（系统会根据设备语言自动选择）
translations: [
  IAppPlayerTranslations.chinese(),
  IAppPlayerTranslations.english(),
  IAppPlayerTranslations.japanese(),
],

// 自定义翻译
translations: [
  IAppPlayerTranslations(
    languageCode: 'zh',
    generalDefaultError: '无法播放视频',
    generalNone: '无',
    generalDefault: '默认',
    generalRetry: '重试',
    playlistLoadingNextVideo: '正在加载下一个视频',
    playlistUnavailable: '播放列表不可用',
    playlistTitle: '播放列表',
    videoItem: '视频 {index}',
    trackItem: '音轨 {index}',
    controlsLive: '直播',
    controlsNextIn: '下一个视频',
    overflowMenuPlaybackSpeed: '播放速度',
    overflowMenuSubtitles: '字幕',
    overflowMenuQuality: '画质',
    overflowMenuAudioTracks: '音轨',
    qualityAuto: '自动',
  ),
],
```

---

## 🎚️ 八、控件配置

### 🎨 颜色配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `controlBarColor` | `Color` | `Colors.transparent` | 控制栏背景色 |
| `textColor` | `Color` | `Colors.white` | 文本颜色 |
| `iconsColor` | `Color` | `Colors.white` | 图标颜色 |
| `liveTextColor` | `Color` | `Colors.red` | 直播标识文本颜色 |
| `backgroundColor` | `Color` | `Colors.black` | 无视频时的背景色 |
| `loadingColor` | `Color` | `Colors.white` | 加载指示器颜色 |

### 📊 进度条颜色

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `progressBarPlayedColor` | `Color` | `Color(0xFFFF0000)` | 已播放部分颜色 |
| `progressBarHandleColor` | `Color` | `Color(0xFFFF0000)` | 拖动手柄颜色 |
| `progressBarBufferedColor` | `Color` | `Color.fromRGBO(255, 255, 255, 0.3)` | 缓冲部分颜色 |
| `progressBarBackgroundColor` | `Color` | `Color.fromRGBO(255, 255, 255, 0.2)` | 背景颜色 |

### 🎯 图标配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `playIcon` | `IconData` | `Icons.play_arrow_outlined` | 播放图标 |
| `pauseIcon` | `IconData` | `Icons.pause_outlined` | 暂停图标 |
| `muteIcon` | `IconData` | `Icons.volume_up_outlined` | 静音图标 |
| `unMuteIcon` | `IconData` | `Icons.volume_off_outlined` | 取消静音图标 |
| `fullscreenEnableIcon` | `IconData` | `Icons.fullscreen_outlined` | 进入全屏图标 |
| `fullscreenDisableIcon` | `IconData` | `Icons.fullscreen_exit_outlined` | 退出全屏图标 |
| `skipBackIcon` | `IconData` | `Icons.replay_10_outlined` | 后退图标 |
| `skipForwardIcon` | `IconData` | `Icons.forward_10_outlined` | 前进图标 |

### 🔧 功能开关

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `showControls` | `bool` | `true` | 是否显示控件 |
| `showControlsOnInitialize` | `bool` | `true` | 初始化时是否显示控件 |
| `enableFullscreen` | `bool` | `true` | 启用全屏功能 |
| `enableMute` | `bool` | `true` | 启用静音功能 |
| `enableProgressText` | `bool` | `true` | 显示进度时间文本 |
| `enableProgressBar` | `bool` | `true` | 显示进度条 |
| `enableProgressBarDrag` | `bool` | `true` | 允许拖动进度条 |
| `enablePlayPause` | `bool` | `true` | 启用播放/暂停按钮 |
| `enableSkips` | `bool` | `true` | 启用快进/快退功能 |
| `enableAudioTracks` | `bool` | `true` | 启用音轨选择 |
| `enableSubtitles` | `bool` | `true` | 启用字幕功能 |
| `enableQualities` | `bool` | `true` | 启用画质选择 |
| `enablePip` | `bool` | `true` | 启用画中画 |
| `enableRetry` | `bool` | `true` | 启用重试功能 |
| `enableOverflowMenu` | `bool` | `true` | 启用溢出菜单 |
| `enablePlaybackSpeed` | `bool` | `true` | 启用播放速度调节 |

### 📱 菜单图标

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `overflowMenuIcon` | `IconData` | `Icons.more_vert_outlined` | 溢出菜单图标 |
| `pipMenuIcon` | `IconData` | `Icons.picture_in_picture_outlined` | 画中画图标 |
| `playbackSpeedIcon` | `IconData` | `Icons.shutter_speed_outlined` | 速度调节图标 |
| `qualitiesIcon` | `IconData` | `Icons.hd_outlined` | 画质选择图标 |
| `subtitlesIcon` | `IconData` | `Icons.closed_caption_outlined` | 字幕图标 |
| `audioTracksIcon` | `IconData` | `Icons.audiotrack_outlined` | 音轨图标 |

### 📋 溢出菜单

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `overflowMenuCustomItems` | `List<IAppPlayerOverflowMenuItem>` | `[]` | 自定义菜单项 |
| `overflowModalColor` | `Color` | `Colors.white` | 菜单背景色 |
| `overflowModalTextColor` | `Color` | `Colors.black` | 菜单文本颜色 |
| `overflowMenuIconsColor` | `Color` | `Colors.black` | 菜单图标颜色 |

#### IAppPlayerOverflowMenuItem 完整属性

```dart
class IAppPlayerOverflowMenuItem {
  final String title;           // 菜单项标题
  final IconData icon;         // 菜单项图标
  final Function() onClicked;  // 点击回调（注意：属性名是onClicked不是onTap）
  final bool Function()? isEnabled;  // 可选：控制是否启用
  
  IAppPlayerOverflowMenuItem(
    this.icon,
    this.title,
    this.onClicked,
  );
}
```

#### 自定义菜单项示例

```dart
overflowMenuCustomItems: [
  IAppPlayerOverflowMenuItem(
    Icons.share,
    '分享',
    () {
      // 执行分享逻辑
    },
  ),
  IAppPlayerOverflowMenuItem(
    Icons.download,
    '下载',
    () {
      // 执行下载逻辑
    },
  ),
],
```

### ⚙️ 其他配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `controlsHideTime` | `Duration` | `Duration(milliseconds: 1000)` | 控件自动隐藏时间（注意：音频控件不会自动隐藏） |
| `controlBarHeight` | `double` | `30.0` | 控制栏高度 |
| `forwardSkipTimeInMilliseconds` | `int` | `10000` | 快进时间（毫秒） |
| `backwardSkipTimeInMilliseconds` | `int` | `10000` | 快退时间（毫秒） |
| `loadingWidget` | `Widget?` | `null` | 自定义加载组件 |
| `audioOnly` | `bool` | `false` | 纯音频模式（隐藏视频显示音频控件）。音频控件在高度超过200px时会显示扩展布局（包含封面和标题） |
| `handleAllGestures` | `bool` | `true` | 播放器不拦截手势，让事件能传递到外部 |
| `customControlsBuilder` | `Function?` | `null` | 自定义控件构建器 |
| `playerTheme` | `IAppPlayerTheme?` | `null` | 播放器主题 |

### 🎨 播放器主题

`IAppPlayerTheme` 枚举值：

| 主题 | 说明 | 效果 |
|:---:|:---|:---|
| `video` | 视频风格（默认） | 为视频设计的控件 |
| `audio` | 音频风格 | 为音频设计的控件 |
| `custom` | 自定义控件 | 使用 customControlsBuilder 构建 |

### 🎵 音频模式配置

纯音频模式配置说明：

```dart
// 音频模式会显示一个音频可视化界面而不是视频
controlsConfiguration: IAppPlayerControlsConfiguration(
  audioOnly: true,  // 启用纯音频模式
  // 音频模式下建议配置
  enableFullscreen: false,  // 音频模式通常不需要全屏
  showControls: true,
  enableProgressBar: true,
  enablePlayPause: true,
  enableSkips: true,
  enablePlaybackSpeed: true,
  // 可以自定义音频封面
  placeholder: Image.asset('assets/audio_cover.png'),
),
```

---

## 📝 九、字幕配置

### 🎨 字体配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `fontSize` | `double` | `14` | 字幕字体大小 |
| `fontFamily` | `String` | `"Roboto"` | 字幕字体 |
| `fontColor` | `Color` | `Colors.white` | 字幕文字颜色 |
| `fontWeight` | `FontWeight?` | `null` | 字体粗细 |
| `letterSpacing` | `double?` | `null` | 字母间距 |
| `height` | `double?` | `null` | 行高 |

### 🖋️ 描边配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `outlineEnabled` | `bool` | `true` | 是否启用文字描边 |
| `outlineColor` | `Color` | `Colors.black` | 描边颜色 |
| `outlineSize` | `double` | `2.0` | 描边粗细 |

### 📏 边距配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `leftPadding` | `double` | `8.0` | 左边距 |
| `rightPadding` | `double` | `8.0` | 右边距 |
| `bottomPadding` | `double` | `20.0` | 底部边距 |

### 🎯 样式配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `alignment` | `Alignment` | `Alignment.center` | 字幕对齐方式 |
| `backgroundColor` | `Color` | `Colors.transparent` | 字幕背景色 |
| `textShadows` | `List<Shadow>?` | `null` | 文字阴影效果 |
| `textDecoration` | `TextDecoration?` | `null` | 文字装饰（下划线等） |

### 📝 支持的字幕格式

| 格式 | 说明 | 示例 |
|:---:|:---|:---|
| `SRT` | SubRip字幕格式 | `.srt` 文件 |
| `WEBVTT` | Web视频文本轨道 | `.vtt` 文件，支持HTML标签 |
| `LRC` | 歌词格式 | `.lrc` 文件，适合音乐播放 |
| `HLS字幕` | HLS流内嵌字幕 | 自动检测 |
| `DASH字幕` | DASH流内嵌字幕 | 自动检测 |

---

## 💾 十、数据源配置

### 🎯 基础参数

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `type` | `IAppPlayerDataSourceType` | 数据源类型（network/file/memory） |
| `url` | `String` | 视频URL或文件路径（需要trim处理，不能为空） |
| `bytes` | `List<int>?` | 内存数据源的字节数组 |

#### 数据源类型说明

| 类型 | 说明 | 使用场景 |
|:---:|:---|:---|
| `network` | 网络视频 | 在线视频播放 |
| `file` | 本地文件 | 已下载的视频 |
| `memory` | 内存数据 | 加密视频或动态生成。**注意**：内存数据源会创建临时文件，在dispose或切换数据源时自动清理 |

### 📺 视频格式

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `videoFormat` | `IAppPlayerVideoFormat?` | 视频格式（hls/dash/ss/other） |
| `videoExtension` | `String?` | 视频扩展名 |
| `liveStream` | `bool?` | 是否为直播流 |

#### 视频格式说明

| 格式 | 说明 | 文件扩展名 |
|:---:|:---|:---|
| `hls` | HTTP Live Streaming | `.m3u8` |
| `dash` | Dynamic Adaptive Streaming | `.mpd` |
| `ss` | Smooth Streaming | `.ism/manifest` |
| `other` | 其他格式 | `.mp4`, `.webm`, `.mkv` 等 |

#### 支持的视频格式列表

| 平台 | 支持格式 |
|:---:|:---|
| **Android** | MP4, WebM, MKV, MP3, AAC, HLS(.m3u8), DASH(.mpd), SmoothStreaming, FLV, AVI, MOV, TS |
| **iOS** | MP4, M4V, MOV, MP3, HLS(.m3u8), AAC |
| **Web** | 取决于浏览器（通常支持 MP4, WebM, HLS） |

### 📑 字幕配置

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `subtitles` | `List<IAppPlayerSubtitlesSource>?` | 字幕源列表（通过专门的创建方法构建） |
| `useAsmsSubtitles` | `bool` | 是否使用HLS/DASH内嵌字幕 |

### 🎵 音视频轨道（ASMS）

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `useAsmsTracks` | `bool` | 是否使用HLS轨道（默认根据liveStream自动设置） |
| `useAsmsAudioTracks` | `bool` | 是否使用HLS/DASH音轨（默认根据liveStream自动设置） |
| `asmsTrackNames` | `List<String>?` | 自定义轨道名称 |

#### ASMS（自适应流媒体源）说明

ASMS 指的是 Adaptive Streaming Media Sources，包括：
- HLS 多码率视频轨道
- DASH 多码率视频轨道
- 多语言音频轨道
- 内嵌字幕轨道

#### IAppPlayerAsmsTrack 属性

| 属性 | 类型 | 说明 |
|:---:|:---:|:---|
| `id` | `String?` | 轨道ID |
| `width` | `int?` | 视频宽度 |
| `height` | `int?` | 视频高度 |
| `bitrate` | `int?` | 比特率 |
| `frameRate` | `int?` | 帧率 |
| `codecs` | `String?` | 编码格式 |
| `mimeType` | `String?` | MIME类型 |

#### IAppPlayerAsmsAudioTrack 属性

| 属性 | 类型 | 说明 |
|:---:|:---:|:---|
| `id` | `String?` | 音轨ID |
| `label` | `String?` | 音轨标签/名称 |
| `language` | `String?` | 音轨语言 |

### 🌐 网络配置

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `headers` | `Map<String, String>?` | HTTP请求头 |
| `overriddenDuration` | `Duration?` | 覆盖视频时长 |

#### 请求头示例

```dart
headers: {
  'Authorization': 'Bearer token',
  'User-Agent': 'MyApp/1.0',
  'Referer': 'https://myapp.com',
}
```

### 🎬 画质配置

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `resolutions` | `Map<String, String>?` | 多分辨率URL映射 |

#### 分辨率配置示例

```dart
resolutions: {
  "360p": "https://example.com/video_360p.mp4",
  "720p": "https://example.com/video_720p.mp4",
  "1080p": "https://example.com/video_1080p.mp4",
  "自动": "auto",  // 特殊值，表示自动选择
}
```

### 💾 缓存配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | `null` | 缓存配置对象 |

#### IAppPlayerCacheConfiguration 参数

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `useCache` | `bool` | 根据流类型 | 是否启用缓存。默认值根据 `liveStream` 自动设置：<br>• 非直播流：`true`<br>• 直播流：`false` |
| `preCacheSize` | `int` | 见[内部常量](#-内部常量说明) | 预缓存大小（默认10MB） |
| `maxCacheSize` | `int` | 见[内部常量](#-内部常量说明) | 最大缓存大小（默认300MB） |
| `maxCacheFileSize` | `int` | 见[内部常量](#-内部常量说明) | 单个文件最大缓存大小（默认50MB） |
| `key` | `String?` | `null` | 缓存键，用于区分不同视频 |

#### 缓存 Key 命名规范

```dart
// 推荐的缓存 key 命名规范
// 格式：[应用名]_[类型]_[唯一标识]_[版本]
cacheConfiguration: IAppPlayerCacheConfiguration(
  useCache: true,
  key: 'myapp_video_${videoId}_v1',
  // 或使用 URL 的 MD5
  // key: md5.convert(utf8.encode(videoUrl)).toString(),
),

// 实际示例
// 电影：myapp_movie_tt0111161_v1
// 剧集：myapp_series_s01e01_12345_v1  
// 直播：不使用缓存
// 用户视频：myapp_user_${userId}_${videoId}_v1
```

### 🔔 通知配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | `null` | 通知配置（TV模式下不会创建） |

#### IAppPlayerNotificationConfiguration 结构

通知配置对象，用于控制播放器通知栏的显示。参数说明请参考 [基础参数](#-基础参数) 部分。

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `showNotification` | `bool` | `false` | 是否显示通知（非TV模式默认true） |
| `activityName` | `String?` | `"MainActivity"` | Android Activity名称 |

**注意**：
- `title`、`author`、`imageUrl`、`notificationChannelName` 参数与 createPlayer 的基础参数相同
- TV模式下不会创建通知配置，即使设置了相关参数

### 🔐 DRM配置

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | DRM保护配置 |

#### IAppPlayerDrmConfiguration 参数

| 参数 | 类型 | 说明 | 平台 |
|:---:|:---:|:---|:---|
| `drmType` | `IAppPlayerDrmType?` | DRM类型 | 通用 |
| `token` | `String?` | DRM令牌 | 通用 |
| `licenseUrl` | `String?` | 许可证URL | 通用 |
| `certificateUrl` | `String?` | 证书URL | iOS (FairPlay) |
| `headers` | `Map<String, String>?` | DRM请求头 | 通用 |
| `clearKey` | `String?` | ClearKey配置（JSON字符串） | Android |

#### DRM类型说明

| 类型 | 说明 | 支持平台 |
|:---:|:---|:---|
| `widevine` | Google Widevine | Android |
| `fairplay` | Apple FairPlay | iOS |
| `clearkey` | W3C ClearKey | Android |
| `token` | 基于令牌的DRM | 通用 |

#### DRM 配置完整示例

```dart
// Widevine DRM (Android)
drmConfiguration: IAppPlayerDrmConfiguration(
  drmType: IAppPlayerDrmType.widevine,
  licenseUrl: 'https://widevine-license.server.com/license',
  headers: {
    'Authorization': 'Bearer token',
    'Content-Type': 'application/octet-stream',
  },
),

// FairPlay DRM (iOS)
drmConfiguration: IAppPlayerDrmConfiguration(
  drmType: IAppPlayerDrmType.fairplay,
  certificateUrl: 'https://fairplay.server.com/certificate',
  licenseUrl: 'https://fairplay.server.com/license',
  headers: {
    'Authorization': 'Bearer token',
  },
),

// ClearKey DRM (Android) - 注意clearKey是String类型的JSON
drmConfiguration: IAppPlayerDrmConfiguration(
  drmType: IAppPlayerDrmType.clearkey,
  clearKey: '{"keys":[{"kty":"oct","k":"GawgguFyGrWKav7AX4VKUg","kid":"nrQFDeRLSAKTLifXUIPiZg"}]}',
),
```

### ⏸️ 缓冲配置

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration` | 缓冲配置（如果未提供会根据liveStream自动创建） |

#### IAppPlayerBufferingConfiguration 参数

| 参数 | 类型 | 默认值 | 说明 | 平台 |
|:---:|:---:|:---:|:---|:---|
| `minBufferMs` | `int?` | 见[内部常量](#-内部常量说明) | 最小缓冲时间（毫秒）<br>直播流：15秒<br>点播流：20秒 | Android |
| `maxBufferMs` | `int?` | 见[内部常量](#-内部常量说明) | 最大缓冲时间（毫秒）<br>直播流：15秒<br>点播流：30秒 | Android |
| `bufferForPlaybackMs` | `int?` | 见[内部常量](#-内部常量说明) | 播放所需缓冲时间（默认3秒） | Android |
| `bufferForPlaybackAfterRebufferMs` | `int?` | 见[内部常量](#-内部常量说明) | 重新缓冲后播放所需时间（默认5秒） | Android |

**注意**：如果不提供缓冲配置，系统会根据是否是直播流自动创建合适的默认配置。

### 🎯 其他配置

| 参数 | 类型 | 说明 |
|:---:|:---:|:---|
| `placeholder` | `Widget?` | 视频占位组件 |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | 首选解码器类型（默认hardwareFirst） |

---

## 📑 十一、字幕源配置

| 参数 | 类型 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| `type` | `IAppPlayerSubtitlesSourceType` | - | 字幕源类型 |
| `name` | `String` | `"Default subtitles"` | 字幕名称（用于多语言选择） |
| `urls` | `List<String>?` | `null` | 字幕文件URL列表 |
| `content` | `String?` | `null` | 字幕内容字符串 |
| `selectedByDefault` | `bool?` | `null` | 是否默认选中 |
| `headers` | `Map<String, String>?` | `null` | HTTP请求头（网络字幕） |
| `asmsIsSegmented` | `bool?` | `null` | 是否为分段字幕（HLS） |
| `asmsSegmentsTime` | `int?` | `null` | 分段时间间隔（毫秒） |
| `asmsSegments` | `List<IAppPlayerAsmsSubtitleSegment>?` | `null` | 字幕分段列表 |

### 字幕源类型

| 类型 | 说明 | 使用方式 |
|:---:|:---|:---|
| `file` | 本地文件 | 提供文件路径 |
| `network` | 网络URL | 提供HTTP/HTTPS URL |
| `memory` | 内存字符串 | 直接提供字幕内容 |
| `none` | 无字幕 | 关闭字幕选项 |

### 多语言字幕示例

```dart
subtitles: [
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.network,
    name: "中文",
    urls: ["https://example.com/chinese.srt"],
    selectedByDefault: true,
  ),
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.network,
    name: "English",
    urls: ["https://example.com/english.srt"],
  ),
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.none,
    name: "关闭字幕",
  ),
],
```

### HLS 分段字幕示例

```dart
// HLS 分段字幕配置
subtitles: [
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.network,
    name: "中文字幕",
    asmsIsSegmented: true,  // 标记为分段字幕
    asmsSegmentsTime: 10000, // 每段10秒
    asmsSegments: [
      IAppPlayerAsmsSubtitleSegment(
        startTime: Duration.zero,
        endTime: Duration(seconds: 10),
        realUrl: 'https://example.com/subtitle_seg1.vtt',
      ),
      IAppPlayerAsmsSubtitleSegment(
        startTime: Duration(seconds: 10),
        endTime: Duration(seconds: 20),
        realUrl: 'https://example.com/subtitle_seg2.vtt',
      ),
      // 更多分段...
    ],
  ),
],
```

---

## ⚠️ 十二、平台限制与注意事项

### 📱 iOS 平台

#### 画中画（PiP）限制
- 进入PiP时会先进入全屏模式
- 退出PiP时可能有短暂的方向错误
- 需要在Info.plist中配置相关权限

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

#### FairPlay DRM
- 需要配置证书URL
- 某些实现可能强制使用L3安全级别
- 需要正确的许可证服务器配置

#### 视频格式
- 原生支持HLS（.m3u8）
- 其他格式通过FFmpeg支持
- 30 FPS限制已在最新版本修复

### 🤖 Android 平台

#### 缓存
- 多个播放器实例可能共享缓存目录
- 建议为不同视频设置不同的缓存key

```dart
cacheConfiguration: IAppPlayerCacheConfiguration(
  useCache: true,
  key: 'unique_video_id',
),
```

#### ExoPlayer
- 基于ExoPlayer 2.15.1+
- 支持DASH、HLS、SmoothStreaming
- Widevine DRM需要L1或L3支持

#### 权限要求
在AndroidManifest.xml中添加：

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### 🌐 通用限制

#### 内存管理
- 同时播放多个视频时注意内存使用
- 及时调用dispose()释放资源
- 大型播放列表建议分页加载
- 内存数据源会创建临时文件，在dispose或切换数据源时自动清理

#### 内存使用优化指标

```dart
// 推荐的内存使用限制
// 单个视频实例：
// - 480p: 30-50MB
// - 720p: 50-80MB  
// - 1080p: 80-120MB
// - 4K: 150-200MB

// 设备类型建议：
// 移动设备：
//   - 最多同时播放: 1-2个视频
//   - 缓存大小: 50-200MB
//   - 预加载: 最多1个视频

// 平板设备：
//   - 最多同时播放: 2-3个视频
//   - 缓存大小: 100-500MB
//   - 预加载: 最多2个视频

// TV设备：
//   - 最多同时播放: 1个视频
//   - 缓存大小: 200MB-1GB
//   - 预加载: 2-3个视频
```

#### 网络视频
- HTTPS优于HTTP
- 某些CDN可能需要特定请求头
- 跨域问题需要服务器配置CORS

#### 字幕
- WebVTT格式支持HTML标签
- SRT格式更通用
- HLS分段字幕需要正确的时间戳

#### URL验证
- 播放列表中的URL不能为空
- 空URL会抛出 `ArgumentError` 异常，错误信息会包含具体的索引位置
- 建议在添加URL前进行验证

#### 缓冲防抖机制
- 缓冲状态变化默认有500ms的防抖时间
- 可以通过 `setBufferingDebounceTime()` 方法调整防抖时间
- 防抖机制可以避免频繁的缓冲状态切换，提升用户体验

#### ASMS字幕段智能加载
- HLS/DASH分段字幕采用按需加载策略
- 根据当前播放位置预加载未来5个分段时间的字幕
- 避免一次性加载所有字幕段，节省内存和带宽
- 字幕段位置检查有1秒的最小间隔限制，避免频繁检查

#### 播放列表资源管理
- `IAppPlayerPlaylistController` 的 `dispose` 方法会强制释放内部播放器控制器
- 切换播放列表时会自动暂停当前视频
- 建议在组件销毁时调用 `dispose` 方法释放所有资源

---

<div align="center">

**🎯 本文档包含了 IAppPlayer 的所有参数详细说明和最佳实践**

**👍 如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

**📚 [⬅️ 返回首页](../README.md)   [⬆ 回到顶部](#-iappplayer-api-参数详细说明文档)**

</div>