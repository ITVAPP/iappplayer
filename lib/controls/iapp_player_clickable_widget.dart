import 'package:flutter/material.dart';

/// 可点击组件，支持圆角和点击涟漪效果
class IAppPlayerClickableWidget extends StatelessWidget {
  /// 子组件
  final Widget child;
  /// 点击回调
  final void Function() onTap;

  /// 构造函数，初始化点击回调和子组件
  const IAppPlayerClickableWidget({
    Key? key,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 构建圆角边框和点击效果
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
