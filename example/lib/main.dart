import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'common_utils.dart';
import 'single_video_page.dart';
import 'playlist_page.dart';
import 'music_player_page.dart';
import 'music_playlist_page.dart';

void main() {
  runApp(const MyApp()); // 启动应用根组件
}

// 应用程序根组件类，配置全局主题和路由
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IAppPlayer Example',
      debugShowCheckedModeBanner: false, // 隐藏调试标识
      theme: ThemeData(
        brightness: Brightness.dark, // 设置深色主题
        primarySwatch: Colors.deepPurple, // 主色调为深紫色
        useMaterial3: true, // 启用Material Design 3样式
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // 脚手架背景色
      ),
      // 配置多语言支持代理
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales, // 支持的语言列表
      home: const HomePage(), // 设置首页组件
    );
  }
}

// 应用首页组件类，展示多媒体播放器功能选项
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // 获取本地化文本实例
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient( // 设置渐变背景
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E21),
              const Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 构建应用标题区域
              Container(
                padding: EdgeInsets.only(
                  top: UIConstants.spaceMD,
                  left: UIConstants.spaceLG,
                  right: UIConstants.spaceLG,
                  bottom: UIConstants.spaceMD,
                ),
                child: Column(
                  children: [
                    // 显示应用Logo图片
                    Image.asset(
                      'assets/images/logo.png',
                      width: UIConstants.iconLogo,
                      height: UIConstants.iconLogo,
                    ),
                    SizedBox(height: UIConstants.spaceSM),
                    Text(
                      'IApp Player', // 应用标题文本
                      style: TextStyle(
                        fontSize: UIConstants.fontXXXXL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 构建功能选项卡片列表
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    left: UIConstants.spaceLG - 4, // 左边距20像素
                    right: UIConstants.spaceLG - 4, // 右边距20像素
                    bottom: UIConstants.spaceLG - 4, // 底边距20像素
                    top: 0, // 顶部无边距
                  ),
                  children: [
                    _buildModernCard( // 构建视频播放器卡片
                      context,
                      icon: Icons.movie_outlined,
                      title: l10n.videoPlayer,
                      subtitle: l10n.videoPlayerSubtitle,
                      gradient: [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const SingleVideoExample(),
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    _buildModernCard( // 构建视频列表卡片
                      context,
                      icon: Icons.playlist_play,
                      title: l10n.videoList,
                      subtitle: l10n.videoListSubtitle,
                      gradient: [
                        const Color(0xFFf093fb),
                        const Color(0xFFf5576c),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const PlaylistExample(),
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    _buildModernCard( // 构建音乐播放器卡片
                      context,
                      icon: Icons.music_note_outlined,
                      title: l10n.musicPlayer,
                      subtitle: l10n.musicPlayerSubtitle,
                      gradient: [
                        const Color(0xFF4facfe),
                        const Color(0xFF00f2fe),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const MusicPlayerExample(),
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceMD),
                    _buildModernCard( // 构建音乐列表卡片
                      context,
                      icon: Icons.queue_music,
                      title: l10n.musicList,
                      subtitle: l10n.musicListSubtitle,
                      gradient: [
                        const Color(0xFFfa709a),
                        const Color(0xFFfee140),
                      ],
                      onTap: () => _navigateWithAnimation(
                        context,
                        const MusicPlaylistExample(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建现代风格功能卡片组件
  Widget _buildModernCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // 绑定点击事件
        borderRadius: BorderRadius.circular(UIConstants.radiusLG),
        child: Container(
          padding: EdgeInsets.all(UIConstants.spaceMD),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusLG),
            gradient: LinearGradient( // 设置卡片渐变背景
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow( // 添加阴影效果
                color: gradient[0].withOpacity(0.3),
                blurRadius: UIConstants.shadowMD,
                offset: Offset(0, UIConstants.shadowSM),
              ),
            ],
          ),
          child: Row(
            children: [
              Container( // 构建图标容器
                padding: EdgeInsets.all(UIConstants.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // 半透明白色背景
                  borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                ),
                child: Icon(
                  icon,
                  size: UIConstants.iconXL,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: UIConstants.spaceLG - 4), // 间距20像素
              Expanded( // 构建文本信息区域
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( // 显示卡片标题
                      title,
                      style: TextStyle(
                        fontSize: UIConstants.fontXL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceXS),
                    Text( // 显示卡片副标题
                      subtitle,
                      style: TextStyle(
                        fontSize: UIConstants.fontSM,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon( // 显示右箭头图标
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.8),
                size: UIConstants.iconSM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 执行带动画效果的页面导航
  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 动画起始位置
          const end = Offset.zero; // 动画结束位置
          const curve = Curves.easeInOutCubic; // 动画曲线
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition( // 创建滑动过渡动画
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
