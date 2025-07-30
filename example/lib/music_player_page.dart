import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

import 'app_localizations.dart';
import 'common_utils.dart';

// 单曲音乐播放器页面组件
class MusicPlayerExample extends StatefulWidget {
  const MusicPlayerExample({Key? key}) : super(key: key);

  @override
  State<MusicPlayerExample> createState() => _MusicPlayerExampleState();
}

class _MusicPlayerExampleState extends State<MusicPlayerExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin {
  // 歌曲信息常量定义
  static const String _songTitle = 'Are You That Somebody';
  static const String _artistName = 'Aaliyah';
  static const String _songImageUrl = 'assets/images/song2.webp';
  static const String _songUrl = 'assets/music/song2.mp3';
  
  IAppPlayerController? _controller;
  bool _isLoading = true;
  bool _isPlaying = false;

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // 初始化单曲音乐播放器配置
  Future<void> _initializePlayer() async {
    // 定义内置LRC歌词内容
    const lrcContent = '''[00:01.35]Dirty South, can y'all really feel me
[00:04.27]East coast feel me
[00:06.01]West coast feel me
[00:07.76]Dirty South, can y'all really feel me
[00:11.06]East coast feel me
[00:12.58]West coast feel me
[00:14.18]Dirty South, dirty dirty, can y'all really feel me
[00:18.12]East coast feel me
[00:19.87]West coast feel me
[00:21.59]Dirty South, dirty dirty, can y'all really feel me
[00:25.00]East coast feel me
[00:27.08]West coast feel me
[00:28.53]Boy, I been watching you like a hawk in the sky
[00:33.67]That flies, cause you were my prey (my prey)
[00:37.21]Boy, I promise you if we keep bumpin heads
[00:40.29]I know that one of these days (days)
[00:43.56]We gon hook it up while we talk on the phone
[00:47.70]But see, I don't know if that's good
[00:50.55]I been holding back this secret from you
[00:54.24]I probably shouldn't tell it but
[00:56.95]If I, if I let you know
[00:59.87]You can't tell nobody
[01:01.75]I'm talking bout nobody
[01:03.27]Are you responsible
[01:07.00]Boy I gotta watch my back
[01:08.93]Cause I'm not just anybody
[01:11.13]Is it my go, is it your go
[01:14.32]Sometimes I'm goody-goody
[01:15.12]Right now I'm naughty naughty
[01:16.94]Say yes or say no
[01:20.65]Cause I really need somebody
[01:21.80]Tell me you're that somebody
[01:24.15]Boy, won't you pick me up at the park right now
[01:29.38]Up the block, while everyone sleeps (sleeps, sleeps)
[01:33.17]I'll be waiting there with my tucks, my loads, my hat
[01:37.38]Just so I'm low key
[01:39.34]If you tell the world (don't sleep, you know that we'll be weak)
[01:45.06]Oh boy, see I'm trusting you with my heart, my soul
[01:49.70]I probably shouldn't let ya but if I
[01:53.71]If I, if I let this go
[01:55.77]You can't tell nobody
[01:57.43]I'm talking bout nobody
[01:59.13]I hope you're responsible
[02:02.20]Boy I gotta watch my back
[02:04.51]Cause I'm not just anybody
[02:06.78]Is it my go, is it your go
[02:09.82]Sometimes I'm goody-goody
[02:10.78]Right now I'm naughty naughty
[02:13.73]Say yes or say no
[02:16.46]Cause I really need somebody
[02:18.01]Tell me you're that somebody
[02:19.71]Baby girl
[02:21.11]I'm the man from the big VA
[02:23.28]Won't you come play round my way
[02:25.12]And listen to what I gotta say
[02:26.94]Don't you know I am the man
[02:29.87]Rock shows here to Japan
[02:31.89]Have people shaking-shaking my hand
[02:33.77]Baby girl, better known as Aaliyah
[02:36.34]Give me hives, corns, and high fevers
[02:39.86]Make the playa haters believe us
[02:41.75]Gotta tell somebody
[02:43.15]Cause I really need somebody
[02:45.68]Tell me you're that somebody
[02:46.75]You can't tell nobody, I'm talking about nobody
[02:55.44]I hope you're responsible
[02:58.60]Boy I gotta watch my back
[03:00.22]Cause I'm not just anybody
[03:02.39]Is it my go, is it your go
[03:05.52]Sometimes I'm goody-goody
[03:06.27]Right now I'm naughty naughty
[03:09.31]Say yes or say no
[03:12.13]Cause I really need somebody
[03:13.82]Tell me you're that somebody
[03:15.39]You can't tell nobody, I'm talking about nobody
[03:23.15]I hope you're responsible
[03:24.58]Boy I gotta watch my back
[03:27.92]Cause I'm not just anybody
[03:30.21]Is it my go, is it your go
[03:33.24]Sometimes I'm goody-goody
[03:35.44]Right now I'm naughty naughty
[03:36.43]Say yes or say no''';
    
    // 创建单曲音频播放器实例
    final result = await IAppPlayerConfig.createPlayer(
      url: _songUrl,
      dataSourceType: IAppPlayerDataSourceType.file,
      title: _songTitle, 
      author: _artistName,
      imageUrl: _songImageUrl, 
      audioOnly: true,
      aspectRatio: 1.0,
      subtitleContent: lrcContent,
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
      });
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  // 释放单曲播放器资源并清理状态
  Future<void> _releasePlayer() async {
    try {
      if (_controller != null) {
        // 停止播放并销毁控制器
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
              // 主要内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG),
                      // 音乐播放器区域
                      Container(
                        width: UIConstants.musicPlayerSquareSize,
                        height: UIConstants.musicPlayerSquareSize,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(UIConstants.radiusLG),
                          color: Colors.black,
                          boxShadow: [
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
                      // 歌曲信息展示区域
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
                        child: Column(
                          children: [
                            // 显示歌曲标题
                            Text(
                              _songTitle,
                              style: TextStyle(
                                fontSize: UIConstants.fontXXXL,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: UIConstants.spaceSM),
                            // 显示艺术家信息
                            Text(
                              _artistName,
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
              // 固定底部控制按钮区域
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
                    // 播放暂停控制按钮
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
