import 'package:flutter/material.dart';

// 辅助类，用于传递手势至上层
class IAppPlayerMultipleGestureDetector extends InheritedWidget {
  final void Function()? onTap; // 单次点击回调
  final void Function()? onDoubleTap; // 双击回调
  final void Function()? onLongPress; // 长按回调

  const IAppPlayerMultipleGestureDetector({
    Key? key,
    required Widget child, // 子组件
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  }) : super(key: key, child: child);

  // 获取当前上下文中的 IAppPlayerMultipleGestureDetector 实例
  static IAppPlayerMultipleGestureDetector? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<
        IAppPlayerMultipleGestureDetector>();
  }

  // 判断是否需要通知更新
  @override
  bool updateShouldNotify(IAppPlayerMultipleGestureDetector oldWidget) =>
      false;
}
