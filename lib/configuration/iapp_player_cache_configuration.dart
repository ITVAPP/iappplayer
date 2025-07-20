/// Android: 启用缓存需 useCache 为 true 且 maxCacheSize/maxCacheFileSize > 0
/// iOS: 仅 useCache 生效，maxCacheSize/maxCacheFileSize 无影响
class IAppPlayerCacheConfiguration {
  /// 是否启用网络数据源缓存
  final bool useCache;
  /// 磁盘最大缓存大小（字节），仅 Android 生效，应用首次访问时设置
  final int maxCacheSize;
  /// 单个文件最大缓存大小（字节），仅 Android 生效
  final int maxCacheFileSize;
  /// 预缓存大小（字节）
  final int preCacheSize;
  /// 缓存键，用于跨会话重用缓存
  final String? key;

  /// 构造函数，初始化缓存配置
  const IAppPlayerCacheConfiguration({
    this.useCache = false,
    this.maxCacheSize = 10 * 1024 * 1024,
    this.maxCacheFileSize = 10 * 1024 * 1024,
    this.preCacheSize = 3 * 1024 * 1024,
    this.key,
  });
}
