import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 导入通用工具类和语言类
import 'app_localizations.dart';
import 'common_utils.dart';
import 'player_widgets.dart';
import 'player_lifecycle_mixin.dart';

// 播放列表示例 - 使用新的组件和Mixin简化代码
class PlaylistExample extends StatefulWidget {
  const PlaylistExample({Key? key}) : super(key: key);

  @override
  State<PlaylistExample> createState() => _PlaylistExampleState();
}

class _PlaylistExampleState extends State<PlaylistExample> 
    with WidgetsBindingObserver, PlayerOrientationMixin, PlayerLifecycleMixin, PlaylistLifecycleMixin {
  
  // 视频标题列表
  static const List<String> _videoTitles = [
    'Superman (1941)',
    'Betty Boop - Snow White',
    'Felix the Cat',
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
    final config = IAppPlayerConfig(
      urls: [
        'assets/videos/video1.mp4',
        'assets/videos/video2.mp4',
        'assets/videos/video3.mp4',
      ],
      dataSourceType: IAppPlayerDataSourceType.file,
      titles: _videoTitles,
      imageUrls: List.filled(3, 'https://www.itvapp.net/images/logo-1.png'),
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

  // 获取当前视频标题
  String _getCurrentVideoTitle(BuildContext context) {
    if (currentIndex >= 0 && currentIndex < _videoTitles.length) {
      return _videoTitles[currentIndex];
    }
    return AppLocalizations.of(context).videoNumber(currentIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalVideos = playlistController?.dataSourceList.length ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(title: l10n.videoList),
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
                                ? IAppPlayer(controller: controller!)
                                : PlayerLoadingIndicator(),
                      ),
                      // 播放信息卡片
                      _buildPlaylistInfoCard(context, totalVideos),
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
                  SizedBox(height: UIConstants.spaceMD),
                  // 播放模式切换按钮
                  ModernControlButton(
                    onPressed: playlistController != null ? toggleShuffleMode : null,
                    icon: shuffleMode ? Icons.shuffle_rounded : Icons.repeat_rounded,
                    label: shuffleMode ? l10n.shufflePlay : l10n.sequentialPlay,
                  ),
                  SizedBox(height: UIConstants.spaceMD),
                  // 全屏播放按钮
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

  // 构建播放列表信息卡片
  Widget _buildPlaylistInfoCard(BuildContext context, int totalVideos) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: UIConstants.spaceMD),
      padding: EdgeInsets.all(UIConstants.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
          ),
        ],
      ),
      child: Row(
        children: [
          // 播放列表按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showPlaylistMenu,
              borderRadius: BorderRadius.circular(UIConstants.radiusSM),
              child: Container(
                padding: EdgeInsets.all(UIConstants.spaceSM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  color: Colors.white,
                  size: UIConstants.iconMD,
                ),
              ),
            ),
          ),
          SizedBox(width: UIConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCurrentVideoTitle(context),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: UIConstants.fontLG,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: UIConstants.spaceXS),
                Text(
                  '${currentIndex + 1} / $totalVideos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: UIConstants.fontSM,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 显示播放列表菜单
  void _showPlaylistMenu() {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          left: UIConstants.spaceMD,
          right: UIConstants.spaceMD,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A).withOpacity(0.95),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UIConstants.radiusLG),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.spaceLG,
                vertical: UIConstants.spaceSM,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.playlist_play,
                    color: Colors.white,
                    size: UIConstants.iconMD,
                  ),
                  SizedBox(width: UIConstants.spaceSM),
                  Text(
                    l10n.playlist,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: UIConstants.fontLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 列表内容
            Container(
              height: 260,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: UIConstants.spaceXS),
                itemCount: _videoTitles.length,
                itemBuilder: (context, index) {
                  final isPlaying = index == currentIndex;
                  
                  return ListTile(
                    leading: Icon(
                      isPlaying ? Icons.play_circle_filled : Icons.play_circle_outline,
                      color: isPlaying ? const Color(0xFF667eea) : Colors.white.withOpacity(0.6),
                    ),
                    title: Text(
                      _videoTitles[index],
                      style: TextStyle(
                        color: isPlaying ? const Color(0xFF667eea) : Colors.white,
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      l10n.videoNumber(index + 1),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: UIConstants.fontSM,
                      ),
                    ),
                    onTap: () {
                      playAtIndex(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}