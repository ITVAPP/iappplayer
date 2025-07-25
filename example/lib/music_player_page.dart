import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';
import 'player_widgets.dart';
import 'player_lifecycle_mixin.dart';

// 音乐播放器示例 - 使用新的组件和Mixin简化代码
class MusicPlayerExample extends StatefulWidget {
  const MusicPlayerExample({Key? key}) : super(key: key);

  @override
  State<MusicPlayerExample> createState() => _MusicPlayerExampleState();
}

class _MusicPlayerExampleState extends State<MusicPlayerExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin, PlayerLifecycleMixin {
  String? _currentLyric;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    
    final config = IAppPlayerConfig(
      url: 'assets/music/song1.mp3',
      dataSourceType: IAppPlayerDataSourceType.file,
      title: 'Creative Design',
      imageUrl: 'https://www.itvapp.net/images/logo-1.png',
      audioOnly: true,
      aspectRatio: 1.0,
      subtitleContent: lrcContent,
      enableFullscreen: true,
      eventListener: handlePlayerEvent,
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
    if (event.iappPlayerEventType == IAppPlayerEventType.progress) {
      _updateCurrentLyric();
    }
  }

  // 更新当前歌词
  void _updateCurrentLyric() {
    if (controller == null || !mounted) return;
    
    final subtitle = controller!.renderedSubtitle;
    if (subtitle != null && subtitle.texts != null && subtitle.texts!.isNotEmpty) {
      final newLyric = subtitle.texts!.join(' ');
      if (newLyric != _currentLyric) {
        setState(() {
          _currentLyric = newLyric;
        });
      }
    } else {
      if (_currentLyric != null && _currentLyric!.isNotEmpty) {
        setState(() {
          _currentLyric = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(title: l10n.musicPlayer),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 顶部内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: UIConstants.spaceLG),
                      // 播放器区域 - 正方形，带发光效果
                      Container(
                        width: UIConstants.musicPlayerSquareSize,
                        height: UIConstants.musicPlayerSquareSize,
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
                        child: PlayerContainer(
                          aspectRatio: 1.0,
                          glowColors: [const Color(0xFF4facfe)],
                          margin: EdgeInsets.zero,
                          child: errorMessage != null
                              ? PlayerErrorWidget(
                                  message: errorMessage!,
                                  onRetry: retryPlay,
                                )
                              : controller != null
                                  ? IAppPlayer(controller: controller!)
                                  : PlayerLoadingIndicator(),
                        ),
                      ),
                      SizedBox(height: UIConstants.spaceLG),
                      // 歌曲信息
                      MediaInfoDisplay(
                        title: 'Creative Design',
                        subtitle: 'Unknown Artist',
                        currentLyric: _currentLyric,
                        titleStyle: TextStyle(
                          fontSize: UIConstants.fontXXXL,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                  ModernControlButton(
                    onPressed: controller != null && !isLoading
                        ? toggleFullscreen
                        : null,
                    icon: controller?.isFullScreen ?? false
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    label: controller?.isFullScreen ?? false 
                        ? l10n.exitFullscreen 
                        : l10n.fullscreenPlay,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}