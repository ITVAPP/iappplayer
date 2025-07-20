import 'package:iapp_player/src/hls/hls_parser/drm_init_data.dart';

/// 表示HLS播放列表中的分段
class Segment {
  Segment({
    required this.url,
    this.initializationSegment,
    this.durationUs,
    this.title,
    this.relativeDiscontinuitySequence,
    this.relativeStartTimeUs,
    this.drmInitData,
    required this.fullSegmentEncryptionKeyUri,
    required this.encryptionIV,
    required this.byterangeOffset,
    required this.byterangeLength,
    this.hasGapTag = false,
  });

  /// 分段的URL
  final String? url;

  /// 分段的媒体初始化部分，由#EXT-X-MAP定义，无定义时为null
  final Segment? initializationSegment;

  /// 分段持续时间（微秒），由#EXTINF定义
  final int? durationUs;

  /// 分段的可读标题，未知时为null
  final String? title;

  /// 分段前的#EXT-X-DISCONTINUITY标签数，未知时为null
  final int? relativeDiscontinuitySequence;

  /// 分段相对于播放列表起始的开始时间（微秒），未知时为null
  final int? relativeStartTimeUs;

  /// 样本解密的DRM初始化数据，未使用CDM-DRM保护时为null
  final DrmInitData? drmInitData;

  /// 全分段加密的密钥URI，由#EXT-X-KEY定义，未使用时为null
  final String? fullSegmentEncryptionKeyUri;

  /// 加密初始化向量，由#EXT-X-KEY定义，未加密时为null
  final String? encryptionIV;

  /// 分段的字节范围偏移，由#EXT-X-BYTERANGE定义
  final int? byterangeOffset;

  /// 分段的字节范围长度，由#EXT-X-BYTERANGE定义，无指定时为null
  final int? byterangeLength;

  /// 是否带有#EXT-X-GAP标签
  final bool hasGapTag;
}
