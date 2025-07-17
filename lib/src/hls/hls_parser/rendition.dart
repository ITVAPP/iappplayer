import 'package:iapp_player/src/hls/hls_parser/format.dart';

/// HLS播放列表中的变体信息
class Rendition {
  Rendition({
    this.url,
    required this.format,
    required this.groupId,
    required this.name,
  });

  /// 变体的URL，无URI属性时为null
  final Uri? url;

  /// 变体的格式信息
  final Format format;

  /// 变体所属的组ID
  final String? groupId;

  /// 变体名称
  final String? name;
}
