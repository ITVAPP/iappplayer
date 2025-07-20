import 'dart:async';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/configuration/iapp_player_controller_event.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/core/iapp_player_with_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 渲染视频播放器的组件
class IAppPlayer extends StatefulWidget {
  const IAppPlayer({Key? key, required this.controller}) : super(key: key);

  /// 从网络URL创建播放器实例
  factory IAppPlayer.network(
    String url, {
    IAppPlayerConfiguration? iappPlayerConfiguration,
  }) =>
      IAppPlayer(
        controller: IAppPlayerController(
          iappPlayerConfiguration ?? const IAppPlayerConfiguration(),
          iappPlayerDataSource:
              IAppPlayerDataSource(IAppPlayerDataSourceType.network, url),
        ),
      );

  /// 从本地文件创建播放器实例
  factory IAppPlayer.file(
    String url, {
    IAppPlayerConfiguration? iappPlayerConfiguration,
  }) =>
      IAppPlayer(
        controller: IAppPlayerController(
          iappPlayerConfiguration ?? const IAppPlayerConfiguration(),
          iappPlayerDataSource:
              IAppPlayerDataSource(IAppPlayerDataSourceType.file, url),
        ),
      );

  final IAppPlayerController controller; // 播放控制器

  @override
  _IAppPlayerState createState() => _IAppPlayerState();
}

class _IAppPlayerState extends State<IAppPlayer> with WidgetsBindingObserver {
  static const double _defaultAspectRatio = 16.0 / 9.0; // 默认宽高比
  static const double _minReasonableSize = 50.0; // 最小合理尺寸
  static const double _aspectRatioDifferenceThreshold = 5.0; // 宽高比差异阈值
  static const double _minValidAspectRatio = 0.1; // 最小有效宽高比
  static const double _maxValidAspectRatio = 10.0; // 最大有效宽高比
  static const Duration _updateDebounceDelay = Duration(milliseconds: 16); // 更新防抖延迟

  IAppPlayerConfiguration get _iappPlayerConfiguration =>
      widget.controller.iappPlayerConfiguration; // 播放器配置

  bool _isFullScreen = false; // 全屏状态
  late NavigatorState _navigatorState; // 导航状态
  bool _initialized = false; // 初始化标志
  StreamSubscription? _controllerEventSubscription; // 控制器事件订阅
  bool _needsUpdate = false; // 批量更新标志
  Timer? _updateDebounceTimer; // 更新防抖定时器

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 注册生命周期观察者
  }

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      _navigatorState = Navigator.of(context); // 保存导航状态
      _setup(); // 执行初始化设置
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  /// 设置控制器事件监听和语言环境
  Future<void> _setup() async {
    _controllerEventSubscription =
        widget.controller.controllerEventStream.listen(onControllerEvent); // 监听控制器事件
    var locale = const Locale("en", "US");
    try {
      if (mounted) {
        locale = Localizations.localeOf(context); // 获取当前语言环境
      }
    } catch (exception) {
      assert(() {
        IAppPlayerUtils.log(exception.toString()); // 调试模式下记录异常
        return true;
      }());
    }
    widget.controller.setupTranslations(locale); // 设置语言环境
  }

  @override
  void dispose() {
    if (_isFullScreen) {
      WakelockPlus.disable(); // 禁用屏幕常亮
      _navigatorState.maybePop(); // 退出全屏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: _iappPlayerConfiguration.systemOverlaysAfterFullScreen); // 恢复系统UI
      SystemChrome.setPreferredOrientations(
          _iappPlayerConfiguration.deviceOrientationsAfterFullScreen); // 恢复屏幕方向
    }
    WidgetsBinding.instance.removeObserver(this); // 移除生命周期观察者
    _controllerEventSubscription?.cancel(); // 取消事件订阅
    _updateDebounceTimer?.cancel(); // 清理定时器
    widget.controller.dispose(); // 释放控制器
    VisibilityDetectorController.instance
        .forget(Key("${widget.controller.hashCode}_key")); // 移除可见性检测
    super.dispose();
  }

  @override
  void didUpdateWidget(IAppPlayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      _controllerEventSubscription?.cancel();
      _controllerEventSubscription =
          widget.controller.controllerEventStream.listen(onControllerEvent); // 更新事件监听
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 处理控制器事件，更新UI或全屏状态
  void onControllerEvent(IAppPlayerControllerEvent event) {
    switch (event) {
      case IAppPlayerControllerEvent.openFullscreen:
      case IAppPlayerControllerEvent.hideFullscreen:
        onFullScreenChanged(); // 处理全屏切换
        break;
      case IAppPlayerControllerEvent.changeSubtitles:
      case IAppPlayerControllerEvent.setupDataSource:
        _scheduleUpdate(); // 批量更新UI
        break;
      default:
        break;
    }
  }

  /// 批量处理UI更新，减少重绘
  void _scheduleUpdate() {
    if (_needsUpdate) return;
    _needsUpdate = true;
    _updateDebounceTimer?.cancel();
    _updateDebounceTimer = Timer(_updateDebounceDelay, () {
      if (mounted && _needsUpdate) {
        setState(() {
          _needsUpdate = false;
        });
      }
    });
  }

  /// 处理全屏切换
  Future<void> onFullScreenChanged() async {
    final controller = widget.controller;
    if (controller.isFullScreen && !_isFullScreen) {
      _isFullScreen = true;
      controller.postEvent(IAppPlayerEvent(IAppPlayerEventType.openFullscreen)); // 发送全屏事件
      await _pushFullScreenWidget(context); // 推送全屏页面
    } else if (_isFullScreen) {
      Navigator.of(context, rootNavigator: true).pop(); // 退出全屏
      _isFullScreen = false;
      controller.postEvent(IAppPlayerEvent(IAppPlayerEventType.hideFullscreen)); // 发送退出全屏事件
    }
  }

  @override
  Widget build(BuildContext context) {
    return IAppPlayerControllerProvider(
      controller: widget.controller,
      child: LayoutBuilder(
        builder: (context, constraints) {
          try {
            if (widget.controller.isDisposed) {
              assert(() {
                IAppPlayerUtils.log('Controller已释放，显示错误占位'); // 控制器释放时记录
                return true;
              }());
              return _buildErrorPlaceholder('播放器已释放'); // 显示错误占位
            }
            final aspectRatio = _getSafeAspectRatio(); // 获取安全宽高比
            if (_shouldProvideDefaultConstraints(constraints)) {
              assert(() {
                IAppPlayerUtils.log('提供默认约束，宽高比: $aspectRatio'); // 记录默认约束
                return true;
              }());
              return AspectRatio(
                aspectRatio: aspectRatio,
                child: _buildPlayer(), // 构建播放器
              );
            }
            return _buildPlayer(); // 使用外部约束构建
          } catch (e, stackTrace) {
            assert(() {
              IAppPlayerUtils.log('IAppPlayer构建异常: $e'); // 记录构建异常
              return true;
            }());
            return _buildErrorPlaceholder('播放器构建失败'); // 显示错误占位
          }
        },
      ),
    );
  }

  /// 检测是否需要默认约束
  bool _shouldProvideDefaultConstraints(BoxConstraints constraints) {
    if (constraints.maxHeight == double.infinity ||
        constraints.maxHeight.isNaN ||
        constraints.maxHeight <= 0) {
      return true; // 高度无效
    }
    if (constraints.maxWidth == double.infinity ||
        constraints.maxWidth.isNaN ||
        constraints.maxWidth <= 0) {
      return true; // 宽度无效
    }
    if (constraints.maxWidth < _minReasonableSize ||
        constraints.maxHeight < _minReasonableSize) {
      assert(() {
        IAppPlayerUtils.log(
            '检测到占位约束: ${constraints.maxWidth}x${constraints.maxHeight}，应用默认约束'); // 记录占位约束
        return true;
      }());
      return true; // 约束过小
    }
    final constraintAspectRatio = constraints.maxWidth / constraints.maxHeight;
    final expectedAspectRatio = _getSafeAspectRatio();
    final aspectRatioDifference = (constraintAspectRatio - expectedAspectRatio).abs();
    if (aspectRatioDifference > _aspectRatioDifferenceThreshold) {
      assert(() {
        IAppPlayerUtils.log(
            '检测到异常宽高比: 约束=${constraintAspectRatio.toStringAsFixed(2)}, '
            '期望=${expectedAspectRatio.toStringAsFixed(2)}，应用默认约束'); // 记录宽高比异常
        return true;
      }());
      return true; // 宽高比失真
    }
    return false;
  }

  /// 获取安全宽高比
  double _getSafeAspectRatio() {
    try {
      final controllerAspectRatio = widget.controller.getAspectRatio();
      if (controllerAspectRatio != null && _isValidAspectRatio(controllerAspectRatio)) {
        return controllerAspectRatio; // 使用控制器宽高比
      }
      final videoAspectRatio = widget.controller.videoPlayerController?.value.aspectRatio;
      if (videoAspectRatio != null && _isValidAspectRatio(videoAspectRatio)) {
        return videoAspectRatio; // 使用视频宽高比
      }
      final configAspectRatio = widget.controller.iappPlayerConfiguration.aspectRatio;
      if (configAspectRatio != null && _isValidAspectRatio(configAspectRatio)) {
        return configAspectRatio; // 使用配置宽高比
      }
      return _defaultAspectRatio; // 默认16:9
    } catch (e) {
      assert(() {
        IAppPlayerUtils.log('获取宽高比失败: $e，使用默认值 16:9'); // 记录宽高比失败
        return true;
      }());
      return _defaultAspectRatio;
    }
  }

  /// 验证宽高比有效性
  bool _isValidAspectRatio(double aspectRatio) {
    return !aspectRatio.isNaN &&
        !aspectRatio.isInfinite &&
        aspectRatio > _minValidAspectRatio &&
        aspectRatio < _maxValidAspectRatio; // 检查宽高比范围
  }

  /// 构建错误占位组件
  Widget _buildErrorPlaceholder(String message) {
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: _defaultAspectRatio,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                '播放器错误',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建全屏视频页面
  Widget _buildFullScreenVideo(
      BuildContext context, Animation<double> animation, IAppPlayerControllerProvider controllerProvider) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        color: Colors.black,
        child: controllerProvider, // 全屏播放器
      ),
    );
  }

  /// 默认全屏页面构建器
  AnimatedWidget _defaultRoutePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      IAppPlayerControllerProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return _buildFullScreenVideo(context, animation, controllerProvider); // 构建默认全屏页面
      },
    );
  }

  /// 自定义全屏页面构建器
  Widget _fullScreenRoutePageBuilder(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final controllerProvider = IAppPlayerControllerProvider(
        controller: widget.controller, child: _buildPlayer());
    final routePageBuilder = _iappPlayerConfiguration.routePageBuilder;
    if (routePageBuilder == null) {
      return _defaultRoutePageBuilder(context, animation, secondaryAnimation, controllerProvider); // 使用默认构建器
    }
    return routePageBuilder(context, animation, secondaryAnimation, controllerProvider); // 使用自定义构建器
  }

  /// 推送全屏页面并设置屏幕方向
  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final route = PageRouteBuilder<void>(
      settings: const RouteSettings(),
      pageBuilder: _fullScreenRoutePageBuilder,
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // 设置沉浸模式
    if (_iappPlayerConfiguration.autoDetectFullscreenDeviceOrientation) {
      final aspectRatio = widget.controller.videoPlayerController?.value.aspectRatio ?? 1.0;
      List<DeviceOrientation> deviceOrientations;
      if (aspectRatio < 1.0) {
        deviceOrientations = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
      } else {
        deviceOrientations = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
      }
      await SystemChrome.setPreferredOrientations(deviceOrientations); // 设置屏幕方向
    } else {
      await SystemChrome.setPreferredOrientations(
          _iappPlayerConfiguration.deviceOrientationsOnFullScreen); // 使用配置屏幕方向
    }
    if (!_iappPlayerConfiguration.allowedScreenSleep) {
      WakelockPlus.enable(); // 启用屏幕常亮
    }
    await Navigator.of(context, rootNavigator: true).push(route); // 推送全屏页面
    _isFullScreen = false;
    widget.controller.exitFullScreen(); // 退出全屏
    WakelockPlus.disable(); // 禁用屏幕常亮
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: _iappPlayerConfiguration.systemOverlaysAfterFullScreen); // 恢复系统UI
    await SystemChrome.setPreferredOrientations(
        _iappPlayerConfiguration.deviceOrientationsAfterFullScreen); // 恢复屏幕方向
  }

  /// 构建带可见性检测的播放器组件
  Widget _buildPlayer() {
    return VisibilityDetector(
      key: Key("${widget.controller.hashCode}_key"),
      onVisibilityChanged: (VisibilityInfo info) =>
          widget.controller.onPlayerVisibilityChanged(info.visibleFraction), // 可见性变化回调
      child: IAppPlayerWithControls(controller: widget.controller), // 播放器控件
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    widget.controller.setAppLifecycleState(state); // 更新生命周期状态
  }
}

/// 全屏页面构建器类型
typedef IAppPlayerRoutePageBuilder = Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    IAppPlayerControllerProvider controllerProvider);
