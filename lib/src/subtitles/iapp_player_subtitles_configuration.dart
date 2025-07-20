import 'package:flutter/material.dart';

/// 字幕配置 - 字体、颜色、边距等
class IAppPlayerSubtitlesConfiguration {
  /// 字幕字体大小
  final double fontSize;

  /// 字幕字体颜色
  final Color fontColor;

  /// 启用文本描边
  final bool outlineEnabled;

  /// 描边颜色
  final Color outlineColor;

  /// 描边大小
  final double outlineSize;

  /// 字幕字体家族
  final String fontFamily;

  /// 字幕左侧边距
  final double leftPadding;

  /// 字幕右侧边距
  final double rightPadding;

  /// 字幕底部边距
  final double bottomPadding;

  /// 字幕对齐方式
  final Alignment alignment;

  /// 字幕背景颜色
  final Color backgroundColor;
  
  /// 文字阴影效果
  final List<Shadow>? textShadows;
  
  /// 文字装饰（下划线等）
  final TextDecoration? textDecoration;
  
  /// 字体粗细
  final FontWeight? fontWeight;
  
  /// 行高
  final double? height;
  
  /// 字母间距
  final double? letterSpacing;

  const IAppPlayerSubtitlesConfiguration({
    this.fontSize = 14,
    this.fontColor = Colors.white,
    this.outlineEnabled = true,
    this.outlineColor = Colors.black,
    this.outlineSize = 2.0,
    this.fontFamily = "Roboto",
    this.leftPadding = 8.0,
    this.rightPadding = 8.0,
    this.bottomPadding = 20.0,
    this.alignment = Alignment.center,
    this.backgroundColor = Colors.transparent,
    this.textShadows,
    this.textDecoration,
    this.fontWeight,
    this.height,
    this.letterSpacing,
  });
  
  /// 获取默认阴影效果（黑色描边效果）
  static List<Shadow> get defaultShadows => [
    const Shadow(
      offset: Offset(-1.5, -1.5),
      color: Colors.black,
      blurRadius: 1.0,
    ),
    const Shadow(
      offset: Offset(1.5, -1.5),
      color: Colors.black,
      blurRadius: 1.0,
    ),
    const Shadow(
      offset: Offset(1.5, 1.5),
      color: Colors.black,
      blurRadius: 1.0,
    ),
    const Shadow(
      offset: Offset(-1.5, 1.5),
      color: Colors.black,
      blurRadius: 1.0,
    ),
  ];
  
  /// 获取柔和阴影效果
  static List<Shadow> get softShadows => [
    Shadow(
      offset: const Offset(0, 1),
      blurRadius: 4.0,
      color: Colors.black.withOpacity(0.8),
    ),
    Shadow(
      offset: const Offset(0, 1),
      blurRadius: 8.0,
      color: Colors.black.withOpacity(0.4),
    ),
  ];
}
