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
  static const double musicPlayerHeight = 180.0;
  static const double musicCoverSize = 100.0; // 封面大小减半
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
                    SizedBox(height: UIConstants.spaceXS), // 减少间距
                    Text(
                      '选择您的播放体验',
                      style: TextStyle(
                        fontSize: UIConstants.fontMD,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 选项卡片
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(UIConstants.spaceLG - 4), // 20
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
                    SizedBox(height: UIConstants.spaceMD),
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
        borderRadius: BorderRadius.circular(UIConstants.radiusLG),
        child: Container(
          padding: EdgeInsets.all(UIConstants.spaceLG - 4), // 20
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
      eventListener: (event) {
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
          });
          // 初始化后检查方向
          _handleOrientationChange();
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
          // 使用 SingleChildScrollView 解决滚动问题
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                    ],
                  ),
                  // 控制按钮区域
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

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 安全读取字幕文件
    final subtitle1 = await _safeLoadSubtitle('assets/subtitles/video1.srt');
    final subtitle2 = await _safeLoadSubtitle('assets/subtitles/video2.srt');
    final subtitle3 = await _safeLoadSubtitle('assets/subtitles/video3.srt');
    
    // 构建字幕内容列表，过滤掉null值
    final subtitleContents = [subtitle1, subtitle2, subtitle3]
        .where((content) => content != null)
        .cast<String>()
        .toList();
    
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
      subtitleContents: subtitleContents.isNotEmpty ? subtitleContents : null,
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
          // 使用 SingleChildScrollView 解决滚动问题
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      // 播放信息卡片
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
                            Container(
                              padding: EdgeInsets.all(UIConstants.spaceSM + 4), // 12
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                              ),
                              child: Icon(
                                Icons.playlist_play_rounded,
                                color: Colors.white,
                                size: UIConstants.iconMD,
                              ),
                            ),
                            SizedBox(width: UIConstants.spaceMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '播放进度',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: UIConstants.fontSM,
                                    ),
                                  ),
                                  SizedBox(height: UIConstants.spaceXS),
                                  Text(
                                    '${_currentIndex + 1} / $totalVideos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: UIConstants.fontXL,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
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
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD),
                    ],
                  ),
                  // 控制按钮区域
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
                        SizedBox(height: UIConstants.spaceLG - 4), // 20
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
      width: isPrimary ? UIConstants.buttonSizeLarge : UIConstants.buttonSizeNormal,
      height: isPrimary ? UIConstants.buttonSizeLarge : UIConstants.buttonSizeNormal,
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
              size: isPrimary ? UIConstants.iconXXL : UIConstants.iconLG,
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
          // 使用 SingleChildScrollView 解决滚动问题
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG - 4), // 20 - 减少顶部间距
                      // 音乐封面区域 - 使用logo.png
                      Container(
                        width: UIConstants.musicCoverSize,
                        height: UIConstants.musicCoverSize,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4facfe).withOpacity(0.3),
                              blurRadius: UIConstants.shadowLG,
                              offset: Offset(0, UIConstants.spaceLG - 4), // 20
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceLG - 4), // 20 - 减少间距
                      // 播放器区域 - 固定高度180
                      Container(
                        height: UIConstants.musicPlayerHeight,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                          color: Colors.black.withOpacity(0.3),
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
                      SizedBox(height: UIConstants.spaceLG - 4), // 20 - 减少间距
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
                    ],
                  ),
                  // 控制按钮区域
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
                          label: '全屏歌词',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      subtitleContents: subtitleContents.isNotEmpty ? subtitleContents : null,
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
          // 使用 SingleChildScrollView 解决滚动问题
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG - 4), // 20 - 减少顶部间距
                      // 音乐封面区域 - 使用logo.png
                      Container(
                        width: UIConstants.musicCoverSize,
                        height: UIConstants.musicCoverSize,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXXL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFfa709a).withOpacity(0.3),
                              blurRadius: UIConstants.shadowLG,
                              offset: Offset(0, UIConstants.spaceLG - 4), // 20
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD), // 16 - 调整间距
                      // 播放器区域 - 固定高度180
                      Container(
                        height: UIConstants.musicPlayerHeight,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXXL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                          color: Colors.black.withOpacity(0.3),
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
                      // 当前歌曲信息
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
                            SizedBox(height: UIConstants.spaceSM),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: UIConstants.spaceMD,
                                vertical: UIConstants.spaceSM,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFfa709a),
                                    const Color(0xFFfee140),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                              ),
                              child: Text(
                                '${_currentIndex + 1} / $totalSongs • ${_shuffleMode ? "随机播放" : "顺序播放"}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: UIConstants.fontSM,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 控制按钮区域
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
                        SizedBox(height: UIConstants.spaceLG - 4), // 20
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
      width: isPrimary ? UIConstants.buttonSizeLarge : UIConstants.buttonSizeNormal,
      height: isPrimary ? UIConstants.buttonSizeLarge : UIConstants.buttonSizeNormal,
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
              size: isPrimary ? UIConstants.iconXXL : UIConstants.iconLG,
            ),
          ),
        ),
      ),
    );
  }
}
