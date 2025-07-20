import 'dart:async';
import 'package:iapp_player/src/configuration/iapp_player_controls_configuration.dart';
import 'package:iapp_player/src/controls/iapp_player_clickable_widget.dart';
import 'package:iapp_player/src/controls/iapp_player_controls_state.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_bar.dart';
import 'package:iapp_player/src/controls/iapp_player_multiple_gesture_detector.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_colors.dart';
import 'package:iapp_player/src/core/iapp_player_controller.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitles_drawer.dart';
import 'package:flutter/material.dart';

// 视频播放器控件
class IAppPlayerVideoControls extends StatefulWidget {
  // 控件可见性变化回调
  final Function(bool visbility) onControlsVisibilityChanged;
  // 控件配置
  final IAppPlayerControlsConfiguration controlsConfiguration;

  const IAppPlayerVideoControls({
    Key? key,
    required this.onControlsVisibilityChanged,
    required this.controlsConfiguration,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IAppPlayerVideoControlsState();
}

class _IAppPlayerVideoControlsState extends IAppPlayerControlsState<IAppPlayerVideoControls> {
  // 基础间距单位
  static const double kSpacingUnit = 8.0;
  // 半间距
  static const double kSpacingHalf = 4.0;
  // 双倍间距
  static const double kSpacingDouble = 16.0;
  // 三倍间距
  static const double kSpacingTriple = 24.0;
  // 底部控制栏内边距
  static const double kBottomBarPadding = 5.0;
  // 进度条高度
  static const double kProgressBarHeight = 12.0;
  // 基础图标尺寸
  static const double kIconSizeBase = 24.0;
  // 基础文本尺寸
  static const double kTextSizeBase = 13.0;
  // 错误图标尺寸
  static const double kErrorIconSize = 42.0;
  // 模态框圆角
  static const double kModalBorderRadius = 18.0;
  // 模态框头部高度
  static const double kModalHeaderHeight = 48.0;
  // 播放列表项高度
  static const double kModalItemHeight = 30.0;
  // 模态框标题字体大小
  static const double kModalTitleFontSize = 18.0;
  // 播放列表项字体大小
  static const double kModalItemFontSize = 16.0;
  // 播放指示器图标大小
  static const double kPlayIndicatorIconSize = 20.0;
  // 模态框背景透明度
  static const double kModalBackgroundOpacity = 0.95;
  // 播放列表项悬停透明度
  static const double kModalItemHoverOpacity = 0.08;
  // 播放指示器宽度
  static const double kPlayIndicatorWidth = 48.0;
  // 默认音量
  static const double kDefaultVolume = 0.5;
  // 静音音量
  static const double kMutedVolume = 0.0;
  // 播放列表最大高度比例
  static const double kPlaylistMaxHeightRatio = 0.6;
  // 下一视频提示底部间距
  static const double kNextVideoBottomSpacing = 20.0;
  // 下一视频提示圆角
  static const double kNextVideoBorderRadius = 8.0;
  // 下一视频提示内边距
  static const double kNextVideoPadding = 12.0;
  // 图标阴影
  static const List<Shadow> _iconShadows = [
    Shadow(blurRadius: 3.0, color: Colors.black45, offset: Offset(0.0, 1.0)),
  ];
  // 文本阴影
  static const List<Shadow> _textShadows = [
    Shadow(blurRadius: 2.0, color: Colors.black54, offset: Offset(0.0, 1.0)),
  ];
  // 进度条阴影
  static const List<BoxShadow> _progressBarShadows = [
    BoxShadow(blurRadius: 3.0, color: Colors.black45, offset: Offset(0.0, 1.0)),
  ];

  // 最新播放值
  VideoPlayerValue? _latestValue;
  // 最新音量
  double? _latestVolume;
  // Timer管理器
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  // 是否正在加载
  bool _wasLoading = false;
  // 视频播放控制器
  VideoPlayerController? _controller;
  // 播放器控制器
  IAppPlayerController? _iappPlayerController;
  // 控件可见性流订阅
  StreamSubscription? _controlsVisibilityStreamSubscription;
  // 响应式尺寸缓存
  double? _cachedScaleFactor;
  Size? _cachedScreenSize;
  // 响应式图标尺寸
  late double _responsiveIconSize;
  // 响应式文本尺寸
  late double _responsiveTextSize;
  // 响应式错误图标尺寸
  late double _responsiveErrorIconSize;
  // 响应式控制栏高度
  late double _responsiveControlBarHeight;

  // 获取控件配置
  IAppPlayerControlsConfiguration get _controlsConfiguration => widget.controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  IAppPlayerController? get iappPlayerController => _iappPlayerController;

  @override
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration => _controlsConfiguration;

  // 计算响应式尺寸
  double _getResponsiveSize(double baseSize) {
    if (_cachedScaleFactor == null) return baseSize;
    return baseSize * _cachedScaleFactor!;
  }

  // 更新响应式尺寸缓存
  void _updateResponsiveSizes(BuildContext context) {
    final currentScreenSize = MediaQuery.of(context).size;
    if (_cachedScreenSize != currentScreenSize) {
      _cachedScreenSize = currentScreenSize;
      final screenWidth = currentScreenSize.width;
      final screenHeight = currentScreenSize.height;
      final screenSize = screenWidth < screenHeight ? screenWidth : screenHeight;
      final scaleFactor = screenSize / 360.0;
      _cachedScaleFactor = scaleFactor.clamp(0.8, 1.5);
      _responsiveIconSize = _getResponsiveSize(kIconSizeBase);
      _responsiveTextSize = _getResponsiveSize(kTextSizeBase);
      _responsiveErrorIconSize = _getResponsiveSize(kErrorIconSize);
      _responsiveControlBarHeight = _getResponsiveSize(_controlsConfiguration.controlBarHeight);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖变化时更新响应式尺寸
    _updateResponsiveSizes(context);
    
    final _oldController = _iappPlayerController;
    _iappPlayerController = IAppPlayerController.of(context);
    _controller = _iappPlayerController!.videoPlayerController;
    _latestValue = _controller!.value;
    if (_oldController != _iappPlayerController) {
      _dispose();
      _initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(_buildMainWidget());
  }

  // 构建主控件
  Widget _buildMainWidget() {
    final currentLoading = isLoading(_latestValue);
    if (currentLoading != _wasLoading) {
      _wasLoading = currentLoading;
    }
    if (_latestValue?.hasError == true) {
      return Container(
        color: Colors.black,
        child: _buildErrorWidget(),
      );
    }
    final Widget content = Stack(
      fit: StackFit.expand,
      children: [
        if (_wasLoading) Center(child: _buildLoadingWidget()),
        _buildHitArea(),
        Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        // 字幕显示，动态调整位置
        if (_controlsConfiguration.enableSubtitles)
          AnimatedPositioned(
            duration: _controlsConfiguration.controlsHideTime,
            bottom: controlsNotVisible ? kSpacingUnit : kBottomBarPadding + _responsiveControlBarHeight + kProgressBarHeight,
            left: kSpacingDouble,
            right: kSpacingDouble,
            child: IAppPlayerSubtitlesDrawer(
              iappPlayerController: _iappPlayerController!,
              iappPlayerSubtitlesConfiguration: _iappPlayerController!.iappPlayerConfiguration.subtitlesConfiguration,
              subtitles: _iappPlayerController!.subtitlesLines,
            ),
          ),
        _buildNextVideoWidget(),
      ],
    );
    final gestureDetector = IAppPlayerMultipleGestureDetector.of(context);
    final onTapHandler = () {
      gestureDetector?.onTap?.call();
      controlsNotVisible ? cancelAndRestartTimer() : changePlayerControlsNotVisible(true);
    };
    if (!_controlsConfiguration.handleAllGestures) {
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) => onTapHandler(),
        child: content,
      );
    } else {
      return GestureDetector(
        onTap: onTapHandler,
        onDoubleTap: () {
          gestureDetector?.onDoubleTap?.call();
          cancelAndRestartTimer();
        },
        onLongPress: () {
          gestureDetector?.onLongPress?.call();
        },
        child: content,
      );
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  // 清理资源
  void _dispose() {
    _controller?.removeListener(_updateState);
    _disposeTimers();
    _controlsVisibilityStreamSubscription?.cancel();
  }

  // 统一管理Timer清理
  void _disposeTimers() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _initTimer?.cancel();
    _initTimer = null;
    _showAfterExpandCollapseTimer?.cancel();
    _showAfterExpandCollapseTimer = null;
  }

  // 构建错误提示
  Widget _buildErrorWidget() {
    final errorBuilder = _iappPlayerController!.iappPlayerConfiguration.errorBuilder;
    if (errorBuilder != null) {
      return errorBuilder(context, _iappPlayerController!.videoPlayerController!.value.errorDescription);
    }
    final textStyle = TextStyle(color: _controlsConfiguration.textColor, fontSize: _responsiveTextSize);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_rounded, color: _controlsConfiguration.iconsColor, size: _responsiveErrorIconSize),
          SizedBox(height: kSpacingDouble),
          Text(_iappPlayerController!.translations.generalDefaultError, style: textStyle),
          if (_controlsConfiguration.enableRetry) SizedBox(height: kSpacingDouble),
          if (_controlsConfiguration.enableRetry)
            TextButton(
              onPressed: () => _iappPlayerController!.retryDataSource(),
              child: Text(
                _iappPlayerController!.translations.generalRetry,
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  // 构建带阴影的图标
  Icon _buildShadowedIcon(IconData icon, {double? size}) {
    return Icon(
      icon,
      color: _controlsConfiguration.iconsColor,
      size: size ?? _responsiveIconSize,
      shadows: _iconShadows,
    );
  }

  // 构建控制按钮
  Widget _buildControlButton({
    required VoidCallback onTap,
    required IconData icon,
    double? iconSize,
    Key? key,
  }) {
    return IAppPlayerClickableWidget(
      key: key,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(kSpacingHalf),
        child: _buildShadowedIcon(icon, size: iconSize),
      ),
    );
  }

  // 构建顶部控制栏
  Widget _buildTopBar() {
    if (!iappPlayerController!.controlsEnabled) return const SizedBox();
    return (_controlsConfiguration.enableOverflowMenu)
        ? AnimatedOpacity(
            opacity: controlsNotVisible ? 0.0 : 1.0,
            duration: _controlsConfiguration.controlsHideTime,
            onEnd: _onPlayerHide,
            child: Container(
              height: _responsiveControlBarHeight + kSpacingHalf * 2,
              padding: EdgeInsets.symmetric(horizontal: kSpacingUnit / 2, vertical: kSpacingHalf),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_controlsConfiguration.enablePip) _buildPipButtonWrapperWidget() else const SizedBox(),
                  _buildControlButton(onTap: onShowMoreClicked, icon: _controlsConfiguration.overflowMenuIcon),
                ],
              ),
            ),
          )
        : const SizedBox();
  }

  // 显示播放列表菜单
  void _showPlaylistMenu() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: _iappPlayerController?.iappPlayerConfiguration.useRootNavigator ?? false,
      builder: (context) => _buildPlaylistModal(),
    ).then((_) {
      if (mounted && !controlsNotVisible) _startHideTimer();
    });
  }

  // 构建播放列表模态框
  Widget _buildPlaylistModal() {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: kSpacingDouble),
        decoration: BoxDecoration(
          color: _controlsConfiguration.overflowModalColor.withOpacity(kModalBackgroundOpacity),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(kModalBorderRadius), topRight: Radius.circular(kModalBorderRadius)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(kModalBorderRadius), topRight: Radius.circular(kModalBorderRadius)),
          child: _buildPlaylistMenuContent(),
        ),
      ),
    );
  }

  // 构建播放列表菜单内容
  Widget _buildPlaylistMenuContent() {
    final playlistController = _iappPlayerController!.playlistController;
    final translations = _iappPlayerController!.translations;
    if (playlistController == null) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            translations.playlistUnavailable,
            style: TextStyle(color: _controlsConfiguration.overflowModalTextColor, fontSize: kModalItemFontSize),
          ),
        ),
      );
    }
    final dataSourceList = playlistController.dataSourceList;
    final currentIndex = playlistController.currentDataSourceIndex;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * kPlaylistMaxHeightRatio),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: kModalHeaderHeight,
            padding: EdgeInsets.only(left: kSpacingDouble, right: kSpacingUnit),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _controlsConfiguration.overflowModalTextColor.withOpacity(0.1), width: 1)),
            ),
            child: Row(
              children: [
                Text(
                  translations.playlistTitle,
                  style: TextStyle(color: _controlsConfiguration.overflowModalTextColor, fontSize: kModalTitleFontSize, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.all(kSpacingUnit),
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.close, color: _controlsConfiguration.overflowModalTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: kSpacingUnit),
              itemCount: dataSourceList.length,
              itemBuilder: (context, index) {
                final dataSource = dataSourceList[index];
                final isCurrentItem = index == currentIndex;
                final title = dataSource.notificationConfiguration?.title ?? translations.videoItem.replaceAll('{index}', '${index + 1}');
                return _buildPlaylistItem(
                  title: title,
                  isCurrentItem: isCurrentItem,
                  onTap: () {
                    _playAtIndex(index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建播放列表项
  Widget _buildPlaylistItem({required String title, required bool isCurrentItem, required VoidCallback onTap}) {
    return IAppPlayerClickableWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: kModalItemHeight,
        margin: EdgeInsets.symmetric(horizontal: kSpacingUnit, vertical: 2),
        decoration: BoxDecoration(
          color: isCurrentItem ? _controlsConfiguration.overflowModalTextColor.withOpacity(kModalItemHoverOpacity) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: kPlayIndicatorWidth,
              alignment: Alignment.center,
              child: isCurrentItem
                ? Icon(Icons.play_arrow_rounded, color: _controlsConfiguration.overflowModalTextColor, size: kPlayIndicatorIconSize)
                : null,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _controlsConfiguration.overflowModalTextColor,
                  fontSize: kModalItemFontSize,
                  fontWeight: isCurrentItem ? FontWeight.w600 : FontWeight.normal,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: kSpacingDouble),
          ],
        ),
      ),
    );
  }

  // 播放指定索引的视频
  void _playAtIndex(int index) {
    final playlistController = _iappPlayerController!.playlistController;
    if (playlistController != null) playlistController.setupDataSource(index);
  }

  // 构建画中画按钮
  Widget _buildPipButton() {
    return _buildControlButton(
      onTap: () => iappPlayerController!.enablePictureInPicture(iappPlayerController!.iappPlayerGlobalKey!),
      icon: iappPlayerControlsConfiguration.pipMenuIcon,
    );
  }

  // 构建画中画按钮包装器
  Widget _buildPipButtonWrapperWidget() {
    return FutureBuilder<bool>(
      future: iappPlayerController!.isPictureInPictureSupported(),
      builder: (context, snapshot) {
        final bool isPipSupported = snapshot.data ?? false;
        if (isPipSupported && _iappPlayerController!.iappPlayerGlobalKey != null) {
          return _buildPipButton();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // 构建底部控制栏
  Widget _buildBottomBar() {
    if (!iappPlayerController!.controlsEnabled) return const SizedBox();
    final bool isLive = _iappPlayerController?.isLiveStream() ?? false;
    final bool isPlaylist = _iappPlayerController!.isPlaylistMode;
    return AnimatedOpacity(
      opacity: controlsNotVisible ? 0.0 : 1.0,
      duration: _controlsConfiguration.controlsHideTime,
      onEnd: _onPlayerHide,
      child: Container(
        padding: const EdgeInsets.only(bottom: kBottomBarPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 进度条
            Container(
              height: kProgressBarHeight,
              padding: EdgeInsets.symmetric(horizontal: kSpacingDouble),
              decoration: const BoxDecoration(boxShadow: _progressBarShadows),
              child: _controlsConfiguration.enableProgressBar ? _buildProgressBar() : const SizedBox(),
            ),
            Container(
              height: _responsiveControlBarHeight,
              padding: EdgeInsets.symmetric(horizontal: kSpacingUnit),
              child: Row(
                children: [
                  if (isPlaylist)
                    _buildControlButton(
                      onTap: () {
                        _iappPlayerController!.togglePlaylistShuffle();
                        cancelAndRestartTimer();
                        setState(() {});
                      },
                      icon: _iappPlayerController!.playlistShuffleMode ? Icons.shuffle : Icons.repeat,
                    ),
                  if (!isLive && _controlsConfiguration.enableSkips)
                    if (isPlaylist) ...[
                      if (_iappPlayerController!.playlistController?.hasPrevious ?? false)
                        _buildControlButton(onTap: () => _playWithTimer(true), icon: Icons.skip_previous)
                    ] else
                      _buildControlButton(onTap: skipBack, icon: Icons.fast_rewind),
                  if (_controlsConfiguration.enablePlayPause) _buildPlayPause(_controller!),
                  if (!isLive && _controlsConfiguration.enableSkips)
                    if (isPlaylist) ...[
                      if (_iappPlayerController!.playlistController?.hasNext ?? false)
                        _buildControlButton(onTap: () => _playWithTimer(false), icon: Icons.skip_next)
                    ] else
                      _buildControlButton(onTap: skipForward, icon: Icons.fast_forward),
                  if (_controlsConfiguration.enableMute) _buildMuteButton(_controller),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: kSpacingHalf),
                      child: isLive
                          ? _buildLiveWidget()
                          : _controlsConfiguration.enableProgressText
                              ? _buildPosition()
                              : const SizedBox(),
                    ),
                  ),
                  if (isPlaylist) _buildControlButton(onTap: _showPlaylistMenu, icon: Icons.queue_music),
                  if (_controlsConfiguration.enableFullscreen)
                    _buildControlButton(
                      onTap: _onExpandCollapse,
                      icon: _iappPlayerController!.isFullScreen
                          ? _controlsConfiguration.fullscreenDisableIcon
                          : _controlsConfiguration.fullscreenEnableIcon,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 播放上一个/下一个的逻辑
  void _playWithTimer(bool isPrevious) {
    final playlistController = _iappPlayerController!.playlistController;
    if (playlistController != null) {
      if (isPrevious) {
        playlistController.playPrevious();
      } else {
        playlistController.playNext();
      }
      cancelAndRestartTimer();
    }
  }

  // 构建直播标识
  Widget _buildLiveWidget() {
    return Text(
      _iappPlayerController!.translations.controlsLive,
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, shadows: _textShadows),
    );
  }

  // 构建点击区域
  Widget _buildHitArea() {
    if (!iappPlayerController!.controlsEnabled) return const SizedBox();
    return Container(color: Colors.transparent, width: double.infinity, height: double.infinity);
  }

  // 构建下一视频提示
  Widget _buildNextVideoWidget() {
    return StreamBuilder<int?>(
      stream: _iappPlayerController!.nextVideoTimeStream,
      builder: (context, snapshot) {
        final time = snapshot.data;
        if (time != null && time > 0) {
          return IAppPlayerClickableWidget(
            onTap: () => _iappPlayerController!.playNextVideo(),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(bottom: _responsiveControlBarHeight + kProgressBarHeight + kBottomBarPadding + kNextVideoBottomSpacing, right: kSpacingTriple),
                decoration: BoxDecoration(color: _controlsConfiguration.controlBarColor, borderRadius: BorderRadius.circular(kNextVideoBorderRadius)),
                child: Padding(
                  padding: const EdgeInsets.all(kNextVideoPadding),
                  child: Text(
                    "${_iappPlayerController!.translations.controlsNextIn} $time...",
                    style: TextStyle(color: Colors.white, fontSize: _responsiveTextSize, shadows: _textShadows),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // 构建静音按钮
  Widget _buildMuteButton(VideoPlayerController? controller) {
    return _buildControlButton(
      onTap: () {
        cancelAndRestartTimer();
        if (_latestValue!.volume == kMutedVolume) {
          _iappPlayerController!.setVolume(_latestVolume ?? kDefaultVolume);
        } else {
          _latestVolume = controller!.value.volume;
          _iappPlayerController!.setVolume(kMutedVolume);
        }
      },
      icon: (_latestValue != null && _latestValue!.volume > kMutedVolume)
          ? _controlsConfiguration.muteIcon
          : _controlsConfiguration.unMuteIcon,
    );
  }

  // 构建播放/暂停/重播按钮
  Widget _buildPlayPause(VideoPlayerController controller) {
    final bool isFinished = isVideoFinished(_latestValue);
    return _buildControlButton(
      key: const Key("iapp_player_material_controls_play_pause_button"),
      onTap: _onPlayPause,
      icon: isFinished ? Icons.replay : controller.value.isPlaying ? _controlsConfiguration.pauseIcon : _controlsConfiguration.playIcon,
    );
  }

  // 构建时间显示
  Widget _buildPosition() {
    final position = _latestValue != null ? _latestValue!.position : Duration.zero;
    final duration = _latestValue != null && _latestValue!.duration != null ? _latestValue!.duration! : Duration.zero;
    return Text(
      '${IAppPlayerUtils.formatDuration(position)} / ${IAppPlayerUtils.formatDuration(duration)}',
      style: TextStyle(fontSize: _responsiveTextSize, color: _controlsConfiguration.textColor, shadows: _textShadows),
    );
  }

  @override
  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();
    changePlayerControlsNotVisible(false);
  }

  // 初始化控制器
  Future<void> _initialize() async {
    _controller!.addListener(_updateState);
    _updateState();
    if ((_controller!.value.isPlaying) || _iappPlayerController!.iappPlayerConfiguration.autoPlay) {
      _startHideTimer();
    }
    if (_controlsConfiguration.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 500), () => changePlayerControlsNotVisible(false));
    }
    _controlsVisibilityStreamSubscription = _iappPlayerController!.controlsVisibilityStream.listen((state) {
      changePlayerControlsNotVisible(!state);
      if (!controlsNotVisible) cancelAndRestartTimer();
    });
  }

  // 切换全屏状态
  void _onExpandCollapse() {
    changePlayerControlsNotVisible(true);
    _iappPlayerController!.toggleFullScreen();
    _showAfterExpandCollapseTimer = Timer(_controlsConfiguration.controlsHideTime, () {
      setState(() => cancelAndRestartTimer());
    });
  }

  // 播放/暂停切换
  void _onPlayPause() {
    bool isFinished = false;
    if (_latestValue?.position != null && _latestValue?.duration != null) {
      isFinished = _latestValue!.position >= _latestValue!.duration!;
    }
    if (_controller!.value.isPlaying) {
      changePlayerControlsNotVisible(false);
      _hideTimer?.cancel();
      _iappPlayerController!.pause();
    } else {
      cancelAndRestartTimer();
      if (!_controller!.value.initialized) {
      } else {
        if (isFinished) _iappPlayerController!.seekTo(const Duration());
        _iappPlayerController!.play();
        _iappPlayerController!.cancelNextVideoTimer();
      }
    }
  }

  // 启动隐藏定时器
  void _startHideTimer() {
    if (_iappPlayerController!.controlsAlwaysVisible) return;
    _hideTimer = Timer(const Duration(milliseconds: 5000), () => changePlayerControlsNotVisible(true));
  }

  // 更新播放状态
  void _updateState() {
    if (!mounted) return;
    final newValue = _controller!.value;
    final shouldUpdate = !controlsNotVisible || isVideoFinished(newValue) || _wasLoading || isLoading(newValue);
    if (shouldUpdate) {
      if (_latestValue?.isPlaying != newValue.isPlaying ||
          _latestValue?.position != newValue.position ||
          _latestValue?.duration != newValue.duration ||
          _latestValue?.hasError != newValue.hasError ||
          _latestValue?.isBuffering != newValue.isBuffering ||
          _latestValue?.volume != newValue.volume) {
        setState(() {
          _latestValue = newValue;
          if (isVideoFinished(_latestValue) && _iappPlayerController?.isLiveStream() == false) {
            changePlayerControlsNotVisible(false);
          }
        });
      }
    }
  }

  // 构建进度条
  Widget _buildProgressBar() {
    return IAppPlayerProgressBar(
      _controller,
      _iappPlayerController,
      onDragStart: () => _hideTimer?.cancel(),
      onDragEnd: () => _startHideTimer(),
      onTapDown: () => cancelAndRestartTimer(),
      colors: IAppPlayerProgressColors(
          playedColor: _controlsConfiguration.progressBarPlayedColor,
          handleColor: _controlsConfiguration.progressBarHandleColor,
          bufferedColor: _controlsConfiguration.progressBarBufferedColor,
          backgroundColor: _controlsConfiguration.progressBarBackgroundColor),
    );
  }

  // 控件隐藏回调
  void _onPlayerHide() {
    _iappPlayerController!.toggleControlsVisibility(!controlsNotVisible);
    widget.onControlsVisibilityChanged(!controlsNotVisible);
  }

  // 构建加载指示器
  Widget? _buildLoadingWidget() {
    if (_controlsConfiguration.loadingWidget != null) {
      return Container(color: _controlsConfiguration.controlBarColor, child: _controlsConfiguration.loadingWidget);
    }
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_controlsConfiguration.loadingColor ?? Colors.white),
          strokeWidth: 2.0,
        ),
      ),
    );
  }
}
