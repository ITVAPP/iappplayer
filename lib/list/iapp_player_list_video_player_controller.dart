import 'package:iapp_player/iapp_player.dart';

/// 列表视频播放器控制器
class IAppPlayerListVideoPlayerController {
  /// 播放器控制器实例
  IAppPlayerController? _iappPlayerController;

  /// 设置音量
  void setVolume(double volume) {
    _iappPlayerController?.setVolume(volume);
  }

  /// 暂停播放
  void pause() {
    _iappPlayerController?.pause();
  }

  /// 开始播放
  void play() {
    _iappPlayerController?.play();
  }

  /// 跳转到指定时间
  void seekTo(Duration duration) {
    _iappPlayerController?.seekTo(duration);
  }

  /// 设置播放器控制器
  // ignore: use_setters_to_change_properties
  void setIAppPlayerController(IAppPlayerController? iappPlayerController) {
    _iappPlayerController = iappPlayerController;
  }

  /// 设置与其他音频混播
  void setMixWithOthers(bool mixWithOthers) {
    _iappPlayerController?.setMixWithOthers(mixWithOthers);
  }
}
