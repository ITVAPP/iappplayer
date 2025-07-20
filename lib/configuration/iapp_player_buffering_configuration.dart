/// 用于设置更好的缓冲体验或自定义加载设置的配置类。目前仅在Android中使用。
class IAppPlayerBufferingConfiguration {
  /// 常量值来自官方Media3文档
  /// https://developer.android.com/reference/androidx/media3/exoplayer/DefaultLoadControl
  static const defaultMinBufferMs = 25000;
  static const defaultMaxBufferMs = 6553600;
  static const defaultBufferForPlaybackMs = 3000;
  static const defaultBufferForPlaybackAfterRebufferMs = 6000;

  /// 播放器将尝试始终确保缓冲的媒体的默认最小持续时间（毫秒）
  final int minBufferMs;

  /// 播放器将尝试缓冲的媒体的默认最大持续时间（毫秒）
  final int maxBufferMs;

  /// 在用户操作（如搜索）后开始或恢复播放所需缓冲的媒体的默认持续时间（毫秒）
  final int bufferForPlaybackMs;

  /// 重新缓冲后恢复播放所需缓冲的媒体的默认持续时间（毫秒）
  /// 重新缓冲定义为由缓冲区耗尽而非用户操作引起的
  final int bufferForPlaybackAfterRebufferMs;

  const IAppPlayerBufferingConfiguration({
    this.minBufferMs = defaultMinBufferMs,
    this.maxBufferMs = defaultMaxBufferMs,
    this.bufferForPlaybackMs = defaultBufferForPlaybackMs,
    this.bufferForPlaybackAfterRebufferMs =
        defaultBufferForPlaybackAfterRebufferMs,
  });
}
