import 'dart:async';
import 'dart:io';
import 'package:iapp_player/src/configuration/iapp_player_buffering_configuration.dart';
import 'package:iapp_player/src/configuration/iapp_player_data_source_type.dart';
import 'package:iapp_player/src/video_player/video_player_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 初始化平台视频播放器
final VideoPlayerPlatform _videoPlayerPlatform = VideoPlayerPlatform.instance
  ..init();

// 封装视频播放状态
class VideoPlayerValue {
  // 构造视频播放状态，需指定时长
  VideoPlayerValue({
    required this.duration,
    this.size,
    this.position = const Duration(),
    this.absolutePosition,
    this.buffered = const <DurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.speed = 1.0,
    this.errorDescription,
    this.isPip = false,
  });

  // 创建未初始化状态
  VideoPlayerValue.uninitialized() : this(duration: null);

  // 创建错误状态
  VideoPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  // 视频总时长
  final Duration? duration;

  // 当前播放位置
  final Duration position;

  // 当前绝对播放位置
  final DateTime? absolutePosition;

  // 已缓冲范围
  final List<DurationRange> buffered;

  // 是否正在播放
  final bool isPlaying;

  // 是否循环播放
  final bool isLooping;

  // 是否正在缓冲
  final bool isBuffering;

  // 播放音量
  final double volume;

  // 播放速度
  final double speed;

  // 错误描述
  final String? errorDescription;

  // 视频尺寸
  final Size? size;

  // 是否在画中画模式
  final bool isPip;

  // 是否已初始化
  bool get initialized => duration != null;

  // 是否有错误
  bool get hasError => errorDescription != null;

  // 计算视频宽高比
  double get aspectRatio {
    if (size == null) {
      return 1.0;
    }
    final double aspectRatio = size!.width / size!.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  // 复制并更新播放状态
  VideoPlayerValue copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    DateTime? absolutePosition,
    List<DurationRange>? buffered,
    bool? isPlaying,
    bool? isLooping,
    bool? isBuffering,
    double? volume,
    String? errorDescription,
    double? speed,
    bool? isPip,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      absolutePosition: absolutePosition ?? this.absolutePosition,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      errorDescription: errorDescription ?? this.errorDescription,
      isPip: isPip ?? this.isPip,
    );
  }

  // 格式化播放状态输出
  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'absolutePosition: $absolutePosition, '
        'buffered: [${buffered.join(', ')}], '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering, '
        'volume: $volume, '
        'errorDescription: $errorDescription)';
  }
}

// 控制视频播放和状态更新
class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  // 缓冲配置
  final IAppPlayerBufferingConfiguration bufferingConfiguration;

  // 构造视频控制器
  VideoPlayerController({
    this.bufferingConfiguration = const IAppPlayerBufferingConfiguration(),
    bool autoCreate = true,
  }) : super(VideoPlayerValue(duration: null)) {
    if (autoCreate) {
      _create();
    }
  }

  // 视频事件流控制器
  final StreamController<VideoEvent> videoEventStreamController =
      StreamController.broadcast();
  // 创建完成器
  final Completer<void> _creatingCompleter = Completer<void>();
  // 视频纹理 ID
  int? _textureId;

  // 定时器
  Timer? _timer;
  // 是否已释放
  bool _isDisposed = false;
  // 初始化完成器
  late Completer<void> _initializingCompleter;
  // 事件订阅
  StreamSubscription<dynamic>? _eventSubscription;

  // 是否已创建
  bool get _created => _creatingCompleter.isCompleted;
  // 跳转目标位置
  Duration? _seekPosition;

  // 获取纹理 ID（用于测试）
  @visibleForTesting
  int? get textureId => _textureId;

  // 创建平台视频控制器
  Future<void> _create() async {
    _textureId = await _videoPlayerPlatform.create(
      bufferingConfiguration: bufferingConfiguration,
    );
    _creatingCompleter.complete(null);

    unawaited(_applyLooping());
    unawaited(_applyVolume());

    void eventListener(VideoEvent event) {
      if (_isDisposed) {
        return;
      }
      videoEventStreamController.add(event);
      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
          );
          _initializingCompleter.complete(null);
          _applyPlayPause();
          break;
        case VideoEventType.completed:
          value = value.copyWith(isPlaying: false, position: value.duration);
          _timer?.cancel();
          break;
        case VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          if (value.isBuffering) {
            value = value.copyWith(isBuffering: false);
          }
          break;

        case VideoEventType.play:
          play();
          break;
        case VideoEventType.pause:
          pause();
          break;
        case VideoEventType.seek:
          seekTo(event.position);
          break;
        case VideoEventType.pipStart:
          value = value.copyWith(isPip: true);
          break;
        case VideoEventType.pipStop:
          value = value.copyWith(isPip: false);
          videoEventStreamController.add(event);
          break;
        case VideoEventType.unknown:
          break;
      }
    }

    void errorListener(Object object) {
      if (object is PlatformException) {
        final PlatformException e = object;
        value = value.copyWith(errorDescription: e.message);
      } else {
        value.copyWith(errorDescription: object.toString());
      }
      _timer?.cancel();
      if (!_initializingCompleter.isCompleted) {
        _initializingCompleter.completeError(object);
      }
    }

    _eventSubscription = _videoPlayerPlatform
        .videoEventsFor(_textureId)
        .listen(eventListener, onError: errorListener);
  }

  // 设置资产数据源
  Future<void> setAssetDataSource(
    String dataSource, {
    String? package,
    bool? showNotification,
    String? title,
    String? author,
    String? imageUrl,
    String? notificationChannelName,
    Duration? overriddenDuration,
    String? activityName,
  }) {
    return _setDataSource(
      DataSource(
        sourceType: DataSourceType.asset,
        asset: dataSource,
        package: package,
        showNotification: showNotification,
        title: title,
        author: author,
        imageUrl: imageUrl,
        notificationChannelName: notificationChannelName,
        overriddenDuration: overriddenDuration,
        activityName: activityName,
      ),
    );
  }

  // 设置网络数据源
  Future<void> setNetworkDataSource(
    String dataSource, {
    VideoFormat? formatHint,
    Map<String, String?>? headers,
    bool useCache = false,
    int? maxCacheSize,
    int? maxCacheFileSize,
    String? cacheKey,
    bool? showNotification,
    String? title,
    String? author,
    String? imageUrl,
    String? notificationChannelName,
    Duration? overriddenDuration,
    String? licenseUrl,
    String? certificateUrl,
    Map<String, String>? drmHeaders,
    String? activityName,
    String? clearKey,
    String? videoExtension,
    IAppPlayerDecoderType? preferredDecoderType,
  }) {
    // 转换解码器类型为int
    int? decoderTypeValue;
    if (preferredDecoderType != null) {
      switch (preferredDecoderType) {
        case IAppPlayerDecoderType.auto:
          decoderTypeValue = 0;
          break;
        case IAppPlayerDecoderType.hardwareFirst:
          decoderTypeValue = 1;
          break;
        case IAppPlayerDecoderType.softwareFirst:
          decoderTypeValue = 2;
          break;
      }
    }
    
    return _setDataSource(
      DataSource(
        sourceType: DataSourceType.network,
        uri: dataSource,
        formatHint: formatHint,
        headers: headers,
        useCache: useCache,
        maxCacheSize: maxCacheSize,
        maxCacheFileSize: maxCacheFileSize,
        cacheKey: cacheKey,
        showNotification: showNotification,
        title: title,
        author: author,
        imageUrl: imageUrl,
        notificationChannelName: notificationChannelName,
        overriddenDuration: overriddenDuration,
        licenseUrl: licenseUrl,
        certificateUrl: certificateUrl,
        drmHeaders: drmHeaders,
        activityName: activityName,
        clearKey: clearKey,
        videoExtension: videoExtension,
        preferredDecoderType: decoderTypeValue,
      ),
    );
  }

  // 设置文件数据源
  Future<void> setFileDataSource(File file,
      {bool? showNotification,
      String? title,
      String? author,
      String? imageUrl,
      String? notificationChannelName,
      Duration? overriddenDuration,
      String? activityName,
      String? clearKey}) {
    return _setDataSource(
      DataSource(
          sourceType: DataSourceType.file,
          uri: 'file://${file.path}',
          showNotification: showNotification,
          title: title,
          author: author,
          imageUrl: imageUrl,
          notificationChannelName: notificationChannelName,
          overriddenDuration: overriddenDuration,
          activityName: activityName,
          clearKey: clearKey),
    );
  }

  // 设置数据源
  Future<void> _setDataSource(DataSource dataSourceDescription) async {
    if (_isDisposed) {
      return;
    }

    value = VideoPlayerValue(
      duration: null,
      isLooping: value.isLooping,
      volume: value.volume,
    );

    if (!_creatingCompleter.isCompleted) await _creatingCompleter.future;

    _initializingCompleter = Completer<void>();

    await VideoPlayerPlatform.instance
        .setDataSource(_textureId, dataSourceDescription);
    return _initializingCompleter.future;
  }

  // 释放资源
  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    if (_creatingCompleter != null) {
      await _creatingCompleter!.future;
      if (!_isDisposed) {
        _isDisposed = true;
        value = VideoPlayerValue.uninitialized();         
        _timer?.cancel();
        await _eventSubscription?.cancel();
        await _videoPlayerPlatform.dispose(_textureId);
        videoEventStreamController.close();
      }
    }
    _isDisposed = true;
    super.dispose();
  }

  // 开始播放视频
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  // 设置循环播放
  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  // 暂停视频
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  // 应用循环设置
  Future<void> _applyLooping() async {
    if (!_created || _isDisposed) {
      return;
    }
    await _videoPlayerPlatform.setLooping(_textureId, value.isLooping);
  }

  // 应用播放/暂停状态
  Future<void> _applyPlayPause() async {
    if (!_created || _isDisposed) {
      return;
    }
    _timer?.cancel();
    if (value.isPlaying) {
      await _videoPlayerPlatform.play(_textureId);
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          if (_isDisposed) {
            return;
          }
          final Duration? newPosition = await position;
          final DateTime? newAbsolutePosition = await absolutePosition;
          if (_isDisposed) {
            return;
          }
          _updatePosition(newPosition, absolutePosition: newAbsolutePosition);
          if (_seekPosition != null && newPosition != null) {
            final difference =
                newPosition.inMilliseconds - _seekPosition!.inMilliseconds;
            if (difference > 0) {
              _seekPosition = null;
            }
          }
        },
      );
    } else {
      await _videoPlayerPlatform.pause(_textureId);
    }
  }

  // 应用音量设置
  Future<void> _applyVolume() async {
    if (!_created || _isDisposed) {
      return;
    }
    await _videoPlayerPlatform.setVolume(_textureId, value.volume);
  }

  // 应用播放速度
  Future<void> _applySpeed() async {
    if (!_created || _isDisposed) {
      return;
    }
    await _videoPlayerPlatform.setSpeed(_textureId, value.speed);
  }

  // 获取当前播放位置
  Future<Duration?> get position async {
    if (!value.initialized && _isDisposed) {
      return null;
    }
    return _videoPlayerPlatform.getPosition(_textureId);
  }

  // 获取绝对播放位置
  Future<DateTime?> get absolutePosition async {
    if (!value.initialized && _isDisposed) {
      return null;
    }
    return _videoPlayerPlatform.getAbsolutePosition(_textureId);
  }

  // 跳转到指定播放位置
  Future<void> seekTo(Duration? position) async {
    _timer?.cancel();
    bool isPlaying = value.isPlaying;
    final int positionInMs = value.position.inMilliseconds;
    final int durationInMs = value.duration?.inMilliseconds ?? 0;

    if (positionInMs >= durationInMs && position?.inMilliseconds == 0) {
      isPlaying = true;
    }
    if (_isDisposed) {
      return;
    }

    Duration? positionToSeek = position;
    if (position! > value.duration!) {
      positionToSeek = value.duration;
    } else if (position < const Duration()) {
      positionToSeek = const Duration();
    }
    _seekPosition = positionToSeek;

    await _videoPlayerPlatform.seekTo(_textureId, positionToSeek);
    _updatePosition(position);

    if (isPlaying) {
      play();
    } else {
      pause();
    }
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    final double previousSpeed = value.speed;
    try {
      value = value.copyWith(speed: speed);
      await _applySpeed();
    } catch (exception) {
      value = value.copyWith(speed: previousSpeed);
      rethrow;
    }
  }

  // 设置视频轨道参数
  Future<void> setTrackParameters(int? width, int? height, int? bitrate) async {
    await _videoPlayerPlatform.setTrackParameters(
        _textureId, width, height, bitrate);
  }

  // 启用画中画模式
  Future<void> enablePictureInPicture(
      {double? top, double? left, double? width, double? height}) async {
    await _videoPlayerPlatform.enablePictureInPicture(
        textureId, top, left, width, height);
  }

  // 禁用画中画模式
  Future<void> disablePictureInPicture() async {
    await _videoPlayerPlatform.disablePictureInPicture(textureId);
  }

  // 更新播放位置
  void _updatePosition(Duration? position, {DateTime? absolutePosition}) {
    value = value.copyWith(position: _seekPosition ?? position);
    if (_seekPosition == null) {
      value = value.copyWith(absolutePosition: absolutePosition);
    }
  }

  // 检查是否支持画中画
  Future<bool?> isPictureInPictureSupported() async {
    if (_textureId == null) {
      return false;
    }
    return _videoPlayerPlatform.isPictureInPictureEnabled(_textureId);
  }

  // 刷新状态
  void refresh() {
    value = value.copyWith();
  }

  // 设置音频轨道
  void setAudioTrack(String? name, int? index) {
    _videoPlayerPlatform.setAudioTrack(_textureId, name, index);
  }

  // 设置与其他音频混合
  void setMixWithOthers(bool mixWithOthers) {
    _videoPlayerPlatform.setMixWithOthers(_textureId, mixWithOthers);
  }

  // 清除缓存
  static Future clearCache() async {
    return _videoPlayerPlatform.clearCache();
  }

  // 预缓存数据源
  static Future preCache(DataSource dataSource, int preCacheSize) async {
    return _videoPlayerPlatform.preCache(dataSource, preCacheSize);
  }

  // 停止预缓存
  static Future stopPreCache(String url, String? cacheKey) async {
    return _videoPlayerPlatform.stopPreCache(url, cacheKey);
  }
}

// 显示视频的 UI 组件
class VideoPlayer extends StatefulWidget {
  // 使用指定控制器渲染视频
  const VideoPlayer(this.controller, {Key? key}) : super(key: key);

  // 视频控制器
  final VideoPlayerController? controller;

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

// 管理视频播放状态
class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState() {
    _listener = () {
      final int? newTextureId = widget.controller!.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  // 状态监听器
  late VoidCallback _listener;
  // 纹理 ID
  int? _textureId;

  // 初始化状态
  @override
  void initState() {
    super.initState();
    _textureId = widget.controller!.textureId;
    widget.controller!.addListener(_listener);
  }

  // 更新控件
  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller!.removeListener(_listener);
    _textureId = widget.controller!.textureId;
    widget.controller!.addListener(_listener);
  }

  // 停用控件
  @override
  void deactivate() {
    super.deactivate();
    widget.controller!.removeListener(_listener);
  }

  // 渲染视频纹理
  @override
  Widget build(BuildContext context) {
    return _textureId == null
        ? Container()
        : _videoPlayerPlatform.buildView(_textureId);
  }
}

// 配置视频进度条颜色
class VideoProgressColors {
  // 构造进度条颜色配置
  VideoProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  // 已播放部分的颜色
  final Color playedColor;

  // 已缓冲部分的颜色
  final Color bufferedColor;

  // 背景颜色
  final Color backgroundColor;
}

// 处理视频进度条交互
class _VideoScrubber extends StatefulWidget {
  const _VideoScrubber({
    required this.child,
    required this.controller,
  });

  // 子控件
  final Widget child;
  // 视频控制器
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

// 管理进度条交互状态
class _VideoScrubberState extends State<_VideoScrubber> {
  // 是否正在播放
  bool _controllerWasPlaying = false;

  // 获取控制器
  VideoPlayerController get controller => widget.controller;

  // 根据位置跳转视频
  void seekToRelativePosition(Offset globalPosition) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject != null) {
      final RenderBox box = renderObject as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration! * relative;
      controller.seekTo(position);
    }
  }

  // 构建交互控件
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      child: widget.child,
    );
  }
}

// 显示视频播放和缓冲进度
class VideoProgressIndicator extends StatefulWidget {
  // 构造进度条
  VideoProgressIndicator(
    this.controller, {
    VideoProgressColors? colors,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
    Key? key,
  })  : colors = colors ?? VideoProgressColors(),
        super(key: key);

  // 视频控制器
  final VideoPlayerController controller;

  // 进度条颜色配置
  final VideoProgressColors colors;

  // 是否允许拖动
  final bool? allowScrubbing;

  // 进度条内边距
  final EdgeInsets padding;

  @override
  _VideoProgressIndicatorState createState() => _VideoProgressIndicatorState();
}

// 管理进度条状态
class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  // 状态监听器
  late VoidCallback listener;

  // 获取控制器
  VideoPlayerController get controller => widget.controller;

  // 获取颜色配置
  VideoProgressColors get colors => widget.colors;

  // 初始化状态
  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  // 停用控件
  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  // 渲染进度条
  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.initialized) {
      final int duration = controller.value.duration!.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      // 优化：使用更高效的算法查找最大缓冲值
      int maxBuffering = 0;
      if (controller.value.buffered.isNotEmpty) {
        // 大多数情况下，缓冲区是有序的，最后一个就是最大的
        maxBuffering = controller.value.buffered.last.end.inMilliseconds;
        // 但为了保险起见，还是遍历一遍
        for (final DurationRange range in controller.value.buffered) {
          final int end = range.end.inMilliseconds;
          if (end > maxBuffering) {
            maxBuffering = end;
          }
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing!) {
      return _VideoScrubber(
        controller: controller,
        child: paddedProgressIndicator,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}

// 显示视频字幕
class ClosedCaption extends StatelessWidget {
  // 构造字幕组件
  const ClosedCaption({Key? key, this.text, this.textStyle}) : super(key: key);

  // 字幕文本
  final String? text;

  // 字幕样式
  final TextStyle? textStyle;

  // 渲染字幕文本
  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveTextStyle = textStyle ??
        DefaultTextStyle.of(context).style.copyWith(
              fontSize: 36.0,
              color: Colors.white,
            );

    if (text == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xB8000000),
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(text!, style: effectiveTextStyle),
          ),
        ),
      ),
    );
  }
}
