/// 内部事件，用于更新组件状态
enum IAppPlayerControllerEvent {
  /// 进入全屏模式
  openFullscreen,
  /// 退出全屏模式
  hideFullscreen,
  /// 字幕切换
  changeSubtitles,
  /// 设置新数据源
  setupDataSource,
  /// 视频开始播放
  play,
}
