import 'package:iapp_player/src/asms/iapp_player_asms_audio_track.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_data_holder.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_subtitle.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_track.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/hls/hls_parser/mime_types.dart';
import 'package:xml/xml.dart';

/// DASH 流解析工具类
class IAppPlayerDashUtils {
  /// 解析 DASH 数据，生成音视频轨道和字幕数据
  static Future<IAppPlayerAsmsDataHolder> parse(
      String data, String masterPlaylistUrl) async {
    final List<IAppPlayerAsmsTrack> tracks = [];
    final List<IAppPlayerAsmsAudioTrack> audios = [];
    final List<IAppPlayerAsmsSubtitle> subtitles = [];
    try {
      int audiosCount = 0;
      final document = XmlDocument.parse(data);
      final adaptationSets = document.findAllElements('AdaptationSet');
      for (final node in adaptationSets) {
        final mimeType = node.getAttribute('mimeType');
        if (mimeType != null) {
          if (MimeTypes.isVideo(mimeType)) {
            /// 解析视频轨道并添加到列表
            tracks.addAll(parseVideo(node));
          } else if (MimeTypes.isAudio(mimeType)) {
            /// 解析音频轨道并添加到列表
            audios.add(parseAudio(node, audiosCount));
            audiosCount += 1;
          } else if (MimeTypes.isText(mimeType)) {
            /// 解析字幕轨道并添加到列表
            subtitles.add(parseSubtitle(masterPlaylistUrl, node));
          }
        }
      }
    } catch (exception) {
      /// 记录 DASH 解析异常
      IAppPlayerUtils.log("DASH 解析失败: $exception");
    }
    /// 返回包含音视频轨道和字幕的数据持有者
    return IAppPlayerAsmsDataHolder(
        tracks: tracks, audios: audios, subtitles: subtitles);
  }

  /// 解析视频轨道信息
  static List<IAppPlayerAsmsTrack> parseVideo(XmlElement node) {
    final List<IAppPlayerAsmsTrack> tracks = [];
    final representations = node.findAllElements('Representation');
    for (final representation in representations) {
      final String? id = representation.getAttribute('id');
      final int width = int.tryParse(representation.getAttribute('width') ?? '') ?? 0;
      final int height = int.tryParse(representation.getAttribute('height') ?? '') ?? 0;
      final int bitrate = int.tryParse(representation.getAttribute('bandwidth') ?? '') ?? 0;
      final int frameRate = int.tryParse(representation.getAttribute('frameRate') ?? '') ?? 0;
      final String? codecs = representation.getAttribute('codecs');
      final String? mimeType = MimeTypes.getMediaMimeType(codecs ?? '');
      /// 添加解析后的视频轨道
      tracks.add(IAppPlayerAsmsTrack(
          id, width, height, bitrate, frameRate, codecs, mimeType));
    }
    return tracks;
  }

  /// 解析音频轨道信息
  static IAppPlayerAsmsAudioTrack parseAudio(XmlElement node, int index) {
    final String segmentAlignmentStr = node.getAttribute('segmentAlignment') ?? '';
    String? label = node.getAttribute('label');
    final String? language = node.getAttribute('lang');
    final String? mimeType = node.getAttribute('mimeType');
    label ??= language;
    /// 返回解析后的音频轨道
    return IAppPlayerAsmsAudioTrack(
        id: index,
        segmentAlignment: segmentAlignmentStr.toLowerCase() == 'true',
        label: label,
        language: language,
        mimeType: mimeType);
  }

  /// 解析字幕轨道信息，处理 URL 拼接
  static IAppPlayerAsmsSubtitle parseSubtitle(
      String masterPlaylistUrl, XmlElement node) {
    final String segmentAlignmentStr = node.getAttribute('segmentAlignment') ?? '';
    String? name = node.getAttribute('label');
    final String? language = node.getAttribute('lang');
    final String? mimeType = node.getAttribute('mimeType');
    String? url = node.getElement('Representation')?.getElement('BaseURL')?.text;
    if (url?.contains("http") == false) {
      final Uri masterPlaylistUri = Uri.parse(masterPlaylistUrl);
      final pathSegments = <String>[...masterPlaylistUri.pathSegments];
      pathSegments[pathSegments.length - 1] = url!;
      url = Uri(
              scheme: masterPlaylistUri.scheme,
              host: masterPlaylistUri.host,
              port: masterPlaylistUri.port,
              pathSegments: pathSegments)
          .toString();
    }
    if (url != null && url.startsWith('//')) {
      url = 'https:$url';
    }
    name ??= language;
    /// 返回解析后的字幕轨道
    return IAppPlayerAsmsSubtitle(
        name: name,
        language: language,
        mimeType: mimeType,
        segmentAlignment: segmentAlignmentStr.toLowerCase() == 'true',
        url: url,
        realUrls: [url ?? '']);
  }
}
