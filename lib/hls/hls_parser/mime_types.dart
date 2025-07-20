import 'util.dart';

/// MIME类型定义与处理
class MimeTypes {
  /// 视频基础类型
  static const String baseTypeVideo = 'video';
  /// 音频基础类型
  static const String baseTypeAudio = 'audio';
  /// 文本基础类型
  static const String baseTypeText = 'text';
  /// 应用基础类型
  static const String baseTypeApplication = 'application';
  /// MP4视频
  static const String videoMp4 = '$baseTypeVideo/mp4';
  /// WebM视频
  static const String videoWebm = '$baseTypeVideo/webm';
  /// H263视频
  static const String videoH263 = '$baseTypeVideo/3gpp';
  /// H264视频
  static const String videoH264 = '$baseTypeVideo/avc';
  /// H265视频
  static const String videoH265 = '$baseTypeVideo/hevc';
  /// VP8视频
  static const String videoVp8 = '$baseTypeVideo/x-vnd.on2.vp8';
  /// VP9视频
  static const String videoVp9 = '$baseTypeVideo/x-vnd.on2.vp9';
  /// AV1视频
  static const String videoAv1 = '$baseTypeVideo/av01';
  /// MP4V视频
  static const String videoMp4v = '$baseTypeVideo/mp4v-es';
  /// MPEG视频
  static const String videoMpeg = '$baseTypeVideo/mpeg';
  /// MPEG2视频
  static const String videoMpeg2 = '$baseTypeVideo/mpeg2';
  /// VC1视频
  static const String videoVc1 = '$baseTypeVideo/wvc1';
  /// DivX视频
  static const String videoDivx = '$baseTypeVideo/divx';
  /// Dolby Vision视频
  static const String videoDolbyVision = '$baseTypeVideo/dolby-vision';
  /// 未知视频
  static const String videoUnknown = '$baseTypeVideo/x-unknown';
  /// MP4音频
  static const String audioMp4 = '$baseTypeAudio/mp4';
  /// AAC音频
  static const String audioAac = '$baseTypeAudio/mp4a-latm';
  /// WebM音频
  static const String audioWebm = '$baseTypeAudio/webm';
  /// MPEG音频
  static const String audioMpeg = '$baseTypeAudio/mpeg';
  /// MPEG Layer 1音频
  static const String audioMpegL1 = '$baseTypeAudio/mpeg-L1';
  /// MPEG Layer 2音频
  static const String audioMpegL2 = '$baseTypeAudio/mpeg-L2';
  /// 原始音频
  static const String audioRaw = '$baseTypeAudio/raw';
  /// G.711 A-law音频
  static const String audioAlaw = '$baseTypeAudio/g711-alaw';
  /// G.711 μ-law音频
  static const String audioMlaw = '$baseTypeAudio/g711-mlaw';
  /// AC3音频
  static const String audioAc3 = '$baseTypeAudio/ac3';
  /// E-AC3音频
  static const String audioEAc3 = '$baseTypeAudio/eac3';
  /// E-AC3 JOC音频
  static const String audioEAc3Joc = '$baseTypeAudio/eac3-joc';
  /// AC4音频
  static const String audioAc4 = '$baseTypeAudio/ac4';
  /// TrueHD音频
  static const String audioTruehd = '$baseTypeAudio/true-hd';
  /// DTS音频
  static const String audioDts = '$baseTypeAudio/vnd.dts';
  /// DTS-HD音频
  static const String audioDtsHd = '$baseTypeAudio/vnd.dts.hd';
  /// DTS Express音频
  static const String audioDtsExpress = '$baseTypeAudio/vnd.dts.hd;profile=lbr';
  /// Vorbis音频
  static const String audioVorbis = '$baseTypeAudio/vorbis';
  /// Opus音频
  static const String audioOpus = '$baseTypeAudio/opus';
  /// AMR-NB音频
  static const String audioAmrNb = '$baseTypeAudio/3gpp';
  /// AMR-WB音频
  static const String audioAmrWb = '$baseTypeAudio/amr-wb';
  /// FLAC音频
  static const String audioFlac = '$baseTypeAudio/flac';
  /// ALAC音频
  static const String audioAlac = '$baseTypeAudio/alac';
  /// GSM音频
  static const String audioMsgsm = '$baseTypeAudio/gsm';
  /// 未知音频
  static const String audioUnknown = '$baseTypeAudio/x-unknown';
  /// WebVTT文本
  static const String textVtt = '$baseTypeText/vtt';
  /// SSA文本
  static const String textSsa = '$baseTypeText/x-ssa';
  /// MP4应用
  static const String applicationMp4 = '$baseTypeApplication/mp4';
  /// WebM应用
  static const String applicationWebm = '$baseTypeApplication/webm';
  /// MPEG-DASH应用
  static const String applicationMpd = '$baseTypeApplication/dash+xml';
  /// HLS M3U8应用
  static const String applicationM3u8 = '$baseTypeApplication/x-mpegURL';
  /// SmoothStreaming应用
  static const String applicationSs = '$baseTypeApplication/vnd.ms-sstr+xml';
  /// ID3元数据
  static const String applicationId3 = '$baseTypeApplication/id3';
  /// CEA-608字幕
  static const String applicationCea608 = '$baseTypeApplication/cea-608';
  /// CEA-708字幕
  static const String applicationCea708 = '$baseTypeApplication/cea-708';
  /// SubRip字幕
  static const String applicationSubrip = '$baseTypeApplication/x-subrip';
  /// TTML字幕
  static const String applicationTtml = '$baseTypeApplication/ttml+xml';
  /// QuickTime字幕
  static const String applicationTx3g = '$baseTypeApplication/x-quicktime-tx3g';
  /// MP4 VTT字幕
  static const String applicationMp4vtt = '$baseTypeApplication/x-mp4-vtt';
  /// MP4 CEA-608字幕
  static const String applicationMp4cea608 = '$baseTypeApplication/x-mp4-cea-608';
  /// RawCC字幕
  static const String applicationRawcc = '$baseTypeApplication/x-rawcc';
  /// VobSub字幕
  static const String applicationVobsub = '$baseTypeApplication/vobsub';
  /// PGS字幕
  static const String applicationPgs = '$baseTypeApplication/pgs';
  /// SCTE-35元数据
  static const String applicationScte35 = '$baseTypeApplication/x-scte35';
  /// 相机运动元数据
  static const String applicationCameraMotion = '$baseTypeApplication/x-camera-motion';
  /// EMSG元数据
  static const String applicationEmsg = '$baseTypeApplication/x-emsg';
  /// DVB字幕
  static const String applicationDvbsubs = '$baseTypeApplication/dvbsubs';
  /// EXIF元数据
  static const String applicationExif = '$baseTypeApplication/x-exif';
  /// ICY元数据
  static const String applicationIcy = '$baseTypeApplication/x-icy';
  /// HLS协议
  static const String hls = 'hls';

  /// 自定义MIME类型列表
  static final List<CustomMimeType> _customMimeTypes = [];

  /// 根据MP4对象类型获取MIME类型
  static String? _getMimeTypeFromMp4ObjectType(int objectType) {
    switch (objectType) {
      case 0x20: return videoMp4v;
      case 0x21: return videoH264;
      case 0x23: return videoH265;
      case 0x60:
      case 0x61:
      case 0x62:
      case 0x63:
      case 0x64:
      case 0x65: return videoMpeg2;
      case 0x6A: return videoMpeg;
      case 0x69:
      case 0x6B: return audioMpeg;
      case 0xA3: return videoVc1;
      case 0xB1: return videoVp9;
      case 0x40:
      case 0x66:
      case 0x67:
      case 0x68: return audioAac;
      case 0xA5: return audioAc3;
      case 0xA6: return audioEAc3;
      case 0xA9:
      case 0xAC: return audioDts;
      case 0xAA:
      case 0xAB: return audioDtsHd;
      case 0xAD: return audioOpus;
      case 0xAE: return audioAc4;
      default: return null;
    }
  }

  /// 根据编解码器值获取媒体MIME类型
  static String? getMediaMimeType(String codecValue) {
    String codec = codecValue.trim().toLowerCase();
    if (codec.startsWith('avc1') || codec.startsWith('avc3')) return videoH264;
    if (codec.startsWith('hev1') || codec.startsWith('hvc1')) return videoH265;
    if (codec.startsWith('dvav') || codec.startsWith('dva1') || codec.startsWith('dvhe') || codec.startsWith('dvh1')) return videoDolbyVision;
    if (codec.startsWith('av01')) return videoAv1;
    if (codec.startsWith('vp9') || codec.startsWith('vp09')) return videoVp9;
    if (codec.startsWith('vp8') || codec.startsWith('vp08')) return videoVp8;
    if (codec.startsWith('mp4a')) {
      String? mimeType;
      if (codec.startsWith('mp4a.')) {
        final String objectTypeString = codec.substring(5);
        if (objectTypeString.length >= 2) {
          try {
            final String objectTypeHexString = objectTypeString.substring(0, 2).toUpperCase();
            final int objectTypeInt = int.parse(objectTypeHexString, radix: 16);
            mimeType = _getMimeTypeFromMp4ObjectType(objectTypeInt);
          } on FormatException {}
        }
      }
      return mimeType ?? audioAac;
    }
    if (codec.startsWith('ac-3') || codec.startsWith('dac3')) return audioAc3;
    if (codec.startsWith('ec-3') || codec.startsWith('dec3')) return audioEAc3;
    if (codec.startsWith('ec+3')) return audioEAc3Joc;
    if (codec.startsWith('ac-4') || codec.startsWith('dac4')) return audioAc4;
    if (codec.startsWith('dtsc') || codec.startsWith('dtse')) return audioDts;
    if (codec.startsWith('dtsh') || codec.startsWith('dtsl')) return audioDtsHd;
    if (codec.startsWith('opus')) return audioOpus;
    if (codec.startsWith('vorbis')) return audioVorbis;
    if (codec.startsWith('flac')) return audioFlac;
    return getCustomMimeTypeForCodec(codec);
  }

  /// 根据编解码器获取自定义MIME类型
  static String? getCustomMimeTypeForCodec(String codec) {
    for (final customMimeType in _customMimeTypes) {
      if (codec.startsWith(customMimeType.codecPrefix)) return customMimeType.mimeType;
    }
    return null;
  }

  /// 根据MIME类型获取轨道类型
  static int getTrackType(String? mimeType) {
    if (mimeType?.isNotEmpty != true) return Util.trackTypeUnknown;
    if (isAudio(mimeType)) return Util.trackTypeAudio;
    if (isVideo(mimeType)) return Util.trackTypeVideo;
    if (isText(mimeType) ||
        [applicationCea608, applicationCea708, applicationMp4cea608, applicationSubrip,
         applicationTtml, applicationTx3g, applicationMp4vtt, applicationRawcc,
         applicationVobsub, applicationPgs, applicationDvbsubs].contains(mimeType)) {
      return Util.trackTypeText;
    }
    if ([applicationId3, applicationEmsg, applicationScte35].contains(mimeType)) {
      return Util.trackTypeMetadata;
    }
    if (applicationCameraMotion == mimeType) return Util.trackTypeCameraMotion;
    return getTrackTypeForCustomMimeType(mimeType);
  }

  /// 根据自定义MIME类型获取轨道类型
  static int getTrackTypeForCustomMimeType(String? mimeType) {
    for (final it in _customMimeTypes) {
      if (it.mimeType == mimeType) return it.trackType;
    }
    return Util.trackTypeUnknown;
  }

  /// 获取MIME类型的顶级类型
  static String? getTopLevelType(String? mimeType) {
    if (mimeType == null) return null;
    final int indexOfSlash = mimeType.indexOf('/');
    if (indexOfSlash == -1) return null;
    return mimeType.substring(0, indexOfSlash);
  }

  /// 判断是否为音频MIME类型
  static bool isAudio(String? mimeType) => baseTypeAudio == getTopLevelType(mimeType);

  /// 判断是否为视频MIME类型
  static bool isVideo(String? mimeType) => baseTypeVideo == getTopLevelType(mimeType);

  /// 判断是否为文本MIME类型
  static bool isText(String? mimeType) => baseTypeText == getTopLevelType(mimeType);

  /// 根据编解码器获取轨道类型
  static int getTrackTypeOfCodec(String codec) => getTrackType(getMediaMimeType(codec));
}

/// 自定义MIME类型结构
class CustomMimeType {
  CustomMimeType({
    required this.mimeType,
    required this.codecPrefix,
    required this.trackType,
  });
  /// MIME类型
  final String mimeType;
  /// 编解码器前缀
  final String codecPrefix;
  /// 轨道类型
  final int trackType;
}
