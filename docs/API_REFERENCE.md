# 📚 IAppPlayer API Reference Documentation

[![Home](https://img.shields.io/badge/🏠-TV%20Treasure%20App%20Store-blue?style=for-the-badge)](https://www.itvapp.net)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?style=for-the-badge&logo=github)](https://github.com/ITVAPP/IAppPlayer)
[![中文](https://img.shields.io/badge/📄-中文-green?style=for-the-badge)](./API_REFERENCE_CN.md)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

---

## 📋 Table of Contents

- [📚 IAppPlayer API Reference Documentation](#-iappplayer-api-reference-documentation)
  - [🎯 I. createPlayer Method Parameters](#-i-createplayer-method-parameters)
  - [🎮 II. PlayerResult Return Value](#-ii-playerresult-return-value)
  - [🎪 III. IAppPlayerEvent Types](#-iii-iappplayerevent-types)
  - [🎛️ IV. Controller Methods](#️-iv-controller-methods)
  - [🛠️ V. Utility Methods](#️-v-utility-methods)
  - [🎭 VI. Decoder Types](#-vi-decoder-types)
  - [⚙️ VII. Player Configuration](#️-vii-player-configuration)
  - [🎚️ VIII. Controls Configuration](#️-viii-controls-configuration)
  - [🎵 IX. Audio Player Display Modes](#-ix-audio-player-display-modes)
  - [📝 X. Subtitle Configuration](#-x-subtitle-configuration)
  - [💾 XI. Data Source Configuration](#-xi-data-source-configuration)
  - [📑 XII. Subtitle Source Configuration](#-xii-subtitle-source-configuration)
  - [⚠️ XIII. Platform Limitations and Notes](#️-xiii-platform-limitations-and-notes)

---

## 🎯 I. createPlayer Method Parameters

### 🔍 URL Format Auto-Detection Rules

The player automatically detects video format and whether it's a live stream based on URL:

| URL Feature | Detection Result | Description |
|:---:|:---:|:---|
| `.m3u8` | HLS format, live stream | HTTP Live Streaming |
| `.mpd` | DASH format, non-live stream | Dynamic Adaptive Streaming |
| `.flv` | Live stream | Flash Video |
| `.ism` | SmoothStreaming format, non-live stream | Microsoft Smooth Streaming |
| `rtmp://` | Live stream | Real-Time Messaging Protocol |
| `rtmps://` | Live stream | Secure RTMP |
| `rtsp://` | Live stream | Real-Time Streaming Protocol |
| `rtsps://` | Live stream | Secure RTSP |

**Note**:
- Detection results are cached for performance
- Can clear cache using `clearAllCaches()`
- Can override auto-detection by explicitly setting `videoFormat` and `liveStream` parameters

### 🔧 Required Parameters (Choose One)

| Parameter | Type | Description |
|:---:|:---:|:---|
| `url` | `String?` | Single video URL (mutually exclusive with urls, must provide one) |
| `urls` | `List<String>?` | Playlist URL array (mutually exclusive with url, must provide one) |

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
| `backgroundImage` | `String?` | `null` | Player background image, supports network images (http:// or https://) and local assets |

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
| `autoPlay` | `bool` | `true` | Auto-play. **Note**: This setting is ignored when switching videos in playlist mode, always auto-plays |
| `loopVideos` | `bool` | `true` | Whether playlist loops |
| `looping` | `bool?` | `null` | Single video loop (null uses configuration default value false). **Note**: Forced to false in playlist mode |
| `startAt` | `Duration?` | `null` | Start playback position |
| `shuffleMode` | `bool?` | `null` | Enable shuffle play mode |
| `nextVideoDelay` | `Duration?` | `null` | Playlist video switch delay time (default 1 second) |
| `initialStartIndex` | `int?` | `null` | Playlist initial play index |

### ⚙️ Advanced Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `isTV` | `bool` | `false` | TV mode, disables notifications and logo download |
| `headers` | `Map<String, String>?` | `null` | HTTP request headers for authenticated video resources |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | `null` | Preferred decoder type (hardware/software/auto) |
| `liveStream` | `bool?` | `null` | Whether live stream (null auto-detects based on URL format) |
| `audioOnly` | `bool?` | `null` | Audio-only mode |

### 🎥 Video Configuration Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `videoFormat` | `IAppPlayerVideoFormat?` | `null` | Video format (null auto-detects based on URL format) |
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
| `rotation` | `double?` | `null` | Video rotation angle (must be multiple of 90 and not exceed 360) |
| `showPlaceholderUntilPlay` | `bool?` | `null` | Show placeholder until play |
| `placeholderOnTop` | `bool?` | `null` | Place placeholder on top |

### 🎛️ Configuration Object Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `playerConfiguration` | `IAppPlayerConfiguration?` | `null` | Player core configuration object |
| `controlsConfiguration` | `IAppPlayerControlsConfiguration?` | `null` | Controls configuration object |
| `subtitlesConfiguration` | `IAppPlayerSubtitlesConfiguration?` | `null` | Subtitle configuration object |
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration?` | `null` | Buffering configuration object |
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | `null` | Cache configuration object |
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | `null` | Notification configuration object |
| `drmConfiguration` | `IAppPlayerDrmConfiguration?` | `null` | DRM configuration object |

### 🎚️ Control Feature Switches

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `enableSubtitles` | `bool?` | `true` | Enable subtitle feature |
| `enableQualities` | `bool?` | `false` | Enable quality selection |
| `enableAudioTracks` | `bool?` | `false` | Enable audio track selection |
| `enableFullscreen` | `bool?` | `true` | Enable fullscreen feature |
| `enableOverflowMenu` | `bool?` | `false` | Enable overflow menu |
| `handleAllGestures` | `bool?` | `true` | Handle all gestures |
| `showNotification` | `bool?` | `true` | Show notification control (TV mode forces false) |

### 📱 Fullscreen Related Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `fullScreenByDefault` | `bool?` | `null` | Default fullscreen playback |
| `fullScreenAspectRatio` | `double?` | `null` | Fullscreen aspect ratio |
| `deviceOrientationsOnFullScreen` | `List<DeviceOrientation>?` | `null` | Device orientations in fullscreen |
| `deviceOrientationsAfterFullScreen` | `List<DeviceOrientation>?` | `null` | Device orientations after fullscreen |
| `systemOverlaysAfterFullScreen` | `List<SystemUiOverlay>?` | `null` | System UI after fullscreen |
| `autoDetectFullscreenDeviceOrientation` | `bool?` | `null` | Auto-detect fullscreen device orientation |
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
| `autoDispose` | `bool?` | `null` | Auto-release resources |
| `allowedScreenSleep` | `bool?` | `null` | Allow screen sleep |
| `expandToFill` | `bool?` | `null` | Expand to fill available space |
| `routePageBuilder` | `IAppPlayerRoutePageBuilder?` | `null` | Custom route page builder |
| `translations` | `List<IAppPlayerTranslations>?` | `null` | Multi-language translation configuration |
| `useRootNavigator` | `bool?` | `null` | Use root navigator |
| `playerVisibilityChangedBehavior` | `Function(double)?` | `null` | Player visibility change callback |

### 💡 Notification Parameters Usage Example

```dart
// Usage example:
IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  title: 'Video Title',           // Video title, also used as notification main title
  imageUrl: 'cover.jpg',         // Video cover, also used as notification icon
  author: 'App Name',            // Notification subtitle (usually app name)
  notificationChannelName: 'com.example.app', // Android notification channel
);
```

### 📌 Playlist Default Values

When using playlist mode, if certain parameters are not provided, the system uses these defaults:

| Scenario | Default Value | Description |
|:---:|:---:|:---|
| No titles provided | `Video 1`, `Video 2`... | Auto-generated incremental default titles |
| No subtitle names | `Subtitle` | Default subtitle name |
| Notification activity name | `MainActivity` | Android default activity name |

---

## 🎮 II. PlayerResult Return Value

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
final activeController = result.activeController;  // Always returns currently active player controller
```

| Property | Type | Description |
|:---:|:---:|:---|
| `controller` | `IAppPlayerController?` | Returns this controller for single video |
| `playlistController` | `IAppPlayerPlaylistController?` | Returns this controller for playlist |
| `isPlaylist` | `bool` | Whether in playlist mode |
| `activeController` | `IAppPlayerController?` | Get currently active controller |

---

## 🎪 III. IAppPlayerEvent Types

### 📡 Event Type Enumeration

| Event Type | Description | Parameters |
|:---:|:---|:---|
| `initialized` | Player initialized | - |
| `play` | Started playing | - |
| `pause` | Paused | - |
| `seekTo` | Seek progress | `{duration: Duration}` |
| `progress` | Progress update (max once per 500ms) | `{progress: Duration, duration: Duration}` |
| `finished` | Video finished | - |
| `exception` | Playback error | `{exception: String}` |
| `bufferingStart` | Buffering started | - |
| `bufferingEnd` | Buffering ended | - |
| `bufferingUpdate` | Buffering progress update | `{buffered: List<Duration>}` |
| `setVolume` | Volume changed | `{volume: double}` |
| `setSpeed` | Speed changed | `{speed: double}` |
| `openFullscreen` | Entered fullscreen | - |
| `hideFullscreen` | Exited fullscreen | - |
| `changedSubtitles` | Subtitle changed | `{subtitlesSource: IAppPlayerSubtitlesSource}` |
| `changedTrack` | Video track changed (HLS multi-bitrate) | `{track: IAppPlayerAsmsTrack}` |
| `changedAudioTrack` | Audio track changed | `{audioTrack: IAppPlayerAsmsAudioTrack}` |
| `changedResolution` | Resolution changed | `{url: String}` |
| `changedPlayerVisibility` | Player visibility changed | `{visible: bool}` |
| `changedPlaylistItem` | Playlist item changed | `{index: int}` |
| `togglePlaylistShuffle` | Toggle shuffle mode triggered | - |
| `changedPlaylistShuffle` | Shuffle mode changed | `{shuffleMode: bool}` |
| `pipStart` | Entered PiP | - |
| `pipStop` | Exited PiP | - |
| `setupDataSource` | Data source set | `{dataSource: IAppPlayerDataSource}` |
| `controlsVisible` | Controls shown | - |
| `controlsHiddenStart` | Controls start hiding | - |
| `controlsHiddenEnd` | Controls hidden | - |

### 🚨 Error Type Classification

Common playback error types (`exception` event):

| Error Type | Description | Handling Suggestion |
|:---:|:---|:---|
| `PlatformException` | Platform-related error | Check device compatibility |
| `FormatException` | Video format not supported | Convert format or use another source |
| `NetworkException` | Network error (403/404/timeout) | Check network connection and URL validity |
| `DrmException` | DRM-related error | Check DRM configuration and license |
| `UnknownException` | Unknown error | Check detailed error info and retry |

### 👂 Event Listening Example

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
      break;
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('Shuffle mode: $shuffleMode');
      break;
    case IAppPlayerEventType.changedAudioTrack:
      final audioTrack = event.parameters?['audioTrack'] as IAppPlayerAsmsAudioTrack?;
      print('Audio track changed: ${audioTrack?.label}');
      break;
  }
}
```

---

## 🎛️ IV. Controller Methods

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
| `setTrack(IAppPlayerAsmsTrack)` | Set video track (HLS multi-bitrate) |
| `setAudioTrack(IAppPlayerAsmsAudioTrack)` | Set audio track |

#### Advanced Features

### 🚦 Controller Methods

| Method | Description | Example |
|:---:|:---|:---|
| `setMixWithOthers(bool)` | Set whether to mix with other audio | `controller.setMixWithOthers(true)` |
| `enablePictureInPicture(GlobalKey)` | Enable PiP (requires GlobalKey) | `controller.enablePictureInPicture(playerKey)` |
| `disablePictureInPicture()` | Disable PiP | `controller.disablePictureInPicture()` |
| `setControlsEnabled(bool)` | Enable/disable controls | `controller.setControlsEnabled(false)` |
| `setControlsAlwaysVisible(bool)` | Set controls always visible | `controller.setControlsAlwaysVisible(true)` |
| `retryDataSource()` | Retry current data source | `controller.retryDataSource()` |
| `clearCache()` | Clear cache | `await controller.clearCache()` |
| `preCache(IAppPlayerDataSource)` | Pre-cache video | `await controller.preCache(dataSource)` |
| `stopPreCache(IAppPlayerDataSource)` | Stop pre-caching | `await controller.stopPreCache(dataSource)` |
| `setBufferingDebounceTime(int)` | Set buffering state debounce time (ms) | `controller.setBufferingDebounceTime(500)` |
| `dispose()` | Release resources | `controller.dispose()` |

### Usage Examples:

```dart
// Mix with other audio (e.g., background music)
controller.setMixWithOthers(true);

// Enable Picture-in-Picture
final GlobalKey playerKey = GlobalKey();
controller.setIAppPlayerGlobalKey(playerKey);
controller.enablePictureInPicture(playerKey);

// Disable controls for kiosk mode
controller.setControlsEnabled(false);

// Keep controls visible for tutorials
controller.setControlsAlwaysVisible(true);

// Retry on network error
if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
  controller.retryDataSource();
}

// Clear cache to free storage
await controller.clearCache();

// Pre-cache next video
final nextVideo = IAppPlayerDataSource.network('https://example.com/video2.mp4');
await controller.preCache(nextVideo);

// Adjust buffering sensitivity
controller.setBufferingDebounceTime(1000); // 1 second

// Clean up when done
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### 📊 Property Getters

| Property/Method | Return Type | Description |
|:---:|:---:|:---|
| `isPlaying()` | `bool` | Whether playing |
| `isBuffering()` | `bool` | Whether buffering |
| `isVideoInitialized()` | `bool` | Whether video initialized |
| `isFullScreen` | `bool` | Whether fullscreen |
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
| `dispose()` | Release resources | `playlistController.dispose()` |

### 📈 Playlist Property Getters

| Property | Type | Description |
|:---:|:---:|:---|
| `currentDataSourceIndex` | `int` | Current play index |
| `dataSourceList` | `List<IAppPlayerDataSource>` | Get data source list (read-only) |
| `hasNext` | `bool` | Has next item |
| `hasPrevious` | `bool` | Has previous item |
| `shuffleMode` | `bool` | Current shuffle mode state |
| `iappPlayerController` | `IAppPlayerController?` | Get internal player controller |

---

## 🛠️ V. Utility Methods

### 🎯 IAppPlayerConfig Static Methods

| Method | Description | Use Case |
|:---:|:---|:---|
| `playSource()` | Simplified source switching method | Dynamic video source switching |
| `clearAllCaches()` | Clear URL format detection cache | Release memory or force URL format re-detection |
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
  String? title,
  String? imageUrl,
  String? author,
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

**Note**: Although `source` parameter type is `dynamic`, it must be passed as `String`, otherwise will throw `ArgumentError`.

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

### 🎯 createDataSource Method

Create data source object for building complex video configurations.

```dart
static IAppPlayerDataSource createDataSource({
  required String url,
  bool? liveStream,
  Map<String, String>? headers,
  String? title,
  String? imageUrl,
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

### 🎮 createPlayerConfig Method

Create player configuration object.

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
  bool? looping,  // Dynamically set based on liveStream (non-live default true, live default false)
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

### 📋 createPlaylistConfig Method

Create playlist configuration object.

```dart
static IAppPlayerPlaylistConfiguration createPlaylistConfig({
  bool shuffleMode = false,
  bool loopVideos = true,
  Duration nextVideoDelay = const Duration(seconds: 1),  // Default 1 second delay
  int initialStartIndex = 0,
})
```

**Note**:
- `IAppPlayerPlaylistConfiguration` class itself has a default switch delay of 3 seconds, but `createPlaylistConfig` method uses 1 second as default
- Playlist shows countdown UI after video ends, users can skip wait time to play next video immediately

### 🎵 createPlaylistPlayer Method

Create playlist player with custom data sources.

```dart
static PlayerResult createPlaylistPlayer({
  required Function(IAppPlayerEvent) eventListener,
  required List<IAppPlayerDataSource> dataSources,
  bool shuffleMode = false,
  bool loopVideos = true,
  Duration nextVideoDelay = const Duration(seconds: 1),
  int initialStartIndex = 0,
  IAppPlayerConfiguration? playerConfiguration,
})
```

---

## 🎭 VI. Decoder Types

### 🎨 IAppPlayerDecoderType Options

| Type | Description | Use Case |
|:---:|:---|:---|
| `auto` | Auto-select decoder | System decides best decoder |
| `hardwareFirst` | Prefer hardware decoding, auto-switch to software on failure | Recommended, best performance |
| `softwareFirst` | Prefer software decoding, auto-switch to hardware on failure | Specific device compatibility issues |

### 💡 Usage Recommendations

```dart
// General case (recommend hardware decoding)
preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,

// Software decoding first
preferredDecoderType: IAppPlayerDecoderType.softwareFirst,

// Auto selection
preferredDecoderType: IAppPlayerDecoderType.auto,
```

---

## ⚙️ VII. Player Configuration

### 🎮 Playback Behavior Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `autoPlay` | `bool` | `true` | Auto-play. **Note**: Ignored when switching videos in playlist mode, always auto-plays |
| `startAt` | `Duration?` | `null` | Video start playback position |
| `looping` | `bool` | `false` | Single video loop. **Note**:<br>1. `createPlayerConfig()` dynamically sets based on `liveStream` (non-live default true, live default false)<br>2. Forced to false in playlist mode |
| `handleLifecycle` | `bool` | `true` | Auto-handle app lifecycle (pause in background) |
| `autoDispose` | `bool` | `false` | Auto-release resources. Set to false requires manual `dispose()` call, useful for complex UI to avoid early release |

### 🎨 Display Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `aspectRatio` | `double?` | `null` | Video aspect ratio, null means adaptive |
| `fit` | `BoxFit` | `BoxFit.fill` | Video scaling mode |
| `rotation` | `double` | `0` | Video rotation angle (must be multiple of 90 and not exceed 360) |
| `expandToFill` | `bool` | `true` | Expand to fill all available space |

#### BoxFit Scaling Mode Description

| Mode | Description |
|:---:|:---|
| `BoxFit.fill` | Fill entire container, may distort |
| `BoxFit.contain` | Maintain aspect ratio, show completely |
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
| `placeholderOnTop` | `bool` | `true` | Placeholder above video layer |

### 📱 Fullscreen Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `fullScreenByDefault` | `bool` | `false` | Default fullscreen playback |
| `allowedScreenSleep` | `bool` | `false` | Allow screen sleep in fullscreen |
| `fullScreenAspectRatio` | `double?` | `null` | Fullscreen aspect ratio |
| `autoDetectFullscreenDeviceOrientation` | `bool` | `false` | Auto-detect fullscreen orientation |
| `autoDetectFullscreenAspectRatio` | `bool` | `false` | Auto-detect fullscreen aspect ratio |
| `deviceOrientationsOnFullScreen` | `List<DeviceOrientation>` | `[landscapeLeft, landscapeRight]` | Allowed device orientations in fullscreen |
| `deviceOrientationsAfterFullScreen` | `List<DeviceOrientation>` | `[portraitUp, portraitDown, landscapeLeft, landscapeRight]` | Device orientations after fullscreen |
| `systemOverlaysAfterFullScreen` | `List<SystemUiOverlay>` | `SystemUiOverlay.values` | System UI after fullscreen |

### 🎯 Other Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `overlay` | `Widget?` | `null` | Overlay widget on video |
| `errorBuilder` | `Function?` | `null` | Custom error widget builder |
| `eventListener` | `Function?` | `null` | Event listener |
| `routePageBuilder` | `Function?` | `null` | Custom fullscreen page route builder |
| `translations` | `List<IAppPlayerTranslations>?` | `null` | Multi-language translation configuration |
| `playerVisibilityChangedBehavior` | `Function?` | `null` | Player visibility change callback (receives 0.0-1.0 visibility value) |
| `subtitlesConfiguration` | `IAppPlayerSubtitlesConfiguration` | - | Subtitle configuration |
| `controlsConfiguration` | `IAppPlayerControlsConfiguration` | - | Controls configuration |
| `useRootNavigator` | `bool` | `false` | Use root navigator |

### 📊 Visibility Callback Description

`playerVisibilityChangedBehavior` works based on VisibilityDetector for handling auto-play/pause in lists:

```dart
// Example: Pause when player visibility below 50%, play when above 80%
playerVisibilityChangedBehavior: (visibilityFraction) {
  // visibilityFraction: 0.0 = completely invisible, 1.0 = completely visible
  if (visibilityFraction < 0.5 && controller.isPlaying()) {
    controller.pause();
  } else if (visibilityFraction > 0.8 && !controller.isPlaying()) {
    controller.play();
  }
}
```

### 🌐 Multi-language Configuration

`IAppPlayerTranslations` structure:

```dart
class IAppPlayerTranslations {
  final String languageCode;           // Language code (e.g., zh, en, ja)
  final String generalDefaultError;    // Default error message
  final String generalNone;            // "None" option text
  final String generalDefault;         // "Default" text
  final String generalRetry;           // "Retry" button text
  final String playlistLoadingNextVideo; // Loading next video prompt
  final String playlistUnavailable;    // Playlist unavailable prompt
  final String playlistTitle;          // Playlist title
  final String videoItem;              // Video item format (contains {index} placeholder)
  final String trackItem;              // Track item format (contains {index} placeholder)
  final String controlsLive;           // "Live" label text
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

| Language Code | Language | Usage |
|:---:|:---|:---|
| `zh` | Chinese Simplified | `IAppPlayerTranslations.chinese()` |
| `zh-Hant` | Chinese Traditional | `IAppPlayerTranslations.traditionalChinese()` |
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
// Use Chinese Simplified
translations: [
  IAppPlayerTranslations.chinese(),
],

// Use multiple languages (system auto-selects based on device language)
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
    controlsNextIn: 'Next in',
    overflowMenuPlaybackSpeed: 'Playback speed',
    overflowMenuSubtitles: 'Subtitles',
    overflowMenuQuality: 'Quality',
    overflowMenuAudioTracks: 'Audio tracks',
    qualityAuto: 'Auto',
  ),
],
```

---

## 🎚️ VIII. Controls Configuration

### 🎨 Color Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `controlBarColor` | `Color` | `Colors.transparent` | Control bar background color |
| `textColor` | `Color` | `Colors.white` | Text color |
| `iconsColor` | `Color` | `Colors.white` | Icon color |
| `liveTextColor` | `Color` | `Colors.red` | Live label text color |
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

### 🔧 Feature Switches

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `showControls` | `bool` | `true` | Show controls |
| `showControlsOnInitialize` | `bool` | `true` | Show controls on initialization |
| `enableFullscreen` | `bool` | `true` | Enable fullscreen feature |
| `enableMute` | `bool` | `true` | Enable mute feature |
| `enableProgressText` | `bool` | `true` | Show progress time text |
| `enableProgressBar` | `bool` | `true` | Show progress bar |
| `enableProgressBarDrag` | `bool` | `true` | Allow dragging progress bar |
| `enablePlayPause` | `bool` | `true` | Enable play/pause button |
| `enableSkips` | `bool` | `true` | Enable skip forward/back |
| `enableAudioTracks` | `bool` | `true` | Enable audio track selection |
| `enableSubtitles` | `bool` | `true` | Enable subtitle feature |
| `enableQualities` | `bool` | `true` | Enable quality selection |
| `enablePip` | `bool` | `true` | Enable picture-in-picture |
| `enableRetry` | `bool` | `true` | Enable retry feature |
| `enableOverflowMenu` | `bool` | `true` | Enable overflow menu |
| `enablePlaybackSpeed` | `bool` | `true` | Enable playback speed adjustment |

### 📱 Menu Icons

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `overflowMenuIcon` | `IconData` | `Icons.more_vert_outlined` | Overflow menu icon |
| `pipMenuIcon` | `IconData` | `Icons.picture_in_picture_outlined` | PiP icon |
| `playbackSpeedIcon` | `IconData` | `Icons.shutter_speed_outlined` | Speed adjustment icon |
| `qualitiesIcon` | `IconData` | `Icons.hd_outlined` | Quality selection icon |
| `subtitlesIcon` | `IconData` | `Icons.closed_caption_outlined` | Subtitle icon |
| `audioTracksIcon` | `IconData` | `Icons.audiotrack_outlined` | Audio track icon |

### 📋 Overflow Menu

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `overflowMenuCustomItems` | `List<IAppPlayerOverflowMenuItem>` | `[]` | Custom menu items |
| `overflowModalColor` | `Color` | `Colors.white` | Menu background color |
| `overflowModalTextColor` | `Color` | `Colors.black` | Menu text color |
| `overflowMenuIconsColor` | `Color` | `Colors.black` | Menu icon color |

#### IAppPlayerOverflowMenuItem Complete Properties

```dart
class IAppPlayerOverflowMenuItem {
  final String title;           // Menu item title
  final IconData icon;         // Menu item icon
  final Function() onClicked;  // Click callback
  final bool Function()? isEnabled;  // Optional: Control enabled state
  
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
| `controlsHideTime` | `Duration` | `Duration(seconds: 3)` | Controls auto-hide time. **Note**: Audio controls don't auto-hide |
| `controlBarHeight` | `double` | `30.0` | Control bar height |
| `forwardSkipTimeInMilliseconds` | `int` | `10000` | Forward skip time (ms) |
| `backwardSkipTimeInMilliseconds` | `int` | `10000` | Backward skip time (ms) |
| `loadingWidget` | `Widget?` | `null` | Custom loading widget |
| `audioOnly` | `bool` | `false` | Audio-only mode (hide video, show audio controls) |
| `handleAllGestures` | `bool` | `true` | Player doesn't intercept gestures |
| `customControlsBuilder` | `Function?` | `null` | Custom controls builder |
| `playerTheme` | `IAppPlayerTheme?` | `null` | Player theme |

### 🎨 Player Themes

`IAppPlayerTheme` enum values:

| Theme | Description | Effect |
|:---:|:---|:---|
| `video` | Video style (default) | Controls designed for video |
| `audio` | Audio style | Controls designed for audio |
| `custom` | Custom controls | Use customControlsBuilder |

---

## 🎵 IX. Audio Player Display Modes

Audio controls automatically switch display modes based on player dimensions for best user experience.

### 📐 Display Mode Rules

| Mode | Conditions | Description |
|:---:|:---|:---|
| **Square Mode** | `aspectRatio = 1.0` (1% tolerance) | Cover fills + centered play button |
| **Compact Mode** | `aspectRatio = 2.0` (1% tolerance) or height ≤ 200px | Horizontal layout, left cover + right controls |
| **Extended Mode** | All other cases | Vinyl animation + full control bar |

### 🎨 Mode Features

#### 📦 Square Mode
- Cover image fills entire area
- Cover scaled 10% to avoid black edges
- Semi-transparent black overlay
- Centered circular play/pause button
- Suitable for: Single track display, album cover showcase

#### 🎯 Compact Mode
- Left square cover (height adaptive)
- Cover scaled 10% to avoid black edges
- Right gradient transition to control area
- Top: Remaining time, mode switch, fullscreen button
- Middle: Song info (artist, title)
- Bottom: Progress bar and playback controls
- Suitable for: Playlists, embedded players

#### 🎭 Extended Mode
- Random gradient background + glass effect
- Rotating vinyl disc animation
- Cover image in disc center
- Disc texture and center label design
- Full control bar and progress bar
- Suitable for: Fullscreen playback, music appreciation

### 💡 Usage Suggestions

```dart
// Square mode example (1:1 ratio)
IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 1.0,  // Triggers square mode
);

// Compact mode example (2:1 ratio)
IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 2.0,  // Triggers compact mode
);

// Extended mode example (other ratios)
IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 16/9,  // Triggers extended mode
);
```

### 🎵 Lyrics Display Support

All modes support LRC lyrics display:
- Square mode: Lyrics processed internally, not shown in UI
- Compact mode: Lyrics processed internally, not shown in UI
- Extended mode: Lyrics shown above progress bar

Get current lyrics via `controller.renderedSubtitle`:

```dart
// Get current lyrics
final subtitle = controller.renderedSubtitle;
if (subtitle != null && subtitle.texts != null) {
  final currentLyric = subtitle.texts!.join(' ');
  print('Current lyrics: $currentLyric');
}
```

---

## 📝 X. Subtitle Configuration

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

### 📏 Margin Configuration

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
| `LRC` | Lyrics format | `.lrc` files, suitable for music |
| `HLS Subtitles` | HLS embedded subtitles | Auto-detected |
| `DASH Subtitles` | DASH embedded subtitles | Auto-detected |

---

## 💾 XI. Data Source Configuration

### 🎯 Basic Parameters

| Parameter | Type | Description |
|:---:|:---:|:---|
| `type` | `IAppPlayerDataSourceType` | Data source type (network/file/memory) |
| `url` | `String` | Video URL or file path |
| `bytes` | `List<int>?` | Byte array for memory data source |

#### Data Source Type Description

| Type | Description | Use Case |
|:---:|:---|:---|
| `network` | Network video | Online video playback |
| `file` | Local file | Downloaded videos |
| `memory` | Memory data | Encrypted videos or dynamically generated |

### 📺 Video Format

| Parameter | Type | Description |
|:---:|:---:|:---|
| `videoFormat` | `IAppPlayerVideoFormat?` | Video format (hls/dash/ss/other) |
| `videoExtension` | `String?` | Video file extension |
| `liveStream` | `bool?` | Whether live stream |

#### Video Format Description

| Format | Description | File Extension |
|:---:|:---|:---|
| `hls` | HTTP Live Streaming | `.m3u8` |
| `dash` | Dynamic Adaptive Streaming | `.mpd` |
| `ss` | Smooth Streaming | `.ism/manifest` |
| `other` | Other formats | `.mp4`, `.webm`, `.mkv` etc. |

#### Supported Video Formats

| Platform | Supported Formats |
|:---:|:---|
| **Android** | MP4, WebM, MKV, MP3, AAC, HLS(.m3u8), DASH(.mpd), SmoothStreaming, FLV, AVI, MOV, TS |
| **iOS** | MP4, M4V, MOV, MP3, HLS(.m3u8), AAC |
| **Web** | Depends on browser (usually MP4, WebM, HLS) |

### 📑 Subtitle Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `subtitles` | `List<IAppPlayerSubtitlesSource>?` | Subtitle source list |
| `useAsmsSubtitles` | `bool` | Use HLS/DASH embedded subtitles |

### 🎵 Audio/Video Tracks (ASMS)

| Parameter | Type | Description |
|:---:|:---:|:---|
| `useAsmsTracks` | `bool` | Use HLS tracks |
| `useAsmsAudioTracks` | `bool` | Use HLS/DASH audio tracks |
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

**Note**: When track height, width, and bitrate are all 0, it displays as "Auto".

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
  "Auto": "auto",  // Special value for auto-selection
}
```

### 💾 Cache Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `cacheConfiguration` | `IAppPlayerCacheConfiguration?` | `null` | Cache configuration object |

#### IAppPlayerCacheConfiguration Parameters

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `useCache` | `bool` | `true`(VOD) / `false`(live) | Enable cache (auto-set based on live/VOD) |
| `preCacheSize` | `int` | 10MB | Pre-cache size (10 * 1024 * 1024 bytes) |
| `maxCacheSize` | `int` | 300MB | Max cache size (300 * 1024 * 1024 bytes) |
| `maxCacheFileSize` | `int` | 50MB | Max single file cache size (50 * 1024 * 1024 bytes) |
| `key` | `String?` | `null` | Cache key to distinguish different videos |

#### Cache Key Naming Convention

```dart
// Recommended cache key naming convention
// Format: [AppName]_[Type]_[UniqueID]_[Version]
cacheConfiguration: IAppPlayerCacheConfiguration(
  useCache: true,
  key: 'myapp_video_${videoId}_v1',
),

// Examples
// Movie: myapp_movie_tt0111161_v1
// Series: myapp_series_s01e01_12345_v1  
// Live: Don't use cache
// User video: myapp_user_${userId}_${videoId}_v1
```

#### Cache Feature Platform Support

| Feature | Android HLS | Android non-HLS | iOS HLS | iOS non-HLS |
|:---:|:---:|:---:|:---:|:---:|
| Normal cache | ✓ | ✓ | ✓ | ✓ |
| Pre-cache | ✓ | ✓ | ✗ | ✓ |
| Stop cache | ✓ | ✓ | ✗ | ✓ |

**Note**: iOS platform has limited cache support for HLS streams.

### 🔔 Notification Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `notificationConfiguration` | `IAppPlayerNotificationConfiguration?` | `null` | Notification configuration (not created in TV mode) |

#### IAppPlayerNotificationConfiguration Structure

Notification configuration object for controlling player notification bar display.

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `showNotification` | `bool?` | `null` | Show notification |
| `activityName` | `String?` | `MainActivity` | Android Activity name |

**Note**:
- Notification configuration is not created in TV mode, even if parameters are set
- Default is `showNotification: false` when created in `IAppPlayerDataSource`

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

// ClearKey DRM (Android)
drmConfiguration: IAppPlayerDrmConfiguration(
  drmType: IAppPlayerDrmType.clearkey,
  clearKey: '{"keys":[{"kty":"oct","k":"GawgguFyGrWKav7AX4VKUg","kid":"nrQFDeRLSAKTLifXUIPiZg"}]}',
),
```

#### ClearKey Generation Steps (Android only)

1. Create `drm_file.xml` configuration file
2. Generate encrypted file using MP4Box:
   ```bash
   MP4Box -crypt drm_file.xml input.mp4 -out encrypted_tmp.mp4
   MP4Box -frag 240000 encrypted_tmp.mp4 -out encrypted.mp4
   ```

### ⏸️ Buffering Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `bufferingConfiguration` | `IAppPlayerBufferingConfiguration` | Buffering configuration |

#### IAppPlayerBufferingConfiguration Parameters

| Parameter | Type | Default | Description | Platform |
|:---:|:---:|:---:|:---|:---|
| `minBufferMs` | `int` | 15000(live) / 20000(VOD) | Min buffer time (ms) | Android |
| `maxBufferMs` | `int` | 15000(live) / 30000(VOD) | Max buffer time (ms) | Android |
| `bufferForPlaybackMs` | `int` | 3000 | Buffer needed for playback | Android |
| `bufferForPlaybackAfterRebufferMs` | `int` | 5000 | Buffer needed after rebuffering | Android |

**Note**: If no buffering configuration is provided, system automatically creates appropriate default configuration based on whether it's a live stream.

### 🎯 Other Configuration

| Parameter | Type | Description |
|:---:|:---:|:---|
| `placeholder` | `Widget?` | Video placeholder widget |
| `preferredDecoderType` | `IAppPlayerDecoderType?` | Preferred decoder type |

---

## 📑 XII. Subtitle Source Configuration

| Parameter | Type | Default | Description |
|:---:|:---:|:---:|:---|
| `type` | `IAppPlayerSubtitlesSourceType` | - | Subtitle source type (required) |
| `name` | `String` | `"Default subtitles"` | Subtitle name (required) |
| `urls` | `List<String>?` | `null` | Subtitle file URL list |
| `content` | `String?` | `null` | Subtitle content string |
| `selectedByDefault` | `bool?` | `null` | Selected by default |
| `headers` | `Map<String, String>?` | `null` | HTTP request headers (network subtitles) |
| `asmsIsSegmented` | `bool?` | `null` | Whether segmented subtitles (HLS) |
| `asmsSegmentsTime` | `int?` | `null` | Segment time interval (ms) |
| `asmsSegments` | `List<IAppPlayerAsmsSubtitleSegment>?` | `null` | Subtitle segment list |

### Subtitle Source Types

| Type | Description | Usage |
|:---:|:---|:---|
| `file` | Local file | Provide file path |
| `network` | Network URL | Provide HTTP/HTTPS URL |
| `memory` | Memory string | Provide subtitle content directly |
| `none` | No subtitles | Turn off subtitle option |

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
    asmsIsSegmented: true,  // Mark as segmented subtitles
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
    ],
  ),
],
```

---

## ⚠️ XIII. Platform Limitations and Notes

### 📱 iOS Platform

#### Picture-in-Picture (PiP) Limitations
- Enters fullscreen mode first when entering PiP
- May have brief orientation issue when exiting PiP
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

### 🤖 Android Platform

#### Caching
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
- Watch memory usage when playing multiple videos simultaneously
- Call dispose() promptly to release resources
- Large playlists recommend pagination loading
- Memory data sources create temporary files, auto-cleaned on dispose or source switch

#### Network Videos
- HTTPS preferred over HTTP
- Some CDNs may require specific request headers
- Cross-origin issues require server CORS configuration

#### Subtitles
- WebVTT format supports HTML tags
- SRT format more universal
- HLS segmented subtitles require correct timestamps

#### URL Validation
- URLs in playlists cannot be empty
- Empty URLs throw `ArgumentError` exception
- Recommend validating URLs before adding

#### Buffering Debounce Mechanism
- Buffering state changes have 500ms default debounce time
- Can adjust debounce time via `setBufferingDebounceTime()` method
- Debounce mechanism avoids frequent buffering state switches, improving user experience

#### HLS Segmented Subtitle Smart Loading
- HLS/DASH segmented subtitles use on-demand loading strategy
- Pre-loads next 5 subtitle segments based on current playback position
- Avoids loading all subtitle segments at once, saving memory and bandwidth

#### Playlist Resource Management
- `IAppPlayerPlaylistController`'s `dispose` method forcefully releases internal player controller
- Automatically pauses current video when switching playlists
- Recommend calling `dispose` method when destroying components to release all resources

---

<div align="center">

**🎯 This document contains detailed API reference and best practices for IAppPlayer**

**👍 If this project helps you, please give it a ⭐ Star!**

**📚 [⬅️ Back to Home](../README.md)   [⬆ Back to Top](#-iappplayer-api-reference-documentation)**

</div>
