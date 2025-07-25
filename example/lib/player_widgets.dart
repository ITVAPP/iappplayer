import 'package:flutter/material.dart';
import 'package:iapp_player/iapp_player.dart';
import 'common_utils.dart';
import 'app_localizations.dart';

// 播放器容器组件 - 统一处理播放器的外观样式
class PlayerContainer extends StatelessWidget {
  final Widget child;
  final double aspectRatio;
  final List<Color>? glowColors; // 可选的发光效果颜色
  final EdgeInsets? margin;

  const PlayerContainer({
    Key? key,
    required this.child,
    this.aspectRatio = 16 / 9,
    this.glowColors,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerMargin = margin ?? EdgeInsets.all(UIConstants.spaceMD);
    
    return Container(
      margin: containerMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.radiusLG),
        boxShadow: [
          // 基础阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: UIConstants.shadowMD,
            offset: Offset(0, UIConstants.shadowSM),
          ),
          // 发光效果（如果提供了颜色）
          if (glowColors != null && glowColors!.isNotEmpty) ...[
            BoxShadow(
              color: glowColors!.first.withOpacity(0.5),
              blurRadius: UIConstants.shadowLG,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: glowColors!.first.withOpacity(0.3),
              blurRadius: UIConstants.shadowLG * 2,
              spreadRadius: 10,
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.radiusLG),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            color: Colors.black,
            child: child,
          ),
        ),
      ),
    );
  }
}

// 播放器加载指示器
class PlayerLoadingIndicator extends StatelessWidget {
  const PlayerLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}

// 播放器错误提示组件
class PlayerErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const PlayerErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withOpacity(0.6),
            size: UIConstants.iconLogo,
          ),
          SizedBox(height: UIConstants.spaceMD),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: UIConstants.fontMD,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: UIConstants.spaceLG),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: UIConstants.spaceLG,
                  vertical: UIConstants.spaceSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 底部控制面板容器
class PlayerControlPanel extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const PlayerControlPanel({
    Key? key,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(UIConstants.spaceLG),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusXL),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// 页面背景渐变容器
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [
      const Color(0xFF1A1F3A),
      const Color(0xFF0A0E21),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: child,
    );
  }
}

// 透明AppBar组件
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const TransparentAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 播放/暂停控制按钮组件
class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const PlayPauseButton({
    Key? key,
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return ModernControlButton(
      onPressed: !isLoading ? onPressed : null,
      icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
      label: isPlaying ? l10n.pausePlay : l10n.continuePlay,
      isPrimary: isPrimary,
    );
  }
}

// 全屏控制按钮组件
class FullscreenButton extends StatelessWidget {
  final bool isFullscreen;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool showLabel;

  const FullscreenButton({
    Key? key,
    required this.isFullscreen,
    required this.isLoading,
    required this.onPressed,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (!showLabel) {
      return IconButton(
        onPressed: !isLoading ? onPressed : null,
        icon: Icon(
          isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
          color: Colors.white,
        ),
      );
    }

    return ModernControlButton(
      onPressed: !isLoading ? onPressed : null,
      icon: isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
      label: isFullscreen ? l10n.exitFullscreen : l10n.fullscreen,
    );
  }
}

// 歌词显示组件
class LyricDisplay extends StatelessWidget {
  final String? lyric;
  final TextStyle? style;

  const LyricDisplay({
    Key? key,
    this.lyric,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lyric == null || lyric!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: UIConstants.spaceSM),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
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
          child: Text(
            lyric!,
            key: ValueKey(lyric),
            style: style ?? TextStyle(
              fontSize: UIConstants.fontMD,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// 圆形控制按钮（用于上一首/下一首等）
class CircleControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isPrimary;
  final double? size;

  const CircleControlButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.isPrimary = false,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? (isPrimary ? UIConstants.buttonSizeNormal : UIConstants.buttonSizeSmall);
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? UIConstants.iconLG : UIConstants.iconMD,
            ),
          ),
        ),
      ),
    );
  }
}

// 媒体信息显示组件（标题、艺术家等）
class MediaInfoDisplay extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? currentLyric;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const MediaInfoDisplay({
    Key? key,
    required this.title,
    this.subtitle,
    this.currentLyric,
    this.titleStyle,
    this.subtitleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: UIConstants.spaceXL),
      child: Column(
        children: [
          Text(
            title,
            style: titleStyle ?? TextStyle(
              fontSize: UIConstants.fontXXL,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: UIConstants.spaceXS),
            Text(
              subtitle!,
              style: subtitleStyle ?? TextStyle(
                fontSize: UIConstants.fontLG,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (currentLyric != null) LyricDisplay(lyric: currentLyric),
        ],
      ),
    );
  }
}