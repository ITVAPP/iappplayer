import 'package:iapp_player/src/hls/hls_parser/drm_init_data.dart';
import 'package:iapp_player/src/hls/hls_parser/playlist.dart';
import 'package:iapp_player/src/hls/hls_parser/segment.dart';

/// HLS媒体播放列表，管理媒体片段及其元数据
class HlsMediaPlaylist extends HlsPlaylist {
  HlsMediaPlaylist._({
    required this.playlistType, // 播放列表类型
    required this.startOffsetUs, // 起始偏移（微秒）
    required this.startTimeUs, // 起始时间或移除片段累积时长（微秒）
    required this.hasDiscontinuitySequence, // 是否包含不连续序列标签
    required this.discontinuitySequence, // 首个媒体片段的不连续序列号
    required this.mediaSequence, // 首个媒体片段的媒体序列号
    required this.version, // 兼容版本号
    required this.targetDurationUs, // 目标时长（微秒）
    required this.hasEndTag, // 是否包含结束标签
    required this.hasProgramDateTime, // 是否包含节目时间标签
    required this.protectionSchemes, // CDM保护方案
    required this.segments, // 媒体片段列表
    required this.durationUs, // 播放列表总时长（微秒）
    required String baseUri, // 基础URI
    required List<String> tags, // 标签列表
    required bool hasIndependentSegments, // 是否包含独立片段
  }) : super(
          baseUri: baseUri,
          tags: tags,
          hasIndependentSegments: hasIndependentSegments,
        );

  /// 创建HLS媒体播放列表实例
  factory HlsMediaPlaylist.create({
    required int playlistType, // 播放列表类型
    required int? startOffsetUs, // 起始偏移（微秒）
    required int? startTimeUs, // 起始时间（微秒）
    required bool hasDiscontinuitySequence, // 是否包含不连续序列标签
    required int discontinuitySequence, // 不连续序列号
    required int? mediaSequence, // 媒体序列号
    required int? version, // 版本号
    required int? targetDurationUs, // 目标时长（微秒）
    required bool hasEndTag, // 是否包含结束标签
    required bool hasProgramDateTime, // 是否包含节目时间标签
    required DrmInitData? protectionSchemes, // DRM保护方案
    required List<Segment> segments, // 媒体片段列表
    required String baseUri, // 基础URI
    required List<String> tags, // 标签列表
    required bool hasIndependentSegments, // 是否包含独立片段
  }) {
    // 计算播放列表总时长
    final int? durationUs = segments.isNotEmpty
        ? (segments.last.relativeStartTimeUs ?? 0) + segments.last.durationUs!
        : null;

    // 处理负起始偏移
    if (startOffsetUs != null && startOffsetUs < 0) {
      startOffsetUs = (durationUs ?? 0) + startOffsetUs;
    }

    return HlsMediaPlaylist._(
      playlistType: playlistType,
      startOffsetUs: startOffsetUs,
      startTimeUs: startTimeUs,
      hasDiscontinuitySequence: hasDiscontinuitySequence,
      discontinuitySequence: discontinuitySequence,
      mediaSequence: mediaSequence,
      version: version,
      targetDurationUs: targetDurationUs,
      hasEndTag: hasEndTag,
      hasProgramDateTime: hasProgramDateTime,
      protectionSchemes: protectionSchemes,
      segments: segments,
      durationUs: durationUs,
      baseUri: baseUri,
      tags: tags,
      hasIndependentSegments: hasIndependentSegments,
    );
  }

  /// 未知播放列表类型
  static const int playlistTypeUnknown = 0;
  /// 点播播放列表类型
  static const int playlistTypeVod = 1;
  /// 事件播放列表类型
  static const int playlistTypeEvent = 2;

  /// 播放列表类型（未知、点播或事件）
  final int playlistType;

  /// #EXT-X-START定义的起始偏移（微秒），可能为null
  final int? startOffsetUs;

  /// 若含节目时间标签，则为自纪元以来的时间（微秒）；否则为移除片段累积时长
  final int? startTimeUs;

  /// 是否包含#EXT-X-DISCONTINUITY-SEQUENCE标签
  final bool hasDiscontinuitySequence;

  /// #EXT-X-DISCONTINUITY-SEQUENCE定义的首个媒体片段不连续序列号
  final int discontinuitySequence;

  /// #EXT-X-MEDIA-SEQUENCE定义的首个媒体片段序列号，可能为null
  final int? mediaSequence;

  /// #EXT-X-VERSION定义的兼容版本号，可能为null
  final int? version;

  /// #EXT-X-TARGETDURATION定义的目标时长（微秒），可能为null
  final int? targetDurationUs;

  /// 是否包含#EXT-X-ENDLIST标签
  final bool hasEndTag;

  /// 是否包含#EXT-X-PROGRAM-DATE-TIME标签
  final bool hasProgramDateTime;

  /// 媒体片段使用的CDM保护方案，若无加密则为null
  final DrmInitData? protectionSchemes;

  /// 播放列表中的媒体片段列表
  final List<Segment> segments;

  /// 播放列表总时长（微秒），可能为null
  final int? durationUs;
}
