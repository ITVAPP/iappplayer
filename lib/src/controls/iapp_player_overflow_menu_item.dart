import 'package:flutter/material.dart';

// 溢出菜单（三点菜单）项数据
class IAppPlayerOverflowMenuItem {
  final IconData icon; // 菜单项图标
  final String title; // 菜单项标题
  final Function() onClicked; // 菜单项点击回调

  IAppPlayerOverflowMenuItem(this.icon, this.title, this.onClicked); // 构造函数
}
