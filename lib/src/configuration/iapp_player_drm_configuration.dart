import 'package:iapp_player/src/configuration/iapp_player_drm_type.dart';

/// 数据源 DRM 保护配置
class IAppPlayerDrmConfiguration {
  /// DRM 类型
  final IAppPlayerDrmType? drmType;
  /// 仅用于 token 加密 DRM 的参数
  final String? token;
  /// 许可证服务器 URL
  final String? licenseUrl;
  /// Fairplay 证书 URL
  final String? certificateUrl;
  /// ClearKey JSON 对象，仅用于 Android 的 ClearKey 保护
  final String? clearKey;
  /// Widevine DRM 认证请求的附加头信息
  final Map<String, String>? headers;

  /// 构造函数，初始化 DRM 配置
  IAppPlayerDrmConfiguration({
    this.drmType,
    this.token,
    this.licenseUrl,
    this.certificateUrl,
    this.headers,
    this.clearKey,
  });
}
