import 'package:iapp_player/iapp_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 播放器配置，定义播放器行为及子配置
class IAppPlayerConfiguration {
  /// 是否自动播放视频，默认为false
  final bool autoPlay;

  /// 视频起始播放位置
  final Duration? startAt;

  /// 是否循环播放视频，默认为false
  final bool looping;

  /// 自定义错误提示组件，处理播放错误
  final Widget Function(BuildContext context, String? errorMessage)?
      errorBuilder;

  /// 视频宽高比，决定视频尺寸，默认为适应容器
  final double? aspectRatio;

  /// 视频初始化或播放前的占位组件
  final Widget? placeholder;

  /// 是否在播放前显示占位组件，默认为false
  final bool showPlaceholderUntilPlay;

  /// 占位组件是否置于播放器上层，默认为true
  final bool placeholderOnTop;

  /// 视频与控件之间的叠加组件
  final Widget? overlay;

  /// 是否默认进入全屏模式，默认为false
  final bool fullScreenByDefault;

  /// 全屏时是否允许屏幕休眠，默认为true
  final bool allowedScreenSleep;

  /// 全屏模式下的视频宽高比
  final double? fullScreenAspectRatio;

  /// 进入全屏时允许的设备方向，默认为横屏
  final List<DeviceOrientation> deviceOrientationsOnFullScreen;

  /// 退出全屏后显示的系统界面，默认为全部
  final List<SystemUiOverlay> systemOverlaysAfterFullScreen;

  /// 退出全屏后允许的设备方向，默认为全方向
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  /// 自定义全屏页面路由构造器
  final IAppPlayerRoutePageBuilder? routePageBuilder;

  /// 播放器事件监听器
  final Function(IAppPlayerEvent)? eventListener;

  /// 字幕配置
  final IAppPlayerSubtitlesConfiguration subtitlesConfiguration;

  /// 控件配置
  final IAppPlayerControlsConfiguration controlsConfiguration;

  /// 视频缩放模式，默认为填充
  final BoxFit fit;

  /// 视频旋转角度（0, 90, 180, 270），仅旋转视频区域，默认为0
  final double rotation;

  /// 播放器可见性变化时的回调
  final Function(double visibilityFraction)? playerVisibilityChangedBehavior;

  /// 播放器翻译配置，默认为英文
  final List<IAppPlayerTranslations>? translations;

  /// 是否根据视频宽高比自动检测全屏方向，默认为false
  final bool autoDetectFullscreenDeviceOrientation;

  /// 是否自动检测全屏宽高比，默认为false
  final bool autoDetectFullscreenAspectRatio;

  /// 是否处理生命周期（暂停/恢复），默认为true
  final bool handleLifecycle;

  /// 是否在播放器销毁时自动释放控制器，默认为true
  final bool autoDispose;

  /// 是否扩展填充所有可用空间，默认为true
  final bool expandToFill;

  /// 是否使用根导航器打开新页面，默认为false
  final bool useRootNavigator;

  const IAppPlayerConfiguration({
    this.aspectRatio,
    this.autoPlay = false,
    this.startAt,
    this.looping = false,
    this.fullScreenByDefault = false,
    this.placeholder,
    this.showPlaceholderUntilPlay = false,
    this.placeholderOnTop = true,
    this.overlay,
    this.errorBuilder,
    this.allowedScreenSleep = true,
    this.fullScreenAspectRatio,
    this.deviceOrientationsOnFullScreen = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    this.systemOverlaysAfterFullScreen = SystemUiOverlay.values,
    this.deviceOrientationsAfterFullScreen = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    this.routePageBuilder,
    this.eventListener,
    this.subtitlesConfiguration = const IAppPlayerSubtitlesConfiguration(),
    this.controlsConfiguration = const IAppPlayerControlsConfiguration(),
    this.fit = BoxFit.fill,
    this.rotation = 0,
    this.playerVisibilityChangedBehavior,
    this.translations,
    this.autoDetectFullscreenDeviceOrientation = false,
    this.autoDetectFullscreenAspectRatio = false,
    this.handleLifecycle = true,
    this.autoDispose = true,
    this.expandToFill = true,
    this.useRootNavigator = false,
  });

  /// 创建配置副本，仅更新指定属性，无变化时返回原实例
  IAppPlayerConfiguration copyWith({
    double? aspectRatio,
    bool? autoPlay,
    Duration? startAt,
    bool? looping,
    bool? fullScreenByDefault,
    Widget? placeholder,
    bool? showPlaceholderUntilPlay,
    bool? placeholderOnTop,
    Widget? overlay,
    bool? showControlsOnInitialize,
    Widget Function(BuildContext context, String? errorMessage)? errorBuilder,
    bool? allowedScreenSleep,
    double? fullScreenAspectRatio,
    List<DeviceOrientation>? deviceOrientationsOnFullScreen,
    List<SystemUiOverlay>? systemOverlaysAfterFullScreen,
    List<DeviceOrientation>? deviceOrientationsAfterFullScreen,
    IAppPlayerRoutePageBuilder? routePageBuilder,
    Function(IAppPlayerEvent)? eventListener,
    IAppPlayerSubtitlesConfiguration? subtitlesConfiguration,
    IAppPlayerControlsConfiguration? controlsConfiguration,
    BoxFit? fit,
    double? rotation,
    Function(double visibilityFraction)? playerVisibilityChangedBehavior,
    List<IAppPlayerTranslations>? translations,
    bool? autoDetectFullscreenDeviceOrientation,
    bool? handleLifecycle,
    bool? autoDispose,
    bool? expandToFill,
    bool? useRootNavigator,
  }) {
    /// 检查是否有实际变化，无变化则返回当前实例
    if (aspectRatio == null &&
        autoPlay == null &&
        startAt == null &&
        looping == null &&
        fullScreenByDefault == null &&
        placeholder == null &&
        showPlaceholderUntilPlay == null &&
        placeholderOnTop == null &&
        overlay == null &&
        errorBuilder == null &&
        allowedScreenSleep == null &&
        fullScreenAspectRatio == null &&
        deviceOrientationsOnFullScreen == null &&
        systemOverlaysAfterFullScreen == null &&
        deviceOrientationsAfterFullScreen == null &&
        routePageBuilder == null &&
        eventListener == null &&
        subtitlesConfiguration == null &&
        controlsConfiguration == null &&
        fit == null &&
        rotation == null &&
        playerVisibilityChangedBehavior == null &&
        translations == null &&
        autoDetectFullscreenDeviceOrientation == null &&
        handleLifecycle == null &&
        autoDispose == null &&
        expandToFill == null &&
        useRootNavigator == null) {
      return this;
    }

    return IAppPlayerConfiguration(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      autoPlay: autoPlay ?? this.autoPlay,
      startAt: startAt ?? this.startAt,
      looping: looping ?? this.looping,
      fullScreenByDefault: fullScreenByDefault ?? this.fullScreenByDefault,
      placeholder: placeholder ?? this.placeholder,
      showPlaceholderUntilPlay:
          showPlaceholderUntilPlay ?? this.showPlaceholderUntilPlay,
      placeholderOnTop: placeholderOnTop ?? this.placeholderOnTop,
      overlay: overlay ?? this.overlay,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      allowedScreenSleep: allowedScreenSleep ?? this.allowedScreenSleep,
      fullScreenAspectRatio:
          fullScreenAspectRatio ?? this.fullScreenAspectRatio,
      deviceOrientationsOnFullScreen:
          deviceOrientationsOnFullScreen ?? this.deviceOrientationsOnFullScreen,
      systemOverlaysAfterFullScreen:
          systemOverlaysAfterFullScreen ?? this.systemOverlaysAfterFullScreen,
      deviceOrientationsAfterFullScreen: deviceOrientationsAfterFullScreen ??
          this.deviceOrientationsAfterFullScreen,
      routePageBuilder: routePageBuilder ?? this.routePageBuilder,
      eventListener: eventListener ?? this.eventListener,
      subtitlesConfiguration:
          subtitlesConfiguration ?? this.subtitlesConfiguration,
      controlsConfiguration:
          controlsConfiguration ?? this.controlsConfiguration,
      fit: fit ?? this.fit,
      rotation: rotation ?? this.rotation,
      playerVisibilityChangedBehavior: playerVisibilityChangedBehavior ??
          this.playerVisibilityChangedBehavior,
      translations: translations ?? this.translations,
      autoDetectFullscreenDeviceOrientation:
          autoDetectFullscreenDeviceOrientation ??
              this.autoDetectFullscreenDeviceOrientation,
      handleLifecycle: handleLifecycle ?? this.handleLifecycle,
      autoDispose: autoDispose ?? this.autoDispose,
      expandToFill: expandToFill ?? this.expandToFill,
      useRootNavigator: useRootNavigator ?? this.useRootNavigator,
    );
  }
}
