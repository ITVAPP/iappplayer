import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// 封装播放器返回结果
class PlayerResult {
  final IAppPlayerController? controller; // 单视频控制器
  final IAppPlayerPlaylistController? playlistController; // 播放列表控制器
  final bool isPlaylist; // 标识是否为播放列表模式

  PlayerResult({
    this.controller,
    this.playlistController,
    this.isPlaylist = false,
  });

  // 获取当前活动控制器
  IAppPlayerController? get activeController {
    return isPlaylist && playlistController != null
        ? playlistController!.iappPlayerController
        : controller;
  }
}

// URL格式检测结果
class _UrlFormatInfo {
  final bool isLiveStream; // 直播流标志
  final IAppPlayerVideoFormat format; // 视频格式

  _UrlFormatInfo(this.isLiveStream, this.format);
}

// LRU缓存管理器
class _CacheManager {
  static const int maxCacheEntries = 1000; // 缓存最大条目数
  static final LinkedHashMap<String, _UrlFormatInfo> urlFormatCache =
      LinkedHashMap<String, _UrlFormatInfo>(); // URL格式检测缓存

  // 缓存清理方法
  static void ensureCacheSize<K, V>(LinkedHashMap<K, V> cache, int maxSize) {
    if (cache.length <= maxSize) return;
    
    final removeCount = cache.length - maxSize;
    final keysToRemove = <K>[];
    
    // 收集需要删除的键
    var count = 0;
    for (final key in cache.keys) {
      if (count >= removeCount) break;
      keysToRemove.add(key);
      count++;
    }
    
    // 批量删除
    for (final key in keysToRemove) {
      cache.remove(key);
    }
  }

  // 清空所有缓存
  static void clearAll() {
    urlFormatCache.clear();
  }
}

// 视频播放器统一配置管理
class IAppPlayerConfig {
  static const int _preCacheSize = 10 * 1024 * 1024; // 预缓存10MB
  static const int _maxCacheSize = 300 * 1024 * 1024; // 最大缓存300MB
  static const int _maxCacheFileSize = 50 * 1024 * 1024; // 单文件最大50MB
  static const int _liveMinBufferMs = 15000; // 直播最小缓冲15秒
  static const int _vodMinBufferMs = 20000; // 点播最小缓冲20秒
  static const int _liveMaxBufferMs = 15000; // 直播最大缓冲15秒
  static const int _vodMaxBufferMs = 30000; // 点播最大缓冲30秒
  static const int _bufferForPlaybackMs = 3000; // 播放缓冲3秒
  static const int _bufferForPlaybackAfterRebufferMs = 5000; // 重新缓冲后播放5秒
  static const String _defaultVideoTitlePrefix = '视频 '; // 默认视频标题前缀
  static const String _defaultSubtitleName = '字幕'; // 默认字幕名称
  static const String _defaultActivityName = 'MainActivity'; // 默认活动名称
  static const BoxFit _defaultImageFit = BoxFit.cover; // 默认图片缩放模式
  static const FilterQuality _defaultImageQuality = FilterQuality.medium; // 默认图片质量
  static const double _defaultRotation = 0; // 默认旋转角度
  static const Duration defaultNextVideoDelay = Duration(seconds: 1); // 默认播放列表切换延迟
  
  // URL格式检测相关常量
  static const String _hlsExtension = '.m3u8';
  static const String _dashExtension = '.mpd';
  static const String _flvExtension = '.flv';
  static const String _smoothStreamingExtension = '.ism';
  static const String _rtmpProtocol = 'rtmp://';
  static const String _rtmpsProtocol = 'rtmps://';
  static const String _rtspProtocol = 'rtsp://';
  static const String _rtspsProtocol = 'rtsps://';

  // 创建播放器实例
  static Future<PlayerResult> createPlayer({
    String? url, // 单个视频URL
    List<String>? urls, // 播放列表URLs
    Function(IAppPlayerEvent)? eventListener, // 事件监听器
    String? title, // 视频标题
    List<String>? titles, // 播放列表标题
    String? imageUrl, // 视频封面
    List<String>? imageUrls, // 播放列表封面
    String? author, // 通知作者
    String? notificationChannelName, // 通知渠道名
    String? subtitleUrl, // 字幕文件URL
    String? subtitleContent, // 字幕内容
    List<String>? subtitleUrls, // 播放列表字幕URL
    List<String>? subtitleContents, // 播放列表字幕内容
    List<IAppPlayerSubtitlesSource>? subtitles, // 高级字幕配置
    bool autoPlay = true, // 自动播放
    bool loopVideos = true, // 播放列表循环
    bool? looping, // 单视频循环
    Duration? startAt, // 起始播放位置
    bool isTV = false, // TV模式
    bool? audioOnly, // 纯音频模式
    String? backgroundImage, // 背景图片
    Duration? nextVideoDelay, // 视频切换延迟
    int? initialStartIndex, // 起始播放索引
    bool? shuffleMode, // 随机播放模式
    Map<String, String>? headers, // HTTP请求头
    IAppPlayerVideoFormat? videoFormat, // 视频格式
    String? videoExtension, // 视频扩展名
    bool? liveStream, // 直播流标志
    IAppPlayerDecoderType? preferredDecoderType, // 解码器类型
    Widget? placeholder, // 占位图
    Widget Function(BuildContext, String?)? errorBuilder, // 错误界面构建器
    Widget? overlay, // 覆盖层
    double? aspectRatio, // 宽高比
    BoxFit? fit, // 缩放模式
    double? rotation, // 旋转角度
    IAppPlayerConfiguration? playerConfiguration, // 播放器配置
    IAppPlayerControlsConfiguration? controlsConfiguration, // 控件配置
    IAppPlayerSubtitlesConfiguration? subtitlesConfiguration, // 字幕配置
    IAppPlayerBufferingConfiguration? bufferingConfiguration, // 缓冲配置
    IAppPlayerCacheConfiguration? cacheConfiguration, // 缓存配置
    IAppPlayerNotificationConfiguration? notificationConfiguration, // 通知配置
    IAppPlayerDrmConfiguration? drmConfiguration, // DRM配置
    bool? enableSubtitles, // 启用字幕
    bool? enableQualities, // 启用画质选择
    bool? enableAudioTracks, // 启用音轨选择
    bool? enableFullscreen, // 启用全屏
    bool? enableOverflowMenu, // 启用更多菜单
    bool? handleAllGestures, // 处理所有手势
    bool? fullScreenByDefault, // 默认全屏
    double? fullScreenAspectRatio, // 全屏宽高比
    List<DeviceOrientation>? deviceOrientationsOnFullScreen, // 全屏设备方向
    List<DeviceOrientation>? deviceOrientationsAfterFullScreen, // 退出全屏设备方向
    bool? handleLifecycle, // 处理生命周期
    bool? autoDispose, // 自动释放资源
    Map<String, String>? resolutions, // 分辨率映射
    bool? useAsmsTracks, // 使用HLS轨道
    bool? useAsmsAudioTracks, // 使用音轨
    bool? useAsmsSubtitles, // 使用内嵌字幕
    Duration? overriddenDuration, // 覆盖视频时长
    bool? allowedScreenSleep, // 允许屏幕休眠
    bool? expandToFill, // 扩展填充
    IAppPlayerDataSourceType? dataSourceType, // 数据源类型
    bool? showNotification, // 显示通知
    bool? showPlaceholderUntilPlay, // 播放前显示占位符
    bool? placeholderOnTop, // 占位符置顶
    List<SystemUiOverlay>? systemOverlaysAfterFullScreen, // 退出全屏后系统UI
    IAppPlayerRoutePageBuilder? routePageBuilder, // 自定义路由页面构建器
    List<IAppPlayerTranslations>? translations, // 多语言翻译配置
    bool? autoDetectFullscreenDeviceOrientation, // 自动检测全屏设备方向
    bool? autoDetectFullscreenAspectRatio, // 自动检测全屏宽高比
    bool? useRootNavigator, // 使用根导航器
    Function(double)? playerVisibilityChangedBehavior, // 播放器可见性变化回调
  }) async {
    // 验证参数互斥性
    if (url != null && urls != null) {
      throw ArgumentError('不能同时设置单个视频URL和播放列表URLs');
    }
    
    // 检查参数有效性
    if (url == null && (urls == null || urls.isEmpty)) {
      return PlayerResult();
    }

    // 判断播放模式并创建对应播放器
    final bool isPlaylist = urls != null && urls.isNotEmpty;
    
    if (isPlaylist) {
      // 播放列表模式
      return _createPlaylistPlayer(
        urls: urls,
        titles: titles,
        imageUrls: imageUrls,
        defaultTitle: title,
        defaultImageUrl: imageUrl,
        defaultAuthor: author,
        defaultNotificationChannelName: notificationChannelName,
        subtitleUrls: subtitleUrls,
        subtitleContents: subtitleContents,
        loopVideos: loopVideos,
        nextVideoDelay: nextVideoDelay,
        initialStartIndex: initialStartIndex,
        shuffleMode: shuffleMode,
        liveStream: liveStream,
        eventListener: eventListener,
        subtitleUrl: subtitleUrl,
        subtitleContent: subtitleContent,
        subtitles: subtitles,
        autoPlay: autoPlay,
        looping: looping,
        startAt: startAt,
        isTV: isTV,
        audioOnly: audioOnly,
        backgroundImage: backgroundImage,
        headers: headers,
        videoFormat: videoFormat,
        videoExtension: videoExtension,
        preferredDecoderType: preferredDecoderType,
        placeholder: placeholder,
        errorBuilder: errorBuilder,
        overlay: overlay,
        aspectRatio: aspectRatio,
        fit: fit,
        rotation: rotation,
        playerConfiguration: playerConfiguration,
        controlsConfiguration: controlsConfiguration,
        subtitlesConfiguration: subtitlesConfiguration,
        bufferingConfiguration: bufferingConfiguration,
        cacheConfiguration: cacheConfiguration,
        notificationConfiguration: notificationConfiguration,
        drmConfiguration: drmConfiguration,
        enableSubtitles: enableSubtitles,
        enableQualities: enableQualities,
        enableAudioTracks: enableAudioTracks,
        enableFullscreen: enableFullscreen,
        enableOverflowMenu: enableOverflowMenu,
        handleAllGestures: handleAllGestures,
        fullScreenByDefault: fullScreenByDefault,
        fullScreenAspectRatio: fullScreenAspectRatio,
        deviceOrientationsOnFullScreen: deviceOrientationsOnFullScreen,
        deviceOrientationsAfterFullScreen: deviceOrientationsAfterFullScreen,
        handleLifecycle: handleLifecycle,
        autoDispose: autoDispose,
        resolutions: resolutions,
        useAsmsTracks: useAsmsTracks,
        useAsmsAudioTracks: useAsmsAudioTracks,
        useAsmsSubtitles: useAsmsSubtitles,
        overriddenDuration: overriddenDuration,
        allowedScreenSleep: allowedScreenSleep,
        expandToFill: expandToFill,
        dataSourceType: dataSourceType,
        showNotification: showNotification,
        showPlaceholderUntilPlay: showPlaceholderUntilPlay,
        placeholderOnTop: placeholderOnTop,
        systemOverlaysAfterFullScreen: systemOverlaysAfterFullScreen,
        routePageBuilder: routePageBuilder,
        translations: translations,
        autoDetectFullscreenDeviceOrientation: autoDetectFullscreenDeviceOrientation,
        autoDetectFullscreenAspectRatio: autoDetectFullscreenAspectRatio,
        useRootNavigator: useRootNavigator,
        playerVisibilityChangedBehavior: playerVisibilityChangedBehavior,
      );
    } else {
      // 单视频模式
      final detectedLiveStream = liveStream ?? _detectUrlFormat(url!).isLiveStream;
      
      // 构建播放器配置
      final configuration = playerConfiguration ?? createPlayerConfig(
        eventListener: eventListener ?? (_) {},
        liveStream: detectedLiveStream,
        autoPlay: autoPlay,
        audioOnly: audioOnly,
        placeholder: placeholder,
        errorBuilder: errorBuilder,
        backgroundImage: backgroundImage,
        overlay: overlay,
        aspectRatio: aspectRatio,
        fit: fit,
        rotation: rotation,
        controlsConfiguration: controlsConfiguration,
        subtitlesConfiguration: subtitlesConfiguration,
        enableSubtitles: enableSubtitles,
        enableQualities: enableQualities,
        enableAudioTracks: enableAudioTracks,
        enableFullscreen: enableFullscreen,
        enableOverflowMenu: enableOverflowMenu,
        handleAllGestures: handleAllGestures,
        fullScreenByDefault: fullScreenByDefault,
        fullScreenAspectRatio: fullScreenAspectRatio,
        deviceOrientationsOnFullScreen: deviceOrientationsOnFullScreen,
        deviceOrientationsAfterFullScreen: deviceOrientationsAfterFullScreen,
        handleLifecycle: handleLifecycle,
        autoDispose: autoDispose,
        looping: looping ?? !detectedLiveStream,
        startAt: startAt,
        allowedScreenSleep: allowedScreenSleep,
        expandToFill: expandToFill,
        showPlaceholderUntilPlay: showPlaceholderUntilPlay,
        placeholderOnTop: placeholderOnTop,
        systemOverlaysAfterFullScreen: systemOverlaysAfterFullScreen,
        routePageBuilder: routePageBuilder,
        translations: translations,
        autoDetectFullscreenDeviceOrientation: autoDetectFullscreenDeviceOrientation,
        autoDetectFullscreenAspectRatio: autoDetectFullscreenAspectRatio,
        useRootNavigator: useRootNavigator,
        playerVisibilityChangedBehavior: playerVisibilityChangedBehavior,
      );

      // 创建数据源
      final dataSource = createDataSource(
        url: url!,
        liveStream: liveStream,
        title: title,
        imageUrl: imageUrl,
        author: author,
        notificationChannelName: notificationChannelName,
        headers: headers,
        isTV: isTV,
        preferredDecoderType: preferredDecoderType,
        subtitles: subtitles,
        subtitleUrl: subtitleUrl,
        subtitleContent: subtitleContent,
        videoFormat: videoFormat,
        videoExtension: videoExtension,
        bufferingConfiguration: bufferingConfiguration,
        cacheConfiguration: cacheConfiguration,
        notificationConfiguration: notificationConfiguration,
        drmConfiguration: drmConfiguration,
        resolutions: resolutions,
        useAsmsTracks: useAsmsTracks,
        useAsmsAudioTracks: useAsmsAudioTracks,
        useAsmsSubtitles: useAsmsSubtitles,
        overriddenDuration: overriddenDuration,
        dataSourceType: dataSourceType,
        showNotification: showNotification,
      );

      // 创建控制器实例
      final controller = IAppPlayerController(
        configuration,
        iappPlayerDataSource: dataSource,
      );

      // 初始化数据源，使播放器可以立即使用
      await controller.setupDataSource(dataSource);

      return PlayerResult(
        controller: controller,
        isPlaylist: false,
      );
    }
  }

  // 创建播放列表播放器
  static PlayerResult _createPlaylistPlayer({
    required List<String> urls,
    List<String>? titles,
    List<String>? imageUrls,
    String? defaultTitle,
    String? defaultImageUrl,
    String? defaultAuthor,
    String? defaultNotificationChannelName,
    List<String>? subtitleUrls,
    List<String>? subtitleContents,
    bool? loopVideos,
    Duration? nextVideoDelay,
    int? initialStartIndex,
    bool? shuffleMode,
    bool? liveStream,
    Function(IAppPlayerEvent)? eventListener,
    String? subtitleUrl,
    String? subtitleContent,
    List<IAppPlayerSubtitlesSource>? subtitles,
    bool autoPlay = true,
    bool? looping,
    Duration? startAt,
    bool isTV = false,
    bool? audioOnly,
    String? backgroundImage,
    Map<String, String>? headers,
    IAppPlayerVideoFormat? videoFormat,
    String? videoExtension,
    IAppPlayerDecoderType? preferredDecoderType,
    Widget? placeholder,
    Widget Function(BuildContext, String?)? errorBuilder,
    Widget? overlay,
    double? aspectRatio,
    BoxFit? fit,
    double? rotation,
    IAppPlayerConfiguration? playerConfiguration,
    IAppPlayerControlsConfiguration? controlsConfiguration,
    IAppPlayerSubtitlesConfiguration? subtitlesConfiguration,
    IAppPlayerBufferingConfiguration? bufferingConfiguration,
    IAppPlayerCacheConfiguration? cacheConfiguration,
    IAppPlayerNotificationConfiguration? notificationConfiguration,
    IAppPlayerDrmConfiguration? drmConfiguration,
    bool? enableSubtitles,
    bool? enableQualities,
    bool? enableAudioTracks,
    bool? enableFullscreen,
    bool? enableOverflowMenu,
    bool? handleAllGestures,
    bool? fullScreenByDefault,
    double? fullScreenAspectRatio,
    List<DeviceOrientation>? deviceOrientationsOnFullScreen,
    List<DeviceOrientation>? deviceOrientationsAfterFullScreen,
    bool? handleLifecycle,
    bool? autoDispose,
    Map<String, String>? resolutions,
    bool? useAsmsTracks,
    bool? useAsmsAudioTracks,
    bool? useAsmsSubtitles,
    Duration? overriddenDuration,
    bool? allowedScreenSleep,
    bool? expandToFill,
    IAppPlayerDataSourceType? dataSourceType,
    bool? showNotification,
    bool? showPlaceholderUntilPlay,
    bool? placeholderOnTop,
    List<SystemUiOverlay>? systemOverlaysAfterFullScreen,
    IAppPlayerRoutePageBuilder? routePageBuilder,
    List<IAppPlayerTranslations>? translations,
    bool? autoDetectFullscreenDeviceOrientation,
    bool? autoDetectFullscreenAspectRatio,
    bool? useRootNavigator,
    Function(double)? playerVisibilityChangedBehavior,
  }) {
    // 检查数据有效性
    final hasTitles = titles != null && titles.isNotEmpty;
    final hasImageUrls = imageUrls != null && imageUrls.isNotEmpty;
    final hasSubtitleUrls = subtitleUrls != null && subtitleUrls.isNotEmpty;
    final hasSubtitleContents = subtitleContents != null && subtitleContents.isNotEmpty;
    
    // 格式检测和数据源创建
    final dataSources = List<IAppPlayerDataSource>.generate(urls.length, (i) {
      // 验证URL有效性
      if (i >= urls.length || urls[i].isEmpty) {
        throw ArgumentError('播放列表中的URL不能为空，索引: $i');
      }
      
      // 获取视频元数据
      final itemTitle = (hasTitles && i < titles!.length)
          ? titles[i]
          : (defaultTitle ?? '$_defaultVideoTitlePrefix${i + 1}');
      final itemImageUrl = (hasImageUrls && i < imageUrls!.length) 
          ? imageUrls[i] 
          : defaultImageUrl;
      final itemAuthor = defaultAuthor;
      final itemNotificationChannelName = defaultNotificationChannelName;
      
      // 处理字幕数据
      final itemSubtitleUrl = (hasSubtitleUrls && i < subtitleUrls!.length) 
          ? subtitleUrls[i] 
          : subtitleUrl;
      final itemSubtitleContent = (hasSubtitleContents && i < subtitleContents!.length) 
          ? subtitleContents[i] 
          : subtitleContent;

      // 创建单个数据源
      return createDataSource(
        url: urls[i],
        liveStream: liveStream,
        title: itemTitle,
        imageUrl: itemImageUrl,
        author: itemAuthor,
        notificationChannelName: itemNotificationChannelName,
        headers: headers,
        isTV: isTV,
        preferredDecoderType: preferredDecoderType,
        subtitles: subtitles,
        subtitleUrl: itemSubtitleUrl,
        subtitleContent: itemSubtitleContent,
        videoFormat: videoFormat,
        videoExtension: videoExtension,
        bufferingConfiguration: bufferingConfiguration,
        cacheConfiguration: cacheConfiguration,
        notificationConfiguration: notificationConfiguration,
        drmConfiguration: drmConfiguration,
        resolutions: resolutions,
        useAsmsTracks: useAsmsTracks,
        useAsmsAudioTracks: useAsmsAudioTracks,
        useAsmsSubtitles: useAsmsSubtitles,
        overriddenDuration: overriddenDuration,
        dataSourceType: dataSourceType,
        showNotification: showNotification,
      );
    });

    // 创建播放列表配置
    final playlistConfig = createPlaylistConfig(
      shuffleMode: shuffleMode ?? false,
      loopVideos: loopVideos ?? true,
      nextVideoDelay: nextVideoDelay ?? defaultNextVideoDelay,
      initialStartIndex: initialStartIndex ?? 0,
    );

    // 创建播放器配置
    final playerConfig = playerConfiguration ?? createPlayerConfig(
      eventListener: eventListener ?? (_) {},
      liveStream: false,
      autoPlay: autoPlay,
      audioOnly: audioOnly,
      placeholder: placeholder,
      errorBuilder: errorBuilder,
      backgroundImage: backgroundImage,
      overlay: overlay,
      aspectRatio: aspectRatio,
      fit: fit,
      rotation: rotation,
      controlsConfiguration: controlsConfiguration,
      subtitlesConfiguration: subtitlesConfiguration,
      enableSubtitles: enableSubtitles,
      enableQualities: enableQualities,
      enableAudioTracks: enableAudioTracks,
      enableFullscreen: enableFullscreen,
      enableOverflowMenu: enableOverflowMenu,
      handleAllGestures: handleAllGestures,
      fullScreenByDefault: fullScreenByDefault,
      fullScreenAspectRatio: fullScreenAspectRatio,
      deviceOrientationsOnFullScreen: deviceOrientationsOnFullScreen,
      deviceOrientationsAfterFullScreen: deviceOrientationsAfterFullScreen,
      handleLifecycle: handleLifecycle,
      autoDispose: autoDispose,
      looping: looping,
      startAt: startAt,
      allowedScreenSleep: allowedScreenSleep,
      expandToFill: expandToFill,
      showPlaceholderUntilPlay: showPlaceholderUntilPlay,
      placeholderOnTop: placeholderOnTop,
      systemOverlaysAfterFullScreen: systemOverlaysAfterFullScreen,
      routePageBuilder: routePageBuilder,
      translations: translations,
      autoDetectFullscreenDeviceOrientation: autoDetectFullscreenDeviceOrientation,
      autoDetectFullscreenAspectRatio: autoDetectFullscreenAspectRatio,
      useRootNavigator: useRootNavigator,
      playerVisibilityChangedBehavior: playerVisibilityChangedBehavior,
    );

    // 创建播放列表控制器
    final playlistController = IAppPlayerPlaylistController(
      dataSources,
      iappPlayerConfiguration: playerConfig,
      iappPlayerPlaylistConfiguration: playlistConfig,
    );

    return PlayerResult(
      playlistController: playlistController,
      isPlaylist: true,
    );
  }

  // 创建自定义数据源的播放列表播放器
  static PlayerResult createPlaylistPlayer({
    required Function(IAppPlayerEvent) eventListener,
    required List<IAppPlayerDataSource> dataSources,
    bool shuffleMode = false,
    bool loopVideos = true,
    Duration nextVideoDelay = defaultNextVideoDelay,
    int initialStartIndex = 0,
    IAppPlayerConfiguration? playerConfiguration,
  }) {
    // 检查数据源有效性
    if (dataSources.isEmpty) {
      return PlayerResult();
    }

    // 创建播放列表配置
    final playlistConfig = createPlaylistConfig(
      shuffleMode: shuffleMode,
      loopVideos: loopVideos,
      nextVideoDelay: nextVideoDelay,
      initialStartIndex: initialStartIndex,
    );

    // 创建播放器配置
    final playerConfig = playerConfiguration ?? createPlayerConfig(
      eventListener: eventListener,
      liveStream: false,
    );

    // 创建播放列表控制器
    final playlistController = IAppPlayerPlaylistController(
      dataSources,
      iappPlayerConfiguration: playerConfig,
      iappPlayerPlaylistConfiguration: playlistConfig,
    );

    return PlayerResult(
      playlistController: playlistController,
      isPlaylist: true,
    );
  }

  // 播放指定视频源
  static Future<void> playSource({
    required IAppPlayerController controller,
    required dynamic source,
    bool? liveStream,
    String? title,
    String? imageUrl,
    String? author,
    String? notificationChannelName,
    bool preloadOnly = false,
    bool isTV = false,
    bool? audioOnly,
    List<IAppPlayerSubtitlesSource>? subtitles,
    String? subtitleUrl,
    String? subtitleContent,
    Map<String, String>? headers,
    IAppPlayerDataSourceType? dataSourceType,
    bool? showNotification,
    IAppPlayerDecoderType? preferredDecoderType,
    IAppPlayerVideoFormat? videoFormat,
    String? videoExtension,
    IAppPlayerBufferingConfiguration? bufferingConfiguration,
    IAppPlayerCacheConfiguration? cacheConfiguration,
    IAppPlayerDrmConfiguration? drmConfiguration,
    Map<String, String>? resolutions,
    bool? useAsmsTracks,
    bool? useAsmsAudioTracks,
    bool? useAsmsSubtitles,
    Duration? overriddenDuration,
    IAppPlayerNotificationConfiguration? notificationConfiguration,
  }) async {
    // 验证数据源类型
    if (source is String) {
      // 预加载时只需要最少的参数
      if (preloadOnly) {
        // 检测URL格式
        final formatInfo = _detectUrlFormat(source);
        final detectedLiveStream = liveStream ?? formatInfo.isLiveStream;
        
        // 创建简化的数据源（只包含网络相关参数）
        final preloadDataSource = IAppPlayerDataSource(
          IAppPlayerDataSourceType.network,
          source,
          videoFormat: videoFormat ?? formatInfo.format,
          liveStream: detectedLiveStream,
          headers: headers,
          bufferingConfiguration: bufferingConfiguration ?? IAppPlayerBufferingConfiguration(
            minBufferMs: detectedLiveStream ? _liveMinBufferMs : _vodMinBufferMs,
            maxBufferMs: detectedLiveStream ? _liveMaxBufferMs : _vodMaxBufferMs,
            bufferForPlaybackMs: _bufferForPlaybackMs,
            bufferForPlaybackAfterRebufferMs: _bufferForPlaybackAfterRebufferMs,
          ),
          cacheConfiguration: cacheConfiguration ?? IAppPlayerCacheConfiguration(
            useCache: !detectedLiveStream,
            preCacheSize: _preCacheSize,
            maxCacheSize: _maxCacheSize,
            maxCacheFileSize: _maxCacheFileSize,
          ),
          // 预加载不需要UI相关参数
        );
        
        // 调用预缓存
        await controller.preCache(preloadDataSource);
        return;
      }

      // 正常播放时需要完整参数
      // 更新音频模式配置
      if (audioOnly != null) {
        final currentControlsConfig = controller.iappPlayerControlsConfiguration;
        final updatedControlsConfig = currentControlsConfig.copyWith(
          audioOnly: audioOnly,
        );
        controller.setIAppPlayerControlsConfiguration(updatedControlsConfig);
      }

      // 构建通知配置
      final finalNotificationConfig = notificationConfiguration ?? (
        (title != null || imageUrl != null || author != null || 
         notificationChannelName != null || showNotification != null)
        ? IAppPlayerNotificationConfiguration(
            showNotification: showNotification,
            title: title,
            author: author,
            imageUrl: imageUrl,
            notificationChannelName: notificationChannelName,
          )
        : null
      );

      // 创建完整数据源
      final dataSource = createDataSource(
        url: source,
        liveStream: liveStream,
        title: title,
        imageUrl: imageUrl,
        author: author,
        notificationChannelName: notificationChannelName,
        isTV: isTV,
        subtitles: subtitles,
        subtitleUrl: subtitleUrl,
        subtitleContent: subtitleContent,
        headers: headers,
        dataSourceType: dataSourceType,
        showNotification: showNotification,
        preferredDecoderType: preferredDecoderType,
        videoFormat: videoFormat,
        videoExtension: videoExtension,
        bufferingConfiguration: bufferingConfiguration,
        cacheConfiguration: cacheConfiguration,
        notificationConfiguration: finalNotificationConfig,
        drmConfiguration: drmConfiguration,
        resolutions: resolutions,
        useAsmsTracks: useAsmsTracks,
        useAsmsAudioTracks: useAsmsAudioTracks,
        useAsmsSubtitles: useAsmsSubtitles,
        overriddenDuration: overriddenDuration,
      );

      // 设置数据源并播放
      await controller.setupDataSource(dataSource);
      await controller.play();
    } else {
      throw ArgumentError('source 必须是 String 类型，当前类型: ${source.runtimeType}');
    }
  }

  // URL格式检测
  static _UrlFormatInfo _detectUrlFormat(String url) {
    // 验证URL有效性
    if (url.isEmpty) return _UrlFormatInfo(false, IAppPlayerVideoFormat.other);

    // 查询缓存
    final cached = _CacheManager.urlFormatCache[url];
    if (cached != null) return cached;

    bool isLiveStream = false;
    IAppPlayerVideoFormat format = IAppPlayerVideoFormat.other;

    // 使用原始URL进行协议检测
    final urlLength = url.length;
    
    // 快速协议检测
    if (urlLength > 7) {
      final firstChar = url[0].toLowerCase();
      if (firstChar == 'r') {
        // 可能是rtmp或rtsp协议
        if (url.substring(0, 7).toLowerCase() == _rtmpProtocol.substring(0, 7) ||
            url.substring(0, 8).toLowerCase() == _rtmpsProtocol.substring(0, 8) ||
            url.substring(0, 7).toLowerCase() == _rtspProtocol.substring(0, 7) ||
            url.substring(0, 8).toLowerCase() == _rtspsProtocol.substring(0, 8)) {
          isLiveStream = true;
        }
      }
    }
    
    // 如果不是直播协议，检查文件扩展名
    if (!isLiveStream) {
      // 查找查询参数位置
      final queryIndex = url.indexOf('?');
      final effectiveLength = queryIndex > 0 ? queryIndex : urlLength;
      
      // 从后向前查找最后一个点的位置
      var lastDotIndex = -1;
      for (var i = effectiveLength - 1; i >= 0; i--) {
        if (url[i] == '.') {
          lastDotIndex = i;
          break;
        }
      }
      
      if (lastDotIndex > 0 && lastDotIndex < effectiveLength - 1) {
        // 提取扩展名并转换为小写
        final extension = url.substring(lastDotIndex, effectiveLength).toLowerCase();
        
        // 使用switch进行快速匹配
        switch (extension) {
          case _hlsExtension:
            format = IAppPlayerVideoFormat.hls;
            isLiveStream = true;
            break;
          case _dashExtension:
            format = IAppPlayerVideoFormat.dash;
            isLiveStream = false;
            break;
          case _flvExtension:
            isLiveStream = true;
            break;
          case _smoothStreamingExtension:
            format = IAppPlayerVideoFormat.ss;
            isLiveStream = false;
            break;
        }
      }
    }

    // 缓存检测结果
    final result = _UrlFormatInfo(isLiveStream, format);
    _CacheManager.urlFormatCache[url] = result;
    _CacheManager.ensureCacheSize(_CacheManager.urlFormatCache, _CacheManager.maxCacheEntries);

    return result;
  }

  // 清理所有缓存
  static void clearAllCaches() {
    _CacheManager.clearAll();
  }
  
  // 创建播放器数据源
  static IAppPlayerDataSource createDataSource({
    required String url,
    bool? liveStream,
    Map<String, String>? headers,
    String? title,
    String? imageUrl,
    String? author,
    String? notificationChannelName,
    bool isTV = false,
    IAppPlayerDecoderType? preferredDecoderType,
    List<IAppPlayerSubtitlesSource>? subtitles,
    String? subtitleUrl,
    String? subtitleContent,
    IAppPlayerVideoFormat? videoFormat,
    String? videoExtension,
    IAppPlayerBufferingConfiguration? bufferingConfiguration,
    IAppPlayerCacheConfiguration? cacheConfiguration,
    IAppPlayerNotificationConfiguration? notificationConfiguration,
    IAppPlayerDrmConfiguration? drmConfiguration,
    Map<String, String>? resolutions,
    bool? useAsmsTracks,
    bool? useAsmsAudioTracks,
    bool? useAsmsSubtitles,
    Duration? overriddenDuration,
    IAppPlayerDataSourceType? dataSourceType,
    bool? showNotification,
    _UrlFormatInfo? formatInfo,
  }) {
    // 验证URL有效性
    final validUrl = url.trim();
    if (validUrl.isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }

    // URL格式检测
    final urlFormatInfo = formatInfo ?? _detectUrlFormat(url);
    
    // 确定直播流状态 - 如果没有明确指定，则使用检测结果
    final detectedLiveStream = liveStream ?? urlFormatInfo.isLiveStream;
    
    // 确定视频格式
    final detectedVideoFormat = videoFormat ?? urlFormatInfo.format;
  
    // 创建字幕源
    final subtitlesSources = subtitles ?? 
      (subtitleUrl != null ? [
        IAppPlayerSubtitlesSource(
          type: IAppPlayerSubtitlesSourceType.network,
          urls: [subtitleUrl],
          name: _defaultSubtitleName,
          selectedByDefault: true,
        )
      ] : subtitleContent != null ? [
        IAppPlayerSubtitlesSource(
          type: IAppPlayerSubtitlesSourceType.memory,
          content: subtitleContent,
          name: _defaultSubtitleName,
          selectedByDefault: true,
        )
      ] : null);

    // 构建通知配置
    final finalNotificationConfig = _buildNotificationConfig(
      notificationConfiguration,
      isTV,
      showNotification,
      title,
      author,
      imageUrl,
      notificationChannelName,
    );

    // 构建缓冲配置
    final finalBufferingConfig = bufferingConfiguration ?? IAppPlayerBufferingConfiguration(
      minBufferMs: detectedLiveStream ? _liveMinBufferMs : _vodMinBufferMs,
      maxBufferMs: detectedLiveStream ? _liveMaxBufferMs : _vodMaxBufferMs,
      bufferForPlaybackMs: _bufferForPlaybackMs,
      bufferForPlaybackAfterRebufferMs: _bufferForPlaybackAfterRebufferMs,
    );

    // 构建缓存配置
    final finalCacheConfig = cacheConfiguration ?? IAppPlayerCacheConfiguration(
      useCache: !detectedLiveStream,
      preCacheSize: _preCacheSize,
      maxCacheSize: _maxCacheSize,
      maxCacheFileSize: _maxCacheFileSize,
    );

    // 创建数据源实例
    return IAppPlayerDataSource(
      dataSourceType ?? IAppPlayerDataSourceType.network,
      validUrl,
      preferredDecoderType: preferredDecoderType ?? IAppPlayerDecoderType.hardwareFirst,
      videoFormat: detectedVideoFormat,
      videoExtension: videoExtension,
      liveStream: detectedLiveStream,
      useAsmsTracks: useAsmsTracks ?? detectedLiveStream,
      useAsmsAudioTracks: useAsmsAudioTracks ?? detectedLiveStream,
      useAsmsSubtitles: useAsmsSubtitles ?? (subtitlesSources != null),
      subtitles: subtitlesSources,
      headers: headers,
      notificationConfiguration: finalNotificationConfig,
      bufferingConfiguration: finalBufferingConfig,
      cacheConfiguration: finalCacheConfig,
      drmConfiguration: drmConfiguration,
      resolutions: resolutions,
      overriddenDuration: overriddenDuration,
    );
  }

  // 构建通知配置
  static IAppPlayerNotificationConfiguration? _buildNotificationConfig(
    IAppPlayerNotificationConfiguration? notificationConfiguration,
    bool isTV,
    bool? showNotification,
    String? title,
    String? author,
    String? imageUrl,
    String? notificationChannelName,
  ) {
    if (notificationConfiguration != null) {
      return notificationConfiguration;
    } else if (!isTV && (showNotification ?? true)) {
      return IAppPlayerNotificationConfiguration(
        showNotification: showNotification ?? true,
        title: title,
        author: author,
        imageUrl: imageUrl,
        notificationChannelName: notificationChannelName,
        activityName: _defaultActivityName,
      );
    }
    return null;
  }

  // 创建播放列表配置
  static IAppPlayerPlaylistConfiguration createPlaylistConfig({
    bool shuffleMode = false,
    bool loopVideos = true,
    Duration nextVideoDelay = defaultNextVideoDelay,
    int initialStartIndex = 0,
  }) {
    return IAppPlayerPlaylistConfiguration(
      shuffleMode: shuffleMode,
      loopVideos: loopVideos,
      nextVideoDelay: nextVideoDelay,
      initialStartIndex: initialStartIndex,
    );
  }

  // 创建播放器核心配置
  static IAppPlayerConfiguration createPlayerConfig({
    required bool liveStream,
    required Function(IAppPlayerEvent) eventListener,
    bool autoPlay = true,
    bool? audioOnly,
    Widget? placeholder,
    Widget Function(BuildContext, String?)? errorBuilder,
    String? backgroundImage,
    Widget? overlay,
    double? aspectRatio,
    BoxFit? fit,
    double? rotation,
    IAppPlayerControlsConfiguration? controlsConfiguration,
    IAppPlayerSubtitlesConfiguration? subtitlesConfiguration,
    bool? enableSubtitles,
    bool? enableQualities,
    bool? enableAudioTracks,
    bool? enableFullscreen,
    bool? enableOverflowMenu,
    bool? handleAllGestures,
    bool? fullScreenByDefault,
    double? fullScreenAspectRatio,
    List<DeviceOrientation>? deviceOrientationsOnFullScreen,
    List<DeviceOrientation>? deviceOrientationsAfterFullScreen,
    bool? handleLifecycle,
    bool? autoDispose,
    bool? looping,
    Duration? startAt,
    bool? allowedScreenSleep,
    bool? expandToFill,
    bool? showPlaceholderUntilPlay,
    bool? placeholderOnTop,
    List<SystemUiOverlay>? systemOverlaysAfterFullScreen,
    IAppPlayerRoutePageBuilder? routePageBuilder,
    List<IAppPlayerTranslations>? translations,
    bool? autoDetectFullscreenDeviceOrientation,
    bool? autoDetectFullscreenAspectRatio,
    bool? useRootNavigator,
    Function(double)? playerVisibilityChangedBehavior,
  }) {
    // 构建控件配置
    final finalControlsConfig = audioOnly != null 
        ? (controlsConfiguration?.copyWith(audioOnly: audioOnly) ?? 
           IAppPlayerControlsConfiguration(
             handleAllGestures: handleAllGestures ?? false,
             audioOnly: audioOnly,
             enableSubtitles: enableSubtitles ?? true,
             enableQualities: enableQualities ?? false,
             enableAudioTracks: enableAudioTracks ?? false,
             enableFullscreen: enableFullscreen ?? false,
             enableOverflowMenu: enableOverflowMenu ?? false,
           ))
        : (controlsConfiguration ?? IAppPlayerControlsConfiguration(
             handleAllGestures: handleAllGestures ?? false,
             audioOnly: false,
             enableSubtitles: enableSubtitles ?? true,
             enableQualities: enableQualities ?? false,
             enableAudioTracks: enableAudioTracks ?? false,
             enableFullscreen: enableFullscreen ?? false,
             enableOverflowMenu: enableOverflowMenu ?? false,
           ));

    // 处理背景图片
    Widget? backgroundWidget;
    if (backgroundImage != null && backgroundImage.isNotEmpty) {
      // 根据URL协议判断是网络图片还是本地资源
      if (backgroundImage.startsWith('http://') || backgroundImage.startsWith('https://')) {
        backgroundWidget = Image.network(
          backgroundImage,
          fit: _defaultImageFit,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        );
      } else {
        backgroundWidget = Image.asset(
          backgroundImage,
          fit: _defaultImageFit,
          gaplessPlayback: true,
          filterQuality: _defaultImageQuality,
        );
      }
    }
    
    // 构建错误处理器
    final finalErrorBuilder = errorBuilder ?? (backgroundWidget != null
        ? (context, error) => backgroundWidget ?? const SizedBox()
        : null);

    // 创建播放器配置实例
    return IAppPlayerConfiguration(
      fit: fit ?? BoxFit.fill,
      autoPlay: autoPlay,
      looping: looping ?? !liveStream,
      allowedScreenSleep: allowedScreenSleep ?? false,
      autoDispose: autoDispose ?? false,
      expandToFill: expandToFill ?? true,
      handleLifecycle: handleLifecycle ?? true,
      errorBuilder: finalErrorBuilder,
      placeholder: placeholder ?? backgroundWidget,
      overlay: overlay,
      aspectRatio: aspectRatio,
      rotation: rotation ?? _defaultRotation,
      controlsConfiguration: finalControlsConfig,
      subtitlesConfiguration: subtitlesConfiguration ?? const IAppPlayerSubtitlesConfiguration(),
      fullScreenByDefault: fullScreenByDefault ?? false,
      fullScreenAspectRatio: fullScreenAspectRatio,
      deviceOrientationsOnFullScreen: deviceOrientationsOnFullScreen ?? const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: deviceOrientationsAfterFullScreen ?? const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
      eventListener: eventListener,
      startAt: startAt,
      showPlaceholderUntilPlay: showPlaceholderUntilPlay ?? false,
      placeholderOnTop: placeholderOnTop ?? true,
      systemOverlaysAfterFullScreen: systemOverlaysAfterFullScreen ?? SystemUiOverlay.values,
      routePageBuilder: routePageBuilder,
      translations: translations,
      autoDetectFullscreenDeviceOrientation: autoDetectFullscreenDeviceOrientation ?? false,
      autoDetectFullscreenAspectRatio: autoDetectFullscreenAspectRatio ?? false,
      useRootNavigator: useRootNavigator ?? false,
      playerVisibilityChangedBehavior: playerVisibilityChangedBehavior,
    );
  }
}
