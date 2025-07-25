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
  Key _playerContainerKey = UniqueKey(); // 添加：用于强制重建播放器
  bool _isSwitchingDecoder = false; // 添加：防止重复切换

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _playerGlobalKey = GlobalKey(); // 初始化时就创建全局键
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
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
            if (!_isPlaying) {  // 【优化】只在状态真正改变时更新
              setState(() {
                _isPlaying = true;
              });
            }
          } else if (event.iappPlayerEventType == IAppPlayerEventType.pause) {
            // 监听暂停事件
            if (_isPlaying) {  // 【优化】只在状态真正改变时更新
              setState(() {
                _isPlaying = false;
              });
            }
          } else if (event.iappPlayerEventType == IAppPlayerEventType.pipStart) {
            // 监听进入画中画
            if (!_isPipMode) {  // 【优化】只在状态真正改变时更新
              setState(() {
                _isPipMode = true;
              });
            }
          } else if (event.iappPlayerEventType == IAppPlayerEventType.pipStop) {
            // 监听退出画中画
            if (_isPipMode) {  // 【优化】只在状态真正改变时更新
              setState(() {
                _isPipMode = false;
              });
            }
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
          _isLoading = false;  // 无论成功与否都要设置加载完成
          if (_controller != null) {
            // 关键修改：设置播放器的 GlobalKey 以启用画中画功能
            _controller!.setIAppPlayerGlobalKey(_playerGlobalKey!);
          }
        });
      }
    } catch (e) {
      print('Player initialization failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;  // 错误时也要设置加载完成
        });
      }
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
    if (_currentDecoder == newDecoder || _isSwitchingDecoder) return;
    
    _isSwitchingDecoder = true; // 设置切换标志
    
    try {
      // 先释放旧的播放器
      await _releasePlayer();
      
      setState(() {
        _currentDecoder = newDecoder;
        _isLoading = true;
        _isPipMode = false;  // 重置画中画状态
        _playerGlobalKey = GlobalKey(); // 在 setState 内创建新的 GlobalKey
        _playerContainerKey = UniqueKey(); // 强制重建播放器容器
      });
      
      // 重新初始化播放器
      await _initializePlayer();
    } finally {
      _isSwitchingDecoder = false; // 确保标志被重置
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    // 只在组件销毁时才清理 GlobalKey
    _playerGlobalKey = null;
    super.dispose();
  }

  Future<void> _releasePlayer() async {
    try {
      // 移除全局缓存清理，避免影响其他页面
      if (_controller != null) {
        // 先退出画中画模式
        if (_isPipMode && _controller!.isVideoInitialized()) {
          try {
            await _controller!.disablePictureInPicture();
            _isPipMode = false; // 立即更新状态
          } catch (e) {
            print('Exit PiP failed: $e');
            _isPipMode = false; // 即使失败也要重置状态
          }
        }
        
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
                              key: _playerContainerKey, // 添加key以强制重建
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
                        child: Row(
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
                    // 画中画按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading && _playerGlobalKey != null
                          ? () {
                              if (_isPipMode) {
                                _controller!.disablePictureInPicture();
                              } else {
                                _controller!.enablePictureInPicture(_playerGlobalKey!);
                              }
                            }
                          : null,
                      icon: _isPipMode
                          ? Icons.picture_in_picture_alt_outlined
                          : Icons.picture_in_picture_alt_rounded,
                      label: _isPipMode ? l10n.exitPictureInPicture : l10n.pictureInPicture,
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
      onTap: _isSwitchingDecoder ? null : () => _switchDecoder(decoder),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.spaceLG,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF667eea) 
                  : Colors.white.withOpacity(_isSwitchingDecoder ? 0.3 : 0.6),
              size: UIConstants.iconMD,
            ),
            SizedBox(width: UIConstants.spaceSM),
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.fontSM,
                color: isSelected 
                    ? const Color(0xFF667eea) 
                    : Colors.white.withOpacity(_isSwitchingDecoder ? 0.3 : 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
