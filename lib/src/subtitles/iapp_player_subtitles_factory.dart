import 'dart:convert';
import 'dart:io';
import 'package:iapp_player/iapp_player.dart';
import 'package:iapp_player/src/core/iapp_player_utils.dart';
import 'iapp_player_subtitle.dart';

/// 字幕格式枚举
enum SubtitleFormat { lrc, srtOrWebVtt }

/// 字幕解析工厂，处理多种字幕源
class IAppPlayerSubtitlesFactory {
  /// 预编译正则表达式
  static final RegExp _lrcTimePattern = RegExp(r'\[(?:(\d{1,2}):)?(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\]');
  static final RegExp _lrcMetaPattern = RegExp(r'^\s*\[([a-z]+):(.*?)\]', caseSensitive: false);
  static final RegExp _lrcTimePatternQuick = RegExp(r'^\s*\[\d{1,2}:\d{2}(?:\.\d{1,3})?\]');

  /// 解析字幕源为字幕列表
  static Future<List<IAppPlayerSubtitle>> parseSubtitles(IAppPlayerSubtitlesSource source) async {
    switch (source.type) {
      case IAppPlayerSubtitlesSourceType.file:
        return _parseSubtitlesFromFile(source);
      case IAppPlayerSubtitlesSourceType.network:
        return _parseSubtitlesFromNetwork(source);
      case IAppPlayerSubtitlesSourceType.memory:
        return _parseSubtitlesFromMemory(source);
      default:
        return [];
    }
  }

  /// 从文件解析字幕
  static Future<List<IAppPlayerSubtitle>> _parseSubtitlesFromFile(IAppPlayerSubtitlesSource source) async {
    try {
      final List<IAppPlayerSubtitle> subtitles = [];
      final futures = <Future<List<IAppPlayerSubtitle>>>[];

      for (final String? url in source.urls!) {
        if (url != null) {
          futures.add(_readSingleFile(url));
        }
      }

      final results = await Future.wait(futures);
      for (final result in results) {
        subtitles.addAll(result);
      }

      return subtitles;
    } catch (exception) {
      return [];
    }
  }

  /// 读取单个字幕文件
  static Future<List<IAppPlayerSubtitle>> _readSingleFile(String url) async {
    try {
      final file = File(url);
      if (file.existsSync()) {
        final String fileContent = await file.readAsString();
        final String extension = url.toLowerCase().split('.').last;
        return _parseString(fileContent, fileExtension: extension);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  /// 从网络解析字幕
  static Future<List<IAppPlayerSubtitle>> _parseSubtitlesFromNetwork(IAppPlayerSubtitlesSource source) async {
    try {
      final List<IAppPlayerSubtitle> subtitles = [];
      final futures = <Future<List<IAppPlayerSubtitle>>>[];

      for (final String? url in source.urls!) {
        if (url != null) {
          futures.add(_fetchSingleUrl(url, source.headers));
        }
      }

      final results = await Future.wait(futures);
      for (final result in results) {
        subtitles.addAll(result);
      }

      return subtitles;
    } catch (exception) {
      return [];
    }
  }

  /// 获取单个网络字幕
  static Future<List<IAppPlayerSubtitle>> _fetchSingleUrl(String url, Map<String, String>? headers) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      headers?.forEach((key, value) {
        request.headers.add(key, value);
      });
      final response = await request.close();
      final data = await response.transform(const Utf8Decoder()).join();
      final String extension = url.toLowerCase().split('.').last.split('?').first;
      return _parseString(data, fileExtension: extension);
    } catch (e) {
      return [];
    } finally {
      client.close();
    }
  }

  /// 从内存解析字幕
  static List<IAppPlayerSubtitle> _parseSubtitlesFromMemory(IAppPlayerSubtitlesSource source) {
    try {
      return _parseString(source.content!);
    } catch (exception) {
      return [];
    }
  }

  /// 解析字幕字符串，自动检测格式
  static List<IAppPlayerSubtitle> _parseString(String value, {String? fileExtension}) {
    if (fileExtension == 'lrc') {
      return _parseLrcString(value);
    }

    final SubtitleFormat format = _detectFormat(value);

    switch (format) {
      case SubtitleFormat.lrc:
        return _parseLrcString(value);
      case SubtitleFormat.srtOrWebVtt:
        return _parseSrtWebVttString(value);
    }
  }

  /// 检测字幕格式
  static SubtitleFormat _detectFormat(String value) {
    // 快速检查特征字符串
    if (value.contains(' --> ')) {
      return SubtitleFormat.srtOrWebVtt;
    }

    if (value.contains('WEBVTT')) {
      return SubtitleFormat.srtOrWebVtt;
    }

    // LRC 格式检测
    final lines = value.split('\n');
    if (lines.isEmpty) return SubtitleFormat.srtOrWebVtt;
    
    // 只检查前20行或总行数的10%，取较小值
    final int maxCheckLines = (lines.length * 0.1).toInt().clamp(5, 20);
    int lrcLineCount = 0;
    int checkLineCount = 0;

    for (int i = 0; i < maxCheckLines && i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      checkLineCount++;

      if (_lrcTimePatternQuick.hasMatch(line)) {
        lrcLineCount++;
      }
    }

    // 如果30%以上的非空行符合LRC格式，认为是LRC
    if (checkLineCount > 0 && lrcLineCount / checkLineCount > 0.3) {
      return SubtitleFormat.lrc;
    }

    return SubtitleFormat.srtOrWebVtt;
  }

  /// 解析LRC格式字幕
  static List<IAppPlayerSubtitle> _parseLrcString(String value) {
    final List<IAppPlayerSubtitle> subtitles = [];
    final lines = value.split('\n');
    final Map<Duration, String> timedSubtitlesMap = {};

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // 跳过元数据行
      if (_lrcMetaPattern.hasMatch(trimmedLine) && !_lrcTimePattern.hasMatch(trimmedLine)) {
        continue;
      }

      final matches = _lrcTimePattern.allMatches(trimmedLine);
      if (matches.isEmpty) continue;

      // 提取歌词文本
      String lyricText = trimmedLine;
      for (final match in matches) {
        lyricText = lyricText.replaceAll(match.group(0)!, '');
      }
      lyricText = lyricText.trim();

      // 解析时间标签
      for (final match in matches) {
        final String? hoursStr = match.group(1);
        final String minutesStr = match.group(2)!;
        final String secondsStr = match.group(3)!;
        final String? millisecondsStr = match.group(4);

        final int hours = hoursStr != null ? int.parse(hoursStr) : 0;
        final int minutes = int.parse(minutesStr);
        final int seconds = int.parse(secondsStr);
        
        int milliseconds = 0;
        if (millisecondsStr != null) {
          milliseconds = int.parse(millisecondsStr);
          // 标准化毫秒值
          if (millisecondsStr.length == 1) {
            milliseconds *= 100;
          } else if (millisecondsStr.length == 2) {
            milliseconds *= 10;
          }
        }

        final startTime = Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        timedSubtitlesMap[startTime] = lyricText;
      }
    }

    // 转换为列表并排序
    final timedSubtitles = timedSubtitlesMap.entries
        .map((e) => _TimedSubtitle(start: e.key, text: e.value))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    // 生成字幕对象
    for (int i = 0; i < timedSubtitles.length; i++) {
      final current = timedSubtitles[i];
      Duration endTime;

      if (i < timedSubtitles.length - 1) {
        final nextStart = timedSubtitles[i + 1].start;
        // 字幕结束时间为下一条开始前100ms
        endTime = nextStart - const Duration(milliseconds: 100);

        // 确保结束时间不早于开始时间
        if (endTime.compareTo(current.start) <= 0) {
          endTime = current.start + const Duration(milliseconds: 100);
        }
      } else {
        // 最后一条字幕默认显示3秒
        endTime = current.start + const Duration(seconds: 3);
      }

      subtitles.add(IAppPlayerSubtitle.create(
        index: i,
        start: current.start,
        end: endTime,
        texts: [current.text],
      ));
    }

    return subtitles;
  }

  /// 解析SRT或WebVTT格式字幕
  static List<IAppPlayerSubtitle> _parseSrtWebVttString(String value) {
    List<String> components = value.split('\r\n\r\n');
    if (components.length == 1) {
      components = value.split('\n\n');
    }

    if (components.length == 1) {
      return [];
    }

    final List<IAppPlayerSubtitle> subtitlesObj = [];
    final bool isWebVTT = components.any((c) => c.contains("WEBVTT"));
    for (final component in components) {
      if (component.isEmpty) {
        continue;
      }
      final subtitle = IAppPlayerSubtitle(component, isWebVTT);
      if (subtitle.start != null &&
          subtitle.end != null &&
          subtitle.texts != null) {
        subtitlesObj.add(subtitle);
      }
    }

    return subtitlesObj;
  }
}

/// 临时字幕类，用于排序
class _TimedSubtitle {
  final Duration start;
  final String text;

  _TimedSubtitle({required this.start, required this.text});
}