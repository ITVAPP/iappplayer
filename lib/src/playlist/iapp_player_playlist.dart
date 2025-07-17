import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:flutter/material.dart';

/// 播放列表控制器
class IAppPlayerPlaylist extends StatefulWidget {
  /// 播放列表数据源
  final List<IAppPlayerDataSource> iappPlayerDataSourceList;

  /// 播放器配置
  final IAppPlayerConfiguration iappPlayerConfiguration;

  /// 播放列表配置
  final IAppPlayerPlaylistConfiguration iappPlayerPlaylistConfiguration;

  /// 构造函数，初始化播放列表及配置
  const IAppPlayerPlaylist({
    Key? key,
    required this.iappPlayerDataSourceList,
    required this.iappPlayerConfiguration,
    required this.iappPlayerPlaylistConfiguration,
  }) : super(key: key);

  @override
  IAppPlayerPlaylistState createState() => IAppPlayerPlaylistState();
}

/// 播放列表状态，用于访问播放列表控制器
class IAppPlayerPlaylistState extends State<IAppPlayerPlaylist> {
  /// 播放列表控制器实例
  IAppPlayerPlaylistController? _iappPlayerPlaylistController;

  /// 获取播放器控制器
  IAppPlayerController? get _iappPlayerController =>
      _iappPlayerPlaylistController!.iappPlayerController;

  /// 获取播放列表控制器
  IAppPlayerPlaylistController? get iappPlayerPlaylistController =>
      _iappPlayerPlaylistController;

  /// 初始化播放列表控制器
  @override
  void initState() {
    _iappPlayerPlaylistController = IAppPlayerPlaylistController(
        widget.iappPlayerDataSourceList,
        iappPlayerConfiguration: widget.iappPlayerConfiguration,
        iappPlayerPlaylistConfiguration:
            widget.iappPlayerPlaylistConfiguration);
    super.initState();
  }

  /// 构建播放列表视图
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _iappPlayerController!.getAspectRatio() ??
          IAppPlayerUtils.calculateAspectRatio(context),
      child: IAppPlayer(
        controller: _iappPlayerController!,
      ),
    );
  }

  /// 清理控制器资源
  @override
  void dispose() {
    _iappPlayerPlaylistController!.dispose();
    super.dispose();
  }
}
