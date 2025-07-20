/// 视频数据源类型
/// network: 网络托管视频
/// file: 设备本地视频
/// memory: 内存视频
enum IAppPlayerDataSourceType { network, file, memory }

/// 解码器类型配置
enum IAppPlayerDecoderType {
  /// 自动选择（默认）
  auto,
  /// 硬件解码优先
  hardwareFirst,
  /// 软件解码优先
  softwareFirst,
}
