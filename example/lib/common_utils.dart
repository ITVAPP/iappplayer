import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iapp_player/iapp_player.dart';

// UI常量定义 - 集中管理所有硬编码数字
class UIConstants {
  // 间距常量
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 38.0;
  
  // 圆角常量
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 30.0;
  
  // 按钮尺寸
  static const double buttonSizeSmall = 48.0;  // 新增：小尺寸按钮
  static const double buttonSizeNormal = 60.0;
  
  // 图标尺寸
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 28.0;
  static const double iconXL = 32.0;
  static const double iconLogo = 64.0;
  
  // 字体大小
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
  
  // 音乐播放器专用
  static const double musicPlayerHeight = 120.0;
  static const double musicPlayerSquareSize = 200.0; // 新增：单首音乐播放的正方形尺寸
}

// 屏幕旋转处理Mixin - 提取重复的旋转处理逻辑
mixin PlayerOrientationMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  IAppPlayerController? get controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    handleOrientationChange();
  }

  void handleOrientationChange() {
    if (controller == null || !mounted) return;
    
    // 延迟执行以确保 MediaQuery 可用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.landscape) {
        if (!controller!.isFullScreen) {
          controller!.enterFullScreen();
        }
      } else {
        if (controller!.isFullScreen) {
          controller!.exitFullScreen();
        }
      }
    });
  }
}

// 现代化控制按钮组件
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
        gradient: isPrimary ? LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
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
                SizedBox(width: UIConstants.spaceSM + 4), // 12
                Text(
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

// 安全读取字幕内容的辅助函数
Future<String?> safeLoadSubtitle(String path) async {
  try {
    return await rootBundle.loadString(path);
  } catch (e) {
    print('字幕加载失败: $path, 错误: $e');
    return null;
  }
}
 
