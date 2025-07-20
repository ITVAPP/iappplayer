import 'package:iapp_player/src/asms/iapp_player_asms_subtitle_segment.dart';

/// HLS/DASH 字幕元素表示
class IAppPlayerAsmsSubtitle {
  /// 字幕语言
  final String? language;
  /// 字幕名称
  final String? name;
  /// 字幕 MIME 类型（仅 DASH）
  final String? mimeType;
  /// 分段对齐标志（仅 DASH）
  final bool? segmentAlignment;
  /// 主播放列表字幕 URL
  final String? url;
  /// 具体字幕文件 URL 列表
  final List<String>? realUrls;
  /// 是否分段加载字幕
  final bool? isSegmented;
  /// 分段最大持续时间（仅分段时使用）
  final int? segmentsTime;
  /// 字幕分段列表（仅分段时使用）
  final List<IAppPlayerAsmsSubtitleSegment>? segments;
  /// 是否默认字幕
  final bool? isDefault;

  /// 构造函数，初始化字幕属性
  IAppPlayerAsmsSubtitle({
    this.language,
    this.name,
    this.mimeType,
    this.segmentAlignment,
    this.url,
    this.realUrls,
    this.isSegmented,
    this.segmentsTime,
    this.segments,
    this.isDefault,
  });
}
