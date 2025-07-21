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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E21),
              const Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定义标题栏 - 减少间距
              Container(
                padding: const EdgeInsets.only(
                  top: 16, // 减少顶部间距
                  left: 24,
                  right: 24,
                  bottom: 16, // 减少底部间距
                ),
                child: Column(
                  children: [
                    // 使用图片替代图标
                    Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 8), // 减少间距
                    const Text(
                      'IApp Player',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4), // 减少间距
                    Text(
                      '选择您的播放体验',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 选项卡片
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildModernCard(
                      context,
                      icon: Icons.movie_outlined,
                      title: '视频播放器',
                      subtitle: '播放单个本地视频',
                      gradient: [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const SingleVideoExample(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernCard(
                      context,
                      icon: Icons.playlist_play,
                      title: '视频列表',
                      subtitle: '连续播放多个视频',
                      gradient: [
                        const Color(0xFFf093fb),
                        const Color(0xFFf5576c),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const PlaylistExample(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernCard(
                      context,
                      icon: Icons.music_note_outlined,
                      title: '音乐播放器',
                      subtitle: '支持LRC歌词显示',
                      gradient: [
                        const Color(0xFF4facfe),
                        const Color(0xFF00f2fe),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const MusicPlayerExample(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernCard(
                      context,
                      icon: Icons.queue_music,
                      title: '音乐列表',
                      subtitle: '连续播放多首歌曲',
                      gradient: [
                        const Color(0xFFfa709a),
                        const Color(0xFFfee140),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const MusicPlaylistExample(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// 资源缓存类 - 避免重复读取文件
class AssetCache {
  static final AssetCache _instance = AssetCache._internal();
  factory AssetCache() => _instance;
  AssetCache._internal();

  final Map<String, String> _cache = {};

  Future<String> loadString(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final content = await rootBundle.loadString(key);
    _cache[key] = content;
    return content;
  }
}

// 屏幕旋转处理Mixin - 提取重复的旋转处理逻辑
mixin PlayerOrientationMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  IAppPlayerController? get controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _handleOrientationChange();
  }

  void _handleOrientationChange() {
    if (controller == null || !mounted) return;
    
    // 延迟执行以确保 MediaQuery 可用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.landscape) {
        if (!controller!.isFullScreen) {
          controller!.enterFullScreen();
        }
      } else {
        if (controller!.isFullScreen) {
          controller!.exitFullScreen();
        }
      }
    });
  }
}

// 现代化控制按钮组件
class ModernControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const ModernControlButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary ? LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _SingleVideoExampleState extends State<SingleVideoExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin {
  IAppPlayerController? _controller;
  bool _isLoading = true;
  final _assetCache = AssetCache();

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 使用缓存读取字幕文件
    final subtitleContent = await _assetCache.loadString('assets/subtitles/video1.srt');
    
    // 修复：使用正确的本地资源路径
    final result = await IAppPlayerConfig.createPlayer(
      url: 'assets/videos/video1.mp4',
      // dataSourceType: IAppPlayerDataSourceType.file,
      title: 'Superman (1941)',
      imageUrl: 'https://www.itvapp.net/images/logo-1.png',
      subtitleContent: subtitleContent,
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
        }
      },
      preferredDecoderType: IAppPlayerDecoderType.hardwareFirst,
      autoDetectFullscreenDeviceOrientation: true,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
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
      // 移除全局缓存清理，避免影响其他页面
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('视频播放器'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F3A),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 播放器区域
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: _controller != null
                          ? IAppPlayer(controller: _controller!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // 控制按钮区域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放/暂停按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_controller!.isPlaying() ?? false) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            }
                          : null,
                      icon: (_controller?.isPlaying() ?? false)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: (_controller?.isPlaying() ?? false) ? '暂停' : '播放',
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    // 全屏按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_controller!.isFullScreen) {
                                _controller!.exitFullScreen();
                              } else {
                                _controller!.enterFullScreen();
                              }
                            }
                          : null,
                      icon: _controller?.isFullScreen ?? false
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      label: '全屏观看',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

class _PlaylistExampleState extends State<PlaylistExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin {
  IAppPlayerController? _controller;
  IAppPlayerPlaylistController? _playlistController;
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _shuffleMode = false;
  final _assetCache = AssetCache();

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 使用缓存批量读取字幕文件
    final subtitle1 = await _assetCache.loadString('assets/subtitles/video1.srt');
    final subtitle2 = await _assetCache.loadString('assets/subtitles/video2.srt');
    final subtitle3 = await _assetCache.loadString('assets/subtitles/video3.srt');
    
    // 修复：使用正确的本地资源路径
    final result = await IAppPlayerConfig.createPlayer(
      urls: [
        'assets/videos/video1.mp4',
        'assets/videos/video2.mp4',
        'assets/videos/video3.mp4',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: ['Superman (1941)', 'Betty Boop - Snow White', 'Felix the Cat'],
      imageUrls: [
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
      ],
      subtitleContents: [subtitle1, subtitle2, subtitle3],
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
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
      autoDetectFullscreenDeviceOrientation: true,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
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
      // 移除全局缓存清理
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('视频列表'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F3A),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 播放器区域
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: _controller != null
                          ? IAppPlayer(controller: _controller!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              // 播放信息卡片
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.playlist_play_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '播放进度',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currentIndex + 1} / $totalVideos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _shuffleMode ? '随机' : '顺序',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 控制按钮区域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放控制按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一个
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () => _playlistController!.playPrevious()
                              : null,
                          icon: Icons.skip_previous_rounded,
                        ),
                        // 播放/暂停
                        _buildCircleButton(
                          onPressed: _controller != null && !_isLoading
                              ? () {
                                  if (_controller!.isPlaying() ?? false) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                }
                              : null,
                          icon: (_controller?.isPlaying() ?? false)
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          isPrimary: true,
                        ),
                        // 下一个
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () => _playlistController!.playNext()
                              : null,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 模式切换按钮
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: _shuffleMode ? '切换到顺序播放' : '切换到随机播放',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback? onPressed,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return Container(
      width: isPrimary ? 80 : 60,
      height: isPrimary ? 80 : 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPrimary ? LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 36 : 28,
            ),
          ),
        ),
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

class _MusicPlayerExampleState extends State<MusicPlayerExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin {
  IAppPlayerController? _controller;
  bool _isLoading = true;
  final _assetCache = AssetCache();

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 直接在代码中定义LRC歌词内容
    const lrcContent = '''[00:02.05]愿得一人心
[00:08.64]词：胡小健 曲：罗俊霖
[00:27.48]曾在我背包小小夹层里的那个人
[00:34.23]陪伴我度过漫长岁月的那个人
[00:41.01]我不能够说出她名字的那个人
[00:47.76]在被我淡忘的那个人
[00:54.47]有什么东西快要从胸口跳出
[01:01.23]一直都紧紧的锁在心里头
[01:07.93]你看进我的眼睛里面有什么
[01:14.69]是不是找到失落的自己
[01:21.44]愿得一人心
[01:24.87]白首不相离
[01:28.15]这简单的话语
[01:31.58]需要巨大的勇气
[01:34.95]没想过失去你
[01:38.33]却是在骗自己
[01:41.66]最后你深深藏在我的歌声里''';
    
    // 修复：使用正确的本地资源路径
    final result = await IAppPlayerConfig.createPlayer(
      url: 'assets/music/song1.mp3',
      dataSourceType: IAppPlayerDataSourceType.file,
      title: 'Creative Design',
      imageUrl: 'https://www.itvapp.net/images/logo-1.png',
      audioOnly: true,
      subtitleContent: lrcContent,
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
        }
      },
      autoDetectFullscreenDeviceOrientation: true,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
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
      // 移除全局缓存清理
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('音乐播放器'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F3A),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // 减少顶部间距
              // 音乐封面区域
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4facfe).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4facfe),
                            const Color(0xFF00f2fe),
                          ],
                        ),
                      ),
                      child: _controller != null
                          ? IAppPlayer(controller: _controller!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // 减少间距
              // 歌曲信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const Text(
                      'Creative Design',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unknown Artist',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 控制按钮区域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放/暂停按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_controller!.isPlaying() ?? false) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            }
                          : null,
                      icon: (_controller?.isPlaying() ?? false)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: (_controller?.isPlaying() ?? false) ? '暂停' : '播放',
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    // 全屏按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_controller!.isFullScreen) {
                                _controller!.exitFullScreen();
                              } else {
                                _controller!.enterFullScreen();
                              }
                            }
                          : null,
                      icon: _controller?.isFullScreen ?? false
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      label: '全屏歌词',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 音乐播放列表示例
class MusicPlaylistExample extends StatefulWidget {
  const MusicPlaylistExample({Key? key}) : super(key: key);

  @override
  State<MusicPlaylistExample> createState() => _MusicPlaylistExampleState();
}

class _MusicPlaylistExampleState extends State<MusicPlaylistExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin {
  IAppPlayerController? _controller;
  IAppPlayerPlaylistController? _playlistController;
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _shuffleMode = false;
  final _assetCache = AssetCache();

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 使用缓存批量读取LRC歌词文件
    final lyrics1 = await _assetCache.loadString('assets/lyrics/song1.lrc');
    final lyrics2 = await _assetCache.loadString('assets/lyrics/song2.lrc');
    final lyrics3 = await _assetCache.loadString('assets/lyrics/song3.lrc');
    
    // 修复：使用正确的本地资源路径
    final result = await IAppPlayerConfig.createPlayer(
      urls: [
        'http://m804.music.126.net/20250721092811/1f6afe43fa14bedfb52f96637d47acbd/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/60942712315/c65e/8c1a/a815/210492e49065671f04e5c3ba82fd77bd.mp3?vuutv=jX9LLOOzznGh2LlhXGVRq/rHsz587ka2vlctvtRQHa0SFJ4CEr2oQGAp25Itrs3jB3bRBOUQgzdyxFPSkOX1Udf4PQCUMGBnIdbfCUWOaN8=&authSecret=000001982a81931506630a3b184e0ccd',
        'http://m704.music.126.net/20250721092932/750ab58c17428fbc071881c2f12a43ac/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/60971015254/a679/2eb4/b68e/ac48af8be2670dc220d1e26d94b5e3ac.mp3?vuutv=km+pZd2TGDd/xATPqOZAJvAebP33ny5KVaYdWxIHrFwiZY8Nsf2p/V8agOUfRkgyYotmh9dblJE0xfYYz09Mbyiv0s1JnWPvbmctrUd/lIo=&authSecret=000001982a82cecd0c6e0a3084e71618',
        'http://m704.music.126.net/20250721092939/d7d2a534c432991aa0c49904541fbba6/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/61173539343/8a31/86db/b5e0/d9586dc54e235f5df8411a13bad5a61d.mp3?vuutv=sAgX7I9g6nz2+xUEfr8TquOz3SMyI3lWOXhnta0NZEOLiTbMf+dnFnYEqa/3FiERArsYasoDeKiYwRuRTWy04feoBXZzjV6ulkqhTjL0qi0=&authSecret=000001982a82e98b1c3a0a3084b10091',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: ['Creative Design', 'Corporate Creative', 'Cool Hiphop Beat'],
      imageUrls: [
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
      ],
      subtitleContents: [lyrics1, lyrics2, lyrics3],
      audioOnly: true,
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
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
      autoDetectFullscreenDeviceOrientation: true,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
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
      // 移除全局缓存清理
      _playlistController?.dispose();
      _controller = null;
      _playlistController = null;
    } catch (e) {
      print('Player cleanup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSongs = _playlistController?.dataSourceList.length ?? 0;
    final titles = ['Creative Design', 'Corporate Creative', 'Cool Hiphop Beat'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('音乐列表'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F3A),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // 减少顶部间距
              // 音乐封面区域
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFfa709a).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
                        ),
                      ),
                      child: _controller != null
                          ? IAppPlayer(controller: _controller!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15), // 减少间距
              // 当前歌曲信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      _currentIndex < titles.length ? titles[_currentIndex] : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / $totalSongs • ${_shuffleMode ? "随机播放" : "顺序播放"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 控制按钮区域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放控制按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一首
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () => _playlistController!.playPrevious()
                              : null,
                          icon: Icons.skip_previous_rounded,
                        ),
                        // 播放/暂停
                        _buildCircleButton(
                          onPressed: _controller != null && !_isLoading
                              ? () {
                                  if (_controller!.isPlaying() ?? false) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                }
                              : null,
                          icon: (_controller?.isPlaying() ?? false)
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          isPrimary: true,
                        ),
                        // 下一首
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () => _playlistController!.playNext()
                              : null,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 模式切换按钮
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: _shuffleMode ? '切换到顺序播放' : '切换到随机播放',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback? onPressed,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return Container(
      width: isPrimary ? 80 : 60,
      height: isPrimary ? 80 : 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPrimary ? LinearGradient(
          colors: [
            const Color(0xFFfa709a),
            const Color(0xFFfee140),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: const Color(0xFFfa709a).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 36 : 28,
            ),
          ),
        ),
      ),
    );
  }
}
