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
    return Object.hash(
      id,
      width,
      height,
      bitrate,
      frameRate,
      codecs,
      mimeType,
    );
  }

  /// 比较轨道对象是否相等
  @override
  bool operator ==(dynamic other) {
    return other is IAppPlayerAsmsTrack &&
        width == other.width &&
        height == other.height &&
        bitrate == other.bitrate &&
        frameRate == other.frameRate &&
        codecs == other.codecs &&
        mimeType == other.mimeType;
  }
}
