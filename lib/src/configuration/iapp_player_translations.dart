/// 语言翻译类
class IAppPlayerTranslations {
  /// 语言代码
  final String languageCode;
  /// 默认错误提示
  final String generalDefaultError;
  /// 无选项提示
  final String generalNone;
  /// 默认选项提示
  final String generalDefault;
  /// 重试提示
  final String generalRetry;
  /// 直播提示
  final String controlsLive;
  /// 下一个倒计时提示
  final String controlsNextIn;
  /// 播放速度菜单项
  final String overflowMenuPlaybackSpeed;
  /// 字幕菜单项
  final String overflowMenuSubtitles;
  /// 质量菜单项
  final String overflowMenuQuality;
  /// 音频轨道菜单项
  final String overflowMenuAudioTracks;
  /// 自动质量提示
  final String qualityAuto;
  /// 播放列表
  final String playlistTitle;
  /// 播放列表不可用
  final String playlistUnavailable;
  /// 视频项目（用于格式化）
  final String videoItem;
  /// 音频项目（用于格式化）
  final String audioItem;
  /// 曲目项目（用于格式化）
  final String trackItem;

  IAppPlayerTranslations({
    this.languageCode = "en",
    this.generalDefaultError = "Playback error",
    this.generalNone = "None",
    this.generalDefault = "Default",
    this.generalRetry = "Retry",
    this.controlsLive = "LIVE",
    this.controlsNextIn = "Next in",
    this.overflowMenuPlaybackSpeed = "Playback speed",
    this.overflowMenuSubtitles = "Subtitles",
    this.overflowMenuQuality = "Quality",
    this.overflowMenuAudioTracks = "Audio",
    this.qualityAuto = "Auto",
    this.playlistTitle = "Playlist",
    this.playlistUnavailable = "Playlist unavailable",
    this.videoItem = "Video {index}",
    this.audioItem = "Track {index}",
    this.trackItem = "Track {index}",
  });

  /// 波兰语翻译
  factory IAppPlayerTranslations.polish() => IAppPlayerTranslations(
        languageCode: "pl",
        generalDefaultError: "Błąd odtwarzania",
        generalNone: "Brak",
        generalDefault: "Domyślne",
        generalRetry: "Ponów",
        controlsLive: "NA ŻYWO",
        controlsNextIn: "Następny za",
        overflowMenuPlaybackSpeed: "Prędkość",
        overflowMenuSubtitles: "Napisy",
        overflowMenuQuality: "Jakość",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
        playlistTitle: "Playlista",
        playlistUnavailable: "Playlista niedostępna",
        videoItem: "Wideo {index}",
        audioItem: "Ścieżka {index}",
        trackItem: "Utwór {index}",
      );

  /// 简体中文
  factory IAppPlayerTranslations.chinese() => IAppPlayerTranslations(
        languageCode: "zh",
        generalDefaultError: "播放错误",
        generalNone: "无",
        generalDefault: "默认",
        generalRetry: "重试",
        controlsLive: "直播",
        controlsNextIn: "下一个",
        overflowMenuPlaybackSpeed: "播放速度",
        overflowMenuSubtitles: "字幕",
        overflowMenuQuality: "画质",
        overflowMenuAudioTracks: "音频",
        qualityAuto: "自动",
        playlistTitle: "播放列表",
        playlistUnavailable: "播放列表不可用",
        videoItem: "视频 {index}",
        audioItem: "音轨 {index}",
        trackItem: "曲目 {index}",
      );

  /// 繁体中文
  factory IAppPlayerTranslations.traditionalChinese() => IAppPlayerTranslations(
        languageCode: "zh-Hant",
        generalDefaultError: "播放錯誤",
        generalNone: "無",
        generalDefault: "預設",
        generalRetry: "重試",
        controlsLive: "直播",
        controlsNextIn: "下一個",
        overflowMenuPlaybackSpeed: "播放速度",
        overflowMenuSubtitles: "字幕",
        overflowMenuQuality: "畫質",
        overflowMenuAudioTracks: "音訊",
        qualityAuto: "自動",
        playlistTitle: "播放清單",
        playlistUnavailable: "播放清單不可用",
        videoItem: "影片 {index}",
        audioItem: "音軌 {index}",
        trackItem: "曲目 {index}",
      );

  /// 印地语
  factory IAppPlayerTranslations.hindi() => IAppPlayerTranslations(
        languageCode: "hi",
        generalDefaultError: "प्लेबैक त्रुटि",
        generalNone: "कोई नहीं",
        generalDefault: "डिफ़ॉल्ट",
        generalRetry: "दोबारा करें",
        controlsLive: "लाइव",
        controlsNextIn: "अगला",
        overflowMenuPlaybackSpeed: "स्पीड",
        overflowMenuSubtitles: "सबटाइटल",
        overflowMenuQuality: "क्वालिटी",
        overflowMenuAudioTracks: "ऑडियो",
        qualityAuto: "ऑटो",
        playlistTitle: "प्लेलिस्ट",
        playlistUnavailable: "प्लेलिस्ट उपलब्ध नहीं",
        videoItem: "वीडियो {index}",
        audioItem: "ट्रैक {index}",
        trackItem: "गाना {index}",
      );

  /// 阿拉伯语
  factory IAppPlayerTranslations.arabic() => IAppPlayerTranslations(
        languageCode: "ar",
        generalDefaultError: "خطأ في التشغيل",
        generalNone: "لا شيء",
        generalDefault: "افتراضي",
        generalRetry: "إعادة المحاولة",
        controlsLive: "مباشر",
        controlsNextIn: "التالي في",
        overflowMenuPlaybackSpeed: "السرعة",
        overflowMenuSubtitles: "الترجمة",
        overflowMenuQuality: "الجودة",
        overflowMenuAudioTracks: "الصوت",
        qualityAuto: "تلقائي",
        playlistTitle: "قائمة التشغيل",
        playlistUnavailable: "قائمة التشغيل غير متاحة",
        videoItem: "فيديو {index}",
        audioItem: "مقطع {index}",
        trackItem: "أغنية {index}",
      );

  /// 土耳其语
  factory IAppPlayerTranslations.turkish() => IAppPlayerTranslations(
        languageCode: "tr",
        generalDefaultError: "Oynatma hatası",
        generalNone: "Yok",
        generalDefault: "Varsayılan",
        generalRetry: "Tekrar Dene",
        controlsLive: "CANLI",
        controlsNextIn: "Sonraki",
        overflowMenuPlaybackSpeed: "Hız",
        overflowMenuSubtitles: "Altyazı",
        overflowMenuQuality: "Kalite",
        overflowMenuAudioTracks: "Ses",
        qualityAuto: "Otomatik",
        playlistTitle: "Çalma Listesi",
        playlistUnavailable: "Çalma listesi kullanılamıyor",
        videoItem: "Video {index}",
        audioItem: "Parça {index}",
        trackItem: "Şarkı {index}",
      );

  /// 越南语
  factory IAppPlayerTranslations.vietnamese() => IAppPlayerTranslations(
        languageCode: "vi",
        generalDefaultError: "Lỗi phát",
        generalNone: "Không có",
        generalDefault: "Mặc định",
        generalRetry: "Thử lại",
        controlsLive: "TRỰC TIẾP",
        controlsNextIn: "Tiếp theo",
        overflowMenuPlaybackSpeed: "Tốc độ",
        overflowMenuSubtitles: "Phụ đề",
        overflowMenuQuality: "Chất lượng",
        overflowMenuAudioTracks: "Âm thanh",
        qualityAuto: "Tự động",
        playlistTitle: "Danh sách phát",
        playlistUnavailable: "Danh sách phát không khả dụng",
        videoItem: "Video {index}",
        audioItem: "Track {index}",
        trackItem: "Bài hát {index}",
      );

  /// 西班牙语
  factory IAppPlayerTranslations.spanish() => IAppPlayerTranslations(
        languageCode: "es",
        generalDefaultError: "Error de reproducción",
        generalNone: "Ninguno",
        generalDefault: "Por defecto",
        generalRetry: "Reintentar",
        controlsLive: "EN VIVO",
        controlsNextIn: "Siguiente en",
        overflowMenuPlaybackSpeed: "Velocidad",
        overflowMenuSubtitles: "Subtítulos",
        overflowMenuQuality: "Calidad",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
        playlistTitle: "Lista de reproducción",
        playlistUnavailable: "Lista no disponible",
        videoItem: "Video {index}",
        audioItem: "Pista {index}",
        trackItem: "Canción {index}",
      );

  /// 葡萄牙语
  factory IAppPlayerTranslations.portuguese() => IAppPlayerTranslations(
        languageCode: "pt",
        generalDefaultError: "Erro de reprodução",
        generalNone: "Nenhum",
        generalDefault: "Padrão",
        generalRetry: "Tentar novamente",
        controlsLive: "AO VIVO",
        controlsNextIn: "Próximo em",
        overflowMenuPlaybackSpeed: "Velocidade",
        overflowMenuSubtitles: "Legendas",
        overflowMenuQuality: "Qualidade",
        overflowMenuAudioTracks: "Áudio",
        qualityAuto: "Auto",
        playlistTitle: "Lista de reprodução",
        playlistUnavailable: "Lista indisponível",
        videoItem: "Vídeo {index}",
        audioItem: "Faixa {index}",
        trackItem: "Música {index}",
      );

  /// 孟加拉语
  factory IAppPlayerTranslations.bengali() => IAppPlayerTranslations(
        languageCode: "bn",
        generalDefaultError: "প্লেব্যাক ত্রুটি",
        generalNone: "কিছুই না",
        generalDefault: "ডিফল্ট",
        generalRetry: "পুনরায় চেষ্টা করুন",
        controlsLive: "লাইভ",
        controlsNextIn: "পরবর্তী",
        overflowMenuPlaybackSpeed: "গতি",
        overflowMenuSubtitles: "সাবটাইটেল",
        overflowMenuQuality: "মান",
        overflowMenuAudioTracks: "অডিও",
        qualityAuto: "অটো",
        playlistTitle: "প্লেলিস্ট",
        playlistUnavailable: "প্লেলিস্ট উপলব্ধ নয়",
        videoItem: "ভিডিও {index}",
        audioItem: "ট্র্যাক {index}",
        trackItem: "গান {index}",
      );

  /// 俄语
  factory IAppPlayerTranslations.russian() => IAppPlayerTranslations(
        languageCode: "ru",
        generalDefaultError: "Ошибка воспроизведения",
        generalNone: "Нет",
        generalDefault: "По умолчанию",
        generalRetry: "Повторить",
        controlsLive: "ПРЯМОЙ ЭФИР",
        controlsNextIn: "Следующий через",
        overflowMenuPlaybackSpeed: "Скорость",
        overflowMenuSubtitles: "Субтитры",
        overflowMenuQuality: "Качество",
        overflowMenuAudioTracks: "Аудио",
        qualityAuto: "Авто",
        playlistTitle: "Плейлист",
        playlistUnavailable: "Плейлист недоступен",
        videoItem: "Видео {index}",
        audioItem: "Трек {index}",
        trackItem: "Песня {index}",
      );

  /// 日语
  factory IAppPlayerTranslations.japanese() => IAppPlayerTranslations(
        languageCode: "ja",
        generalDefaultError: "再生エラー",
        generalNone: "なし",
        generalDefault: "デフォルト",
        generalRetry: "再試行",
        controlsLive: "ライブ",
        controlsNextIn: "次まで",
        overflowMenuPlaybackSpeed: "再生速度",
        overflowMenuSubtitles: "字幕",
        overflowMenuQuality: "画質",
        overflowMenuAudioTracks: "音声",
        qualityAuto: "自動",
        playlistTitle: "プレイリスト",
        playlistUnavailable: "プレイリスト利用不可",
        videoItem: "動画 {index}",
        audioItem: "トラック {index}",
        trackItem: "曲 {index}",
      );

  /// 法语
  factory IAppPlayerTranslations.french() => IAppPlayerTranslations(
        languageCode: "fr",
        generalDefaultError: "Erreur de lecture",
        generalNone: "Aucun",
        generalDefault: "Par défaut",
        generalRetry: "Réessayer",
        controlsLive: "EN DIRECT",
        controlsNextIn: "Prochain dans",
        overflowMenuPlaybackSpeed: "Vitesse",
        overflowMenuSubtitles: "Sous-titres",
        overflowMenuQuality: "Qualité",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
        playlistTitle: "Playlist",
        playlistUnavailable: "Playlist non disponible",
        videoItem: "Vidéo {index}",
        audioItem: "Piste {index}",
        trackItem: "Morceau {index}",
      );

  /// 德语
  factory IAppPlayerTranslations.german() => IAppPlayerTranslations(
        languageCode: "de",
        generalDefaultError: "Wiedergabefehler",
        generalNone: "Keine",
        generalDefault: "Standard",
        generalRetry: "Erneut versuchen",
        controlsLive: "LIVE",
        controlsNextIn: "Nächstes in",
        overflowMenuPlaybackSpeed: "Geschwindigkeit",
        overflowMenuSubtitles: "Untertitel",
        overflowMenuQuality: "Qualität",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
        playlistTitle: "Wiedergabeliste",
        playlistUnavailable: "Wiedergabeliste nicht verfügbar",
        videoItem: "Video {index}",
        audioItem: "Spur {index}",
        trackItem: "Titel {index}",
      );

  /// 印尼语
  factory IAppPlayerTranslations.indonesian() => IAppPlayerTranslations(
        languageCode: "id",
        generalDefaultError: "Kesalahan pemutaran",
        generalNone: "Tidak ada",
        generalDefault: "Default",
        generalRetry: "Coba lagi",
        controlsLive: "LANGSUNG",
        controlsNextIn: "Berikutnya dalam",
        overflowMenuPlaybackSpeed: "Kecepatan",
        overflowMenuSubtitles: "Subtitle",
        overflowMenuQuality: "Kualitas",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Otomatis",
        playlistTitle: "Daftar Putar",
        playlistUnavailable: "Daftar putar tidak tersedia",
        videoItem: "Video {index}",
        audioItem: "Trek {index}",
        trackItem: "Lagu {index}",
      );

  /// 韩语
  factory IAppPlayerTranslations.korean() => IAppPlayerTranslations(
        languageCode: "ko",
        generalDefaultError: "재생 오류",
        generalNone: "없음",
        generalDefault: "기본",
        generalRetry: "다시 시도",
        controlsLive: "라이브",
        controlsNextIn: "다음",
        overflowMenuPlaybackSpeed: "재생 속도",
        overflowMenuSubtitles: "자막",
        overflowMenuQuality: "화질",
        overflowMenuAudioTracks: "오디오",
        qualityAuto: "자동",
        playlistTitle: "재생목록",
        playlistUnavailable: "재생목록 사용 불가",
        videoItem: "동영상 {index}",
        audioItem: "트랙 {index}",
        trackItem: "곡 {index}",
      );

  /// 意大利语
  factory IAppPlayerTranslations.italian() => IAppPlayerTranslations(
        languageCode: "it",
        generalDefaultError: "Errore di riproduzione",
        generalNone: "Nessuno",
        generalDefault: "Predefinito",
        generalRetry: "Riprova",
        controlsLive: "LIVE",
        controlsNextIn: "Prossimo tra",
        overflowMenuPlaybackSpeed: "Velocità",
        overflowMenuSubtitles: "Sottotitoli",
        overflowMenuQuality: "Qualità",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
        playlistTitle: "Playlist",
        playlistUnavailable: "Playlist non disponibile",
        videoItem: "Video {index}",
        audioItem: "Traccia {index}",
        trackItem: "Brano {index}",
      );
}
