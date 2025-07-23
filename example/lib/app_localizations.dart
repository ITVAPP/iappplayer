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
    Locale('zh', 'TW'), // 繁体中文
    Locale('ja', 'JP'), // 日语
    Locale('fr', 'FR'), // 法语
    Locale('es', 'ES'), // 西班牙语
    Locale('pt', 'BR'), // 葡萄牙语（巴西）
    Locale('ru', 'RU'), // 俄语
  ];
  
  // 根据语言返回对应的翻译
  String get appTitle {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? 'IApp Player 範例' : 'IApp Player 示例';
      case 'ja':
        return 'IApp Player サンプル';
      case 'fr':
        return 'Exemple IApp Player';
      case 'es':
        return 'Ejemplo de IApp Player';
      case 'pt':
        return 'Exemplo IApp Player';
      case 'ru':
        return 'Пример IApp Player';
      default:
        return 'IApp Player Example';
    }
  }
  
  String get videoPlayer {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '影片播放器' : '视频播放器';
      case 'ja':
        return 'ビデオプレーヤー';
      case 'fr':
        return 'Lecteur Vidéo';
      case 'es':
        return 'Reproductor de Video';
      case 'pt':
        return 'Reprodutor de Vídeo';
      case 'ru':
        return 'Видеоплеер';
      default:
        return 'Video Player';
    }
  }
  
  String get videoPlayerSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '支援切換軟硬體解碼' : '支持切换软硬件解码';
      case 'ja':
        return 'ハードウェア/ソフトウェアデコードの切り替えをサポート';
      case 'fr':
        return 'Supporte le décodage matériel/logiciel';
      case 'es':
        return 'Soporta decodificación hardware/software';
      case 'pt':
        return 'Suporta decodificação hardware/software';
      case 'ru':
        return 'Поддержка аппаратного/программного декодирования';
      default:
        return 'Support hardware/software decoding';
    }
  }
  
  String get videoList {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '影片清單' : '视频列表';
      case 'ja':
        return 'ビデオプレイリスト';
      case 'fr':
        return 'Liste de Vidéos';
      case 'es':
        return 'Lista de Videos';
      case 'pt':
        return 'Lista de Vídeos';
      case 'ru':
        return 'Видео плейлист';
      default:
        return 'Video Playlist';
    }
  }
  
  String get videoListSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '支援隨機和順序播放' : '支持随机和顺序播放';
      case 'ja':
        return 'シャッフルと順次再生をサポート';
      case 'fr':
        return 'Supporte la lecture aléatoire et séquentielle';
      case 'es':
        return 'Soporta reproducción aleatoria y secuencial';
      case 'pt':
        return 'Suporta reprodução aleatória e sequencial';
      case 'ru':
        return 'Поддержка случайного и последовательного воспроизведения';
      default:
        return 'Support shuffle and sequential play';
    }
  }
  
  String get musicPlayer {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '音樂播放器' : '音乐播放器';
      case 'ja':
        return '音楽プレーヤー';
      case 'fr':
        return 'Lecteur de Musique';
      case 'es':
        return 'Reproductor de Música';
      case 'pt':
        return 'Reprodutor de Música';
      case 'ru':
        return 'Музыкальный плеер';
      default:
        return 'Music Player';
    }
  }
  
  String get musicPlayerSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '支援LRC歌詞顯示' : '支持LRC歌词显示';
      case 'ja':
        return 'LRC歌詞表示をサポート';
      case 'fr':
        return 'Supporte l\'affichage des paroles LRC';
      case 'es':
        return 'Soporta visualización de letras LRC';
      case 'pt':
        return 'Suporta exibição de letras LRC';
      case 'ru':
        return 'Поддержка отображения текстов LRC';
      default:
        return 'Support LRC lyrics display';
    }
  }
  
  String get musicList {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '音樂清單' : '音乐列表';
      case 'ja':
        return '音楽プレイリスト';
      case 'fr':
        return 'Liste de Musique';
      case 'es':
        return 'Lista de Música';
      case 'pt':
        return 'Lista de Música';
      case 'ru':
        return 'Музыкальный плейлист';
      default:
        return 'Music Playlist';
    }
  }
  
  String get musicListSubtitle {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '另一種播放UI的展示' : '另一种播放UI的展示';
      case 'ja':
        return '別の再生UIの表示';
      case 'fr':
        return 'Interface de lecture alternative';
      case 'es':
        return 'Interfaz de reproducción alternativa';
      case 'pt':
        return 'Interface de reprodução alternativa';
      case 'ru':
        return 'Альтернативный интерфейс воспроизведения';
      default:
        return 'Alternative playback UI';
    }
  }
  
  String get decoderSelection {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '解碼器選擇' : '解码器选择';
      case 'ja':
        return 'デコーダー選択';
      case 'fr':
        return 'Sélection du Décodeur';
      case 'es':
        return 'Selección de Decodificador';
      case 'pt':
        return 'Seleção de Decodificador';
      case 'ru':
        return 'Выбор декодера';
      default:
        return 'Decoder Selection';
    }
  }
  
  String get hardwareDecoder {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '硬體解碼' : '硬件解码';
      case 'ja':
        return 'ハードウェア';
      case 'fr':
        return 'Matériel';
      case 'es':
        return 'Hardware';
      case 'pt':
        return 'Hardware';
      case 'ru':
        return 'Аппаратный';
      default:
        return 'Hardware';
    }
  }
  
  String get softwareDecoder {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '軟體解碼' : '软件解码';
      case 'ja':
        return 'ソフトウェア';
      case 'fr':
        return 'Logiciel';
      case 'es':
        return 'Software';
      case 'pt':
        return 'Software';
      case 'ru':
        return 'Программный';
      default:
        return 'Software';
    }
  }
  
  String get autoSelect {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '自動選擇' : '自动选择';
      case 'ja':
        return '自動';
      case 'fr':
        return 'Auto';
      case 'es':
        return 'Auto';
      case 'pt':
        return 'Auto';
      case 'ru':
        return 'Авто';
      default:
        return 'Auto';
    }
  }
  
  String get pausePlay {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '暫停播放' : '暂停播放';
      case 'ja':
        return '一時停止';
      case 'fr':
        return 'Pause';
      case 'es':
        return 'Pausar';
      case 'pt':
        return 'Pausar';
      case 'ru':
        return 'Пауза';
      default:
        return 'Pause';
    }
  }
  
  String get continuePlay {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '繼續播放' : '继续播放';
      case 'ja':
        return '再生';
      case 'fr':
        return 'Lecture';
      case 'es':
        return 'Reproducir';
      case 'pt':
        return 'Reproduzir';
      case 'ru':
        return 'Воспроизвести';
      default:
        return 'Play';
    }
  }
  
  String get fullscreen {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '全螢幕觀看' : '全屏观看';
      case 'ja':
        return 'フルスクリーン';
      case 'fr':
        return 'Plein Écran';
      case 'es':
        return 'Pantalla Completa';
      case 'pt':
        return 'Tela Cheia';
      case 'ru':
        return 'Полный экран';
      default:
        return 'Fullscreen';
    }
  }
  
  String get exitFullscreen {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '退出全螢幕' : '退出全屏';
      case 'ja':
        return 'フルスクリーン終了';
      case 'fr':
        return 'Quitter Plein Écran';
      case 'es':
        return 'Salir de Pantalla Completa';
      case 'pt':
        return 'Sair da Tela Cheia';
      case 'ru':
        return 'Выйти из полноэкранного режима';
      default:
        return 'Exit Fullscreen';
    }
  }
  
  String get playlist {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '播放清單' : '播放列表';
      case 'ja':
        return 'プレイリスト';
      case 'fr':
        return 'Liste de Lecture';
      case 'es':
        return 'Lista de Reproducción';
      case 'pt':
        return 'Lista de Reprodução';
      case 'ru':
        return 'Плейлист';
      default:
        return 'Playlist';
    }
  }
  
  String videoNumber(int number) {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '影片 $number' : '视频 $number';
      case 'ja':
        return 'ビデオ $number';
      case 'fr':
        return 'Vidéo $number';
      case 'es':
        return 'Video $number';
      case 'pt':
        return 'Vídeo $number';
      case 'ru':
        return 'Видео $number';
      default:
        return 'Video $number';
    }
  }
  
  String get shufflePlay {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '隨機播放' : '随机播放';
      case 'ja':
        return 'シャッフル';
      case 'fr':
        return 'Aléatoire';
      case 'es':
        return 'Aleatorio';
      case 'pt':
        return 'Aleatório';
      case 'ru':
        return 'Случайный порядок';
      default:
        return 'Shuffle';
    }
  }
  
  String get sequentialPlay {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '順序播放' : '顺序播放';
      case 'ja':
        return '順次再生';
      case 'fr':
        return 'Séquentiel';
      case 'es':
        return 'Secuencial';
      case 'pt':
        return 'Sequencial';
      case 'ru':
        return 'По порядку';
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
        return locale.countryCode == 'TW' ? '全螢幕播放' : '全屏播放';
      case 'ja':
        return 'フルスクリーン再生';
      case 'fr':
        return 'Lecture Plein Écran';
      case 'es':
        return 'Reproducir en Pantalla Completa';
      case 'pt':
        return 'Reproduzir em Tela Cheia';
      case 'ru':
        return 'Полноэкранное воспроизведение';
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
    // 支持的语言代码列表
    return ['en', 'zh', 'ja', 'fr', 'es', 'pt', 'ru'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
