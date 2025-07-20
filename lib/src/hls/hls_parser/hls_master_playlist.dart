import 'drm_init_data.dart';
import 'format.dart';
import 'playlist.dart';
import 'rendition.dart';
import 'variant.dart';

/// HLS主播放列表，管理变体、音视频渲染及DRM初始化数据
class HlsMasterPlaylist extends HlsPlaylist {
  HlsMasterPlaylist({
    String? baseUri,
    List<String> tags = const [], // 播放列表标签列表
    this.variants = const [], // 变体列表
    this.videos = const [], // 视频渲染列表
    this.audios = const [], // 音频渲染列表
    this.subtitles = const [], // 字幕渲染列表
    this.closedCaptions = const [], // 隐藏字幕渲染列表
    this.muxedAudioFormat, // 变体中混合音频格式
    this.muxedCaptionFormats = const [], // 隐藏字幕格式列表
    bool hasIndependentSegments = false, // 是否包含独立片段
    this.variableDefinitions = const {}, // 变量定义映射
    this.sessionKeyDrmInitData = const [], // DRM会话密钥初始化数据
  })  : mediaPlaylistUrls = _getMediaPlaylistUrls(
            variants, videos, audios, subtitles, closedCaptions),
        super(
            baseUri: baseUri,
            tags: tags,
            hasIndependentSegments: hasIndependentSegments);

  /// 播放列表引用的所有媒体播放列表URL
  final List<Uri?> mediaPlaylistUrls;

  /// 播放列表声明的变体
  final List<Variant> variants;

  /// 播放列表声明的视频渲染
  final List<Rendition> videos;

  /// 播放列表声明的音频渲染
  final List<Rendition> audios;

  /// 播放列表声明的字幕渲染
  final List<Rendition> subtitles;

  /// 播放列表声明的隐藏字幕渲染
  final List<Rendition> closedCaptions;

  /// 变体中混合的音频格式，可能为null
  final Format? muxedAudioFormat;

  /// 播放列表声明的隐藏字幕格式，可能为空或null
  final List<Format>? muxedCaptionFormats;

  /// #EXT-X-DEFINE标签定义的变量
  final Map<String?, String> variableDefinitions;

  /// #EXT-X-SESSION-KEY标签衍生的DRM初始化数据
  final List<DrmInitData> sessionKeyDrmInitData;

  /// 生成优化后的媒体播放列表URL集合
  static List<Uri?> _getMediaPlaylistUrls(
      List<Variant> variants, 
      List<Rendition> videos,
      List<Rendition> audios,
      List<Rendition> subtitles,
      List<Rendition> closedCaptions) {
    
    // 计算总URL数量以预分配列表
    final int totalSize = variants.length + videos.length + audios.length + 
                         subtitles.length + closedCaptions.length;
    final uriList = List<Uri?>.filled(totalSize, null, growable: true);
    
    int index = 0;
    
    // 收集变体URL
    for (final variant in variants) {
      uriList[index++] = variant.url;
    }
    
    // 收集视频渲染URL
    for (final video in videos) {
      uriList[index++] = video.url;
    }
    
    // 收集音频渲染URL
    for (final audio in audios) {
      uriList[index++] = audio.url;
    }
    
    // 收集字幕渲染URL
    for (final subtitle in subtitles) {
      uriList[index++] = subtitle.url;
    }
    
    // 收集隐藏字幕渲染URL
    for (final closedCaption in closedCaptions) {
      uriList[index++] = closedCaption.url;
    }
    
    // 截取实际大小的URL列表
    return index < totalSize ? uriList.sublist(0, index) : uriList;
  }
}
