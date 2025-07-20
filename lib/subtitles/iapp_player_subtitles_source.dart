import 'package:iapp_player/src/asms/iapp_player_asms_subtitle_segment.dart';
import 'iapp_player_subtitles_source_type.dart';

/// 字幕源配置，定义字幕来源与属性
class IAppPlayerSubtitlesSource {
  /// 字幕源类型
  final IAppPlayerSubtitlesSourceType? type;

  /// 字幕名称，默认“Default subtitles”
  final String? name;

  /// 字幕文件URL列表
  final List<String?>? urls;

  /// 字幕内容，用于内存源
  final String? content;

  /// 默认选中字幕
  final bool? selectedByDefault;

  /// HTTP请求头，仅用于内存源
  final Map<String, String>? headers;

  /// 是否为ASMS分段字幕
  final bool? asmsIsSegmented;

  /// 分段间最大时间间隔（毫秒）
  final int? asmsSegmentsTime;

  /// ASMS字幕分段列表
  final List<IAppPlayerAsmsSubtitleSegment>? asmsSegments;

  IAppPlayerSubtitlesSource({
    this.type,
    this.name = "Default subtitles",
    this.urls,
    this.content,
    this.selectedByDefault,
    this.headers,
    this.asmsIsSegmented,
    this.asmsSegmentsTime,
    this.asmsSegments,
  });

  /// 创建单一字幕源
  static List<IAppPlayerSubtitlesSource> single({
    IAppPlayerSubtitlesSourceType? type,
    String name = "Default subtitles",
    String? url,
    String? content,
    bool? selectedByDefault,
    Map<String, String>? headers,
  }) =>
      [
        IAppPlayerSubtitlesSource(
          type: type,
          name: name,
          urls: [url],
          content: content,
          selectedByDefault: selectedByDefault,
          headers: headers,
        )
      ];
}
