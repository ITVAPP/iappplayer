import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

import 'app_localizations.dart';
import 'common_utils.dart';

// 定义解码器类型枚举
enum DecoderState {
  hardware,
  software,
}

// 单视频播放页面组件
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
  bool _isPlaying = false;
  bool _isPipMode = false;
  Key _playerContainerKey = UniqueKey();
  bool _isSwitchingDecoder = false;

  @override
  IAppPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // 初始化播放器配置
  Future<void> _initializePlayer() async {
    try {
      // 安全加载字幕文件内容
      final subtitleContent = await safeLoadSubtitle('assets/subtitles/video1.srt');
      
      // 创建播放器实例并配置参数
      final result = await IAppPlayerConfig.createPlayer(
        url: 'assets/videos/video1.mp4',
        dataSourceType: IAppPlayerDataSourceType.file,
        title: 'Big Buck Bunny',
        imageUrl: 'https://www.itvapp.net/images/logo-1.png',
        subtitleContent: subtitleContent,
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
          // 监听画中画模式开启事件
          else if (event.iappPlayerEventType == IAppPlayerEventType.pipStart) {
            if (!_isPipMode) {
              setState(() {
                _isPipMode = true;
              });
            }
          } 
          // 监听画中画模式退出事件
          else if (event.iappPlayerEventType == IAppPlayerEventType.pipStop) {
            if (_isPipMode) {
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

      // 检查组件是否仍然挂载并更新控制器状态
      if (mounted) {
        setState(() {
          _controller = result.activeController;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Player initialization failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 根据当前解码器状态返回对应类型
  IAppPlayerDecoderType _getDecoderType() {
    switch (_currentDecoder) {
      case DecoderState.hardware:
        return IAppPlayerDecoderType.hardwareFirst;
      case DecoderState.software:
        return IAppPlayerDecoderType.softwareFirst;
    }
  }

  // 切换解码器类型并重新初始化播放器
  void _switchDecoder(DecoderState newDecoder) async {
    if (_currentDecoder == newDecoder || _isSwitchingDecoder) return;
    
    _isSwitchingDecoder = true;
    
    try {
      // 释放当前播放器资源
      await _releasePlayer();
      
      setState(() {
        _currentDecoder = newDecoder;
        _isLoading = true;
        _isPipMode = false;
        _playerContainerKey = UniqueKey();
      });
      
      // 使用新解码器重新初始化播放器
      await _initializePlayer();
    } finally {
      _isSwitchingDecoder = false;
    }
  }

  @override
  void dispose() {
    _releasePlayer();
    super.dispose();
  }

  // 释放播放器资源并清理状态
  Future<void> _releasePlayer() async {
    try {
      if (_controller != null) {
        // 退出画中画模式
        if (_isPipMode && (_controller!.isVideoInitialized() ?? false)) {
          try {
            await _controller!.disablePictureInPicture();
            _isPipMode = false;
          } catch (e) {
            print('Exit PiP failed: $e');
            _isPipMode = false;
          }
        }
        
        // 停止播放并静音
        if (_controller!.isPlaying() ?? false) {
          await _controller!.pause();
          await _controller!.setVolume(0);
        }
        
        // 销毁控制器实例
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
                              key: _playerContainerKey,
                              color: Colors.black,
                              child: _controller != null
                                  ? IAppPlayer(
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
                      // 解码器选项切换器
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
                    // 画中画模式切换按钮
                    ModernControlButton(
                      onPressed: _controller != null && !_isLoading
                          ? () {
                              if (_isPipMode) {
                                _controller!.disablePictureInPicture();
                              } else {
                                _controller!.enablePictureInPicture(); 
                              }
                            }
                          : null,
                      icon: _isPipMode
                          ? Icons.picture_in_picture_alt_outlined
                          : Icons.picture_in_picture_alt_rounded,
                      label: _isPipMode ? l10n.exitPictureInPicture : l10n.pictureInPicture,
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

  // 构建解码器选项UI组件
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
