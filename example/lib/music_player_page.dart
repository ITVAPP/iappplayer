import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';

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
  String? _currentLyric; // 添加当前歌词状态

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
      aspectRatio: 1.0,   // 传递比例显示正方形播放器
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
        } else if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
          // 监听播放进度，更新歌词
          _updateCurrentLyric();
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
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.musicPlayer),
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
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
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
                      SizedBox(height: UIConstants.spaceLG),
                      // 歌曲信息
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
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
                      label: _isPlaying ? l10n.pausePlay : l10n.continuePlay,
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
