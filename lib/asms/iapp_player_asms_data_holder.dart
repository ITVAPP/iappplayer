import 'package:iapp_player/src/asms/iapp_player_asms_audio_track.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_subtitle.dart';
import 'package:iapp_player/src/asms/iapp_player_asms_track.dart';

/// 存储 HLS/DASH 音视频轨道和字幕的数据持有者
class IAppPlayerAsmsDataHolder {
  /// 视频轨道列表
  List<IAppPlayerAsmsTrack>? tracks;
  /// 字幕轨道列表
  List<IAppPlayerAsmsSubtitle>? subtitles;
  /// 音频轨道列表
  List<IAppPlayerAsmsAudioTrack>? audios;

  /// 构造函数，初始化轨道和字幕列表
  IAppPlayerAsmsDataHolder({this.tracks, this.subtitles, this.audios});
}
