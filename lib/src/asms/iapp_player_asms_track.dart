/// HLS/DASH 视频轨道
class IAppPlayerAsmsTrack {
  /// 轨道 ID
  final String? id;
  /// 轨道宽度（像素）
  final int? width;
  /// 轨道高度（像素）
  final int? height;
  /// 轨道比特率
  final int? bitrate;
  /// 轨道帧率
  final int? frameRate;
  /// 轨道编解码器
  final String? codecs;
  /// 视频轨道 MIME 类型
  final String? mimeType;
  
  /// 缓存的哈希值，避免重复计算
  int? _cachedHashCode;

  /// 构造函数，初始化视频轨道属性
  IAppPlayerAsmsTrack(
    this.id,
    this.width,
    this.height,
    this.bitrate,
    this.frameRate,
    this.codecs,
    this.mimeType,
  );

  /// 创建默认视频轨道
  factory IAppPlayerAsmsTrack.defaultTrack() {
    return IAppPlayerAsmsTrack('', 0, 0, 0, 0, '', '');
  }

  /// 计算轨道哈希值
  @override
  int get hashCode {
    // 使用缓存的哈希值，避免重复计算
    _cachedHashCode ??= Object.hash(
      id,
      width,
      height,
      bitrate,
      frameRate,
      codecs,
      mimeType,
    );
    return _cachedHashCode!;
  }

  /// 比较轨道对象是否相等
  @override
  bool operator ==(dynamic other) {
    // 快速检查：相同引用直接返回 true
    if (identical(this, other)) return true;
    
    // 类型检查
    if (other is! IAppPlayerAsmsTrack) return false;
    
    // 快速检查：哈希值不同直接返回 false
    if (hashCode != other.hashCode) return false;
    
    // 详细比较所有字段
    return id == other.id &&
        width == other.width &&
        height == other.height &&
        bitrate == other.bitrate &&
        frameRate == other.frameRate &&
        codecs == other.codecs &&
        mimeType == other.mimeType;
  }
}