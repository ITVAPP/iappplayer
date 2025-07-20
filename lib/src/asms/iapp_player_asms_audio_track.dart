/// HLS/DASH 音频轨道表示
class IAppPlayerAsmsAudioTrack {
  /// 音频轨道索引或 ID
  final int? id;
  /// 分段对齐标志
  final bool? segmentAlignment;
  /// 音频描述标签
  final String? label;
  /// 语言代码
  final String? language;
  /// 音频轨道 URL
  final String? url;
  /// 音频轨道 MIME 类型
  final String? mimeType;

  /// 构造函数，初始化音频轨道属性
  IAppPlayerAsmsAudioTrack({
    this.id,
    this.segmentAlignment,
    this.label,
    this.language,
    this.url,
    this.mimeType,
  });
}
