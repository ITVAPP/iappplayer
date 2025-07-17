import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:flutter/material.dart';

/// 列表视图专用视频播放器
class IAppPlayerListVideoPlayer extends StatefulWidget {
  /// 视频数据源
  final IAppPlayerDataSource dataSource;

  /// 播放器配置
  final IAppPlayerConfiguration configuration;

  /// 触发播放/暂停的屏幕高度比例
  final double playFraction;

  /// 是否自动播放
  final bool autoPlay;

  /// 是否自动暂停
  final bool autoPause;

  /// 播放器控制器
  final IAppPlayerListVideoPlayerController? iappPlayerListVideoPlayerController;

  /// 构造函数，初始化播放器数据源及配置
  const IAppPlayerListVideoPlayer(
    this.dataSource, {
    this.configuration = const IAppPlayerConfiguration(),
    this.playFraction = 0.6,
    this.autoPlay = true,
    this.autoPause = true,
    this.iappPlayerListVideoPlayerController,
    Key? key,
  })  : assert(playFraction >= 0.0 && playFraction <= 1.0,
            "播放比例需在0.0到1.0之间"),
        super(key: key);

  @override
  _IAppPlayerListVideoPlayerState createState() =>
      _IAppPlayerListVideoPlayerState();
}

class _IAppPlayerListVideoPlayerState
    extends State<IAppPlayerListVideoPlayer>
    with AutomaticKeepAliveClientMixin<IAppPlayerListVideoPlayer> {
  /// 播放器控制器实例
  IAppPlayerController? _iappPlayerController;

  /// 是否正在释放资源
  bool _isDisposing = false;

  /// 初始化控制器及配置
  @override
  void initState() {
    super.initState();
    _iappPlayerController = IAppPlayerController(
      widget.configuration.copyWith(
        playerVisibilityChangedBehavior: onVisibilityChanged,
      ),
      iappPlayerDataSource: widget.dataSource,
      iappPlayerPlaylistConfiguration:
          const IAppPlayerPlaylistConfiguration(),
    );

    if (widget.iappPlayerListVideoPlayerController != null) {
      widget.iappPlayerListVideoPlayerController!
          .setIAppPlayerController(_iappPlayerController);
    }
  }

  /// 清理控制器资源
  @override
  void dispose() {
    _isDisposing = true;
    _iappPlayerController?.dispose();
    super.dispose();
  }

  /// 构建视频播放器视图
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AspectRatio(
      aspectRatio: _iappPlayerController!.getAspectRatio() ??
          IAppPlayerUtils.calculateAspectRatio(context),
      child: IAppPlayer(
        key: Key("${_getUniqueKey()}_player"),
        controller: _iappPlayerController!,
      ),
    );
  }

  /// 处理可见度变化，控制播放/暂停
  void onVisibilityChanged(double visibleFraction) {
    final bool? isPlaying = _iappPlayerController!.isPlaying();
    final bool? initialized = _iappPlayerController!.isVideoInitialized();
    if (visibleFraction >= widget.playFraction) {
      if (widget.autoPlay && initialized! && !isPlaying! && !_isDisposing) {
        _iappPlayerController!.play();
      }
    } else {
      if (widget.autoPause && initialized! && isPlaying! && !_isDisposing) {
        _iappPlayerController!.pause();
      }
    }
  }

  /// 获取唯一键值
  String _getUniqueKey() => widget.dataSource.hashCode.toString();

  /// 保持页面状态
  @override
  bool get wantKeepAlive => true;
}
