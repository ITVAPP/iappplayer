import 'package:iapp_player/src/hls/hls_parser/format.dart';

/// HLS播放列表中的变体
class Variant {
  Variant({
    required this.url,
    required this.format,
    required this.videoGroupId,
    required this.audioGroupId,
    required this.subtitleGroupId,
    required this.captionGroupId,
  });

  /// 变体的URL
  final Uri url;

  /// 变体的格式信息
  final Format format;

  /// 视频变体组ID，无时为null
  final String? videoGroupId;

  /// 音频变体组ID，无时为null
  final String? audioGroupId;

  /// 字幕变体组ID，无时为null
  final String? subtitleGroupId;

  /// 隐藏字幕变体组ID，无时为null
  final String? captionGroupId;

  /// 复制变体并更新格式
  Variant copyWithFormat(Format format) => Variant(
        url: url,
        format: format,
        videoGroupId: videoGroupId,
        audioGroupId: audioGroupId,
        subtitleGroupId: subtitleGroupId,
        captionGroupId: captionGroupId,
      );
}
