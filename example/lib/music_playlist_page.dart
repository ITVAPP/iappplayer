import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

import 'app_localizations.dart';
import 'common_utils.dart';

// 音乐播放列表页面组件
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
  bool _isPlaying = false;

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // 初始化音乐播放器和歌词配置
  Future<void> _initializePlayer() async {
    // 安全加载LRC歌词文件内容
    final lyrics1 = await safeLoadSubtitle('assets/lyrics/song1.lrc');
    final lyrics2 = await safeLoadSubtitle('assets/lyrics/song2.lrc');
    final lyrics3 = await safeLoadSubtitle('assets/lyrics/song3.lrc');
    
    // 过滤空歌词并构建内容列表
    final subtitleContents = [lyrics1, lyrics2, lyrics3]
        .where((content) => content != null)
        .cast<String>()
        .toList();
    
    // 创建音频播放器实例
    final result = await IAppPlayerConfig.createPlayer(
      urls: [
        'assets/music/song1.mp3',
        'assets/music/song2.mp3',
        'assets/music/song3.mp3',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: ['Creative Design', 'Corporate Creative', 'Cool Hiphop Beat'],
      imageUrls: [
        'assets/images/song1.webp',
        'assets/images/song2.webp',
        'assets/images/song3.webp',
      ],
      subtitleContents: subtitleContents.isNotEmpty ? subtitleContents : null,
      audioOnly: true,
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
        // 监听播放列表曲目切换事件
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
        // 监听音乐播放开始事件
        else if (event.iappPlayerEventType == IAppPlayerEventType.play) {
          if (!_isPlaying) {
            setState(() {
              _isPlaying = true;
            });
          }
        } 
        // 监听音乐暂停事件
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

  // 更新当前播放曲目索引状态
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

  // 释放音乐播放器和播放列表控制器资源
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
    final totalSongs = _playlistController?.dataSourceList.length ?? 0;
    final titles = ['月亮代表我的心', 'Are You That Somebody', 'My Love Is Your Love'];
    final artists = ['邓丽君', 'Aaliyah', 'Whitney Houston'];

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
              // 主要内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG),
                      // 音乐播放器视觉化区域（带发光效果）
                      Container(
                        height: UIConstants.musicPlayerHeight,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceMD),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                          color: Colors.black,
                          boxShadow: [
                            // 主发光效果
                            BoxShadow(
                              color: const Color(0xFFfa709a).withOpacity(0.5),
                              blurRadius: UIConstants.shadowLG,
                              spreadRadius: 5,
                            ),
                            // 外围发光效果
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
                      SizedBox(height: UIConstants.spaceMD - 1),
                      // 当前歌曲信息展示区域
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
                        child: Column(
                          children: [
                            // 显示当前歌曲标题
                            Text(
                              _currentIndex < titles.length ? titles[_currentIndex] : '',
                              style: TextStyle(
                                fontSize: UIConstants.fontXXL,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: UIConstants.spaceXS),
                            // 显示艺术家信息
                            Text(
                              _currentIndex < artists.length ? artists[_currentIndex] : '',
                              style: TextStyle(
                                fontSize: UIConstants.fontLG,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            // 歌词显示组件
                            LyricDisplay(controller: _controller),
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD),
                    ],
                  ),
                ),
              ),
              // 固定底部音乐控制区域
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
                    // 音乐播放控制按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一首切换按钮
                        CircleControlButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playPrevious();
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_previous_rounded,
                          gradientColors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
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
                          gradientColors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
                        ),
                        // 下一首切换按钮
                        CircleControlButton(
                          onPressed: _playlistController != null && !_isLoading
                              ? () {
                                  _playlistController!.playNext();
                                  Future.delayed(Duration(milliseconds: 100), _updateCurrentIndex);
                                }
                              : null,
                          icon: Icons.skip_next_rounded,
                          gradientColors: [
                            const Color(0xFFfa709a),
                            const Color(0xFFfee140),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: UIConstants.spaceLG - 4),
                    // 播放模式和进度信息展示按钮
                    ModernControlButton(
                      onPressed: _playlistController != null
                          ? () => _playlistController!.toggleShuffleMode()
                          : null,
                      icon: _shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                      label: l10n.playlistStatus(_currentIndex + 1, totalSongs, _shuffleMode),
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    // 全屏播放切换按钮
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
}
