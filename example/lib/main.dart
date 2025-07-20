import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IAppPlayer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IAppPlayer Examples'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            title: '🎬 单视频播放',
            subtitle: '播放单个网络视频',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SingleVideoExample()),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: '📑 播放列表',
            subtitle: '连续播放多个视频',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlaylistExample()),
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: '🎵 音乐播放器',
            subtitle: '音频播放器（支持LRC歌词）',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MusicPlayerExample()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// 单视频播放示例
class SingleVideoExample extends StatefulWidget {
  const SingleVideoExample({Key? key}) : super(key: key);

  @override
  State<SingleVideoExample> createState() => _SingleVideoExampleState();
}

class _SingleVideoExampleState extends State<SingleVideoExample> {
  IAppPlayerController? _controller;
  bool _isLoading = true;
  String _eventLog = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final result = await IAppPlayerConfig.createPlayer(
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      title: 'Big Buck Bunny',
      eventListener: (event) {
        setState(() {
          _eventLog = '事件: ${event.iappPlayerEventType}';
        });
        
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
    );

    if (mounted) {
      setState(() {
        _controller = result.activeController;
      });
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  Future<void> _releasePlayer() async {
    try {
      IAppPlayerConfig.clearAllCaches();
      if (_controller != null) {
        if (_controller!.isPlaying() ?? false) {
          await _controller!.pause();
          await _controller!.setVolume(0);
        }
        await Future.microtask(() {
          _controller!.dispose();
        });
        _controller = null;
      }
    } catch (e) {
      print('Player cleanup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('单视频播放'),
      ),
      body: Column(
        children: [
          // 播放器区域
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _controller != null
                  ? IAppPlayer(controller: _controller!)
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          // 控制按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 事件日志
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_eventLog)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 播放控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_controller!.isPlaying() ?? false) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            }
                          : null,
                      icon: Icon(
                        (_controller?.isPlaying() ?? false)
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        (_controller?.isPlaying() ?? false) ? '暂停' : '播放',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              final currentPosition = _controller!
                                      .videoPlayerController
                                      ?.value
                                      .position ??
                                  Duration.zero;
                              _controller!.seekTo(
                                currentPosition - const Duration(seconds: 10),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.replay_10),
                      label: const Text('后退10秒'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              final currentPosition = _controller!
                                      .videoPlayerController
                                      ?.value
                                      .position ??
                                  Duration.zero;
                              _controller!.seekTo(
                                currentPosition + const Duration(seconds: 10),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.forward_10),
                      label: const Text('前进10秒'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 播放列表示例
class PlaylistExample extends StatefulWidget {
  const PlaylistExample({Key? key}) : super(key: key);

  @override
  State<PlaylistExample> createState() => _PlaylistExampleState();
}

class _PlaylistExampleState extends State<PlaylistExample> {
  IAppPlayerController? _controller;
  IAppPlayerPlaylistController? _playlistController;
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _shuffleMode = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final result = await IAppPlayerConfig.createPlayer(
      urls: [
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      ],
      titles: ['Big Buck Bunny', 'Elephants Dream', 'For Bigger Blazes'],
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistItem) {
          final index = event.parameters?['index'] as int?;
          if (index != null) {
            setState(() {
              _currentIndex = index;
            });
          }
        } else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
          final shuffleMode = event.parameters?['shuffleMode'] as bool?;
          if (shuffleMode != null) {
            setState(() {
              _shuffleMode = shuffleMode;
            });
          }
        }
      },
      shuffleMode: false,
      loopVideos: true,
    );

    if (mounted) {
      setState(() {
        _controller = result.activeController;
        _playlistController = result.playlistController;
      });
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  Future<void> _releasePlayer() async {
    try {
      IAppPlayerConfig.clearAllCaches();
      _playlistController?.dispose();
      _controller = null;
      _playlistController = null;
    } catch (e) {
      print('Player cleanup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalVideos = _playlistController?.dataSourceList.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('播放列表'),
      ),
      body: Column(
        children: [
          // 播放器区域
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _controller != null
                  ? IAppPlayer(controller: _controller!)
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          // 播放列表信息
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 当前播放信息
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_play, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '正在播放: ${_currentIndex + 1}/$totalVideos',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(_shuffleMode ? '随机播放' : '顺序播放'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _playlistController != null && !_isLoading
                          ? () => _playlistController!.playPrevious()
                          : null,
                      icon: const Icon(Icons.skip_previous),
                      label: const Text('上一个'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_controller!.isPlaying() ?? false) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            }
                          : null,
                      icon: Icon(
                        (_controller?.isPlaying() ?? false)
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        (_controller?.isPlaying() ?? false) ? '暂停' : '播放',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _playlistController != null && !_isLoading
                          ? () => _playlistController!.playNext()
                          : null,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('下一个'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 播放模式切换
                OutlinedButton.icon(
                  onPressed: _playlistController != null
                      ? () => _playlistController!.toggleShuffleMode()
                      : null,
                  icon: Icon(_shuffleMode ? Icons.shuffle : Icons.repeat),
                  label: Text(_shuffleMode ? '切换到顺序播放' : '切换到随机播放'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 音乐播放器示例
class MusicPlayerExample extends StatefulWidget {
  const MusicPlayerExample({Key? key}) : super(key: key);

  @override
  State<MusicPlayerExample> createState() => _MusicPlayerExampleState();
}

class _MusicPlayerExampleState extends State<MusicPlayerExample> {
  IAppPlayerController? _controller;
  bool _isLoading = true;
  String _currentLyric = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final result = await IAppPlayerConfig.createPlayer(
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      title: 'Sample Music',
      audioOnly: true,
      subtitleContent: '''[00:00.00]示例音乐播放器
[00:05.00]这是一个演示
[00:10.00]支持LRC歌词格式
[00:15.00]可以显示同步歌词
[00:20.00]享受音乐吧！
[00:25.00]♪ ♫ ♬ ♪ ♫ ♬
[00:30.00]继续播放...
[00:35.00]音乐让生活更美好
[00:40.00]IAppPlayer 音乐播放器
[00:45.00]感谢使用！''',
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _controller = result.activeController;
      });
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  Future<void> _releasePlayer() async {
    try {
      IAppPlayerConfig.clearAllCaches();
      if (_controller != null) {
        if (_controller!.isPlaying() ?? false) {
          await _controller!.pause();
        }
        _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      print('Player cleanup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐播放器'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[200]!,
              Colors.purple[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 封面占位符
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.purple[300],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // 音乐播放器
            Container(
              height: 250,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _controller != null
                  ? IAppPlayer(controller: _controller!)
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
            // 控制按钮
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _controller != null && !_isLoading
                        ? () {
                            final currentPosition = _controller!
                                    .videoPlayerController
                                    ?.value
                                    .position ??
                                Duration.zero;
                            _controller!.seekTo(
                              currentPosition - const Duration(seconds: 10),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.replay_10),
                    iconSize: 36,
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    onPressed: _controller != null && !_isLoading
                        ? () {
                            if (_controller!.isPlaying() ?? false) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          }
                        : null,
                    child: Icon(
                      (_controller?.isPlaying() ?? false)
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _controller != null && !_isLoading
                        ? () {
                            final currentPosition = _controller!
                                    .videoPlayerController
                                    ?.value
                                    .position ??
                                Duration.zero;
                            _controller!.seekTo(
                              currentPosition + const Duration(seconds: 10),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.forward_10),
                    iconSize: 36,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
