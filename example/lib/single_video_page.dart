import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';

// 解码器类型状态管理
enum DecoderState {
  hardware,
  software,
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
  bool _isPipMode = false; // 添加画中画状态跟踪
  GlobalKey? _playerGlobalKey; // 添加：播放器全局键

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _playerGlobalKey = GlobalKey(); // 初始化全局键
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 安全读取字幕，即使失败也不影响播放
    final subtitleContent = await safeLoadSubtitle('assets/subtitles/video1.srt');
    
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
          handleOrientationChange();
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
        } else if (event.iappPlayerEventType == IAppPlayerEventType.pipStart) {
          // 监听进入画中画
          setState(() {
            _isPipMode = true;
          });
        } else if (event.iappPlayerEventType == IAppPlayerEventType.pipStop) {
          // 监听退出画中画
          setState(() {
            _isPipMode = false;
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
        if (_controller != null) {
          _isLoading = false;
        }
      });
    }
  }

  IAppPlayerDecoderType _getDecoderType() {
    switch (_currentDecoder) {
      case DecoderState.hardware:
        return IAppPlayerDecoderType.hardwareFirst;
      case DecoderState.software:
        return IAppPlayerDecoderType.softwareFirst;
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
    _playerGlobalKey = GlobalKey(); // 重新创建全局键
    await _initializePlayer();
  }

  @override
  void dispose() {
    _releasePlayer();
    _playerGlobalKey = null; // 清理全局键
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
        title: Text(l10n.videoPlayer),
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
                                  ? IAppPlayer(
                                      key: _playerGlobalKey, // 关键修改：绑定 GlobalKey 到 Widget
                                      controller: _controller!,
                                    )
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
                              l10n.decoderSelection,
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
                                  l10n.hardwareDecoder,
                                  DecoderState.hardware,
                                  Icons.memory,
                                ),
                                _buildDecoderOption(
                                  l10n.softwareDecoder,
                                  DecoderState.software,
                                  Icons.computer,
                                ),
                                _buildPipOption(),
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

  // 画中画选项按钮
  Widget _buildPipOption() {
    return GestureDetector(
      onTap: _controller != null && !_isLoading && _playerGlobalKey != null
          ? () {
              if (_isPipMode) {
                _controller!.disablePictureInPicture();
              } else {
                _controller!.enablePictureInPicture(_playerGlobalKey!);
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.spaceMD,
          vertical: UIConstants.spaceSM,
        ),
        decoration: BoxDecoration(
          color: _isPipMode 
              ? const Color(0xFF667eea).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(UIConstants.radiusSM),
          border: Border.all(
            color: _isPipMode 
                ? const Color(0xFF667eea)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isPipMode
                  ? Icons.picture_in_picture_alt_outlined
                  : Icons.picture_in_picture_alt_rounded,
              color: _isPipMode 
                  ? const Color(0xFF667eea) 
                  : Colors.white.withOpacity(0.6),
              size: UIConstants.iconMD,
            ),
            SizedBox(height: UIConstants.spaceXS),
            Text(
              _isPipMode ? '退出画中画' : '画中画',
              style: TextStyle(
                fontSize: UIConstants.fontSM,
                color: _isPipMode 
                    ? const Color(0xFF667eea) 
                    : Colors.white.withOpacity(0.6),
                fontWeight: _isPipMode ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
