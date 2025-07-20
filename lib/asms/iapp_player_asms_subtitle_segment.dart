/// 字幕分段表示，包含起止时间和 URL
class IAppPlayerAsmsSubtitleSegment {
  /// 字幕起始时间（相对于视频开始）
  final Duration startTime;
  /// 字幕结束时间（相对于视频开始）
  final Duration endTime;
  /// 字幕实际 URL（含域名和路径）
  final String realUrl;

  /// 构造函数，初始化字幕分段
  IAppPlayerAsmsSubtitleSegment(this.startTime, this.endTime, this.realUrl);
}
