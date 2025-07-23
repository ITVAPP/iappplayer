import 'package:flutter/material.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';

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
  String _getCurrentVideoTitle(BuildContext context) {
    final titles = ['Superman (1941)', 'Betty Boop - Snow White', 'Felix the Cat'];
    if (_currentIndex >= 0 && _currentIndex < titles.length) {
      return titles[_currentIndex];
    }
    return AppLocalizations.of(context).videoNumber(_currentIndex + 1);
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
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.videoList),
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
                      // 播放信息卡片 - 显示当前视频标题（修改：移除模式切换按钮）
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
                                  padding: EdgeInsets.all(UIConstants.spaceSM),
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
                                    _getCurrentVideoTitle(context), // 显示当前视频标题
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
                padding: EdgeInsets.all(UIConstants.spaceMD),
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
                    SizedBox(height: UIConstants.spaceMD),
                    // 修改：添加播放模式切换按钮
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: _shuffleMode ? l10n.shufflePlay : l10n.sequentialPlay,
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
                      label: _controller?.isFullScreen ?? false 
                          ? l10n.exitFullscreen 
                          : l10n.fullscreen,
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
    final l10n = AppLocalizations.of(context);
    
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
                vertical: UIConstants.spaceSM,
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
                    l10n.playlist,
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
              height: 260,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: UIConstants.spaceXS),
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
                      l10n.videoNumber(index + 1),
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
