import 'package:flutter/material.dart';

// 国际化支持类 - 使用Map结构优化，减少重复代码
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
    Locale('zh', 'TW'),
    Locale('ja', 'JP'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
    Locale('pt', 'BR'),
    Locale('ru', 'RU'),
  ];

  // 获取当前语言代码（包含地区码）
  String get _localeKey {
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      return 'zh_TW';
    }
    return locale.languageCode;
  }

  // 翻译数据结构 - 使用Map替代switch-case
  static const Map<String, Map<String, String>> _translations = {
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
      'decoderSelection': 'Decoder Selection',
      'hardwareDecoder': 'Hardware',
      'softwareDecoder': 'Software',
      'pausePlay': 'Pause',
      'continuePlay': 'Play',
      'fullscreen': 'Fullscreen',
      'exitFullscreen': 'Exit Fullscreen',
      'playlist': 'Playlist',
      'videoPrefix': 'Video',
      'shufflePlay': 'Shuffle',
      'sequentialPlay': 'Sequential',
      'fullscreenPlay': 'Fullscreen Play',
      'pictureInPicture': 'Picture in Picture',
      'exitPictureInPicture': 'Exit Picture in Picture',
      'retryButton': 'Retry',
      'loadingError': 'Loading failed, please check your network connection',
    },
    'zh': {
      'appTitle': 'IApp Player 示例',
      'videoPlayer': '视频播放器',
      'videoPlayerSubtitle': '支持切换软硬件解码',
      'videoList': '视频列表',
      'videoListSubtitle': '支持随机和顺序播放',
      'musicPlayer': '音乐播放器',
      'musicPlayerSubtitle': '支持LRC歌词显示',
      'musicList': '音乐列表',
      'musicListSubtitle': '另一种播放UI的展示',
      'decoderSelection': '解码器选择',
      'hardwareDecoder': '硬件解码',
      'softwareDecoder': '软件解码',
      'pausePlay': '暂停播放',
      'continuePlay': '继续播放',
      'fullscreen': '全屏观看',
      'exitFullscreen': '退出全屏',
      'playlist': '播放列表',
      'videoPrefix': '视频',
      'shufflePlay': '随机播放',
      'sequentialPlay': '顺序播放',
      'fullscreenPlay': '全屏播放',
      'pictureInPicture': '画中画',
      'exitPictureInPicture': '退出画中画',
      'retryButton': '重试',
      'loadingError': '加载失败，请检查网络连接',
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
      'decoderSelection': '解碼器選擇',
      'hardwareDecoder': '硬體解碼',
      'softwareDecoder': '軟體解碼',
      'pausePlay': '暫停播放',
      'continuePlay': '繼續播放',
      'fullscreen': '全螢幕觀看',
      'exitFullscreen': '退出全螢幕',
      'playlist': '播放清單',
      'videoPrefix': '影片',
      'shufflePlay': '隨機播放',
      'sequentialPlay': '順序播放',
      'fullscreenPlay': '全螢幕播放',
      'pictureInPicture': '畫中畫',
      'exitPictureInPicture': '退出畫中畫',
      'retryButton': '重試',
      'loadingError': '載入失敗，請檢查網路連線',
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
      'decoderSelection': 'デコーダー選択',
      'hardwareDecoder': 'ハードウェア',
      'softwareDecoder': 'ソフトウェア',
      'pausePlay': '一時停止',
      'continuePlay': '再生',
      'fullscreen': 'フルスクリーン',
      'exitFullscreen': 'フルスクリーン終了',
      'playlist': 'プレイリスト',
      'videoPrefix': 'ビデオ',
      'shufflePlay': 'シャッフル',
      'sequentialPlay': '順次再生',
      'fullscreenPlay': 'フルスクリーン再生',
      'pictureInPicture': 'ピクチャー・イン・ピクチャー',
      'exitPictureInPicture': 'ピクチャー・イン・ピクチャー終了',
      'retryButton': '再試行',
      'loadingError': '読み込みに失敗しました。ネットワーク接続を確認してください',
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
      'decoderSelection': 'Sélection du décodeur',
      'hardwareDecoder': 'Matériel',
      'softwareDecoder': 'Logiciel',
      'pausePlay': 'Pause',
      'continuePlay': 'Lecture',
      'fullscreen': 'Plein Écran',
      'exitFullscreen': 'Quitter Plein Écran',
      'playlist': 'Liste de Lecture',
      'videoPrefix': 'Vidéo',
      'shufflePlay': 'Aléatoire',
      'sequentialPlay': 'Séquentiel',
      'fullscreenPlay': 'Lecture Plein Écran',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Quitter Picture-in-Picture',
      'retryButton': 'Réessayer',
      'loadingError': 'Échec du chargement, veuillez vérifier votre connexion réseau',
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
      'decoderSelection': 'Selección de decodificador',
      'hardwareDecoder': 'Hardware',
      'softwareDecoder': 'Software',
      'pausePlay': 'Pausar',
      'continuePlay': 'Reproducir',
      'fullscreen': 'Pantalla Completa',
      'exitFullscreen': 'Salir de Pantalla Completa',
      'playlist': 'Lista de Reproducción',
      'videoPrefix': 'Video',
      'shufflePlay': 'Aleatorio',
      'sequentialPlay': 'Secuencial',
      'fullscreenPlay': 'Reproducir en Pantalla Completa',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Salir de Picture-in-Picture',
      'retryButton': 'Reintentar',
      'loadingError': 'Error al cargar, por favor verifique su conexión a internet',
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
      'decoderSelection': 'Seleção de decodificador',
      'hardwareDecoder': 'Hardware',
      'softwareDecoder': 'Software',
      'pausePlay': 'Pausar',
      'continuePlay': 'Reproduzir',
      'fullscreen': 'Tela Cheia',
      'exitFullscreen': 'Sair da Tela Cheia',
      'playlist': 'Lista de Reprodução',
      'videoPrefix': 'Vídeo',
      'shufflePlay': 'Aleatório',
      'sequentialPlay': 'Sequencial',
      'fullscreenPlay': 'Reproduzir em Tela Cheia',
      'pictureInPicture': 'Picture-in-Picture',
      'exitPictureInPicture': 'Sair do Picture-in-Picture',
      'retryButton': 'Tentar Novamente',
      'loadingError': 'Falha ao carregar, verifique sua conexão com a internet',
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
      'decoderSelection': 'Выбор декодера',
      'hardwareDecoder': 'Аппаратный',
      'softwareDecoder': 'Программный',
      'pausePlay': 'Пауза',
      'continuePlay': 'Воспроизвести',
      'fullscreen': 'Полный экран',
      'exitFullscreen': 'Выйти из полноэкранного режима',
      'playlist': 'Плейлист',
      'videoPrefix': 'Видео',
      'shufflePlay': 'Случайный порядок',
      'sequentialPlay': 'По порядку',
      'fullscreenPlay': 'Полноэкранное воспроизведение',
      'pictureInPicture': 'Картинка в картинке',
      'exitPictureInPicture': 'Выйти из картинки в картинке',
      'retryButton': 'Повторить',
      'loadingError': 'Ошибка загрузки, проверьте подключение к интернету',
    },
  };

  // 通用的获取翻译方法
  String _getText(String key) {
    return _translations[_localeKey]?[key] ?? _translations['en']?[key] ?? key;
  }

  // 保持原有的API接口
  String get appTitle => _getText('appTitle');
  String get videoPlayer => _getText('videoPlayer');
  String get videoPlayerSubtitle => _getText('videoPlayerSubtitle');
  String get videoList => _getText('videoList');
  String get videoListSubtitle => _getText('videoListSubtitle');
  String get musicPlayer => _getText('musicPlayer');
  String get musicPlayerSubtitle => _getText('musicPlayerSubtitle');
  String get musicList => _getText('musicList');
  String get musicListSubtitle => _getText('musicListSubtitle');
  String get decoderSelection => _getText('decoderSelection');
  String get hardwareDecoder => _getText('hardwareDecoder');
  String get softwareDecoder => _getText('softwareDecoder');
  String get pausePlay => _getText('pausePlay');
  String get continuePlay => _getText('continuePlay');
  String get fullscreen => _getText('fullscreen');
  String get exitFullscreen => _getText('exitFullscreen');
  String get playlist => _getText('playlist');
  String get shufflePlay => _getText('shufflePlay');
  String get sequentialPlay => _getText('sequentialPlay');
  String get fullscreenPlay => _getText('fullscreenPlay');
  String get pictureInPicture => _getText('pictureInPicture');
  String get exitPictureInPicture => _getText('exitPictureInPicture');
  String get retryButton => _getText('retryButton');
  String get loadingError => _getText('loadingError');

  // 带参数的方法
  String videoNumber(int number) {
    return '${_getText('videoPrefix')} $number';
  }
  
  String playlistStatus(int current, int total, bool shuffleMode) {
    final mode = shuffleMode ? shufflePlay : sequentialPlay;
    return '$current / $total • $mode';
  }
}

// 本地化委托 - 保持不变
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'ja', 'fr', 'es', 'pt', 'ru'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}