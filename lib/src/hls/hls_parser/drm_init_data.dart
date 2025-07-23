import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'scheme_data.dart';

/// DRM初始化数据，管理DRM方案及相关数据
class DrmInitData {
  DrmInitData({this.schemeType, this.schemeData = const []});

  /// DRM方案数据列表
  final List<SchemeData> schemeData;

  /// DRM方案类型
  final String? schemeType;

  /// 缓存hashCode，避免重复计算
  int? _cachedHashCode;

  /// 比较对象是否相等
  @override
  bool operator ==(dynamic other) {
    if (other is DrmInitData) {
      return schemeType == other.schemeType &&
          const ListEquality<SchemeData>().equals(other.schemeData, schemeData);
    }
    return false;
  }

  /// 计算哈希值
  @override
  int get hashCode {
    // 如果已缓存，直接返回
    _cachedHashCode ??= Object.hash(schemeType, schemeData);
    return _cachedHashCode!;
  }
}