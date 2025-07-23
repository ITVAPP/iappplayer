import 'package:iapp_player/src/core/iapp_player_utils.dart';

/// 字幕数据处理类，解析字幕内容与时间
class IAppPlayerSubtitle {
  static const String timerSeparator = ' --> ';
  final int? index;
  final Duration? start;
  final Duration? end;
  final List<String>? texts;
  
  // 预编译正则表达式
  static final RegExp _timeComponentPattern = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})(?:[,.](\d{1,3}))?');
  static final RegExp _shortTimePattern = RegExp(r'^(\d{1,2}):(\d{2})(?:[,.](\d{1,3}))?');

  IAppPlayerSubtitle._({this.index, this.start, this.end, this.texts});

  /// 解析字幕字符串为对象
  factory IAppPlayerSubtitle(String value, bool isWebVTT) {
    try {
      final scanner = value.split('\n');
      if (scanner.length == 2) {
        return _handle2LinesSubtitles(scanner);
      }
      if (scanner.length > 2) {
        return _handle3LinesAndMoreSubtitles(scanner, isWebVTT);
      }
      return IAppPlayerSubtitle._();
    } catch (exception) {
      return IAppPlayerSubtitle._();
    }
  }

  /// 创建已解析的字幕对象
  factory IAppPlayerSubtitle.create({
    required int index,
    required Duration start,
    required Duration end,
    required List<String> texts,
  }) {
    return IAppPlayerSubtitle._(
      index: index,
      start: start,
      end: end,
      texts: texts,
    );
  }

  /// 解析两行字幕格式
  static IAppPlayerSubtitle _handle2LinesSubtitles(List<String> scanner) {
    try {
      final timeSplit = scanner[0].split(timerSeparator);
      final start = _stringToDuration(timeSplit[0]);
      final end = _stringToDuration(timeSplit[1]);
      final texts = scanner.sublist(1, scanner.length);

      return IAppPlayerSubtitle._(index: -1, start: start, end: end, texts: texts);
    } catch (exception) {
      return IAppPlayerSubtitle._();
    }
  }

  /// 解析三行及以上字幕格式
  static IAppPlayerSubtitle _handle3LinesAndMoreSubtitles(List<String> scanner, bool isWebVTT) {
    try {
      int? index = -1;
      List<String> timeSplit = [];
      int firstLineOfText = 0;
      if (scanner[0].contains(timerSeparator)) {
        timeSplit = scanner[0].split(timerSeparator);
        firstLineOfText = 1;
      } else {
        index = int.tryParse(scanner[0]);
        timeSplit = scanner[1].split(timerSeparator);
        firstLineOfText = 2;
      }

      final start = _stringToDuration(timeSplit[0]);
      final end = _stringToDuration(timeSplit[1]);
      final texts = scanner.sublist(firstLineOfText, scanner.length);
      return IAppPlayerSubtitle._(index: index, start: start, end: end, texts: texts);
    } catch (exception) {
      return IAppPlayerSubtitle._();
    }
  }

  /// 将时间字符串转换为Duration
  static Duration _stringToDuration(String value) {
    try {
      final trimmedValue = value.trim();
      
      // 处理可能的额外信息（如WebVTT的位置信息）
      final spaceIndex = trimmedValue.indexOf(' ');
      final timeValue = spaceIndex != -1 ? trimmedValue.substring(0, spaceIndex) : trimmedValue;
      
      // 尝试匹配完整时间格式 HH:MM:SS,mmm 或 HH:MM:SS.mmm
      Match? match = _timeComponentPattern.firstMatch(timeValue);
      if (match != null) {
        final hours = int.parse(match.group(1)!);
        final minutes = int.parse(match.group(2)!);
        final seconds = int.parse(match.group(3)!);
        final millisecondsStr = match.group(4) ?? '0';
        
        // 标准化毫秒值
        int milliseconds = int.parse(millisecondsStr);
        if (millisecondsStr.length == 1) {
          milliseconds *= 100;
        } else if (millisecondsStr.length == 2) {
          milliseconds *= 10;
        }
        
        return Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds
        );
      }
      
      // 尝试匹配短时间格式 MM:SS,mmm 或 MM:SS.mmm
      match = _shortTimePattern.firstMatch(timeValue);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millisecondsStr = match.group(3) ?? '0';
        
        // 标准化毫秒值
        int milliseconds = int.parse(millisecondsStr);
        if (millisecondsStr.length == 1) {
          milliseconds *= 100;
        } else if (millisecondsStr.length == 2) {
          milliseconds *= 10;
        }
        
        return Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds
        );
      }
      
      return const Duration();
    } catch (exception) {
      return const Duration();
    }
  }

  @override
  String toString() {
    return 'IAppPlayerSubtitle{index: $index, start: $start, end: $end, texts: $texts}';
  }
}