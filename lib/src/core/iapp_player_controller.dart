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

// 管理视频播放状态、数据源、字幕和事件
class IAppPlayerController {
  static const String _durationParameter = "duration"; // 定义持续时间参数
  static const String _progressParameter = "progress"; // 定义进度参数
  static const String _bufferedParameter = "buffered"; // 定义缓冲参数
  static const String _volumeParameter = "volume"; // 定义音量参数
  static const String _speedParameter = "speed"; // 定义速度参数
  static const String _dataSourceParameter = "dataSource"; // 定义数据源参数
  static const String _authorizationHeader = "Authorization"; // 定义授权头

  final IAppPlayerConfiguration iappPlayerConfiguration; // 存储播放器配置
  final IAppPlayerPlaylistConfiguration? iappPlayerPlaylistConfiguration; // 存储播放列表配置
  IAppPlayerPlaylistController? _playlistController; // 存储播放列表控制器

  // 设置播放列表控制器
  set playlistController(IAppPlayerPlaylistController? controller) {
    _playlistController = controller; // 更新播放列表控制器
  }

  final List<Function(IAppPlayerEvent)?> _eventListeners = []; // 存储事件监听器
  final List<File> _tempFiles = []; // 存储临时文件
  final StreamController<bool> _controlsVisibilityStreamController = StreamController.broadcast(); // 控制控件显示状态流
  VideoPlayerController? videoPlayerController; // 存储视频播放器控制器
  late IAppPlayerControlsConfiguration _iappPlayerControlsConfiguration; // 存储控件配置

  // 获取控件配置
  IAppPlayerControlsConfiguration get iappPlayerControlsConfiguration => _iappPlayerControlsConfiguration;

  // 获取事件监听器（排除第一个）
  List<Function(IAppPlayerEvent)?> get eventListeners => _eventListeners.sublist(1);

  // 获取全局事件监听器
  Function(IAppPlayerEvent)? get eventListener => iappPlayerConfiguration.eventListener;

  bool _isFullScreen = false; // 跟踪全屏模式状态

  // 获取全屏状态
  bool get isFullScreen => _isFullScreen;

  int _lastPositionSelection = 0; // 记录上次进度事件时间
  IAppPlayerDataSource? _iappPlayerDataSource; // 存储当前数据源

  // 获取当前数据源
  IAppPlayerDataSource? get iappPlayerDataSource => _iappPlayerDataSource;

  final List<IAppPlayerSubtitlesSource> _iappPlayerSubtitlesSourceList = []; // 存储字幕源列表

  // 获取字幕源列表
  List<IAppPlayerSubtitlesSource> get iappPlayerSubtitlesSourceList => _iappPlayerSubtitlesSourceList;

  IAppPlayerSubtitlesSource? _iappPlayerSubtitlesSource; // 存储当前字幕源

  // 获取当前字幕源
  IAppPlayerSubtitlesSource? get iappPlayerSubtitlesSource => _iappPlayerSubtitlesSource;

  List<IAppPlayerSubtitle> subtitlesLines = []; // 存储当前字幕行
  List<IAppPlayerAsmsTrack> _iappPlayerAsmsTracks = []; // 存储HLS/DASH轨道列表

  // 获取轨道列表
  List<IAppPlayerAsmsTrack> get iappPlayerAsmsTracks => _iappPlayerAsmsTracks;

  IAppPlayerAsmsTrack? _iappPlayerAsmsTrack; // 存储当前轨道

  // 获取当前轨道
  IAppPlayerAsmsTrack? get iappPlayerAsmsTrack => _iappPlayerAsmsTrack;

  Timer? _nextVideoTimer; // 存储下一视频定时器

  // 获取播放列表控制器
  IAppPlayerPlaylistController? get playlistController => _playlistController;

  int? _nextVideoTime; // 存储下一视频剩余时间
  final StreamController<int?> _nextVideoTimeStreamController = StreamController.broadcast(); // 控制下一视频时间流

  // 获取下一视频时间流
  Stream<int?> get nextVideoTimeStream => _nextVideoTimeStreamController.stream;

  bool _disposed = false; // 跟踪控制器销毁状态

  // 获取销毁状态
  bool get isDisposed => _disposed;

  bool? _wasPlayingBeforePause; // 记录暂停前播放状态
  IAppPlayerTranslations translations = IAppPlayerTranslations(); // 存储翻译配置
  bool _hasCurrentDataSourceStarted = false; // 跟踪数据源启动状态
  bool _hasCurrentDataSourceInitialized = false; // 跟踪数据源初始化状态

  // 获取控件显示状态流
  Stream<bool> get controlsVisibilityStream => _controlsVisibilityStreamController.stream;

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed; // 跟踪应用生命周期状态
  bool _controlsEnabled = true; // 跟踪控件启用状态

  // 获取控件启用状态
  bool get controlsEnabled => _controlsEnabled;

  double? _overriddenAspectRatio; // 存储覆盖宽高比
  BoxFit? _overriddenFit; // 存储覆盖适配模式
  bool _wasInPipMode = false; // 跟踪画中画模式状态
  bool _wasInFullScreenBeforePiP = false; // 记录画中画前全屏状态
  bool _wasControlsEnabledBeforePiP = false; // 记录画中画前控件状态
  String? _lastPipExitReason; // 记录画中画退出原因
  GlobalKey? _iappPlayerGlobalKey; // 存储全局键

  // 获取全局键
  GlobalKey? get iappPlayerGlobalKey => _iappPlayerGlobalKey;

  StreamSubscription<VideoEvent>? _videoEventStreamSubscription; // 存储视频事件流订阅
  bool _controlsAlwaysVisible = false; // 跟踪控件始终可见状态

  // 获取控件始终可见状态
  bool get controlsAlwaysVisible => _controlsAlwaysVisible;

  List<IAppPlayerAsmsAudioTrack>? _iappPlayerAsmsAudioTracks; // 存储ASMS音频轨道列表

  // 获取音频轨道列表
  List<IAppPlayerAsmsAudioTrack>? get iappPlayerAsmsAudioTracks => _iappPlayerAsmsAudioTracks;

  IAppPlayerAsmsAudioTrack? _iappPlayerAsmsAudioTrack; // 存储当前音频轨道

  // 获取当前音频轨道
  IAppPlayerAsmsAudioTrack? get iappPlayerAsmsAudioTrack => _iappPlayerAsmsAudioTrack;

  VideoPlayerValue? _videoPlayerValueOnError; // 存储错误时播放器值
  bool _isPlayerVisible = true; // 跟踪播放器可见性
  final StreamController<IAppPlayerControllerEvent> _controllerEventStreamController = StreamController.broadcast(); // 控制内部事件流

  // 获取内部事件流
  Stream<IAppPlayerControllerEvent> get controllerEventStream => _controllerEventStreamController.stream;

  bool _asmsSegmentsLoading = false; // 跟踪ASMS字幕段加载状态
  final Set<String> _asmsSegmentsLoaded = {}; // 存储已加载的ASMS字幕段
  IAppPlayerSubtitle? renderedSubtitle; // 存储当前显示字幕
  VideoPlayerValue? _lastVideoPlayerValue; // 存储缓存播放器值
  Timer? _bufferingDebounceTimer; // 存储缓冲防抖定时器
  bool _isCurrentlyBuffering = false; // 跟踪当前缓冲状态
  DateTime? _lastBufferingChangeTime; // 记录上次缓冲状态变更时间
  int _bufferingDebounceMs = 500; // 设置缓冲防抖时间（毫秒）
  bool _playlistShuffleMode = false; // 跟踪播放列表随机模式

  // 获取随机模式状态
  bool get playlistShuffleMode => _playlistShuffleMode;

  bool? _cachedIsLiveStream; // 缓存直播流检测结果
  List<IAppPlayerAsmsSubtitleSegment>? _pendingSubtitleSegments; // 存储字幕段缓存
  Duration? _lastSubtitleCheckPosition; // 记录上次字幕检查位置
  static const int _subtitleWindowSize = 300; // 设置字幕滑动窗口大小
  static const Duration _subtitleWindowDuration = Duration(minutes: 10); // 设置字幕滑动窗口时长

  // 初始化配置和数据源
  IAppPlayerController(
    this.iappPlayerConfiguration, {
    this.iappPlayerPlaylistConfiguration,
    IAppPlayerDataSource? iappPlayerDataSource,
  }) {
    _iappPlayerControlsConfiguration = iappPlayerConfiguration.controlsConfiguration; // 设置控件配置
    _eventListeners.add(eventListener); // 添加全局事件监听器
    if (iappPlayerDataSource != null) {
      setupDataSource(iappPlayerDataSource); // 初始化数据源
    }
  }

  // 从上下文获取控制器
  static IAppPlayerController of(BuildContext context) {
    final betterPLayerControllerProvider = context
        .dependOnInheritedWidgetOfExactType<IAppPlayerControllerProvider>()!;
    return betterPLayerControllerProvider.controller; // 返回控制器实例
  }

  // 设置数据源并初始化
  Future setupDataSource(IAppPlayerDataSource iappPlayerDataSource) async {
    await _clearTempFiles(); // 清理旧临时文件
    postEvent(IAppPlayerEvent(IAppPlayerEventType.setupDataSource,
        parameters: <String, dynamic>{_dataSourceParameter: iappPlayerDataSource})); // 发送数据源设置事件
    _postControllerEvent(IAppPlayerControllerEvent.setupDataSource); // 发送控制器事件
    _hasCurrentDataSourceStarted = false; // 重置数据源启动状态
    _hasCurrentDataSourceInitialized = false; // 重置数据源初始化状态
    _iappPlayerDataSource = iappPlayerDataSource; // 更新当前数据源
    _iappPlayerSubtitlesSourceList.clear(); // 清空字幕源列表
    _clearBufferingState(); // 清理缓冲状态
    _cachedIsLiveStream = null; // 重置直播流缓存
    _pendingSubtitleSegments = null; // 清空字幕段缓存
    _lastSubtitleCheckPosition = null; // 重置字幕检查位置

    if (videoPlayerController == null) {
      videoPlayerController = VideoPlayerController(
          bufferingConfiguration: iappPlayerDataSource.bufferingConfiguration); // 创建视频播放器控制器
      videoPlayerController?.addListener(_onVideoPlayerChanged); // 添加播放器状态监听
    }

    iappPlayerAsmsTracks.clear(); // 清空轨道列表

    final List<IAppPlayerSubtitlesSource>? iappPlayerSubtitlesSourceList =
        iappPlayerDataSource.subtitles;
    if (iappPlayerSubtitlesSourceList != null) {
      _iappPlayerSubtitlesSourceList.addAll(iappPlayerDataSource.subtitles!); // 添加字幕源
    }

    if (_isDataSourceAsms(iappPlayerDataSource)) {
      await _setupAsmsDataSource(iappPlayerDataSource); // 配置HLS/DASH数据源
      _setupSubtitles(); // 配置字幕
    } else {
      _setupSubtitles(); // 配置字幕
    }

    await _setupDataSource(iappPlayerDataSource); // 设置数据源
    setTrack(IAppPlayerAsmsTrack.defaultTrack()); // 设置默认轨道
  }

  // 清理临时文件
  Future<void> _clearTempFiles() async {
    for (final file in _tempFiles) {
      try {
        if (await file.exists()) {
          await file.delete(); // 删除存在的临时文件
        }
      } catch (e) {
        IAppPlayerUtils.log("删除临时文件失败: $e"); // 记录删除失败日志
      }
    }
    _tempFiles.clear(); // 清空临时文件列表
  }

  // 配置字幕源
  void _setupSubtitles() {
    _iappPlayerSubtitlesSourceList.add(
      IAppPlayerSubtitlesSource(type: IAppPlayerSubtitlesSourceType.none)); // 添加无字幕选项
    final defaultSubtitle = _iappPlayerSubtitlesSourceList
        .firstWhereOrNull((element) => element.selectedByDefault == true); // 查找默认字幕

    setupSubtitleSource(
        defaultSubtitle ?? _iappPlayerSubtitlesSourceList.last,
        sourceInitialize: true); // 设置默认或最后字幕源
  }

  // 检查是否为HLS/DASH数据源
  bool _isDataSourceAsms(IAppPlayerDataSource iappPlayerDataSource) =>
      (IAppPlayerAsmsUtils.isDataSourceHls(iappPlayerDataSource.url) ||
          iappPlayerDataSource.videoFormat == IAppPlayerVideoFormat.hls) ||
      (IAppPlayerAsmsUtils.isDataSourceDash(iappPlayerDataSource.url) ||
          iappPlayerDataSource.videoFormat == IAppPlayerVideoFormat.dash);

  // 配置HLS/DASH数据源
  Future _setupAsmsDataSource(IAppPlayerDataSource source) async {
    final String? data = await IAppPlayerAsmsUtils.getDataFromUrl(
      iappPlayerDataSource!.url,
      _getHeaders()); // 获取数据源内容
    if (data != null) {
      final IAppPlayerAsmsDataHolder _response =
          await IAppPlayerAsmsUtils.parse(data, iappPlayerDataSource!.url); // 解析数据

      if (_iappPlayerDataSource?.useAsmsTracks == true) {
        _iappPlayerAsmsTracks = _response.tracks ?? []; // 更新轨道列表
      }

      if (iappPlayerDataSource?.useAsmsSubtitles == true) {
        final List<IAppPlayerAsmsSubtitle> asmsSubtitles = _response.subtitles ?? [];
        asmsSubtitles.forEach((IAppPlayerAsmsSubtitle asmsSubtitle) {
          _iappPlayerSubtitlesSourceList.add(
            IAppPlayerSubtitlesSource(
              type: IAppPlayerSubtitlesSourceType.network,
              name: asmsSubtitle.name,
              urls: asmsSubtitle.realUrls,
              asmsIsSegmented: asmsSubtitle.isSegmented,
              asmsSegmentsTime: asmsSubtitle.segmentsTime,
              asmsSegments: asmsSubtitle.segments,
              selectedByDefault: asmsSubtitle.isDefault)); // 添加字幕源
        });
      }

      if (iappPlayerDataSource?.useAsmsAudioTracks == true &&
          _isDataSourceAsms(iappPlayerDataSource!)) {
        _iappPlayerAsmsAudioTracks = _response.audios ?? []; // 更新音频轨道
        if (_iappPlayerAsmsAudioTracks?.isNotEmpty == true) {
          setAudioTrack(_iappPlayerAsmsAudioTracks!.first); // 设置默认音频轨道
        }
      }
    }
  }

  // 设置字幕源并加载
  Future<void> setupSubtitleSource(IAppPlayerSubtitlesSource subtitlesSource,
      {bool sourceInitialize = false}) async {
    _iappPlayerSubtitlesSource = subtitlesSource; // 更新当前字幕源
    subtitlesLines.clear(); // 清空字幕行
    _asmsSegmentsLoaded.clear(); // 清空已加载字幕段
    _asmsSegmentsLoading = false; // 重置加载状态
    _pendingSubtitleSegments = null; // 清空字幕段缓存
    _lastSubtitleCheckPosition = null; // 重置字幕检查位置

    if (subtitlesSource.type != IAppPlayerSubtitlesSourceType.none) {
      if (subtitlesSource.asmsIsSegmented == true) {
        return; // 分段字幕不立即加载
      }
      try {
        final subtitlesParsed =
            await IAppPlayerSubtitlesFactory.parseSubtitles(subtitlesSource); // 解析字幕
        subtitlesLines.addAll(subtitlesParsed); // 添加解析后的字幕
      } catch (e) {
        IAppPlayerUtils.log("字幕加载失败: $e"); // 记录字幕加载失败日志
      }
    }

    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedSubtitles)); // 发送字幕变更事件
    if (!_disposed && !sourceInitialize) {
      _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles); // 发送控制器字幕变更事件
    }
  }

  // 加载ASMS字幕段
  Future _loadAsmsSubtitlesSegments(Duration position) async {
    try {
      if (_asmsSegmentsLoading) {
        return; // 避免重复加载
      }

      if (_lastSubtitleCheckPosition != null) {
        final positionDiff =
            (position.inMilliseconds - _lastSubtitleCheckPosition!.inMilliseconds).abs();
        if (positionDiff < 1000) {
          return; // 避免频繁检查
        }
      }
      _lastSubtitleCheckPosition = position; // 更新字幕检查位置

      _asmsSegmentsLoading = true; // 设置加载状态
      final IAppPlayerSubtitlesSource? source = _iappPlayerSubtitlesSource;
      final Duration loadDurationEnd = Duration(
          milliseconds: position.inMilliseconds +
              5 * (_iappPlayerSubtitlesSource?.asmsSegmentsTime ?? 5000)); // 计算加载时间范围

      if (_pendingSubtitleSegments == null) {
        _pendingSubtitleSegments = _iappPlayerSubtitlesSource?.asmsSegments
            ?.where((segment) => !_asmsSegmentsLoaded.contains(segment.realUrl))
            .toList() ?? []; // 初始化待加载字幕段
      }

      final segmentsToLoad = <String>[]; // 存储待加载段
      final segmentsToRemove = <IAppPlayerAsmsSubtitleSegment>[]; // 存储待移除段

      for (final segment in _pendingSubtitleSegments!) {
        if (segment.startTime > position && segment.endTime < loadDurationEnd) {
          segmentsToLoad.add(segment.realUrl); // 添加待加载段
          segmentsToRemove.add(segment); // 添加待移除段
        }
      }

      if (segmentsToRemove.isNotEmpty) {
        _pendingSubtitleSegments!.removeWhere((s) => segmentsToRemove.contains(s)); // 移除已加载段
      }

      if (segmentsToLoad.isNotEmpty) {
        final subtitlesParsed =
            await IAppPlayerSubtitlesFactory.parseSubtitles(
                IAppPlayerSubtitlesSource(
          type: _iappPlayerSubtitlesSource!.type,
          headers: _iappPlayerSubtitlesSource!.headers,
          urls: segmentsToLoad)); // 解析字幕段

        if (source == _iappPlayerSubtitlesSource) {
          subtitlesLines.addAll(subtitlesParsed); // 添加解析后的字幕
          _asmsSegmentsLoaded.addAll(segmentsToLoad); // 更新已加载段
          
          _cleanupOldSubtitles(position); // 清理过期字幕
        }
      }
      _asmsSegmentsLoading = false; // 重置加载状态
    } catch (exception) {
      IAppPlayerUtils.log("加载ASMS字幕段失败: $exception"); // 记录加载失败日志
    }
  }

  // 清理过期字幕（滑动窗口机制）
  void _cleanupOldSubtitles(Duration currentPosition) {
    if (subtitlesLines.length <= _subtitleWindowSize) {
      return; // 字幕数量未超限
    }

    final minTime = currentPosition - _subtitleWindowDuration; // 计算时间窗口下限
    final maxTime = currentPosition + _subtitleWindowDuration; // 计算时间窗口上限

    subtitlesLines.removeWhere((subtitle) {
      final startTime = subtitle.start;
      final endTime = subtitle.end;
      return endTime != null && 
             (endTime < minTime || (startTime != null && startTime > maxTime)); // 移除时间窗口外字幕
    });

    if (subtitlesLines.length > _subtitleWindowSize) {
      bool needsSort = false;
      for (int i = 1; i < subtitlesLines.length; i++) {
        final prevStart = subtitlesLines[i-1].start?.inMilliseconds ?? 0;
        final currStart = subtitlesLines[i].start?.inMilliseconds ?? 0;
        if (prevStart > currStart) {
          needsSort = true;
          break;
        }
      }
      
      if (needsSort) {
        subtitlesLines.sort((a, b) {
          final aStart = a.start?.inMilliseconds ?? 0;
          final bStart = b.start?.inMilliseconds ?? 0;
          return aStart.compareTo(bStart); // 按开始时间排序
        });
      }

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

      final halfWindow = _subtitleWindowSize ~/ 2;
      final startIndex = (currentIndex - halfWindow).clamp(0, subtitlesLines.length); // 计算保留范围起始
      final endIndex = (currentIndex + halfWindow).clamp(0, subtitlesLines.length); // 计算保留范围结束

      subtitlesLines = subtitlesLines.sublist(startIndex, endIndex); // 保留窗口内字幕
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
    return path.startsWith('assets/') || path.startsWith('asset://'); // 检查路径前缀
  }

  // 从asset创建临时文件
  Future<File> _createFileFromAsset(String assetPath) async {
    try {
      final cleanPath = assetPath.startsWith('asset://') 
          ? assetPath.substring(8) 
          : assetPath; // 移除asset前缀
      final ByteData data = await rootBundle.load(cleanPath); // 读取asset数据
      final List<int> bytes = data.buffer.asUint8List(); // 转换为字节列表
      final String extension = cleanPath.split('.').last; // 获取文件扩展名
      final tempFile = await _createFile(bytes, extension: extension); // 创建临时文件
      return tempFile;
    } catch (e) {
      throw Exception('无法从asset加载文件: $assetPath, 错误: $e'); // 抛出加载失败异常
    }
  }

  // 设置数据源
  Future _setupDataSource(IAppPlayerDataSource iappPlayerDataSource) async {
    switch (iappPlayerDataSource.type) {
      case IAppPlayerDataSourceType.network:
        await videoPlayerController?.setNetworkDataSource(
          iappPlayerDataSource.url,
          headers: _getHeaders(),
          useCache: _iappPlayerDataSource!.cacheConfiguration?.useCache ?? false,
          maxCacheSize: _iappPlayerDataSource!.cacheConfiguration?.maxCacheSize ?? 0,
          maxCacheFileSize: _iappPlayerDataSource!.cacheConfiguration?.maxCacheFileSize ?? 0,
          cacheKey: _iappPlayerDataSource?.cacheConfiguration?.key,
          showNotification: _iappPlayerDataSource?.notificationConfiguration?.showNotification,
          title: _iappPlayerDataSource?.notificationConfiguration?.title,
          author: _iappPlayerDataSource?.notificationConfiguration?.author,
          imageUrl: _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
          notificationChannelName: _iappPlayerDataSource?.notificationConfiguration?.notificationChannelName,
          overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
          formatHint: _getVideoFormat(_iappPlayerDataSource!.videoFormat),
          licenseUrl: _iappPlayerDataSource?.drmConfiguration?.licenseUrl,
          certificateUrl: _iappPlayerDataSource?.drmConfiguration?.certificateUrl,
          drmHeaders: _iappPlayerDataSource?.drmConfiguration?.headers,
          activityName: _iappPlayerDataSource?.notificationConfiguration?.activityName,
          clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey,
          videoExtension: _iappPlayerDataSource!.videoExtension,
          preferredDecoderType: _iappPlayerDataSource?.preferredDecoderType); // 设置网络数据源
        break;
      case IAppPlayerDataSourceType.file:
        if (_isAssetPath(iappPlayerDataSource.url)) {
          IAppPlayerUtils.log("检测到asset路径: ${iappPlayerDataSource.url}，将从asset加载"); // 记录asset路径日志
          final tempFile = await _createFileFromAsset(iappPlayerDataSource.url); // 从asset创建临时文件
          _tempFiles.add(tempFile); // 添加到临时文件列表
          await videoPlayerController?.setFileDataSource(
              tempFile,
              showNotification: _iappPlayerDataSource?.notificationConfiguration?.showNotification,
              title: _iappPlayerDataSource?.notificationConfiguration?.title,
              author: _iappPlayerDataSource?.notificationConfiguration?.author,
              imageUrl: _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
              notificationChannelName: _iappPlayerDataSource?.notificationConfiguration?.notificationChannelName,
              overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
              activityName: _iappPlayerDataSource?.notificationConfiguration?.activityName,
              clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey); // 设置文件数据源
        } else {
          final file = File(iappPlayerDataSource.url); // 创建文件对象
          await videoPlayerController?.setFileDataSource(
              file,
              showNotification: _iappPlayerDataSource?.notificationConfiguration?.showNotification,
              title: _iappPlayerDataSource?.notificationConfiguration?.title,
              author: _iappPlayerDataSource?.notificationConfiguration?.author,
              imageUrl: _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
              notificationChannelName: _iappPlayerDataSource?.notificationConfiguration?.notificationChannelName,
              overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
              activityName: _iappPlayerDataSource?.notificationConfiguration?.activityName,
              clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey); // 设置文件数据源
        }
        break;
      case IAppPlayerDataSourceType.memory:
        final file = await _createFile(_iappPlayerDataSource!.bytes!, extension: _iappPlayerDataSource!.videoExtension); // 从内存创建临时文件
        if (file.existsSync()) {
          await videoPlayerController?.setFileDataSource(file,
              showNotification: _iappPlayerDataSource?.notificationConfiguration?.showNotification,
              title: _iappPlayerDataSource?.notificationConfiguration?.title,
              author: _iappPlayerDataSource?.notificationConfiguration?.author,
              imageUrl: _iappPlayerDataSource?.notificationConfiguration?.imageUrl,
              notificationChannelName: _iappPlayerDataSource?.notificationConfiguration?.notificationChannelName,
              overriddenDuration: _iappPlayerDataSource!.overriddenDuration,
              activityName: _iappPlayerDataSource?.notificationConfiguration?.activityName,
              clearKey: _iappPlayerDataSource?.drmConfiguration?.clearKey); // 设置文件数据源
          _tempFiles.add(file); // 添加到临时文件列表
        } else {
          throw ArgumentError("无法从内存创建文件"); // 抛出文件创建失败异常
        }
        break;
      default:
        throw UnimplementedError("${iappPlayerDataSource.type} 未实现"); // 抛出未实现异常
    }
    await _initializeVideo(); // 初始化视频
  }

  // 创建临时文件
  Future<File> _createFile(List<int> bytes, {String? extension = "temp"}) async {
    final String dir = (await getTemporaryDirectory()).path; // 获取临时目录
    final File temp = File('$dir/iapp_player_${DateTime.now().millisecondsSinceEpoch}.$extension'); // 创建临时文件
    await temp.writeAsBytes(bytes); // 写入字节数据
    return temp;
  }

  // 初始化视频
  Future _initializeVideo() async {
    if (isPlaylistMode) {
      setLooping(false); // 播放列表模式禁用循环
    } else {
      setLooping(iappPlayerConfiguration.looping); // 设置循环配置
    }
    _videoEventStreamSubscription?.cancel(); // 取消现有视频事件订阅
    _videoEventStreamSubscription = null;

    _videoEventStreamSubscription = videoPlayerController
        ?.videoEventStreamController.stream
        .listen(_handleVideoEvent); // 订阅视频事件

    final fullScreenByDefault = iappPlayerConfiguration.fullScreenByDefault; // 获取默认全屏配置
    final shouldAutoPlay = iappPlayerConfiguration.autoPlay || (iappPlayerPlaylistConfiguration != null); // 判断是否自动播放
    
    if (shouldAutoPlay) {
      if (fullScreenByDefault && !isFullScreen) {
        enterFullScreen(); // 进入全屏
      }
      if (_isAutomaticPlayPauseHandled()) {
        if (_appLifecycleState == AppLifecycleState.resumed && _isPlayerVisible) {
          await play(); // 播放视频
        } else {
          _wasPlayingBeforePause = true; // 记录暂停前播放状态
        }
      } else {
        await play(); // 播放视频
      }
    } else {
      if (fullScreenByDefault) {
        enterFullScreen(); // 进入全屏
      }
    }

    final startAt = iappPlayerConfiguration.startAt;
    if (startAt != null) {
      seekTo(startAt); // 跳转到指定位置
    }
  }

  // 处理全屏状态变化
  Future<void> _onFullScreenStateChanged() async {
    if (videoPlayerController?.value.isPlaying == true && !_isFullScreen) {
      enterFullScreen(); // 进入全屏
      videoPlayerController?.removeListener(_onFullScreenStateChanged); // 移除监听
    }
  }

  // 进入全屏模式
  void enterFullScreen() {
    _isFullScreen = true; // 设置全屏状态
    _postControllerEvent(IAppPlayerControllerEvent.openFullscreen); // 发送全屏事件
  }

  // 退出全屏模式
  void exitFullScreen() {
    _isFullScreen = false; // 重置全屏状态
    _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen); // 发送退出全屏事件
  }

  // 切换全屏模式
  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen; // 切换全屏状态
    if (_isFullScreen) {
      _postControllerEvent(IAppPlayerControllerEvent.openFullscreen); // 发送全屏事件
    } else {
      _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen); // 发送退出全屏事件
    }
  }

  // 播放视频
  Future<void> play() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }

    if (_appLifecycleState == AppLifecycleState.resumed) {
      await videoPlayerController!.play(); // 播放视频
      _hasCurrentDataSourceStarted = true; // 更新数据源启动状态
      _wasPlayingBeforePause = null; // 重置暂停前状态
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.play)); // 发送播放事件
      _postControllerEvent(IAppPlayerControllerEvent.play); // 发送控制器播放事件
    }
  }

  // 设置循环播放
  Future<void> setLooping(bool looping) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    await videoPlayerController!.setLooping(looping); // 设置循环状态
  }

  // 暂停视频
  Future<void> pause() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    await videoPlayerController!.pause(); // 暂停播放
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.pause)); // 发送暂停事件
  }

  // 跳转到指定位置
  Future<void> seekTo(Duration moment) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    if (videoPlayerController?.value.duration == null) {
      throw StateError("视频未初始化"); // 抛出视频未初始化异常
    }
    await videoPlayerController!.seekTo(moment); // 跳转到指定时间
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.seekTo,
        parameters: <String, dynamic>{_durationParameter: moment})); // 发送跳转事件
    final Duration? currentDuration = videoPlayerController!.value.duration;
    if (currentDuration == null) {
      return;
    }
    if (moment > currentDuration) {
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.finished)); // 发送播放结束事件
    } else {
      cancelNextVideoTimer(); // 取消下一视频定时器
    }
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      IAppPlayerUtils.log("音量必须在 0.0 到 1.0 之间"); // 记录音量范围错误
      throw ArgumentError("音量必须在 0.0 到 1.0 之间"); // 抛出音量范围异常
    }
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化"); // 记录未初始化错误
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    await videoPlayerController!.setVolume(volume); // 设置音量
    _postEvent(IAppPlayerEvent(
      IAppPlayerEventType.setVolume,
      parameters: <String, dynamic>{_volumeParameter: volume})); // 发送音量设置事件
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    if (speed <= 0 || speed > 2) {
      IAppPlayerUtils.log("速度必须在 0 到 2 之间"); // 记录速度范围错误
      throw ArgumentError("速度必须在 0 到 2 之间"); // 抛出速度范围异常
    }
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化"); // 记录未初始化错误
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    await videoPlayerController?.setSpeed(speed); // 设置播放速度
    _postEvent(IAppPlayerEvent(
      IAppPlayerEventType.setSpeed,
      parameters: <String, dynamic>{_speedParameter: speed})); // 发送速度设置事件
  }

  // 检查播放状态
  bool? isPlaying() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    return videoPlayerController!.value.isPlaying; // 返回播放状态
  }

  // 检查缓冲状态
  bool? isBuffering() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    return videoPlayerController!.value.isBuffering; // 返回缓冲状态
  }

  // 设置控件可见性
  void setControlsVisibility(bool isVisible) {
    _controlsVisibilityStreamController.add(isVisible); // 更新控件可见性
  }

  // 启用/禁用控件
  void setControlsEnabled(bool enabled) {
    if (!enabled) {
      _controlsVisibilityStreamController.add(false); // 禁用时隐藏控件
    }
    _controlsEnabled = enabled; // 更新控件启用状态
  }

  // 触发控件显示/隐藏事件
  void toggleControlsVisibility(bool isVisible) {
    _postEvent(isVisible
        ? IAppPlayerEvent(IAppPlayerEventType.controlsVisible)
        : IAppPlayerEvent(IAppPlayerEventType.controlsHiddenEnd)); // 发送控件显示/隐藏事件
  }

  // 发送播放器事件
  void postEvent(IAppPlayerEvent iappPlayerEvent) {
    _postEvent(iappPlayerEvent); // 广播事件
  }

  // 广播事件
  void _postEvent(IAppPlayerEvent iappPlayerEvent) {
    if (_disposed) {
      return; // 已销毁时不处理
    }
    if (iappPlayerEvent.iappPlayerEventType == IAppPlayerEventType.changedPlaylistShuffle) {
      _playlistShuffleMode = iappPlayerEvent.parameters?['shuffleMode'] ?? false; // 更新随机模式
      _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles); // 发送字幕变更事件
    }
    for (final Function(IAppPlayerEvent)? eventListener in _eventListeners) {
      if (eventListener != null) {
        eventListener(iappPlayerEvent); // 通知所有监听器
      }
    }
  }

  // 检查播放列表模式
  bool get isPlaylistMode => iappPlayerPlaylistConfiguration != null || _playlistController != null;

  // 切换播放列表随机模式
  void togglePlaylistShuffle() {
    if (isPlaylistMode) {
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.togglePlaylistShuffle)); // 发送随机模式切换事件
    }
  }

  // 处理播放器状态变化
  void _onVideoPlayerChanged() async {
    if (_disposed) {
      return; // 已销毁时不处理
    }
    final currentValue = videoPlayerController?.value;
    if (currentValue == null) {
      return; // 无有效值时返回
    }
    if (_lastVideoPlayerValue != null) {
      final hasPositionChanged = currentValue.position != _lastVideoPlayerValue!.position;
      final hasPlayingChanged = currentValue.isPlaying != _lastVideoPlayerValue!.isPlaying;
      final hasBufferingChanged = currentValue.isBuffering != _lastVideoPlayerValue!.isBuffering;
      final hasErrorChanged = currentValue.hasError != _lastVideoPlayerValue!.hasError;
      final hasPipChanged = currentValue.isPip != _lastVideoPlayerValue!.isPip;
      if (!hasPositionChanged && !hasPlayingChanged && !hasBufferingChanged && !hasErrorChanged && !hasPipChanged) {
        return; // 无变化时返回
      }
    }
    if (currentValue.hasError && _videoPlayerValueOnError == null) {
      _videoPlayerValueOnError = currentValue; // 记录错误状态
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.exception,
          parameters: <String, dynamic>{"exception": currentValue.errorDescription})); // 发送异常事件
    }
    if (currentValue.initialized && !_hasCurrentDataSourceInitialized) {
      _hasCurrentDataSourceInitialized = true; // 更新初始化状态
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.initialized)); // 发送初始化事件
    }
    if (currentValue.isPip) {
      _wasInPipMode = true; // 进入画中画模式
    } else if (_wasInPipMode) {
      _wasInPipMode = false; // 退出画中画模式
      Future.delayed(Duration(milliseconds: 300), () {
        if (!_disposed) {
          videoPlayerController?.refresh(); // 延迟刷新播放器
        }
      });
    }
    if (_iappPlayerSubtitlesSource?.asmsIsSegmented == true) {
      _loadAsmsSubtitlesSegments(currentValue.position); // 加载分段字幕
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPositionSelection > 500) {
      _lastPositionSelection = now; // 更新进度选择时间
      _postEvent(IAppPlayerEvent(IAppPlayerEventType.progress,
          parameters: <String, dynamic>{
            _progressParameter: currentValue.position,
            _durationParameter: currentValue.duration
          })); // 发送进度事件
    }
    _lastVideoPlayerValue = currentValue; // 更新缓存值
  }

  // 检查并退出画中画模式
  Future<void> checkAndExitPictureInPicture() async {
    try {
      if (videoPlayerController?.value.isPip == true) {
        await disablePictureInPicture(); // 退出画中画
        await Future.delayed(Duration(milliseconds: 300)); // 等待退出完成
      }
      if (_isFullScreen) {
        exitFullScreen(); // 退出全屏
        await Future.delayed(Duration(milliseconds: 200)); // 等待退出完成
        if (_isFullScreen) {
          _isFullScreen = false; // 强制退出全屏
          _postControllerEvent(IAppPlayerControllerEvent.hideFullscreen); // 发送退出全屏事件
          _postControllerEvent(IAppPlayerControllerEvent.changeSubtitles); // 强制刷新UI
        }
      }
    } catch (e) {
      IAppPlayerUtils.log("退出画中画失败: $e"); // 记录退出失败日志
    }
  }

  // 添加事件监听器
  void addEventsListener(Function(IAppPlayerEvent) eventListener) {
    if (!_eventListeners.contains(eventListener)) {
      _eventListeners.add(eventListener); // 添加不重复的监听器
    }
  }

  // 移除事件监听器
  void removeEventsListener(Function(IAppPlayerEvent) eventListener) {
    _eventListeners.remove(eventListener); // 移除指定监听器
  }

  // 检查是否为直播流
  bool isLiveStream() {
    if (_iappPlayerDataSource == null) {
      IAppPlayerUtils.log("数据源未初始化"); // 记录未初始化错误
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    if (_cachedIsLiveStream != null) {
      return _cachedIsLiveStream!; // 返回缓存结果
    }
    if (_iappPlayerDataSource!.liveStream == true) {
      _cachedIsLiveStream = true;
      return true; // 直播流明确配置
    }
    final url = _iappPlayerDataSource!.url.toLowerCase();
    if (url.contains('rtmp://') || url.contains('.m3u8') || url.contains('.flv') ||
        url.contains('rtsp://') || url.contains('mms://') || url.contains('rtmps://')) {
      _cachedIsLiveStream = true;
      return true; // 根据URL判断直播流
    }
    _cachedIsLiveStream = false;
    return false; // 非直播流
  }

  // 检查视频初始化状态
  bool? isVideoInitialized() {
    if (videoPlayerController == null) {
      IAppPlayerUtils.log("数据源未初始化"); // 记录未初始化错误
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    return videoPlayerController?.value.initialized; // 返回初始化状态
  }

  // 启动下一视频定时器
  void startNextVideoTimer() {
    if (_nextVideoTimer == null) {
      if (iappPlayerPlaylistConfiguration == null) {
        IAppPlayerUtils.log("播放列表配置未设置"); // 记录配置错误
        throw StateError("播放列表配置未设置"); // 抛出配置异常
      }
      _nextVideoTime = iappPlayerPlaylistConfiguration!.nextVideoDelay.inSeconds; // 设置定时器时间
      _nextVideoTimeStreamController.add(_nextVideoTime); // 更新时间流
      if (_nextVideoTime == 0) {
        return;
      }
      _nextVideoTimer = Timer.periodic(const Duration(milliseconds: 1000), (_timer) async {
        if (_nextVideoTime == 1) {
          _timer.cancel();
          _nextVideoTimer = null; // 停止定时器
        }
        if (_nextVideoTime != null) {
          _nextVideoTime = _nextVideoTime! - 1; // 减少剩余时间
        }
        _nextVideoTimeStreamController.add(_nextVideoTime); // 更新时间流
      });
    }
  }

  // 取消下一视频定时器
  void cancelNextVideoTimer() {
    _nextVideoTime = null; // 重置时间
    _nextVideoTimeStreamController.add(_nextVideoTime); // 更新时间流
    _nextVideoTimer?.cancel(); // 取消定时器
    _nextVideoTimer = null;
  }

  // 播放下一视频
  void playNextVideo() {
    _nextVideoTime = 0; // 重置时间
    _nextVideoTimeStreamController.add(_nextVideoTime); // 更新时间流
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedPlaylistItem)); // 发送播放列表变更事件
    cancelNextVideoTimer(); // 取消定时器
  }

  // 设置轨道
  void setTrack(IAppPlayerAsmsTrack track) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
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
        })); // 发送轨道变更事件
    videoPlayerController!.setTrackParameters(track.width, track.height, track.bitrate); // 设置轨道参数
    _iappPlayerAsmsTrack = track; // 更新当前轨道
  }

  // 检查自动播放/暂停支持
  bool _isAutomaticPlayPauseHandled() {
    return !(_iappPlayerDataSource?.notificationConfiguration?.showNotification == true) &&
        iappPlayerConfiguration.handleLifecycle; // 判断是否支持自动播放/暂停
  }

  // 处理可见性变化
  void onPlayerVisibilityChanged(double visibilityFraction) async {
    _isPlayerVisible = visibilityFraction > 0; // 更新可见性状态
    if (_disposed) {
      return;
    }
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedPlayerVisibility)); // 发送可见性变更事件
    if (_isAutomaticPlayPauseHandled()) {
      if (iappPlayerConfiguration.playerVisibilityChangedBehavior != null) {
        iappPlayerConfiguration.playerVisibilityChangedBehavior!(visibilityFraction); // 执行自定义行为
      } else {
        if (visibilityFraction == 0) {
          _wasPlayingBeforePause ??= isPlaying(); // 记录暂停前状态
          pause(); // 暂停播放
        } else {
          if (_wasPlayingBeforePause == true && !isPlaying()!) {
            play(); // 恢复播放
          }
        }
      }
    }
  }

  // 设置分辨率
  void setResolution(String url) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    final position = await videoPlayerController!.position; // 获取当前播放位置
    final wasPlayingBeforeChange = isPlaying()!; // 记录变更前播放状态
    pause(); // 暂停播放
    await setupDataSource(iappPlayerDataSource!.copyWith(url: url)); // 设置新数据源
    seekTo(position!); // 恢复播放位置
    if (wasPlayingBeforeChange) {
      play(); // 恢复播放
    }
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.changedResolution,
        parameters: <String, dynamic>{"url": url})); // 发送分辨率变更事件
  }

  // 设置翻译
  void setupTranslations(Locale locale) {
    if (locale != null) {
      final String languageCode = locale.languageCode;
      translations = iappPlayerConfiguration.translations?.firstWhereOrNull(
              (translations) => translations.languageCode == languageCode) ??
          _getDefaultTranslations(locale); // 设置翻译或默认翻译
    } else {
      IAppPlayerUtils.log("语言环境为空，无法设置翻译"); // 记录语言环境错误
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
              (countryCode == "TW" || countryCode == "HK" || countryCode == "MO"))) {
        return IAppPlayerTranslations.traditionalChinese(); // 返回繁体中文翻译
      }
      return IAppPlayerTranslations.chinese(); // 返回简体中文翻译
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
        return IAppPlayerTranslations(); // 返回默认翻译
    }
  }

  // 获取数据源启动状态
  bool get hasCurrentDataSourceStarted => _hasCurrentDataSourceStarted;

  // 设置生命周期状态
  void setAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (_isAutomaticPlayPauseHandled()) {
      _appLifecycleState = appLifecycleState; // 更新生命周期状态
      if (appLifecycleState == AppLifecycleState.resumed) {
        if (_wasPlayingBeforePause == true && _isPlayerVisible) {
          play(); // 恢复播放
        }
      }
      if (appLifecycleState == AppLifecycleState.paused) {
        _wasPlayingBeforePause ??= isPlaying(); // 记录暂停前状态
        pause(); // 暂停播放
      }
    }
  }

  // 设置宽高比
  void setOverriddenAspectRatio(double aspectRatio) {
    _overriddenAspectRatio = aspectRatio; // 更新覆盖宽高比
  }

  // 获取宽高比
  double? getAspectRatio() {
    return _overriddenAspectRatio ?? iappPlayerConfiguration.aspectRatio; // 返回覆盖或默认宽高比
  }

  // 设置适配模式
  void setOverriddenFit(BoxFit fit) {
    _overriddenFit = fit; // 更新覆盖适配模式
  }

  // 获取适配模式
  BoxFit getFit() {
    return _overriddenFit ?? iappPlayerConfiguration.fit; // 返回覆盖或默认适配模式
  }

  // 启用画中画
  Future<void>? enablePictureInPicture(GlobalKey iappPlayerGlobalKey) async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    final bool isPipSupported =
        (await videoPlayerController!.isPictureInPictureSupported()) ?? false; // 检查画中画支持
    if (isPipSupported) {
      _wasInFullScreenBeforePiP = _isFullScreen; // 记录全屏状态
      _wasControlsEnabledBeforePiP = _controlsEnabled; // 记录控件状态
      _wasPlayingBeforePause = isPlaying(); // 记录播放状态
      setControlsEnabled(false); // 禁用控件
      _iappPlayerGlobalKey = iappPlayerGlobalKey; // 设置全局键
      if (Platform.isAndroid || Platform.isIOS) {
        await videoPlayerController?.enablePictureInPicture(); // 启用画中画
        _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipStart)); // 发送画中画开始事件
        return;
      } else {
        IAppPlayerUtils.log("当前平台不支持画中画"); // 记录平台不支持日志
      }
    } else {
      IAppPlayerUtils.log("设备不支持画中画，Android 请检查是否使用活动 v2 嵌入"); // 记录不支持日志
    }
  }

  // 禁用画中画
  Future<void>? disablePictureInPicture() {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    return videoPlayerController!.disablePictureInPicture(); // 禁用画中画
  }

  // 设置全局键
  void setIAppPlayerGlobalKey(GlobalKey iappPlayerGlobalKey) {
    _iappPlayerGlobalKey = iappPlayerGlobalKey; // 更新全局键
  }

  // 检查画中画支持
  Future<bool> isPictureInPictureSupported() async {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    final bool isPipSupported =
        (await videoPlayerController!.isPictureInPictureSupported()) ?? false; // 检查画中画支持
    return isPipSupported && !_isFullScreen; // 返回支持状态
  }

  // 处理视频事件
  void _handleVideoEvent(VideoEvent event) async {
    if (_disposed) {
      return; // 已销毁时不处理
    }
    switch (event.eventType) {
      case VideoEventType.play:
        _postEvent(IAppPlayerEvent(IAppPlayerEventType.play)); // 发送播放事件
        break;
      case VideoEventType.pause:
        _postEvent(IAppPlayerEvent(IAppPlayerEventType.pause)); // 发送暂停事件
        break;
      case VideoEventType.seek:
        _postEvent(IAppPlayerEvent(IAppPlayerEventType.seekTo)); // 发送跳转事件
        break;
      case VideoEventType.completed:
        final VideoPlayerValue? videoValue = videoPlayerController?.value;
        _postEvent(IAppPlayerEvent(IAppPlayerEventType.finished,
            parameters: <String, dynamic>{
              _progressParameter: videoValue?.position,
              _durationParameter: videoValue?.duration
            })); // 发送播放结束事件
        break;
      case VideoEventType.bufferingStart:
        _handleBufferingStart(); // 处理缓冲开始
        break;
      case VideoEventType.bufferingUpdate:
        _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingUpdate,
            parameters: <String, dynamic>{_bufferedParameter: event.buffered})); // 发送缓冲更新事件
        break;
      case VideoEventType.bufferingEnd:
        _handleBufferingEnd(); // 处理缓冲结束
        break;
      case VideoEventType.pipStop:
        _lastPipExitReason = event.pipExitReason; // 记录退出原因
        await _processPipExit(); // 处理画中画退出
        break;
      default:
        break;
    }
  }

  // 处理画中画退出
  Future<void> _processPipExit() async {
    if (_disposed) {
      return; // 已销毁时不处理
    }
    await checkAndExitPictureInPicture(); // 退出画中画和全屏
    if (_wasControlsEnabledBeforePiP) {
      setControlsEnabled(true); // 恢复控件状态
    }
    if (_lastPipExitReason == 'return') {
      if (!isPlaying()! && _wasPlayingBeforePause == true) {
        await play(); // 恢复播放
      }
    } else if (_lastPipExitReason == 'close') {
      await pause(); // 暂停播放
    } else {
      await pause(); // 默认暂停
    }
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.pipStop)); // 发送画中画停止事件
    _lastPipExitReason = null; // 重置退出原因
  }

  // 处理缓冲开始
  void _handleBufferingStart() {
    if (_disposed) {
      return; // 已销毁时不处理
    }
    final now = DateTime.now();
    if (_isCurrentlyBuffering) {
      return; // 已缓冲时返回
    }
    _bufferingDebounceTimer?.cancel(); // 取消现有防抖定时器
    if (_lastBufferingChangeTime != null) {
      final timeSinceLastChange = now.difference(_lastBufferingChangeTime!).inMilliseconds;
      if (timeSinceLastChange < _bufferingDebounceMs) {
        _bufferingDebounceTimer = Timer(
          Duration(milliseconds: _bufferingDebounceMs - timeSinceLastChange),
          () {
            if (!_disposed && !_isCurrentlyBuffering) {
              _isCurrentlyBuffering = true;
              _lastBufferingChangeTime = DateTime.now();
              _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingStart)); // 发送缓冲开始事件
            }
          });
        return;
      }
    }
    _isCurrentlyBuffering = true; // 设置缓冲状态
    _lastBufferingChangeTime = now; // 更新缓冲时间
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingStart)); // 发送缓冲开始事件
  }

  // 处理缓冲结束
  void _handleBufferingEnd() {
    if (_disposed) {
      return; // 已销毁时不处理
    }
    final now = DateTime.now();
    if (!_isCurrentlyBuffering) {
      return; // 未缓冲时返回
    }
    _bufferingDebounceTimer?.cancel(); // 取消现有防抖定时器
    if (_lastBufferingChangeTime != null) {
      final timeSinceLastChange = now.difference(_lastBufferingChangeTime!).inMilliseconds;
      if (timeSinceLastChange < _bufferingDebounceMs) {
        _bufferingDebounceTimer = Timer(
          Duration(milliseconds: _bufferingDebounceMs - timeSinceLastChange),
          () {
            if (!_disposed && _isCurrentlyBuffering) {
              _isCurrentlyBuffering = false;
              _lastBufferingChangeTime = DateTime.now();
              _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingEnd)); // 发送缓冲结束事件
            }
          });
        return;
      }
    }
    _isCurrentlyBuffering = false; // 重置缓冲状态
    _lastBufferingChangeTime = now; // 更新缓冲时间
    _postEvent(IAppPlayerEvent(IAppPlayerEventType.bufferingEnd)); // 发送缓冲结束事件
  }

  // 设置控件始终可见
  void setControlsAlwaysVisible(bool controlsAlwaysVisible) {
    _controlsAlwaysVisible = controlsAlwaysVisible; // 更新控件可见性状态
    _controlsVisibilityStreamController.add(controlsAlwaysVisible); // 更新控件可见性流
  }

  // 重试数据源
  Future retryDataSource() async {
    await _setupDataSource(_iappPlayerDataSource!); // 重新设置数据源
    if (_videoPlayerValueOnError != null) {
      final position = _videoPlayerValueOnError!.position; // 获取错误时位置
      await seekTo(position); // 跳转到错误位置
      await play(); // 恢复播放
      _videoPlayerValueOnError = null; // 重置错误值
    }
  }

  // 设置音频轨道
  void setAudioTrack(IAppPlayerAsmsAudioTrack audioTrack) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    if (audioTrack.language == null) {
      _iappPlayerAsmsAudioTrack = null; // 重置音频轨道
      return;
    }
    _iappPlayerAsmsAudioTrack = audioTrack; // 更新当前音频轨道
    videoPlayerController!.setAudioTrack(audioTrack.label, audioTrack.id); // 设置音频轨道
  }

  // 设置音频混音
  void setMixWithOthers(bool mixWithOthers) {
    if (videoPlayerController == null) {
      throw StateError("数据源未初始化"); // 抛出未初始化异常
    }
    videoPlayerController!.setMixWithOthers(mixWithOthers); // 设置混音状态
  }

  // 清除缓存
  Future<void> clearCache() async {
    return VideoPlayerController.clearCache(); // 清除播放器缓存
  }

  // 构建请求头
  Map<String, String?> _getHeaders() {
    final headers = iappPlayerDataSource!.headers ?? {};
    if (iappPlayerDataSource?.drmConfiguration?.drmType == IAppPlayerDrmType.token &&
        iappPlayerDataSource?.drmConfiguration?.token != null) {
      headers[_authorizationHeader] = iappPlayerDataSource!.drmConfiguration!.token!; // 添加授权头
    }
    return headers;
  }

  // 预缓存数据
  Future<void> preCache(IAppPlayerDataSource iappPlayerDataSource) async {
    final cacheConfig = iappPlayerDataSource.cacheConfiguration ??
        const IAppPlayerCacheConfiguration(useCache: true); // 获取缓存配置
    final dataSource = DataSource(
      sourceType: DataSourceType.network,
      uri: iappPlayerDataSource.url,
      useCache: true,
      headers: iappPlayerDataSource.headers,
      maxCacheSize: cacheConfig.maxCacheSize,
      maxCacheFileSize: cacheConfig.maxCacheFileSize,
      cacheKey: cacheConfig.key,
      videoExtension: iappPlayerDataSource.videoExtension); // 构建数据源
    return VideoPlayerController.preCache(dataSource, cacheConfig.preCacheSize); // 预缓存数据
  }

  // 停止预缓存
  Future<void> stopPreCache(IAppPlayerDataSource iappPlayerDataSource) async {
    return VideoPlayerController?.stopPreCache(iappPlayerDataSource.url,
        iappPlayerDataSource.cacheConfiguration?.key); // 停止预缓存
  }

  // 设置控件配置
  void setIAppPlayerControlsConfiguration(IAppPlayerControlsConfiguration iappPlayerControlsConfiguration) {
    this._iappPlayerControlsConfiguration = iappPlayerControlsConfiguration; // 更新控件配置
  }

  // 发送内部事件
  void _postControllerEvent(IAppPlayerControllerEvent event) {
    if (_disposed || _controllerEventStreamController.isClosed) {
      return; // 已销毁或流关闭时返回
    }
    _controllerEventStreamController.add(event); // 发送控制器事件
  }

  // 设置缓冲防抖时间
  void setBufferingDebounceTime(int milliseconds) {
    if (milliseconds < 0) {
      return; // 无效时间返回
    }
    _bufferingDebounceMs = milliseconds; // 更新防抖时间
  }

  // 清理缓冲状态
  void _clearBufferingState() {
    _bufferingDebounceTimer?.cancel(); // 取消防抖定时器
    _bufferingDebounceTimer = null;
    _isCurrentlyBuffering = false; // 重置缓冲状态
    _lastBufferingChangeTime = null; // 重置缓冲时间
  }

  // 销毁控制器
  Future<void> dispose({bool forceDispose = false}) async {
    if (!iappPlayerConfiguration.autoDispose && !forceDispose) {
      return; // 非自动销毁且非强制销毁时返回
    }
    if (!_disposed) {
      _disposed = true; // 设置销毁状态
      _nextVideoTimer?.cancel(); // 取消下一视频定时器
      _nextVideoTimer = null;
      _bufferingDebounceTimer?.cancel(); // 取消缓冲防抖定时器
      _bufferingDebounceTimer = null;
      await _videoEventStreamSubscription?.cancel(); // 取消视频事件订阅
      _videoEventStreamSubscription = null;
      _eventListeners.clear(); // 清空事件监听器
      if (videoPlayerController != null) {
        videoPlayerController!.removeListener(_onFullScreenStateChanged); // 移除全屏监听
        videoPlayerController!.removeListener(_onVideoPlayerChanged); // 移除状态监听
      }
      if (!_controllerEventStreamController.isClosed) {
        await _controllerEventStreamController.close(); // 关闭控制器事件流
      }
      if (!_nextVideoTimeStreamController.isClosed) {
        await _nextVideoTimeStreamController.close(); // 关闭下一视频时间流
      }
      if (!_controlsVisibilityStreamController.isClosed) {
        await _controlsVisibilityStreamController.close(); // 关闭控件可见性流
      }
      if (videoPlayerController != null) {
        await videoPlayerController!.pause(); // 暂停播放
        await videoPlayerController!.dispose(); // 销毁播放器
        videoPlayerController = null;
      }
      _clearBufferingState(); // 清理缓冲状态
      _cachedIsLiveStream = null; // 重置直播流缓存
      _pendingSubtitleSegments = null; // 清空字幕段缓存
      _lastSubtitleCheckPosition = null; // 重置字幕检查位置
      await _clearTempFiles(); // 清理临时文件
    }
  }
}
