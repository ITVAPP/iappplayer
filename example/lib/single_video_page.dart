import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';
import 'player_widgets.dart';
import 'player_lifecycle_mixin.dart';

// 解码器类型状态管理
enum DecoderState {
  hardware,
  software,
}

// 单视频播放示例 - 使用新的组件和Mixin简化代码
class SingleVideoExample extends StatefulWidget {
  const SingleVideoExample({Key? key}) : super(key: key);

  @override
  State<SingleVideoExample> createState() => _SingleVideoExampleState();
}

class _SingleVideoExampleState extends State<SingleVideoExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin, PlayerLifecycleMixin {
  DecoderState _currentDecoder = DecoderState.hardware;
  bool _isPipMode = false;
  GlobalKey? _playerGlobalKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerGlobalKey = GlobalKey();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    handleOrientationChange();
  }

  @override
  Future<void> initializePlayer() async {
    // 安全读取字幕
    final subtitleContent = await safeLoadSubtitle('assets/subtitles/video1.srt');
    
    // 创建播放器配置
    final config = IAppPlayerConfig(
      url: 'assets/videos/video1.mp4',
      dataSourceType: IAppPlayerDataSourceType.file,
      title: 'Superman (1941)',
      imageUrl: 'https://www.itvapp.net/images/logo-1.png',
      subtitleContent: subtitleContent,
      enableFullscreen: true,
      eventListener: handlePlayerEvent,
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

    await createPlayer(config);
  }

  @override
  void onPlayerInitialized() {
    handleOrientationChange();
  }

  @override
  void handleCustomEvent(IAppPlayerEvent event) {
    if (event.iappPlayerEventType == IAppPlayerEventType.pipStart) {
      setState(() {
        _isPipMode = true;
      });
    } else if (event.iappPlayerEventType == IAppPlayerEventType.pipStop) {
      setState(() {
        _isPipMode = false;
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
    });
    
    _playerGlobalKey = GlobalKey();
    await retryPlay();
  }

  // 切换画中画
  void _togglePip() {
    if (controller == null || isLoading || _playerGlobalKey == null) return;
    
    if (_isPipMode) {
      controller!.disablePictureInPicture();
    } else {
      controller!.enablePictureInPicture(_playerGlobalKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(title: l10n.videoPlayer),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 顶部内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 播放器区域
                      PlayerContainer(
                        aspectRatio: 16 / 9,
                        child: errorMessage != null
                            ? PlayerErrorWidget(
                                message: errorMessage!,
                                onRetry: retryPlay,
                              )
                            : controller != null
                                ? IAppPlayer(
                                    key: _playerGlobalKey,
                                    controller: controller!,
                                  )
                                : PlayerLoadingIndicator(),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceMD),
                    ],
                  ),
                ),
              ),
              // 控制按钮区域
              PlayerControlPanel(
                children: [
                  PlayPauseButton(
                    isPlaying: isPlaying,
                    isLoading: isLoading || controller == null,
                    onPressed: togglePlayPause,
                  ),
                  SizedBox(height: UIConstants.spaceMD),
                  // 画中画按钮（移到全屏按钮上面）
                  ModernControlButton(
                    onPressed: controller != null && !isLoading ? _togglePip : null,
                    icon: _isPipMode
                        ? Icons.picture_in_picture_alt_outlined
                        : Icons.picture_in_picture_alt_rounded,
                    label: _isPipMode ? l10n.exitPictureInPicture : l10n.pictureInPicture,
                  ),
                  SizedBox(height: UIConstants.spaceMD),
                  // 全屏按钮
                  FullscreenButton(
                    isFullscreen: controller?.isFullScreen ?? false,
                    isLoading: isLoading || controller == null,
                    onPressed: toggleFullscreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 修改解码器选项为横向布局（图标和文字在同一行）
  Widget _buildDecoderOption(String label, DecoderState decoder, IconData icon) {
    final isSelected = _currentDecoder == decoder;
    
    return GestureDetector(
      onTap: () => _switchDecoder(decoder),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.spaceLG,
          vertical: UIConstants.spaceSM + 2,
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
                  : Colors.white.withOpacity(0.6),
              size: UIConstants.iconMD,
            ),
            SizedBox(width: UIConstants.spaceSM),
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.fontMD,
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