import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 导入其他页面和工具类
import 'app_localizations.dart';
import 'common_utils.dart';
import 'single_video_page.dart';
import 'playlist_page.dart';
import 'music_player_page.dart';
import 'music_playlist_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IAppPlayer Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      // 添加国际化支持
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
              // 自定义标题栏 - 减少间距
              Container(
                padding: EdgeInsets.only(
                  top: UIConstants.spaceMD, // 减少顶部间距
                  left: UIConstants.spaceLG,
                  right: UIConstants.spaceLG,
                  bottom: UIConstants.spaceMD, // 减少底部间距
                ),
                child: Column(
                  children: [
                    // 使用图片替代图标
                    Image.asset(
                      'assets/images/logo.png',
                      width: UIConstants.iconLogo,
                      height: UIConstants.iconLogo,
                    ),
                    SizedBox(height: UIConstants.spaceSM), // 减少间距
                    Text(
                      'IApp Player',
                      style: TextStyle(
                        fontSize: UIConstants.fontXXXXL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 选项卡片
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    left: UIConstants.spaceLG - 4, // 20
                    right: UIConstants.spaceLG - 4, // 20
                    bottom: UIConstants.spaceLG - 4, // 20
                    top: 0, // 第一个选项卡无上边距
                  ),
                  children: [
                    _buildModernCard(
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
                    _buildModernCard(
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
                    _buildModernCard(
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
                    _buildModernCard(
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.radiusLG),
        child: Container(
          padding: EdgeInsets.all(UIConstants.spaceMD), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusLG),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: UIConstants.shadowMD,
                offset: Offset(0, UIConstants.shadowSM),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(UIConstants.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                ),
                child: Icon(
                  icon,
                  size: UIConstants.iconXL,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: UIConstants.spaceLG - 4), // 20
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: UIConstants.fontXL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: UIConstants.spaceXS),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: UIConstants.fontSM,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
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

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
