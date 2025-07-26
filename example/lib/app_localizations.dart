import 'package:flutter/material.dart';

// 应用国际化支持类，管理多语言文本翻译
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  // 从上下文获取本地化实例
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }
  
  // 定义应用支持的语言地区列表
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // 英语
    Locale('zh', 'CN'), // 简体中文
    Locale('zh', 'TW'), // 繁体中文
    Locale('ja', 'JP'), // 日语
    Locale('fr', 'FR'), // 法语
    Locale('es', 'ES'), // 西班牙语
    Locale('pt', 'BR'), // 葡萄牙语（巴西）
    Locale('ru', 'RU'), // 俄语
  ];
  
  // 多语言文本翻译映射表，按语言代码组织
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'IApp Player Example',
      'videoPlayer': 'Video Player',
      'videoPlayerSubtitle': 'Support hardware/software decoding',
      'videoList': 'Video Playlist',
      'videoListSubtitle': 'Support shuffle and sequential play',
      'musicPlayer': 'Music Player',
      'musicPlayerSubtitle': 'Support LRC lyrics display',
      'musicList': 'Music Playlist',
      'musicListSubtitle': 'Alternative playback UI',
      'hardwareDecoder': 'Hardware',
      'softwareDecoder': 'Software',
      'pausePlay': 'Pause',
      'continuePlay': 'Play',
      'fullscreen': 'Fullscreen',
      'exitFullscreen': 'Exit Fullscreen',
      'playlist': 'Playlist',
      'videoNumber': 'Video %s',
      'shufflePlay': 'Shuffle',
      'sequentialPlay': 'Sequential',
      'fullscreenPlay': 'Fullscreen Play',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Exit Picture-in-Picture',
    },
    'zh_CN': {
      'appTitle': 'IApp Player 示例',
      'videoPlayer': '视频播放器',
      'videoPlayerSubtitle': '支持切换软硬件解码',
      'videoList': '视频列表',
      'videoListSubtitle': '支持随机和顺序播放',
      'musicPlayer': '音乐播放器',
      'musicPlayerSubtitle': '支持LRC歌词显示',
      'musicList': '音乐列表',
      'musicListSubtitle': '另一种播放UI的展示',
      'hardwareDecoder': '硬件解码',
      'softwareDecoder': '软件解码',
      'pausePlay': '暂停播放',
      'continuePlay': '继续播放',
      'fullscreen': '全屏观看',
      'exitFullscreen': '退出全屏',
      'playlist': '播放列表',
      'videoNumber': '视频 %s',
      'shufflePlay': '随机播放',
      'sequentialPlay': '顺序播放',
      'fullscreenPlay': '全屏播放',
      'pictureInPicture': '画中画',
      'exitPictureInPicture': '退出画中画',
    },
    'zh_TW': {
      'appTitle': 'IApp Player 範例',
      'videoPlayer': '影片播放器',
      'videoPlayerSubtitle': '支援切換軟硬體解碼',
      'videoList': '影片清單',
      'videoListSubtitle': '支援隨機和順序播放',
      'musicPlayer': '音樂播放器',
      'musicPlayerSubtitle': '支援LRC歌詞顯示',
      'musicList': '音樂清單',
      'musicListSubtitle': '另一種播放UI的展示',
      'hardwareDecoder': '硬體解碼',
      'softwareDecoder': '軟體解碼',
      'pausePlay': '暫停播放',
      'continuePlay': '繼續播放',
      'fullscreen': '全螢幕觀看',
      'exitFullscreen': '退出全螢幕',
      'playlist': '播放清單',
      'videoNumber': '影片 %s',
      'shufflePlay': '隨機播放',
      'sequentialPlay': '順序播放',
      'fullscreenPlay': '全螢幕播放',
      'pictureInPicture': '畫中畫',
      'exitPictureInPicture': '退出畫中畫',
    },
    'ja': {
      'appTitle': 'IApp Player サンプル',
      'videoPlayer': 'ビデオプレーヤー',
      'videoPlayerSubtitle': 'ハードウェア/ソフトウェアデコードの切り替えをサポート',
      'videoList': 'ビデオプレイリスト',
      'videoListSubtitle': 'シャッフルと順次再生をサポート',
      'musicPlayer': '音楽プレーヤー',
      'musicPlayerSubtitle': 'LRC歌詞表示をサポート',
      'musicList': '音楽プレイリスト',
      'musicListSubtitle': '別の再生UIの表示',
      'hardwareDecoder': 'ハードウェア',
      'softwareDecoder': 'ソフトウェア',
      'pausePlay': '一時停止',
      'continuePlay': '再生',
      'fullscreen': 'フルスクリーン',
      'exitFullscreen': 'フルスクリーン終了',
      'playlist': 'プレイリスト',
      'videoNumber': 'ビデオ %s',
      'shufflePlay': 'シャッフル',
      'sequentialPlay': '順次再生',
      'fullscreenPlay': 'フルスクリーン再生',
      'pictureInPicture': 'ピクチャー・イン・ピクチャー',
      'exitPictureInPicture': 'PiPを終了',
    },
    'fr': {
      'appTitle': 'Exemple IApp Player',
      'videoPlayer': 'Lecteur Vidéo',
      'videoPlayerSubtitle': 'Supporte le décodage matériel/logiciel',
      'videoList': 'Liste de Vidéos',
      'videoListSubtitle': 'Supporte la lecture aléatoire et séquentielle',
      'musicPlayer': 'Lecteur de Musique',
      'musicPlayerSubtitle': 'Supporte l\'affichage des paroles LRC',
      'musicList': 'Liste de Musique',
      'musicListSubtitle': 'Interface de lecture alternative',
      'hardwareDecoder': 'Matériel',
      'softwareDecoder': 'Logiciel',
      'pausePlay': 'Pause',
      'continuePlay': 'Lecture',
      'fullscreen': 'Plein Écran',
      'exitFullscreen': 'Quitter Plein Écran',
      'playlist': 'Liste de Lecture',
      'videoNumber': 'Vidéo %s',
      'shufflePlay': 'Aléatoire',
      'sequentialPlay': 'Séquentiel',
      'fullscreenPlay': 'Lecture Plein Écran',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Quitter Picture-in-Picture',
    },
    'es': {
      'appTitle': 'Ejemplo de IApp Player',
      'videoPlayer': 'Reproductor de Video',
      'videoPlayerSubtitle': 'Soporta decodificación hardware/software',
      'videoList': 'Lista de Videos',
      'videoListSubtitle': 'Soporta reproducción aleatoria y secuencial',
      'musicPlayer': 'Reproductor de Música',
      'musicPlayerSubtitle': 'Soporta visualización de letras LRC',
      'musicList': 'Lista de Música',
      'musicListSubtitle': 'Interfaz de reproducción alternativa',
      'hardwareDecoder': 'Hardware',
      'softwareDecoder': 'Software',
      'pausePlay': 'Pausar',
      'continuePlay': 'Reproducir',
      'fullscreen': 'Pantalla Completa',
      'exitFullscreen': 'Salir de Pantalla Completa',
      'playlist': 'Lista de Reproducción',
      'videoNumber': 'Video %s',
      'shufflePlay': 'Aleatorio',
      'sequentialPlay': 'Secuencial',
      'fullscreenPlay': 'Reproducir en Pantalla Completa',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Salir de Picture-in-Picture',
    },
    'pt': {
      'appTitle': 'Exemplo IApp Player',
      'videoPlayer': 'Reprodutor de Vídeo',
      'videoPlayerSubtitle': 'Suporta decodificação hardware/software',
      'videoList': 'Lista de Vídeos',
      'videoListSubtitle': 'Suporta reprodução aleatória e sequencial',
      'musicPlayer': 'Reprodutor de Música',
      'musicPlayerSubtitle': 'Suporta exibição de letras LRC',
      'musicList': 'Lista de Música',
      'musicListSubtitle': 'Interface de reprodução alternativa',
      'hardwareDecoder': 'Hardware',
      'softwareDecoder': 'Software',
      'pausePlay': 'Pausar',
      'continuePlay': 'Reproduzir',
      'fullscreen': 'Tela Cheia',
      'exitFullscreen': 'Sair da Tela Cheia',
      'playlist': 'Lista de Reprodução',
      'videoNumber': 'Vídeo %s',
      'shufflePlay': 'Aleatório',
      'sequentialPlay': 'Sequencial',
      'fullscreenPlay': 'Reproduzir em Tela Cheia',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Sair do Picture-in-Picture',
    },
    'ru': {
      'appTitle': 'Пример IApp Player',
      'videoPlayer': 'Видеоплеер',
      'videoPlayerSubtitle': 'Поддержка аппаратного/программного декодирования',
      'videoList': 'Видео плейлист',
      'videoListSubtitle': 'Поддержка случайного и последовательного воспроизведения',
      'musicPlayer': 'Музыкальный плеер',
      'musicPlayerSubtitle': 'Поддержка отображения текстов LRC',
      'musicList': 'Музыкальный плейлист',
      'musicListSubtitle': 'Альтернативный интерфейс воспроизведения',
      'hardwareDecoder': 'Аппаратный',
      'softwareDecoder': 'Программный',
      'pausePlay': 'Пауза',
      'continuePlay': 'Воспроизвести',
      'fullscreen': 'Полный экран',
      'exitFullscreen': 'Выйти из полноэкранного режима',
      'playlist': 'Плейлист',
      'videoNumber': 'Видео %s',
      'shufflePlay': 'Случайный порядок',
      'sequentialPlay': 'По порядку',
      'fullscreenPlay': 'Полноэкранное воспроизведение',
      'pictureInPicture': 'Картинка в картинке',
      'exitPictureInPicture': 'Выйти из картинки в картинке',
    },
  };
  
  // 获取当前语言键值，处理地区代码差异
  String get _languageKey {
    if (locale.languageCode == 'zh') {
      // 区分简体中文和繁体中文
      return locale.countryCode == 'TW' ? 'zh_TW' : 'zh_CN';
    }
    return locale.languageCode;
  }
  
  // 通用翻译获取方法，支持降级处理
  String _getValue(String key) {
    final languageMap = _localizedValues[_languageKey];
    if (languageMap != null && languageMap.containsKey(key)) {
      return languageMap[key]!; // 返回当前语言翻译
    }
    // 找不到翻译时降级到英文
    final englishMap = _localizedValues['en'];
    if (englishMap != null && englishMap.containsKey(key)) {
      return englishMap[key]!;
    }
    // 最终降级返回键名本身
    return key;
  }
  
  // 应用标题和功能模块翻译属性
  String get appTitle => _getValue('appTitle');
  String get videoPlayer => _getValue('videoPlayer');
  String get videoPlayerSubtitle => _getValue('videoPlayerSubtitle');
  String get videoList => _getValue('videoList');
  String get videoListSubtitle => _getValue('videoListSubtitle');
  String get musicPlayer => _getValue('musicPlayer');
  String get musicPlayerSubtitle => _getValue('musicPlayerSubtitle');
  String get musicList => _getValue('musicList');
  String get musicListSubtitle => _getValue('musicListSubtitle');
  
  // 播放器控制功能翻译属性
  String get hardwareDecoder => _getValue('hardwareDecoder');
  String get softwareDecoder => _getValue('softwareDecoder');
  String get pausePlay => _getValue('pausePlay');
  String get continuePlay => _getValue('continuePlay');
  String get fullscreen => _getValue('fullscreen');
  String get exitFullscreen => _getValue('exitFullscreen');
  String get playlist => _getValue('playlist');
  String get shufflePlay => _getValue('shufflePlay');
  String get sequentialPlay => _getValue('sequentialPlay');
  String get fullscreenPlay => _getValue('fullscreenPlay');
  String get pictureInPicture => _getValue('pictureInPicture');
  String get exitPictureInPicture => _getValue('exitPictureInPicture');
  
  // 生成带参数的视频编号文本
  String videoNumber(int number) {
    final template = _getValue('videoNumber');
    return template.replaceAll('%s', number.toString());
  }
  
  // 生成播放列表状态复合文本
  String playlistStatus(int current, int total, bool shuffleMode) {
    final mode = shuffleMode ? shufflePlay : sequentialPlay;
    return '$current / $total • $mode';
  }
}

// 本地化委托类，实现Flutter国际化机制
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    // 检查语言代码是否在支持列表中
    return ['en', 'zh', 'ja', 'fr', 'es', 'pt', 'ru'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale); // 创建本地化实例
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false; // 不需要重新加载
}
