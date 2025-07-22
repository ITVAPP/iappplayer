import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/configuration/iapp_player_controller_event.dart';
import 'package:iapp_player/src/controls/iapp_player_video_controls.dart';
import 'package:iapp_player/src/controls/iapp_player_audio_controls.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:flutter/material.dart';

// 视频播放组件，渲染视频、控件和字幕
class IAppPlayerWithControls extends StatefulWidget {
  final IAppPlayerController? controller;

  const IAppPlayerWithControls({Key? key, this.controller}) : super(key: key);

  @override
  _IAppPlayerWithControlsState createState() => _IAppPlayerWithControlsState();
}

class _IAppPlayerWithControlsState extends State<IAppPlayerWithControls> {
  // 默认宽高比
  static const double _defaultAspectRatio = 16.0 / 9.0;
  // 最大旋转角度
  static const int _maxRotationDegrees = 360;
  // 旋转角度步长
  static const int _rotationStep = 90;

  // 获取字幕配置
  IAppPlayerSubtitlesConfiguration get subtitlesConfiguration =>
      widget.controller!.iappPlayerConfiguration.subtitlesConfiguration;

  // 获取控件配置
  IAppPlayerControlsConfiguration get controlsConfiguration =>
      widget.controller!.iappPlayerControlsConfiguration;

  // 播放器初始化状态
  bool _initialized = false;

  // 控制器事件订阅
  StreamSubscription? _controllerEventSubscription;

  @override
  void initState() {
    // 订阅控制器事件
    _controllerEventSubscription =
        widget.controller!.controllerEventStream.listen(_onControllerChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(IAppPlayerWithControls oldWidget) {
    // 更新控制器时重新订阅事件
    if (oldWidget.controller != widget.controller) {
      _controllerEventSubscription?.cancel();
      _controllerEventSubscription =
          widget.controller!.controllerEventStream.listen(_onControllerChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // 清理资源
    _controllerEventSubscription?.cancel();
    super.dispose();
  }

  // 处理控制器事件更新
  void _onControllerChanged(IAppPlayerControllerEvent event) {
    if (!mounted) return;
    if (!_initialized) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 缓存控制器实例
    final IAppPlayerController iappPlayerController = IAppPlayerController.of(context);
    final iappConfiguration = iappPlayerController.iappPlayerConfiguration;

    // 计算宽高比
    double? aspectRatio;
    if (iappPlayerController.isFullScreen) {
      if (iappConfiguration.autoDetectFullscreenDeviceOrientation ||
          iappConfiguration.autoDetectFullscreenAspectRatio) {
        aspectRatio = iappPlayerController.videoPlayerController?.value.aspectRatio ?? 1.0;
      } else {
        aspectRatio = iappConfiguration.fullScreenAspectRatio ??
            IAppPlayerUtils.calculateAspectRatio(context);
      }
    } else {
      aspectRatio = iappPlayerController.getAspectRatio();
    }

    aspectRatio ??= _defaultAspectRatio;
    final innerContainer = Container(
      width: double.infinity,
      color: iappConfiguration.controlsConfiguration.backgroundColor,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _buildPlayerWithControls(iappPlayerController, context),
      ),
    );

    // 根据配置决定是否居中显示
    return iappConfiguration.expandToFill ? Center(child: innerContainer) : innerContainer;
  }

  // 构建播放器核心组件
  Container _buildPlayerWithControls(IAppPlayerController iappPlayerController, BuildContext context) {
    final configuration = iappPlayerController.iappPlayerConfiguration;
    var rotation = configuration.rotation;
    if (rotation > _maxRotationDegrees || rotation % _rotationStep != 0) {
      assert(() {
        IAppPlayerUtils.log("旋转角度无效，使用默认旋转 0");
        return true;
      }());
      rotation = 0;
    }
    if (iappPlayerController.iappPlayerDataSource == null) return Container();
    _initialized = true;

    final bool placeholderOnTop = configuration.placeholderOnTop;
    final bool isAudioOnly = controlsConfiguration.audioOnly;

    return Container(
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          if (!isAudioOnly) ...[
            if (placeholderOnTop) _buildPlaceholder(iappPlayerController),
            // 视频旋转与适配
            Transform.rotate(
              angle: rotation * pi / 180,
              child: _IAppPlayerVideoFitWidget(
                iappPlayerController,
                iappPlayerController.getFit(),
              ),
            ),
            // 自定义覆盖层
            configuration.overlay ?? const SizedBox(),
            if (!placeholderOnTop) _buildPlaceholder(iappPlayerController),
          ] else ...[
            // 音频模式占位图
            _buildPlaceholder(iappPlayerController),
          ],
          // 控件层
          _buildControls(context, iappPlayerController),
        ],
      ),
    );
  }

  // 构建占位符
  Widget _buildPlaceholder(IAppPlayerController iappPlayerController) {
    return iappPlayerController.iappPlayerDataSource!.placeholder ??
        iappPlayerController.iappPlayerConfiguration.placeholder ??
        const SizedBox();
  }

  // 构建控件层
  Widget _buildControls(BuildContext context, IAppPlayerController iappPlayerController) {
    if (!controlsConfiguration.showControls) return const SizedBox();
    if (controlsConfiguration.audioOnly) {
      // 音频模式控件
      return IAppPlayerAudioControls(
        onControlsVisibilityChanged: (_) {},
        controlsConfiguration: controlsConfiguration,
      );
    }

    // 视频模式控件
    IAppPlayerTheme? playerTheme = controlsConfiguration.playerTheme ?? IAppPlayerTheme.video;
    if (controlsConfiguration.customControlsBuilder != null && playerTheme == IAppPlayerTheme.custom) {
      return controlsConfiguration.customControlsBuilder!(iappPlayerController, (_) {});
    }
    return _buildVideoControl();
  }

  // 构建控件
  Widget _buildVideoControl() {
    return IAppPlayerVideoControls(
      onControlsVisibilityChanged: (_) {},
      controlsConfiguration: controlsConfiguration,
    );
  }
}

// 视频适配组件
class _IAppPlayerVideoFitWidget extends StatefulWidget {
  const _IAppPlayerVideoFitWidget(this.iappPlayerController, this.boxFit, {Key? key}) : super(key: key);

  final IAppPlayerController iappPlayerController;
  final BoxFit boxFit;

  @override
  _IAppPlayerVideoFitWidgetState createState() => _IAppPlayerVideoFitWidgetState();
}

class _IAppPlayerVideoFitWidgetState extends State<_IAppPlayerVideoFitWidget> {
  // 视频控制器
  VideoPlayerController? get controller => widget.iappPlayerController.videoPlayerController;

  // 初始化状态
  bool _initialized = false;

  // 初始化监听器
  VoidCallback? _initializedListener;

  // 播放状态
  bool _started = false;

  // 控制器事件订阅
  StreamSubscription? _controllerEventSubscription;

  @override
  void initState() {
    super.initState();
    final showPlaceholderUntilPlay = widget.iappPlayerController.iappPlayerConfiguration.showPlaceholderUntilPlay;
    // 设置初始播放状态
    _started = !showPlaceholderUntilPlay || widget.iappPlayerController.hasCurrentDataSourceStarted;
    _initialize();
  }

  @override
  void didUpdateWidget(_IAppPlayerVideoFitWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 更新控制器时重新初始化
    if (oldWidget.iappPlayerController.videoPlayerController != controller) {
      if (_initializedListener != null) {
        oldWidget.iappPlayerController.videoPlayerController!.removeListener(_initializedListener!);
      }
      _initialized = false;
      _initialize();
    }
  }

  // 初始化视频适配
  void _initialize() {
    if (controller?.value.initialized == false) {
      _initializedListener = () {
        if (!mounted) return;
        if (_initialized != controller!.value.initialized) {
          setState(() => _initialized = controller!.value.initialized);
        }
      };
      controller!.addListener(_initializedListener!);
    } else {
      _initialized = true;
    }

    // 订阅控制器事件
    _controllerEventSubscription = widget.iappPlayerController.controllerEventStream.listen((event) {
      if (!mounted) return;
      if (event == IAppPlayerControllerEvent.play && !_started) {
        setState(() => _started = widget.iappPlayerController.hasCurrentDataSourceStarted);
      }
      if (event == IAppPlayerControllerEvent.setupDataSource) {
        setState(() => _started = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 显示视频或占位符
    if (_initialized && _started) {
      return Center(
        child: ClipRect(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: widget.boxFit,
              child: SizedBox(
                width: controller!.value.size?.width ?? 0,
                height: controller!.value.size?.height ?? 0,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  void dispose() {
    // 清理资源
    if (_initializedListener != null) {
      // 安全检查，避免空指针异常
      widget.iappPlayerController.videoPlayerController?.removeListener(_initializedListener!);
    }
    _controllerEventSubscription?.cancel();
    super.dispose();
  }
}
