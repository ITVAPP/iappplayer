/// HLS播放列表抽象类
abstract class HlsPlaylist {
  HlsPlaylist({
    required this.baseUri,
    required this.tags,
    required this.hasIndependentSegments,
  });

  /// 基础URI，用于解析相对路径
  final String? baseUri;

  /// 播放列表中的标签列表
  final List<String> tags;

  /// 是否由独立分段组成，由#EXT-X-INDEPENDENT-SEGMENTS标签定义
  final bool hasIndependentSegments;
}
