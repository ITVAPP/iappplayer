import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:iapp_player/src/hls/hls_parser/variant_info.dart';

/// HLS轨道元数据条目
class HlsTrackMetadataEntry {
  HlsTrackMetadataEntry({this.groupId, this.name, this.variantInfos});

  /// EXT-X-MEDIA标签的GROUP-ID，轨道非来源于此标签时为null
  final String? groupId;

  /// EXT-X-MEDIA标签的NAME，轨道非来源于此标签时为null
  final String? name;

  /// EXT-X-STREAM-INF标签属性，轨道来源于EXT-X-MEDIA时为空
  final List<VariantInfo>? variantInfos;

  /// 缓存hashCode，避免重复计算
  int? _cachedHashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is HlsTrackMetadataEntry) {
      /// 比较groupId、name和variantInfos是否相等
      return other.groupId == groupId &&
          other.name == name &&
          const ListEquality<VariantInfo>()
              .equals(other.variantInfos, variantInfos);
    }
    return false;
  }

  @override
  int get hashCode {
    // 如果已缓存，直接返回
    _cachedHashCode ??= Object.hash(groupId, name, variantInfos);
    return _cachedHashCode!;
  }
}