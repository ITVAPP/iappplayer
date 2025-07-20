import 'package:iapp_player/iapp_player.dart';
import 'package:flutter/material.dart';

/// 播放器控件UI配置，定义颜色、图标及行为
class IAppPlayerControlsConfiguration {
  final Color controlBarColor; // 控件栏背景色，默认透明
  final Color textColor; // 文本颜色，默认白色
  final Color iconsColor; // 图标颜色，默认白色
  final IconData playIcon; // 播放图标，默认箭头
  final IconData pauseIcon; // 暂停图标，默认暂停
  final IconData muteIcon; // 静音图标，默认音量开启
  final IconData unMuteIcon; // 取消静音图标，默认音量关闭
  final IconData fullscreenEnableIcon; // 进入全屏图标，默认全屏
  final IconData fullscreenDisableIcon; // 退出全屏图标，默认退出全屏
  final IconData skipBackIcon; // 后退图标，默认回退10秒
  final IconData skipForwardIcon; // 快进图标，默认前进10秒
  final bool enableFullscreen; // 启用全屏功能，默认true
  final bool enableMute; // 启用静音功能，默认true
  final bool enableProgressText; // 显示进度文本，默认true
  final bool enableProgressBar; // 显示进度条，默认true
  final bool enableProgressBarDrag; // 允许拖动进度条，默认true
  final bool enablePlayPause; // 启用播放/暂停按钮，默认true
  final bool enableSkips; // 启用快进/后退功能，默认true
  final bool enableAudioTracks; // 启用音频轨道选择，默认true
  final Color progressBarPlayedColor; // 进度条已播放颜色，默认红色
  final Color progressBarHandleColor; // 进度条拖动点颜色，默认红色
  final Color progressBarBufferedColor; // 进度条缓冲颜色，默认白色半透明
  final Color progressBarBackgroundColor; // 进度条背景色，默认白色半透明
  final Duration controlsHideTime; // 控件自动隐藏时间
  final Widget Function(IAppPlayerController controller,
      Function(bool) onPlayerVisibilityChanged)? customControlsBuilder; // 自定义控件构造器
  final IAppPlayerTheme? playerTheme; // 播放器主题配置
  final bool showControls; // 显示控件，默认true
  final bool showControlsOnInitialize; // 初始化时显示控件，默认true
  final double controlBarHeight; // 控件栏高度
  final Color liveTextColor; // 直播文本颜色，默认红色
  final bool enableOverflowMenu; // 启用溢出菜单，默认true
  final bool enablePlaybackSpeed; // 启用播放速度选择，默认true
  final bool enableSubtitles; // 启用字幕功能，默认true
  final bool enableQualities; // 启用画质选择，默认true
  final bool enablePip; // 启用画中画模式，默认true
  final bool enableRetry; // 启用重试功能，默认true
  final List<IAppPlayerOverflowMenuItem> overflowMenuCustomItems; // 自定义溢出菜单项，默认空
  final IconData overflowMenuIcon; // 溢出菜单图标，默认更多
  final IconData pipMenuIcon; // 画中画菜单图标，默认画中画
  final IconData playbackSpeedIcon; // 播放速度菜单图标，默认速度
  final IconData subtitlesIcon; // 字幕菜单图标，默认字幕
  final IconData qualitiesIcon; // 画质菜单图标，默认高清
  final IconData audioTracksIcon; // 音频轨道菜单图标，默认音频
  final Color overflowMenuIconsColor; // 溢出菜单图标颜色，默认黑色
  final int forwardSkipTimeInMilliseconds; // 快进时间，默认10000毫秒
  final int backwardSkipTimeInMilliseconds; // 后退时间，默认10000毫秒
  final Color loadingColor; // 加载指示器颜色，默认白色
  final Widget? loadingWidget; // 自定义加载组件，默认空
  final Color backgroundColor; // 无视频帧时背景色，默认黑色
  final Color overflowModalColor; // 溢出菜单模态框颜色，默认白色
  final Color overflowModalTextColor; // 溢出菜单模态框文本颜色，默认黑色
  final bool audioOnly; // 音频模式开关，默认false
  final bool handleAllGestures; // 控件隐藏时吸收点击事件，默认true

  static const _whiteConfig = IAppPlayerControlsConfiguration(
    controlBarColor: Colors.white,
    textColor: Colors.black,
    iconsColor: Colors.black,
    progressBarPlayedColor: Colors.black,
    progressBarHandleColor: Colors.black,
    progressBarBufferedColor: Colors.black54,
    progressBarBackgroundColor: Colors.white70,
  ); // 白色主题静态配置

  const IAppPlayerControlsConfiguration({
    this.controlBarColor = Colors.transparent,
    this.textColor = Colors.white,
    this.iconsColor = Colors.white,
    this.playIcon = Icons.play_arrow_outlined,
    this.pauseIcon = Icons.pause_outlined,
    this.muteIcon = Icons.volume_up_outlined,
    this.unMuteIcon = Icons.volume_off_outlined,
    this.fullscreenEnableIcon = Icons.fullscreen_outlined,
    this.fullscreenDisableIcon = Icons.fullscreen_exit_outlined,
    this.skipBackIcon = Icons.replay_10_outlined,
    this.skipForwardIcon = Icons.forward_10_outlined,
    this.enableFullscreen = true,
    this.enableMute = true,
    this.enableProgressText = true,
    this.enableProgressBar = true,
    this.enableProgressBarDrag = true,
    this.enablePlayPause = true,
    this.enableSkips = true,
    this.enableAudioTracks = true,
    this.progressBarPlayedColor = const Color(0xFFFF0000),
    this.progressBarHandleColor = const Color(0xFFFF0000),
    this.progressBarBufferedColor = const Color.fromRGBO(255, 255, 255, 0.3),
    this.progressBarBackgroundColor = const Color.fromRGBO(255, 255, 255, 0.2),
    this.controlsHideTime = const Duration(milliseconds: 1000),
    this.customControlsBuilder,
    this.playerTheme,
    this.showControls = true,
    this.showControlsOnInitialize = true,
    this.controlBarHeight = 30.0,
    this.liveTextColor = Colors.red,
    this.enableOverflowMenu = true,
    this.enablePlaybackSpeed = true,
    this.enableSubtitles = true,
    this.enableQualities = true,
    this.enablePip = true,
    this.enableRetry = true,
    this.overflowMenuCustomItems = const [],
    this.overflowMenuIcon = Icons.more_vert_outlined,
    this.pipMenuIcon = Icons.picture_in_picture_outlined,
    this.playbackSpeedIcon = Icons.shutter_speed_outlined,
    this.qualitiesIcon = Icons.hd_outlined,
    this.subtitlesIcon = Icons.closed_caption_outlined,
    this.audioTracksIcon = Icons.audiotrack_outlined,
    this.overflowMenuIconsColor = Colors.black,
    this.forwardSkipTimeInMilliseconds = 10000,
    this.backwardSkipTimeInMilliseconds = 10000,
    this.loadingColor = Colors.white,
    this.loadingWidget,
    this.backgroundColor = Colors.black,
    this.overflowModalColor = Colors.white,
    this.overflowModalTextColor = Colors.black,
    this.audioOnly = false,
    this.handleAllGestures = true,
  });

  /// 返回白色主题静态配置
  factory IAppPlayerControlsConfiguration.white() => _whiteConfig;

  /// 根据主题动态生成控件配置
  factory IAppPlayerControlsConfiguration.theme(ThemeData theme) {
    return IAppPlayerControlsConfiguration(
      textColor: theme.textTheme.bodySmall?.color ?? Colors.white,
      iconsColor: theme.buttonTheme.colorScheme?.primary ?? Colors.white,
    );
  }

  /// 创建当前配置的副本，可选择性地覆盖某些字段
  IAppPlayerControlsConfiguration copyWith({
    Color? controlBarColor,
    Color? textColor,
    Color? iconsColor,
    IconData? playIcon,
    IconData? pauseIcon,
    IconData? muteIcon,
    IconData? unMuteIcon,
    IconData? fullscreenEnableIcon,
    IconData? fullscreenDisableIcon,
    IconData? skipBackIcon,
    IconData? skipForwardIcon,
    bool? enableFullscreen,
    bool? enableMute,
    bool? enableProgressText,
    bool? enableProgressBar,
    bool? enableProgressBarDrag,
    bool? enablePlayPause,
    bool? enableSkips,
    bool? enableAudioTracks,
    Color? progressBarPlayedColor,
    Color? progressBarHandleColor,
    Color? progressBarBufferedColor,
    Color? progressBarBackgroundColor,
    Duration? controlsHideTime,
    Widget Function(IAppPlayerController controller,
            Function(bool) onPlayerVisibilityChanged)?
        customControlsBuilder,
    IAppPlayerTheme? playerTheme,
    bool? showControls,
    bool? showControlsOnInitialize,
    double? controlBarHeight,
    Color? liveTextColor,
    bool? enableOverflowMenu,
    bool? enablePlaybackSpeed,
    bool? enableSubtitles,
    bool? enableQualities,
    bool? enablePip,
    bool? enableRetry,
    List<IAppPlayerOverflowMenuItem>? overflowMenuCustomItems,
    IconData? overflowMenuIcon,
    IconData? pipMenuIcon,
    IconData? playbackSpeedIcon,
    IconData? subtitlesIcon,
    IconData? qualitiesIcon,
    IconData? audioTracksIcon,
    Color? overflowMenuIconsColor,
    int? forwardSkipTimeInMilliseconds,
    int? backwardSkipTimeInMilliseconds,
    Color? loadingColor,
    Widget? loadingWidget,
    Color? backgroundColor,
    Color? overflowModalColor,
    Color? overflowModalTextColor,
    bool? audioOnly,
    bool? handleAllGestures,
  }) {
    return IAppPlayerControlsConfiguration(
      controlBarColor: controlBarColor ?? this.controlBarColor,
      textColor: textColor ?? this.textColor,
      iconsColor: iconsColor ?? this.iconsColor,
      playIcon: playIcon ?? this.playIcon,
      pauseIcon: pauseIcon ?? this.pauseIcon,
      muteIcon: muteIcon ?? this.muteIcon,
      unMuteIcon: unMuteIcon ?? this.unMuteIcon,
      fullscreenEnableIcon: fullscreenEnableIcon ?? this.fullscreenEnableIcon,
      fullscreenDisableIcon:
          fullscreenDisableIcon ?? this.fullscreenDisableIcon,
      skipBackIcon: skipBackIcon ?? this.skipBackIcon,
      skipForwardIcon: skipForwardIcon ?? this.skipForwardIcon,
      enableFullscreen: enableFullscreen ?? this.enableFullscreen,
      enableMute: enableMute ?? this.enableMute,
      enableProgressText: enableProgressText ?? this.enableProgressText,
      enableProgressBar: enableProgressBar ?? this.enableProgressBar,
      enableProgressBarDrag:
          enableProgressBarDrag ?? this.enableProgressBarDrag,
      enablePlayPause: enablePlayPause ?? this.enablePlayPause,
      enableSkips: enableSkips ?? this.enableSkips,
      enableAudioTracks: enableAudioTracks ?? this.enableAudioTracks,
      progressBarPlayedColor:
          progressBarPlayedColor ?? this.progressBarPlayedColor,
      progressBarHandleColor:
          progressBarHandleColor ?? this.progressBarHandleColor,
      progressBarBufferedColor:
          progressBarBufferedColor ?? this.progressBarBufferedColor,
      progressBarBackgroundColor:
          progressBarBackgroundColor ?? this.progressBarBackgroundColor,
      controlsHideTime: controlsHideTime ?? this.controlsHideTime,
      customControlsBuilder:
          customControlsBuilder ?? this.customControlsBuilder,
      playerTheme: playerTheme ?? this.playerTheme,
      showControls: showControls ?? this.showControls,
      showControlsOnInitialize:
          showControlsOnInitialize ?? this.showControlsOnInitialize,
      controlBarHeight: controlBarHeight ?? this.controlBarHeight,
      liveTextColor: liveTextColor ?? this.liveTextColor,
      enableOverflowMenu: enableOverflowMenu ?? this.enableOverflowMenu,
      enablePlaybackSpeed: enablePlaybackSpeed ?? this.enablePlaybackSpeed,
      enableSubtitles: enableSubtitles ?? this.enableSubtitles,
      enableQualities: enableQualities ?? this.enableQualities,
      enablePip: enablePip ?? this.enablePip,
      enableRetry: enableRetry ?? this.enableRetry,
      overflowMenuCustomItems:
          overflowMenuCustomItems ?? this.overflowMenuCustomItems,
      overflowMenuIcon: overflowMenuIcon ?? this.overflowMenuIcon,
      pipMenuIcon: pipMenuIcon ?? this.pipMenuIcon,
      playbackSpeedIcon: playbackSpeedIcon ?? this.playbackSpeedIcon,
      subtitlesIcon: subtitlesIcon ?? this.subtitlesIcon,
      qualitiesIcon: qualitiesIcon ?? this.qualitiesIcon,
      audioTracksIcon: audioTracksIcon ?? this.audioTracksIcon,
      overflowMenuIconsColor:
          overflowMenuIconsColor ?? this.overflowMenuIconsColor,
      forwardSkipTimeInMilliseconds:
          forwardSkipTimeInMilliseconds ?? this.forwardSkipTimeInMilliseconds,
      backwardSkipTimeInMilliseconds: backwardSkipTimeInMilliseconds ??
          this.backwardSkipTimeInMilliseconds,
      loadingColor: loadingColor ?? this.loadingColor,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overflowModalColor: overflowModalColor ?? this.overflowModalColor,
      overflowModalTextColor:
          overflowModalTextColor ?? this.overflowModalTextColor,
      audioOnly: audioOnly ?? this.audioOnly,
      handleAllGestures: handleAllGestures ?? this.handleAllGestures,
    );
  }
}
