import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iapp_player/src/configuration/iapp_player_controls_configuration.dart';
import 'package:iapp_player/src/controls/iapp_player_clickable_widget.dart';
import 'package:iapp_player/src/controls/iapp_player_controls_state.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_bar.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_colors.dart';
import 'package:iapp_player/src/core/iapp_player_controller.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitles_drawer.dart';

// 音频播放控件
class IAppPlayerAudioControls extends StatefulWidget {
  // 控件可见性变化回调
  final Function(bool visbility) onControlsVisibilityChanged;
  // 控件配置
  final IAppPlayerControlsConfiguration controlsConfiguration;

  const IAppPlayerAudioControls({
    Key? key,
    required this.onControlsVisibilityChanged,
    required this.controlsConfiguration,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IAppPlayerAudioControlsState();
}

class _IAppPlayerAudioControlsState extends IAppPlayerControlsState<IAppPlayerAudioControls> 
    with TickerProviderStateMixin {
  // 基础间距单位
  static const double kSpacingUnit = 8.0;
  // 半间距
  static const double kSpacingHalf = 4.0;
  // 双倍间距
  static const double kSpacingDouble = 16.0;

  // 进度条高度
  static const double kProgressBarHeight = 12.0;
  // 音频控件条高度
  static const double kAudioControlBarHeight = 36.0;
  // 基础图标尺寸
  static const double kIconSizeBase = 22.0;
  // 播放/暂停图标尺寸
  static const double kPlayPauseIconSize = 26.0;
  // 基础文本尺寸
  static const double kTextSizeBase = 13.0;
  // 错误图标尺寸
  static const double kErrorIconSize = 42.0;

  // 图标阴影模糊半径
  static const double kIconShadowBlurRadius = 3.0;
  // 文本阴影模糊半径
  static const double kTextShadowBlurRadius = 2.0;
  // 阴影垂直偏移
  static const double kShadowOffsetY = 1.0;
  // 阴影水平偏移
  static const double kShadowOffsetX = 0.0;

  // 模态框圆角
  static const double kModalBorderRadius = 22.0;
  // 模态框头部高度
  static const double kModalHeaderHeight = 48.0;
  // 播放列表项高度
  static const double kModalItemHeight = 30.0;
  // 模态框标题字体大小
  static const double kModalTitleFontSize = 18.0;
  // 播放列表项字体大小
  static const double kModalItemFontSize = 16.0;
  // 播放指示器图标尺寸
  static const double kPlayIndicatorIconSize = 20.0;
  // 模态框背景透明度
  static const double kModalBackgroundOpacity = 0.95;
  // 播放列表项悬停透明度
  static const double kModalItemHoverOpacity = 0.08;

  // 禁用按钮透明度
  static const double kDisabledButtonOpacity = 0.3;
  // 静音音量
  static const double kMutedVolume = 0.0;
  // 播放列表最大高度比例
  static const double kPlaylistMaxHeightRatio = 0.6;

  // 时间文本尺寸减量
  static const double kTimeTextSizeDecrease = 1.0;
  // 时间与进度条水平间距
  static const double kTimeProgressSpacing = 8.0;

  // 扩展模式高度阈值
  static const double kExpandedModeThreshold = 200.0;
  // 封面尺寸
  static const double kCoverSize = 100.0;
  // 标题字体大小
  static const double kTitleFontSize = 16.0;
  // 封面圆角
  static const double kCoverBorderRadius = 12.0;
  // 默认音乐图标比例
  static const double kDefaultMusicIconRatio = 0.6;

  // 紧凑模式相关常量
  static const double kCompactModeMinHeight = 120.0;
  static const double kCompactModeMaxHeight = 180.0;
  static const double kCompactDiscSize = 80.0;
  static const double kCompactPointerWidth = 20.0;
  static const double kDiscBorderWidth = 2.0;
  static const double kPointerRotationAngle = -15.0;
  static const double kPointerPlayRotationAngle = 0.0;

  // 唱臂相关常量
  static const double kPointerArmLength = 60.0;
  static const double kPointerBaseSize = 16.0;
  static const double kPointerNeedleWidth = 4.0;
  static const double kPointerShadowSpread = 2.0;
  static const double kPointerArmOffset = 5.0;

  // 常量样式定义
  static const List<Shadow> _textShadows = [
    Shadow(blurRadius: kTextShadowBlurRadius, color: Colors.black54, offset: Offset(kShadowOffsetX, kShadowOffsetY)),
  ];

  static const List<BoxShadow> _progressBarShadows = [
    BoxShadow(blurRadius: kIconShadowBlurRadius, color: Colors.black45, offset: Offset(kShadowOffsetX, kShadowOffsetY)),
  ];

  static const List<Shadow> _iconShadows = [
    Shadow(blurRadius: kIconShadowBlurRadius, color: Colors.black45, offset: Offset(kShadowOffsetX, kShadowOffsetY)),
  ];

  // 常量EdgeInsets
  static const EdgeInsets _controlsPadding = EdgeInsets.symmetric(horizontal: kSpacingDouble);
  static const EdgeInsets _progressPadding = EdgeInsets.only(
    left: kSpacingDouble,
    right: kSpacingDouble,
    top: kSpacingUnit,
  );
  static const EdgeInsets _progressPaddingLive = EdgeInsets.only(
    left: kSpacingDouble,
    right: kSpacingDouble,
    top: 0.0,
  );
  static const EdgeInsets _iconButtonPadding = EdgeInsets.all(kSpacingHalf);
  static const EdgeInsets _titlePadding = EdgeInsets.symmetric(horizontal: kSpacingUnit);
  static const EdgeInsets _modalHeaderPadding = EdgeInsets.only(left: kSpacingDouble, right: kSpacingUnit);
  static const EdgeInsets _modalListPadding = EdgeInsets.symmetric(vertical: kSpacingUnit);
  static const EdgeInsets _modalItemMargin = EdgeInsets.symmetric(horizontal: kSpacingUnit, vertical: 2);

  // 常量BorderRadius
  static const BorderRadius _modalTopBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(kModalBorderRadius),
    topRight: Radius.circular(kModalBorderRadius),
  );
  static const BorderRadius _coverBorderRadius = BorderRadius.all(Radius.circular(kCoverBorderRadius));
  static const BorderRadius _itemBorderRadius = BorderRadius.all(Radius.circular(8));

  // 常量SizedBox
  static const SizedBox _spacingDoubleBox = SizedBox(height: kSpacingDouble);
  static const SizedBox _spacingDoubleWidthBox = SizedBox(width: kSpacingDouble);
  static const SizedBox _timeSpacingBox = SizedBox(width: kTimeProgressSpacing);

  // 最新播放值
  VideoPlayerValue? _latestValue;
  // 最新音量，用于静音恢复
  double? _latestVolume;
  // 视频播放控制器
  VideoPlayerController? _controller;
  // 播放器控制器
  IAppPlayerController? _iappPlayerController;

  // 唱片旋转动画控制器
  AnimationController? _rotationController;
  // 唱片旋转动画
  Animation<double>? _rotationAnimation;
  // 指针动画控制器
  AnimationController? _pointerController;
  // 指针动画
  Animation<double>? _pointerAnimation;

  // 获取控件配置
  IAppPlayerControlsConfiguration get _controlsConfiguration => widget.controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  IAppPlayerController? get iappPlayerController => _iappPlayerController;

  @override
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration => _controlsConfiguration;

  // 响应式尺寸缓存
  double? _cachedScaleFactor;
  // 屏幕尺寸缓存
  Size? _cachedScreenSize;
  // 响应式图标尺寸
  late double _responsiveIconSize;
  // 响应式播放/暂停图标尺寸
  late double _responsivePlayPauseIconSize;
  // 响应式文本尺寸
  late double _responsiveTextSize;
  // 响应式错误图标尺寸
  late double _responsiveErrorIconSize;
  // 响应式封面尺寸
  late double _responsiveCoverSize;
  // 响应式标题字体尺寸
  late double _responsiveTitleFontSize;

  // 计算响应式尺寸
  double _getResponsiveSize(BuildContext context, double baseSize) {
    final currentScreenSize = MediaQuery.of(context).size;

    if (_cachedScreenSize == currentScreenSize && _cachedScaleFactor != null) {
      return baseSize * _cachedScaleFactor!;
    }

    _cachedScreenSize = currentScreenSize;
    final screenWidth = currentScreenSize.width;
    final screenHeight = currentScreenSize.height;
    final screenSize = screenWidth < screenHeight ? screenWidth : screenHeight;

    final scaleFactor = screenSize / 360.0;
    _cachedScaleFactor = scaleFactor.clamp(0.8, 1.5);

    return baseSize * _cachedScaleFactor!;
  }

  // 预计算响应式尺寸
  void _precalculateResponsiveSizes(BuildContext context) {
    _responsiveIconSize = _getResponsiveSize(context, kIconSizeBase);
    _responsivePlayPauseIconSize = _getResponsiveSize(context, kPlayPauseIconSize);
    _responsiveTextSize = _getResponsiveSize(context, kTextSizeBase);
    _responsiveErrorIconSize = _getResponsiveSize(context, kErrorIconSize);
    _responsiveCoverSize = _getResponsiveSize(context, kCoverSize);
    _responsiveTitleFontSize = _getResponsiveSize(context, kTitleFontSize);
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  // 初始化动画
  void _initializeAnimations() {
    // 唱片旋转动画
    _rotationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController!,
      curve: Curves.linear,
    ));

    // 指针动画
    _pointerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pointerAnimation = Tween<double>(
      begin: kPointerRotationAngle,
      end: kPointerPlayRotationAngle,
    ).animate(CurvedAnimation(
      parent: _pointerController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(
      LayoutBuilder(
        builder: (context, constraints) {
          // 判断是否为扩展模式
          final bool isExpandedMode = constraints.maxHeight != double.infinity && 
                                     constraints.maxHeight > kExpandedModeThreshold;
          return _buildMainWidget(isExpandedMode, constraints);
        },
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    _rotationController?.dispose();
    _pointerController?.dispose();
    super.dispose();
  }

  // 清理控制器监听
  void _dispose() {
    _controller?.removeListener(_updateState);
  }

  @override
  void didChangeDependencies() {
    final _oldController = _iappPlayerController;
    _iappPlayerController = IAppPlayerController.of(context);
    _controller = _iappPlayerController!.videoPlayerController;
    _latestValue = _controller!.value;

    if (_oldController != _iappPlayerController) {
      _dispose();
      _initialize();
    }

    // 只在必要时重新计算尺寸
    final currentScreenSize = MediaQuery.of(context).size;
    if (_cachedScreenSize != currentScreenSize) {
      _precalculateResponsiveSizes(context);
    }

    super.didChangeDependencies();
  }

  // 构建主控件布局
  Widget _buildMainWidget(bool isExpandedMode, BoxConstraints constraints) {
    if (_latestValue?.hasError == true) {
      return Container(
        color: Colors.black,
        child: _buildErrorWidget(),
      );
    }

    // 获取封面图片用于背景
    final imageUrl = _getImageUrl();
    
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 模糊背景层（仅在扩展模式且有图片时显示）
          if (isExpandedMode && imageUrl != null)
            Positioned.fill(
              child: _buildBlurredBackground(imageUrl),
            ),
          // 主内容层
          isExpandedMode 
            ? _buildExpandedLayout() 
            : _buildCompactLayout(constraints),
        ],
      ),
    );
  }

  // 构建模糊背景
  Widget _buildBlurredBackground(String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图片
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
          )
        else
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
          ),
        // 模糊效果
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // 渐变遮罩
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 获取图片URL
  String? _getImageUrl() {
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    if (placeholder != null) return null; // placeholder是Widget，不是URL
    
    return _iappPlayerController?.iappPlayerDataSource?.notificationConfiguration?.imageUrl;
  }

  // 构建紧凑布局（仿HTML播放器）
  Widget _buildCompactLayout(BoxConstraints constraints) {
    final imageUrl = _getImageUrl();
    
    return Container(
      constraints: BoxConstraints(
        minHeight: kCompactModeMinHeight,
        maxHeight: kCompactModeMaxHeight,
      ),
      child: Stack(
        children: [
          // 背景模糊层
          if (imageUrl != null)
            Positioned.fill(
              child: ClipRRect(
                child: _buildCompactBlurredBackground(imageUrl),
              ),
            ),
          // 主内容层
          Container(
            decoration: BoxDecoration(
              color: imageUrl != null 
                ? Colors.black.withOpacity(0.7) 
                : Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 主内容区域
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingDouble),
                    child: Row(
                      children: [
                        // 左侧唱片区域
                        _buildCompactDisc(),
                        _spacingDoubleWidthBox,
                        // 右侧控件区域
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 歌曲信息
                              _buildCompactSongInfo(),
                              const SizedBox(height: kSpacingUnit),
                              // 控制按钮
                              _buildCompactControls(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 进度条区域
                _buildProgressSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 添加紧凑模式的背景模糊方法
  Widget _buildCompactBlurredBackground(String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图片
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
          )
        else
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
          ),
        // 模糊效果（降低模糊程度以提升性能）
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  // 构建紧凑模式的唱片
  Widget _buildCompactDisc() {
    final imageUrl = _getImageUrl();
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // 唱片容器
        Container(
          width: kCompactDiscSize,
          height: kCompactDiscSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: kDiscBorderWidth),
            boxShadow: _progressBarShadows,
          ),
          child: AnimatedBuilder(
            animation: _rotationAnimation!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation!.value * 2 * 3.14159,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                    Colors.grey[700]!,
                    Colors.grey[800]!,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: kCompactDiscSize * 0.6,
                  height: kCompactDiscSize * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: ClipOval(
                    child: _buildDiscCover(placeholder, imageUrl, kCompactDiscSize * 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 指针
        Positioned(
          right: -kPointerArmOffset,
          top: kPointerArmOffset,
          child: AnimatedBuilder(
            animation: _pointerAnimation!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _pointerAnimation!.value * 3.14159 / 180,
                alignment: const Alignment(0.5, -0.5), // 旋转锚点在顶部中心稍微偏上
                child: CustomPaint(
                  size: const Size(kPointerBaseSize, kPointerArmLength),
                  painter: TonearmPainter(
                    color: Colors.grey[700]!,
                    shadows: _iconShadows,
                    baseSize: kPointerBaseSize,
                    needleWidth: kPointerNeedleWidth,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 构建唱片封面
  Widget _buildDiscCover(Widget? placeholder, String? imageUrl, double size) {
    if (placeholder != null) {
      return placeholder;
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.music_note,
            size: size * 0.5,
            color: _controlsConfiguration.iconsColor,
          ),
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.music_note,
            size: size * 0.5,
            color: _controlsConfiguration.iconsColor,
          ),
        );
      }
    }
    return Icon(
      Icons.music_note,
      size: size * 0.5,
      color: _controlsConfiguration.iconsColor,
    );
  }

  // 构建紧凑模式的歌曲信息
  Widget _buildCompactSongInfo() {
    final title = _getCurrentTitle();
    final singer = _getCurrentSinger();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _responsiveTextSize + 1,
            color: _controlsConfiguration.textColor,
            fontWeight: FontWeight.w500,
            shadows: _textShadows,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (singer != null)
          Text(
            singer,
            style: TextStyle(
              fontSize: _responsiveTextSize - 1,
              color: _controlsConfiguration.textColor.withOpacity(0.7),
              shadows: _textShadows,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  // 获取当前歌手信息
  String? _getCurrentSinger() {
    if (_iappPlayerController?.isPlaylistMode == true) {
      final playlistController = _iappPlayerController!.playlistController;
      final currentIndex = playlistController?.currentDataSourceIndex ?? 0;
      if (playlistController != null && 
          currentIndex < (playlistController.dataSourceList.length)) {
        final dataSource = playlistController.dataSourceList[currentIndex];
        return dataSource.notificationConfiguration?.author;
      }
    }
    
    return _iappPlayerController?.iappPlayerDataSource?.notificationConfiguration?.author;
  }

  // 构建紧凑模式的控制按钮
  Widget _buildCompactControls() {
    final bool isPlaylist = _iappPlayerController!.isPlaylistMode;
    final bool isLive = _iappPlayerController?.isLiveStream() ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPlaylist) ...[
          _buildShuffleButton(),
          if (_controlsConfiguration.enableMute) _buildMuteButton(),
          const SizedBox(width: kSpacingUnit),
          _buildPreviousButton(),
          _buildPlayPauseButton(),
          _buildNextButton(),
          const SizedBox(width: kSpacingUnit),
          _buildPlaylistMenuButton(),
        ] else ...[
          if (_controlsConfiguration.enableMute) _buildMuteButton(),
          const SizedBox(width: kSpacingUnit),
          if (!isLive) _buildSkipBackButton(),
          _buildPlayPauseButton(),
          if (!isLive) _buildSkipForwardButton(),
        ],
      ],
    );
  }

  // 构建扩展布局
  Widget _buildExpandedLayout() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: _buildCoverSection(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProgressSection(),
                _buildControlsSection(),
              ],
            ),
          ],
        ),
        Positioned(
          top: kSpacingDouble,
          left: 0,
          right: 0,
          child: _buildTitleSection(),
        ),
        // 字幕显示在距离进度条的 kSpacingHalf 上面
        if (_controlsConfiguration.enableSubtitles)
          Positioned(
            bottom: kAudioControlBarHeight + kProgressBarHeight + kSpacingHalf,
            left: kSpacingDouble,
            right: kSpacingDouble,
            child: IAppPlayerSubtitlesDrawer(
              iappPlayerController: _iappPlayerController!,
              iappPlayerSubtitlesConfiguration: _iappPlayerController!.iappPlayerConfiguration.subtitlesConfiguration,
              subtitles: _iappPlayerController!.subtitlesLines,
            ),
          ),
      ],
    );
  }

  // 构建封面区域（增强版）
  Widget _buildCoverSection() {
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    final imageUrl = _iappPlayerController?.iappPlayerDataSource?.notificationConfiguration?.imageUrl;
    
    Widget? coverWidget;
    
    // 优先使用 placeholder，其次使用 imageUrl
    if (placeholder != null) {
      coverWidget = placeholder;
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      // 根据 URL 类型创建图片组件
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        coverWidget = Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.music_note,
            size: _responsiveCoverSize * kDefaultMusicIconRatio,
            color: _controlsConfiguration.iconsColor,
            shadows: _iconShadows,
          ),
        );
      } else {
        coverWidget = Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.music_note,
            size: _responsiveCoverSize * kDefaultMusicIconRatio,
            color: _controlsConfiguration.iconsColor,
            shadows: _iconShadows,
          ),
        );
      }
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (coverWidget != null) 
          Container(
            width: _responsiveCoverSize,
            height: _responsiveCoverSize,
            decoration: BoxDecoration(
              borderRadius: _coverBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _rotationAnimation!,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation!.value * 2 * 3.14159,
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: _coverBorderRadius,
                child: Stack(
                  children: [
                    coverWidget,
                    // 添加光泽效果
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: _coverBorderRadius,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          AnimatedBuilder(
            animation: _rotationAnimation!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation!.value * 2 * 3.14159,
                child: child,
              );
            },
            child: Icon(
              Icons.music_note,
              size: _responsiveCoverSize * kDefaultMusicIconRatio,
              color: _controlsConfiguration.iconsColor,
              shadows: _iconShadows,
            ),
          ),
      ],
    );
  }

  // 构建标题区域
  Widget _buildTitleSection() {
    final title = _getCurrentTitle();
    
    return Container(
      padding: _titlePadding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: _responsiveTitleFontSize,
          color: _controlsConfiguration.textColor,
          fontWeight: FontWeight.w500,
          shadows: _textShadows,
        ),
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // 获取当前标题
  String _getCurrentTitle() {
    if (_iappPlayerController?.isPlaylistMode == true) {
      final playlistController = _iappPlayerController!.playlistController;
      final currentIndex = playlistController?.currentDataSourceIndex ?? 0;
      if (playlistController != null && 
          currentIndex < (playlistController.dataSourceList.length)) {
        final dataSource = playlistController.dataSourceList[currentIndex];
        return dataSource.notificationConfiguration?.title ?? 
          _iappPlayerController!.translations.trackItem.replaceAll('{index}', '${currentIndex + 1}');
      }
    }
    
    return _iappPlayerController?.iappPlayerDataSource?.notificationConfiguration?.title ?? 
      _iappPlayerController!.translations.trackItem.replaceAll('{index}', '1');
  }

  // 构建错误提示界面
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
          _spacingDoubleBox,
          Text(_iappPlayerController!.translations.generalDefaultError, style: textStyle),
          if (_controlsConfiguration.enableRetry) _spacingDoubleBox,
          if (_controlsConfiguration.enableRetry)
            TextButton(
              onPressed: () => _iappPlayerController!.retryDataSource(),
              child: Text(_iappPlayerController!.translations.generalRetry, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // 为图标添加阴影效果
  Widget _wrapIconWithStroke(Widget icon) {
    if (icon is Icon) {
      return Icon(
        icon.icon,
        color: icon.color,
        size: icon.size,
        shadows: _iconShadows,
      );
    }
    return icon;
  }

  // 构建进度条区域
  Widget _buildProgressSection() {
    final bool isLive = _iappPlayerController?.isLiveStream() ?? false;

    return Container(
      padding: isLive ? _progressPaddingLive : _progressPadding,
      child: Row(
        children: [
          if (_controlsConfiguration.enableProgressText && !isLive) ...[
            Text(
              IAppPlayerUtils.formatDuration(_latestValue?.position ?? Duration.zero),
              style: TextStyle(
                fontSize: _responsiveTextSize - kTimeTextSizeDecrease,
                color: _controlsConfiguration.textColor,
                shadows: _textShadows,
              ),
            ),
            _timeSpacingBox,
          ],
          if (_controlsConfiguration.enableProgressBar)
            Expanded(
              child: Container(
                height: kProgressBarHeight,
                decoration: const BoxDecoration(boxShadow: _progressBarShadows),
                child: _buildProgressBar(),
              ),
            )
          else if (_controlsConfiguration.enableProgressText && !isLive)
            const Expanded(child: SizedBox()),
          if (_controlsConfiguration.enableProgressText && !isLive) ...[
            _timeSpacingBox,
            Text(
              IAppPlayerUtils.formatDuration(_latestValue?.duration ?? Duration.zero),
              style: TextStyle(
                fontSize: _responsiveTextSize - kTimeTextSizeDecrease,
                color: _controlsConfiguration.textColor,
                shadows: _textShadows,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 构建控制按钮区域
  Widget _buildControlsSection() {
    final bool isPlaylist = _iappPlayerController!.isPlaylistMode;
    final bool isLive = _iappPlayerController?.isLiveStream() ?? false;

    return Container(
      height: kAudioControlBarHeight,
      margin: const EdgeInsets.only(bottom: kSpacingHalf),
      padding: _controlsPadding,
      child: Row(
        children: [
          if (isPlaylist) ...[
            _buildShuffleButton(),
            if (_controlsConfiguration.enableMute) _buildMuteButton(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPreviousButton(),
                  _buildPlayPauseButton(),
                  _buildNextButton(),
                ],
              ),
            ),
            if (_controlsConfiguration.enableMute) _buildPlaceholder(),
            _buildPlaylistMenuButton(),
          ] else ...[
            if (_controlsConfiguration.enableMute) _buildMuteButton(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLive) _buildSkipBackButton(),
                  _buildPlayPauseButton(),
                  if (!isLive) _buildSkipForwardButton(),
                ],
              ),
            ),
            if (_controlsConfiguration.enableMute) _buildPlaceholder(),
          ],
        ],
      ),
    );
  }

  // 构建图标按钮
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    double? iconSize,
    Color? color,
    bool enabled = true,
  }) {
    final effectiveColor = enabled 
      ? (color ?? _controlsConfiguration.iconsColor)
      : (color ?? _controlsConfiguration.iconsColor).withOpacity(kDisabledButtonOpacity);
    
    return IAppPlayerClickableWidget(
      onTap: (enabled && onTap != null) ? onTap : () {},
      child: Container(
        padding: _iconButtonPadding,
        child: _wrapIconWithStroke(
          Icon(
            icon,
            color: effectiveColor,
            size: iconSize ?? _responsiveIconSize,
          ),
        ),
      ),
    );
  }

  // 构建静音按钮
  Widget _buildMuteButton() {
    return _buildIconButton(
      icon: (_latestValue?.volume ?? kMutedVolume) > kMutedVolume 
        ? _controlsConfiguration.muteIcon 
        : _controlsConfiguration.unMuteIcon,
      onTap: () {
        if (_latestValue == null || _controller == null) return;
        if (_latestValue!.volume == kMutedVolume) {
          _iappPlayerController!.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = _controller!.value.volume;
          _iappPlayerController!.setVolume(kMutedVolume);
        }
      },
    );
  }

  // 构建随机/顺序播放按钮
  Widget _buildShuffleButton() {
    return _buildIconButton(
      icon: _iappPlayerController!.playlistShuffleMode ? Icons.shuffle : Icons.repeat,
      onTap: () {
        _iappPlayerController!.togglePlaylistShuffle();
        setState(() {});
      },
    );
  }

  // 构建上一曲按钮
  Widget _buildPreviousButton() {
    final bool hasPrevious = _iappPlayerController!.playlistController?.hasPrevious ?? false;
    
    return _buildIconButton(
      icon: Icons.skip_previous,
      onTap: hasPrevious ? _playPrevious : null,
      enabled: hasPrevious,
    );
  }

  // 构建下一曲按钮
  Widget _buildNextButton() {
    final bool hasNext = _iappPlayerController!.playlistController?.hasNext ?? false;
    
    return _buildIconButton(
      icon: Icons.skip_next,
      onTap: hasNext ? _playNext : null,
      enabled: hasNext,
    );
  }

  // 构建播放/暂停按钮
  Widget _buildPlayPauseButton() {
    final bool isFinished = isVideoFinished(_latestValue);
    final bool isPlaying = _controller?.value.isPlaying ?? false;

    IconData iconData;
    if (isFinished) {
      iconData = Icons.replay_circle_filled;
    } else if (isPlaying) {
      iconData = Icons.pause_circle_filled;
    } else {
      iconData = Icons.play_circle_filled;
    }

    return IAppPlayerClickableWidget(
      key: const Key("iapp_player_audio_controls_play_pause_button"),
      onTap: _onPlayPause,
      child: Container(
        padding: _iconButtonPadding,
        child: _wrapIconWithStroke(
          Icon(
            iconData,
            color: _controlsConfiguration.iconsColor,
            size: _responsivePlayPauseIconSize,
          ),
        ),
      ),
    );
  }

  // 构建快退按钮
  Widget _buildSkipBackButton() {
    return _buildIconButton(
      icon: Icons.fast_rewind,
      onTap: skipBack,
    );
  }

  // 构建快进按钮
  Widget _buildSkipForwardButton() {
    return _buildIconButton(
      icon: Icons.fast_forward,
      onTap: skipForward,
    );
  }

  // 构建播放列表菜单按钮
  Widget _buildPlaylistMenuButton() {
    return _buildIconButton(
      icon: Icons.queue_music,
      onTap: _showPlaylistMenu,
    );
  }

  // 构建占位符
  Widget _buildPlaceholder() {
    return Container(
      padding: _iconButtonPadding,
      child: SizedBox(width: _responsiveIconSize, height: _responsiveIconSize),
    );
  }

  // 显示播放列表菜单
  void _showPlaylistMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPlaylistModal(),
    );
  }

  // 构建播放列表模态框
  Widget _buildPlaylistModal() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: kSpacingDouble),
        decoration: BoxDecoration(
          color: _controlsConfiguration.overflowModalColor.withOpacity(kModalBackgroundOpacity),
          borderRadius: _modalTopBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _modalTopBorderRadius,
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
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            translations.playlistUnavailable,
            style: TextStyle(
              color: _controlsConfiguration.overflowModalTextColor,
              fontSize: kModalItemFontSize,
            ),
          ),
        ),
      );
    }

    final dataSourceList = playlistController.dataSourceList;
    final currentIndex = playlistController.currentDataSourceIndex;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * kPlaylistMaxHeightRatio,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: kModalHeaderHeight,
            padding: _modalHeaderPadding,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _controlsConfiguration.overflowModalTextColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  translations.playlistTitle,
                  style: TextStyle(
                    color: _controlsConfiguration.overflowModalTextColor,
                    fontSize: kModalTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: const EdgeInsets.all(kSpacingUnit),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close,
                    color: _controlsConfiguration.overflowModalTextColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: _modalListPadding,
              itemCount: dataSourceList.length,
              itemBuilder: (context, index) {
                final dataSource = dataSourceList[index];
                final isCurrentItem = index == currentIndex;
                final title = dataSource.notificationConfiguration?.title ?? 
                  translations.trackItem.replaceAll('{index}', '${index + 1}');

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
  Widget _buildPlaylistItem({
    required String title,
    required bool isCurrentItem,
    required VoidCallback onTap,
  }) {
    return IAppPlayerClickableWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: kModalItemHeight,
        margin: _modalItemMargin,
        decoration: BoxDecoration(
          color: isCurrentItem 
            ? _controlsConfiguration.overflowModalTextColor.withOpacity(kModalItemHoverOpacity)
            : Colors.transparent,
          borderRadius: _itemBorderRadius,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              alignment: Alignment.center,
              child: isCurrentItem
                ? Icon(
                    Icons.play_arrow_rounded,
                    color: _controlsConfiguration.overflowModalTextColor,
                    size: kPlayIndicatorIconSize,
                  )
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
            _spacingDoubleWidthBox,
          ],
        ),
      ),
    );
  }

  // 播放上一曲
  void _playPrevious() {
    final playlistController = _iappPlayerController!.playlistController;
    if (playlistController != null) playlistController.playPrevious();
  }

  // 播放下一曲
  void _playNext() {
    final playlistController = _iappPlayerController!.playlistController;
    if (playlistController != null) playlistController.playNext();
  }

  // 播放指定索引曲目
  void _playAtIndex(int index) {
    final playlistController = _iappPlayerController!.playlistController;
    if (playlistController != null) {
      playlistController.setupDataSource(index);
    }
  }

  // 播放/暂停切换
  void _onPlayPause() {
    final bool isFinished = _latestValue?.position != null && 
      _latestValue?.duration != null && 
      _latestValue!.position >= _latestValue!.duration!;

    if (_controller!.value.isPlaying) {
      _iappPlayerController!.pause();
      _stopAnimations();
    } else if (_controller!.value.initialized) {
      if (isFinished) _iappPlayerController!.seekTo(const Duration());
      _iappPlayerController!.play();
      _iappPlayerController!.cancelNextVideoTimer();
      _startAnimations();
    }
  }

  // 开始动画
  void _startAnimations() {
    _rotationController?.repeat();
    _pointerController?.forward();
  }

  // 停止动画
  void _stopAnimations() {
    _rotationController?.stop();
    _pointerController?.reverse();
  }

  // 初始化控制器
  Future<void> _initialize() async {
    _controller!.addListener(_updateState);
    _updateState();
    
    // 根据初始播放状态设置动画
    if (_controller!.value.isPlaying) {
      _startAnimations();
    }
  }

  // 更新播放状态
  void _updateState() {
    if (!mounted) return;
    
    final newValue = _controller!.value;
    
    // 进度条更新
    final needsUpdate = _latestValue == null ||
        _latestValue!.isPlaying != newValue.isPlaying ||
        _latestValue!.position != newValue.position ||
        _latestValue!.duration != newValue.duration ||
        _latestValue!.hasError != newValue.hasError ||
        _latestValue!.volume != newValue.volume;
    
    if (needsUpdate) {
      setState(() {
        _latestValue = newValue;
      });
      
      // 根据播放状态控制动画
      if (newValue.isPlaying && !(_rotationController?.isAnimating ?? false)) {
        _startAnimations();
      } else if (!newValue.isPlaying && (_rotationController?.isAnimating ?? false)) {
        _stopAnimations();
      }
    }
  }

  // 构建进度条
  Widget _buildProgressBar() {
    return IAppPlayerProgressBar(
      _controller,
      _iappPlayerController,
      onDragStart: () {},
      onDragEnd: () {},
      onTapDown: () {},
      colors: IAppPlayerProgressColors(
        playedColor: _controlsConfiguration.progressBarPlayedColor,
        handleColor: _controlsConfiguration.progressBarHandleColor,
        bufferedColor: _controlsConfiguration.progressBarBufferedColor,
        backgroundColor: _controlsConfiguration.progressBarBackgroundColor,
      ),
    );
  }

  @override
  void cancelAndRestartTimer() {
    // 音频控件保持始终可见
  }
}

// 自定义唱臂绘制器
class TonearmPainter extends CustomPainter {
  final Color color;
  final List<Shadow> shadows;
  final double baseSize;
  final double needleWidth;
  
  TonearmPainter({
    this.color = Colors.grey,
    this.shadows = const [],
    this.baseSize = 16.0,
    this.needleWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // 绘制阴影
    for (final shadow in shadows) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
      
      // 绘制基座阴影
      canvas.drawCircle(
        Offset(size.width / 2 + shadow.offset.dx, baseSize / 2 + shadow.offset.dy),
        baseSize / 2,
        shadowPaint,
      );
      
      // 绘制唱臂主体阴影
      final shadowPath = Path()
        ..moveTo(size.width / 2 - needleWidth / 2 + shadow.offset.dx, baseSize + shadow.offset.dy)
        ..lineTo(size.width / 2 - needleWidth / 2 + shadow.offset.dx, size.height - 10 + shadow.offset.dy)
        ..quadraticBezierTo(
          size.width / 2 + shadow.offset.dx, 
          size.height - 5 + shadow.offset.dy,
          size.width / 2 + needleWidth / 2 + shadow.offset.dx, 
          size.height - 10 + shadow.offset.dy,
        )
        ..lineTo(size.width / 2 + needleWidth / 2 + shadow.offset.dx, baseSize + shadow.offset.dy)
        ..close();
      
      canvas.drawPath(shadowPath, shadowPaint);
    }
    
    // 绘制基座（圆形）
    canvas.drawCircle(
      Offset(size.width / 2, baseSize / 2),
      baseSize / 2,
      paint,
    );
    
    // 添加基座高光
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2 - 2, baseSize / 2 - 2),
      baseSize / 4,
      highlightPaint,
    );
    
    // 绘制唱臂主体
    final armPath = Path()
      ..moveTo(size.width / 2 - needleWidth / 2, baseSize)
      ..lineTo(size.width / 2 - needleWidth / 2, size.height - 10)
      ..quadraticBezierTo(
        size.width / 2, 
        size.height - 5,
        size.width / 2 + needleWidth / 2, 
        size.height - 10,
      )
      ..lineTo(size.width / 2 + needleWidth / 2, baseSize)
      ..close();
    
    canvas.drawPath(armPath, paint);
    
    // 绘制唱臂细节线条
    final detailPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawLine(
      Offset(size.width / 2, baseSize),
      Offset(size.width / 2, size.height - 8),
      detailPaint,
    );
    
    // 绘制唱针头
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 5),
      3,
      paint..color = Colors.white,
    );
    
    // 唱针头高光
    canvas.drawCircle(
      Offset(size.width / 2 - 0.5, size.height - 5.5),
      1,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TonearmPainter oldDelegate) => 
    oldDelegate.color != color || 
    oldDelegate.shadows != shadows ||
    oldDelegate.baseSize != baseSize ||
    oldDelegate.needleWidth != needleWidth;
}
