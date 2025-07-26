import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';
import 'dart:async';

// UI设计规范常量类，统一管理界面尺寸和样式参数
class UIConstants {
  // 间距尺寸定义
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 38.0;
  
  // 圆角半径定义
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 30.0;
  
  // 按钮标准尺寸
  static const double buttonSizeSmall = 48.0;
  static const double buttonSizeNormal = 60.0;
  
  // 图标尺寸规格
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 28.0;
  static const double iconXL = 32.0;
  static const double iconLogo = 64.0;
  
  // 字体大小分级
  static const double fontSM = 14.0;
  static const double fontMD = 16.0;
  static const double fontLG = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontXXXL = 28.0;
  static const double fontXXXXL = 32.0;
  
  // 阴影模糊半径
  static const double shadowSM = 10.0;
  static const double shadowMD = 20.0;
  static const double shadowLG = 30.0;
  
  // 音乐播放器专用尺寸
  static const double musicPlayerHeight = 120.0;
  static const double musicPlayerSquareSize = 180.0;
}

// 播放器屏幕旋转处理混入类，自动管理横竖屏切换
mixin PlayerOrientationMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  IAppPlayerController? get controller; // 获取播放器控制器实例

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 注册屏幕变化监听器
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除屏幕变化监听器
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    handleOrientationChange(); // 处理屏幕方向变化事件
  }

  // 处理设备旋转时的全屏切换逻辑
  void handleOrientationChange() {
    if (controller == null || !mounted) return;
    
    // 延迟执行确保MediaQuery数据可用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.landscape) {
        if (!controller!.isFullScreen) {
          controller!.enterFullScreen(); // 横屏时进入全屏模式
        }
      } else {
        if (controller!.isFullScreen) {
          controller!.exitFullScreen(); // 竖屏时退出全屏模式
        }
      }
    });
  }
}

// 现代风格控制按钮组件类，提供统一的按钮样式
class ModernControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const ModernControlButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.radiusMD),
        gradient: isPrimary ? LinearGradient( // 主要按钮使用渐变背景
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1), // 次要按钮使用半透明背景
        boxShadow: isPrimary ? [
          BoxShadow( // 主要按钮添加阴影效果
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed, // 绑定点击事件
          borderRadius: BorderRadius.circular(UIConstants.radiusMD),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: UIConstants.spaceLG,
              vertical: UIConstants.spaceMD,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: UIConstants.iconMD,
                ),
                SizedBox(width: UIConstants.spaceSM + 4), // 间距12像素
                Text( // 显示按钮文本标签
                  label,
                  style: TextStyle(
                    fontSize: UIConstants.fontMD,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 通用圆形控制按钮组件类，用于播放控制等场景
class CircleControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isPrimary;
  final List<Color>? gradientColors;

  const CircleControlButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.isPrimary = false,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 设置默认渐变色方案
    final defaultGradient = gradientColors ?? [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
    ];

    return Container(
      width: isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall, // 根据类型设置按钮尺寸
      height: isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // 设置圆形形状
        gradient: isPrimary ? LinearGradient(colors: defaultGradient) : null, // 主要按钮使用渐变
        color: isPrimary ? null : Colors.white.withOpacity(0.1), // 次要按钮使用半透明背景
        boxShadow: isPrimary ? [
          BoxShadow( // 主要按钮添加投影
            color: defaultGradient[0].withOpacity(0.3),
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed, // 绑定点击事件
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? UIConstants.iconLG : UIConstants.iconMD, // 根据类型设置图标尺寸
            ),
          ),
        ),
      ),
    );
  }
}

// 歌词显示组件类，实时显示音乐播放时的歌词内容
class LyricDisplay extends StatefulWidget {
  final IAppPlayerController? controller;
  final TextStyle? style;
  final int maxLines;

  const LyricDisplay({
    Key? key,
    required this.controller,
    this.style,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  State<LyricDisplay> createState() => _LyricDisplayState();
}

// 歌词显示组件状态类，管理歌词更新和动画效果
class _LyricDisplayState extends State<LyricDisplay> {
  String? _currentLyric;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startListening(); // 启动歌词监听
  }

  @override
  void dispose() {
    _timer?.cancel(); // 清理定时器资源
    super.dispose();
  }

  // 启动歌词变化监听机制
  void _startListening() {
    _timer?.cancel();
    if (widget.controller != null) {
      _updateCurrentLyric(); // 初始化当前歌词
      // 每100毫秒检查歌词更新，仅在播放状态时运行
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (widget.controller?.isPlaying() ?? false) {
          _updateCurrentLyric();
        }
      });
    }
  }

  // 更新当前显示的歌词内容
  void _updateCurrentLyric() {
    if (widget.controller == null || !mounted) return;
    
    final subtitle = widget.controller!.renderedSubtitle;
    if (subtitle != null && subtitle.texts != null && subtitle.texts!.isNotEmpty) {
      final newLyric = subtitle.texts!.join(' ');
      // 仅在歌词内容真正改变时更新状态
      if (newLyric != _currentLyric) {
        setState(() {
          _currentLyric = newLyric;
        });
      }
    } else if (_currentLyric != null) {
      // 清空歌词显示
      setState(() {
        _currentLyric = null;
      });
    }
  }

  @override
  void didUpdateWidget(LyricDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _startListening(); // 控制器变化时重新启动监听
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLyric == null || _currentLyric!.isEmpty) {
      return const SizedBox.shrink(); // 无歌词时返回空组件
    }

    // 使用RepaintBoundary优化重绘性能
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(top: UIConstants.spaceSM),
        child: AnimatedSwitcher( // 添加歌词切换动画
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition( // 淡入淡出效果
              opacity: animation,
              child: ScaleTransition( // 缩放动画效果
                scale: Tween<double>(
                  begin: 0.95,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: Text( // 显示歌词文本内容
            _currentLyric!,
            key: ValueKey(_currentLyric),
            style: widget.style ?? TextStyle(
              fontSize: UIConstants.fontMD,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// 安全加载字幕文件的工具函数，处理加载异常情况
Future<String?> safeLoadSubtitle(String path) async {
  try {
    return await rootBundle.loadString(path); // 从资源包加载字幕文件
  } catch (e) {
    print('字幕加载失败: $path, 错误: $e'); // 输出错误日志
    return null; // 加载失败时返回空值
  }
}
