import 'package:flutter/material.dart';

// 国际化支持类
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }
  
  // 定义支持的语言
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];
  
  // 根据语言返回对应的翻译
  String get appTitle {
    switch (locale.languageCode) {
      case 'zh':
        return 'IApp Player 示例';
      default:
        return 'IApp Player Example';
    }
  }
  
  String get videoPlayer {
    switch (locale.languageCode) {
      case 'zh':
        return '视频播放器';
      default:
        return 'Video Player';
    }
  }
  
  String get videoPlayerSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return '支持切换软硬件解码';
      default:
        return 'Support hardware/software decoding';
    }
  }
  
  String get videoList {
    switch (locale.languageCode) {
      case 'zh':
        return '视频列表';
      default:
        return 'Video Playlist';
    }
  }
  
  String get videoListSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return '支持随机和顺序播放';
      default:
        return 'Support shuffle and sequential play';
    }
  }
  
  String get musicPlayer {
    switch (locale.languageCode) {
      case 'zh':
        return '音乐播放器';
      default:
        return 'Music Player';
    }
  }
  
  String get musicPlayerSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return '支持LRC歌词显示';
      default:
        return 'Support LRC lyrics display';
    }
  }
  
  String get musicList {
    switch (locale.languageCode) {
      case 'zh':
        return '音乐列表';
      default:
        return 'Music Playlist';
    }
  }
  
  String get musicListSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return '另一种播放UI的展示';
      default:
        return 'Alternative playback UI';
    }
  }
  
  String get decoderSelection {
    switch (locale.languageCode) {
      case 'zh':
        return '解码器选择';
      default:
        return 'Decoder Selection';
    }
  }
  
  String get hardwareDecoder {
    switch (locale.languageCode) {
      case 'zh':
        return '硬件解码';
      default:
        return 'Hardware';
    }
  }
  
  String get softwareDecoder {
    switch (locale.languageCode) {
      case 'zh':
        return '软件解码';
      default:
        return 'Software';
    }
  }
  
  String get autoSelect {
    switch (locale.languageCode) {
      case 'zh':
        return '自动选择';
      default:
        return 'Auto';
    }
  }
  
  String get pausePlay {
    switch (locale.languageCode) {
      case 'zh':
        return '暂停播放';
      default:
        return 'Pause';
    }
  }
  
  String get continuePlay {
    switch (locale.languageCode) {
      case 'zh':
        return '继续播放';
      default:
        return 'Play';
    }
  }
  
  String get fullscreen {
    switch (locale.languageCode) {
      case 'zh':
        return '全屏观看';
      default:
        return 'Fullscreen';
    }
  }
  
  String get exitFullscreen {
    switch (locale.languageCode) {
      case 'zh':
        return '退出全屏';
      default:
        return 'Exit Fullscreen';
    }
  }
  
  String get playlist {
    switch (locale.languageCode) {
      case 'zh':
        return '播放列表';
      default:
        return 'Playlist';
    }
  }
  
  String videoNumber(int number) {
    switch (locale.languageCode) {
      case 'zh':
        return '视频 $number';
      default:
        return 'Video $number';
    }
  }
  
  String get shufflePlay {
    switch (locale.languageCode) {
      case 'zh':
        return '随机播放';
      default:
        return 'Shuffle';
    }
  }
  
  String get sequentialPlay {
    switch (locale.languageCode) {
      case 'zh':
        return '顺序播放';
      default:
        return 'Sequential';
    }
  }
  
  String playlistStatus(int current, int total, bool shuffleMode) {
    final mode = shuffleMode ? shufflePlay : sequentialPlay;
    return '$current / $total • $mode';
  }
  
  String get fullscreenPlay {
    switch (locale.languageCode) {
      case 'zh':
        return '全屏播放';
      default:
        return 'Fullscreen Play';
    }
  }
}

// 本地化委托
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
