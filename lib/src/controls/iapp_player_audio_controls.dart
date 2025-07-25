import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iapp_player/src/configuration/iapp_player_controls_configuration.dart';
import 'package:iapp_player/src/controls/iapp_player_clickable_widget.dart';
import 'package:iapp_player/src/controls/iapp_player_controls_state.dart';
import 'package:iapp_player/src/controls/iapp_player_multiple_gesture_detector.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_bar.dart';
import 'package:iapp_player/src/controls/iapp_player_progress_colors.dart';
import 'package:iapp_player/src/core/iapp_player_controller.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitles_drawer.dart';

// 定义播放器显示模式
enum PlayerDisplayMode {
  expanded,   // 显示扩展模式：高度 ≥ 200px 且非正方形
  square,     // 显示封面模式：宽高比接近 1:1
  compact,    // 显示紧凑模式：高度 < 200px 且非正方形
}

// 构建音频播放控件
class IAppPlayerAudioControls extends StatefulWidget {
  // 通知控件可见性变化
  final Function(bool visbility) onControlsVisibilityChanged;
  // 配置控件参数
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
  // 定义基础间距单位
  static const double kSpacingUnit = 8.0;
  // 定义半间距单位
  static const double kSpacingHalf = 2.0;
  // 定义双倍间距单位
  static const double kSpacingDouble = 16.0;

  // 定义进度条高度
  static const double kProgressBarHeight = 12.0;
  // 定义音频控件条高度
  static const double kAudioControlBarHeight = 36.0;
  // 定义基础图标尺寸
  static const double kIconSizeBase = 24.0;
  // 定义播放/暂停图标尺寸
  static const double kPlayPauseIconSize = 32.0;
  // 定义基础文本尺寸
  static const double kTextSizeBase = 13.0;
  // 定义错误图标尺寸
  static const double kErrorIconSize = 42.0;

  // 定义图标阴影模糊半径
  static const double kIconShadowBlurRadius = 3.0;
  // 定义文本阴影模糊半径
  static const double kTextShadowBlurRadius = 2.0;
  // 定义阴影垂直偏移
  static const double kShadowOffsetY = 1.0;
  // 定义阴影水平偏移
  static const double kShadowOffsetX = 0.0;

  // 定义模态框圆角
  static const double kModalBorderRadius = 22.0;
  // 定义模态框头部高度
  static const double kModalHeaderHeight = 48.0;
  // 定义模态框标题字体大小
  static const double kModalTitleFontSize = 18.0;
  // 定义标准字体大小（用于标题和列表项）
  static const double kStandardFontSize = 16.0;
  // 定义小图标尺寸（用于播放指示器和紧凑模式小图标）
  static const double kSmallIconSize = 20.0;
  // 定义模态框背景透明度
  static const double kModalBackgroundOpacity = 0.95;

  // 定义播放列表主题色
  static const Color kPlaylistPrimaryColor = Color(0xFFFF0000);
  // 定义播放列表背景色
  static const Color kPlaylistBackgroundColor = Color(0xFF1A1A1A);
  // 定义播放列表表面颜色
  static const Color kPlaylistSurfaceColor = Color(0xFF2A2A2A);
  // 定义标准圆角半径（用于封面和列表项）
  static const double kStandardBorderRadius = 12.0;
  // 定义播放列表项垂直间距
  static const double kPlaylistItemVerticalMargin = 1.0;

  // 定义禁用按钮透明度
  static const double kDisabledButtonOpacity = 0.3;
  // 定义静音音量
  static const double kMutedVolume = 0.0;
  // 定义播放列表最大高度比例
  static const double kPlaylistMaxHeightRatio = 0.6;

  // 定义时间文本尺寸减量
  static const double kTimeTextSizeDecrease = 1.0;

  // 定义扩展模式高度阈值
  static const double kExpandedModeThreshold = 200.0;
  // 定义封面尺寸
  static const double kCoverSize = 100.0;
  // 定义紧凑模式最小高度
  static const double kCompactModeMinHeight = 120.0;
  // 定义紧凑模式最大高度
  static const double kCompactModeMaxHeight = 180.0;

  // 定义唱片线条宽度
  static const double kDiscGrooveWidth = 1.0;
  // 定义唱片线条间距
  static const double kDiscGrooveSpacing = 11.0;
  // 定义唱片中心标签比例
  static const double kDiscCenterRatio = 0.25;
  // 定义唱片内圈封面比例
  static const double kDiscInnerCircleRatio = 0.75;

  // 定义扩展模式唱片尺寸
  static const double kExpandedDiscSize = 150.0;

  // 定义唱片旋转动画周期
  static const Duration kRotationDuration = Duration(seconds: 5);
  // 定义完整旋转角度
  static const double kFullRotation = 2 * math.pi;

  // 定义紧凑模式背景色
  static const Color kCompactBackgroundColor = Colors.black;
  // 定义紧凑模式渐变宽度
  static const double kGradientWidth = 60.0;
  // 定义紧凑模式歌曲信息间距
  static const double kCompactSongInfoSpacing = 4.0;
  // 定义紧凑模式区域间距
  static const double kCompactSectionSpacing = 6.0;
  // 定义紧凑模式进度条高度
  static const double kCompactProgressHeight = 6.0;
  // 定义紧凑模式顶部栏高度
  static const double kCompactTopBarHeight = 20.0;
  // 定义紧凑模式按钮尺寸（统一播放按钮和控制按钮）
  static const double kCompactButtonSize = 28.0;
  // 定义紧凑模式播放/暂停图标尺寸
  static const double kCompactPlayPauseIconSize = 22.0;

  // 定义封面模式播放按钮尺寸
  static const double kSquareModePlayButtonSize = 38.0;
  // 定义封面模式图标尺寸
  static const double kSquareModeIconSize = 32.0;
  // 定义封面模式按钮透明度
  static const double kSquareModeButtonOpacity = 0.7;

  // 定义双击检测超时时间
  static const Duration kDoubleTapTimeout = Duration(milliseconds: 300);
  // 定义全屏切换防抖时间
  static const Duration kFullscreenDebounceTimeout = Duration(milliseconds: 500);

  // 定义图片缓存最大宽度
  static const int kImageCacheMaxWidth = 512;
  // 定义图片缓存最大高度
  static const int kImageCacheMaxHeight = 512;

  // 定义文本阴影效果
  static const List<Shadow> _textShadows = [
    Shadow(blurRadius: kTextShadowBlurRadius, color: Colors.black54, offset: Offset(kShadowOffsetX, kShadowOffsetY)),
  ];

  // 定义进度条阴影效果
  static const List<BoxShadow> _progressBarShadows = [
    BoxShadow(blurRadius: kIconShadowBlurRadius, color: Colors.black45, offset: Offset(kShadowOffsetX, kShadowOffsetY)),
  ];

  // 定义图标阴影效果
  static const List<Shadow> _iconShadows = [
    Shadow(blurRadius: kIconShadowBlurRadius, color: Colors.black45, offset: Offset(kShadowOffsetX, kShadowOffsetY)),
  ];

  // 定义控件内边距
  static const EdgeInsets _controlsPadding = EdgeInsets.symmetric(horizontal: kSpacingDouble);
  // 定义进度条内边距
  static const EdgeInsets _progressPadding = EdgeInsets.only(
    left: kSpacingDouble,
    right: kSpacingDouble,
    top: kSpacingUnit,
  );
  // 定义直播模式进度条内边距
  static const EdgeInsets _progressPaddingLive = EdgeInsets.only(
    left: kSpacingDouble,
    right: kSpacingDouble,
    top: 0.0,
  );
  // 定义图标按钮内边距
  static const EdgeInsets _iconButtonPadding = EdgeInsets.all(kSpacingHalf);
  // 定义标题内边距
  static const EdgeInsets _titlePadding = EdgeInsets.symmetric(horizontal: kSpacingUnit);
  // 定义模态框头部内边距
  static const EdgeInsets _modalHeaderPadding = EdgeInsets.only(left: kSpacingDouble, right: kSpacingUnit);
  // 定义模态框列表内边距
  static const EdgeInsets _modalListPadding = EdgeInsets.symmetric(vertical: kSpacingUnit);
  // 定义模态框列表项外边距
  static const EdgeInsets _modalItemMargin = EdgeInsets.symmetric(horizontal: kSpacingUnit, vertical: kPlaylistItemVerticalMargin);

  // 定义模态框顶部圆角
  static const BorderRadius _modalTopBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(kModalBorderRadius),
    topRight: Radius.circular(kModalBorderRadius),
  );
  // 定义封面圆角
  static const BorderRadius _coverBorderRadius = BorderRadius.all(Radius.circular(kStandardBorderRadius));
  // 定义列表项圆角
  static const BorderRadius _itemBorderRadius = BorderRadius.all(Radius.circular(8));

  // 定义双倍间距占位
  static const SizedBox _spacingDoubleBox = SizedBox(height: kSpacingDouble);
  // 定义双倍宽度间距占位
  static const SizedBox _spacingDoubleWidthBox = SizedBox(width: kSpacingDouble);
  // 定义时间与进度条间距占位
  static const SizedBox _timeSpacingBox = SizedBox(width: kSpacingUnit);

  // 缓存音乐图标
  static final Widget _musicNoteIcon = Icon(
    Icons.music_note,
    size: 60,
    color: Colors.grey[600],
  );
  // 缓存音乐图标背景
  static final Widget _musicNoteBackground = Container(
    color: Colors.grey[900],
    child: _musicNoteIcon,
  );

  // 缓存黑色背景
  static const Widget _blackBackground = ColoredBox(color: Colors.black);
  // 缓存透明遮罩
  static final Widget _transparentOverlay = Container(
    color: Colors.black.withOpacity(0.4),
  );
  // 缓存紧凑模式区域间距占位
  static const Widget _compactSectionSpacer = SizedBox(height: kCompactSectionSpacing);
  // 缓存紧凑模式歌曲信息间距占位
  static const Widget _compactSongInfoSpacer = SizedBox(height: kCompactSongInfoSpacing);
  // 缓存单位间距占位
  static const Widget _spacingUnitBox = SizedBox(width: kSpacingUnit);
  // 缓存双倍间距占位
  static const Widget _spacingDoubleBox2 = SizedBox(width: kSpacingDouble);
  
  // 缓存唱片阴影装饰
  static final BoxDecoration _discShadowDecoration = BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  );
  
  // 缓存透明圆形装饰
  static const BoxDecoration _transparentCircleDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.transparent,
  );
  
  // 缓存白色圆形装饰
  static const BoxDecoration _whiteCircleDecoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
  );
  
  // 缓存中心孔装饰
  static final BoxDecoration _centerHoleDecoration = BoxDecoration(
    color: Colors.grey[800],
    shape: BoxShape.circle,
  );

  // 存储最新播放值
  VideoPlayerValue? _latestValue;
  // 存储最新音量
  double? _latestVolume;
  // 存储视频播放控制器
  VideoPlayerController? _controller;
  // 存储播放器控制器
  IAppPlayerController? _iappPlayerController;

  // 控制唱片旋转动画
  AnimationController? _rotationController;
  // 驱动旋转动画
  Animation<double>? _rotationAnimation;

  // 生成随机渐变色
  final _random = math.Random();
  // 存储渐变色列表
  List<Color>? _gradientColors;

  // 存储当前显示模式
  PlayerDisplayMode _currentDisplayMode = PlayerDisplayMode.compact;
  // 标记动画初始化状态
  bool _animationsInitialized = false;

  // 缓存上次更新位置（秒级）
  int? _lastUpdatedPositionInSeconds;
  // 缓存布局约束
  BoxConstraints? _cachedConstraints;
  // 缓存显示模式
  PlayerDisplayMode? _cachedDisplayMode;

  // 存储上次点击时间
  DateTime? _lastTapTime;
  // 控制双击定时器
  Timer? _doubleTapTimer;

  // 控制全屏切换防抖
  Timer? _fullscreenDebounceTimer;
  // 标记全屏切换状态
  bool _isFullscreenTransitioning = false;

  // 缓存播放列表索引
  int? _cachedPlaylistIndex;
  // 缓存随机播放模式
  bool? _cachedShuffleMode;

  // 缓存播放状态
  bool? _cachedIsPlaying;
  // 缓存错误状态
  bool? _cachedHasError;
  // 缓存音量值
  double? _cachedVolume;
  // 缓存时长
  Duration? _cachedDuration;

  // 获取控件配置
  IAppPlayerControlsConfiguration get _controlsConfiguration => widget.controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  IAppPlayerController? get iappPlayerController => _iappPlayerController;

  @override
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration => _controlsConfiguration;

  // 缓存响应式缩放因子
  double? _cachedScaleFactor;
  // 缓存屏幕尺寸
  Size? _cachedScreenSize;
  // 存储响应式图标尺寸
  late double _responsiveIconSize;
  // 存储响应式播放/暂停图标尺寸
  late double _responsivePlayPauseIconSize;
  // 存储响应式文本尺寸
  late double _responsiveTextSize;
  // 存储响应式错误图标尺寸
  late double _responsiveErrorIconSize;
  // 存储响应式标题字体尺寸
  late double _responsiveTitleFontSize;

  // 计算响应式尺寸
  double _getResponsiveSize(double baseSize) {
    return baseSize * (_cachedScaleFactor ?? 1.0);
  }

  // 预计算响应式尺寸
  void _precalculateResponsiveSizes(BuildContext context) {
    final currentScreenSize = MediaQuery.of(context).size;
    
    // 检查屏幕尺寸变化
    if (_cachedScreenSize != currentScreenSize) {
      _cachedScreenSize = currentScreenSize;
      final screenWidth = currentScreenSize.width;
      final screenHeight = currentScreenSize.height;
      final screenSize = screenWidth < screenHeight ? screenWidth : screenHeight;

      final scaleFactor = screenSize / 360.0;
      _cachedScaleFactor = scaleFactor.clamp(0.8, 1.5);
    }
    
    // 计算响应式尺寸
    _responsiveIconSize = _getResponsiveSize(kIconSizeBase);
    _responsivePlayPauseIconSize = _getResponsiveSize(kPlayPauseIconSize);
    _responsiveTextSize = _getResponsiveSize(kTextSizeBase);
    _responsiveErrorIconSize = _getResponsiveSize(kErrorIconSize);
    _responsiveTitleFontSize = _getResponsiveSize(kStandardFontSize);
  }

  @override
  void initState() {
    super.initState();
    // 延迟动画初始化至布局确定
  }

  // 生成随机渐变色
  void _generateRandomGradient({bool force = false}) {
    if (_gradientColors != null && !force) return;
    
    final hue1 = _random.nextDouble() * 360;
    final hue2 = (hue1 + 30 + _random.nextDouble() * 60) % 360;
    
    _gradientColors = [
      HSVColor.fromAHSV(1.0, hue1, 0.6, 0.3).toColor(),
      HSVColor.fromAHSV(1.0, hue2, 0.5, 0.4).toColor(),
    ];
  }

  // 初始化旋转动画
  void _initializeAnimations() {
    if (_animationsInitialized) return;
    
    _animationsInitialized = true;
    
    // 设置旋转动画控制器
    _rotationController = AnimationController(
      duration: kRotationDuration,
      vsync: this,
    );
    // 设置旋转动画驱动
    _rotationAnimation = _rotationController!.drive(
      Tween<double>(begin: 0.0, end: 1.0),
    );
  }

  // 计算当前显示模式
  PlayerDisplayMode _calculateDisplayMode(BoxConstraints constraints) {
    if (_cachedConstraints == constraints && _cachedDisplayMode != null) {
      return _cachedDisplayMode!;
    }
    
    _cachedConstraints = constraints;
    
    final double aspectRatio = constraints.maxWidth / constraints.maxHeight;
    
    // 判断封面模式
    if ((aspectRatio - 1.0).abs() < 0.01) {
      _cachedDisplayMode = PlayerDisplayMode.square;
    }
    // 判断紧凑模式
    else if ((aspectRatio - 2.0).abs() < 0.01 || 
        (constraints.maxHeight != double.infinity && 
         constraints.maxHeight <= kExpandedModeThreshold)) {
      _cachedDisplayMode = PlayerDisplayMode.compact;
    }
    // 默认扩展模式
    else {
      _cachedDisplayMode = PlayerDisplayMode.expanded;
    }
    
    return _cachedDisplayMode!;
  }

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(
      LayoutBuilder(
        builder: (context, constraints) {
          // 计算显示模式
          final displayMode = _calculateDisplayMode(constraints);
          
          // 处理显示模式变化
          if (_currentDisplayMode != displayMode) {
            _currentDisplayMode = displayMode;
            
            // 初始化扩展模式动画
            if (_currentDisplayMode == PlayerDisplayMode.expanded && !_animationsInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializeAnimations();
                  _generateRandomGradient();
                  // 开始播放动画
                  if (_controller?.value.isPlaying ?? false) {
                    _startAnimations();
                  }
                }
              });
            }
          }
          
          // 构建主控件
          return _buildMainWidget(constraints);
        },
      ),
    );
  }

  @override
  void dispose() {
    // 清理资源
    _dispose();
    _rotationController?.dispose();
    _doubleTapTimer?.cancel();
    _fullscreenDebounceTimer?.cancel();
    _animationsInitialized = false;
    super.dispose();
  }

  // 清理控制器监听
  void _dispose() {
    _controller?.removeListener(_updateState);
    _doubleTapTimer?.cancel();
    _fullscreenDebounceTimer?.cancel();
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

    // 计算响应式尺寸
    _precalculateResponsiveSizes(context);

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
    
    // 根据显示模式选择布局
    switch (_currentDisplayMode) {
      case PlayerDisplayMode.expanded:
        return _buildExpandedMode();
      case PlayerDisplayMode.square:
        return _buildSquareMode();
      case PlayerDisplayMode.compact:
        return _buildCompactMode(constraints);
    }
  }

  // 构建扩展模式布局
  Widget _buildExpandedMode() {
    Widget content = Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 添加渐变背景
          if (_gradientColors != null)
            Positioned.fill(
              child: _buildGradientBackground(),
            ),
          // 添加主内容
          _buildExpandedLayout(),
        ],
      ),
    );

    // 处理手势事件
    final gestureDetector = IAppPlayerMultipleGestureDetector.of(context);
    
    if (!_controlsConfiguration.handleAllGestures) {
      // 使用Listener处理单击/双击
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) {
          final now = DateTime.now();
          if (_lastTapTime != null && now.difference(_lastTapTime!) < kDoubleTapTimeout) {
            _doubleTapTimer?.cancel();
            _lastTapTime = null;
            gestureDetector?.onDoubleTap?.call();
            // 切换全屏
            if (_controlsConfiguration.enableFullscreen) {
              _toggleFullscreen();
            }
          } else {
            _lastTapTime = now;
            _doubleTapTimer?.cancel();
            _doubleTapTimer = Timer(kDoubleTapTimeout, () {
              _lastTapTime = null;
              gestureDetector?.onTap?.call();
            });
          }
        },
        child: content,
      );
    } else {
      // 使用GestureDetector处理所有手势
      return GestureDetector(
        onTap: () {
          gestureDetector?.onTap?.call();
        },
        onDoubleTap: () {
          gestureDetector?.onDoubleTap?.call();
          // 切换全屏
          if (_controlsConfiguration.enableFullscreen) {
            _toggleFullscreen();
          }
        },
        onLongPress: () {
          gestureDetector?.onLongPress?.call();
        },
        child: content,
      );
    }
  }

  // 构建渐变背景
  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors!,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
      ),
    );
  }

  // 构建扩展模式主布局
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
        // 添加标题区域
        Positioned(
          top: kSpacingDouble,
          left: 0,
          right: 0,
          child: _buildTitleSection(),
        ),
        // 添加字幕显示
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
      child: RepaintBoundary(
        child: Container(
          width: kExpandedDiscSize,
          height: kExpandedDiscSize,
          decoration: _discShadowDecoration,
          child: ClipOval(
            child: RotationTransition(
              turns: _rotationAnimation ?? const AlwaysStoppedAnimation(0.0),
              child: Stack(
                children: [
                  // 绘制唱片纹理
                  const CustomPaint(
                    size: Size(kExpandedDiscSize, kExpandedDiscSize),
                    painter: _DiscPainter(isCompact: false),
                  ),
                  // 添加中心封面
                  Center(
                    child: Container(
                      width: kExpandedDiscSize * kDiscInnerCircleRatio,
                      height: kExpandedDiscSize * kDiscInnerCircleRatio,
                      decoration: _transparentCircleDecoration,
                      child: ClipOval(
                        child: _buildCoverImage(placeholder, imageUrl),
                      ),
                    ),
                  ),
                  // 添加中心白色标签
                  Center(
                    child: Container(
                      width: kExpandedDiscSize * kDiscCenterRatio,
                      height: kExpandedDiscSize * kDiscCenterRatio,
                      decoration: _whiteCircleDecoration,
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
                  // 添加中心孔
                  Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: _centerHoleDecoration,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建封面模式布局
  Widget _buildSquareMode() {
    final imageUrl = _getImageUrl();
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // 添加黑色背景
        _blackBackground,
        // 添加封面图片
        _buildCoverImage(
          placeholder, 
          imageUrl, 
          fit: BoxFit.cover,
        ),
        // 添加透明遮罩
        _transparentOverlay,
        // 添加居中播放按钮
        Center(
          child: _buildSquareModePlayButton(),
        ),
        // 处理字幕逻辑
        if (_controlsConfiguration.enableSubtitles)
          Offstage(
            offstage: true,
            child: IAppPlayerSubtitlesDrawer(
              iappPlayerController: _iappPlayerController!,
              iappPlayerSubtitlesConfiguration: _iappPlayerController!.iappPlayerConfiguration.subtitlesConfiguration,
              subtitles: _iappPlayerController!.subtitlesLines,
            ),
          ),
      ],
    );
  }

  // 构建封面模式播放按钮
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
          color: Colors.white.withOpacity(kSquareModeButtonOpacity),
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
          color: Colors.black,
          size: kSquareModeIconSize,
        ),
      ),
    );
  }

  // 构建紧凑模式布局
  Widget _buildCompactMode(BoxConstraints constraints) {
    final bool isPlaylist = _iappPlayerController!.isPlaylistMode;
    final imageUrl = _getImageUrl();
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    
    final double playerHeight = constraints.maxHeight.isFinite 
      ? math.min(constraints.maxHeight, kCompactModeMaxHeight)
      : kCompactModeMinHeight;
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
      child: Stack(
        children: [
          Row(
            children: [
              // 添加左侧封面
              _buildCompactCoverSection(placeholder, imageUrl, coverSize, showGradient: true),
              // 添加右侧控制区域
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
          // 处理字幕逻辑
          if (_controlsConfiguration.enableSubtitles)
            Offstage(
              offstage: true,
              child: IAppPlayerSubtitlesDrawer(
                iappPlayerController: _iappPlayerController!,
                iappPlayerSubtitlesConfiguration: _iappPlayerController!.iappPlayerConfiguration.subtitlesConfiguration,
                subtitles: _iappPlayerController!.subtitlesLines,
              ),
            ),
        ],
      ),
    );
  }

  // 构建紧凑模式封面区域
  Widget _buildCompactCoverSection(Widget? placeholder, String? imageUrl, double size, {bool showGradient = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 添加封面图片
          _buildCoverImage(
            placeholder, 
            imageUrl, 
            fit: BoxFit.cover,
          ),
          // 添加渐变遮罩
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

  // 构建紧凑模式控制区域
  Widget _buildCompactControlsArea(bool isPlaylist) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 添加顶部栏
        _buildCompactTopBar(isPlaylist),
        // 添加歌曲信息
        Expanded(
          child: Center(
            child: _buildCompactSongInfoArea(),
          ),
        ),
        // 添加底部控制区
        Column(
          children: [
            _buildCompactProgressSection(),
            _compactSectionSpacer,
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
          // 显示剩余时间
          if (_controlsConfiguration.enableProgressText && !isLive)
            Text(
              '-${IAppPlayerUtils.formatDuration(remaining)}',
              style: TextStyle(
                fontSize: 11,
                color: _controlsConfiguration.textColor.withOpacity(0.7),
              ),
            ),
          const Spacer(),
          // 添加右侧按钮组
          Row(
            children: [
              if (isPlaylist) ...[
                _buildCompactIconButton(
                  icon: _iappPlayerController!.playlistShuffleMode 
                    ? Icons.shuffle 
                    : Icons.repeat,
                  onTap: () {
                    _iappPlayerController!.togglePlaylistShuffle();
                    setState(() {});
                  },
                  size: kSmallIconSize,
                ),
                _spacingUnitBox,
                _buildCompactIconButton(
                  icon: Icons.queue_music,
                  onTap: _showPlaylistMenu,
                  size: kSmallIconSize,
                ),
                if (_controlsConfiguration.enableFullscreen)
                  _spacingUnitBox,
              ],
              // 添加全屏按钮
              if (_controlsConfiguration.enableFullscreen)
                _buildCompactIconButton(
                  icon: _iappPlayerController!.isFullScreen
                      ? _controlsConfiguration.fullscreenDisableIcon
                      : _controlsConfiguration.fullscreenEnableIcon,
                  onTap: _toggleFullscreen,
                  size: kSmallIconSize,
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
          _compactSongInfoSpacer,
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

  // 构建紧凑模式进度条区域
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
            size: kCompactButtonSize,
          ),
          _spacingDoubleBox2,
          _buildCompactPlayPauseButton(),
          _spacingDoubleBox2,
          _buildCompactIconButton(
            icon: Icons.skip_next,
            onTap: (_iappPlayerController!.playlistController?.hasNext ?? false) 
              ? _playNext 
              : null,
            enabled: _iappPlayerController!.playlistController?.hasNext ?? false,
            size: kCompactButtonSize,
          ),
        ] else ...[
          if (!isLive) ...[
            _buildCompactIconButton(
              icon: Icons.replay_10,
              onTap: skipBack,
              size: 24,
            ),
            _spacingDoubleBox2,
          ],
          _buildCompactPlayPauseButton(),
          if (!isLive) ...[
            _spacingDoubleBox2,
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

  // 构建紧凑模式图标按钮
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

  // 构建紧凑模式播放/暂停按钮
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
        width: kCompactButtonSize,
        height: kCompactButtonSize,
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

  // 获取封面图片URL
  String? _getImageUrl() {
    final placeholder = _iappPlayerController?.iappPlayerDataSource?.placeholder;
    if (placeholder != null) return null;
    
    return _iappPlayerController?.iappPlayerDataSource?.notificationConfiguration?.imageUrl;
  }

  // 构建封面图片
  Widget _buildCoverImage(Widget? placeholder, String? imageUrl, {
    BoxFit? fit,
  }) {
    final effectiveFit = fit ?? BoxFit.cover;
    
    // 设置缓存尺寸
    int cacheWidth = kImageCacheMaxWidth;
    int cacheHeight = kImageCacheMaxHeight;
    
    switch (_currentDisplayMode) {
      case PlayerDisplayMode.compact:
        cacheWidth = 180;
        cacheHeight = 180;
        break;
      case PlayerDisplayMode.square:
        break;
      case PlayerDisplayMode.expanded:
        cacheWidth = (kExpandedDiscSize * kDiscInnerCircleRatio).toInt();
        cacheHeight = (kExpandedDiscSize * kDiscInnerCircleRatio).toInt();
        break;
    }
    
    Widget imageWidget;
    
    if (placeholder != null) {
      imageWidget = placeholder;
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        imageWidget = Image.network(
          imageUrl,
          fit: effectiveFit,
          alignment: Alignment.center,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) => _musicNoteBackground,
        );
      } else {
        imageWidget = Image.asset(
          imageUrl,
          fit: effectiveFit,
          alignment: Alignment.center,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) => _musicNoteBackground,
        );
      }
    } else {
      imageWidget = _musicNoteBackground;
    }
    
    return imageWidget;
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
          // 显示当前时间
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
          // 添加进度条
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
          // 显示总时长
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
          // 添加左侧按钮
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
          // 添加中间播放控制
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
          // 添加右侧按钮
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
      onTap: _toggleFullscreen,
    );
  }

  // 切换全屏模式
  void _toggleFullscreen() {
    if (_isFullscreenTransitioning) return;
    
    _isFullscreenTransitioning = true;
    
    if (_iappPlayerController!.isFullScreen) {
      _iappPlayerController!.exitFullScreen();
    } else {
      _iappPlayerController!.enterFullScreen();
    }
    
    // 设置防抖定时器
    _fullscreenDebounceTimer?.cancel();
    _fullscreenDebounceTimer = Timer(kFullscreenDebounceTimeout, () {
      _isFullscreenTransitioning = false;
    });
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
        child: ClipRRect(
          borderRadius: _modalTopBorderRadius,
          child: Container(
            decoration: BoxDecoration(
              color: kPlaylistBackgroundColor.withOpacity(kModalBackgroundOpacity),
              borderRadius: _modalTopBorderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _buildPlaylistMenuContent(),
          ),
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
              color: Colors.white.withOpacity(0.7),
              fontSize: kStandardFontSize,
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
          // 添加标题栏
          Container(
            height: kModalHeaderHeight,
            padding: _modalHeaderPadding,
            decoration: BoxDecoration(
              color: kPlaylistSurfaceColor.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: kPlaylistPrimaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.queue_music_rounded,
                  color: kPlaylistPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  translations.playlistTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: kModalTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: const EdgeInsets.all(kSpacingUnit),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 添加列表内容
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: kSpacingUnit),
              itemCount: dataSourceList.length,
              itemBuilder: (context, index) {
                final dataSource = dataSourceList[index];
                final isCurrentItem = index == currentIndex;
                final title = dataSource.notificationConfiguration?.title ?? 
                  translations.videoItem.replaceAll('{index}', '${index + 1}');
                
                return _buildPlaylistItem(
                  title: title,
                  index: index,
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
    String? author,
    required int index,
    required bool isCurrentItem,
    required VoidCallback onTap,
  }) {
    return IAppPlayerClickableWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: _modalItemMargin,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentItem 
            ? kPlaylistPrimaryColor.withOpacity(0.15)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(kStandardBorderRadius),
          border: Border.all(
            color: isCurrentItem 
              ? kPlaylistPrimaryColor.withOpacity(0.3)
              : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 添加播放指示器
            Container(
              width: 40,
              alignment: Alignment.center,
              child: isCurrentItem
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPlaylistPrimaryColor.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: kPlaylistPrimaryColor,
                      size: kSmallIconSize,
                    ),
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
            ),
            const SizedBox(width: 8),
            // 添加歌曲信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCurrentItem ? Colors.white : Colors.white.withOpacity(0.9),
                      fontSize: kStandardFontSize,
                      fontWeight: isCurrentItem ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      author,
                      style: TextStyle(
                        color: isCurrentItem 
                          ? kPlaylistPrimaryColor.withOpacity(0.8)
                          : Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
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

  // 切换播放/暂停状态
  void _onPlayPause() {
    if (_controller == null || !(_controller!.value.initialized)) {
      return;
    }
    
    final bool isFinished = _latestValue?.position != null && 
      _latestValue?.duration != null && 
      _latestValue!.position >= _latestValue!.duration!;

    if (_controller!.value.isPlaying) {
      _iappPlayerController!.pause();
      _stopAnimations();
    } else {
      if (isFinished) _iappPlayerController!.seekTo(const Duration());
      _iappPlayerController!.play();
      _iappPlayerController!.cancelNextVideoTimer();
      _startAnimations();
    }
  }

  // 开始旋转动画
  void _startAnimations() {
    if (_currentDisplayMode == PlayerDisplayMode.expanded && _animationsInitialized) {
      _rotationController?.repeat();
    }
  }

  // 停止旋转动画
  void _stopAnimations() {
    _rotationController?.stop();
  }

  // 初始化播放控制器
  Future<void> _initialize() async {
    _controller!.addListener(_updateState);
    _updateState();
    
    // 设置初始播放动画
    if (_controller!.value.isPlaying) {
      _startAnimations();
    }
  }

  // 更新播放状态
  void _updateState() {
    if (!mounted) return;
    
    final newValue = _controller!.value;
    
    final currentPositionInSeconds = newValue.position.inSeconds;
    final bool positionChanged = _lastUpdatedPositionInSeconds != currentPositionInSeconds;
    
    bool shouldUpdate = false;
    
    // 检查位置变化
    if (positionChanged) {
      _lastUpdatedPositionInSeconds = currentPositionInSeconds;
      shouldUpdate = true;
    }
    
    // 检查播放状态变化
    if (_cachedIsPlaying != newValue.isPlaying) {
      _cachedIsPlaying = newValue.isPlaying;
      shouldUpdate = true;
      
      // 控制动画状态
      if (newValue.isPlaying && !(_rotationController?.isAnimating ?? false)) {
        _startAnimations();
      } else if (!newValue.isPlaying && (_rotationController?.isAnimating ?? false)) {
        _stopAnimations();
      }
    }
    
    // 检查错误状态变化
    if (_cachedHasError != newValue.hasError) {
      _cachedHasError = newValue.hasError;
      shouldUpdate = true;
    }
    
    // 检查音量变化
    if (_cachedVolume == null || (_cachedVolume! - newValue.volume).abs() > 0.01) {
      _cachedVolume = newValue.volume;
      shouldUpdate = true;
    }
    
    // 检查时长变化
    if (_cachedDuration != newValue.duration) {
      _cachedDuration = newValue.duration;
      shouldUpdate = true;
    }
    
    // 检查播放列表状态
    if (_iappPlayerController?.isPlaylistMode == true) {
      final currentIndex = _iappPlayerController!.playlistController?.currentDataSourceIndex;
      final currentShuffleMode = _iappPlayerController!.playlistShuffleMode;
      
      if (_cachedPlaylistIndex != currentIndex || _cachedShuffleMode != currentShuffleMode) {
        // 检测到歌曲切换
        final bool songChanged = _cachedPlaylistIndex != null && 
                                _cachedPlaylistIndex != currentIndex;
        
        _cachedPlaylistIndex = currentIndex;
        _cachedShuffleMode = currentShuffleMode;
        shouldUpdate = true;
        
        // 如果是扩展模式且歌曲切换，更新渐变背景
        if (songChanged && 
            _currentDisplayMode == PlayerDisplayMode.expanded && 
            _animationsInitialized) {
          _generateRandomGradient(force: true);
        }
      }
    }
    
    // 更新UI状态
    if (shouldUpdate) {
      setState(() {
        _latestValue = newValue;
      });
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
    // 保持控件始终可见
  }
}

// 绘制唱片纹理
class _DiscPainter extends CustomPainter {
  final bool isCompact;
  
  const _DiscPainter({required this.isCompact});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 绘制黑色背景
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 设置纹理画笔
    final groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCompact ? _IAppPlayerAudioControlsState.kDiscGrooveWidth : 1.0;
    
    // 绘制紧凑模式纹理
    if (isCompact) {
      groovePaint.color = Colors.white.withOpacity(0.15);
      for (double r = _IAppPlayerAudioControlsState.kDiscGrooveSpacing * 2; 
           r < radius; 
           r += _IAppPlayerAudioControlsState.kDiscGrooveSpacing * 3) {
        canvas.drawCircle(center, r, groovePaint);
      }
    } else {
      // 绘制扩展模式纹理
      groovePaint.color = Colors.white.withOpacity(0.3);
      final coverRadius = radius * _IAppPlayerAudioControlsState.kDiscInnerCircleRatio;
      final availableSpace = radius - coverRadius;
      final spacing = availableSpace / 5;
      for (int i = 1; i <= 4; i++) {
        final r = coverRadius + spacing * i;
        canvas.drawCircle(center, r, groovePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
