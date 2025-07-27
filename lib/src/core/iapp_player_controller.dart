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

/// 视频播放控制器：管理播放状态、数据源、字幕和事件分发
class IAppPlayerController {
  // 常量定义 - 事件参数键名
  static const String _durationParameter = "duration";
  static const String _progressParameter = "progress";
  static const String _bufferedParameter = "buffered";
  static const String _volumeParameter = "volume";
  static const String _speedParameter = "speed";
  static const String _dataSourceParameter = "dataSource";
  static const String _authorizationHeader = "Authorization";

  /// 播放器配置信息
  final IAppPlayerConfiguration iappPlayerConfiguration;

  /// 播放列表配置信息
  final IAppPlayerPlaylistConfiguration? iappPlayerPlaylistConfiguration;

  /// 播放列表控制器实例
  IAppPlayerPlaylistController? _playlistController;

  /// 设置播放列表控制器
  set playlistController(IAppPlayerPlaylistController? controller) {
    _playlistController = controller;
  }

  /// 事件监听器列表：存储所有注册的事件回调
  final List<Function(IAppPlayerEvent)?> _eventListeners = [];

  /// 临时文件列表：用于内存播放和asset播放的临时文件管理
  final List<File> _tempFiles = [];

  /// 控件显示状态流控制器：管理播放控件的显示/隐藏
  final StreamController<bool> _controlsVisibilityStreamController =
      StreamController.broadcast();

  /// 底层视频播放器控制器
  VideoPlayerController? videoPlayerController;

  /// 控件配置信息
  late IAppPlayerControlsConfiguration _iappPlayerControlsConfiguration;

  /// 获取控件配置信息
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration =>
      _iappPlayerControlsConfiguration;

  /// 获取事件监听器列表（排除全局监听器）
  List<Function(IAppPlayerEvent)?> get eventListeners =>
      _eventListeners.sublist(1);

  /// 获取全局事件监听器
  Function(IAppPlayerEvent)? get eventListener =>
      iappPlayerConfiguration.eventListener;

  /// 全屏模式状态标识
  bool _isFullScreen = false;

  /// 获取当前全屏状态
  bool get isFullScreen => _isFullScreen;

  /// 上次进度事件触发时间戳：用于限制进度事件频率
  int _lastPositionSelection = 0;

  /// 当前数据源信息
  IAppPlayerDataSource? _iappPlayerDataSource;

  /// 获取当前数据源信息
  IAppPlayerDataSource? get iappPlayerDataSource => _iappPlayerDataSource;

  /// 字幕源列表：包含所有可用的字幕源
  final List<IAppPlayerSubtitlesSource> _iappPlayerSubtitlesSourceList = [];

  /// 获取字幕源列表
  List<IAppPlayerSubtitlesSource> get iappPlayerSubtitlesSourceList =>
      _iappPlayerSubtitlesSourceList;

  /// 当前选中的字幕源
  IAppPlayerSubtitlesSource? _iappPlayerSubtitlesSource;

  /// 获取当前字幕源
  IAppPlayerSubtitlesSource? get iappPlayerSubtitlesSource =>
      _iappPlayerSubtitlesSource;

  /// 当前字幕行列表：存储解析后的字幕数据
  List<IAppPlayerSubtitle> subtitlesLines = [];

  /// HLS/DASH视频轨道列表：存储不同分辨率和码率的轨道
  List<IAppPlayerAsmsTrack> _iappPlayerAsmsTracks = [];

  /// 获取轨道列表
  List<IAppPlayerAsmsTrack> get iappPlayerAsmsTracks => _iappPlayerAsmsTracks;

  /// 当前选中的视频轨道
  IAppPlayerAsmsTrack? _iappPlayerAsmsTrack;

  /// 获取当前轨道
  IAppPlayerAsmsTrack? get iappPlayerAsmsTrack => _iappPlayerAsmsTrack;

  /// 下一视频倒计时定时器
  Timer? _nextVideoTimer;

  /// 获取播放列表控制器
  IAppPlayerPlaylistController? get playlistController => _playlistController;

  /// 下一视频剩余时间（秒）
  int? _nextVideoTime;

  /// 下一视频时间流控制器：广播倒计时状态
  final StreamController<int?> _nextVideoTimeStreamController =
      StreamController.broadcast();

  /// 获取下一视频时间流
  Stream<int?> get nextVideoTimeStream => _nextVideoTimeStreamController.stream;

  /// 控制器销毁状态标识
  bool _disposed = false;

  /// 获取控制器销毁状态
  bool get isDisposed => _disposed;

  /// 暂停前的播放状态：用于生命周期恢复播放
  bool? _wasPlayingBeforePause;

  /// 翻译配置：支持多语言界面
  IAppPlayerTranslations translations = IAppPlayerTranslations();

  /// 数据源启动状态：标识播放是否已开始
  bool _hasCurrentDataSourceStarted = false;

  /// 数据源初始化状态：标识视频是否已初始化
  bool _hasCurrentDataSourceInitialized = false;

  /// 获取控件显示状态流
  Stream<bool> get controlsVisibilityStream =>
      _controlsVisibilityStreamController.stream;

  /// 应用生命周期状态：用于自动播放/暂停管理
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  /// 控件启用状态：控制播放控件的交互能力
  bool _controlsEnabled = true;

  /// 获取控件启用状态
  bool get controlsEnabled => _controlsEnabled;

  /// 覆盖的宽高比设置
  double? _overriddenAspectRatio;

  /// 覆盖的适配模式设置
  BoxFit? _overriddenFit;

  /// 画中画模式状态标识
  bool _wasInPipMode = false;

  /// 画中画前控件启用状态：用于退出画中画时恢复
  bool _wasControlsEnabledBeforePiP = false;
  
  /// 画中画退出原因：区分用户行为（返回/关闭）
  String? _lastPipExitReason;

  /// 视频事件流订阅：监听底层播放器事件
  StreamSubscription<VideoEvent>? _videoEventStreamSubscription;

  /// 控件始终可见状态：禁用自动隐藏功能
  bool _controlsAlwaysVisible = false;

  /// 获取控件始终可见状态
  bool get controlsAlwaysVisible => _controlsAlwaysVisible;

  /// HLS/DASH音频轨道列表：支持多语言音轨
  List<IAppPlayerAsmsAudioTrack>? _iappPlayerAsmsAudioTracks;

  /// 获取音频轨道列表
  List<IAppPlayerAsmsAudioTrack>? get iappPlayerAsmsAudioTracks =>
      _iappPlayerAsmsAudioTracks;

  /// 当前选中的音频轨道
  IAppPlayerAsmsAudioTrack? _iappPlayerAsmsAudioTrack;

  /// 获取当前音频轨道
  IAppPlayerAsmsAudioTrack? get iappPlayerAsmsAudioTrack =>
      _iappPlayerAsmsAudioTrack;

  /// 错误发生时的播放器状态：用于错误恢复
  VideoPlayerValue? _videoPlayerValueOnError;

  /// 播放器可见性标识：用于自动播放/暂停
  bool _isPlayerVisible = true;

  /// 内部事件流控制器：传递控制器级别的事件
  final StreamController<IAppPlayerControllerEvent>
      _controllerEventStreamController = StreamController.broadcast();

  /// 获取内部事件流
  Stream<IAppPlayerControllerEvent> get controllerEventStream =>
      _controllerEventStreamController.stream;

  /// ASMS字幕段加载状态：防止重复加载
  bool _asmsSegmentsLoading = false;

  /// 已加载的ASMS字幕段集合：避免重复请求
  final Set<String> _asmsSegmentsLoaded = {};

  /// 当前显示的字幕对象
  IAppPlayerSubtitle? renderedSubtitle;

  /// 缓存的播放器状态：优化状态变更检测
  VideoPlayerValue? _lastVideoPlayerValue;

  /// 缓冲防抖定时器：避免频繁缓冲事件
  Timer? _bufferingDebounceTimer;

  /// 当前缓冲状态标识
  bool _isCurrentlyBuffering = false;

  /// 上次缓冲状态变更时间：用于防抖计算
  DateTime? _lastBufferingChangeTime;

  /// 缓冲防抖时间（毫秒）
  int _bufferingDebounceMs = 500;

  /// 播放列表随机模式状态
  bool _playlistShuffleMode = false;

  /// 获取随机模式状态
  bool get playlistShuffleMode => _playlistShuffleMode;

  /// 直播流检测缓存：避免重复检测
  bool? _cachedIsLiveStream;

  /// 待处理的字幕段列表：用于分段字幕预加载
  List<IAppPlayerAsmsSubtitleSegment>? _pendingSubtitleSegments;

  /// 上次字幕检查的播放位置：优化检查频率
  Duration? _lastSubtitleCheckPosition;

  // 字幕滑动窗口配置：优化内存使用
  static const int _subtitleWindowSize = 300;
  static const Duration _subtitleWindowDuration = Duration(minutes: 10);

  /// 最后播放的数据源：用于恢复播放
  IAppPlayerDataSource? _lastDataSource;

  /// 最后播放位置：用于断点续播
  Duration? _lastPlayPosition;

  /// 构造函数：初始化配置和可选数据源
  IAppPlayerController(
    this.iappPlayerConfiguration, {
    this.iappPlayerPlaylistConfiguration,
    IAppPlayerDataSource? iappPlayerDataSource,
  }) {
    this._iappPlayerControlsConfiguration =
        iappPlayerConfiguration.controlsConfiguration;
    // 添加全局事件监听器到列表首位
    _eventListeners.add(eventListener);
    // 如果提供了数据源则立即设置
    if (iappPlayerDataSource != null) {
      setupDataSource(iappPlayerDataSource);
    }
  }

  /// 从上下文获取控制器实例
  static IAppPlayerController of(BuildContext context) {
    final betterPLayerControllerProvider = context
        .dependOnInheritedWidgetOfExactType<IAppPlayerControllerProvider>()!;

    return betterPLayerControllerProvider.controller;
  }

  /// 设置数据源并初始化播放器：核心方法，处理视频加载流程
  Future setupDataSource(IAppPlayerDataSource iappPlayerDataSource) async {
    // 清理旧的临时文件避免内存泄漏
    await _clearTempFiles();
    
    // 发送数据源设置事件
    postEvent(IAppPlayerEvent(IAppPlayerEventType.setupDataSource,
        parameters: <String, dynamic>{
          _dataSourceParameter: iappPlayerDataSource,
        }));
    _postControllerEvent(IAppPlayerControllerEvent.setupDataSource);
    
    // 重置播放状态
    _hasCurrentDataSourceStarted = false;
    _hasCurrentDataSourceInitialized = false;
    _iappPlayerDataSource = iappPlayerDataSource;
    _iappPlayerSubtitlesSourceList.clear();
    _clearBufferingState();
    _cachedIsLiveStream = null;
    _pendingSubtitleSegments = null;
    _lastSubtitleCheckPosition = null;

    // 创建视频播放器控制器
    if (videoPlayerController == null) {
      videoPlayerController = VideoPlayerController(
          bufferingConfiguration:
              iappPlayerDataSource.bufferingConfiguration);
      videoPlayerController?.addListener(_onVideoPlayerChanged);
    }

    // 清空轨道列表
    iappPlayerAsmsTracks.clear();

    // 添加字幕源到列表
    final List<IAppPlayerSubtitlesSource>? iappPlayerSubtitlesSourceList =
        iappPlayerDataSource.subtitles;
    if (iappPlayerSubtitlesSourceList != null) {
      _iappPlayerSubtitlesSourceList
          .addAll(iappPlayerDataSource.subtitles!);
    }

    // 检测HLS/DASH流并设置字幕
    if (_isDataSourceAsms(iappPlayerDataSource)) {
      _setupAsmsDataSource(iappPlayerDataSource).then((dynamic value) {
        _setupSubtitles();
      });
    } else {
      _setupSubtitles();
    }

    // 设置数据源并应用默认轨道
    await _setupDataSource(iappPlayerDataSource);
    setTrack(IAppPlayerAsmsTrack.defaultTrack());
  }

  /// 清理临时文件：防止存储空间泄漏
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

  /// 配置字幕源：添加默认"无字幕"选项并选择默认字幕
  void _setupSubtitles() {
    // 添加无字幕选项
    _iappPlayerSubtitlesSourceList.add(
      IAppPlayerSubtitlesSource(type: IAppPlayerSubtitlesSourceType.none),
    );
    
    // 查找标记为默认的字幕源
    final defaultSubtitle = _iappPlayerSubtitlesSourceList
        .firstWhereOrNull((element) => element.selectedByDefault == true);

    // 设置默认字幕或无字幕
    setupSubtitleSource(
        defaultSubtitle ?? _iappPlayerSubtitlesSourceList.last,
        sourceInitialize: true);
  }

  /// 检查数据源是否为HLS/DASH格式
  bool _isDataSourceAsms(IAppPlayerDataSource iappPlayerDataSource) =>
      (IAppPlayerAsmsUtils.isDataSourceHls(iappPlayerDataSource.url) ||
          iappPlayerDataSource.videoFormat == IAppPlayerVideoFormat.hls) ||
      (IAppPlayerAsmsUtils.isDataSourceDash(iappPlayerDataSource.url) ||
          iappPlayerDataSource.videoFormat == IAppPlayerVideoFormat.dash);

  /// 配置HLS/DASH数据源：解析M3U8/MPD文件获取轨道和字幕信息
  Future _setupAsmsDataSource(IAppPlayerDataSource source) async {
    // 获取M3U8/MPD文件内容
    final String? data = await IAppPlayerAsmsUtils.getDataFromUrl(
      iappPlayerDataSource!.url,
      _getHeaders(),
    );
    
    if (data != null) {
      // 解析文件获取轨道和字幕信息
      final IAppPlayerAsmsDataHolder _response =
          await IAppPlayerAsmsUtils.parse(data, iappPlayerDataSource!.url);

      // 配置视频轨道
      if (_iappPlayerDataSource?.useAsmsTracks == true) {
        _iappPlayerAsmsTracks = _response.tracks ?? [];
      }

      // 配置ASMS字幕
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

      // 配置音频轨道
      if (iappPlayerDataSource?.useAsmsAudioTracks == true &&
          _isDataSourceAsms(iappPlayerDataSource!)) {
        _iappPlayerAsmsAudioTracks = _response.audios ?? [];
        if (_iappPlayerAsmsAudioTracks?.isNotEmpty == true) {
          setAudioTrack(_iappPlayerAsmsAudioTracks!.first);
        }
      }
    }
  }

  /// 设置字幕源并加载字幕内容
  Future<void> setupSubtitleSource(IAppPlayerSubtitlesSource subtitlesSource,
      {bool sourceInitialize = false}) async {
    _iappPlayerSubtitlesSource = subtitlesSource;
    // 清理旧字幕数据
    subtitlesLines.clear();
    _asmsSegmentsLoaded.clear();
    _asmsSegmentsLoading = false;
    _pendingSubtitleSegments = null;
    _lastSubtitleCheckPosition = null;

    // 加载非空字幕源
    if (subtitlesSource.type != IAppPlayerSubtitlesSourceType.none) {
      // 分段字幕延迟加载
      if (subtitlesSource.asmsIsSegmented == true) {
        return;
      }
      try {
        // 解析并加载字幕文件（错误不影响播放）
        final subtitlesParsed =
            await IAppPlayerSubtitlesFactory.parseSubtitles(subtitlesSource);
        subtitlesLines.addAll(subtitlesParsed);
      } catch (e) {
        IAppPlayerUtils.log("字幕加载失败: $e");
      }
    }

    // 发送字幕变更事件
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedSubtitles));
    if (!_disposed && !sourceInitialize) {
      _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles);
    }
  }

  /// 按需加载ASMS分段字幕：根据播放位置智能预加载字幕段
  Future _loadAsmsSubtitlesSegments(Duration position) async {
    if (_disposed) return;
    
    try {
      // 防止重复加载
      if (_asmsSegmentsLoading) {
        return;
      }

      // 频率控制：避免过频繁的加载检查
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
      
      // 计算预加载时间窗口（当前位置+5秒）
      final Duration loadDurationEnd = Duration(
          milliseconds: position.inMilliseconds +
              5 * (_iappPlayerSubtitlesSource?.asmsSegmentsTime ?? 5000));

      // 初始化待处理字幕段列表
      if (_pendingSubtitleSegments == null) {
        _pendingSubtitleSegments = _iappPlayerSubtitlesSource?.asmsSegments
            ?.where((segment) => !_asmsSegmentsLoaded.contains(segment.realUrl))
            .toList() ?? [];
      }

      final segmentsToLoad = <String>[];
      final segmentsToRemove = <IAppPlayerAsmsSubtitleSegment>[];

      // 筛选需要加载的字幕段
      for (final segment in _pendingSubtitleSegments!) {
        if (segment.startTime > position && segment.endTime < loadDurationEnd) {
          segmentsToLoad.add(segment.realUrl);
          segmentsToRemove.add(segment);
        }
      }

      // 移除已筛选的字幕段
      if (segmentsToRemove.isNotEmpty) {
        _pendingSubtitleSegments!.removeWhere((s) => segmentsToRemove.contains(s));
      }

      // 批量加载字幕段
      if (segmentsToLoad.isNotEmpty) {
        final subtitlesParsed =
            await IAppPlayerSubtitlesFactory.parseSubtitles(
                IAppPlayerSubtitlesSource(
          type: _iappPlayerSubtitlesSource!.type,
          headers: _iappPlayerSubtitlesSource!.headers,
          urls: segmentsToLoad,
        ));

        if (_disposed) return;
        
        // 验证字幕源未变更后添加字幕
        if (source == _iappPlayerSubtitlesSource) {
          subtitlesLines.addAll(subtitlesParsed);
          _asmsSegmentsLoaded.addAll(segmentsToLoad);
          
          // 执行字幕滑动窗口清理
          _cleanupOldSubtitles(position);
        }
      }
      _asmsSegmentsLoading = false;
    } catch (exception) {
      IAppPlayerUtils.log("加载ASMS字幕段失败: $exception");
    }
  }

  /// 清理过期字幕：实施滑动窗口策略优化内存使用
  void _cleanupOldSubtitles(Duration currentPosition) {
    // 数量未超限则跳过清理
    if (subtitlesLines.length <= _subtitleWindowSize) {
      return;
    }

    final minTime = currentPosition - _subtitleWindowDuration;
    final maxTime = currentPosition + _subtitleWindowDuration;

    // 移除时间窗口外的字幕
    subtitlesLines.removeWhere((subtitle) {
      final startTime = subtitle.start;
      final endTime = subtitle.end;
      return endTime != null && 
             (endTime < minTime || (startTime != null && startTime > maxTime));
    });

    // 数量仍超限时按位置保留最近字幕
    if (subtitlesLines.length > _subtitleWindowSize) {
      // 检查排序状态避免不必要的排序
      bool needsSort = false;
      for (int i = 1; i < subtitlesLines.length; i++) {
        final prevStart = subtitlesLines[i-1].start?.inMilliseconds ?? 0;
        final currStart = subtitlesLines[i].start?.inMilliseconds ?? 0;
        if (prevStart > currStart) {
          needsSort = true;
          break;
        }
      }
      
      // 按需排序优化性能
      if (needsSort) {
        subtitlesLines.sort((a, b) {
          final aStart = a.start?.inMilliseconds ?? 0;
          final bStart = b.start?.inMilliseconds ?? 0;
          return aStart.compareTo(bStart);
        });
      }

      // 二分查找当前播放位置
      int currentIndex = 0;
      int left = 0;
      int right = subtitlesLines.length - 1;
      
      while (left <= right) {
        int mid = (left + right) ~/ 2;
        final midStart = subtitlesLines[mid].start;
        
        if (midStart == null) {
          left = mid + 1;
        } else if (midStart.inMilliseconds <= currentPosition.inMilliseconds) {
          currentIndex = mid;
          left = mid + 1;
        } else {
          right = mid - 1;
        }
      }

      // 计算滑动窗口范围
      final halfWindow = _subtitleWindowSize ~/ 2;
      final startIndex = (currentIndex - halfWindow).clamp(0, subtitlesLines.length);
      final endIndex = (currentIndex + halfWindow).clamp(0, subtitlesLines.length);

      // 保留窗口内字幕
      subtitlesLines = subtitlesLines.sublist(startIndex, endIndex);
    }
  }

  /// 转换视频格式枚举到底层格式
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

  /// 判断路径是否为Flutter资源路径
  bool _isAssetPath(String path) {
    return path.startsWith('assets/') || path.startsWith('asset://');
  }

  /// 从Flutter资源创建临时文件：支持asset://协议播放
  Future<File> _createFileFromAsset(String assetPath) async {
    try {
      // 清理asset://前缀
      final cleanPath = assetPath.startsWith('asset://') 
          ? assetPath.substring(8) 
          : assetPath;
      
      // 从资源包读取文件数据
      final ByteData data = await rootBundle.load(cleanPath);
      final List<int> bytes = data.buffer.asUint8List();
      
      // 提取文件扩展名
      final String extension = cleanPath.split('.').last;
      
      // 创建临时文件并写入数据
      final tempFile = await _createFile(bytes, extension: extension);
      return tempFile;
    } catch (e) {
      throw Exception('无法从asset加载文件: $assetPath, 错误: $e');
    }
  }

  /// 根据数据源类型设置播放器：处理网络、文件、内存三种数据源
  Future _setupDataSource(IAppPlayerDataSource iappPlayerDataSource) async {
    switch (iappPlayerDataSource.type) {
      case IAppPlayerDataSourceType.network:
        // 网络数据源：支持HTTP/HTTPS、HLS、DASH等
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
        // 文件数据源：支持本地文件和Flutter资源
        if (_isAssetPath(iappPlayerDataSource.url)) {
          // 处理Flutter资源文件
          IAppPlayerUtils.log(
              "检测到asset路径: ${iappPlayerDataSource.url}，将从asset加载");
          
          // 创建资源临时文件
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
          // 处理本地文件系统路径
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
        // 内存数据源：将字节数组写入临时文件播放
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

  /// 创建临时文件：将字节数组写入临时目录
  Future<File> _createFile(List<int> bytes,
      {String? extension = "temp"}) async {
    final String dir = (await getTemporaryDirectory()).path;
    final File temp = File(
        '$dir/iapp_player_${DateTime.now().millisecondsSinceEpoch}.$extension');
    await temp.writeAsBytes(bytes);
    return temp;
  }

  /// 初始化视频播放器：配置循环、全屏、自动播放等设置
  Future _initializeVideo() async {
    // 播放列表模式强制禁用循环
    if (isPlaylistMode) {
      setLooping(false);
    } else {
      setLooping(iappPlayerConfiguration.looping);
    }
    
    // 重新订阅视频事件
    _videoEventStreamSubscription?.cancel();
    _videoEventStreamSubscription = null;
    _videoEventStreamSubscription = videoPlayerController
        ?.videoEventStreamController.stream
        .listen(_handleVideoEvent);

    final fullScreenByDefault = iappPlayerConfiguration.fullScreenByDefault;
    // 播放列表模式下切换视频总是自动播放
    final shouldAutoPlay = iappPlayerConfiguration.autoPlay || (iappPlayerPlaylistConfiguration != null);
    
    if (shouldAutoPlay) {
      if (fullScreenByDefault && !isFullScreen) {
        enterFullScreen();
      }
      // 检查自动播放/暂停处理
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

    // 应用起始播放位置
    final startAt = iappPlayerConfiguration.startAt;
    if (startAt != null) {
      seekTo(startAt);
    }
  }

  /// 处理全屏状态变化：自动进入全屏模式
  Future<void> _onFullScreenStateChanged() async {
    if (videoPlayerController?.value.isPlaying == true && !_isFullScreen) {
      enterFullScreen();
      videoPlayerController?.removeListener(_onFullScreenStateChanged);
    }
  }

  /// 进入全屏模式
  void enterFullScreen() {
    _isFullScreen = true;
    _postControllerEvent(IAppPlayerControllerEvent.openFullscreen);
  }

  /// 退出全屏模式
  void exitFullScreen() {
    _isFullScreen = false;
    _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen);
  }

  /// 切换全屏模式状态
  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    if (_isFullScreen) {
      _postControllerEvent(IAppPlayerControllerEvent.openFullscreen);
    } else {
      _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen);
    }
  }

  /// 开始播放视频
  Future<void> play() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    // 仅在应用前台时播放
    if (_appLifecycleState == AppLifecycleState.resumed) {
      await videoPlayerController!.play();
      _hasCurrentDataSourceStarted = true;
      _wasPlayingBeforePause = null;
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.play));
      _postControllerEvent(IAppPlayerControllerEvent.play);
    }
  }

  /// 设置循环播放模式
  Future<void> setLooping(bool looping) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    await videoPlayerController!.setLooping(looping);
  }

  /// 暂停视频播放
  Future<void> pause() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    await videoPlayerController!.pause();
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.pause));
  }

  /// 跳转到指定播放位置
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
    // 检查是否跳转到视频结尾
    if (moment > currentDuration) {
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.finished));
    } else {
      cancelNextVideoTimer();
    }
  }

  /// 设置播放音量：范围0.0-1.0
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

  /// 设置播放速度：范围0-2倍速
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

  /// 检查视频播放状态
  bool? isPlaying() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    return videoPlayerController!.value.isPlaying;
  }

  /// 检查视频缓冲状态
  bool? isBuffering() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    return videoPlayerController!.value.isBuffering;
  }

  /// 设置控件显示状态
  void setControlsVisibility(bool isVisible) {
    _controlsVisibilityStreamController.add(isVisible);
  }

  /// 启用或禁用播放控件
  void setControlsEnabled(bool enabled) {
    if (!enabled) {
      _controlsVisibilityStreamController.add(false);
    }
    _controlsEnabled = enabled;
  }

  /// 触发控件显示/隐藏事件
  void toggleControlsVisibility(bool isVisible) {
    _postEvent(isVisible
        ? IAppPlayerEvent(IAppPlayerEventType.controlsVisible)
        : IAppPlayerEvent(IAppPlayerEventType.controlsHiddenEnd));
  }

  /// 发送播放器事件：公开接口
  void postEvent(IAppPlayerEvent iappPlayerEvent) {
    _postEvent(iappPlayerEvent);
  }

  /// 广播事件到所有监听器
  void _postEvent(IAppPlayerEvent iappPlayerEvent) {
    if (_disposed) {
      return;
    }

    // 处理播放列表随机模式变更
    if (iappPlayerEvent.iappPlayerEventType == 
        IAppPlayerEventType.changedPlaylistShuffle) {
      _playlistShuffleMode = iappPlayerEvent.parameters?['shuffleMode'] ?? false;
      _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles);
    }

    // 遍历所有监听器并发送事件
    for (final Function(IAppPlayerEvent)? eventListener in _eventListeners) {
      if (eventListener != null) {
        eventListener(iappPlayerEvent);
      }
    }
  }

  /// 检查是否为播放列表模式
  bool get isPlaylistMode => 
      iappPlayerPlaylistConfiguration != null || _playlistController != null;

  /// 切换播放列表随机播放模式
  void togglePlaylistShuffle() {
    if (isPlaylistMode) {
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.togglePlaylistShuffle));
    }
  }

  /// 处理播放器状态变化：核心监听方法，处理播放进度、错误、画中画等
  void _onVideoPlayerChanged() async {
    if (_disposed) {
      return;
    }

    final currentValue = videoPlayerController?.value;
    if (currentValue == null) {
      return;
    }

    // 优化：仅在关键值变化时处理
    if (_lastVideoPlayerValue != null) {
      final hasPositionChanged = currentValue.position != _lastVideoPlayerValue!.position;
      final hasPlayingChanged = currentValue.isPlaying != _lastVideoPlayerValue!.isPlaying;
      final hasBufferingChanged = currentValue.isBuffering != _lastVideoPlayerValue!.isBuffering;
      final hasErrorChanged = currentValue.hasError != _lastVideoPlayerValue!.hasError;
      final hasPipChanged = currentValue.isPip != _lastVideoPlayerValue!.isPip;
      
      // 无变化时直接返回
      if (!hasPositionChanged && !hasPlayingChanged && !hasBufferingChanged && !hasErrorChanged && !hasPipChanged) {
        return;
      }
    }

    // 处理播放错误
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

    // 处理初始化完成
    if (currentValue.initialized && !_hasCurrentDataSourceInitialized) {
      _hasCurrentDataSourceInitialized = true;
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.initialized));
    }

    // 处理画中画状态变化
    if (currentValue.isPip) {
      _wasInPipMode = true;
    } else if (_wasInPipMode) {
      _wasInPipMode = false;
      // 延迟刷新避免立即状态更新冲突
      Future.delayed(Duration(milliseconds: 300), () {
        if (!_disposed) {
          videoPlayerController?.refresh();
        }
      });
    }
    
    // 按需加载ASMS分段字幕
    if (_iappPlayerSubtitlesSource?.asmsIsSegmented == true) {
      _loadAsmsSubtitlesSegments(currentValue.position);
    }

    // 限频发送播放进度事件（500ms间隔）
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

  /// 检查并退出画中画模式：确保完全退出画中画和全屏
  Future<void> checkAndExitPictureInPicture() async {
    try {
      // 退出画中画模式
      if (videoPlayerController?.value.isPip == true) {
        await disablePictureInPicture();
        await Future.delayed(Duration(milliseconds: 300));
      }
      
      // 确保退出全屏模式
      if (_isFullScreen) {
        exitFullScreen();
        await Future.delayed(Duration(milliseconds: 200));
        // 二次检查并强制退出
        if (_isFullScreen) {
          _isFullScreen = false;
          _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen);
          _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles);
        }
      }
    } catch (e) {
      IAppPlayerUtils.log("退出画中画失败: $e");
    }
  }

  /// 添加事件监听器：防止重复添加
  void addEventsListener(Function(IAppPlayerEvent) eventListener) {
    if (!_eventListeners.contains(eventListener)) {
      _eventListeners.add(eventListener);
    }
  }

  /// 移除事件监听器
  void removeEventsListener(Function(IAppPlayerEvent) eventListener) {
    _eventListeners.remove(eventListener);
  }

  /// 检查是否为直播流：缓存检测结果提升性能
  bool isLiveStream() {
    if (_iappPlayerDataSource == null) {
      IAppPlayerUtils.log("数据源未初始化");
      throw StateError("数据源未初始化");
    }

    // 返回缓存结果
    if (_cachedIsLiveStream != null) {
      return _cachedIsLiveStream!;
    }

    // 显式直播流标记
    if (_iappPlayerDataSource!.liveStream == true) {
      _cachedIsLiveStream = true;
      return true;
    }

    final url = _iappPlayerDataSource!.url.toLowerCase();

    // RTMP协议检测
    if (url.contains('rtmp://')) {
      _cachedIsLiveStream = true;
      return true;
    }

    // HLS直播流检测
    if (url.contains('.m3u8')) {
      _cachedIsLiveStream = true;
      return true;
    }

    // FLV直播流检测
    if (url.contains('.flv')) {
      _cachedIsLiveStream = true;
      return true;
    }

    // 其他直播协议检测
    if (url.contains('rtsp://') ||
        url.contains('mms://') ||
        url.contains('rtmps://')) {
      _cachedIsLiveStream = true;
      return true;
    }

    _cachedIsLiveStream = false;
    return false;
  }

  /// 检查视频初始化状态
  bool? isVideoInitialized() {
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化");
      throw StateError("数据源未初始化");
    }
    return videoPlayerController?.value.initialized;
  }

  /// 启动下一视频倒计时定时器
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

      // 每秒递减倒计时
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

  /// 取消下一视频倒计时
  void cancelNextVideoTimer() {
    _nextVideoTime = null;
    _nextVideoTimeStreamController.add(_nextVideoTime);
    _nextVideoTimer?.cancel();
    _nextVideoTimer = null;
  }

  /// 立即播放下一视频
  void playNextVideo() {
    _nextVideoTime = 0;
    _nextVideoTimeStreamController.add(_nextVideoTime);
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedPlaylistItem));
    cancelNextVideoTimer();
  }

  /// 设置视频质量轨道
  void setTrack(IAppPlayerAsmsTrack track) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    
    // 发送轨道变更事件
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

    // 设置轨道参数到播放器
    videoPlayerController!
        .setTrackParameters(track.width, track.height, track.bitrate);
    _iappPlayerAsmsTrack = track;
  }

  /// 检查是否处理自动播放/暂停
  bool _isAutomaticPlayPauseHandled() {
    return !(_iappPlayerDataSource
                ?.notificationConfiguration?.showNotification ==
            true) &&
        iappPlayerConfiguration.handleLifecycle;
  }

  /// 处理播放器可见性变化：支持自动播放/暂停
  void onPlayerVisibilityChanged(double visibilityFraction) async {
    _isPlayerVisible = visibilityFraction > 0;
    if (_disposed) {
      return;
    }
    _postEvent(
        IAppPlayerEvent(IAppPlayerEventType.changedPlayerVisibility));

    // 执行自动播放/暂停逻辑
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

  /// 切换视频分辨率：保持播放位置和状态
  void setResolution(String url) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    
    // 保存当前播放状态
    final position = await videoPlayerController!.position;
    final wasPlayingBeforeChange = isPlaying()!;
    
    // 暂停并切换数据源
    pause();
    await setupDataSource(iappPlayerDataSource!.copyWith(url: url));
    
    // 恢复播放位置和状态
    seekTo(position!);
    if (wasPlayingBeforeChange) {
      play();
    }
    _postEvent(IAppPlayerEvent(
      IAppPlayerEventType.changedResolution,
      parameters: <String, dynamic>{"url": url},
    ));
  }

  /// 设置多语言翻译
  void setupTranslations(Locale locale) {
    if (locale != null) {
      final String languageCode = locale.languageCode;
      translations = iappPlayerConfiguration.translations?.firstWhereOrNull(
              (translations) => translations.languageCode == languageCode) ??
          _getDefaultTranslations(locale);
    } else {
      IAppPlayerUtils.log("语言环境为空，无法设置翻译");
    }
  }

  /// 获取默认翻译配置：支持多种语言
  IAppPlayerTranslations _getDefaultTranslations(Locale locale) {
    final String languageCode = locale.languageCode;
    final String? scriptCode = locale.scriptCode;
    final String? countryCode = locale.countryCode;

    // 中文语言处理：区分简繁体
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

    // 其他语言映射
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

  /// 获取数据源启动状态
  bool get hasCurrentDataSourceStarted => _hasCurrentDataSourceStarted;

  /// 设置应用生命周期状态：处理前后台切换
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

  /// 设置覆盖宽高比
  void setOverriddenAspectRatio(double aspectRatio) {
    _overriddenAspectRatio = aspectRatio;
  }

  /// 获取有效宽高比：优先使用覆盖值
  double? getAspectRatio() {
    return _overriddenAspectRatio ?? iappPlayerConfiguration.aspectRatio;
  }

  /// 设置覆盖适配模式
  void setOverriddenFit(BoxFit fit) {
    _overriddenFit = fit;
  }

  /// 获取有效适配模式：优先使用覆盖值
  BoxFit getFit() {
    return _overriddenFit ?? iappPlayerConfiguration.fit;
  }

  /// 启用画中画模式：Android/iOS平台支持
  Future<void>? enablePictureInPicture() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    final bool isPipSupported =
        (await videoPlayerController!.isPictureInPictureSupported()) ?? false;

    if (isPipSupported) {
      // 保存进入画中画前的状态
      _wasControlsEnabledBeforePiP = _controlsEnabled;
      _wasPlayingBeforePause = isPlaying();
      
      // 禁用控件
      setControlsEnabled(false);
      
      if (Platform.isAndroid || Platform.isIOS) {
        // 进入画中画模式
        await videoPlayerController?.enablePictureInPicture();
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

  /// 禁用画中画模式
  Future<void>? disablePictureInPicture() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }
    return videoPlayerController!.disablePictureInPicture();
  }

  /// 检查画中画支持状态
  Future<bool> isPictureInPictureSupported() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    final bool isPipSupported =
        (await videoPlayerController!.isPictureInPictureSupported()) ?? false;

    return isPipSupported && !_isFullScreen;
  }

  /// 处理底层视频事件：播放、暂停、完成、缓冲、画中画等
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
        // 保存画中画退出原因
        _lastPipExitReason = event.pipExitReason;
        await _processPipExit();
        break;
      default:
        break;
    }
  }

  /// 处理画中画退出：根据退出原因决定播放行为
  Future<void> _processPipExit() async {
    if (_disposed) {
      return;
    }
    
    // 退出画中画和全屏
    await checkAndExitPictureInPicture();
    
    // 恢复控件状态
    if (_wasControlsEnabledBeforePiP) {
      setControlsEnabled(true);
    }
    
    // 根据退出原因处理播放状态
    if (_lastPipExitReason == 'return') {
      // 返回按钮：恢复播放状态
      if (!isPlaying()! && _wasPlayingBeforePause == true) {
        await play();
      }
    } else {
      // 关闭按钮：暂停播放
      await pause();
    }
    
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipStop));
  }

  /// 释放视频播放器：专门处理播放器资源清理
  Future<void> _disposeVideoPlayer() async {
    if (videoPlayerController != null) {
      try {
        await videoPlayerController!.pause();
      } catch (e) {
        IAppPlayerUtils.log("暂停播放器失败: $e");
      }
      
      try {
        await videoPlayerController!.seekTo(Duration.zero);
      } catch (e) {
        IAppPlayerUtils.log("重置播放位置失败: $e");
      }
      
      // 移除所有监听器
      videoPlayerController!.removeListener(_onFullScreenStateChanged);
      videoPlayerController!.removeListener(_onVideoPlayerChanged);
      
      // 释放播放器资源
      await videoPlayerController!.dispose();
      videoPlayerController = null;
    }
  }

  /// 清理播放器状态：不包括UI状态
  void _clearPlayerStates() {
    // 播放状态重置
    _hasCurrentDataSourceStarted = false;
    _hasCurrentDataSourceInitialized = false;
    _videoPlayerValueOnError = null;
    _lastVideoPlayerValue = null;
    _cachedIsLiveStream = null;
    
    // 字幕相关清理
    subtitlesLines.clear();
    _asmsSegmentsLoaded.clear();
    _asmsSegmentsLoading = false;
    _pendingSubtitleSegments = null;
    _lastSubtitleCheckPosition = null;
    renderedSubtitle = null;
    
    // 清理缓冲和画中画状态
    _clearBufferingState();
    _clearPipStates();
  }

  /// 清理画中画相关状态
  void _clearPipStates() {
    _wasInPipMode = false;
    _wasControlsEnabledBeforePiP = false;
    _lastPipExitReason = null;
  }

  /// 恢复最后播放的视频：断点续播功能
  Future<void> restoreLastVideo() async {
    if (_lastDataSource != null) {
      await setupDataSource(_lastDataSource!);
      if (_lastPlayPosition != null) {
        await seekTo(_lastPlayPosition!);
      }
      await play();
    }
  }

  /// 处理缓冲开始：带防抖机制避免频繁事件
  void _handleBufferingStart() {
    if (_disposed) {
      return;
    }

    final now = DateTime.now();

    if (_isCurrentlyBuffering) {
      return;
    }

    _bufferingDebounceTimer?.cancel();

    // 防抖检查：避免频繁状态切换
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

  /// 处理缓冲结束：带防抖机制避免频繁事件
  void _handleBufferingEnd() {
    if (_disposed) {
      return;
    }

    final now = DateTime.now();

    if (!_isCurrentlyBuffering) {
      return;
    }

    _bufferingDebounceTimer?.cancel();

    // 防抖检查：避免频繁状态切换
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

  /// 设置控件始终可见模式
  void setControlsAlwaysVisible(bool controlsAlwaysVisible) {
    _controlsAlwaysVisible = controlsAlwaysVisible;
    _controlsVisibilityStreamController.add(controlsAlwaysVisible);
  }

  /// 重试当前数据源：错误恢复机制
  Future retryDataSource() async {
    await _setupDataSource(_iappPlayerDataSource!);
    if (_videoPlayerValueOnError != null) {
      final position = _videoPlayerValueOnError!.position;
      await seekTo(position);
      await play();
      _videoPlayerValueOnError = null;
    }
  }

  /// 设置音频轨道：多语言音轨支持
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

  /// 设置音频混音模式：与其他应用音频混合
  void setMixWithOthers(bool mixWithOthers) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化");
    }

    videoPlayerController!.setMixWithOthers(mixWithOthers);
  }

  /// 清除播放器缓存
  Future<void> clearCache() async {
    return VideoPlayerController.clearCache();
  }

  /// 构建HTTP请求头：包含DRM令牌等
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

  /// 预缓存视频数据：提前下载减少播放延迟
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

  /// 停止预缓存任务
  Future<void> stopPreCache(
      IAppPlayerDataSource iappPlayerDataSource) async {
    return VideoPlayerController?.stopPreCache(iappPlayerDataSource.url,
        iappPlayerDataSource.cacheConfiguration?.key);
  }

  /// 设置控件配置
  void setIAppPlayerControlsConfiguration(
      IAppPlayerControlsConfiguration iappPlayerControlsConfiguration) {
    this._iappPlayerControlsConfiguration = iappPlayerControlsConfiguration;
  }

  /// 发送内部控制器事件
  void _postControllerEvent(IAppPlayerControllerEvent event) {
    if (_disposed || _controllerEventStreamController.isClosed) {
      return;
    }
    _controllerEventStreamController.add(event);
  }

  /// 设置缓冲防抖时间：调整缓冲事件敏感度
  void setBufferingDebounceTime(int milliseconds) {
    if (milliseconds < 0) {
      return;
    }
    _bufferingDebounceMs = milliseconds;
  }

  /// 清理缓冲状态
  void _clearBufferingState() {
    _bufferingDebounceTimer?.cancel();
    _bufferingDebounceTimer = null;
    _isCurrentlyBuffering = false;
    _lastBufferingChangeTime = null;
  }

  /// 清理所有对象引用：dispose专用
  void _clearAllReferences() {
    // 清理集合
    _iappPlayerSubtitlesSourceList.clear();
    _iappPlayerAsmsTracks.clear();
    
    // 置空对象引用
    _playlistController = null;
    _iappPlayerDataSource = null;
    _iappPlayerSubtitlesSource = null;
    _iappPlayerAsmsTrack = null;
    _iappPlayerAsmsAudioTracks = null;
    _iappPlayerAsmsAudioTrack = null;
    _lastDataSource = null;
    _lastPlayPosition = null;
  }

  /// 销毁控制器：释放所有资源防止内存泄漏
  Future<void> dispose({bool forceDispose = false}) async {
    if (!iappPlayerConfiguration.autoDispose && !forceDispose) {
      return;
    }
    if (!_disposed) {
      _disposed = true;
      
      // 取消所有定时器
      _nextVideoTimer?.cancel();
      _nextVideoTimer = null;
      _bufferingDebounceTimer?.cancel();
      _bufferingDebounceTimer = null;
      
      // 取消视频事件订阅
      await _videoEventStreamSubscription?.cancel();
      _videoEventStreamSubscription = null;
      
      // 清理事件监听器
      _eventListeners.clear();
      
      // 释放播放器资源
      if (videoPlayerController != null) {
        await _disposeVideoPlayer();
      }
      
      // 关闭所有流控制器
      if (!_controllerEventStreamController.isClosed) {
        await _controllerEventStreamController.close();
      }
      if (!_nextVideoTimeStreamController.isClosed) {
        await _nextVideoTimeStreamController.close();
      }
      if (!_controlsVisibilityStreamController.isClosed) {
        await _controlsVisibilityStreamController.close();
      }
      
      // 清理状态和引用
      _clearPlayerStates();
      _clearAllReferences();
      
      // 清理临时文件
      await _clearTempFiles();
    }
  }
}
