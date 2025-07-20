import 'dart:typed_data';
import 'package:flutter/material.dart';

/// DRM方案数据，封装许可证请求及解密相关信息
class SchemeData {
  SchemeData({
    this.licenseServerUrl, // 许可证服务器URL，可能为null
    required this.mimeType, // 数据MIME类型
    this.data, // 初始化基础数据
    this.requiresSecureDecryption, // 是否需要安全解密
  });

  /// 许可证请求的服务器URL，可能为null
  final String? licenseServerUrl;

  /// 数据MIME类型
  final String mimeType;

  /// 初始化基础数据
  final Uint8List? data;

  /// 是否需要安全解密
  final bool? requiresSecureDecryption;

  /// 创建副本并替换数据
  SchemeData copyWithData(Uint8List? data) => SchemeData(
        licenseServerUrl: licenseServerUrl,
        mimeType: mimeType,
        data: data,
        requiresSecureDecryption: requiresSecureDecryption,
      );

  /// 比较对象是否相等
  @override
  bool operator ==(dynamic other) {
    if (other is SchemeData) {
      return other.mimeType == mimeType &&
          other.licenseServerUrl == licenseServerUrl &&
          other.requiresSecureDecryption == requiresSecureDecryption &&
          other.data == data;
    }
    return false;
  }

  /// 计算哈希值
  @override
  int get hashCode => Object.hash(
      licenseServerUrl,
      mimeType,
      data,
      requiresSecureDecryption);
}
