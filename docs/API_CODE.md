# 📚 IAppPlayer Common Examples Documentation

[![Back to Home](https://img.shields.io/badge/🏠-TV_Treasure_App_Store-blue?style=for-the-badge)](https://www.itvapp.net)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?style=for-the-badge&logo=github)](https://github.com/ITVAPP/IAppPlayer)
[![中文](https://img.shields.io/badge/📄-中文-green?style=for-the-badge)](./API_CODE_CN.md)
[![Stars](https://img.shields.io/github/stars/ITVAPP/IAppPlayer?style=for-the-badge&logo=github&label=⭐%20Stars)](https://github.com/ITVAPP/IAppPlayer/stargazers)

---

## 📋 Table of Contents

- [📚 IAppPlayer Common Examples Documentation](#-iappplayer-common-examples-documentation)
  - [📋 Table of Contents](#-table-of-contents)
  - [⚠️ Important Notes](#️-important-notes)
  - [📊 Default Configuration Values](#-default-configuration-values)
  - [🎯 1. Common Parameter Combinations](#-1-common-parameter-combinations)
  - [🚀 2. Performance Optimization Recommendations](#-2-performance-optimization-recommendations)
  - [🔧 3. Common Troubleshooting](#-3-common-troubleshooting)

---

## ⚠️ Important Notes

### Parameter Mutual Exclusivity
- `url` and `urls` parameters **cannot be used simultaneously**, the system will throw `ArgumentError`
- Use `url` parameter for single video
- Use `urls` parameter for playlists

### URL Validation
- URL cannot be an empty string
- Each URL in the playlist will be validated, empty URLs will throw an error

### Return Value Handling
- When no valid URL is provided, `createPlayer` returns an empty `PlayerResult` object
- Check if `result.activeController` is null before use

### Asynchronous Calls
- `createPlayer` is an asynchronous method that returns `Future<PlayerResult>`
- Use `await` keyword when calling

---

## 📊 Default Configuration Values

| Configuration Item | Default Value | Description |
|:---|:---:|:---|
| **Cache Configuration** |  |  |
| Pre-cache Size | 10MB | Cache size for preloading video |
| Maximum Cache | 300MB | Total cache size limit |
| Single File Max Cache | 50MB | Cache limit for single video file |
| **Buffer Configuration** |  |  |
| Live Stream Min Buffer | 15s | Minimum buffer time for live streams |
| VOD Min Buffer | 20s | Minimum buffer time for on-demand video |
| Live Stream Max Buffer | 15s | Maximum buffer time for live streams |
| VOD Max Buffer | 30s | Maximum buffer time for on-demand video |
| Playback Buffer | 3s | Buffer time required to start playback |
| Rebuffer Playback | 5s | Buffer time required to resume after stalling |
| **UI Configuration** |  |  |
| Default Activity Name | `MainActivity` | Activity name used in Android notification bar |
| Image Scale Mode | `BoxFit.cover` | Default scale mode for background and placeholder images |
| Image Quality | `FilterQuality.medium` | Render quality for local images |
| Default Rotation | 0° | Default video rotation angle |
| **Other Configuration** |  |  |
| Video Title Format | `Video ${index+1}` | Default format when title not specified in playlist |
| Subtitle Name | `Subtitles` | Default subtitle track name |
| Playlist Switch Delay | 1s | Delay time for auto-playing next video |
| URL Format Cache | 1000 entries | Maximum cached URL format detection results |

### Live Stream Special Configuration
Live streams automatically apply the following special configurations:
- **No cache** - Live content requires real-time delivery
- **Enable HLS tracks** - Support multi-bitrate switching
- **Enable audio track selection** - Support multi-language audio tracks
- **Disable looping** - Live streams don't support looping

### URL Format Detection Description
- The system automatically detects URL format, supports URLs with query parameters
- During detection, query parameters (after `?`) are removed first, then file extension is checked
- Detection results are cached to avoid repeated detection of the same URL

---

## 🎯 1. Common Parameter Combinations

### 🎬 1. Simplest Video Playback

```dart
// createPlayer returns PlayerResult object, containing controller reference
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
  // Can pass the following parameter when called from parent component to specify preferred decoder
  // Use hardware decoding first (default)
  preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
  // Or use software decoding first (better compatibility, but higher performance consumption)
  // preferredDecoderType: IAppPlayerDecoderType.softwareFirst,
);

// Check if player was created successfully
if (result.activeController == null) {
  print('Player creation failed, please check if URL is valid');
  return;
}

// PlayerResult provides convenient access methods
final controller = result.controller;  // Single video controller
// Or use activeController to automatically get current active controller
final activeController = result.activeController;

// If video playback has compatibility issues, can switch decoder type and retry
void switchDecoder() async {
  await IAppPlayerConfig.playSource(
    controller: controller!,
    source: 'https://example.com/video.mp4',
    preferredDecoderType: IAppPlayerDecoderType.softwareFirst,
  );
}
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

### 🎵 3. Music Player (Supporting LRC Lyrics)

```dart
// Single audio file playback
final singleMusicPlayer = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: 'Song Name',
  audioOnly: true,  // Enable audio controls UI instead of video controls
  subtitleContent: '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人''',  // LRC lyrics content
  eventListener: (event) {
    print('Music player event: ${event.iappPlayerEventType}');
  },
);

// Music playlist (with LRC lyrics)
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
  subtitleContents: [  // LRC lyrics format
    '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人
[00:34.23]陪伴我度过漫长岁月的那个人''',
    '''[00:00.00]About Love
[00:05.00]Beautiful melody
[00:10.00]Love is in the air
[00:15.00]Everywhere I look around''',
    '''[00:01.00]Third Song
[00:06.00]This is example lyrics
[00:12.00]Supports LRC format''',
  ],
  audioOnly: true,  // Enable audio controls UI
  shuffleMode: true,  // Shuffle play
  autoPlay: true,
  eventListener: (event) {
    switch (event.iappPlayerEventType) {
      case IAppPlayerEventType.changedPlaylistItem:
        final index = event.parameters?['index'] as int?;
        print('Switched to song ${index! + 1}');
        break;
      case IAppPlayerEventType.changedPlaylistShuffle:
        final shuffleMode = event.parameters?['shuffleMode'] as bool?;
        print('Shuffle mode: ${shuffleMode! ? "On" : "Off"}');
        break;
      default:
        break;
    }
  },
);

// Control playlist
musicPlaylist.playlistController?.playNext();
musicPlaylist.playlistController?.toggleShuffleMode();

// Can also use external LRC file
final musicWithLrcFile = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/song.mp3',
  title: 'Song Name',
  audioOnly: true,
  subtitleUrl: 'https://example.com/lyrics.lrc',  // LRC lyrics file URL
  eventListener: (event) {},
);
```

### 📺 4. Live Stream (HLS)

```dart
// URL format auto-detection description:
// IAppPlayerConfig automatically detects URL format and sets appropriate parameters:
// - .m3u8 -> HLS format, automatically recognized as live stream
// - .mpd -> DASH format
// - .flv -> FLV format, automatically recognized as live stream
// - .ism -> Smooth Streaming format
// - rtmp://, rtsp:// -> Streaming protocols, automatically recognized as live stream

final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/live.m3u8',
  title: 'Live Channel',
  autoPlay: true,
  looping: false,     // Live streams don't loop
  liveStream: true,   // Explicitly specify as live stream (usually auto-detected)
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.bufferingStart) {
      print('Buffering started');
    } else if (event.iappPlayerEventType == IAppPlayerEventType.bufferingEnd) {
      print('Buffering ended');
    }
  },
);

// Live streams automatically apply the following configuration:
// - Disable cache (useCache: false)
// - Enable HLS tracks (useAsmsTracks: true)
// - Enable audio track selection (useAsmsAudioTracks: true)
// - Smaller buffer (15 seconds)
```

### 🔐 5. Video Requiring Authentication

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
      // May need to refresh token
    }
  },
);
```

### 📺 6. TV Mode (Disable Notifications)

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  isTV: true,  // TV mode, automatically disables notifications
  autoPlay: true,
  eventListener: (event) {
    // Event handling in TV mode
  },
);

// TV mode features:
// - Automatically disables system notifications
// - Suitable for large screen display
// - Recommended to work with remote control
```

### 🎯 7. Advanced Playlist (Different Configuration for Each Video)

```dart
// Method 1: Create playlist using URLs (simple mode)
final simplePlaylist = await IAppPlayerConfig.createPlayer(
  urls: ['url1', 'url2', 'url3'],
  titles: ['Video 1', 'Video 2', 'Video 3'],
  imageUrls: ['cover1.jpg', 'cover2.jpg', 'cover3.jpg'],  // Cover for each video
  subtitleUrls: ['sub1.srt', 'sub2.srt', 'sub3.srt'],  // Subtitles for each video
  // Or use subtitleContents to provide subtitle content
  eventListener: (event) {},
);

// Method 2: Create playlist using data sources (advanced mode)
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

// Use createPlaylistPlayer to create advanced playlist
final result = IAppPlayerConfig.createPlaylistPlayer(
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('Play mode: ${shuffleMode! ? "Shuffle" : "Sequential"}');
    }
  },
  dataSources: dataSources,
  shuffleMode: false,  // false: sequential play, true: shuffle play
  loopVideos: true,    // Loop playlist
  initialStartIndex: 0,  // Start from first video
  nextVideoDelay: Duration(seconds: 3),  // Video switch delay
  playerConfiguration: null,  // Optional custom player configuration
);

// Dynamically switch play mode
void togglePlayMode() {
  result.playlistController?.toggleShuffleMode();
  print('Current mode: ${result.playlistController?.shuffleMode ? "Shuffle" : "Sequential"}');
}

// Jump to specific video
void jumpToVideo(int index) {
  result.playlistController?.setupDataSource(index);
}
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
  preloadOnly: false,  // Play immediately
);

// Preload next video (without playing)
await IAppPlayerConfig.playSource(
  controller: result.activeController!,
  source: 'https://example.com/next_video.mp4',
  preloadOnly: true,  // Only preload, don't play
);
```

### 👂 9. Complete Event Handling Example

```dart
eventListener: (IAppPlayerEvent event) {
  switch (event.iappPlayerEventType) {
    // Initialization event
    case IAppPlayerEventType.initialized:
      print('Player initialized');
      final duration = result.activeController?.videoPlayerController?.value.duration;
      print('Total video duration: ${duration?.inSeconds} seconds');
      break;
      
    // Playback control events
    case IAppPlayerEventType.play:
      print('Playback started');
      break;
    case IAppPlayerEventType.pause:
      print('Playback paused');
      break;
      
    // Progress event
    case IAppPlayerEventType.progress:
      final progress = event.parameters?['progress'] as Duration?;
      final duration = event.parameters?['duration'] as Duration?;
      if (progress != null && duration != null) {
        final percent = (progress.inSeconds / duration.inSeconds * 100).toStringAsFixed(1);
        print('Playback progress: ${progress.inSeconds}/${duration.inSeconds} seconds ($percent%)');
      }
      break;
      
    // Buffering events
    case IAppPlayerEventType.bufferingStart:
      print('Buffering started...');
      break;
    case IAppPlayerEventType.bufferingEnd:
      print('Buffering completed');
      break;
    case IAppPlayerEventType.bufferingUpdate:
      final buffered = event.parameters?['buffered'] as List<Duration>?;
      if (buffered != null && buffered.isNotEmpty) {
        print('Buffered: ${buffered.last.inSeconds} seconds');
      }
      break;
      
    // Completion event
    case IAppPlayerEventType.finished:
      print('Playback finished');
      // Can implement auto-play next here
      break;
      
    // Error event
    case IAppPlayerEventType.exception:
      final error = event.parameters?['exception'];
      print('Playback error: $error');
      // Can show error prompt or try retry
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Playback Error'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                result.activeController?.retryDataSource();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
      break;
      
    // Fullscreen events
    case IAppPlayerEventType.openFullscreen:
      print('Entered fullscreen');
      break;
    case IAppPlayerEventType.hideFullscreen:
      print('Exited fullscreen');
      break;
      
    // Playlist events
    case IAppPlayerEventType.changedPlaylistItem:
      final index = event.parameters?['index'] as int?;
      print('Switched to playlist item ${index! + 1}');
      break;
    case IAppPlayerEventType.changedPlaylistShuffle:
      final shuffleMode = event.parameters?['shuffleMode'] as bool?;
      print('Shuffle mode: ${shuffleMode ? "On" : "Off"}');
      break;
      
    // Subtitle event
    case IAppPlayerEventType.changedSubtitles:
      final subtitlesSource = event.parameters?['subtitlesSource'] as IAppPlayerSubtitlesSource?;
      print('Switched subtitles: ${subtitlesSource?.name}');
      break;
      
    // Quality switch event
    case IAppPlayerEventType.changedResolution:
      final url = event.parameters?['url'] as String?;
      print('Switched quality: $url');
      break;
      
    default:
      break;
  }
}
```

### 🎮 10. Complete Controller Usage Example

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

// Playlist control
if (result.isPlaylist) {
  // Playback control
  result.playlistController?.playNext();
  result.playlistController?.playPrevious();
  result.playlistController?.setupDataSource(3); // Play 4th video
  
  // Shuffle play
  result.playlistController?.toggleShuffleMode();
  
  // Get playlist info
  final currentIndex = result.playlistController?.currentDataSourceIndex ?? 0;
  final hasNext = result.playlistController?.hasNext ?? false;
  final hasPrevious = result.playlistController?.hasPrevious ?? false;
  final shuffleMode = result.playlistController?.shuffleMode ?? false;
  final totalVideos = result.playlistController?.dataSourceList.length ?? 0;
  
  print('Currently playing: ${currentIndex + 1}/$totalVideos');
  print('Shuffle mode: $shuffleMode');
}

// Advanced features
result.activeController?.enablePictureInPicture();
result.activeController?.setMixWithOthers(true);

// Cache management
result.activeController?.clearCache();
await result.activeController?.preCache(dataSource);

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

// Custom controls implementation
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
      // Implement custom controls UI
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

### 📊 12. Multi-Resolution Switching Example

```dart
final result = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video_720p.mp4',
  eventListener: (event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.changedResolution) {
      final url = event.parameters?['url'];
      print('Switched to: $url');
    }
  },
);

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

### 🌐 13. Network Exception Handling Example

```dart
// Network status monitoring and reconnection mechanism
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
    // Create player
    playerResult = await IAppPlayerConfig.createPlayer(
      url: 'https://example.com/video.mp4',
      eventListener: handlePlayerEvent,
    );
    
    // Monitor network status
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && wasDisconnected) {
        // Network restored, retry playback
        print('Network restored, attempting to reconnect...');
        playerResult?.activeController?.retryDataSource();
        wasDisconnected = false;
        retryCount = 0;
      } else if (result == ConnectivityResult.none) {
        wasDisconnected = true;
        print('Network disconnected');
      }
    });
  }
  
  void handlePlayerEvent(IAppPlayerEvent event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
      final error = event.parameters?['exception'] as String?;
      
      // Check if it's a network error
      if (error != null && (error.contains('network') || 
          error.contains('timeout') || 
          error.contains('connection'))) {
        
        if (retryCount < maxRetries) {
          // Exponential backoff retry strategy
          final delay = Duration(seconds: math.pow(2, retryCount).toInt());
          print('Network error, will retry in ${delay.inSeconds} seconds (attempt ${retryCount + 1}/$maxRetries)');
          
          Future.delayed(delay, () {
            playerResult?.activeController?.retryDataSource();
            retryCount++;
          });
        } else {
          // Maximum retries reached
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Network Error'),
              content: Text('Unable to connect to server, please check network settings'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    retryCount = 0;  // Reset retry count
                    playerResult?.activeController?.retryDataSource();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
      }
    } else if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
      // Playback successful, reset retry count
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
    // Build your UI
    return Container();
  }
}
```

### 🔑 14. Complete Initialization Example

```dart
// This is a complete example containing all available parameters
final result = await IAppPlayerConfig.createPlayer(
  // Basic parameters
  url: 'https://example.com/video.mp4',
  eventListener: (event) => print('Event: ${event.iappPlayerEventType}'),
  title: 'Example Video',
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
  
  // Controls feature toggles
  enableSubtitles: true,
  enableQualities: true,
  enableAudioTracks: true,
  enableFullscreen: true,
  enableOverflowMenu: true,
  handleAllGestures: true,
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
    IAppPlayerTranslations(
      languageCode: 'en',
      generalDefaultError: 'Cannot play video',
      generalNone: 'None',
      generalDefault: 'Default',
      generalRetry: 'Retry',
      playlistLoadingNextVideo: 'Loading next video',
      controlsLive: 'LIVE',
      controlsNextVideoIn: 'Next video in',
      overflowMenuPlaybackSpeed: 'Playback speed',
      overflowMenuSubtitles: 'Subtitles',
      overflowMenuQuality: 'Quality',
      overflowMenuAudioTracks: 'Audio tracks',
      qualityAuto: 'Auto',
    ),
  ],
  
  // Visibility change callback
  playerVisibilityChangedBehavior: (visibility) {
    print('Player visibility: $visibility');
  },
  
  // Route page builder
  routePageBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
);
```

### 🌟 15. Background Image Usage Example

```dart
// Using network background image
final result1 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'https://example.com/background.jpg',  // Network image
  eventListener: (event) {},
);

// Using local asset background image
final result2 = await IAppPlayerConfig.createPlayer(
  url: 'https://example.com/video.mp4',
  backgroundImage: 'assets/images/video_bg.png',  // Local asset
  eventListener: (event) {},
);

// Background image features:
// - Automatically uses BoxFit.cover scale mode
// - Local images use FilterQuality.medium render quality
// - If errorBuilder is set, background image also serves as error display content
// - Supports network images (http/https) and local asset images
```

### 🚀 16. URL Format Detection Cache Optimization Example

```dart
// Preheat common URL formats on app startup
void preloadUrlFormats() {
  final commonUrls = [
    'https://example.com/video.mp4',
    'https://example.com/live.m3u8',
    'https://example.com/stream.mpd',
    'https://example.com/video.mp4?token=abc123',  // URL with query parameters
  ];
  
  // Pre-detect URL formats, results will be cached
  for (final url in commonUrls) {
    IAppPlayerConfig.createDataSource(
      url: url,
      liveStream: false,  // Will trigger URL format detection
    );
  }
}

// Clear cache when app exits or memory is tight
void onAppCleanup() {
  IAppPlayerConfig.clearAllCaches();
  print('URL format detection cache cleared');
}

// URL format detection cache description:
// - Automatically caches format detection results for last 1000 URLs
// - Uses LRU algorithm, automatically evicts least recently used entries
// - Improves performance when repeatedly playing same URLs
// - Cache includes: whether it's live stream, video format info
// - Detection removes query parameters first, then checks file extension
```

---

## 🚀 2. Performance Optimization Recommendations

### 📊 Playlist Optimization

#### 1. Preload Strategy
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

#### 2. Lazy Loading Large Lists
```dart
// Paginated playlist loading
import 'dart:math';

const pageSize = 20;
var currentPage = 0;

void loadMoreVideos() {
  final startIndex = currentPage * pageSize;
  final endIndex = min(startIndex + pageSize, allVideos.length);
  final pageVideos = allVideos.sublist(startIndex, endIndex);
  
  // Add to playlist
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

### 💾 Cache Strategy

#### 1. Smart Cache Configuration
```dart
// Set cache based on video type
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
        useCache: false,  // No cache for live
      );
    default:
      return IAppPlayerCacheConfiguration(useCache: true);
  }
}
```

#### 2. Cache Cleanup
```dart
// Regular cache cleanup
void cleanupCache() async {
  // Clear video cache
  result.activeController?.clearCache();
  
  // Clear URL format detection cache
  IAppPlayerConfig.clearAllCaches();
}
```

### 🔋 Battery Optimization

```dart
// Adjust playback strategy based on battery level
void optimizeForBattery(int batteryLevel) {
  if (batteryLevel < 20) {
    // Low battery mode
    result.activeController?.setSpeed(1.0);  // Normal speed
    // Consider reducing quality
  }
}
```

### 📈 URL Format Detection Optimization

```dart
// URL format detection cache mechanism description:
// 1. Automatically caches format detection results for last 1000 URLs
// 2. Uses LRU (Least Recently Used) algorithm to manage cache
// 3. Avoids repeated detection of same URLs, improves performance

// Batch pre-detect URL formats
void batchPreloadUrlFormats(List<String> urls) {
  for (final url in urls) {
    // Trigger format detection and cache results
    IAppPlayerConfig.createDataSource(
      url: url,
      liveStream: false,
    );
  }
}

// Clean cache at appropriate times
void performMaintenance() {
  // Clear URL format detection cache
  IAppPlayerConfig.clearAllCaches();
  
  // Can immediately preload common URLs
  final frequentlyUsedUrls = [
    'https://example.com/common1.m3u8',
    'https://example.com/common2.mp4',
  ];
  batchPreloadUrlFormats(frequentlyUsedUrls);
}
```

### 📊 Performance Benchmark Data

Performance reference data based on actual testing:

| Device Type | Video Resolution | CPU Usage | Memory Usage | Recommended Concurrency |
|:---:|:---:|:---:|:---:|:---:|
| Low-end Phone | 480p | 15-25% | 30-50MB | 1 |
| Mid-range Phone | 720p | 20-30% | 50-80MB | 1-2 |
| High-end Phone | 1080p | 25-35% | 80-120MB | 2-3 |
| Tablet | 1080p | 20-30% | 100-150MB | 2-3 |
| TV Box | 4K | 40-60% | 150-200MB | 1 |

---

## 🔧 3. Common Troubleshooting

### ❌ Common Issues and Solutions

#### 1. Video Cannot Play

**Issue Description**: Video loading fails or black screen

**Solution**:
```dart
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
    final error = event.parameters?['exception'];
    
    // Check error type
    if (error.toString().contains('403')) {
      print('Authentication failed, please check headers configuration');
    } else if (error.toString().contains('404')) {
      print('Video does not exist');
    } else if (error.toString().contains('format')) {
      print('Video format not supported');
      // Try switching decoder
      result.activeController?.retryDataSource();
    }
  }
}
```

#### 2. Subtitles Not Displaying

**Issue Description**: Subtitle file loaded but not showing

**Solution**:
```dart
// Check subtitle configuration
final subtitlesConfig = IAppPlayerSubtitlesConfiguration(
  fontSize: 16,  // Ensure appropriate font size
  fontColor: Colors.white,
  outlineEnabled: true,
  outlineColor: Colors.black,
  backgroundColor: Colors.transparent,
);

// Check subtitle source
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

#### 3. Playback Stuttering

**Issue Description**: Video playback not smooth

**Solution**:
```dart
// Adjust buffer configuration
final bufferingConfig = IAppPlayerBufferingConfiguration(
  minBufferMs: 15000,  // Increase minimum buffer
  maxBufferMs: 30000,  // Increase maximum buffer
  bufferForPlaybackMs: 2500,
  bufferForPlaybackAfterRebufferMs: 5000,
);

// Monitor buffer status
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.bufferingUpdate) {
    final buffered = event.parameters?['buffered'] as List<Duration>?;
    if (buffered != null && buffered.isNotEmpty) {
      final totalBuffered = buffered.last.inSeconds;
      print('Buffered: $totalBuffered seconds');
      
      // If buffer insufficient, can pause to wait
      if (totalBuffered < 5) {
        result.activeController?.pause();
        // Continue playback after sufficient buffering
      }
    }
  }
}
```

#### 4. Fullscreen Issues

**Issue Description**: Fullscreen switching abnormal or wrong orientation

**Solution**:
```dart
// Customize fullscreen behavior
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

// Listen to fullscreen events
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

#### 5. Null Value Handling

**Issue Description**: Player creation fails due to invalid URL

**Solution**:
```dart
// Check parameters before creating player
final result = await IAppPlayerConfig.createPlayer(
  url: videoUrl,  // May be null
  eventListener: (event) {},
);

// Check if player was created successfully
if (result.activeController == null) {
  print('Player creation failed, please check if URL is valid');
  // Show error message to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Cannot load video')),
  );
  return;
}

// Safely use controller
result.activeController?.play();
```

#### 6. URL Format Validation Error

**Issue Description**: Playlist contains empty URLs

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

### 🐛 Debugging Tips

#### 1. Enable Detailed Logging
```dart
// Print all events in event listener
eventListener: (event) {
  print('IAppPlayer Event: ${event.iappPlayerEventType}');
  if (event.parameters != null) {
    print('Parameters: ${event.parameters}');
  }
}
```

#### 2. Check Player State
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

#### 3. Network Request Debugging
```dart
// Use proxy to debug network requests
final headers = {
  'Authorization': 'Bearer token',
  'X-Debug-Mode': 'true',  // Add debug flag
};

// Listen to network-related errors
eventListener: (event) {
  if (event.iappPlayerEventType == IAppPlayerEventType.exception) {
    final error = event.parameters?['exception'];
    // Log detailed error info
    print('Video playback error: $error');
  }
}
```

---

<div align="center">

**🎯 This document contains common examples and best practices for IAppPlayer**

**👍 If this project helps you, please give it a ⭐ Star to support!**

**📚 [⬅️ Back to Home](../README.md)   [⬆ Back to Top](#-iappplayer-common-examples-documentation)**

</div>
