# 📚 IAppPlayer API Reference Documentation

[![Home](https://img.shields.io/badge/🏠-TV%20Treasure%20App%20Store-blue?style=for-the-badge)](https://www.itvapp.net)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?style=for-the-badge&logo=github)](https://github.com/ITVAPP/IAppPlayer)
[![中文](https://img.shields.io/badge/📄-中文-green?style=for-the-badge)](./API_REFERENCE_CN.md)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

---

## 📋 Table of Contents

- [📚 IAppPlayer API Reference Documentation](#-iappplayer-api-reference-documentation)
  - [📋 Table of Contents](#-table-of-contents)
  - [🎯 1. createPlayer Method Parameters](#-1-createplayer-method-parameters)
  - [🎮 2. PlayerResult Return Value](#-2-playerresult-return-value)
  - [🎪 3. IAppPlayerEvent Event Types](#-3-iappplayerevent-event-types)
  - [🎛️ 4. Controller Methods](#️-4-controller-methods)
  - [🛠️ 5. Utility Methods](#️-5-utility-methods)
  - [🎭 6. Decoder Types](#-6-decoder-types)
  - [⚙️ 7. Player Configuration](#️-7-player-configuration)
  - [🎚️ 8. Controls Configuration](#️-8-controls-configuration)
  - [📝 9. Subtitles Configuration](#-9-subtitles-configuration)
  - [💾 10. Data Source Configuration](#-10-data-source-configuration)
  - [📑 11. Subtitle Source Configuration](#-11-subtitle-source-configuration)
  - [⚠️ 12. Platform Limitations & Considerations](#️-12-platform-limitations--considerations)

---

## 🎯 1. createPlayer Method Parameters

### 🔍 URL Format Auto-detection Rules

The player automatically detects video format and live stream status based on URL:

| URL Feature | Detection Result | Description |
|:---:|:---:|:---|
| `.m3u8` | HLS format, live stream | HTTP Live Streaming |
| `.mpd` | DASH format, non-live | Dynamic Adaptive Streaming |
| `.flv` | Live stream | Flash Video |
| `.ism` | SmoothStreaming format, non-live | Microsoft Smooth Streaming |
| `rtmp://` | Live stream | Real-Time Messaging Protocol |
| `rtmps://` | Live stream | Secure RTMP |
| `rtsp://` | Live stream | Real-Time Streaming Protocol |
| `rtsps://` | Live stream | Secure RTSP |

**Note**:
- Detection results are cached for performance (LRU cache, max 1000 entries)
- Cache uses LRU (Least Recently Used) strategy, automatically removing oldest entries when full
- Extension detection uses `lastIndexOf('.')` for performance optimization
- Cache can be cleared using `clearAllCaches()`
- Auto-detection can be overridden by explicitly setting `videoFormat` and `liveStream` parameters

### 🔧 Required Parameters (Choose One)

| Parameter | Type | Description |
|:---:|:---:|:---|
| `url` | `String?` | Single video URL (either this or urls must be provided) |
| `urls` | `List<String>?` | Playlist URL array (either this or url must be provided) |

### 📝 Basic Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `eventListener` | `Function(IAppPlayerEvent)?` | `null` | Player event listener |
| `title` | `String?` | `null` | Video title, also used as notification title |
| `titles` | `List<String>?` | `null` | Playlist title array |
| `imageUrl` | `String?` | `null` | Video cover image URL, also used as notification icon |
| `imageUrls` | `List<String>?` | `null` | Playlist cover image URL array |
| `author` | `String?` | `null` | Notification author info (usually app name) |
| `notificationChannelName` | `String?` | `null` | Android notification channel name (usually app package name) |
| `backgroundImage` | `String?` | `null` | Player background image, supports network images (http:// or https://) and local resource images. Background uses BoxFit.cover scaling mode, returns background Widget on error. Local images use gaplessPlayback and FilterQuality.medium for optimized display |

### 📑 Subtitle Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `subtitleUrl` | `String?` | `null` | Subtitle file URL |
| `subtitleContent` | `String?` | `null` | Subtitle content string |
| `subtitleUrls` | `List<String>?` | `null` | Playlist subtitle URL array |
| `subtitleContents` | `List<String>?` | `null` | Playlist subtitle content array |
| `subtitles` | `List<IAppPlayerSubtitlesSource>?` | `null` | Advanced subtitle configuration |

### ▶️ Playback Control Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `autoPlay` | `bool` | `true` | Auto-play enabled. **Note**: This setting is ignored when switching videos in playlist mode, always auto-plays |
| `loopVideos` | `bool` | `true` | Loop playlist |
| `looping` | `bool?` | `null` | Loop single video (null auto-sets based on live stream: true for non-live, false for live). **Note**: This parameter is forced to false in playlist mode |
| `startAt` | `Duration?` | `null` | Start playback position |
| `shuffleMode` | `bool?` | `null` | Enable shuffle mode |
| `nextVideoDelay` | `Duration?` | `null` | Playlist video switch delay |
| `initialStartIndex` | `int?` | `null` | Playlist initial start index |

### ⚙️ Advanced Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `isTV` | `bool` | `false` | TV mode, disables notifications and logo downloads, won't create notification config |
| `headers` | `Map<String, String>?` | `null` | HTTP request headers for authenticated video resources |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | `null` | Preferred decoder type (hardware/software/auto) |
| `liveStream` | `bool?` | `null` | Is live stream (null auto-detects based on [URL format](#-url-format-auto-detection-rules)) |
| `audioOnly` | `bool?` | `null` | Audio-only mode (convenience parameter, can also be set via controlsConfiguration) |

### 🎥 Video Configuration Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `videoFormat` | `IAppPlayerVideoFormat?` | `null` | Video format (null auto-detects based on [URL format](#-url-format-auto-detection-rules)) |
| `videoExtension` | `String?` | `null` | Video file extension |
| `dataSourceType` | `IAppPlayerDataSourceType?` | `null` | Data source type (network/file/memory) |
| `resolutions` | `Map<String, String>?` | `null` | Resolution mapping table |
| `overriddenDuration` | `Duration?` | `null` | Override video duration |

### 🎨 UI Configuration Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `placeholder` | `Widget?` | `null` | Placeholder widget before video loads |
| `errorBuilder` | `Widget Function(BuildContext, String?)?` | `null` | Error UI builder |
| `overlay` | `Widget?` | `null` | Overlay widget on video |
| `aspectRatio` | `double?` | `null` | Video aspect ratio |
| `fit` | `BoxFit?` | `null` | Video scaling mode |
| `rotation` | `double?` | `null` | Video rotation angle (must be multiple of 90 and not exceed 360 degrees, otherwise uses default 0) |
| `showPlaceholderUntilPlay` | `bool?` | `null` | Show placeholder until play |
| `placeholderOnTop` | `bool?` | `null` | Placeholder on top layer |

### 🎛️ Configuration Object Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `playerConfiguration` | `IAppPlayerConfiguration?` | `null` | Player core configuration object |
| `controlsConfiguration` | `IAppPlayerControlsConfiguration?` | `null` | Controls configuration object |
| `subtitlesConfiguration` | `IAppPlayerSubtitlesConfiguration?` | `null` | Subtitles configuration object |
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration?` | `null` | Buffering configuration object |
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | `null` | Cache configuration object |
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | `null` | Notification configuration object |
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | `null` | DRM configuration object |

### 🎚️ Control Feature Toggles

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `enableSubtitles` | `bool?` | `null` | Enable subtitles feature |
| `enableQualities` | `bool?` | `null` | Enable quality selection |
| `enableAudioTracks` | `bool?` | `null` | Enable audio track selection |
| `enableFullscreen` | `bool?` | `null` | Enable fullscreen feature |
| `enableOverflowMenu` | `bool?` | `null` | Enable overflow menu |
| `handleAllGestures` | `bool?` | `null` | Handle all gestures |
| `showNotification` | `bool?` | `null` | Show notification controls (invalid in TV mode) |

### 📱 Fullscreen Related Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `fullScreenByDefault` | `bool?` | `null` | Default fullscreen playback |
| `fullScreenAspectRatio` | `double?` | `null` | Fullscreen aspect ratio |
| `deviceOrientationsOnFullScreen` | `List<DeviceOrientation>?` | `null` | Device orientations in fullscreen |
| `deviceOrientationsAfterFullScreen` | `List<DeviceOrientation>?` | `null` | Device orientations after fullscreen |
| `systemOverlaysAfterFullScreen` | `List<SystemUiOverlay>?` | `null` | System UI after fullscreen |
| `autoDetectFullscreenDeviceOrientation` | `bool?` | `null` | Auto-detect fullscreen device orientation (automatically choose landscape or portrait based on video aspect ratio) |
| `autoDetectFullscreenAspectRatio` | `bool?` | `null` | Auto-detect fullscreen aspect ratio |

### 🎵 Streaming Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `useAsmsTracks` | `bool?` | `null` | Use HLS/DASH video tracks |
| `useAsmsAudioTracks` | `bool?` | `null` | Use HLS/DASH audio tracks |
| `useAsmsSubtitles` | `bool?` | `null` | Use HLS/DASH embedded subtitles |

### 🔧 Other Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `handleLifecycle` | `bool?` | `null` | Handle app lifecycle |
| `autoDispose` | `bool?` | `null` | Auto-dispose resources |
| `allowedScreenSleep` | `bool?` | `null` | Allow screen sleep |
| `expandToFill` | `bool?` | `null` | Expand to fill available space |
| `routePageBuilder` | `IAppPlayerRoutePageBuilder?` | `null` | Custom route page builder |
| `translations` | `List<IAppPlayerTranslations>?` | `null` | Multi-language translation config |
| `useRootNavigator` | `bool?` | `null` | Use root navigator |
| `playerVisibilityChangedBehavior` | `Function(double)?` | `null` | Player visibility change callback |

### 📌 Playlist Default Values

When using playlist mode without certain parameters, the system uses these defaults:

| Scenario | Default Value | Description |
|:---:|:---:|:---|
| No titles provided | `Video 1`, `Video 2`... | Auto-generated incremental titles |
| No subtitle names | `Subtitles` | Default subtitle name |
| Notification activity name | `MainActivity` | Android default activity name |

**Note**: Playlists use `List.generate` for batch data source creation, ensuring efficient handling of large video collections.

### 💡 Notification Parameters Example

```dart
// Usage example:
IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  title: 'Video Title',         // Video title, also used as notification main title
  imageUrl: 'cover.jpg',        // Video cover, also used as notification icon
  author: 'App Name',           // Notification subtitle (usually app name)
  notificationChannelName: 'com.example.app', // Android notification channel
);
```

---

## 🎮 2. PlayerResult Return Value

`PlayerResult` is the return value of `createPlayer` method, containing different controllers based on playback mode:

### 🎵 Single Video Mode

```dart
final result = IAppPlayerConfig.createPlayer(url: 'video.mp4', ...);
final controller = result.controller;  // Use controller
```

### 📺 Playlist Mode

```dart
final result = IAppPlayerConfig.createPlayer(urls: [...], ...);
final playlistController = result.playlistController;  // Use playlistController
final activeController = result.activeController;      // Get internal player controller
```

### 🔄 Universal Access

```dart
final activeController = result.activeController;  // Always returns current active controller
```

| Property | Type | Description |
|:---:|:---:|:---|
| `controller` | `IAppPlayerController?` | Returns this controller for single video |
| `playlistController` | `IAppPlayerPlaylistController?` | Returns this controller for playlist |
| `isPlaylist` | `bool` | Whether in playlist mode |
| `activeController` | `IAppPlayerController?` | Get current active controller |

---

## 🎪 3. IAppPlayerEvent Event Types

### 📡 Event Type Enumeration

| Event Type | Description | Parameters |
|:---:|:---|:---|
| `initialized` | Player initialized | - |
| `play` | Start playing | - |
| `pause` | Pause playback | - |
| `seekTo` | Seek to position | `{duration: Duration}` |
| `progress` | Playback progress update (max once per 500ms) | `{progress: Duration, duration: Duration}` |
| `finished` | Video playback finished | - |
| `exception` | Playback error | `{exception: String}` |
| `bufferingStart` | Start buffering | - |
| `bufferingEnd` | End buffering | - |
| `bufferingUpdate` | Buffering progress update | `{buffered: List<Duration>}` |
| `setVolume` | Volume changed | `{volume: double}` |
| `setSpeed` | Playback speed changed | `{speed: double}` |
| `openFullscreen` | Enter fullscreen | - |
| `hideFullscreen` | Exit fullscreen | - |
| `changedSubtitles` | Subtitle switched | `{subtitlesSource: IAppPlayerSubtitlesSource}` |
| `changedTrack` | Video track switched (HLS multi-bitrate) | `{track: IAppPlayerAsmsTrack}` |
| `changedAudioTrack` | Audio track switched | `{audioTrack: IAppPlayerAsmsAudioTrack}` |
| `changedResolution` | Resolution switched | `{url: String}` |
| `changedPlayerVisibility` | Player visibility changed | `{visible: bool}` |
| `changedPlaylistItem` | Playlist item switched | `{index: int}` |
| `togglePlaylistShuffle` | Trigger shuffle mode toggle | - |
| `changedPlaylistShuffle` | Shuffle mode changed | `{shuffleMode: bool}` |
| `pipStart` | Enter picture-in-picture | - |
| `pipStop` | Exit picture-in-picture | - |
| `setupDataSource` | Setup data source | `{dataSource: IAppPlayerDataSource}` |
| `controlsVisible` | Controls visible | - |
| `controlsHiddenStart` | Controls start hiding | - |
| `controlsHiddenEnd` | Controls hidden complete | - |

### 🚨 Error Type Classification

Common playback error types (`exception` event):

| Error Type | Description | Handling Suggestion |
|:---:|:---|:---|
| `PlatformException` | Platform-related error | Check device compatibility |
| `FormatException` | Video format not supported | Convert format or use another source |
| `NetworkException` | Network error (403/404/timeout) | Check network connection and URL validity |
| `DrmException` | DRM-related error | Check DRM configuration and license |
| `UnknownException` | Unknown error | Check detailed error message and retry |

### 👂 Event Listener Example

```dart
eventListener: (IAppPlayerEvent event) {
  switch (event.iappPlayerEventType) {
    case IAppPlayerEventType.progress:
      final progress = event.parameters?['progress'] as Duration?;
      final duration = event.parameters?['duration'] as Duration?;
      print('Progress: ${progress?.inSeconds}/${duration?.inSeconds}');
      break;
    case IAppPlayerEventType.exception:
      final error = event.parameters?['exception'] as String?;
      print('Playback error: $error');
      // Implement retry logic here
      break;
    case IAppPlayerEventType.bufferingStart:
      print('Start buffering, show loading animation');
      break;
    case IAppPlayerEventType.bufferingEnd:
      print('Buffering ended, hide loading animation');
      break;
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('Shuffle mode: $shuffleMode');
      break;
    case IAppPlayerEventType.changedAudioTrack:
      final audioTrack = event.parameters?['audioTrack'] as IAppPlayerAsmsAudioTrack?;
      print('Audio track switched: ${audioTrack?.label}');
      break;
  }
}
```

---

## 🎛️ 4. Controller Methods

### 🎬 IAppPlayerController Main Methods

#### Playback Control

| Method | Description | Example |
|:---:|:---|:---|
| `play()` | Play | `controller.play()` |
| `pause()` | Pause | `controller.pause()` |
| `seekTo(Duration moment)` | Seek to position | `controller.seekTo(Duration(seconds: 30))` |
| `setVolume(double volume)` | Set volume (0.0 - 1.0) | `controller.setVolume(0.8)` |
| `setSpeed(double speed)` | Set playback speed (>0 and ≤2.0) | `controller.setSpeed(1.5)` |

#### Fullscreen Control

| Method | Description |
|:---:|:---|
| `enterFullScreen()` | Enter fullscreen |
| `exitFullScreen()` | Exit fullscreen |
| `toggleFullScreen()` | Toggle fullscreen state |

#### Subtitles and Tracks

| Method | Description |
|:---:|:---|
| `setupSubtitleSource(IAppPlayerSubtitlesSource)` | Switch subtitle source |
| `setTrack(IAppPlayerAsmsTrack)` | Set video track (HLS multi-bitrate). When track's height, width, and bitrate are all 0, it displays as "Auto" |
| `setAudioTrack(IAppPlayerAsmsAudioTrack)` | Set audio track |

#### Advanced Features

| Method | Description |
|:---:|:---|
| `setMixWithOthers(bool)` | Set whether to mix with other audio |
| `enablePictureInPicture()` | Enable picture-in-picture |
| `disablePictureInPicture()` | Disable picture-in-picture |
| `setControlsEnabled(bool)` | Enable/disable controls |
| `setControlsAlwaysVisible(bool)` | Set controls always visible |
| `retryDataSource()` | Retry current data source |
| `clearCache()` | Clear cache |
| `preCache(IAppPlayerDataSource)` | Pre-cache video |
| `stopPreCache(IAppPlayerDataSource)` | Stop pre-caching |
| `setBufferingDebounceTime(int)` | Set buffering state debounce time (milliseconds) |
| `dispose()` | Release resources |

### 📊 Property Getters

| Property/Method | Return Type | Description |
|:---:|:---:|:---|
| `isPlaying()` | `bool` | Is playing |
| `isBuffering()` | `bool` | Is buffering |
| `isVideoInitialized()` | `bool` | Is video initialized |
| `isFullScreen` | `bool` | Is fullscreen |
| `videoPlayerController` | `VideoPlayerController?` | Get underlying video controller |
| `iappPlayerDataSource` | `IAppPlayerDataSource?` | Get current data source |
| `subtitlesLines` | `List<IAppPlayerSubtitle>` | Get subtitle list |
| `renderedSubtitle` | `IAppPlayerSubtitle?` | Get currently displayed subtitle |
| `iappPlayerAsmsTrack` | `IAppPlayerAsmsTrack?` | Get current video track |
| `iappPlayerAsmsTracks` | `List<IAppPlayerAsmsTrack>` | Get available video tracks |
| `iappPlayerAsmsAudioTrack` | `IAppPlayerAsmsAudioTrack?` | Get current audio track |
| `iappPlayerAsmsAudioTracks` | `List<IAppPlayerAsmsAudioTrack>` | Get available audio tracks |

### 📜 IAppPlayerPlaylistController Main Methods

| Method | Description | Example |
|:---:|:---|:---|
| `playNext()` | Play next | `playlistController.playNext()` |
| `playPrevious()` | Play previous | `playlistController.playPrevious()` |
| `setupDataSource(int index)` | Play video at index | `playlistController.setupDataSource(2)` |
| `toggleShuffleMode()` | Toggle shuffle mode | `playlistController.toggleShuffleMode()` |
| `setupDataSourceList(List<IAppPlayerDataSource>)` | Set new playlist | - |
| `dispose()` | Release resources (force dispose internal player controller) | `playlistController.dispose()` |

### 📈 Playlist Property Getters

| Property | Type | Description |
|:---:|:---:|:---|
| `currentDataSourceIndex` | `int` | Current playback index |
| `dataSourceList` | `List<IAppPlayerDataSource>` | Get data source list (read-only) |
| `hasNext` | `bool` | Has next video |
| `hasPrevious` | `bool` | Has previous video |
| `shuffleMode` | `bool` | Current shuffle mode state |
| `iappPlayerController` | `IAppPlayerController?` | Get internal player controller |

---

## 🛠️ 5. Utility Methods

### 🎯 IAppPlayerConfig Static Methods

| Method | Description | Use Case |
|:---:|:---|:---|
| `playSource()` | Simplified source switching method | Dynamic video source switching |
| `clearAllCaches()` | Clear URL format detection LRU cache (max 1000 entries)<br>Uses LRU strategy, automatically removes oldest entries when full | Release memory after long running or force URL format re-detection |
| `createDataSource()` | Create data source | Build complex data sources |
| `createPlayerConfig()` | Create player configuration | Custom player configuration |
| `createPlaylistConfig()` | Create playlist configuration | Custom playlist configuration |
| `createPlaylistPlayer()` | Create playlist with custom data sources | Advanced playlist usage |

### 🔧 playSource Method Parameters

```dart
static Future<void> playSource({
  required IAppPlayerController controller,
  required dynamic source,  // Must actually be String type
  bool? liveStream,
  String? title,              // Video title
  String? imageUrl,           // Video cover
  String? author,             // Notification author
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

| Parameter | Type | Description |
|:---:|:---:|:---|
| `controller` | `IAppPlayerController` | Player controller |
| `source` | `dynamic` (must be String) | Video source URL, although parameter type is dynamic, must pass String type or will throw ArgumentError |
| `liveStream` | `bool?` | Is live stream |
| `title` | `String?` | Video title |
| `imageUrl` | `String?` | Video cover URL |
| `author` | `String?` | Author info |
| `notificationChannelName` | `String?` | Notification channel name |
| `preloadOnly` | `bool` | Only preload without playing (preload mode creates simplified data source) |
| `isTV` | `bool` | Is TV mode |
| `audioOnly` | `bool?` | Is audio-only mode (updates controller config) |
| `subtitles/subtitleUrl/subtitleContent` | - | Subtitle parameters |
| `headers` | `Map<String, String>?` | HTTP request headers |
| `dataSourceType` | `IAppPlayerDataSourceType?` | Data source type |
| `showNotification` | `bool?` | Show notification |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | Decoder type |
| `videoFormat` | `IAppPlayerVideoFormat?` | Video format |
| `videoExtension` | `String?` | Video extension |
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration?` | Buffering config |
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | Cache config |
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | DRM config |
| `resolutions` | `Map<String, String>?` | Resolution mapping |
| `useAsmsTracks` | `bool?` | Use HLS tracks |
| `useAsmsAudioTracks` | `bool?` | Use audio tracks |
| `useAsmsSubtitles` | `bool?` | Use embedded subtitles |
| `overriddenDuration` | `Duration?` | Override duration |
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | Notification config |

#### Usage Example

```dart
// Switch video source
await IAppPlayerConfig.playSource(
  controller: player.activeController!,
  source: 'https://example.com/new_video.mp4',  // Must be String
  title: 'New Video Title',
  imageUrl: 'https://example.com/cover.jpg',
  author: 'App Name',
  notificationChannelName: 'com.example.app',
);
```

### 🎯 createDataSource Method Parameters

```dart
static IAppPlayerDataSource createDataSource({
  required String url,
  bool? liveStream,
  Map<String, String>? headers,
  String? title,              // Video title
  String? imageUrl,           // Video cover
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

### 🎮 createPlayerConfig Method Parameters

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

**Note**: `createPlayerConfig` dynamically builds controls configuration based on `audioOnly` parameter. If `audioOnly` is provided, it will automatically create or update `controlsConfiguration`.

### 📋 createPlaylistConfig Method Parameters

```dart
static IAppPlayerPlaylistConfiguration createPlaylistConfig({
  bool shuffleMode = false,
  bool loopVideos = true,
  Duration nextVideoDelay = defaultNextVideoDelay,
  int initialStartIndex = 0,
})
```

### 🎵 createPlaylistPlayer Method Parameters

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

### 🔧 Constant Definitions

| Constant | Value | Description |
|:---:|:---:|:---|
| `defaultNextVideoDelay` | `Duration(seconds: 1)` | Default playlist switch delay in IAppPlayerConfig |

### 📌 Internal Constants

Default constant values used internally by the player:

| Constant | Value | Description |
|:---:|:---:|:---|
| Pre-cache size | 10MB (10 * 1024 * 1024 bytes) | Default pre-cache size |
| Max cache | 300MB (300 * 1024 * 1024 bytes) | Default max cache size |
| Single file max cache | 50MB (50 * 1024 * 1024 bytes) | Single file max cache size |
| Live min buffer | 15 seconds | Live stream minimum buffer time |
| Live max buffer | 15 seconds | Live stream maximum buffer time |
| VOD min buffer | 20 seconds | VOD stream minimum buffer time |
| VOD max buffer | 30 seconds | VOD stream maximum buffer time |
| Playback buffer | 3 seconds | Buffer needed to start playback |
| Re-buffer playback | 5 seconds | Buffer needed after re-buffering |
| URL cache capacity | 1000 entries | URL format detection cache max entries (LRU strategy) |
| Default video title prefix | `Video ` | Playlist default title prefix |
| Default subtitle name | `Subtitles` | Default subtitle name |
| Default activity name | `MainActivity` | Android default activity name |
| Default image scale mode | BoxFit.cover | Background image default scale mode |
| Default image quality | FilterQuality.medium | Local image default render quality |
| Default rotation angle | 0 | Video default rotation angle |
| Buffer debounce time | 500ms | Default debounce time for buffer state changes |
| Playlist switch delay (IAppPlayerPlaylistConfiguration) | 3s | Default switch delay when using IAppPlayerPlaylistConfiguration |
| Audio controls hide time | No hiding | Audio controls always remain visible |
| Progress event throttle | 500ms | Minimum interval for Progress event |
| Audio extended layout threshold | 200px | Show extended layout when height exceeds this |
| Subtitle segment check interval | 1s | Minimum interval for ASMS subtitle segment position check |

---

## 🎭 6. Decoder Types

### 🎨 IAppPlayerDecoderType Options

| Type | Description | Use Case |
|:---:|:---|:---|
| `auto` | Auto-select decoder | System automatically decides best decoder |
| `hardwareFirst` | Prefer hardware decoding, auto-switch to software on failure | Recommended, best performance |
| `softwareFirst` | Prefer software decoding, auto-switch to hardware on failure | Specific device compatibility issues |

### 💡 Usage Recommendations

```dart
// General case (hardware decoding recommended)
preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,

// Software decoding priority
preferredDecoderType: IAppPlayerDecoderType.softwareFirst,

// Auto selection
preferredDecoderType: IAppPlayerDecoderType.auto,
```

---

## ⚙️ 7. Player Configuration

**Note**: The following default values are based on the `IAppPlayerConfiguration` class definition. When using `createPlayerConfig()` method to create configuration, some parameters will be dynamically set based on `liveStream` and other parameters.

### 🎮 Playback Behavior Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `autoPlay` | `bool` | `false` | Auto-play enabled. **Note**: This setting is ignored when switching videos in playlist mode, always auto-plays |
| `startAt` | `Duration?` | `null` | Video start position |
| `looping` | `bool` | `false` | Loop single video. **Note**: <br>1. This is the base default. When using `createPlayerConfig()`, it's dynamically set based on `liveStream` (true for non-live, false for live)<br>2. This parameter is forced to false in playlist mode |
| `handleLifecycle` | `bool` | `true` | Auto-handle app lifecycle (pause in background, etc.) |
| `autoDispose` | `bool` | `true` | Auto-dispose resources |
| `showControlsOnInitialize` | `bool` | `true` | Show controls on initialization |

### 🎨 Display Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `aspectRatio` | `double?` | `null` | Video aspect ratio, null for adaptive |
| `fit` | `BoxFit` | `BoxFit.fill` | Video scale mode |
| `rotation` | `double` | `0` | Video rotation angle (must be multiple of 90 and not exceed 360 degrees) |
| `expandToFill` | `bool` | `true` | Expand to fill all available space |

#### BoxFit Scale Mode Description

| Mode | Description |
|:---:|:---|
| `BoxFit.fill` | Fill entire container, may distort |
| `BoxFit.contain` | Maintain aspect ratio, show complete |
| `BoxFit.cover` | Maintain aspect ratio, cover entire container |
| `BoxFit.fitWidth` | Fit width |
| `BoxFit.fitHeight` | Fit height |
| `BoxFit.none` | Original size |
| `BoxFit.scaleDown` | Scale down to fit |

### 🖼️ Placeholder Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `placeholder` | `Widget?` | `null` | Placeholder widget before video loads |
| `showPlaceholderUntilPlay` | `bool` | `false` | Show placeholder until play |
| `placeholderOnTop` | `bool` | `true` | Placeholder on top layer |

### 📱 Fullscreen Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `fullScreenByDefault` | `bool` | `false` | Default fullscreen playback |
| `allowedScreenSleep` | `bool` | `true` | Allow screen sleep in fullscreen |
| `fullScreenAspectRatio` | `double?` | `null` | Fullscreen aspect ratio |
| `autoDetectFullscreenDeviceOrientation` | `bool` | `false` | Auto-detect fullscreen orientation (automatically choose landscape or portrait based on video aspect ratio) |
| `autoDetectFullscreenAspectRatio` | `bool` | `false` | Auto-detect fullscreen aspect ratio |
| `deviceOrientationsOnFullScreen` | `List<DeviceOrientation>` | `[landscapeLeft, landscapeRight]` | Allowed device orientations in fullscreen |
| `deviceOrientationsAfterFullScreen` | `List<DeviceOrientation>` | `[landscapeLeft, landscapeRight, portraitUp]` | Device orientations after fullscreen |
| `systemOverlaysAfterFullScreen` | `List<SystemUiOverlay>` | `SystemUiOverlay.values` | System UI after fullscreen (show all system UI) |
| `fullscreenOrientationLocker` | `Function?` | `null` | Custom fullscreen orientation lock logic |

### 🎯 Other Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `overlay` | `Widget?` | `null` | Overlay widget on video |
| `errorBuilder` | `Function?` | `null` | Custom error widget builder (returns background Widget by default when using backgroundImage) |
| `eventListener` | `Function?` | `null` | Event listener |
| `routePageBuilder` | `Function?` | `null` | Custom fullscreen page route builder |
| `translations` | `List<IAppPlayerTranslations>?` | `null` | Multi-language translation config |
| `playerVisibilityChangedBehavior` | `Function?` | `null` | Player visibility change callback |
| `subtitlesConfiguration` | `IAppPlayerSubtitlesConfiguration` | - | Subtitles configuration |
| `controlsConfiguration` | `IAppPlayerControlsConfiguration` | - | Controls configuration |
| `useRootNavigator` | `bool` | `false` | Use root navigator |

### 🌐 Multi-language Configuration

`IAppPlayerTranslations` structure:

```dart
class IAppPlayerTranslations {
  final String languageCode;           // Language code (e.g., zh, en, ja)
  final String generalDefaultError;    // Default error message
  final String generalNone;            // "None" option text
  final String generalDefault;         // "Default" text
  final String generalRetry;           // "Retry" button text
  final String playlistLoadingNextVideo; // Loading next video hint
  final String playlistUnavailable;    // Playlist unavailable hint
  final String playlistTitle;          // Playlist title
  final String videoItem;              // Video item format (contains {index} placeholder)
  final String trackItem;              // Track item format (contains {index} placeholder)
  final String controlsLive;           // "Live" indicator text
  final String controlsNextIn;         // Next video countdown text
  final String overflowMenuPlaybackSpeed; // Playback speed menu text
  final String overflowMenuSubtitles;  // Subtitles menu text
  final String overflowMenuQuality;    // Quality menu text
  final String overflowMenuAudioTracks; // Audio tracks menu text
  final String qualityAuto;            // Auto quality text
}
```

### 🗣️ Supported Languages

IAppPlayer supports preset translations for the following languages:

| Language Code | Language Name | Usage Method |
|:---:|:---|:---|
| `zh` | Simplified Chinese | `IAppPlayerTranslations.chinese()` |
| `zh-Hant` | Traditional Chinese | `IAppPlayerTranslations.traditionalChinese()` |
| `en` | English | `IAppPlayerTranslations()` (default) |
| `pl` | Polish | `IAppPlayerTranslations.polish()` |
| `hi` | Hindi | `IAppPlayerTranslations.hindi()` |
| `ar` | Arabic | `IAppPlayerTranslations.arabic()` |
| `tr` | Turkish | `IAppPlayerTranslations.turkish()` |
| `vi` | Vietnamese | `IAppPlayerTranslations.vietnamese()` |
| `es` | Spanish | `IAppPlayerTranslations.spanish()` |
| `pt` | Portuguese | `IAppPlayerTranslations.portuguese()` |
| `bn` | Bengali | `IAppPlayerTranslations.bengali()` |
| `ru` | Russian | `IAppPlayerTranslations.russian()` |
| `ja` | Japanese | `IAppPlayerTranslations.japanese()` |
| `fr` | French | `IAppPlayerTranslations.french()` |
| `de` | German | `IAppPlayerTranslations.german()` |
| `id` | Indonesian | `IAppPlayerTranslations.indonesian()` |
| `ko` | Korean | `IAppPlayerTranslations.korean()` |
| `it` | Italian | `IAppPlayerTranslations.italian()` |

Usage examples:

```dart
// Use Simplified Chinese
translations: [
  IAppPlayerTranslations.chinese(),
],

// Use multiple languages (system automatically selects based on device language)
translations: [
  IAppPlayerTranslations.chinese(),
  IAppPlayerTranslations.english(),
  IAppPlayerTranslations.japanese(),
],

// Custom translation
translations: [
  IAppPlayerTranslations(
    languageCode: 'en',
    generalDefaultError: 'Cannot play video',
    generalNone: 'None',
    generalDefault: 'Default',
    generalRetry: 'Retry',
    playlistLoadingNextVideo: 'Loading next video',
    playlistUnavailable: 'Playlist unavailable',
    playlistTitle: 'Playlist',
    videoItem: 'Video {index}',
    trackItem: 'Track {index}',
    controlsLive: 'LIVE',
    controlsNextIn: 'Next video in',
    overflowMenuPlaybackSpeed: 'Playback Speed',
    overflowMenuSubtitles: 'Subtitles',
    overflowMenuQuality: 'Quality',
    overflowMenuAudioTracks: 'Audio Tracks',
    qualityAuto: 'Auto',
  ),
],
```

---

## 🎚️ 8. Controls Configuration

### 🎨 Color Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `controlBarColor` | `Color` | `Colors.transparent` | Control bar background color |
| `textColor` | `Color` | `Colors.white` | Text color |
| `iconsColor` | `Color` | `Colors.white` | Icons color |
| `liveTextColor` | `Color` | `Colors.red` | Live indicator text color |
| `backgroundColor` | `Color` | `Colors.black` | Background color when no video |
| `loadingColor` | `Color` | `Colors.white` | Loading indicator color |

### 📊 Progress Bar Colors

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `progressBarPlayedColor` | `Color` | `Color(0xFFFF0000)` | Played portion color |
| `progressBarHandleColor` | `Color` | `Color(0xFFFF0000)` | Drag handle color |
| `progressBarBufferedColor` | `Color` | `Color.fromRGBO(255, 255, 255, 0.3)` | Buffered portion color |
| `progressBarBackgroundColor` | `Color` | `Color.fromRGBO(255, 255, 255, 0.2)` | Background color |

### 🎯 Icon Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `playIcon` | `IconData` | `Icons.play_arrow_outlined` | Play icon |
| `pauseIcon` | `IconData` | `Icons.pause_outlined` | Pause icon |
| `muteIcon` | `IconData` | `Icons.volume_up_outlined` | Mute icon |
| `unMuteIcon` | `IconData` | `Icons.volume_off_outlined` | Unmute icon |
| `fullscreenEnableIcon` | `IconData` | `Icons.fullscreen_outlined` | Enter fullscreen icon |
| `fullscreenDisableIcon` | `IconData` | `Icons.fullscreen_exit_outlined` | Exit fullscreen icon |
| `skipBackIcon` | `IconData` | `Icons.replay_10_outlined` | Skip back icon |
| `skipForwardIcon` | `IconData` | `Icons.forward_10_outlined` | Skip forward icon |

### 🔧 Feature Toggles

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `showControls` | `bool` | `true` | Show controls |
| `showControlsOnInitialize` | `bool` | `true` | Show controls on initialization |
| `enableFullscreen` | `bool` | `true` | Enable fullscreen feature |
| `enableMute` | `bool` | `true` | Enable mute feature |
| `enableProgressText` | `bool` | `true` | Show progress time text |
| `enableProgressBar` | `bool` | `true` | Show progress bar |
| `enableProgressBarDrag` | `bool` | `true` | Allow progress bar dragging |
| `enablePlayPause` | `bool` | `true` | Enable play/pause button |
| `enableSkips` | `bool` | `true` | Enable skip forward/back |
| `enableAudioTracks` | `bool` | `true` | Enable audio track selection |
| `enableSubtitles` | `bool` | `true` | Enable subtitles feature |
| `enableQualities` | `bool` | `true` | Enable quality selection |
| `enablePip` | `bool` | `true` | Enable picture-in-picture |
| `enableRetry` | `bool` | `true` | Enable retry feature |
| `enableOverflowMenu` | `bool` | `true` | Enable overflow menu |
| `enablePlaybackSpeed` | `bool` | `true` | Enable playback speed adjustment |

### 📱 Menu Icons

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `overflowMenuIcon` | `IconData` | `Icons.more_vert_outlined` | Overflow menu icon |
| `pipMenuIcon` | `IconData` | `Icons.picture_in_picture_outlined` | Picture-in-picture icon |
| `playbackSpeedIcon` | `IconData` | `Icons.shutter_speed_outlined` | Speed adjustment icon |
| `qualitiesIcon` | `IconData` | `Icons.hd_outlined` | Quality selection icon |
| `subtitlesIcon` | `IconData` | `Icons.closed_caption_outlined` | Subtitles icon |
| `audioTracksIcon` | `IconData` | `Icons.audiotrack_outlined` | Audio tracks icon |

### 📋 Overflow Menu

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `overflowMenuCustomItems` | `List<IAppPlayerOverflowMenuItem>` | `[]` | Custom menu items |
| `overflowModalColor` | `Color` | `Colors.white` | Menu background color |
| `overflowModalTextColor` | `Color` | `Colors.black` | Menu text color |
| `overflowMenuIconsColor` | `Color` | `Colors.black` | Menu icons color |

#### IAppPlayerOverflowMenuItem Complete Properties

```dart
class IAppPlayerOverflowMenuItem {
  final String title;           // Menu item title
  final IconData icon;         // Menu item icon
  final Function() onClicked;  // Click callback (Note: property name is onClicked not onTap)
  final bool Function()? isEnabled;  // Optional: control enabled state
  
  IAppPlayerOverflowMenuItem(
    this.icon,
    this.title,
    this.onClicked,
  );
}
```

#### Custom Menu Item Example

```dart
overflowMenuCustomItems: [
  IAppPlayerOverflowMenuItem(
    Icons.share,
    'Share',
    () {
      // Execute share logic
    },
  ),
  IAppPlayerOverflowMenuItem(
    Icons.download,
    'Download',
    () {
      // Execute download logic
    },
  ),
],
```

### ⚙️ Other Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `controlsHideTime` | `Duration` | `Duration(milliseconds: 1000)` | Controls auto-hide time (Note: audio controls do not auto-hide) |
| `controlBarHeight` | `double` | `30.0` | Control bar height |
| `forwardSkipTimeInMilliseconds` | `int` | `10000` | Forward skip time (milliseconds) |
| `backwardSkipTimeInMilliseconds` | `int` | `10000` | Backward skip time (milliseconds) |
| `loadingWidget` | `Widget?` | `null` | Custom loading widget |
| `audioOnly` | `bool` | `false` | Audio-only mode (hide video, show audio controls). Audio controls show extended layout (including cover and title) when height exceeds 200px |
| `handleAllGestures` | `bool` | `true` | Player doesn't intercept gestures, allowing events to pass through |
| `customControlsBuilder` | `Function?` | `null` | Custom controls builder |
| `playerTheme` | `IAppPlayerTheme?` | `null` | Player theme |

### 🎨 Player Theme

`IAppPlayerTheme` enum values:

| Theme | Description | Effect |
|:---:|:---|:---|
| `video` | Video style (default) | Controls designed for video |
| `audio` | Audio style | Controls designed for audio |
| `custom` | Custom controls | Use customControlsBuilder |

### 🎵 Audio Mode Configuration

Audio-only mode configuration:

```dart
// Audio mode shows audio visualization instead of video
controlsConfiguration: IAppPlayerControlsConfiguration(
  audioOnly: true,  // Enable audio-only mode
  // Recommended for audio mode
  enableFullscreen: false,  // Audio mode usually doesn't need fullscreen
  showControls: true,
  enableProgressBar: true,
  enablePlayPause: true,
  enableSkips: true,
  enablePlaybackSpeed: true,
  // Can customize audio cover
  placeholder: Image.asset('assets/audio_cover.png'),
),
```

---

## 📝 9. Subtitles Configuration

### 🎨 Font Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `fontSize` | `double` | `14` | Subtitle font size |
| `fontFamily` | `String` | `"Roboto"` | Subtitle font family |
| `fontColor` | `Color` | `Colors.white` | Subtitle text color |
| `fontWeight` | `FontWeight?` | `null` | Font weight |
| `letterSpacing` | `double?` | `null` | Letter spacing |
| `height` | `double?` | `null` | Line height |

### 🖋️ Outline Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `outlineEnabled` | `bool` | `true` | Enable text outline |
| `outlineColor` | `Color` | `Colors.black` | Outline color |
| `outlineSize` | `double` | `2.0` | Outline thickness |

### 📏 Padding Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `leftPadding` | `double` | `8.0` | Left padding |
| `rightPadding` | `double` | `8.0` | Right padding |
| `bottomPadding` | `double` | `20.0` | Bottom padding |

### 🎯 Style Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `alignment` | `Alignment` | `Alignment.center` | Subtitle alignment |
| `backgroundColor` | `Color` | `Colors.transparent` | Subtitle background color |
| `textShadows` | `List<Shadow>?` | `null` | Text shadow effects |
| `textDecoration` | `TextDecoration?` | `null` | Text decoration (underline, etc.) |

### 📝 Supported Subtitle Formats

| Format | Description | Example |
|:---:|:---|:---|
| `SRT` | SubRip subtitle format | `.srt` files |
| `WEBVTT` | Web Video Text Tracks | `.vtt` files, supports HTML tags |
| `LRC` | Lyrics format | `.lrc` files, suitable for music playback |
| `HLS Subtitles` | HLS embedded subtitles | Auto-detected |
| `DASH Subtitles` | DASH embedded subtitles | Auto-detected |

---

## 💾 10. Data Source Configuration

### 🎯 Basic Parameters

| Parameter | Type | Description |
|:---:|:---:|:---|
| `type` | `IAppPlayerDataSourceType` | Data source type (network/file/memory) |
| `url` | `String` | Video URL or file path (needs trim, cannot be empty) |
| `bytes` | `List<int>?` | Byte array for memory data source |

#### Data Source Type Description

| Type | Description | Use Case |
|:---:|:---|:---|
| `network` | Network video | Online video playback |
| `file` | Local file | Downloaded videos |
| `memory` | Memory data | Encrypted videos or dynamically generated. **Note**: Memory data source creates temporary files, automatically cleaned up on dispose or data source switch |

### 📺 Video Format

| Parameter | Type | Description |
|:---:|:---:|:---|
| `videoFormat` | `IAppPlayerVideoFormat?` | Video format (hls/dash/ss/other) |
| `videoExtension` | `String?` | Video file extension |
| `liveStream` | `bool?` | Is live stream |

#### Video Format Description

| Format | Description | File Extension |
|:---:|:---|:---|
| `hls` | HTTP Live Streaming | `.m3u8` |
| `dash` | Dynamic Adaptive Streaming | `.mpd` |
| `ss` | Smooth Streaming | `.ism/manifest` |
| `other` | Other formats | `.mp4`, `.webm`, `.mkv`, etc. |

#### Supported Video Format List

| Platform | Supported Formats |
|:---:|:---|
| **Android** | MP4, WebM, MKV, MP3, AAC, HLS(.m3u8), DASH(.mpd), SmoothStreaming, FLV, AVI, MOV, TS |
| **iOS** | MP4, M4V, MOV, MP3, HLS(.m3u8), AAC |
| **Web** | Depends on browser (typically MP4, WebM, HLS) |

### 📑 Subtitle Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `subtitles` | `List<IAppPlayerSubtitlesSource>?` | Subtitle source list (built through dedicated creation methods) |
| `useAsmsSubtitles` | `bool` | Use HLS/DASH embedded subtitles |

### 🎵 Audio/Video Tracks (ASMS)

| Parameter | Type | Description |
|:---:|:---:|:---|
| `useAsmsTracks` | `bool` | Use HLS tracks (defaults based on liveStream) |
| `useAsmsAudioTracks` | `bool` | Use HLS/DASH audio tracks (defaults based on liveStream) |
| `asmsTrackNames` | `List<String>?` | Custom track names |

#### ASMS (Adaptive Streaming Media Sources) Description

ASMS refers to Adaptive Streaming Media Sources, including:
- HLS multi-bitrate video tracks
- DASH multi-bitrate video tracks
- Multi-language audio tracks
- Embedded subtitle tracks

#### IAppPlayerAsmsTrack Properties

| Property | Type | Description |
|:---:|:---:|:---|
| `id` | `String?` | Track ID |
| `width` | `int?` | Video width |
| `height` | `int?` | Video height |
| `bitrate` | `int?` | Bitrate |
| `frameRate` | `int?` | Frame rate |
| `codecs` | `String?` | Codec format |
| `mimeType` | `String?` | MIME type |

#### IAppPlayerAsmsAudioTrack Properties

| Property | Type | Description |
|:---:|:---:|:---|
| `id` | `String?` | Audio track ID |
| `label` | `String?` | Audio track label/name |
| `language` | `String?` | Audio track language |

### 🌐 Network Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `headers` | `Map<String, String>?` | HTTP request headers |
| `overriddenDuration` | `Duration?` | Override video duration |

#### Request Headers Example

```dart
headers: {
  'Authorization': 'Bearer token',
  'User-Agent': 'MyApp/1.0',
  'Referer': 'https://myapp.com',
}
```

### 🎬 Quality Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `resolutions` | `Map<String, String>?` | Multi-resolution URL mapping |

#### Resolution Configuration Example

```dart
resolutions: {
  "360p": "https://example.com/video_360p.mp4",
  "720p": "https://example.com/video_720p.mp4",
  "1080p": "https://example.com/video_1080p.mp4",
  "Auto": "auto",  // Special value for auto selection
}
```

### 💾 Cache Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | `null` | Cache configuration object |

#### IAppPlayerCacheConfiguration Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `useCache` | `bool` | Based on stream type | Enable cache. Default based on `liveStream`:<br>• Non-live: `true`<br>• Live: `false` |
| `preCacheSize` | `int` | See [Internal Constants](#-internal-constants) | Pre-cache size (default 10MB) |
| `maxCacheSize` | `int` | See [Internal Constants](#-internal-constants) | Max cache size (default 300MB) |
| `maxCacheFileSize` | `int` | See [Internal Constants](#-internal-constants) | Single file max cache size (default 50MB) |
| `key` | `String?` | `null` | Cache key to distinguish different videos |

#### Cache Key Naming Convention

```dart
// Recommended cache key naming convention
// Format: [app_name]_[type]_[unique_id]_[version]
cacheConfiguration: IAppPlayerCacheConfiguration(
  useCache: true,
  key: 'myapp_video_${videoId}_v1',
  // Or use URL MD5
  // key: md5.convert(utf8.encode(videoUrl)).toString(),
),

// Practical examples
// Movie: myapp_movie_tt0111161_v1
// Series: myapp_series_s01e01_12345_v1  
// Live: don't use cache
// User video: myapp_user_${userId}_${videoId}_v1
```

### 🔔 Notification Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | `null` | Notification config (not created in TV mode) |

#### IAppPlayerNotificationConfiguration Structure

Notification configuration object for controlling player notification bar display. See [Basic Parameters](#-basic-parameters) for parameter descriptions.

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `showNotification` | `bool` | `false` | Show notification (true by default in non-TV mode) |
| `activityName` | `String?` | `"MainActivity"` | Android Activity name |

**Note**:
- `title`, `author`, `imageUrl`, `notificationChannelName` parameters are same as createPlayer basic parameters
- Notification config is not created in TV mode, even if parameters are set

### 🔐 DRM Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | DRM protection configuration |

#### IAppPlayerDrmConfiguration Parameters

| Parameter | Type | Description | Platform |
|:---:|:---:|:---|:---|
| `drmType` | `IAppPlayerDrmType?` | DRM type | Universal |
| `token` | `String?` | DRM token | Universal |
| `licenseUrl` | `String?` | License URL | Universal |
| `certificateUrl` | `String?` | Certificate URL | iOS (FairPlay) |
| `headers` | `Map<String, String>?` | DRM request headers | Universal |
| `clearKey` | `String?` | ClearKey configuration (JSON string) | Android |

#### DRM Type Description

| Type | Description | Supported Platforms |
|:---:|:---|:---|
| `widevine` | Google Widevine | Android |
| `fairplay` | Apple FairPlay | iOS |
| `clearkey` | W3C ClearKey | Android |
| `token` | Token-based DRM | Universal |

#### DRM Configuration Complete Example

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

// ClearKey DRM (Android) - Note clearKey is String type JSON
drmConfiguration: IAppPlayerDrmConfiguration(
  drmType: IAppPlayerDrmType.clearkey,
  clearKey: '{"keys":[{"kty":"oct","k":"GawgguFyGrWKav7AX4VKUg","kid":"nrQFDeRLSAKTLifXUIPiZg"}]}',
),
```

### ⏸️ Buffering Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration` | Buffering config (auto-created based on liveStream if not provided) |

#### IAppPlayerBufferingConfiguration Parameters

| Parameter | Type | Default | Description | Platform |
|:---:|:---:|:---:|:---|:---|
| `minBufferMs` | `int?` | See [Internal Constants](#-internal-constants) | Min buffer time (ms)<br>Live: 15s<br>VOD: 20s | Android |
| `maxBufferMs` | `int?` | See [Internal Constants](#-internal-constants) | Max buffer time (ms)<br>Live: 15s<br>VOD: 30s | Android |
| `bufferForPlaybackMs` | `int?` | See [Internal Constants](#-internal-constants) | Buffer needed for playback (default 3s) | Android |
| `bufferForPlaybackAfterRebufferMs` | `int?` | See [Internal Constants](#-internal-constants) | Buffer needed after re-buffering (default 5s) | Android |

**Note**: If buffering configuration is not provided, the system will automatically create appropriate default configuration based on whether it's a live stream.

### 🎯 Other Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `placeholder` | `Widget?` | Video placeholder widget |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | Preferred decoder type (default hardwareFirst) |

---

## 📑 11. Subtitle Source Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `type` | `IAppPlayerSubtitlesSourceType` | - | Subtitle source type |
| `name` | `String` | `"Default subtitles"` | Subtitle name (for multi-language selection) |
| `urls` | `List<String>?` | `null` | Subtitle file URL list |
| `content` | `String?` | `null` | Subtitle content string |
| `selectedByDefault` | `bool?` | `null` | Selected by default |
| `headers` | `Map<String, String>?` | `null` | HTTP request headers (network subtitles) |
| `asmsIsSegmented` | `bool?` | `null` | Is segmented subtitle (HLS) |
| `asmsSegmentsTime` | `int?` | `null` | Segment time interval (milliseconds) |
| `asmsSegments` | `List<IAppPlayerAsmsSubtitleSegment>?` | `null` | Subtitle segment list |

### Subtitle Source Types

| Type | Description | Usage |
|:---:|:---|:---|
| `file` | Local file | Provide file path |
| `network` | Network URL | Provide HTTP/HTTPS URL |
| `memory` | Memory string | Provide subtitle content directly |
| `none` | No subtitles | Turn off subtitles option |

### Multi-language Subtitle Example

```dart
subtitles: [
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.network,
    name: "English",
    urls: ["https://example.com/english.srt"],
    selectedByDefault: true,
  ),
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.network,
    name: "Spanish",
    urls: ["https://example.com/spanish.srt"],
  ),
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.none,
    name: "Off",
  ),
],
```

### HLS Segmented Subtitle Example

```dart
// HLS segmented subtitle configuration
subtitles: [
  IAppPlayerSubtitlesSource(
    type: IAppPlayerSubtitlesSourceType.network,
    name: "English Subtitles",
    asmsIsSegmented: true,  // Mark as segmented subtitle
    asmsSegmentsTime: 10000, // 10 seconds per segment
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
      // More segments...
    ],
  ),
],
```

---

## ⚠️ 12. Platform Limitations & Considerations

### 📱 iOS Platform

#### Picture-in-Picture (PiP) Limitations
- Enters fullscreen mode first when entering PiP
- May have brief orientation error when exiting PiP
- Requires configuration in Info.plist

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

#### FairPlay DRM
- Requires certificate URL configuration
- Some implementations may force L3 security level
- Requires proper license server configuration

#### Video Formats
- Native HLS support (.m3u8)
- Other formats supported via FFmpeg
- 30 FPS limitation fixed in latest version

### 🤖 Android Platform

#### Cache
- Multiple player instances may share cache directory
- Recommend setting different cache keys for different videos

```dart
cacheConfiguration: IAppPlayerCacheConfiguration(
  useCache: true,
  key: 'unique_video_id',
),
```

#### ExoPlayer
- Based on ExoPlayer 2.15.1+
- Supports DASH, HLS, SmoothStreaming
- Widevine DRM requires L1 or L3 support

#### Permission Requirements
Add to AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### 🌐 General Limitations

#### Memory Management
- Watch memory usage with multiple simultaneous videos
- Call dispose() promptly to release resources
- Consider pagination for large playlists
- Memory data source creates temporary files, automatically cleaned up on dispose or data source switch

#### Memory Usage Optimization Guidelines

```dart
// Recommended memory usage limits
// Single video instance:
// - 480p: 30-50MB
// - 720p: 50-80MB  
// - 1080p: 80-120MB
// - 4K: 150-200MB

// Device type recommendations:
// Mobile devices:
//   - Max simultaneous playback: 1-2 videos
//   - Cache size: 50-200MB
//   - Preload: Max 1 video

// Tablet devices:
//   - Max simultaneous playback: 2-3 videos
//   - Cache size: 100-500MB
//   - Preload: Max 2 videos

// TV devices:
//   - Max simultaneous playback: 1 video
//   - Cache size: 200MB-1GB
//   - Preload: 2-3 videos
```

#### Network Videos
- HTTPS preferred over HTTP
- Some CDNs may require specific headers
- Cross-origin issues need server CORS configuration

#### Subtitles
- WebVTT format supports HTML tags
- SRT format more universal
- HLS segmented subtitles need correct timestamps

#### URL Validation
- URLs in playlist cannot be empty
- Empty URLs throw `ArgumentError` with specific index location
- Recommend validating URLs before adding

#### Buffer Debounce Mechanism
- Buffer state changes have 500ms default debounce time
- Can adjust debounce time via `setBufferingDebounceTime()` method
- Debounce mechanism avoids frequent buffer state switches, improving user experience

#### ASMS Subtitle Segment Smart Loading
- HLS/DASH segmented subtitles use on-demand loading strategy
- Pre-loads next 5 segment periods based on current playback position
- Avoids loading all subtitle segments at once, saving memory and bandwidth
- Subtitle segment position check has 1 second minimum interval to avoid frequent checks

#### Playlist Resource Management
- `IAppPlayerPlaylistController`'s `dispose` method force-releases internal player controller
- Automatically pauses current video when switching playlists
- Recommend calling `dispose` method when component is destroyed to release all resources

---

<div align="center">

**🎯 This document contains all parameter details and best practices for IAppPlayer**

**👍 If this project helps you, please give it a ⭐ Star!**

**📚 [⬅️ Back to Home](../README.md)   [⬆ Back to Top](#-iappplayer-api-reference-documentation)**

</div>