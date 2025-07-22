import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

void main() {
  runApp(const MyApp());
}

// UI常量定义 - 集中管理所有硬编码数字
class UIConstants {
  // 间距常量
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 40.0;
  static const double spaceXXXL = 60.0;
  
  // 圆角常量
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 30.0;
  
  // 按钮尺寸
  static const double buttonSizeSmall = 48.0;  // 新增：小尺寸按钮
  static const double buttonSizeNormal = 60.0;
  static const double buttonSizeLarge = 80.0;
  
  // 图标尺寸
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 28.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 36.0;
  static const double iconLogo = 64.0;
  
  // 字体大小
  static const double fontSM = 14.0;
  static const double fontMD = 16.0;
  static const double fontLG = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontXXXL = 28.0;
  static const double fontXXXXL = 32.0;
  
  // 阴影模糊半径
  static const double shadowSM = 10.0;
  static const double shadowMD = 20.0;
  static const double shadowLG = 30.0;
  
  // 音乐播放器专用
  static const double musicPlayerHeight = 120.0;
  static const double musicPlayerSquareSize = 200.0; // 新增：单首音乐播放的正方形尺寸
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
                padding: EdgeInsets.only(
                  top: UIConstants.spaceMD, // 减少顶部间距
                  left: UIConstants.spaceLG,
                  right: UIConstants.spaceLG,
                  bottom: UIConstants.spaceMD, // 减少底部间距
                ),
                child: Column(
                  children: [
                    // 使用图片替代图标
                    Image.asset(
                      'assets/images/logo.png',
                      width: UIConstants.iconLogo,
                      height: UIConstants.iconLogo,
                    ),
                    SizedBox(height: UIConstants.spaceSM), // 减少间距
                    Text(
                      'IApp Player',
                      style: TextStyle(
                        fontSize: UIConstants.fontXXXXL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 选项卡片
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    left: UIConstants.spaceLG - 4, // 20
                    right: UIConstants.spaceLG - 4, // 20
                    bottom: UIConstants.spaceLG - 4, // 20
                    top: 0, // 第一个选项卡无上边距
                  ),
                  children: [
                    _buildModernCard(
                      context,
                      icon: Icons.movie_outlined,
                      title: '视频播放器',
                      subtitle: '支持切换软硬件解码',
                      gradient: [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const SingleVideoExample(),
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    _buildModernCard(
                      context,
                      icon: Icons.playlist_play,
                      title: '视频列表',
                      subtitle: '支持随机和顺序播放',
                      gradient: [
                        const Color(0xFFf093fb),
                        const Color(0xFFf5576c),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const PlaylistExample(),
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceMD),
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
                    SizedBox(height: UIConstants.spaceMD),
                    _buildModernCard(
                      context,
                      icon: Icons.queue_music,
                      title: '音乐列表',
                      subtitle: '另一种播放UI的展示',
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
        borderRadius: BorderRadius.circular(UIConstants.radiusLG),
        child: Container(
          padding: EdgeInsets.all(UIConstants.spaceMD), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusLG),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: UIConstants.shadowMD,
                offset: Offset(0, UIConstants.shadowSM),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(UIConstants.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                ),
                child: Icon(
                  icon,
                  size: UIConstants.iconXL,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: UIConstants.spaceLG - 4), // 20
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: UIConstants.fontXL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceXS),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: UIConstants.fontSM,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.8),
                size: UIConstants.iconSM,
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
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
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
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(UIConstants.radiusMD),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: UIConstants.spaceLG,
              vertical: UIConstants.spaceMD,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: UIConstants.iconMD,
                ),
                SizedBox(width: UIConstants.spaceSM + 4), // 12
                Text(
                  label,
                  style: TextStyle(
                    fontSize: UIConstants.fontMD,
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

// 解码器类型状态管理
enum DecoderState {
  hardware,
  software,
  auto,
}

// 安全读取字幕内容的辅助函数
Future<String?> _safeLoadSubtitle(String path) async {
  try {
    return await rootBundle.loadString(path);
  } catch (e) {
    print('字幕加载失败: $path, 错误: $e');
    return null;
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
  DecoderState _currentDecoder = DecoderState.hardware;
  bool _isPlaying = false; // 添加播放状态跟踪

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 安全读取字幕，即使失败也不影响播放
    final subtitleContent = await _safeLoadSubtitle('assets/subtitles/video1.srt');
    
    // 修复：使用正确的本地资源路径
    final result = await IAppPlayerConfig.createPlayer(
      url: 'assets/videos/video1.mp4',
      dataSourceType: IAppPlayerDataSourceType.file,
      title: 'Superman (1941)',
      imageUrl: 'https://www.itvapp.net/images/logo-1.png',
      subtitleContent: subtitleContent, // 可能为null，但不影响播放
      enableFullscreen: true, // 添加全屏功能
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
            _isPlaying = _controller?.isPlaying() ?? false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
        } else if (event.iappPlayerEventType == IAppPlayerEventType.play) {
          // 监听播放事件
          setState(() {
            _isPlaying = true;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.pause) {
          // 监听暂停事件
          setState(() {
            _isPlaying = false;
          });
        }
      },
      preferredDecoderType: _getDecoderType(),
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

  IAppPlayerDecoderType _getDecoderType() {
    switch (_currentDecoder) {
      case DecoderState.hardware:
        return IAppPlayerDecoderType.hardwareFirst;
      case DecoderState.software:
        return IAppPlayerDecoderType.softwareFirst;
      case DecoderState.auto:
        return IAppPlayerDecoderType.auto;
    }
  }

  // 切换解码器
  void _switchDecoder(DecoderState newDecoder) async {
    if (_currentDecoder == newDecoder) return;
    
    setState(() {
      _currentDecoder = newDecoder;
      _isLoading = true;
    });
    
    // 重新初始化播放器
    await _releasePlayer();
    await _initializePlayer();
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
              // 顶部内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 播放器区域
                      Container(
                        margin: EdgeInsets.all(UIConstants.spaceMD),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: UIConstants.shadowMD,
                              offset: Offset(0, UIConstants.shadowSM),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
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
                      // 解码器选择器
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceMD),
                        padding: EdgeInsets.all(UIConstants.spaceMD),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '解码器选择',
                              style: TextStyle(
                                fontSize: UIConstants.fontMD,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: UIConstants.spaceSM),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDecoderOption(
                                  '硬件解码',
                                  DecoderState.hardware,
                                  Icons.memory,
                                ),
                                _buildDecoderOption(
                                  '软件解码',
                                  DecoderState.software,
                                  Icons.computer,
                                ),
                                _buildDecoderOption(
                                  '自动选择',
                                  DecoderState.auto,
                                  Icons.auto_mode,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD), // 统一间距
                    ],
                  ),
                ),
              ),
              // 控制按钮区域 - 固定在底部
              Container(
                padding: EdgeInsets.all(UIConstants.spaceLG),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(UIConstants.radiusXL),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放/暂停按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            }
                          : null,
                      icon: _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: _isPlaying ? '暂停播放' : '继续播放',
                      isPrimary: true,
                    ),
                    SizedBox(height: UIConstants.spaceMD),
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

  Widget _buildDecoderOption(String label, DecoderState decoder, IconData icon) {
    final isSelected = _currentDecoder == decoder;
    
    return GestureDetector(
      onTap: () => _switchDecoder(decoder),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.spaceMD,
          vertical: UIConstants.spaceSM,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF667eea).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(UIConstants.radiusSM),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF667eea)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF667eea) 
                  : Colors.white.withOpacity(0.6),
              size: UIConstants.iconMD,
            ),
            SizedBox(height: UIConstants.spaceXS),
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.fontSM,
                color: isSelected 
                    ? const Color(0xFF667eea) 
                    : Colors.white.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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
  bool _isPlaying = false; // 添加播放状态跟踪

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 修复：使用正确的本地资源路径，移除字幕相关代码
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
      enableFullscreen: true, // 添加全屏功能
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
            _isPlaying = _controller?.isPlaying() ?? false;
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
        } else if (event.iappPlayerEventType == IAppPlayerEventType.play) {
          // 监听播放事件
          setState(() {
            _isPlaying = true;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.pause) {
          // 监听暂停事件
          setState(() {
            _isPlaying = false;
          });
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

  // 获取当前视频标题
  String _getCurrentVideoTitle() {
    final titles = ['Superman (1941)', 'Betty Boop - Snow White', 'Felix the Cat'];
    if (_currentIndex >= 0 && _currentIndex < titles.length) {
      return titles[_currentIndex];
    }
    return '视频 ${_currentIndex + 1}';
  }

  // 修复：添加更新当前索引的方法
  void _updateCurrentIndex() {
    if (_playlistController != null && mounted) {
      final newIndex = _playlistController!.currentDataSourceIndex;
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
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
              // 顶部内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 播放器区域
                      Container(
                        margin: EdgeInsets.all(UIConstants.spaceMD),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: UIConstants.shadowMD,
                              offset: Offset(0, UIConstants.shadowSM),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
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
                      // 播放信息卡片 - 显示当前视频标题
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceMD),
                        padding: EdgeInsets.all(UIConstants.spaceMD),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667eea),
                              const Color(0xFF764ba2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: UIConstants.shadowMD,
                              offset: Offset(0, UIConstants.shadowSM),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 左侧播放列表按钮 - 可点击打开播放列表
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showPlaylistMenu,
                                borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                                child: Container(
                                  padding: EdgeInsets.all(UIConstants.spaceSM + 4), // 12
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                                  ),
                                  child: Icon(
                                    Icons.queue_music_rounded,
                                    color: Colors.white,
                                    size: UIConstants.iconMD,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: UIConstants.spaceMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getCurrentVideoTitle(), // 显示当前视频标题
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: UIConstants.fontLG,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: UIConstants.spaceXS),
                                  Text(
                                    '${_currentIndex + 1} / $totalVideos', // 显示播放进度
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: UIConstants.fontSM,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 模式切换按钮
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _playlistController != null
                                    ? () => _playlistController!.toggleShuffleMode()
                                    : null,
                                borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: UIConstants.spaceMD,
                                    vertical: UIConstants.spaceSM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                                        color: Colors.white,
                                        size: UIConstants.iconXS,
                                      ),
                                      SizedBox(width: UIConstants.spaceXS),
                                      Text(
                                        _shuffleMode ? '随机' : '顺序',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: UIConstants.fontSM,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD), // 统一间距
                    ],
                  ),
                ),
              ),
              // 控制按钮区域 - 固定在底部
              Container(
                padding: EdgeInsets.all(UIConstants.spaceLG),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(UIConstants.radiusXL),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放控制按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一个 - 修复：添加索引更新
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playPrevious();
                                  // 延迟更新索引
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_previous_rounded,
                        ),
                        // 播放/暂停
                        _buildCircleButton(
                          onPressed: _controller != null && !_isLoading
                              ? () {
                                  if (_isPlaying) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                }
                              : null,
                          icon: _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          isPrimary: true,
                        ),
                        // 下一个 - 修复：添加索引更新
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playNext();
                                  // 延迟更新索引
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: UIConstants.spaceLG - 4), // 20
                    // 全屏播放按钮
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

  // 显示播放列表菜单
  void _showPlaylistMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          left: UIConstants.spaceMD,
          right: UIConstants.spaceMD,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A).withOpacity(0.95),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UIConstants.radiusLG),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.spaceLG,
                vertical: UIConstants.spaceMD,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.playlist_play,
                    color: Colors.white,
                    size: UIConstants.iconMD,
                  ),
                  SizedBox(width: UIConstants.spaceSM),
                  Text(
                    '播放列表',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: UIConstants.fontLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 列表内容
            Container(
              height: 300,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: UIConstants.spaceSM),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final titles = ['Superman (1941)', 'Betty Boop - Snow White', 'Felix the Cat'];
                  final isPlaying = index == _currentIndex;
                  
                  return ListTile(
                    leading: Icon(
                      isPlaying ? Icons.play_circle_filled : Icons.play_circle_outline,
                      color: isPlaying ? const Color(0xFF667eea) : Colors.white.withOpacity(0.6),
                    ),
                    title: Text(
                      titles[index],
                      style: TextStyle(
                        color: isPlaying ? const Color(0xFF667eea) : Colors.white,
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '视频 ${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: UIConstants.fontSM,
                      ),
                    ),
                    onTap: () {
                      _playlistController?.setupDataSource(index);
                      Navigator.pop(context);
                      // 修复：更新当前索引
                      Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                    },
                  );
                },
              ),
            ),
          ],
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
      width: isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall, // 修改：调小按钮尺寸
      height: isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall, // 修改：调小按钮尺寸
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
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
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
              size: isPrimary ? UIConstants.iconLG : UIConstants.iconMD, // 修改：调整图标大小
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
  bool _isPlaying = false; // 添加播放状态跟踪

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
      enableFullscreen: true, // 添加全屏功能
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
            _isPlaying = _controller?.isPlaying() ?? false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
        } else if (event.iappPlayerEventType == IAppPlayerEventType.play) {
          // 监听播放事件
          setState(() {
            _isPlaying = true;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.pause) {
          // 监听暂停事件
          setState(() {
            _isPlaying = false;
          });
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
              // 顶部内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG), // 顶部间距
                      // 播放器区域 - 正方形，带发光效果
                      Container(
                        width: UIConstants.musicPlayerSquareSize,
                        height: UIConstants.musicPlayerSquareSize,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                          color: Colors.black,
                          boxShadow: [
                            // 发光效果
                            BoxShadow(
                              color: const Color(0xFF4facfe).withOpacity(0.5),
                              blurRadius: UIConstants.shadowLG,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: const Color(0xFF4facfe).withOpacity(0.3),
                              blurRadius: UIConstants.shadowLG * 2,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
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
                      SizedBox(height: UIConstants.spaceLG),
                      // 歌曲信息
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXL),
                        child: Column(
                          children: [
                            Text(
                              'Creative Design',
                              style: TextStyle(
                                fontSize: UIConstants.fontXXXL,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: UIConstants.spaceSM),
                            Text(
                              'Unknown Artist',
                              style: TextStyle(
                                fontSize: UIConstants.fontLG,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD), // 增加底部间距
                    ],
                  ),
                ),
              ),
              // 控制按钮区域 - 固定在底部
              Container(
                padding: EdgeInsets.all(UIConstants.spaceLG),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(UIConstants.radiusXL),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放/暂停按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            }
                          : null,
                      icon: _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: _isPlaying ? '暂停播放' : '继续播放',
                      isPrimary: true,
                    ),
                    SizedBox(height: UIConstants.spaceMD),
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
                      label: '全屏播放',
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
  bool _isPlaying = false; // 添加播放状态跟踪
  String? _currentLyric; // 当前歌词

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 安全读取LRC歌词文件
    final lyrics1 = await _safeLoadSubtitle('assets/lyrics/song1.lrc');
    final lyrics2 = await _safeLoadSubtitle('assets/lyrics/song2.lrc');
    final lyrics3 = await _safeLoadSubtitle('assets/lyrics/song3.lrc');
    
    // 构建歌词内容列表，过滤掉null值
    final subtitleContents = [lyrics1, lyrics2, lyrics3]
        .where((content) => content != null)
        .cast<String>()
        .toList();
    
    // 修复：使用正确的本地资源路径
    final result = await IAppPlayerConfig.createPlayer(
      urls: [
        'assets/music/song1.mp3',
        'assets/music/song2.mp3',
        'assets/music/song3.mp3',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: ['Creative Design', 'Corporate Creative', 'Cool Hiphop Beat'],
      imageUrls: [
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
        'https://www.itvapp.net/images/logo-1.png',
      ],
      subtitleContents: subtitleContents.isNotEmpty ? subtitleContents : null,
      audioOnly: true,
      enableFullscreen: true, // 添加全屏功能
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
            _isPlaying = _controller?.isPlaying() ?? false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
        } else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistItem) {
          final index = event.parameters?['index'] as int?;
          if (index != null) {
            setState(() {
              _currentIndex = index;
              _currentLyric = null; // 切换歌曲时清空歌词
            });
          }
        } else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
          final shuffleMode = event.parameters?['shuffleMode'] as bool?;
          if (shuffleMode != null) {
            setState(() {
              _shuffleMode = shuffleMode;
            });
          }
        } else if (event.iappPlayerEventType == IAppPlayerEventType.play) {
          // 监听播放事件
          setState(() {
            _isPlaying = true;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.pause) {
          // 监听暂停事件
          setState(() {
            _isPlaying = false;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
          // 监听播放进度，更新歌词
          _updateCurrentLyric();
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

  // 更新当前歌词
  void _updateCurrentLyric() {
    if (_controller == null || !mounted) return;
    
    // 获取当前正在渲染的字幕
    final subtitle = _controller!.renderedSubtitle;
    if (subtitle != null && subtitle.texts != null && subtitle.texts!.isNotEmpty) {
      final newLyric = subtitle.texts!.join(' ');
      if (newLyric != _currentLyric) {
        setState(() {
          _currentLyric = newLyric;
        });
      }
    }
  }

  // 修复：添加更新当前索引的方法
  void _updateCurrentIndex() {
    if (_playlistController != null && mounted) {
      final newIndex = _playlistController!.currentDataSourceIndex;
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
          _currentLyric = null; // 切换歌曲时清空歌词
        });
      }
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
    final artists = ['Unknown Artist', 'Unknown Artist', 'Unknown Artist']; // 修复：添加歌手信息

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
              // 顶部内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG), // 顶部间距
                      // 播放器区域 - 保持原尺寸，带发光效果
                      Container(
                        height: UIConstants.musicPlayerHeight,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceMD),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                          color: Colors.black,
                          boxShadow: [
                            // 发光效果
                            BoxShadow(
                              color: const Color(0xFFfa709a).withOpacity(0.5),
                              blurRadius: UIConstants.shadowLG,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: const Color(0xFFfa709a).withOpacity(0.3),
                              blurRadius: UIConstants.shadowLG * 2,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
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
                      SizedBox(height: UIConstants.spaceMD - 1), // 15 - 减少间距
                      // 当前歌曲信息 - 添加歌词显示
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXL),
                        child: Column(
                          children: [
                            Text(
                              _currentIndex < titles.length ? titles[_currentIndex] : '',
                              style: TextStyle(
                                fontSize: UIConstants.fontXXL,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: UIConstants.spaceXS),
                            Text(
                              _currentIndex < artists.length ? artists[_currentIndex] : '',
                              style: TextStyle(
                                fontSize: UIConstants.fontLG,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            // 显示当前歌词
                            if (_currentLyric != null && _currentLyric!.isNotEmpty) ...[
                              SizedBox(height: UIConstants.spaceSM),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: Text(
                                  _currentLyric!,
                                  key: ValueKey(_currentLyric),
                                  style: TextStyle(
                                    fontSize: UIConstants.fontMD,
                                    color: Colors.white.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD), // 增加底部间距
                    ],
                  ),
                ),
              ),
              // 控制按钮区域 - 固定在底部
              Container(
                padding: EdgeInsets.all(UIConstants.spaceLG),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(UIConstants.radiusXL),
                  ),
                ),
                child: Column(
                  children: [
                    // 播放控制按钮行 - 调小按钮尺寸
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一首 - 修复：添加索引更新
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playPrevious();
                                  // 延迟更新索引和歌词
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_previous_rounded,
                        ),
                        // 播放/暂停
                        _buildCircleButton(
                          onPressed: _controller != null && !_isLoading
                              ? () {
                                  if (_isPlaying) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                }
                              : null,
                          icon: _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          isPrimary: true,
                        ),
                        // 下一首 - 修复：添加索引更新
                        _buildCircleButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playNext();
                                  // 延迟更新索引和歌词
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: UIConstants.spaceLG - 4), // 20
                    // 模式切换按钮 - 显示播放进度信息
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: '${_currentIndex + 1} / $totalSongs • ${_shuffleMode ? "随机播放" : "顺序播放"}',
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    // 全屏播放按钮
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
                      label: '全屏播放',
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
      width: isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall,
      height: isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall,
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
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
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
              size: isPrimary ? UIConstants.iconLG : UIConstants.iconMD,
            ),
          ),
        ),
      ),
    );
  }
}
