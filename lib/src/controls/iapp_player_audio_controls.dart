import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:iapp_player/src/configuration/iapp_player_controls_configuration.dart';
import 'package:iapp_player/src/controls/iapp_player_clickable_widget.dart';
import 'package:iapp_player/src/controls/iapp_player_controls_state.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_bar.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_colors.dart';
import 'package:iapp_player/src/core/iapp_player_controller.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitles_drawer.dart';
import 'package:flutter/material.dart';

// 播放器显示模式
enum PlayerDisplayMode {
  expanded,   // 扩展模式：高度 ≥ 200px 且非正方形
  square,     // 正方形模式：宽高比接近 1:1
  compact,    // 紧凑模式：高度 < 200px 且非正方形
}

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
  static const double kIconSizeBase = 24.0;
  // 播放/暂停图标尺寸
  static const double kPlayPauseIconSize = 32.0;
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
  static const double kDiscBorderWidth = 2.0;

  // 唱片相关常量 - 修改以减少纹理，增大封面
  static const double kDiscGrooveWidth = 4.0; // 线条宽度
  static const double kDiscGrooveSpacing = 10.0; // 修改：增加间距
  static const double kDiscCenterRatio = 0.25; // 中心标签比例
  static const double kDiscInnerCircleRatio = 0.75; // 修改：增大内圈封面比例

  // 扩展模式唱片尺寸
  static const double kExpandedDiscSize = 150.0; // 修改：调整为 150.0（原280.0）

  // 动画相关常量
  static const Duration kRotationDuration = Duration(seconds: 5); // 旋转周期
  static const double kFullRotation = 2 * math.pi; // 完整旋转角度

  // 紧凑模式新样式常量
  static const Color kCompactBackgroundColor = Colors.black; // 背景色
  static const double kCompactControlsMinWidth = 120.0; // 控制区域最小宽度
  static const double kGradientWidth = 60.0; // 渐变宽度
  static const double kCompactSongInfoSpacing = 4.0; // 歌曲信息间距
  static const double kCompactSectionSpacing = 12.0; // 各区域间距
  static const double kCompactProgressHeight = 6.0; // 进度条高度（增加高度）
  static const double kCompactTopBarHeight = 24.0; // 顶部栏高度
  static const double kCompactPlayButtonSize = 30.0; // 播放按钮尺寸
  static const double kCompactControlButtonSize = 28.0; // 控制按钮尺寸
  static const double kCompactSmallIconSize = 20.0; // 小图标尺寸
  static const double kCompactPlayPauseIconSize = 26.0; // 修改：紧凑模式播放按钮图标大小从27改为22

  // 正方形模式相关常量
  static const double kSquareModePlayButtonSize = 60.0; // 正方形模式播放按钮尺寸
  static const double kSquareModeButtonOpacity = 0.3; // 正方形模式按钮透明度（更低的透明度，黑色更明显）

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

  // 唱片旋转动画控制器（扩展模式需要）
  AnimationController? _rotationController;
  // 唱片旋转动画（扩展模式需要）
  Animation<double>? _rotationAnimation;

  // 随机渐变色生成器（扩展模式需要）
  final _random = math.Random();
  List<Color>? _gradientColors;

  // 当前显示模式
  PlayerDisplayMode _currentDisplayMode = PlayerDisplayMode.compact;
  // 动画是否已初始化
  bool _animationsInitialized = false;

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
    // 不在这里初始化动画，等待布局确定后再初始化
  }

  // 生成随机渐变色（扩展模式需要）
  void _generateRandomGradient() {
    if (_gradientColors != null) return; // 避免重复生成
    
    final hue1 = _random.nextDouble() * 360;
    final hue2 = (hue1 + 30 + _random.nextDouble() * 60) % 360; // 相近色相
    
    _gradientColors = [
      HSVColor.fromAHSV(1.0, hue1, 0.6, 0.3).toColor(),
      HSVColor.fromAHSV(1.0, hue2, 0.5, 0.4).toColor(),
    ];
  }

  // 初始化动画（仅扩展模式需要）
  void _initializeAnimations() {
    if (_animationsInitialized) return; // 避免重复初始化
    
    _animationsInitialized = true;
    
    // 唱片旋转动画
    _rotationController = AnimationController(
      duration: kRotationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController!,
      curve: Curves.linear,
    ));
  }

  // 计算当前显示模式
  PlayerDisplayMode _calculateDisplayMode(BoxConstraints constraints) {
    // 计算宽高比
    final double aspectRatio = constraints.maxWidth / constraints.maxHeight;
    final bool isSquareRatio = (aspectRatio - 1.0).abs() < 0.1; // 允许10%的误差
    
    // 正方形模式：宽高比接近1:1
    if (isSquareRatio) {
      return PlayerDisplayMode.square;
    }
    
    // 紧凑模式：高度 < 200px 且非正方形
    if (constraints.maxHeight != double.infinity && 
        constraints.maxHeight < kExpandedModeThreshold) {
      return PlayerDisplayMode.compact;
    }
    
    // 扩展模式：高度 ≥ 200px 且非正方形
    return PlayerDisplayMode.expanded;
  }

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(
      LayoutBuilder(
        builder: (context, constraints) {
          // 计算当前显示模式
          final displayMode = _calculateDisplayMode(constraints);
          
          // 如果显示模式发生变化
          if (_currentDisplayMode != displayMode) {
            _currentDisplayMode = displayMode;
            
            // 只在扩展模式下初始化动画
            if (_currentDisplayMode == PlayerDisplayMode.expanded && !_animationsInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializeAnimations();
                  _generateRandomGradient();
                  // 如果正在播放，开始动画
                  if (_controller?.value.isPlaying ?? false) {
                    _startAnimations();
                  }
                }
              });
            }
          }
          
          return _buildMainWidget(constraints);
        },
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    _rotationController?.dispose();
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
  Widget _buildMainWidget(BoxConstraints constraints) {
    if (_latestValue?.hasError == true) {
      return Container(
        color: Colors.black,
        child: _buildErrorWidget(),
      );
    }
    
    // 根据显示模式选择不同的布局
    switch (_currentDisplayMode) {
      case PlayerDisplayMode.expanded:
        return _buildExpandedMode();
      case PlayerDisplayMode.square:
        return _buildSquareMode();
      case PlayerDisplayMode.compact:
        return _buildCompactMode(constraints);
    }
  }

  // ============== 扩展模式 ==============
  // 扩展模式：显示唱片动画 + 完整控制栏
  Widget _buildExpandedMode() {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 渐变背景
          if (_gradientColors != null)
            Positioned.fill(
              child: _buildGradientBackground(),
            ),
          // 主内容
          _buildExpandedLayout(),
        ],
      ),
    );
  }

  // 构建渐变背景
  Widget _buildGradientBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 渐变背景
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradientColors!,
            ),
          ),
        ),
        // 玻璃效果
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
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
              child: _buildDiscSection(),
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

  // 构建唱片区域
  Widget _buildDiscSection() {
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    final imageUrl = _getImageUrl();
    final title = _getCurrentTitle();
    final singer = _getCurrentSinger();
    
    return Center(
      child: Container(
        width: kExpandedDiscSize,
        height: kExpandedDiscSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rotationAnimation ?? const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            return Transform.rotate(
              angle: (_rotationAnimation?.value ?? 0.0) * kFullRotation,
              child: ClipOval(
                child: Stack(
                  children: [
                    // 唱片纹理
                    CustomPaint(
                      size: const Size(kExpandedDiscSize, kExpandedDiscSize),
                      painter: _DiscPainter(isCompact: false),
                    ),
                    // 中心封面
                    Center(
                      child: Container(
                        width: kExpandedDiscSize * kDiscInnerCircleRatio,
                        height: kExpandedDiscSize * kDiscInnerCircleRatio,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: ClipOval(
                          child: _buildCoverImage(placeholder, imageUrl),
                        ),
                      ),
                    ),
                    // 中心白色标签
                    Center(
                      child: Container(
                        width: kExpandedDiscSize * kDiscCenterRatio,
                        height: kExpandedDiscSize * kDiscCenterRatio,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (singer != null)
                              Text(
                                singer,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                    // 中心孔
                    Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============== 正方形模式 ==============
  // 正方形模式：封面铺满 + 居中播放按钮
  Widget _buildSquareMode() {
    final imageUrl = _getImageUrl();
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    
    // 简化设计：直接使用Stack填充
    return Stack(
      fit: StackFit.expand,
      children: [
        // 黑色背景（作为图片加载失败的后备）
        Container(color: Colors.black),
        // 封面图片 - 使用Container包装确保填充
        if (placeholder != null)
          placeholder
        else if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageUrl.startsWith('http://') || imageUrl.startsWith('https://')
                    ? NetworkImage(imageUrl) as ImageProvider
                    : AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            color: Colors.grey[900],
            child: Icon(
              Icons.music_note,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
        // 半透明遮罩
        Container(
          color: Colors.black.withOpacity(0.4),
        ),
        // 居中的播放/暂停按钮
        Center(
          child: _buildSquareModePlayButton(),
        ),
      ],
    );
  }

  // 构建正方形模式的播放按钮
  Widget _buildSquareModePlayButton() {
    final bool isFinished = isVideoFinished(_latestValue);
    final bool isPlaying = _controller?.value.isPlaying ?? false;

    IconData iconData;
    if (isFinished) {
      iconData = Icons.replay;
    } else if (isPlaying) {
      iconData = Icons.pause;
    } else {
      iconData = Icons.play_arrow;
    }

    return IAppPlayerClickableWidget(
      key: const Key("iapp_player_audio_square_play_pause_button"),
      onTap: _onPlayPause,
      child: Container(
        width: kSquareModePlayButtonSize,
        height: kSquareModePlayButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // 纯黑色半透明背景，无边框
          color: Colors.black.withOpacity(kSquareModeButtonOpacity),
          // 强化阴影效果，增加层次感
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  // ============== 紧凑模式 ==============
  // 紧凑模式：横向布局
  Widget _buildCompactMode(BoxConstraints constraints) {
    final bool isPlaylist = _iappPlayerController!.isPlaylistMode;
    final imageUrl = _getImageUrl();
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    
    // 修改：使用实际高度计算
    final double playerHeight = constraints.maxHeight.isFinite 
      ? math.min(constraints.maxHeight, kCompactModeMaxHeight)
      : kCompactModeMinHeight;
    // 修改：左侧封面为正方形
    final double coverSize = playerHeight;
    
    return Container(
      height: playerHeight,
      decoration: BoxDecoration(
        color: kCompactBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧封面区域 - 正方形
          _buildCompactCoverSection(placeholder, imageUrl, coverSize, showGradient: true),
          // 右侧控制区域
          Expanded(
            child: Container(
              color: kCompactBackgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingDouble,
                vertical: kSpacingUnit,
              ),
              child: _buildCompactControlsArea(isPlaylist),
            ),
          ),
        ],
      ),
    );
  }

  // 构建紧凑模式左侧封面区域
  Widget _buildCompactCoverSection(Widget? placeholder, String? imageUrl, double size, {bool showGradient = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 修改：使用 ClipRect 确保图片不会溢出
          ClipRect(
            child: _buildCoverImage(placeholder, imageUrl, fit: BoxFit.cover),
          ),
          // 右侧渐变遮罩（仅在需要时显示）
          if (showGradient)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: kGradientWidth,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      kCompactBackgroundColor.withOpacity(0.7),
                      kCompactBackgroundColor,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建紧凑模式右侧控制区域
  Widget _buildCompactControlsArea(bool isPlaylist) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 顶部栏（居右）
        _buildCompactTopBar(isPlaylist),
        // 歌曲信息（水平居中）
        Expanded(
          child: Center(
            child: _buildCompactSongInfoArea(),
          ),
        ),
        // 底部控制区
        Column(
          children: [
            // 进度条和时间
            _buildCompactProgressSection(),
            SizedBox(height: kCompactSectionSpacing),
            // 播放控制按钮（水平居中）
            Center(
              child: _buildCompactPlaybackControls(isPlaylist),
            ),
          ],
        ),
      ],
    );
  }

  // 构建紧凑模式顶部栏
  Widget _buildCompactTopBar(bool isPlaylist) {
    final bool isLive = _iappPlayerController?.isLiveStream() ?? false;
    final duration = _latestValue?.duration ?? Duration.zero;
    final position = _latestValue?.position ?? Duration.zero;
    final remaining = duration - position;
    
    return SizedBox(
      height: kCompactTopBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧显示剩余时间
          if (_controlsConfiguration.enableProgressText && !isLive)
            Text(
              '-${IAppPlayerUtils.formatDuration(remaining)}',
              style: TextStyle(
                fontSize: 11,
                color: _controlsConfiguration.textColor.withOpacity(0.7),
              ),
            ),
          const Spacer(),
          // 右侧按钮组
          Row(
            children: [
              // 播放列表模式按钮
              if (isPlaylist) ...[
                _buildCompactIconButton(
                  icon: _iappPlayerController!.playlistShuffleMode 
                    ? Icons.shuffle 
                    : Icons.repeat,
                  onTap: () {
                    _iappPlayerController!.togglePlaylistShuffle();
                    setState(() {});
                  },
                  size: kCompactSmallIconSize,
                ),
                SizedBox(width: kSpacingUnit),
                _buildCompactIconButton(
                  icon: Icons.queue_music,
                  onTap: _showPlaylistMenu,
                  size: kCompactSmallIconSize,
                ),
                if (_controlsConfiguration.enableFullscreen)
                  SizedBox(width: kSpacingUnit),
              ],
              // 全屏按钮
              if (_controlsConfiguration.enableFullscreen)
                _buildCompactIconButton(
                  icon: _iappPlayerController!.isFullScreen
                      ? _controlsConfiguration.fullscreenDisableIcon
                      : _controlsConfiguration.fullscreenEnableIcon,
                  onTap: () {
                    if (_iappPlayerController!.isFullScreen) {
                      _iappPlayerController!.exitFullScreen();
                    } else {
                      _iappPlayerController!.enterFullScreen();
                    }
                  },
                  size: kCompactSmallIconSize,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建紧凑模式歌曲信息区域
  Widget _buildCompactSongInfoArea() {
    final title = _getCurrentTitle();
    final singer = _getCurrentSinger();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (singer != null) ...[
          Text(
            singer,
            style: TextStyle(
              fontSize: 12,
              color: _controlsConfiguration.textColor.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: kCompactSongInfoSpacing),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: _controlsConfiguration.textColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 构建紧凑模式的进度条区域
  Widget _buildCompactProgressSection() {
    return Row(
      children: [
        if (_controlsConfiguration.enableProgressBar)
          Expanded(
            child: SizedBox(
              height: kCompactProgressHeight,
              child: _buildProgressBar(),
            ),
          ),
      ],
    );
  }

  // 构建紧凑模式播放控制按钮
  Widget _buildCompactPlaybackControls(bool isPlaylist) {
    final bool isLive = _iappPlayerController?.isLiveStream() ?? false;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPlaylist) ...[
          _buildCompactIconButton(
            icon: Icons.skip_previous,
            onTap: (_iappPlayerController!.playlistController?.hasPrevious ?? false) 
              ? _playPrevious 
              : null,
            enabled: _iappPlayerController!.playlistController?.hasPrevious ?? false,
            size: kCompactControlButtonSize,
          ),
          SizedBox(width: kSpacingDouble),
          _buildCompactPlayPauseButton(),
          SizedBox(width: kSpacingDouble),
          _buildCompactIconButton(
            icon: Icons.skip_next,
            onTap: (_iappPlayerController!.playlistController?.hasNext ?? false) 
              ? _playNext 
              : null,
            enabled: _iappPlayerController!.playlistController?.hasNext ?? false,
            size: kCompactControlButtonSize,
          ),
        ] else ...[
          if (!isLive) ...[
            _buildCompactIconButton(
              icon: Icons.replay_10,
              onTap: skipBack,
              size: 24,
            ),
            SizedBox(width: kSpacingDouble),
          ],
          _buildCompactPlayPauseButton(),
          if (!isLive) ...[
            SizedBox(width: kSpacingDouble),
            _buildCompactIconButton(
              icon: Icons.forward_10,
              onTap: skipForward,
              size: 24,
            ),
          ],
        ],
      ],
    );
  }

  // 构建紧凑模式的图标按钮
  Widget _buildCompactIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    double size = 24,
    bool enabled = true,
  }) {
    final effectiveColor = enabled 
      ? _controlsConfiguration.iconsColor
      : _controlsConfiguration.iconsColor.withOpacity(0.3);
      
    return IAppPlayerClickableWidget(
      onTap: (enabled && onTap != null) ? onTap : () {},
      child: Icon(
        icon,
        color: effectiveColor,
        size: size,
      ),
    );
  }

  // 构建紧凑模式的播放/暂停按钮
  Widget _buildCompactPlayPauseButton() {
    final bool isFinished = isVideoFinished(_latestValue);
    final bool isPlaying = _controller?.value.isPlaying ?? false;

    IconData iconData;
    if (isFinished) {
      iconData = Icons.replay;
    } else if (isPlaying) {
      iconData = Icons.pause;
    } else {
      iconData = Icons.play_arrow;
    }

    return IAppPlayerClickableWidget(
      key: const Key("iapp_player_audio_controls_play_pause_button"),
      onTap: _onPlayPause,
      child: Container(
        width: kCompactPlayButtonSize,
        height: kCompactPlayButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _controlsConfiguration.iconsColor,
        ),
        child: Icon(
          iconData,
          color: kCompactBackgroundColor,
          size: kCompactPlayPauseIconSize,
        ),
      ),
    );
  }

  // ============== 通用方法 ==============
  // 获取图片URL
  String? _getImageUrl() {
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    if (placeholder != null) return null; // placeholder是Widget，不是URL
    
    return _iappPlayerController?.iappPlayerDataSource?.notificationConfiguration?.imageUrl;
  }

  // 构建封面图片 - 修改：添加可选的 fit 参数
  Widget _buildCoverImage(Widget? placeholder, String? imageUrl, {BoxFit? fit}) {
    final effectiveFit = fit ?? BoxFit.cover;
    
    if (placeholder != null) {
      return placeholder;
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: effectiveFit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[900],
            child: Icon(
              Icons.music_note,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: effectiveFit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[900],
            child: Icon(
              Icons.music_note,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
        );
      }
    }
    return Container(
      color: Colors.grey[900],
      child: Icon(
        Icons.music_note,
        size: 60,
        color: Colors.grey[600],
      ),
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
      child: Stack(
        children: [
          // 左侧按钮
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                if (isPlaylist) _buildShuffleButton(),
                if (_controlsConfiguration.enableMute) _buildMuteButton(),
              ],
            ),
          ),
          // 中间播放控制按钮（始终居中）
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPlaylist) ...[
                  _buildPreviousButton(),
                  _buildPlayPauseButton(),
                  _buildNextButton(),
                ] else ...[
                  if (!isLive) _buildSkipBackButton(),
                  _buildPlayPauseButton(),
                  if (!isLive) _buildSkipForwardButton(),
                ],
              ],
            ),
          ),
          // 右侧按钮
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                if (isPlaylist) _buildPlaylistMenuButton(),
                if (_controlsConfiguration.enableFullscreen)
                  _buildFullscreenButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建全屏按钮
  Widget _buildFullscreenButton() {
    return _buildIconButton(
      icon: _iappPlayerController!.isFullScreen
          ? _controlsConfiguration.fullscreenDisableIcon
          : _controlsConfiguration.fullscreenEnableIcon,
      onTap: () {
        if (_iappPlayerController!.isFullScreen) {
          _iappPlayerController!.exitFullScreen();
        } else {
          _iappPlayerController!.enterFullScreen();
        }
      },
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

  // 开始动画（仅扩展模式需要）
  void _startAnimations() {
    if (_currentDisplayMode == PlayerDisplayMode.expanded && _animationsInitialized) {
      _rotationController?.repeat();
    }
  }

  // 停止动画
  void _stopAnimations() {
    _rotationController?.stop();
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

// 唱片纹理绘制器（扩展模式需要）
class _DiscPainter extends CustomPainter {
  final bool isCompact;
  
  _DiscPainter({required this.isCompact});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 黑色背景
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 绘制纹理圆环
    final groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCompact ? _IAppPlayerAudioControlsState.kDiscGrooveWidth : 2.0; // 修改：扩展模式线条更细
    
    // 根据模式选择不同的线条样式
    if (isCompact) {
      // 紧凑模式：白色线条，减少数量
      groovePaint.color = Colors.white.withOpacity(0.15);
      for (double r = _IAppPlayerAudioControlsState.kDiscGrooveSpacing * 2; 
           r < radius; 
           r += _IAppPlayerAudioControlsState.kDiscGrooveSpacing * 3) {
        canvas.drawCircle(center, r, groovePaint);
      }
    } else {
      // 修改：扩展模式精确绘制3条纹理线
      groovePaint.color = Colors.white.withOpacity(0.3);
      
      // 计算封面边缘位置
      final coverRadius = radius * _IAppPlayerAudioControlsState.kDiscInnerCircleRatio;
      // 可用空间
      final availableSpace = radius - coverRadius;
      // 将可用空间分为4份（3条线 + 4个间隔）
      final spacing = availableSpace / 4;
      
      // 从封面边缘开始，绘制3条纹理线
      for (int i = 1; i <= 3; i++) {
        final r = coverRadius + spacing * i;
        canvas.drawCircle(center, r, groovePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
