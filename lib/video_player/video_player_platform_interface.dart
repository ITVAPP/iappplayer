import 'dart:async';
import 'package:iapp_player/src/configuration/iapp_player_buffering_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'method_channel_video_player.dart';

// 视频播放平台接口
abstract class VideoPlayerPlatform {
  @visibleForTesting
  bool get isMock => false;

  // 默认平台实现
  static VideoPlayerPlatform _instance = MethodChannelVideoPlayer();

  // 获取平台实例
  static VideoPlayerPlatform get instance => _instance;

  // 设置平台实例
  static set instance(VideoPlayerPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  // 初始化平台接口
  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  // 释放视频资源
  Future<void> dispose(int? textureId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  // 创建视频播放器
  Future<int?> create(
      {IAppPlayerBufferingConfiguration? bufferingConfiguration}) {
    throw UnimplementedError('create() has not been implemented.');
  }

  // 预缓存视频
  Future<void> preCache(DataSource dataSource, int preCacheSize) {
    throw UnimplementedError('preCache() has not been implemented.');
  }

  // 停止预缓存
  Future<void> stopPreCache(String url, String? cacheKey) {
    throw UnimplementedError('stopPreCache() has not been implemented.');
  }

  // 设置数据源
  Future<void> setDataSource(int? textureId, DataSource dataSource) {
    throw UnimplementedError('setDataSource() has not been implemented.');
  }

  // 获取视频事件流
  Stream<VideoEvent> videoEventsFor(int? textureId) {
    throw UnimplementedError('videoEventsFor() has not been implemented.');
  }

  // 设置循环播放
  Future<void> setLooping(int? textureId, bool looping) {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  // 开始播放
  Future<void> play(int? textureId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  // 暂停播放
  Future<void> pause(int? textureId) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  // 设置音量
  Future<void> setVolume(int? textureId, double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  // 设置播放速度
  Future<void> setSpeed(int? textureId, double speed) {
    throw UnimplementedError('setSpeed() has not been implemented.');
  }

  // 设置视频轨道参数
  Future<void> setTrackParameters(
      int? textureId, int? width, int? height, int? bitrate) {
    throw UnimplementedError('setTrackParameters() has not been implemented.');
  }

  // 跳转到指定位置
  Future<void> seekTo(int? textureId, Duration? position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  // 获取当前播放位置
  Future<Duration> getPosition(int? textureId) {
    throw UnimplementedError('getPosition() has not been implemented.');
  }

  // 获取绝对播放位置
  Future<DateTime?> getAbsolutePosition(int? textureId) {
    throw UnimplementedError('getAbsolutePosition() has not been implemented.');
  }

  // 启用画中画模式
  Future<void> enablePictureInPicture(int? textureId, double? top, double? left,
      double? width, double? height) {
    throw UnimplementedError(
        'enablePictureInPicture() has not been implemented.');
  }

  // 禁用画中画模式
  Future<void> disablePictureInPicture(int? textureId) {
    throw UnimplementedError(
        'disablePictureInPicture() has not been implemented.');
  }

  // 检查画中画支持
  Future<bool?> isPictureInPictureEnabled(int? textureId) {
    throw UnimplementedError(
        'isPictureInPictureEnabled() has not been implemented.');
  }

  // 设置音频轨道
  Future<void> setAudioTrack(int? textureId, String? name, int? index) {
    throw UnimplementedError('setAudio() has not been implemented.');
  }

  // 设置与其他音频混合
  Future<void> setMixWithOthers(int? textureId, bool mixWithOthers) {
    throw UnimplementedError('setMixWithOthers() has not been implemented.');
  }

  // 清除缓存
  Future<void> clearCache() {
    throw UnimplementedError('clearCache() has not been implemented.');
  }

  // 构建视频视图
  Widget buildView(int? textureId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  // 验证默认实现
  void _verifyProvidesDefaultImplementations() {}
}

// 描述视频数据源配置
class DataSource {
  // 最大缓存大小（字节）
  static const int _maxCacheSize = 100 * 1024 * 1024;

  // 最大单个文件缓存大小（字节）
  static const int _maxCacheFileSize = 10 * 1024 * 1024;

  // 构造数据源
  DataSource({
    required this.sourceType,
    this.uri,
    this.formatHint,
    this.asset,
    this.package,
    this.headers,
    this.useCache = false,
    this.maxCacheSize = _maxCacheSize,
    this.maxCacheFileSize = _maxCacheFileSize,
    this.cacheKey,
    this.showNotification = false,
    this.title,
    this.author,
    this.imageUrl,
    this.notificationChannelName,
    this.overriddenDuration,
    this.licenseUrl,
    this.certificateUrl,
    this.drmHeaders,
    this.activityName,
    this.clearKey,
    this.videoExtension,
    this.preferredDecoderType,
  }) : assert(uri == null || asset == null);

  // 数据源类型
  final DataSourceType sourceType;

  // 视频 URI
  final String? uri;

  // 视频格式提示
  final VideoFormat? formatHint;

  // 格式提示字符串
  String? get rawFormalHint {
    switch (formatHint) {
      case VideoFormat.ss:
        return 'ss';
      case VideoFormat.hls:
        return 'hls';
      case VideoFormat.dash:
        return 'dash';
      case VideoFormat.other:
        return 'other';
      default:
        return null;
    }
  }

  // 资产路径
  final String? asset;

  // 资产包名
  final String? package;

  // 请求头
  final Map<String, String?>? headers;

  // 是否使用缓存
  final bool useCache;

  // 最大缓存大小
  final int? maxCacheSize;

  // 最大单个文件缓存大小
  final int? maxCacheFileSize;

  // 缓存键
  final String? cacheKey;

  // 是否显示通知
  final bool? showNotification;

  // 视频标题
  final String? title;

  // 视频作者
  final String? author;

  // 通知图像 URL
  final String? imageUrl;

  // 通知通道名称
  final String? notificationChannelName;

  // 覆盖时长
  final Duration? overriddenDuration;

  // 许可 URL
  final String? licenseUrl;

  // 证书 URL
  final String? certificateUrl;

  // DRM 请求头
  final Map<String, String>? drmHeaders;

  // 活动名称
  final String? activityName;

  // ClearKey
  final String? clearKey;

  // 视频扩展名
  final String? videoExtension;

  // 解码器类型偏好（0=自动, 1=硬件优先, 2=软件优先）
  final int? preferredDecoderType;
  
  // 生成数据源标识
  String get key {
    String? result = "";

    if (uri != null && uri!.isNotEmpty) {
      result = uri;
    } else if (package != null && package!.isNotEmpty) {
      result = "$package:$asset";
    } else {
      result = asset;
    }

    if (formatHint != null) {
      result = "$result:$rawFormalHint";
    }

    return result!;
  }

  // 格式化数据源输出
  @override
  String toString() {
    return 'DataSource{sourceType: $sourceType, uri: $uri certificateUrl: $certificateUrl, formatHint:'
        ' $formatHint, asset: $asset, package: $package, headers: $headers,'
        ' useCache: $useCache,maxCacheSize: $maxCacheSize, maxCacheFileSize: '
        '$maxCacheFileSize, showNotification: $showNotification, title: $title,'
        ' author: $author}';
  }
}

// 数据源类型
enum DataSourceType {
  // 应用资产文件
  asset,
  // 网络下载
  network,
  // 本地文件系统
  file
}

// 视频格式
enum VideoFormat {
  // MPEG-DASH 格式
  dash,
  // HTTP Live Streaming 格式
  hls,
  // Smooth Streaming 格式
  ss,
  // 其他格式
  other
}

// 视频播放事件
class VideoEvent {
  VideoEvent({
    required this.eventType,
    required this.key,
    this.duration,
    this.size,
    this.buffered,
    this.position,
  });

  // 事件类型
  final VideoEventType eventType;

  // 数据源标识
  final String? key;

  // 视频时长
  final Duration? duration;

  // 视频尺寸
  final Size? size;

  // 缓冲范围
  final List<DurationRange>? buffered;

  // 跳转位置
  final Duration? position;

  // 比较事件
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VideoEvent &&
            runtimeType == other.runtimeType &&
            key == other.key &&
            eventType == other.eventType &&
            duration == other.duration &&
            size == other.size &&
            listEquals(buffered, other.buffered);
  }

  // 计算哈希值
  @override
  int get hashCode =>
      eventType.hashCode ^
      duration.hashCode ^
      size.hashCode ^
      buffered.hashCode;
}

// 视频事件类型
enum VideoEventType {
  // 视频已初始化
  initialized,
  // 播放已完成
  completed,
  // 缓冲状态更新
  bufferingUpdate,
  // 开始缓冲
  bufferingStart,
  // 停止缓冲
  bufferingEnd,
  // 设置为播放
  play,
  // 设置为暂停
  pause,
  // 设置跳转位置
  seek,
  // 启用画中画模式
  pipStart,
  // 关闭画中画模式
  pipStop,
  // 未知事件
  unknown,
}

// 视频缓冲时间段
class DurationRange {
  // 构造时间段
  DurationRange(this.start, this.end);

  // 起始时间
  final Duration start;

  // 结束时间
  final Duration end;

  // 计算起始时间占比
  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  // 计算结束时间占比
  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  // 格式化输出
  @override
  String toString() => '$runtimeType(start: $start, end: $end)';

  // 比较时间段
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  // 计算哈希值
  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
