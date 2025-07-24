import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:path_provider/path_provider.dart';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/configuration/iapp_player_controller_event.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitle.dart';
import 'package:iapp_player/src/subtitles/iapp_player_subtitles_factory.dart';
import 'package:iapp_player/src/video_player/video_player.dart';
import 'package:iapp_player/src/video_player/video_player_platform_interface.dart';

// 视频播放控制器，管理播放状态、数据源、字幕和事件
class IAppPlayerController {
  static const String _durationParameter = "duration"; // 持续时间参数
  static const String _progressParameter = "progress"; // 进度参数
  static const String _bufferedParameter = "buffered"; // 缓冲参数
  static const String _volumeParameter = "volume"; // 音量参数
  static const String _speedParameter = "speed"; // 速度参数
  static const String _dataSourceParameter = "dataSource"; // 数据源参数
  static const String _authorizationHeader = "Authorization"; // 授权头

  // 播放器配置
  final IAppPlayerConfiguration iappPlayerConfiguration;

  // 播放列表配置
  final IAppPlayerPlaylistConfiguration? iappPlayerPlaylistConfiguration;

  // 播放列表控制器
  IAppPlayerPlaylistController? _playlistController;

  // 设置播放列表控制器
  set playlistController(IAppPlayerPlaylistController? controller) {
    _playlistController = controller;
  }

  // 事件监听器列表
  final List<Function(IAppPlayerEvent)?> _eventListeners = [];

  // 临时文件列表
  final List<File> _tempFiles = [];

  // 控件显示状态流控制器
  final StreamController<bool> _controlsVisibilityStreamController =
      StreamController.broadcast();

  // 视频播放器控制器
  VideoPlayerController? videoPlayerController;

  // 控件配置
  late IAppPlayerControlsConfiguration _iappPlayerControlsConfiguration;

  // 获取控件配置
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration =>
      _iappPlayerControlsConfiguration;

  // 获取事件监听器
  List<Function(IAppPlayerEvent)?> get eventListeners =>
      _eventListeners.sublist(1);

  // 获取全局事件监听器
  Function(IAppPlayerEvent)? get eventListener =>
      iappPlayerConfiguration.eventListener;

  // 全屏模式状态
  bool _isFullScreen = false;

  // 获取全屏状态
  bool get isFullScreen => _isFullScreen;

  // 上次进度事件时间
  int _lastPositionSelection = 0;

  // 当前数据源
  IAppPlayerDataSource? _iappPlayerDataSource;

  // 获取当前数据源
  IAppPlayerDataSource? get iappPlayerDataSource => _iappPlayerDataSource;

  // 字幕源列表
  final List<IAppPlayerSubtitlesSource> _iappPlayerSubtitlesSourceList = [];

  // 获取字幕源列表
  List<IAppPlayerSubtitlesSource> get iappPlayerSubtitlesSourceList =>
      _iappPlayerSubtitlesSourceList;
  IAppPlayerSubtitlesSource? _iappPlayerSubtitlesSource;

  // 当前字幕源
  IAppPlayerSubtitlesSource? get iappPlayerSubtitlesSource =>
      _iappPlayerSubtitlesSource;

  // 当前字幕行
  List<IAppPlayerSubtitle> subtitlesLines = [];

  // HLS/DASH 轨道列表
  List<IAppPlayerAsmsTrack> _iappPlayerAsmsTracks = [];

  // 获取轨道列表
  List<IAppPlayerAsmsTrack> get iappPlayerAsmsTracks => _iappPlayerAsmsTracks;

  // 当前轨道
  IAppPlayerAsmsTrack? _iappPlayerAsmsTrack;

  // 获取当前轨道
  IAppPlayerAsmsTrack? get iappPlayerAsmsTrack => _iappPlayerAsmsTrack;

  // 下一视频定时器
  Timer? _nextVideoTimer;

  // 获取播放列表控制器
  IAppPlayerPlaylistController? get playlistController => _playlistController;

  // 下一视频剩余时间
  int? _nextVideoTime;

  // 下一视频时间流控制器
  final StreamController<int?> _nextVideoTimeStreamController =
      StreamController.broadcast();

  // 下一视频时间流
  Stream<int?> get nextVideoTimeStream => _nextVideoTimeStreamController.stream;

  // 控制器是否销毁
  bool _disposed = false;

  // 获取销毁状态
  bool get isDisposed => _disposed;

  // 暂停前播放状态
  bool? _wasPlayingBeforePause;

  // 翻译配置
  IAppPlayerTranslations translations = IAppPlayerTranslations();

  // 数据源启动状态
  bool _hasCurrentDataSourceStarted = false;

  // 数据源初始化状态
  bool _hasCurrentDataSourceInitialized = false;

  // 控件显示状态流
  Stream<bool> get controlsVisibilityStream =>
      _controlsVisibilityStreamController.stream;

  // 应用生命周期状态
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  // 控件启用状态
  bool _controlsEnabled = true;

  // 获取控件启用状态
  bool get controlsEnabled => _controlsEnabled;

  // 覆盖宽高比
  double? _overriddenAspectRatio;

  // 覆盖适配模式
  BoxFit? _overriddenFit;

  // 画中画模式状态
  bool _wasInPipMode = false;

  // 画中画前全屏状态
  bool _wasInFullScreenBeforePiP = false;

  // 画中画前控件状态
  bool _wasControlsEnabledBeforePiP = false;
  
  // 画中画退出原因
  String? _lastPipExitReason;
  
  // 画中画状态标志
  bool _isReturningFromPip = false;

  // 公开画中画返回状态，供IAppPlayer使用
  bool get isReturningFromPip => _isReturningFromPip;

  // 全局键
  GlobalKey? _iappPlayerGlobalKey;

  // 获取全局键
  GlobalKey? get iappPlayerGlobalKey => _iappPlayerGlobalKey;

  // 视频事件流订阅
  StreamSubscription<VideoEvent>? _videoEventStreamSubscription;

  // 控件始终可见状态
  bool _controlsAlwaysVisible = false;

  // 获取控件始终可见状态
  bool get controlsAlwaysVisible => _controlsAlwaysVisible;

  // ASMS 音频轨道列表
  List<IAppPlayerAsmsAudioTrack>? _iappPlayerAsmsAudioTracks;

  // 获取音频轨道列表
  List<IAppPlayerAsmsAudioTrack>? get iappPlayerAsmsAudioTracks =>
      _iappPlayerAsmsAudioTracks;

  // 当前音频轨道
  IAppPlayerAsmsAudioTrack? _iappPlayerAsmsAudioTrack;

  // 获取当前音频轨道
  IAppPlayerAsmsAudioTrack? get iappPlayerAsmsAudioTrack =>
      _iappPlayerAsmsAudioTrack;

  // 错误时播放器值
  VideoPlayerValue? _videoPlayerValueOnError;

  // 播放器可见性
  bool _isPlayerVisible = true;

  // 内部事件流控制器
  final StreamController<IAppPlayerControllerEvent>
      _controllerEventStreamController = StreamController.broadcast();

  // 内部事件流
  Stream<IAppPlayerControllerEvent> get controllerEventStream =>
      _controllerEventStreamController.stream;

  // ASMS 字幕段加载状态
  bool _asmsSegmentsLoading = false;

  // 已加载的 ASMS 字幕段
  final Set<String> _asmsSegmentsLoaded = {};

  // 当前显示字幕
  IAppPlayerSubtitle? renderedSubtitle;

  // 缓存播放器值
  VideoPlayerValue? _lastVideoPlayerValue;

  // 缓冲防抖定时器
  Timer? _bufferingDebounceTimer;

  // 当前缓冲状态
  bool _isCurrentlyBuffering = false;

  // 上次缓冲状态变更时间
  DateTime? _lastBufferingChangeTime;

  // 缓冲防抖时间（毫秒）
  int _bufferingDebounceMs = 500;

  // 播放列表随机模式
  bool _playlistShuffleMode = false;

  // 获取随机模式状态
  bool get playlistShuffleMode => _playlistShuffleMode;

  // 直播流检测缓存
  bool? _cachedIsLiveStream;

  // 字幕段缓存
  List<IAppPlayerAsmsSubtitleSegment>? _pendingSubtitleSegments;

  // 上次字幕检查位置
  Duration? _lastSubtitleCheckPosition;

  // 字幕滑动窗口配置
  static const int _subtitleWindowSize = 300; // 保留前后300条字幕
  static const Duration _subtitleWindowDuration = Duration(minutes: 10); // 保留前后10分钟的字幕

  // 构造函数，初始化配置和数据源
  IAppPlayerController(
    this.iappPlayerConfiguration, {
    this.iappPlayerPlaylistConfiguration,
    IAppPlayerDataSource? iappPlayerDataSource,
  }) {
    this._iappPlayerControlsConfiguration =
        iappPlayerConfiguration.controlsConfiguration;
    _eventListeners.add(eventListener);
    if (iappPlayerDataSource != null) {
      setupDataSource(iappPlayerDataSource);
    }
  }

  // 从上下文获取控制器
  static IAppPlayerController of(BuildContext context) {
    final betterPLayerControllerProvider = context
        .dependOnInheritedWidgetOfExactType<IAppPlayerControllerProvider>()!;

    return betterPLayerControllerProvider.controller;
  }

  // 设置数据源并初始化
  Future setupDataSource(IAppPlayerDataSource iappPlayerDataSource) async {
    // 清理旧的临时文件，避免文件累积
    await _clearTempFiles();
    
    postEvent(IAppPlayerEvent(IAppPlayerEventType.setupDataSource,
        parameters: <String, dynamic>{
          _dataSourceParameter: iappPlayerDataSource,
        }));
    _postControllerEvent(IAppPlayerControllerEvent.setupDataSource);
    _hasCurrentDataSourceStarted = false;
    _hasCurrentDataSourceInitialized = false;
    _iappPlayerDataSource = iappPlayerDataSource;
    _iappPlayerSubtitlesSourceList.clear();
    _clearBufferingState();
    _cachedIsLiveStream = null;
    _pendingSubtitleSegments = null;
    _lastSubtitleCheckPosition = null;

    if (videoPlayerController == null) {
      videoPlayerController = VideoPlayerController(
          bufferingConfiguration:
              iappPlayerDataSource.bufferingConfiguration);
      videoPlayerController?.addListener(_onVideoPlayerChanged);
    }

    iappPlayerAsmsTracks.clear();

    final List<IAppPlayerSubtitlesSource>? iappPlayerSubtitlesSourceList =
        iappPlayerDataSource.subtitles;
    if (iappPlayerSubtitlesSourceList != null) {
      _iappPlayerSubtitlesSourceList
          .addAll(iappPlayerDataSource.subtitles!);
    }

    if (_isDataSourceAsms(iappPlayerDataSource)) {
      _setupAsmsDataSource(iappPlayerDataSource).then((dynamic value) {
        _setupSubtitles();
      });
    } else {
      _setupSubtitles();
    }

    await _setupDataSource(iappPlayerDataSource);
    setTrack(IAppPlayerAsmsTrack.defaultTrack());
  }

  // 清理临时文件
  Future<void> _clearTempFiles() async {
    for (final file in _tempFiles) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        IAppPlayerUtils.log("删除临时文件失败: $e");
      }
    }
    _tempFiles.clear();
  }

  // 配置字幕源
  void _setupSubtitles() {
    _iappPlayerSubtitlesSourceList.add(
      IAppPlayerSubtitlesSource(type: IAppPlayerSubtitlesSourceType.none),
    );
    final defaultSubtitle = _iappPlayerSubtitlesSourceList
        .firstWhereOrNull((element) => element.selectedByDefault == true);

    setupSubtitleSource(
        defaultSubtitle ?? _iappPlayerSubtitlesSourceList.last,
        sourceInitialize: true);
  }

  // 检查是否为 HLS/DASH 数据源
  bool _isDataSourceAsms(IAppPlayerDataSource iappPlayerDataSource) =>
      (IAppPlayerAsmsUtils.isDataSourceHls(iappPlayerDataSource.url) ||
          iappPlayerDataSource.videoFormat == IAppPlayerVideoFormat.hls) ||
      (IAppPlayerAsmsUtils.isDataSourceDash(iappPlayerDataSource.url) ||
          iappPlayerDataSource.videoFormat == IAppPlayerVideoFormat.dash);

  // 配置 HLS/DASH 数据源
  Future _setupAsmsDataSource(IAppPlayerDataSource source) async {
    final String? data = await IAppPlayerAsmsUtils.getDataFromUrl(
      iappPlayerDataSource!.url,
      _getHeaders(),
    );
    if (data != null) {
      final IAppPlayerAsmsDataHolder _response =
          await IAppPlayerAsmsUtils.parse(data, iappPlayerDataSource!.url);

      if (_iappPlayerDataSource?.useAsmsTracks == true) {
        _iappPlayerAsmsTracks = _response.tracks ?? [];
      }

      if (iappPlayerDataSource?.useAsmsSubtitles == true) {
        final List<IAppPlayerAsmsSubtitle> asmsSubtitles =
            _response.subtitles ?? [];
        asmsSubtitles.forEach((IAppPlayerAsmsSubtitle asmsSubtitle) {
          _iappPlayerSubtitlesSourceList.add(
            IAppPlayerSubtitlesSource(
              type: IAppPlayerSubtitlesSourceType.network,
              name: asmsSubtitle.name,
              urls: asmsSubtitle.realUrls,
              asmsIsSegmented: asmsSubtitle.isSegmented,
              asmsSegmentsTime: asmsSubtitle.segmentsTime,
              asmsSegments: asmsSubtitle.segments,
              selectedByDefault: asmsSubtitle.isDefault,
            ),
          );
        });
      }

      if (iappPlayerDataSource?.useAsmsAudioTracks == true &&
          _isDataSourceAsms(iappPlayerDataSource!)) {
        _iappPlayerAsmsAudioTracks = _response.audios ?? [];
        if (_iappPlayerAsmsAudioTracks?.isNotEmpty == true) {
          setAudioTrack(_iappPlayerAsmsAudioTracks!.first);
        }
      }
    }
  }

  // 设置字幕源并加载
  Future<void> setupSubtitleSource(IAppPlayerSubtitlesSource subtitlesSource,
      {bool sourceInitialize = false}) async {
    _iappPlayerSubtitlesSource = subtitlesSource;
    subtitlesLines.clear();
    _asmsSegmentsLoaded.clear();
    _asmsSegmentsLoading = false;
    _pendingSubtitleSegments = null;
    _lastSubtitleCheckPosition = null;

    if (subtitlesSource.type != IAppPlayerSubtitlesSourceType.none) {
      if (subtitlesSource.asmsIsSegmented == true) {
        return;
      }
      try {
        // 字幕解析失败不影响播放
        final subtitlesParsed =
            await IAppPlayerSubtitlesFactory.parseSubtitles(subtitlesSource);
        subtitlesLines.addAll(subtitlesParsed);
      } catch (e) {
        IAppPlayerUtils.log("字幕加载失败: $e");
      }
    }

    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedSubtitles));
    if (!_disposed && !sourceInitialize) {
      _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles);
    }
  }

  // 加载 ASMS 字幕段
  Future _loadAsmsSubtitlesSegments(Duration position) async {
    try {
      if (_asmsSegmentsLoading) {
        return;
      }

      if (_lastSubtitleCheckPosition != null) {
        final positionDiff =
            (position.inMilliseconds - _lastSubtitleCheckPosition!.inMilliseconds)
                .abs();
        if (positionDiff < 1000) {
          return;
        }
      }
      _lastSubtitleCheckPosition = position;

      _asmsSegmentsLoading = true;
      final IAppPlayerSubtitlesSource? source = _iappPlayerSubtitlesSource;
      final Duration loadDurationEnd = Duration(
          milliseconds: position.inMilliseconds +
              5 * (_iappPlayerSubtitlesSource?.asmsSegmentsTime ?? 5000));

      if (_pendingSubtitleSegments == null) {
        _pendingSubtitleSegments = _iappPlayerSubtitlesSource?.asmsSegments
            ?.where((segment) => !_asmsSegmentsLoaded.contains(segment.realUrl))
            .toList() ?? [];
      }

      final segmentsToLoad = <String>[];
      final segmentsToRemove = <IAppPlayerAsmsSubtitleSegment>[];

      for (final segment in _pendingSubtitleSegments!) {
        if (segment.startTime > position && segment.endTime < loadDurationEnd) {
          segmentsToLoad.add(segment.realUrl);
          segmentsToRemove.add(segment);
        }
      }

      if (segmentsToRemove.isNotEmpty) {
        _pendingSubtitleSegments!.removeWhere((s) => segmentsToRemove.contains(s));
      }

      if (segmentsToLoad.isNotEmpty) {
        final subtitlesParsed =
            await IAppPlayerSubtitlesFactory.parseSubtitles(
                IAppPlayerSubtitlesSource(
          type: _iappPlayerSubtitlesSource!.type,
          headers: _iappPlayerSubtitlesSource!.headers,
          urls: segmentsToLoad,
        ));

        if (source == _iappPlayerSubtitlesSource) {
          subtitlesLines.addAll(subtitlesParsed);
          _asmsSegmentsLoaded.addAll(segmentsToLoad);
          
          // 实施字幕滑动窗口，清理过期字幕
          _cleanupOldSubtitles(position);
        }
      }
      _asmsSegmentsLoading = false;
    } catch (exception) {
      IAppPlayerUtils.log("加载 ASMS 字幕段失败: $exception");
    }
  }

  // 清理过期字幕（滑动窗口机制）
  void _cleanupOldSubtitles(Duration currentPosition) {
    if (subtitlesLines.length <= _subtitleWindowSize) {
      return;
    }

    final minTime = currentPosition - _subtitleWindowDuration;
    final maxTime = currentPosition + _subtitleWindowDuration;

    // 保留时间窗口内的字幕
    subtitlesLines.removeWhere((subtitle) {
      final startTime = subtitle.start;
      final endTime = subtitle.end;
      return endTime != null && 
             (endTime < minTime || (startTime != null && startTime > maxTime));
    });

    // 如果仍然超过数量限制，保留最近的字幕
    if (subtitlesLines.length > _subtitleWindowSize) {
      // 按时间排序
      subtitlesLines.sort((a, b) {
        final aStart = a.start?.inMilliseconds ?? 0;
        final bStart = b.start?.inMilliseconds ?? 0;
        return aStart.compareTo(bStart);
      });

      // 找到当前位置在列表中的索引
      int currentIndex = 0;
      for (int i = 0; i < subtitlesLines.length; i++) {
        if (subtitlesLines[i].start != null && 
            subtitlesLines[i].start!.inMilliseconds > currentPosition.inMilliseconds) {
          currentIndex = i;
          break;
        }
      }

      // 计算保留范围
      final halfWindow = _subtitleWindowSize ~/ 2;
      final startIndex = (currentIndex - halfWindow).clamp(0, subtitlesLines.length);
      final endIndex = (currentIndex + halfWindow).clamp(0, subtitlesLines.length);

      // 保留窗口内的字幕
      subtitlesLines = subtitlesLines.sublist(startIndex, endIndex);
    }
  }

  // 获取视频格式
  VideoFormat? _getVideoFormat(IAppPlayerVideoFormat? iappPlayerVideoFormat) {
    if (iappPlayerVideoFormat == null) {
      return null;
    }
    switch (iappPlayerVideoFormat) {
      case IAppPlayerVideoFormat.dash:
        return VideoFormat.dash;
      case IAppPlayerVideoFormat.hls:
        return VideoFormat.hls;
      case IAppPlayerVideoFormat.ss:
        return VideoFormat.ss;
      case IAppPlayerVideoFormat.other:
        return VideoFormat.other;
    }
  }

  // 判断是否为Flutter asset路径
  bool _isAssetPath(String path) {
    return path.startsWith('assets/') || path.startsWith('asset://');
  }

  // 从asset创建临时文件
  Future<File> _createFileFromAsset(String assetPath) async {
    try {
      // 移除可能的 asset:// 前缀
      final cleanPath = assetPath.startsWith('asset://') 
          ? assetPath.substring(8) 
          : assetPath;
      
      // 从asset读取文件数据
      final ByteData data = await rootBundle.load(cleanPath);
      final List<int> bytes = data.buffer.asUint8List();
      
      // 获取文件扩展名
      final String extension = cleanPath.split('.').last;
      
      // 创建临时文件
      final tempFile = await _createFile(bytes, extension: extension);
      return tempFile;
    } catch (e) {
      throw Exception('无法从asset加载文件: $assetPath, 错误: $e');
    }
  }

  // 设置数据源
  Future _setupDataSource(IAppPlayerDataSource iappPlayerDataSource) async {
    switch (iappPlayerDataSource.type) {
      case IAppPlayerDataSourceType.network:
        await videoPlayerController?.setNetworkDataSource(
          iappPlayerDataSource.url,
          headers: _getHeaders(),
          useCache:
              _iappPlayerDataSource!.cacheConfiguration?.useCache ?? false,
          maxCacheSize:
              _iappPlayerDataSource!.cacheConfiguration?.maxCacheSize ?? 0,
          maxCacheFileSize:
              _iappPlayerDataSource!.cacheConfiguration?.maxCacheFileSize ??
                  0,
          cacheKey: _iappPlayerDataSource?.cacheConfiguration?.key,
          showNotification: _iappPlayerDataSource
              ?.notificationConfiguration?.showNotification,
          title: _iappPlayerDataSource?.notificationConfiguration?.title,
          author: _iappPlayerDataSource?.notificationConfiguration?.author,
          imageUrl:
              _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
          notificationChannelName: _iappPlayerDataSource
              ?.notificationConfiguration?.notificationChannelName,
          overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
          formatHint: _getVideoFormat(_iappPlayerDataSource!.videoFormat),
          licenseUrl: _iappPlayerDataSource?.drmConfiguration?.licenseUrl,
          certificateUrl:
              _iappPlayerDataSource?.drmConfiguration?.certificateUrl,
          drmHeaders: _iappPlayerDataSource?.drmConfiguration?.headers,
          activityName:
              _iappPlayerDataSource?.notificationConfiguration?.activityName,
          clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey,
          videoExtension: _iappPlayerDataSource!.videoExtension,
          preferredDecoderType: _iappPlayerDataSource?.preferredDecoderType,
        );

        break;
      case IAppPlayerDataSourceType.file:
        // 检查是否为asset路径
        if (_isAssetPath(iappPlayerDataSource.url)) {
          // 处理Flutter asset路径
          IAppPlayerUtils.log(
              "检测到asset路径: ${iappPlayerDataSource.url}，将从asset加载");
          
          // 从asset创建临时文件
          final tempFile = await _createFileFromAsset(iappPlayerDataSource.url);
          _tempFiles.add(tempFile);
          
          // 使用临时文件播放
          await videoPlayerController?.setFileDataSource(
              tempFile,
              showNotification: _iappPlayerDataSource
                  ?.notificationConfiguration?.showNotification,
              title: _iappPlayerDataSource?.notificationConfiguration?.title,
              author: _iappPlayerDataSource?.notificationConfiguration?.author,
              imageUrl:
                  _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
              notificationChannelName: _iappPlayerDataSource
                  ?.notificationConfiguration?.notificationChannelName,
              overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
              activityName: _iappPlayerDataSource
                  ?.notificationConfiguration?.activityName,
              clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey);
        } else {
          // 处理普通文件系统路径
          final file = File(iappPlayerDataSource.url);

          await videoPlayerController?.setFileDataSource(
              file,
              showNotification: _iappPlayerDataSource
                  ?.notificationConfiguration?.showNotification,
              title: _iappPlayerDataSource?.notificationConfiguration?.title,
              author: _iappPlayerDataSource?.notificationConfiguration?.author,
              imageUrl:
                  _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
              notificationChannelName: _iappPlayerDataSource
                  ?.notificationConfiguration?.notificationChannelName,
              overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
              activityName: _iappPlayerDataSource
                  ?.notificationConfiguration?.activityName,
              clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey);
        }
        break;
      case IAppPlayerDataSourceType.memory:
        final file = await _createFile(_iappPlayerDataSource!.bytes!,
            extension: _iappPlayerDataSource!.videoExtension);

        if (file.existsSync()) {
          await videoPlayerController?.setFileDataSource(file,
              showNotification: _iappPlayerDataSource
                  ?.notificationConfiguration?.showNotification,
              title: _iappPlayerDataSource?.notificationConfiguration?.title,
              author:
                  _iappPlayerDataSource?.notificationConfiguration?.author,
              imageUrl:
                  _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
              notificationChannelName: _iappPlayerDataSource
                  ?.notificationConfiguration?.notificationChannelName,
              overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
              activityName: _iappPlayerDataSource
                  ?.notificationConfiguration?.activityName,
              clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey);
          _tempFiles.add(file);
        } else {
          throw ArgumentError("无法从内存创建文件");
        }
        break;

      default:
        throw UnimplementedError(
            "${iappPlayerDataSource.type} 未实现");
    }
    await _initializeVideo();
  }

  // 创建临时文件
  Future<File> _createFile(List<int> bytes,
      {String? extension = "temp"}) async {
    final String dir = (await getTemporaryDirectory()).path;
    final File temp = File(
        '$dir/iapp_player_${DateTime.now().millisecondsSinceEpoch}.$extension');
    await temp.writeAsBytes(bytes);
    return temp;
  }

  // 初始化视频
  Future _initializeVideo() async {
    // 播放列表模式下始终禁用循环
    if (isPlaylistMode) {
      setLooping(false);
    } else {
      setLooping(iappPlayerConfiguration.looping);
    }
    _videoEventStreamSubscription?.cancel();
    _videoEventStreamSubscription = null;

    _videoEventStreamSubscription = videoPlayerController
        ?.videoEventStreamController.stream
        .listen(_handleVideoEvent);

    final fullScreenByDefault = iappPlayerConfiguration.fullScreenByDefault;
    // 播放列表模式下，切换视频总是自动播放
    final shouldAutoPlay = iappPlayerConfiguration.autoPlay || (iappPlayerPlaylistConfiguration != null);
    
    if (shouldAutoPlay) {
      if (fullScreenByDefault && !isFullScreen) {
        enterFullScreen();
      }
      if (_isAutomaticPlayPauseHandled()) {
        if (_appLifecycleState == AppLifecycleState.resumed &&
            _isPlayerVisible) {
          await play();
        } else {
          _wasPlayingBeforePause = true;
        }
      } else {
        await play();
      }
    } else {
      if (fullScreenByDefault) {
        enterFullScreen();
      }
    }

    final startAt = iappPlayerConfiguration.startAt;
    if (startAt != null) {
      seekTo(startAt);
    }
  }

  // 处理全屏状态变化
  Future<void> _onFullScreenStateChanged() async {
    if (videoPlayerController?.value.isPlaying == true && !_isFullScreen) {
      enterFullScreen();
      videoPlayerController?.removeListener(_onFullScreenStateChanged);
    }
  }

  // 进入全屏模式
  void enterFullScreen() {
    // 如果正在画中画模式，不允许进入全屏
    if (videoPlayerController?.value.isPip == true) {
      IAppPlayerUtils.log("画中画模式下不允许进入全屏");
      return;
    }
    
    // 如果刚从画中画返回，阻止全屏
    if (isReturningFromPip) {
      IAppPlayerUtils.log("画中画返回保护期内，暂时阻止全屏");
      return;
    }
    
    _isFullScreen = true;
    _postControllerEvent(IAppPlayerControllerEvent.openFullscreen);
  }

  // 退出全屏模式
  void exitFullScreen() {
    _isFullScreen = false;
    _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen);
  }

  // 切换全屏模式
  void toggleFullScreen() {
    // 如果正在画中画模式，不允许进入全屏
    if (videoPlayerController?.value.isPip == true) {
      IAppPlayerUtils.log("画中画模式下不允许进入全屏");
      return;
    }
    
    // 如果刚从画中画返回，阻止全屏
    if (isReturningFromPip) {
      IAppPlayerUtils.log("画中画返回保护期内，暂时阻止全屏");
      return;
    }
    
    _isFullScreen = !_isFullScreen;
    if (_isFullScreen) {
      _postControllerEvent(IAppPlayerControllerEvent.openFullscreen);
    } else {
      _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen);
    }
  }

  // 播放视频
  Future<void> play() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    if (_appLifecycleState == AppLifecycleState.resumed) {
      await videoPlayerController!.play();
      _hasCurrentDataSourceStarted = true;
      _wasPlayingBeforePause = null;
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.play));
      _postControllerEvent(IAppPlayerControllerEvent.play);
    }
  }

  // 设置循环播放
  Future<void> setLooping(bool looping) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    await videoPlayerController!.setLooping(looping);
  }

  // 暂停视频
  Future<void> pause() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    await videoPlayerController!.pause();
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.pause));
  }

  // 跳转到指定位置
  Future<void> seekTo(Duration moment) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    if (videoPlayerController?.value.duration == null) {
      throw StateError("视频未初始化");
    }

    await videoPlayerController!.seekTo(moment);

    _postEvent(IAppPlayerEvent(IAppPlayerEventType.seekTo,
        parameters: <String, dynamic>{_durationParameter: moment}));

    final Duration? currentDuration = videoPlayerController!.value.duration;
    if (currentDuration == null) {
      return;
    }
    if (moment > currentDuration) {
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.finished));
    } else {
      cancelNextVideoTimer();
    }
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      IAppPlayerUtils.log("音量必须在 0.0 到 1.0 之间");
      throw ArgumentError("音量必须在 0.0 到 1.0 之间");
    }
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化");
      throw StateError("数据源未初始化");
    }
    await videoPlayerController!.setVolume(volume);
    _postEvent(IAppPlayerEvent(
      IAppPlayerEventType.setVolume,
      parameters: <String, dynamic>{_volumeParameter: volume},
    ));
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    if (speed <= 0 || speed > 2) {
      IAppPlayerUtils.log("速度必须在 0 到 2 之间");
      throw ArgumentError("速度必须在 0 到 2 之间");
    }
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化");
      throw StateError("数据源未初始化");
    }
    await videoPlayerController?.setSpeed(speed);
    _postEvent(
      IAppPlayerEvent(
        IAppPlayerEventType.setSpeed,
        parameters: <String, dynamic>{
          _speedParameter: speed,
        },
      ),
    );
  }

  // 检查播放状态
  bool? isPlaying() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    return videoPlayerController!.value.isPlaying;
  }

  // 检查缓冲状态
  bool? isBuffering() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    return videoPlayerController!.value.isBuffering;
  }

  // 设置控件可见性
  void setControlsVisibility(bool isVisible) {
    _controlsVisibilityStreamController.add(isVisible);
  }

  // 启用/禁用控件
  void setControlsEnabled(bool enabled) {
    if (!enabled) {
      _controlsVisibilityStreamController.add(false);
    }
    _controlsEnabled = enabled;
  }

  // 触发控件显示/隐藏事件
  void toggleControlsVisibility(bool isVisible) {
    _postEvent(isVisible
        ? IAppPlayerEvent(IAppPlayerEventType.controlsVisible)
        : IAppPlayerEvent(IAppPlayerEventType.controlsHiddenEnd));
  }

  // 发送播放器事件
  void postEvent(IAppPlayerEvent iappPlayerEvent) {
    _postEvent(iappPlayerEvent);
  }

  // 广播事件
  void _postEvent(IAppPlayerEvent iappPlayerEvent) {
    if (_disposed) {
      return;
    }

    // 根据事件类型管理画中画保护状态
    switch (iappPlayerEvent.iappPlayerEventType) {
      case IAppPlayerEventType.pipStart:
        if (iappPlayerEvent.parameters?['preparing'] == true) {
          // 准备进入画中画，启用短期保护
          _isReturningFromPip = true;
          Future.delayed(Duration(milliseconds: 600), () {
            if (!_disposed) {
              _isReturningFromPip = false;
            }
          });
        }
        break;
      case IAppPlayerEventType.pipStop:
        // 退出画中画，启用保护
        _isReturningFromPip = true;
        Future.delayed(Duration(milliseconds: 2000), () {
          if (!_disposed) {
            _isReturningFromPip = false;
          }
        });
        break;
      default:
        break;
    }

    if (iappPlayerEvent.iappPlayerEventType == 
        IAppPlayerEventType.changedPlaylistShuffle) {
      _playlistShuffleMode = iappPlayerEvent.parameters?['shuffleMode'] ?? false;
      _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles);
    }

    for (final Function(IAppPlayerEvent)? eventListener in _eventListeners) {
      if (eventListener != null) {
        eventListener(iappPlayerEvent);
      }
    }
  }

  // 检查播放列表模式
  bool get isPlaylistMode => 
      iappPlayerPlaylistConfiguration != null || _playlistController != null;

  // 切换播放列表随机模式
  void togglePlaylistShuffle() {
    if (isPlaylistMode) {
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.togglePlaylistShuffle));
    }
  }

// 处理播放器状态变化
void _onVideoPlayerChanged() async {
  if (_disposed) {
    return;
  }

  final currentValue = videoPlayerController?.value;
  if (currentValue == null) {
    return;
  }

  if (_lastVideoPlayerValue != null) {
    // 检查关键值是否有变化
    final hasPositionChanged = currentValue.position != _lastVideoPlayerValue!.position;
    final hasPlayingChanged = currentValue.isPlaying != _lastVideoPlayerValue!.isPlaying;
    final hasBufferingChanged = currentValue.isBuffering != _lastVideoPlayerValue!.isBuffering;
    final hasErrorChanged = currentValue.hasError != _lastVideoPlayerValue!.hasError;
    
    // 如果没有任何变化，直接返回
    if (!hasPositionChanged && !hasPlayingChanged && !hasBufferingChanged && !hasErrorChanged) {
      return;
    }
  }

  if (currentValue.hasError && _videoPlayerValueOnError == null) {
    _videoPlayerValueOnError = currentValue;
    _postEvent(
      IAppPlayerEvent(
        IAppPlayerEventType.exception,
        parameters: <String, dynamic>{
          "exception": currentValue.errorDescription
        },
      ),
    );
  }

  if (currentValue.initialized && !_hasCurrentDataSourceInitialized) {
    _hasCurrentDataSourceInitialized = true;
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.initialized));
  }

  // 画中画状态处理
  if (currentValue.isPip) {
    _wasInPipMode = true;
  } else if (_wasInPipMode) {
    // 画中画退出处理
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipStop));
    _wasInPipMode = false;
    
    // 恢复控件状态
    if (_wasControlsEnabledBeforePiP) {
      setControlsEnabled(true);
    }
    
    // 处理全屏状态
    // 如果之前不是全屏，但当前状态显示为全屏，立即修正
    if (!_wasInFullScreenBeforePiP && _isFullScreen) {
      _isFullScreen = false;
      // 不发送全屏事件，避免UI层的处理
    }
    
    // 如果之前是全屏，需要恢复全屏状态
    if (_wasInFullScreenBeforePiP && !_isFullScreen) {
      // 延迟恢复全屏，等待画中画完全退出
      Future.delayed(Duration(milliseconds: 300), () {
        if (!_disposed && _wasInFullScreenBeforePiP) {
          _isFullScreen = true;
          _postControllerEvent(IAppPlayerControllerEvent.openFullscreen);
        }
      });
    }
    
    // 根据退出原因决定播放行为
    if (_lastPipExitReason == 'return') {
      // 点击返回按钮：保持或恢复播放状态
      if (!currentValue.isPlaying && _wasPlayingBeforePause == true) {
        // 如果之前在播放，恢复播放
        play();
      }
      // 如果正在播放，保持播放状态
    } else if (_lastPipExitReason == 'close') {
      // 点击关闭按钮：暂停播放
      pause();
      // 发送画中画关闭事件，UI层可以根据需要处理
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipClosed));
    } else {
      // 其他情况（如系统关闭）：暂停播放
      pause();
    }
    
    // 重置退出原因
    _lastPipExitReason = null;
    
    // 延迟刷新，避免立即触发状态更新
    Future.delayed(Duration(milliseconds: 100), () {
      if (!_disposed) {
        videoPlayerController?.refresh();
      }
    });
  }

  // 处理字幕加载
  if (_iappPlayerSubtitlesSource?.asmsIsSegmented == true) {
    _loadAsmsSubtitlesSegments(currentValue.position);
  }

  // 处理进度更新
  final int now = DateTime.now().millisecondsSinceEpoch;
  if (now - _lastPositionSelection > 500) {
    _lastPositionSelection = now;
    _postEvent(
      IAppPlayerEvent(
        IAppPlayerEventType.progress,
        parameters: <String, dynamic>{
          _progressParameter: currentValue.position,
          _durationParameter: currentValue.duration
        },
      ),
    );
  }

  _lastVideoPlayerValue = currentValue;
}

// 检查并退出画中画模式
Future<void> checkAndExitPictureInPicture() async {
  if (videoPlayerController?.value.isPip == true) {
    await disablePictureInPicture();
  }
}

  // 添加事件监听器
  void addEventsListener(Function(IAppPlayerEvent) eventListener) {
    // 防止重复添加相同的监听器
    if (!_eventListeners.contains(eventListener)) {
      _eventListeners.add(eventListener);
    }
  }

  // 移除事件监听器
  void removeEventsListener(Function(IAppPlayerEvent) eventListener) {
    _eventListeners.remove(eventListener);
  }

  // 检查是否为直播流
  bool isLiveStream() {
    if (_iappPlayerDataSource == null) {
      IAppPlayerUtils.log("数据源未初始化");
      throw StateError("数据源未初始化");
    }

    if (_cachedIsLiveStream != null) {
      return _cachedIsLiveStream!;
    }

    if (_iappPlayerDataSource!.liveStream == true) {
      _cachedIsLiveStream = true;
      return true;
    }

    final url = _iappPlayerDataSource!.url.toLowerCase();

    if (url.contains('rtmp://')) {
      _cachedIsLiveStream = true;
      return true;
    }

    if (url.contains('.m3u8')) {
      _cachedIsLiveStream = true;
      return true;
    }

    if (url.contains('.flv')) {
      _cachedIsLiveStream = true;
      return true;
    }

    if (url.contains('rtsp://') ||
        url.contains('mms://') ||
        url.contains('rtmps://')) {
      _cachedIsLiveStream = true;
      return true;
    }

    _cachedIsLiveStream = false;
    return false;
  }

  // 检查视频初始化状态
  bool? isVideoInitialized() {
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化");
      throw StateError("数据源未初始化");
    }
    return videoPlayerController?.value.initialized;
  }

  // 启动下一视频定时器
  void startNextVideoTimer() {
    if (_nextVideoTimer == null) {
      if (iappPlayerPlaylistConfiguration == null) {
        IAppPlayerUtils.log("播放列表配置未设置");
        throw StateError("播放列表配置未设置");
      }

      _nextVideoTime =
          iappPlayerPlaylistConfiguration!.nextVideoDelay.inSeconds;
      _nextVideoTimeStreamController.add(_nextVideoTime);
      if (_nextVideoTime == 0) {
        return;
      }

      _nextVideoTimer =
          Timer.periodic(const Duration(milliseconds: 1000), (_timer) async {
        if (_nextVideoTime == 1) {
          _timer.cancel();
          _nextVideoTimer = null;
        }
        if (_nextVideoTime != null) {
          _nextVideoTime = _nextVideoTime! - 1;
        }
        _nextVideoTimeStreamController.add(_nextVideoTime);
      });
    }
  }

  // 取消下一视频定时器
  void cancelNextVideoTimer() {
    _nextVideoTime = null;
    _nextVideoTimeStreamController.add(_nextVideoTime);
    _nextVideoTimer?.cancel();
    _nextVideoTimer = null;
  }

  // 播放下一视频
  void playNextVideo() {
    _nextVideoTime = 0;
    _nextVideoTimeStreamController.add(_nextVideoTime);
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedPlaylistItem));
    cancelNextVideoTimer();
  }

  // 设置轨道
  void setTrack(IAppPlayerAsmsTrack track) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedTrack,
        parameters: <String, dynamic>{
          "id": track.id,
          "width": track.width,
          "height": track.height,
          "bitrate": track.bitrate,
          "frameRate": track.frameRate,
          "codecs": track.codecs,
          "mimeType": track.mimeType,
        }));

    videoPlayerController!
        .setTrackParameters(track.width, track.height, track.bitrate);
    _iappPlayerAsmsTrack = track;
  }

  // 检查自动播放/暂停支持
  bool _isAutomaticPlayPauseHandled() {
    return !(_iappPlayerDataSource
                ?.notificationConfiguration?.showNotification ==
            true) &&
        iappPlayerConfiguration.handleLifecycle;
  }

  // 处理可见性变化
  void onPlayerVisibilityChanged(double visibilityFraction) async {
    _isPlayerVisible = visibilityFraction > 0;
    if (_disposed) {
      return;
    }
    _postEvent(
        IAppPlayerEvent(IAppPlayerEventType.changedPlayerVisibility));

    if (_isAutomaticPlayPauseHandled()) {
      if (iappPlayerConfiguration.playerVisibilityChangedBehavior != null) {
        iappPlayerConfiguration
            .playerVisibilityChangedBehavior!(visibilityFraction);
      } else {
        if (visibilityFraction == 0) {
          _wasPlayingBeforePause ??= isPlaying();
          pause();
        } else {
          if (_wasPlayingBeforePause == true && !isPlaying()!) {
            play();
          }
        }
      }
    }
  }

  // 设置分辨率
  void setResolution(String url) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    final position = await videoPlayerController!.position;
    final wasPlayingBeforeChange = isPlaying()!;
    pause();
    await setupDataSource(iappPlayerDataSource!.copyWith(url: url));
    seekTo(position!);
    if (wasPlayingBeforeChange) {
      play();
    }
    _postEvent(IAppPlayerEvent(
      IAppPlayerEventType.changedResolution,
      parameters: <String, dynamic>{"url": url},
    ));
  }

  // 设置翻译
  void setupTranslations(Locale locale) {
    // ignore: unnecessary_null_comparison
    if (locale != null) {
      final String languageCode = locale.languageCode;
      translations = iappPlayerConfiguration.translations?.firstWhereOrNull(
              (translations) => translations.languageCode == languageCode) ??
          _getDefaultTranslations(locale);
    } else {
      IAppPlayerUtils.log("语言环境为空，无法设置翻译");
    }
  }

  // 获取默认翻译
  IAppPlayerTranslations _getDefaultTranslations(Locale locale) {
    final String languageCode = locale.languageCode;
    final String? scriptCode = locale.scriptCode;
    final String? countryCode = locale.countryCode;

    if (languageCode == "zh") {
      if (scriptCode == "Hant" ||
          (countryCode != null &&
              (countryCode == "TW" ||
                  countryCode == "HK" ||
                  countryCode == "MO"))) {
        return IAppPlayerTranslations.traditionalChinese();
      }
      return IAppPlayerTranslations.chinese();
    }

    switch (languageCode) {
      case "pl":
        return IAppPlayerTranslations.polish();
      case "hi":
        return IAppPlayerTranslations.hindi();
      case "ar":
        return IAppPlayerTranslations.arabic();
      case "tr":
        return IAppPlayerTranslations.turkish();
      case "vi":
        return IAppPlayerTranslations.vietnamese();
      case "es":
        return IAppPlayerTranslations.spanish();
      case "pt":
        return IAppPlayerTranslations.portuguese();
      case "bn":
        return IAppPlayerTranslations.bengali();
      case "ru":
        return IAppPlayerTranslations.russian();
      case "ja":
        return IAppPlayerTranslations.japanese();
      case "fr":
        return IAppPlayerTranslations.french();
      case "de":
        return IAppPlayerTranslations.german();
      case "id":
        return IAppPlayerTranslations.indonesian();
      case "ko":
        return IAppPlayerTranslations.korean();
      case "it":
        return IAppPlayerTranslations.italian();
      default:
        return IAppPlayerTranslations();
    }
  }

  // 获取数据源启动状态
  bool get hasCurrentDataSourceStarted => _hasCurrentDataSourceStarted;

  // 设置生命周期状态
  void setAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (_isAutomaticPlayPauseHandled()) {
      _appLifecycleState = appLifecycleState;
      if (appLifecycleState == AppLifecycleState.resumed) {
        if (_wasPlayingBeforePause == true && _isPlayerVisible) {
          play();
        }
      }
      if (appLifecycleState == AppLifecycleState.paused) {
        _wasPlayingBeforePause ??= isPlaying();
        pause();
      }
    }
  }

  // 设置宽高比
  void setOverriddenAspectRatio(double aspectRatio) {
    _overriddenAspectRatio = aspectRatio;
  }

  // 获取宽高比
  double? getAspectRatio() {
    return _overriddenAspectRatio ?? iappPlayerConfiguration.aspectRatio;
  }

  // 设置适配模式
  void setOverriddenFit(BoxFit fit) {
    _overriddenFit = fit;
  }

  // 获取适配模式
  BoxFit getFit() {
    return _overriddenFit ?? iappPlayerConfiguration.fit;
  }

// 启用画中画
Future<void>? enablePictureInPicture(GlobalKey iappPlayerGlobalKey) async {
  if (videoPlayerController == null) {
    throw StateError("数据源未初始化");
  }

  final bool isPipSupported =
      (await videoPlayerController!.isPictureInPictureSupported()) ?? false;

  if (isPipSupported) {
    _wasInFullScreenBeforePiP = _isFullScreen;
    _wasControlsEnabledBeforePiP = _controlsEnabled;
    setControlsEnabled(false);
    
    // 获取视频区域的实际位置和尺寸
    final RenderBox? renderBox = iappPlayerGlobalKey.currentContext!
        .findRenderObject() as RenderBox?;
    if (renderBox == null) {
      IAppPlayerUtils.log(
          "无法显示画中画，RenderBox 为空，请提供有效的全局键");
      return;
    }
    
    final Offset position = renderBox.localToGlobal(Offset.zero);
    
    if (Platform.isAndroid) {
      // 使用实际的位置和尺寸
      await videoPlayerController?.enablePictureInPicture(
        left: position.dx,
        top: position.dy,
        width: renderBox.size.width,
        height: renderBox.size.height,
      );
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipStart));
      return;
    }
    
    if (Platform.isIOS) {
      await videoPlayerController?.enablePictureInPicture(
        left: position.dx,
        top: position.dy,
        width: renderBox.size.width,
        height: renderBox.size.height,
      );
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipStart));
      return;
    } else {
      IAppPlayerUtils.log("当前平台不支持画中画");
    }
  } else {
    IAppPlayerUtils.log(
        "设备不支持画中画，Android 请检查是否使用活动 v2 嵌入");
  }
}

  // 禁用画中画
  Future<void>? disablePictureInPicture() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    return videoPlayerController!.disablePictureInPicture();
  }

  // 设置全局键
  void setIAppPlayerGlobalKey(GlobalKey iappPlayerGlobalKey) {
    _iappPlayerGlobalKey = iappPlayerGlobalKey;
  }

  // 检查画中画支持
  Future<bool> isPictureInPictureSupported() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    final bool isPipSupported =
        (await videoPlayerController!.isPictureInPictureSupported()) ?? false;

    return isPipSupported && !_isFullScreen;
  }

  // 处理视频事件
void _handleVideoEvent(VideoEvent event) async {
  if (_disposed) {
    return;
  }

  switch (event.eventType) {
    case VideoEventType.play:
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.play));
      break;
    case VideoEventType.pause:
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.pause));
      break;
    case VideoEventType.seek:
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.seekTo));
      break;
    case VideoEventType.completed:
      final VideoPlayerValue? videoValue = videoPlayerController?.value;
      _postEvent(
        IAppPlayerEvent(
          IAppPlayerEventType.finished,
          parameters: <String, dynamic>{
            _progressParameter: videoValue?.position,
            _durationParameter: videoValue?.duration
          },
        ),
      );
      break;
    case VideoEventType.bufferingStart:
      _handleBufferingStart();
      break;
    case VideoEventType.bufferingUpdate:
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingUpdate,
          parameters: <String, dynamic>{
            _bufferedParameter: event.buffered,
          }));
      break;
    case VideoEventType.bufferingEnd:
      _handleBufferingEnd();
      break;
    case VideoEventType.pipStop:
      // 新增：保存退出原因
      _lastPipExitReason = event.pipExitReason;
      break;
    default:
      break;
  }
}

  // 处理缓冲开始
  void _handleBufferingStart() {
    if (_disposed) {
      return;
    }

    final now = DateTime.now();

    if (_isCurrentlyBuffering) {
      return;
    }

    _bufferingDebounceTimer?.cancel();

    if (_lastBufferingChangeTime != null) {
      final timeSinceLastChange = now.difference(_lastBufferingChangeTime!).inMilliseconds;
      if (timeSinceLastChange < _bufferingDebounceMs) {
        _bufferingDebounceTimer = Timer(
          Duration(milliseconds: _bufferingDebounceMs - timeSinceLastChange),
          () {
            if (!_disposed && !_isCurrentlyBuffering) {
              _isCurrentlyBuffering = true;
              _lastBufferingChangeTime = DateTime.now();
              _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingStart));
            }
          }
        );
        return;
      }
    }

    _isCurrentlyBuffering = true;
    _lastBufferingChangeTime = now;
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingStart));
  }

  // 处理缓冲结束
  void _handleBufferingEnd() {
    if (_disposed) {
      return;
    }

    final now = DateTime.now();

    if (!_isCurrentlyBuffering) {
      return;
    }

    _bufferingDebounceTimer?.cancel();

    if (_lastBufferingChangeTime != null) {
      final timeSinceLastChange = now.difference(_lastBufferingChangeTime!).inMilliseconds;
      if (timeSinceLastChange < _bufferingDebounceMs) {
        _bufferingDebounceTimer = Timer(
          Duration(milliseconds: _bufferingDebounceMs - timeSinceLastChange),
          () {
            if (!_disposed && _isCurrentlyBuffering) {
              _isCurrentlyBuffering = false;
              _lastBufferingChangeTime = DateTime.now();
              _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingEnd));
            }
          }
        );
        return;
      }
    }

    _isCurrentlyBuffering = false;
    _lastBufferingChangeTime = now;
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingEnd));
  }

  // 设置控件始终可见
  void setControlsAlwaysVisible(bool controlsAlwaysVisible) {
    _controlsAlwaysVisible = controlsAlwaysVisible;
    _controlsVisibilityStreamController.add(controlsAlwaysVisible);
  }

  // 重试数据源
  Future retryDataSource() async {
    await _setupDataSource(_iappPlayerDataSource!);
    if (_videoPlayerValueOnError != null) {
      final position = _videoPlayerValueOnError!.position;
      await seekTo(position);
      await play();
      _videoPlayerValueOnError = null;
    }
  }

  // 设置音频轨道
  void setAudioTrack(IAppPlayerAsmsAudioTrack audioTrack) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    if (audioTrack.language == null) {
      _iappPlayerAsmsAudioTrack = null;
      return;
    }

    _iappPlayerAsmsAudioTrack = audioTrack;
    videoPlayerController!.setAudioTrack(audioTrack.label, audioTrack.id);
  }

  // 设置音频混音
  void setMixWithOthers(bool mixWithOthers) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    videoPlayerController!.setMixWithOthers(mixWithOthers);
  }

  // 清除缓存
  Future<void> clearCache() async {
    return VideoPlayerController.clearCache();
  }

  // 构建请求头
  Map<String, String?> _getHeaders() {
    final headers = iappPlayerDataSource!.headers ?? {};
    if (iappPlayerDataSource?.drmConfiguration?.drmType ==
            IAppPlayerDrmType.token &&
        iappPlayerDataSource?.drmConfiguration?.token != null) {
      headers[_authorizationHeader] =
          iappPlayerDataSource!.drmConfiguration!.token!;
    }
    return headers;
  }

  // 预缓存数据
  Future<void> preCache(IAppPlayerDataSource iappPlayerDataSource) async {
    final cacheConfig = iappPlayerDataSource.cacheConfiguration ??
        const IAppPlayerCacheConfiguration(useCache: true);

    final dataSource = DataSource(
      sourceType: DataSourceType.network,
      uri: iappPlayerDataSource.url,
      useCache: true,
      headers: iappPlayerDataSource.headers,
      maxCacheSize: cacheConfig.maxCacheSize,
      maxCacheFileSize: cacheConfig.maxCacheFileSize,
      cacheKey: cacheConfig.key,
      videoExtension: iappPlayerDataSource.videoExtension,
    );

    return VideoPlayerController.preCache(dataSource, cacheConfig.preCacheSize);
  }

  // 停止预缓存
  Future<void> stopPreCache(
      IAppPlayerDataSource iappPlayerDataSource) async {
    return VideoPlayerController?.stopPreCache(iappPlayerDataSource.url,
        iappPlayerDataSource.cacheConfiguration?.key);
  }

  // 设置控件配置
  void setIAppPlayerControlsConfiguration(
      IAppPlayerControlsConfiguration iappPlayerControlsConfiguration) {
    this._iappPlayerControlsConfiguration = iappPlayerControlsConfiguration;
  }

  // 发送内部事件
  void _postControllerEvent(IAppPlayerControllerEvent event) {
    if (_disposed || _controllerEventStreamController.isClosed) {
      return;
    }
    _controllerEventStreamController.add(event);
  }

  // 设置缓冲防抖时间
  void setBufferingDebounceTime(int milliseconds) {
    if (milliseconds < 0) {
      return;
    }
    _bufferingDebounceMs = milliseconds;
  }

  // 清理缓冲状态
  void _clearBufferingState() {
    _bufferingDebounceTimer?.cancel();
    _bufferingDebounceTimer = null;
    _isCurrentlyBuffering = false;
    _lastBufferingChangeTime = null;
  }

  // 销毁控制器
  Future<void> dispose({bool forceDispose = false}) async {
    if (!iappPlayerConfiguration.autoDispose && !forceDispose) {
      return;
    }
    if (!_disposed) {
      _disposed = true;
      _nextVideoTimer?.cancel();
      _nextVideoTimer = null;
      _bufferingDebounceTimer?.cancel();
      _bufferingDebounceTimer = null;
      await _videoEventStreamSubscription?.cancel();
      _videoEventStreamSubscription = null;
      _eventListeners.clear();
      if (videoPlayerController != null) {
        videoPlayerController!.removeListener(_onFullScreenStateChanged);
        videoPlayerController!.removeListener(_onVideoPlayerChanged);
      }
      if (!_controllerEventStreamController.isClosed) {
        await _controllerEventStreamController.close();
      }
      if (!_nextVideoTimeStreamController.isClosed) {
        await _nextVideoTimeStreamController.close();
      }
      if (!_controlsVisibilityStreamController.isClosed) {
        await _controlsVisibilityStreamController.close();
      }
      if (videoPlayerController != null) {
        await videoPlayerController!.pause();
        await videoPlayerController!.dispose();
        videoPlayerController = null;
      }
      _clearBufferingState();
      _cachedIsLiveStream = null;
      _pendingSubtitleSegments = null;
      _lastSubtitleCheckPosition = null;
      await _clearTempFiles();
    }
  }
}
