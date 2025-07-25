import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';
import 'player_widgets.dart';
import 'player_lifecycle_mixin.dart';

// 音乐播放列表示例 - 使用新的组件和Mixin简化代码
class MusicPlaylistExample extends StatefulWidget {
  const MusicPlaylistExample({Key? key}) : super(key: key);

  @override
  State<MusicPlaylistExample> createState() => _MusicPlaylistExampleState();
}

class _MusicPlaylistExampleState extends State<MusicPlaylistExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin, PlayerLifecycleMixin, PlaylistLifecycleMixin {
  String? _currentLyric;
  
  // 歌曲信息
  static const List<String> _songTitles = [
    'Creative Design',
    'Corporate Creative',
    'Cool Hiphop Beat',
  ];
  static const List<String> _artists = [
    'Unknown Artist',
    'Unknown Artist',
    'Unknown Artist',
  ];

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
    // 安全读取LRC歌词文件
    final lyrics1 = await safeLoadSubtitle('assets/lyrics/song1.lrc');
    final lyrics2 = await safeLoadSubtitle('assets/lyrics/song2.lrc');
    final lyrics3 = await safeLoadSubtitle('assets/lyrics/song3.lrc');
    
    // 构建歌词内容列表
    final subtitleContents = [lyrics1, lyrics2, lyrics3]
        .where((content) => content != null)
        .cast<String>()
        .toList();
    
    final config = IAppPlayerConfig(
      urls: [
        'assets/music/song1.mp3',
        'assets/music/song2.mp3',
        'assets/music/song3.mp3',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: _songTitles,
      imageUrls: List.filled(3, 'https://www.itvapp.net/images/logo-1.png'),
      subtitleContents: subtitleContents.isNotEmpty ? subtitleContents : null,
      audioOnly: true,
      enableFullscreen: true,
      eventListener: handlePlayerEvent,
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

    await createPlayer(config);
  }

  @override
  void onPlayerInitialized() {
    handleOrientationChange();
  }

  @override
  void onPlaylistItemChanged(int index) {
    setState(() {
      _currentLyric = null; // 切换歌曲时清空歌词
    });
  }

  @override
  void handleCustomEvent(IAppPlayerEvent event) {
    super.handleCustomEvent(event);
    
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
    final totalSongs = playlistController?.dataSourceList.length ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(title: l10n.musicList),
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
                      // 播放器区域
                      PlayerContainer(
                        aspectRatio: UIConstants.musicPlayerHeight / MediaQuery.of(context).size.width,
                        glowColors: [const Color(0xFFfa709a)],
                        margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceMD),
                        child: Container(
                          height: UIConstants.musicPlayerHeight,
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
                      SizedBox(height: UIConstants.spaceMD - 1),
                      // 当前歌曲信息
                      MediaInfoDisplay(
                        title: currentIndex < _songTitles.length 
                            ? _songTitles[currentIndex] 
                            : '',
                        subtitle: currentIndex < _artists.length 
                            ? _artists[currentIndex] 
                            : '',
                        currentLyric: _currentLyric,
                        titleStyle: TextStyle(
                          fontSize: UIConstants.fontXXL,
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
                  // 播放控制按钮行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleControlButton(
                        onPressed: playlistController != null && !isLoading
                            ? playPrevious
                            : null,
                        icon: Icons.skip_previous_rounded,
                      ),
                      CircleControlButton(
                        onPressed: controller != null && !isLoading
                            ? togglePlayPause
                            : null,
                        icon: isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        isPrimary: true,
                      ),
                      CircleControlButton(
                        onPressed: playlistController != null && !isLoading
                            ? playNext
                            : null,
                        icon: Icons.skip_next_rounded,
                      ),
                    ],
                  ),
                  SizedBox(height: UIConstants.spaceLG - 4),
                  // 模式切换按钮 - 显示播放进度信息
                  ModernControlButton(
                    onPressed: playlistController != null ? toggleShuffleMode : null,
                    icon: shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                    label: l10n.playlistStatus(currentIndex + 1, totalSongs, shuffleMode),
                  ),
                  SizedBox(height: UIConstants.spaceMD),
                  // 全屏播放按钮
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