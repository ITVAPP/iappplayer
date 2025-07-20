import 'package:iapp_player/src/hls/hls_parser/hls_track_metadata_entry.dart';
import 'package:collection/collection.dart';

/// 元数据类，存储HLS轨道元数据条目列表
class Metadata {
  Metadata(this.list);

  /// HLS轨道元数据条目列表
  final List<HlsTrackMetadataEntry> list;

  @override
  /// 比较元数据条目列表是否相等
  bool operator ==(dynamic other) {
    if (other is Metadata) {
      return const ListEquality<HlsTrackMetadataEntry>()
          .equals(other.list, list);
    }
    return false;
  }

  @override
  int get hashCode => list.hashCode;
}
