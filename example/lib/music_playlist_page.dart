import 'package:flutter/material.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';

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
    final lyrics1 = await safeLoadSubtitle('assets/lyrics/song1.lrc');
    final lyrics2 = await safeLoadSubtitle('assets/lyrics/song2.lrc');
    final lyrics3 = await safeLoadSubtitle('assets/lyrics/song3.lrc');
    
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
    } else {
      // 处理没有歌词的情况
      if (_currentLyric != null && _currentLyric!.isNotEmpty) {
        setState(() {
          _currentLyric = null;
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
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.musicList),
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
                        padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
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
                            // 显示当前歌词（修改：增强动画效果）
                            if (_currentLyric != null && _currentLyric!.isNotEmpty) ...[
                              SizedBox(height: UIConstants.spaceSM),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                switchInCurve: Curves.easeIn,
                                switchOutCurve: Curves.easeOut,
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  // 组合淡入淡出和缩放动画
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.95,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  _currentLyric!,
                                  key: ValueKey(_currentLyric),
                                  style: TextStyle(
                                    fontSize: UIConstants.fontMD,
                                    color: Colors.white.withOpacity(0.9),
                                    fontStyle: FontStyle.italic,
                                    height: 1.5, // 增加行高
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
                      label: l10n.playlistStatus(_currentIndex + 1, totalSongs, _shuffleMode),
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
                          : l10n.fullscreenPlay,
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
