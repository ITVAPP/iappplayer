/// 应用程序移至后台时显示的通知配置
class IAppPlayerNotificationConfiguration {
  /// 是否启用播放器控制通知
  final bool? showNotification;
  /// 数据源标题，用于控制通知
  final String? title;
  /// 数据源作者，用于控制通知
  final String? author;
  /// 视频封面图片 URL，用于控制通知
  final String? imageUrl;
  /// 通知通道名称，仅 Android 使用
  final String? notificationChannelName;
  /// 从通知打开应用的 Activity 名称，仅 Android 使用
  final String? activityName;

  /// 构造函数，初始化通知配置
  const IAppPlayerNotificationConfiguration({
    this.showNotification,
    this.title,
    this.author,
    this.imageUrl,
    this.notificationChannelName,
    this.activityName,
  });
}
