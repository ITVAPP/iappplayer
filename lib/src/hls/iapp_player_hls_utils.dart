import 'package:iapp_player/src/asms/iapp_player_asms_audio_track.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_data_holder.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_subtitle.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_subtitle_segment.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_track.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_utils.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/hls/hls_parser/hls_master_playlist.dart';
import 'package:iapp_player/src/hls/hls_parser/hls_media_playlist.dart';
import 'package:iapp_player/src/hls/hls_parser/hls_playlist_parser.dart';
import 'package:iapp_player/src/hls/hls_parser/rendition.dart';
import 'package:iapp_player/src/hls/hls_parser/segment.dart';
import 'package:iapp_player/src/hls/hls_parser/util.dart';

/// 解析HLS播放列表，提取轨道、字幕和音频信息
class IAppPlayerHlsUtils {
  static Future<IAppPlayerAsmsDataHolder> parse(
      String data, String masterPlaylistUrl) async {
    List<IAppPlayerAsmsTrack> tracks = [];
    List<IAppPlayerAsmsSubtitle> subtitles = [];
    List<IAppPlayerAsmsAudioTrack> audios = [];
    try {
      /// 创建解析器并解析主播放列表
      final parsedPlaylist = await HlsPlaylistParser.create()
          .parseString(Uri.parse(masterPlaylistUrl), data);
      
      /// 并行解析轨道、字幕和音频
      final List<List<dynamic>> list = await Future.wait([
        _parseTracksFromPlaylist(parsedPlaylist),
        _parseSubtitlesFromPlaylist(parsedPlaylist),
        _parseLanguagesFromPlaylist(parsedPlaylist)
      ]);
      tracks = list[0] as List<IAppPlayerAsmsTrack>;
      subtitles = list[1] as List<IAppPlayerAsmsSubtitle>;
      audios = list[2] as List<IAppPlayerAsmsAudioTrack>;
    } catch (exception) {
      /// 记录HLS播放列表解析错误
      IAppPlayerUtils.log("HLS播放列表解析失败: $exception");
    }
    /// 返回解析后的数据容器
    return IAppPlayerAsmsDataHolder(
        tracks: tracks, audios: audios, subtitles: subtitles);
  }

  /// 提取HLS播放列表中的视频轨道信息
  static Future<List<IAppPlayerAsmsTrack>> _parseTracksFromPlaylist(
      dynamic parsedPlaylist) async {
    final List<IAppPlayerAsmsTrack> tracks = [];
    try {
      if (parsedPlaylist is HlsMasterPlaylist) {
        /// 遍历变体提取视频轨道信息
        for (final variant in parsedPlaylist.variants) {
          tracks.add(IAppPlayerAsmsTrack('', variant.format.width,
              variant.format.height, variant.format.bitrate, 0, '', ''));
        }
      }
      if (tracks.isNotEmpty) {
        /// 添加默认轨道
        tracks.insert(0, IAppPlayerAsmsTrack.defaultTrack());
      }
    } catch (exception) {
      /// 记录视频轨道解析错误
      IAppPlayerUtils.log("视频轨道解析失败: $exception");
    }
    /// 返回视频轨道列表
    return tracks;
  }

  /// 提取HLS播放列表中的字幕信息
  static Future<List<IAppPlayerAsmsSubtitle>> _parseSubtitlesFromPlaylist(
      dynamic parsedPlaylist) async {
    final List<IAppPlayerAsmsSubtitle> subtitles = [];
    try {
      if (parsedPlaylist is HlsMasterPlaylist) {
        /// 遍历字幕变体并解析
        for (final Rendition element in parsedPlaylist.subtitles) {
          final hlsSubtitle = await _parseSubtitlesPlaylist(element);
          if (hlsSubtitle != null) {
            subtitles.add(hlsSubtitle);
          }
        }
      }
    } catch (exception) {
      /// 记录字幕解析错误
      IAppPlayerUtils.log("字幕解析失败: $exception");
    }
    /// 返回字幕列表
    return subtitles;
  }

  /// 提取HLS播放列表中的音频轨道信息
  static Future<List<IAppPlayerAsmsAudioTrack>> _parseLanguagesFromPlaylist(
      dynamic parsedPlaylist) async {
    final List<IAppPlayerAsmsAudioTrack> audios = [];
    if (parsedPlaylist is HlsMasterPlaylist) {
      /// 遍历音频变体提取信息
      for (int index = 0; index < parsedPlaylist.audios.length; index++) {
        final Rendition audio = parsedPlaylist.audios[index];
        audios.add(IAppPlayerAsmsAudioTrack(
          id: index,
          label: audio.name,
          language: audio.format.language,
          url: audio.url.toString(),
        ));
      }
    }
    /// 返回音频轨道列表
    return audios;
  }

  /// 解析HLS播放列表中的视频轨道
  static Future<List<IAppPlayerAsmsTrack>> parseTracks(
      String data, String masterPlaylistUrl) async {
    final List<IAppPlayerAsmsTrack> tracks = [];
    try {
      final parsedPlaylist = await HlsPlaylistParser.create()
          .parseString(Uri.parse(masterPlaylistUrl), data);
      return await _parseTracksFromPlaylist(parsedPlaylist);
    } catch (exception) {
      IAppPlayerUtils.log("解析视频轨道失败: $exception");
    }
    return tracks;
  }

  /// 解析HLS播放列表中的字幕
  static Future<List<IAppPlayerAsmsSubtitle>> parseSubtitles(
      String data, String masterPlaylistUrl) async {
    final List<IAppPlayerAsmsSubtitle> subtitles = [];
    try {
      final parsedPlaylist = await HlsPlaylistParser.create()
          .parseString(Uri.parse(masterPlaylistUrl), data);
      return await _parseSubtitlesFromPlaylist(parsedPlaylist);
    } catch (exception) {
      IAppPlayerUtils.log("解析字幕失败: $exception");
    }
    return subtitles;
  }

  /// 解析字幕播放列表，支持分段字幕
  static Future<IAppPlayerAsmsSubtitle?> _parseSubtitlesPlaylist(
      Rendition rendition) async {
    try {
      /// 创建字幕解析器并获取字幕数据
      final HlsPlaylistParser _hlsPlaylistParser = HlsPlaylistParser.create();
      final subtitleData =
          await IAppPlayerAsmsUtils.getDataFromUrl(rendition.url.toString());
      if (subtitleData == null) {
        return null;
      }
      /// 解析字幕播放列表
      final parsedSubtitle =
          await _hlsPlaylistParser.parseString(rendition.url, subtitleData);
      final hlsMediaPlaylist = parsedSubtitle as HlsMediaPlaylist;
      final hlsSubtitlesUrls = <String>[];
      final List<IAppPlayerAsmsSubtitleSegment> asmsSegments = [];
      final bool isSegmented = hlsMediaPlaylist.segments.length > 1;
      int microSecondsFromStart = 0;
      
      /// 构建基础URL
      final baseUrlString = rendition.url.toString();
      final lastSlashIndex = baseUrlString.lastIndexOf('/');
      final baseUrl = lastSlashIndex != -1 
          ? baseUrlString.substring(0, lastSlashIndex + 1)
          : '$baseUrlString/';
      
      /// 遍历字幕分段，生成URL和时间段
      for (final Segment segment in hlsMediaPlaylist.segments) {
        final String realUrl = segment.url!.startsWith("http")
            ? segment.url!
            : baseUrl + segment.url!;
        hlsSubtitlesUrls.add(realUrl);
        if (isSegmented) {
          /// 计算分段时间并添加字幕分段
          final nextMicroSecondsFromStart =
              microSecondsFromStart + segment.durationUs!;
          asmsSegments.add(
            IAppPlayerAsmsSubtitleSegment(
              Duration(microseconds: microSecondsFromStart),
              Duration(microseconds: nextMicroSecondsFromStart),
              realUrl,
            ),
          );
          microSecondsFromStart = nextMicroSecondsFromStart;
        }
      }
      /// 计算目标持续时间
      int targetDuration = hlsMediaPlaylist.targetDurationUs != null
          ? hlsMediaPlaylist.targetDurationUs! ~/ 1000
          : 0;
      /// 检查是否为默认字幕
      bool isDefault = rendition.format.selectionFlags != null
          ? Util.checkBitPositionIsSet(rendition.format.selectionFlags!, 1)
          : false;
      /// 返回字幕对象
      return IAppPlayerAsmsSubtitle(
          name: rendition.format.label,
          language: rendition.format.language,
          url: rendition.url.toString(),
          realUrls: hlsSubtitlesUrls,
          isSegmented: isSegmented,
          segmentsTime: targetDuration,
          segments: asmsSegments,
          isDefault: isDefault);
    } catch (exception) {
      /// 记录字幕播放列表解析错误
      IAppPlayerUtils.log("字幕播放列表解析失败: $exception");
      return null;
    }
  }

  /// 解析HLS播放列表中的音频轨道
  static Future<List<IAppPlayerAsmsAudioTrack>> parseLanguages(
      String data, String masterPlaylistUrl) async {
    final List<IAppPlayerAsmsAudioTrack> audios = [];
    try {
      final parsedPlaylist = await HlsPlaylistParser.create()
          .parseString(Uri.parse(masterPlaylistUrl), data);
      return await _parseLanguagesFromPlaylist(parsedPlaylist);
    } catch (exception) {
      IAppPlayerUtils.log("解析音频轨道失败: $exception");
    }
    return audios;
  }
}
