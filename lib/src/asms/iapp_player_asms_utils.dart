import 'dart:convert';
import 'dart:io';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'package:iapp_player/src/dash/iapp_player_dash_utils.dart';
import 'package:iapp_player/src/hls/iapp_player_hls_utils.dart';
import 'iapp_player_asms_data_holder.dart';

/// ASMS 流解析基类
class IAppPlayerAsmsUtils {
  /// HLS 文件扩展名
  static const String _hlsExtension = "m3u8";
  /// DASH 文件扩展名
  static const String _dashExtension = "mpd";
  /// HTTP 客户端，设置 5 秒连接超时
  static final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 5);

  /// 检查 URL 是否为 HLS/DASH 数据源
  static bool isDataSourceAsms(String url) =>
      isDataSourceHls(url) || isDataSourceDash(url);

  /// 检查 URL 是否为 HLS 数据源
  static bool isDataSourceHls(String url) => url.contains(_hlsExtension);

  /// 检查 URL 是否为 DASH 数据源
  static bool isDataSourceDash(String url) => url.contains(_dashExtension);

  /// 根据流类型解析播放列表
  static Future<IAppPlayerAsmsDataHolder> parse(
      String data, String masterPlaylistUrl) async {
    return isDataSourceDash(masterPlaylistUrl)
        ? IAppPlayerDashUtils.parse(data, masterPlaylistUrl)
        : IAppPlayerHlsUtils.parse(data, masterPlaylistUrl);
  }

  /// 从指定 URL 获取数据，带可选头信息
  static Future<String?> getDataFromUrl(
    String url, [
    Map<String, String?>? headers,
  ]) async {
    try {
      final request = await _httpClient.getUrl(Uri.parse(url));
      if (headers != null) {
        headers.forEach((name, value) => request.headers.add(name, value!));
      }
      final response = await request.close();
      final dataBuffer = StringBuffer();
      await response.transform(const Utf8Decoder()).listen((content) {
        dataBuffer.write(content);
      }).asFuture<void>();
      /// 返回获取的字符串数据
      return dataBuffer.toString();
    } catch (exception) {
      /// 记录 URL 数据获取失败
      IAppPlayerUtils.log("URL 数据获取失败: $exception");
      return null;
    }
  }
}
