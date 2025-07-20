import 'package:iapp_player/src/core/iapp_player_controller.dart';
import 'package:flutter/material.dart';

// 提供 IAppPlayerController 的继承组件
class IAppPlayerControllerProvider extends InheritedWidget {
  const IAppPlayerControllerProvider({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  // 控制器实例
  final IAppPlayerController controller;

  // 判断是否需要更新通知
  @override
  bool updateShouldNotify(IAppPlayerControllerProvider old) =>
      controller != old.controller;
}
