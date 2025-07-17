import 'package:flutter/material.dart';

/// HLS播放列表中的变体信息
class VariantInfo {
  VariantInfo({
    this.bitrate,
    this.videoGroupId,
    this.audioGroupId,
    this.subtitleGroupId,
    this.captionGroupId,
  });

  /// EXT-X-STREAM-INF标签声明的比特率
  final int? bitrate;

  /// VIDEO属性值，无时为null
  final String? videoGroupId;

  /// AUDIO属性值，无时为null
  final String? audioGroupId;

  /// SUBTITLES属性值，无时为null
  final String? subtitleGroupId;

  /// CLOSED-CAPTIONS属性值，无时为null
  final String? captionGroupId;

  @override
  /// 比较变体信息的相等性
  bool operator ==(dynamic other) {
    if (other is VariantInfo) {
      return other.bitrate == bitrate &&
          other.videoGroupId == videoGroupId &&
          other.audioGroupId == audioGroupId &&
          other.subtitleGroupId == subtitleGroupId &&
          other.captionGroupId == captionGroupId;
    }
    return false;
  }

  @override
  /// 计算变体信息的哈希值
  int get hashCode => Object.hash(
      bitrate, videoGroupId, audioGroupId, subtitleGroupId, captionGroupId);
}
