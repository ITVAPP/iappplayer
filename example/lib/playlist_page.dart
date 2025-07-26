import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';
import 'app_localizations.dart';
import 'common_utils.dart';

// 播放列表页面组件
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
  bool _isPlaying = false;

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // 初始化播放列表配置和控制器
  Future<void> _initializePlayer() async {
    // 创建多视频播放列表实例
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
      enableFullscreen: true,
      eventListener: (event) {
        // 监听播放器初始化完成事件
        if (event.iappPlayerEventType == IAppPlayerEventType.initialized) {
          setState(() {
            _isLoading = false;
            _isPlaying = _controller?.isPlaying() ?? false;
          });
          handleOrientationChange();
        } 
        // 监听播放列表项切换事件
        else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistItem) {
          final index = event.parameters?['index'] as int?;
          if (index != null && index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        } 
        // 监听播放模式切换事件（随机/顺序）
        else if (event.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
          final shuffleMode = event.parameters?['shuffleMode'] as bool?;
          if (shuffleMode != null && shuffleMode != _shuffleMode) {
            setState(() {
              _shuffleMode = shuffleMode;
            });
          }
        } 
        // 监听视频播放开始事件
        else if (event.iappPlayerEventType == IAppPlayerEventType.play) {
          if (!_isPlaying) {
            setState(() {
              _isPlaying = true;
            });
          }
        } 
        // 监听视频暂停事件
        else if (event.iappPlayerEventType == IAppPlayerEventType.pause) {
          if (_isPlaying) {
            setState(() {
              _isPlaying = false;
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

    // 检查组件挂载状态并更新控制器
    if (mounted) {
      setState(() {
        _controller = result.activeController;
        _playlistController = result.playlistController;
      });
    }
  }

  // 根据当前索引获取视频标题
  String _getCurrentVideoTitle(BuildContext context) {
    final titles = ['Superman (1941)', 'Betty Boop - Snow White', 'Felix the Cat'];
    if (_currentIndex >= 0 && _currentIndex < titles.length) {
      return titles[_currentIndex];
    }
    return AppLocalizations.of(context).videoNumber(_currentIndex + 1);
  }

  // 更新当前播放索引状态
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

  // 释放播放器和播放列表控制器资源
  Future<void> _releasePlayer() async {
    try {
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
              // 主要内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 视频播放器容器
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
                      // 播放信息展示卡片
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
                            // 播放列表菜单触发按钮
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
                                  // 显示当前播放视频标题
                                  Text(
                                    _getCurrentVideoTitle(context),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: UIConstants.fontLG,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: UIConstants.spaceXS),
                                  // 显示播放进度信息
                                  Text(
                                    '${_currentIndex + 1} / $totalVideos',
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
                      SizedBox(height: UIConstants.spaceMD),
                    ],
                  ),
                ),
              ),
              // 固定底部控制按钮区域
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
                        // 上一曲播放按钮
                        CircleControlButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playPrevious();
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_previous_rounded,
                        ),
                        // 播放暂停切换按钮
                        CircleControlButton(
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
                        // 下一曲播放按钮
                        CircleControlButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playNext();
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    // 播放模式切换按钮
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: _shuffleMode ? l10n.shufflePlay : l10n.sequentialPlay,
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    // 全屏模式切换按钮
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

  // 展示播放列表弹窗菜单
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
            // 弹窗标题栏
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
            // 播放列表视频项目展示
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
                    // 点击切换到指定视频
                    onTap: () {
                      _playlistController?.setupDataSource(index);
                      Navigator.pop(context);
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
}
