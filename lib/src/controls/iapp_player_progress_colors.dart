import 'package:flutter/rendering.dart';

/// 进度条颜色配置 
class IAppPlayerProgressColors {
  /// 静态缓存避免重复创建Paint对象
  static final Map<Color, Paint> _paintCache = {};
  
  IAppPlayerProgressColors({
    // 红色，完全不透明
    Color playedColor = const Color(0xFFFF0000),
    // 白色半透明，用于缓冲区
    Color bufferedColor = const Color.fromRGBO(255, 255, 255, 0.3),
    // 红色手柄（与播放进度一致）
    Color handleColor = const Color(0xFFFF0000),
    // 白色半透明背景
    Color backgroundColor = const Color.fromRGBO(255, 255, 255, 0.2),
  })  : playedPaint = _getPaint(playedColor),
        bufferedPaint = _getPaint(bufferedColor),
        handlePaint = _getPaint(handleColor),
        backgroundPaint = _getPaint(backgroundColor);
        
  /// 已播放部分画笔
  final Paint playedPaint;
  /// 缓冲部分画笔
  final Paint bufferedPaint;
  /// 控制柄画笔
  final Paint handlePaint;
  /// 背景画笔
  final Paint backgroundPaint;
  
  /// 获取或创建Paint对象
  static Paint _getPaint(Color color) {
    return _paintCache.putIfAbsent(color, () => Paint()..color = color);
  }
}
