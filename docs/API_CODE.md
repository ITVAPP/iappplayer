# 📚 IAppPlayer Common Examples Documentation

[![Back to Home](https://img.shields.io/badge/🏠-TV%20Treasure%20App%20Store-blue?style=for-the-badge)](https://www.itvapp.net)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?style=for-the-badge&logo=github)](https://github.com/ITVAPP/IAppPlayer)
[![中文](https://img.shields.io/badge/📄-中文-green?style=for-the-badge)](./API_CODE_CN.md)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

---

## 📋 Table of Contents

- [📚 IAppPlayer Common Examples Documentation](#-iappplayer-common-examples-documentation)
  - [📋 Table of Contents](#-table-of-contents)
  - [⚠️ Important Notes](#️-important-notes)
  - [🎯 I. Common Parameter Combinations](#-i-common-parameter-combinations)
  - [🚀 II. Performance Optimization Suggestions](#-ii-performance-optimization-suggestions)
  - [🔧 III. Common Problem Solutions](#-iii-common-problem-solutions)

---

## ⚠️ Important Notes

### Parameter Exclusivity
- `url` and `urls` parameters **cannot be used simultaneously**, the system will throw an `ArgumentError`
- Use `url` parameter for single video
- Use `urls` parameter for playlists

### URL Validation
- URLs cannot be empty strings
- Each URL in a playlist will be validated, empty URLs will throw an error

### Return Value Handling
- When no valid URL is provided, `createPlayer` returns an empty `PlayerResult` object
- Check if `result.activeController` is null before use

### Asynchronous Calls
- `createPlayer` is an asynchronous method that returns `Future<PlayerResult>`
- Use the `await` keyword when calling

### URL Format Auto-Detection
The player automatically detects URL formats and supports URLs with query parameters. Detection removes query parameters (after `?`) first, then checks file extensions. Supported formats include:
- `.m3u8` - HLS format, automatically recognized as live stream
- `.mpd` - DASH format
- `.flv` - FLV format, automatically recognized as live stream
- `rtmp://`, `rtsp://` - Streaming protocols, automatically recognized as live streams

### Live Stream Special Configuration
Live streams automatically apply these special configurations:
- No caching - Live content requires real-time delivery
- Enable HLS tracks - Support multi-bitrate switching
- Enable audio track selection - Support multi-language audio
- Disable looping - Live streams don't support looping

---

## 🎯 I. Common Parameter Combinations

### 🎬 1. Simplest Video Playback

```dart
// createPlayer returns PlayerResult object
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
);

// Check if player was created successfully
if (result.activeController == null) {
  print('Player creation failed, please check if URL is valid');
  return;
}

// Use the controller
final controller = result.activeController;
```

### 📑 2. Video with Subtitles

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  title: 'Video Title',
  subtitleUrl: 'https://example.com/subtitles.srt',
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
      print('Player initialized');
    }
  },
);
```

### 🎵 3. Music Player (with LRC Lyrics)

```dart
// Single audio file playback - Square mode
final squareMusicPlayer = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: 'Song Name',
  audioOnly: true,
  aspectRatio: 1.0,  // Square mode
  subtitleContent:     '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人''',  // LRC lyrics content
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
      // Get current lyrics
      final subtitle = result.activeController?.renderedSubtitle;
      if (subtitle != null && subtitle.texts != null) {
        final currentLyric = subtitle.texts!.join(' ');
        print('Current lyrics: $currentLyric');
      }
    }
  },
);

// Compact mode music player
final compactMusicPlayer = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: 'Song Name',
  audioOnly: true,
  aspectRatio: 2.0,  // Compact mode (2:1 ratio)
  subtitleContent: lrcContent,
);

// Music playlist
final musicPlaylist = await IAppPlayerConfig.createPlayer(
  urls: [
    'https://example.com/song1.mp3',
    'https://example.com/song2.mp3',
    'https://example.com/song3.mp3',
  ],
  titles: ['Song 1', 'Song 2', 'Song 3'],
  imageUrls: [  // Album covers
    'https://example.com/album1.jpg',
    'https://example.com/album2.jpg',
    'https://example.com/album3.jpg',
  ],
  subtitleContents: [  // LRC lyrics
    '''[00:02.05]May I have your heart
[00:08.64]Lyrics: Hu Xiaojian Music: Luo Junlin''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody''',
    '''[00:01.00]Third Song
[00:06.00]This is sample lyrics''',
  ],
  audioOnly: true,
  shuffleMode: true,  // Shuffle play
  autoPlay: true,
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistItem) {
      final index = event.parameters?['index'] as int?;
      print('Switched to song ${index! + 1}');
    }
  },
);
```

### 📺 4. Live Stream (HLS)

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/live.m3u8',
  title: 'Live Channel',
  autoPlay: true,
  looping: false,     // No looping for live streams
  liveStream: true,   // Explicitly specify as live stream (usually auto-detected)
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.bufferingStart) {
      print('Buffering started');
    } else if (event.iappPlayerEventType == IAppPlayerEventType.bufferingEnd) {
      print('Buffering ended');
    }
  },
);
```

### 🔐 5. Authenticated Video

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
      print('Playback error: $error');
    }
  },
);
```

### 📺 6. TV Mode (Notifications Disabled)

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  isTV: true,  // TV mode, automatically disables notifications
  autoPlay: true,
  eventListener: (event) {},
);
```

### 🎯 7. Advanced Playlist

```dart
// Create data source list
final dataSources = [
  IAppPlayerConfig.createDataSource(
    url: 'https://example.com/video1.mp4',
    liveStream: false,
    title: 'Video 1',
    subtitleUrl: 'https://example.com/sub1.srt',
    headers: {'Authorization': 'Bearer token1'},
  ),
  IAppPlayerConfig.createDataSource(
    url: 'https://example.com/live.m3u8',
    liveStream: true,
    title: 'Live Stream',
  ),
  IAppPlayerConfig.createDataSource(
    url: 'https://example.com/drm_video.mpd',
    liveStream: false,
    title: 'DRM Protected Video',
    drmConfiguration: IAppPlayerDrmConfiguration(
      drmType: IAppPlayerDrmType.widevine,
      licenseUrl: 'https://example.com/license',
    ),
  ),
];

// Create advanced playlist
final result = IAppPlayerConfig.createPlaylistPlayer(
  eventListener: (event) {},
  dataSources: dataSources,
  shuffleMode: false,
  loopVideos: true,
  initialStartIndex: 0,
);
```

### 🔄 8. Dynamic Source Switching

```dart
// Initial player
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video1.mp4',
  eventListener: (event) {},
);

// Switch to new video later
await IAppPlayerConfig.playSource(
  controller: result.activeController!,
  source: 'https://example.com/video2.mp4',
  title: 'New Video',
  subtitleUrl: 'https://example.com/new_sub.srt',
);

// Preload next video (without playing)
await IAppPlayerConfig.playSource(
  controller: result.activeController!,
  source: 'https://example.com/next_video.mp4',
  preloadOnly: true,  // Preload only
);
```

### 👂 9. Complete Event Handling Example

```dart
eventListener: (IAppPlayerEvent event) {
  switch (event.iappPlayerEventType) {
    case IAppPlayerEventType.initialized:
      print('Player initialized');
      final duration = result.activeController?.videoPlayerController?.value.duration;
      print('Total duration: ${duration?.inSeconds} seconds');
      break;
      
    case IAppPlayerEventType.play:
      print('Started playing');
      break;
      
    case IAppPlayerEventType.pause:
      print('Paused');
      break;
      
    case IAppPlayerEventType.progress:
      final progress = event.parameters?['progress'] as Duration?;
      final duration = event.parameters?['duration'] as Duration?;
      if (progress != null && duration != null) {
        final percent = (progress.inSeconds / duration.inSeconds * 100).toStringAsFixed(1);
        print('Progress: $percent%');
      }
      break;
      
    case IAppPlayerEventType.bufferingStart:
      print('Buffering...');
      break;
      
    case IAppPlayerEventType.bufferingEnd:
      print('Buffering complete');
      break;
      
    case IAppPlayerEventType.finished:
      print('Playback finished');
      break;
      
    case IAppPlayerEventType.exception:
      final error = event.parameters?['exception'];
      print('Playback error: $error');
      break;
      
    case IAppPlayerEventType.openFullscreen:
      print('Entered fullscreen');
      break;
      
    case IAppPlayerEventType.hideFullscreen:
      print('Exited fullscreen');
      break;
      
    case IAppPlayerEventType.changedPlaylistItem:
      final index = event.parameters?['index'] as int?;
      print('Switched to playlist item ${index! + 1}');
      break;
      
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('Shuffle mode: ${shuffleMode ? "On" : "Off"}');
      break;
      
    default:
      break;
  }
}
```

### 🎮 10. Controller Usage Examples

```dart
// Basic playback control
result.activeController?.play();
result.activeController?.pause();
result.activeController?.seekTo(Duration(minutes: 5, seconds: 30));
result.activeController?.setVolume(0.8);
result.activeController?.setSpeed(1.5);

// Fullscreen control
result.activeController?.enterFullScreen();
result.activeController?.exitFullScreen();
result.activeController?.toggleFullScreen();

// Subtitle control
final subtitleSource = IAppPlayerSubtitlesSource(
  type: IAppPlayerSubtitlesSourceType.network,
  urls: ['https://example.com/new_subtitle.srt'],
  name: 'English Subtitles',
);
result.activeController?.setupSubtitleSource(subtitleSource);

// Get playback status
final isPlaying = result.activeController?.isPlaying() ?? false;
final isBuffering = result.activeController?.isBuffering() ?? false;
final isInitialized = result.activeController?.isVideoInitialized() ?? false;

// Get current lyrics (for music player)
final subtitle = result.activeController?.renderedSubtitle;
if (subtitle != null && subtitle.texts != null && subtitle.texts!.isNotEmpty) {
  final currentLyric = subtitle.texts!.join(' ');
  print('Current lyrics: $currentLyric');
}

// Playlist control
if (result.isPlaylist) {
  result.playlistController?.playNext();
  result.playlistController?.playPrevious();
  result.playlistController?.setupDataSource(3); // Play the 4th video
  result.playlistController?.toggleShuffleMode();
  
  // Get playlist information
  final currentIndex = result.playlistController?.currentDataSourceIndex ?? 0;
  final totalVideos = result.playlistController?.dataSourceList.length ?? 0;
  print('Now playing: ${currentIndex + 1}/$totalVideos');
}

// Release resources
result.activeController?.dispose();
result.playlistController?.dispose();
```

### 🎨 11. Custom Controls Example

```dart
// Set custom controls configuration when creating player
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

### 📊 12. Multi-Resolution Switching Example

```dart
// Create data source with multiple resolutions
final dataSource = IAppPlayerConfig.createDataSource(
  url: 'https://example.com/video_720p.mp4',
  liveStream: false,
  resolutions: {
    "360p": "https://example.com/video_360p.mp4",
    "720p": "https://example.com/video_720p.mp4",
    "1080p": "https://example.com/video_1080p.mp4",
    "Auto": "auto",
  },
);

// Apply data source
await result.controller?.setupDataSource(dataSource);
```

### 🌐 13. Network Error Handling Example

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
      final error = event.parameters?['exception'] as String?;
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Playback Error'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Retry playback
                result.activeController?.retryDataSource();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
  },
);
```

### 🎵 14. Audio Player Display Mode Examples

```dart
// Square mode (1:1) - Suitable for single track display
final squarePlayer = await IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 1.0,  // Triggers square mode
  title: 'Song Name',
  imageUrl: 'album_cover.jpg',
  subtitleContent: lrcContent,
);

// Compact mode (2:1) - Suitable for playlists or embedded players
final compactPlayer = await IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 2.0,  // Triggers compact mode
  title: 'Song Name',
  imageUrl: 'album_cover.jpg',
);

// Extended mode (other ratios) - Suitable for fullscreen playback
final expandedPlayer = await IAppPlayerConfig.createPlayer(
  url: 'music.mp3',
  audioOnly: true,
  aspectRatio: 16/9,  // Triggers extended mode
  title: 'Song Name',
  imageUrl: 'album_cover.jpg',
);

// Height constraint can also trigger compact mode
Container(
  height: 180,  // Height <= 200px triggers compact mode
  child: IAppPlayer(controller: result.activeController!),
)
```

### 🔑 15. Complete Initialization Example

```dart
// This is a complete example with all available parameters
final result = await IAppPlayerConfig.createPlayer(
  // Basic parameters
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
  title: 'Sample Video',
  imageUrl: 'https://example.com/cover.jpg',
  backgroundImage: 'assets/background.png',
  
  // Subtitle parameters
  subtitleUrl: 'https://example.com/subtitle.srt',
  subtitles: [
    IAppPlayerSubtitlesSource(
      type: IAppPlayerSubtitlesSourceType.network,
      name: "English",
      urls: ["https://example.com/english.srt"],
      selectedByDefault: true,
    ),
  ],
  
  // Playback control
  autoPlay: false,
  looping: true,
  startAt: Duration(seconds: 10),
  
  // Advanced parameters
  isTV: false,
  audioOnly: false,
  liveStream: false,
  headers: {
    'Authorization': 'Bearer token',
    'User-Agent': 'MyApp/1.0',
  },
  
  // Video configuration
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
  videoFormat: IAppPlayerVideoFormat.hls,
  videoExtension: '.m3u8',
  dataSourceType: IAppPlayerDataSourceType.network,
  resolutions: {
    "720p": "https://example.com/video_720p.mp4",
    "1080p": "https://example.com/video_1080p.mp4",
  },
  
  // UI configuration
  placeholder: CircularProgressIndicator(),
  errorBuilder: (context, error) => Center(child: Text('Playback error: $error')),
  overlay: Container(
    alignment: Alignment.topRight,
    padding: EdgeInsets.all(8),
    child: Text('Watermark', style: TextStyle(color: Colors.white)),
  ),
  aspectRatio: 16 / 9,
  fit: BoxFit.contain,
  rotation: 0,
  showPlaceholderUntilPlay: true,
  placeholderOnTop: true,
  
  // Control feature switches
  enableSubtitles: true,
  enableQualities: true,
  enableAudioTracks: true,
  enableFullscreen: true,
  enableOverflowMenu: true,
  handleAllGestures: true,  // Default: true
  showNotification: true,
  
  // Fullscreen configuration
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
  
  // Streaming parameters
  useAsmsTracks: true,
  useAsmsAudioTracks: true,
  useAsmsSubtitles: true,
  overriddenDuration: Duration(minutes: 30),
  
  // Other parameters
  handleLifecycle: true,
  autoDispose: true,
  allowedScreenSleep: false,
  expandToFill: true,
  useRootNavigator: false,
  author: 'Author Name',
  notificationChannelName: 'MyApp Video Player',
  
  // Multi-language configuration
  translations: [
    IAppPlayerTranslations.chinese(),
  ],
  
  // Visibility change callback
  playerVisibilityChangedBehavior: (visibility) {
    print('Player visibility: $visibility');
  },
);
```

### 🌟 16. Background Image Usage Examples

```dart
// Using network background image
final result1 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'https://example.com/background.jpg',
  eventListener: (event) {},
);

// Using local asset background image
final result2 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'assets/images/video_bg.png',
  eventListener: (event) {},
);
```

### 📊 17. List Auto-play (Visibility Handling)

```dart
// Using player in list, auto play/pause based on visibility
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) {},
  playerVisibilityChangedBehavior: (visibilityFraction) {
    // visibilityFraction: 0.0 = completely invisible, 1.0 = completely visible
    final controller = result.activeController;
    if (controller == null) return;
    
    if (visibilityFraction < 0.5) {
      // Pause when less than 50% visible
      if (controller.isPlaying()) {
        controller.pause();
      }
    } else if (visibilityFraction > 0.8) {
      // Play when more than 80% visible
      if (!controller.isPlaying() && controller.isVideoInitialized()) {
        controller.play();
      }
    }
  },
);
```

---

## 🚀 II. Performance Optimization Suggestions

### 📊 Playlist Optimization

#### Preload Strategy
```dart
// Preload next video
final playlistController = result.playlistController;
if (playlistController != null) {
  final nextIndex = playlistController.currentDataSourceIndex + 1;
  if (nextIndex < playlistController.dataSourceList.length) {
    final nextDataSource = playlistController.dataSourceList[nextIndex];
    
    // Use playSource's preload feature
    await IAppPlayerConfig.playSource(
      controller: result.activeController!,
      source: nextDataSource.uri!,
      liveStream: nextDataSource.liveStream,
      preloadOnly: true,  // Preload only
    );
  }
}
```

### 🎥 Video Quality Adaptation

```dart
// Auto-switch quality based on network conditions
void adaptVideoQuality(double bandwidth) {
  String quality;
  if (bandwidth > 5.0) {
    quality = "1080p";
  } else if (bandwidth > 2.5) {
    quality = "720p";
  } else {
    quality = "360p";
  }
  
  // Switch to appropriate quality
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

### 💾 Cache Configuration

```dart
// Set different cache strategies based on video type
IAppPlayerCacheConfiguration getCacheConfig(String videoType) {
  switch (videoType) {
    case 'short':  // Short videos
      return IAppPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 52428800,  // 50MB
        maxCacheFileSize: 10485760,  // 10MB
      );
    case 'long':  // Long videos
      return IAppPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 209715200,  // 200MB
        maxCacheFileSize: 52428800,  // 50MB
      );
    case 'live':  // Live streams
      return IAppPlayerCacheConfiguration(
        useCache: false,  // No caching for live streams
      );
    default:
      return IAppPlayerCacheConfiguration(useCache: true);
  }
}

// Clear cache
void cleanupCache() {
  result.activeController?.clearCache();
  IAppPlayerConfig.clearAllCaches();  // Clear URL format detection cache
}
```

### 🔋 Memory Management Recommendations

```dart
// 1. Release resources promptly
@override
void dispose() {
  playerResult?.activeController?.dispose();
  playerResult?.playlistController?.dispose();
  super.dispose();
}

// 2. Manual resource lifecycle management (complex UI scenarios)
final result = await IAppPlayerConfig.createPlayer(
  url: 'video.mp4',
  autoDispose: false,  // Disable auto-release
  eventListener: (event) {},
);

// Manual release at appropriate time
void manualDispose() {
  result.activeController?.dispose();
}

// 3. Large playlists - use pagination loading
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

## 🔧 III. Common Problem Solutions

### ❌ Video Won't Play

**Problem**: Video fails to load or shows black screen

**Solution**:
```dart
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
    final error = event.parameters?['exception'];
    
    // Check error type and handle
    if (error.toString().contains('403')) {
      print('Authentication failed, please check headers configuration');
    } else if (error.toString().contains('404')) {
      print('Video not found');
    } else if (error.toString().contains('format')) {
      print('Video format not supported, try switching decoder');
      result.activeController?.retryDataSource();
    }
  }
}
```

### 📝 Subtitles Not Showing

**Problem**: Subtitle file loaded but not displaying

**Solution**:
```dart
// Check if subtitles loaded correctly
if (result.activeController?.subtitlesLines?.isEmpty ?? true) {
  print('Subtitles not loaded correctly');
  // Reset subtitles
  result.activeController?.setupSubtitleSource(
    IAppPlayerSubtitlesSource(
      type: IAppPlayerSubtitlesSourceType.network,
      urls: [subtitleUrl],
      selectedByDefault: true,
    ),
  );
}
```

### 🔄 Playback Stuttering

**Problem**: Video playback not smooth

**Solution**:
```dart
// Monitor buffering status
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.bufferingUpdate) {
    final buffered = event.parameters?['buffered'] as List<Duration>?;
    if (buffered != null && buffered.isNotEmpty) {
      final totalBuffered = buffered.last.inSeconds;
      print('Buffered: $totalBuffered seconds');
      
      // Pause and wait if insufficient buffering
      if (totalBuffered < 5) {
        result.activeController?.pause();
      }
    }
  }
}
```

### 📱 Fullscreen Issues

**Problem**: Fullscreen transition issues or wrong orientation

**Solution**:
```dart
// Listen to fullscreen events and customize handling
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.openFullscreen) {
    // Custom logic when entering fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else if (event.iappPlayerEventType == IAppPlayerEventType.hideFullscreen) {
    // Custom logic when exiting fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
```

### ❓ Null Value Handling

**Problem**: Player creation fails due to invalid URL

**Solution**:
```dart
// Check parameters before creating player
final result = await IAppPlayerConfig.createPlayer(
  url: videoUrl,  // Might be null
  eventListener: (event) {},
);

// Check if player created successfully
if (result.activeController == null) {
  print('Player creation failed, please check if URL is valid');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unable to load video')),
  );
  return;
}

// Safely use controller
result.activeController?.play();
```

### 🔗 URL Format Validation Errors

**Problem**: Playlist contains empty URLs

**Solution**:
```dart
// Validate URLs before creating playlist
final validUrls = urls.where((url) => url.isNotEmpty).toList();

if (validUrls.isEmpty) {
  print('No valid video URLs');
  return;
}

// Create player with validated URLs
final result = await IAppPlayerConfig.createPlayer(
  urls: validUrls,
  eventListener: (event) {},
);
```

### 🎵 Lyrics Sync Issues

**Problem**: LRC lyrics not syncing or not retrievable

**Solution**:
```dart
// Get current lyrics in progress event
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
    // Get currently displayed lyrics
    final subtitle = result.activeController?.renderedSubtitle;
    if (subtitle != null && subtitle.texts != null) {
      final currentLyric = subtitle.texts!.join(' ');
      // Update UI to show current lyrics
      setState(() {
        _currentLyric = currentLyric;
      });
    }
  }
}
```

### 🐛 Debugging Tips

```dart
// Print key events in event listener
eventListener: (event) {
  print('IAppPlayer Event: ${event.iappPlayerEventType}');
  if (event.parameters != null) {
    print('Parameters: ${event.parameters}');
  }
}

// Check player state
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
  
  // Audio player specific: check current lyrics
  final subtitle = controller?.renderedSubtitle;
  if (subtitle != null && subtitle.texts != null) {
    print('Current Lyric: ${subtitle.texts!.join(' ')}');
  }
}
```

---

<div align="center">

**🎯 This document contains common examples and best practices for IAppPlayer**

**👍 If this project helps you, please give it a ⭐ Star!**

**📚 [⬅️ Back to Home](../README.md)   [⬆ Back to Top](#-iappplayer-common-examples-documentation)**

</div>